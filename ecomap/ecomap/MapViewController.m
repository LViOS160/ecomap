//
//  ViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "MapViewController.h"
#import "EcomapRevealViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "EcomapProblem.h"
#import "EcomapFetcher.h"
#import "Spot.h"
#import "NonHierarchicalDistanceBasedAlgorithm.h"
#import "GDefaultClusterRenderer.h"
#import "EcomapClusterRenderer.h"
#import "ProblemViewController.h"
#import "EcomapProblemFilteringMask.h"
#import "EcomapFilter.h"

#define FILTER_ON YES

@interface MapViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (nonatomic, strong) GClusterManager *clusterManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSSet *markers;
@property (nonatomic, strong) GMSCameraPosition *previousCameraPosition;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    [self mapSetup];
}

#pragma mark - Testing filter logic

- (void)testFilterLogic
{
    EcomapProblemFilteringMask *defaultMask = [[EcomapProblemFilteringMask alloc] init];
    EcomapProblemFilteringMask *mask = [[EcomapProblemFilteringMask alloc] init];
    
    NSLog(@"Start date: %@", defaultMask.fromDate);
    NSLog(@"End date: %@", defaultMask.toDate);
    NSLog(@"Problem types: %@", defaultMask.problemTypes);
    defaultMask.showSolved ? NSLog(@"Show solved: YES") : NSLog(@"Show solved: NO");
    defaultMask.showUnsolved ? NSLog(@"Show solved: YES") : NSLog(@"Show unsolved: NO");
    
    
    mask.problemTypes = @[@1, @3, @7];
    NSString *startDate = @"2015-01-01";
    NSString *endDate = @"2015-02-08";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    mask.fromDate = [dateFormatter dateFromString:startDate];
    mask.toDate = [dateFormatter dateFromString:endDate];
    mask.showSolved = NO;
    mask.showUnsolved = YES;
    
    NSLog(@"Testing mask start date: %@", mask.fromDate);
    NSLog(@"Testing mask end date: %@", mask.toDate);
    NSLog(@"Testing mask problem types: %@", mask.problemTypes);
    mask.showSolved ? NSLog(@"Testing mask show solved: YES") : NSLog(@"Show solved: NO");
    mask.showUnsolved ? NSLog(@"Testing mask show solved: YES") : NSLog(@"Show unsolved: NO");
    
    [EcomapFetcher loadAllProblemsOnCompletion:^(NSArray *problems, NSError *error) {
        NSLog(@"Before filtering");
        for(EcomapProblem *problem in problems) {
            if([problem isKindOfClass:[EcomapProblem class]]){
                NSLog(@"Problem type ID: %lu", (unsigned long)problem.problemTypesID);
            }
        }
        NSLog(@"Unfiltered count %lu", [problems count]);
        NSLog(@"After filtering");
        NSArray *filtered = [EcomapFilter filterProblemsArray:problems usingFilteringMask:mask];
        for(EcomapProblem *problem in filtered) {
            if([problem isKindOfClass:[EcomapProblem class]]){
                NSLog(@"Problem type ID: %lu", (unsigned long)problem.problemTypesID);
            }
        }
        NSLog(@"Filtered count %lu", [filtered count]);
    }];
}


#pragma mark - GMAP


- (void)mapSetup {
  
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:50.46012686633918
                                                            longitude:30.52173614501953
                                                                 zoom:6];
    
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = YES;
    [self.view insertSubview:self.mapView atIndex:0];
    [self startStandardUpdates];
    [EcomapFetcher loadAllProblemsOnCompletion:^(NSArray *problems, NSError *error) {

#warning Testing filter
        
        if(FILTER_ON) {
            EcomapProblemFilteringMask *mask = [[EcomapProblemFilteringMask alloc] init];
            
            mask.problemTypes = @[@1, @3, @7];
            NSString *startDate = @"2015-01-01";
            NSString *endDate = @"2015-02-08";
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            mask.fromDate = [dateFormatter dateFromString:startDate];
            mask.toDate = [dateFormatter dateFromString:endDate];
            mask.showSolved = NO;
            mask.showUnsolved = YES;
            
            NSArray *filteredProblems = [EcomapFilter filterProblemsArray:problems usingFilteringMask:mask];
            
            for(EcomapProblem *problem in filteredProblems) {
                if([problem isKindOfClass:[EcomapProblem class]]){
                    Spot* spot = [self generateSpot:problem];
                    [self.clusterManager addItem:spot];
                }
            }
        } else {
            for(EcomapProblem *problem in problems) {
                if([problem isKindOfClass:[EcomapProblem class]]){
                    Spot* spot = [self generateSpot:problem];
                    [self.clusterManager addItem:spot];
                }
            }
        }
        
        [self.mapView setDelegate:self];
        [self.clusterManager cluster];
        
    }];
    self.clusterManager = [GClusterManager managerWithMapView:self.mapView
                                                algorithm:[[NonHierarchicalDistanceBasedAlgorithm alloc] init]
                                                 renderer:[[EcomapClusterRenderer alloc] initWithMapView:self.mapView]];
    
   
}

- (void)customSetup
{    
    EcomapRevealViewController *revealViewController = (EcomapRevealViewController *)self.revealViewController;
    if ( revealViewController )
    {
        revealViewController.mapViewController = self.navigationController;
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
}

- (void)startStandardUpdates
{
    if (self.locationManager == nil)
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.locationManager.distanceFilter = 500; // meters
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    GMSCameraPosition *position = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:17];
    GMSCameraUpdate *update = [GMSCameraUpdate setCamera:position];
    [self.mapView moveCamera:update];
    
}

- (Spot*)generateSpot:(EcomapProblem *)problem
{
    Spot* spot = [[Spot alloc] init];
    spot.problem = problem;
    spot.location = CLLocationCoordinate2DMake(problem.latitude, problem.longtitude);
    return spot;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.mapView.frame = self.view.frame;
    self.mapView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 5,
                                        0,
                                        self.bottomLayoutGuide.length + 5,
                                        0);
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)cameraPosition {
    assert(mapView == _mapView);
    
    // Don't re-compute clusters if the map has just been panned/tilted/rotated.
    GMSCameraPosition *position = [mapView camera];
    if (self.previousCameraPosition != nil && self.previousCameraPosition.zoom == position.zoom) {
        return;
    }
    self.previousCameraPosition = [mapView camera];
    
    [self.clusterManager cluster];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    if([marker.userData isKindOfClass:[EcomapProblem class]]) {
        [self performSegueWithIdentifier:@"Show problem" sender:marker];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show problem"]){
        if([segue.destinationViewController isKindOfClass:[ProblemViewController class]]){
            ProblemViewController *problemVC = (ProblemViewController *)segue.destinationViewController;
            problemVC.problem = ((GMSMarker *)sender).userData;
        }
    }
}

#pragma mark - Utility methods

+ (NSSet *)markersFromProblems:(NSArray *)problems
{
    NSMutableSet *markers = [[NSMutableSet alloc] initWithCapacity:problems.count];
    for(EcomapProblem *problem in problems) {
        if([problem isKindOfClass:[EcomapProblem class]])
            [markers addObject:[MapViewController markerFromProblem:problem]];
    }
    return markers;
}

+ (GMSMarker*)markerFromProblem:(EcomapProblem *)problem
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(problem.latitude, problem.longtitude);
    marker.title = problem.title;
    marker.snippet = problem.problemTypeTitle;
    marker.icon = [MapViewController iconForMarkerType:problem.problemTypesID];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = nil;
    return marker;
}

+ (UIImage *)iconForMarkerType:(NSUInteger)problemTypeID
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"%lu.png", (unsigned long)problemTypeID]];
}

@end

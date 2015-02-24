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
#import "SRWebSocket.h"

#define FILTER_ON NO

@interface MapViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (nonatomic, strong) GClusterManager *clusterManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSSet *markers;
@property (nonatomic, strong) GMSCameraPosition *previousCameraPosition;
@property (nonatomic, strong) NSSet *problems;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    [self mapSetup];
}

- (NSSet*)loadLocalJSON
{
    NSString *filePath = [self getPath];
    id array = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) { // if file is not exist, create it.
        array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }

    return array;
}

- (NSString*)getPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"problems.json"];
    NSLog(@"filePath %@", filePath);
    return filePath;
}

- (void)saveLocalJSON:(NSSet*)problems {
    
    [NSKeyedArchiver archiveRootObject:problems toFile:[self getPath]];
}

- (void)renewMap:(NSSet*)problems {
    [self startStandardUpdates];
    [self.clusterManager removeItems];
    [self.mapView clear];
    self.clusterManager = [GClusterManager managerWithMapView:self.mapView
                                                    algorithm:[[NonHierarchicalDistanceBasedAlgorithm alloc] init]
                                                     renderer:[[EcomapClusterRenderer alloc] initWithMapView:self.mapView]];
#warning Filtering demo
    if(FILTER_ON) {
        
        // Filtering demo
        
        NSArray *arrayOfProblems = [problems allObjects];
        
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
        
        NSArray *filteredProblems = [EcomapFilter filterProblemsArray:arrayOfProblems usingFilteringMask:mask];
        
        for(EcomapProblem *problem in filteredProblems) {
            if([problem isKindOfClass:[EcomapProblem class]]){
                Spot* spot = [self generateSpot:problem];
                [self.clusterManager addItem:spot];
            }
        }
        [self.clusterManager cluster];
        
    } else {
        
        // Working code
        
   
        for(EcomapProblem *problem in problems) {
            if([problem isKindOfClass:[EcomapProblem class]]){
                Spot* spot = [self generateSpot:problem];
                [self.clusterManager addItem:spot];
            }
        }
        [self.clusterManager cluster];
    }
    
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
    [self.mapView setDelegate:self];
    [self.view insertSubview:self.mapView atIndex:0];
   self.problems = [self loadLocalJSON];
    

    if (_problems)
        [self renewMap:self.problems];
    
    [EcomapFetcher loadAllProblemsOnCompletion:^(NSArray *problems, NSError *error) {
        if (!error) {
            NSSet *set = [[NSSet alloc] initWithArray:problems];
            if (![self.problems isEqualToSet:set]) {
                [self renewMap:set];
                [self saveLocalJSON:set];
            }
        }
        
    }];
    
    
   
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
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    self.locationManager.distanceFilter = 3000; // meters
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

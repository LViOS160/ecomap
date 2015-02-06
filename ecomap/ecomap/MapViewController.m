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


@interface MapViewController ()<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSSet *markers;
@property (nonatomic, strong) GClusterManager *clusterManager;
@property (nonatomic, strong) NSArray *problems;

//AddProblemViews
@property (nonatomic, strong) UIView* addProblemNavigationView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    [self mapSetup];
    [self loadNibs];
    
//    [_addProblemNavigationView setFrame:CGRectMake(0, 60, 320, 52)];
//    
//   
//
//
//    [self.view addSubview:_addProblemNavigationView];
//    
//    NSDictionary *metrics = @{@"height":@52.0};
//    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[self.topLayoutGuide, _addProblemNavigationView]
//                                                     forKeys:@[@"topGuide", @"grayView"]];
//    [_addProblemNavigationView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[grayView]"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:dict]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[grayView(height)]-|"
//                                                                      options:0
//                                                                      metrics:metrics
//                                                                        views:dict]];
    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[grayView]-|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:dict]];
}

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
       // self.markers = [MapViewController markersFromProblems:problems];
        //[self drawMarkers];
        self.problems = problems;
        for(EcomapProblem *problem in self.problems) {
        if([problem isKindOfClass:[EcomapProblem class]]){
            Spot* spot = [self generateSpot:problem];
        [self.clusterManager addItem:spot];
        [self.mapView setDelegate:self.clusterManager];
        }
    }
    [self.clusterManager cluster];

        }];
    
    //clasterization
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

- (void)drawMarkers
{
    for(GMSMarker *marker in self.markers) {
        if(marker.map == nil)
            marker.map = self.mapView;
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    GMSCameraPosition *position = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:17];
    GMSCameraUpdate *update = [GMSCameraUpdate setCamera:position];
    [self.mapView moveCamera:update];
}

//Spot from problem
- (Spot*)generateSpot:(EcomapProblem *)problem
{
    Spot* spot = [[Spot alloc] init];
    spot.problem = problem;
    spot.location = CLLocationCoordinate2DMake(problem.latitude, problem.longtitude);
    return spot;
}

- (NSSet *)spotsFromProblems:(NSArray *)problems
{
    NSMutableSet *spots = [[NSMutableSet alloc]initWithCapacity:self.problems.count];
    for(EcomapProblem *problem in self.problems) {
        if([problem isKindOfClass:[EcomapProblem class]])
            [spots addObject:[self generateSpot:problem]];
    }
    return spots;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.mapView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 5,
                                        0,
                                        self.bottomLayoutGuide.length + 5,
                                        0);
}

#pragma mark - Utility methods

/*+ (NSSet *)markersFromProblems:(NSArray *)problems
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
    return [UIImage imageNamed:[NSString stringWithFormat:@"%lu.png", problemTypeID]];
}*/



#pragma mark - AddProblem

- (void)loadNibs {
    _addProblemNavigationView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemNavigation" owner:self options:nil][0];
    
}

@end

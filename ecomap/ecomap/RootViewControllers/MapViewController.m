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
#import "GlobalLoggerLevel.h"
#import "Reachability.h"

#define SOCKET_ADDRESS @"http://176.36.11.25:8091"
#define FILTER_ON NO

@interface MapViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (nonatomic, strong) GClusterManager *clusterManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSSet *markers;
@property (nonatomic, strong) GMSCameraPosition *previousCameraPosition;
@property (nonatomic, strong) NSSet *problems;
@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic) Reachability *hostReachability;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    [self mapSetup];
    [self socketInit];
    [self reachabilitySetup];
}

-(void)reachabilitySetup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.hostReachability = [Reachability reachabilityForInternetConnection];
    [self.hostReachability startNotifier];

}

- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
//    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    
    if ([curReach currentReachabilityStatus] == ReachableViaWWAN ||
        [curReach currentReachabilityStatus] == ReachableViaWiFi) {
        [self loadProblems];
        [self socketInit];
    }
}

- (void)socketInit {
    self.socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:SOCKET_ADDRESS]];
    self.socket.delegate = self;
    [self.socket open];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
    NSLog(@"Data recived %@", message);
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

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Connected");
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Faild to connect");
    [self.socket close];
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Closed connection");
    [self.socket close];
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
//    DDLogVerbose(@"filePath %@", filePath);
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
       for(EcomapProblem *problem in problems) {
            if([problem isKindOfClass:[EcomapProblem class]]){
                Spot* spot = [self generateSpot:problem];
                [self.clusterManager addItem:spot];
            }
        }
        [self.clusterManager cluster];
    }
 }


-(void)loadProblems {
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
    [self loadProblems];
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
            if([((GMSMarker *)sender).userData isKindOfClass:[EcomapProblem class]]) {
                EcomapProblem *problem = (EcomapProblem *)((GMSMarker *)sender).userData;
                problemVC.problemID = problem.problemID;
            }
        }
    }
}


@end

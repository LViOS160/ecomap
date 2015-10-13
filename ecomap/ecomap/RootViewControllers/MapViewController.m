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
#import "GlobalLoggerLevel.h"
#import "Reachability.h"
#import "CustomInfoWindow.h"
#import "ProblemFilterTVC.h"
#import "Defines.h"
#import "EcomapUserFetcher.h"
#import "EcomapLoggedUser.h"
#import "InfoActions.h"
#import "TOP10.h"

#import "Statistics.h"
#define SOCKET_ADDRESS @"http://176.36.11.25:8091"

@interface MapViewController () <ProblemFilterTVCDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (nonatomic, strong) GClusterManager *clusterManager;


@property (nonatomic, strong) NSSet *markers;
@property (nonatomic, strong) GMSCameraPosition *previousCameraPosition;
@property (nonatomic, strong) NSSet *problems;
@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic) Reachability *hostReachability;


@property  NSSet* currentAllProblems;

@property NSArray* arrayWithProblems;


// Filtering mask. We get it through NSNotificationCenter
@property (nonatomic, strong) EcomapProblemFilteringMask *filteringMask;

// Set which contains problems after applying filter.
@property (nonatomic, strong) NSSet *filteredProblems;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    [self mapSetup];
    [self socketInit];
    [self reachabilitySetup];
    [self login];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(allProblemsChanged:)
                                                 name:ALL_PROBLEMS_CHANGED
                                               object:nil];
}

- (void)login {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *isLogged = [ud objectForKey:@"isLogged"];
    if ([isLogged isEqualToString:@"YES"]) {
        [EcomapUserFetcher loginWithEmail:[ud objectForKey:@"email"]
                              andPassword:[ud objectForKey:@"password"] OnCompletion:^(EcomapLoggedUser *loggedUser, NSError *error) {
                                  //show greeting for logged user
                                  [InfoActions showPopupWithMesssage:[NSString stringWithFormat:NSLocalizedString(@"Вітаємо, %@!", @"Welcome, {User Name}"), loggedUser.name]];
                              }];
    }
}

- (void)allProblemsChanged:(NSNotification*)notification
{
    [self loadProblems];
}

-(void)reachabilitySetup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.hostReachability = [Reachability reachabilityForInternetConnection];
    [self.hostReachability startNotifier];

}

- (void)reachabilityChanged:(NSNotification *)note
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
    NSLog(@"Faild to connect %@", error);
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

- (void)renewMap:(NSSet*)problems
{
    Statistics *ob = [Statistics sharedInstanceStatistics];
    [ob setAllProblems:self.arrayWithProblems];
    TOP10 *obj = [TOP10 sharedInstanceTOP10];
    
  //  [ob setAllProblems:self.arrayWithProblems	];
    [obj setAllProblems:self.arrayWithProblems];
    
    [self.clusterManager removeItems];
    [self.mapView clear];
    self.clusterManager = [GClusterManager managerWithMapView:self.mapView
                                                    algorithm:[[NonHierarchicalDistanceBasedAlgorithm alloc] init]
                                                     renderer:[[EcomapClusterRenderer alloc] initWithMapView:self.mapView]];
    
    for(EcomapProblem *problem in problems) {
        if([problem isKindOfClass:[EcomapProblem class]]) {
            Spot* spot = [self generateSpot:problem];
            [self.clusterManager addItem:spot];
        }
    }
    [self.clusterManager cluster];
 }


-(void)loadProblems {
    [EcomapFetcher loadAllProblemsOnCompletion:^(NSArray *problems, NSError *error) {
      
        self.arrayWithProblems = [NSArray arrayWithArray:problems];
        
        
       // [ob countAllProblemsCategory];
        if (!error) {
            NSSet *set = [[NSSet alloc] initWithArray:problems];
            
            self.currentAllProblems = [[NSSet alloc]initWithSet:set];
            
         //   NSLog(@"%@",[self.currentAllProblems valueForKey:@");
            if (![self.problems isEqualToSet:set]) {
                [self renewMap:set];
                [self saveLocalJSON:set];
            }
        }
    }];
}

#pragma mark - Problem Filter TVC Delegate

- (void)userDidApplyFilteringMask:(EcomapProblemFilteringMask *)filteringMask
{
    self.filteringMask = filteringMask;
    
    NSArray *arrProblems;
    NSArray *filteredProblems;
    NSLog(@"%@",[self.problems valueForKey:@"latitude"]);
    NSLog(@"%@",[self.problems valueForKey:@"longitude"]);
    
    if(self.problems) {
        arrProblems = [self.currentAllProblems allObjects];
        //[self.problems allObjects];
        
        if(self.filteringMask) {
            filteredProblems = [self.filteringMask applyOnArray:arrProblems];
            self.filteredProblems = [NSSet setWithArray:filteredProblems];
        } else {
            self.filteredProblems = self.problems;
        }
    }
    
    [self renewMap:self.filteredProblems];
}

#pragma mark - GMAP

- (void)mapSetup {
  
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:50.46012686633918
                                                            longitude:30.52173614501953
                                                                 zoom:6];
    
    self.mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = YES;
    
    [self.mapView setDelegate:self];
    [self.view insertSubview:self.mapView atIndex:0];
    self.problems = [self loadLocalJSON];
    if (self.problems)
        [self renewMap:self.problems];
    [self loadProblems];

//    self.mapView.camera
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

- (Spot*)generateSpot:(EcomapProblem *)problem
{
    Spot* spot = [[Spot alloc] init];
    spot.problem = problem;
    spot.location = CLLocationCoordinate2DMake(problem.latitude, problem.longitude);
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
    assert(mapView == self.mapView);
    
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
    } else if([segue.identifier isEqualToString:@"Filter Problem"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        if([navController.topViewController isKindOfClass:[ProblemFilterTVC class]]) {
            ProblemFilterTVC *dvc = (ProblemFilterTVC *)navController.topViewController;
            dvc.filteringMask = self.filteringMask;
            dvc.delegate = self;
        }
    }
}


- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    CustomInfoWindow *infoWindow = nil;
    EcomapProblem *problem = marker.userData;
    if ([problem isKindOfClass:[EcomapProblem class]])
    {
        infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
        infoWindow.title.text = problem.title;
        infoWindow.snippet.text = problem.problemTypeTitle;
    }
    return infoWindow;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

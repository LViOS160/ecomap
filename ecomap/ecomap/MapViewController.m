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
#import "Defines.h"

@interface MapViewController () {
    CGFloat padding;
    CGFloat paddingWithNavigationView;
    CGFloat screenWidth;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSSet *markers;
//AddProblemProperties

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (strong, nonatomic) UIBarButtonItem *closeButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

//AddProblemViews
@property (nonatomic, strong) UIView* addProblemNavigationView;
@property (nonatomic, strong) UIView* addProblemLocationView;
@property (nonatomic, strong) UIView* addProblemNameView;
@property (nonatomic, strong) UIView* addProblemTypeView;
@property (nonatomic, strong) UIView* addProblemDescriptionView;
@property (nonatomic, strong) UIView* addProblemSolutionView;
@property (nonatomic, strong) UIView* addProblemPhotoView;
@property (nonatomic) BOOL isAddProblemShown;


@property (nonatomic, strong) UIView* curView;
@property (nonatomic, strong) UIView* prevView;
@property (nonatomic, strong) UIView* nextView;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    [self mapSetup];
    [self loadNibs];
}

- (IBAction)nextButtonTap:(UIButton *)sender {

    _prevButton.hidden = NO;
    
    [self slideViewFromRight:_nextView withPadding:paddingWithNavigationView];
    [self slideViewToLeft:_curView];
    
    _prevView = _curView;
    _curView = _nextView;
    _pageControl.currentPage = _pageControl.currentPage + 1;
    NSLog(@"%d", _pageControl.currentPage);
    switch (_pageControl.currentPage) {
        case 1:
            _nextView = _addProblemTypeView;
            break;
        case 2:
            _nextView = _addProblemDescriptionView;
            break;
        case 3:
            _nextView = _addProblemSolutionView;
            break;
        case 4:
            _nextButton.hidden = YES;
           break;
        default:
            break;
    }

//    _nextView =
    
}
- (IBAction)prevButtonTap:(UIButton *)sender {
    _nextButton.hidden = NO;
    _pageControl.currentPage = _pageControl.currentPage - 1;
    [self slideViewToRight:_curView];
    [self slideViewFromLeft:_prevView];
    _nextView = _curView;
    _curView = _prevView;
    switch (_pageControl.currentPage) {
        case 0:
            _prevButton.hidden = YES;
            break;
        case 1:
            _prevView = _addProblemLocationView;
            break;
        case 2:
            _prevView = _addProblemNameView;
            break;
        case 3:
            _prevView = _addProblemTypeView;
            break;
        default:
            break;
    }
    
}

- (void)slideViewFromRight:(UIView *)view withPadding:(CGFloat)pad {
    
    CGRect frame = view.frame;
    [view setFrame:CGRectMake(screenWidth*2, pad, frame.size.width, frame.size.height)];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [view setFrame:CGRectMake(0, pad, frame.size.width, frame.size.height)];
                     }];
}

- (void)slideViewFromLeft:(UIView *)view {
    
    CGFloat pad;
    if (view == _addProblemNavigationView)
        pad = padding;
    else
        pad = paddingWithNavigationView;
    CGRect frame = view.frame;
    [view setFrame:CGRectMake(-screenWidth*2, pad, frame.size.width, frame.size.height)];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [view setFrame:CGRectMake(0, pad, frame.size.width, frame.size.height)];
                     }];
}

- (void)slideViewToRight:(UIView *)view {
    
    CGFloat pad;
    if (view == _addProblemNavigationView)
        pad = padding;
    else
        pad = paddingWithNavigationView;
    CGRect frame = view.frame;
    [view setFrame:CGRectMake(0, pad, frame.size.width, frame.size.height)];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [view setFrame:CGRectMake(screenWidth, pad, frame.size.width, frame.size.height)];
                     }];
}

- (void)slideViewToLeft:(UIView *)view {
    CGFloat pad;
    if (view == _addProblemNavigationView)
        pad = padding;
    else
        pad = paddingWithNavigationView;
    CGRect frame = view.frame;
    [view setFrame:CGRectMake(0, pad, frame.size.width, frame.size.height)];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [view setFrame:CGRectMake(-screenWidth, pad, frame.size.width, frame.size.height)];
                     }];
}

- (void)orientationChanged:(id *)sender {
    [self setPaddings];
    [self layoutAddProblemNavigationView];
    [self layoutAddProblemLocationView];
    [self layoutAddProblemNameView];
    [self layoutAddProblemDescriptionView];
    
    
    [self.mapView setFrame: [UIScreen mainScreen].bounds];
}
- (void)closeButtonPresed:(id *)sender {
    [self slideViewToRight:_curView];
    [self slideViewToRight:_addProblemNavigationView];
    
//    [self.view addSubview:_addProblemLocationView];
//    [self.view addSubview:_addProblemNavigationView];
//    [self.view addSubview:_addProblemNameView];
//    [self.view addSubview:_addProblemTypeView];
//    [self.view addSubview:_addProblemDescriptionView];
//    [self.view addSubview:_addProblemSolutionView];
    self.navigationItem.rightBarButtonItem = nil;
    _pageControl.currentPage = 0;
}
- (void)showAddProblemView {
    
    
    
    _isAddProblemShown = true;
    self.closeButton = [[UIBarButtonItem alloc] init];
    self.closeButton.title = @"Close";
    [self.closeButton setAction:@selector(closeButtonPresed:)];
    [self.closeButton setTarget:self];
    self.navigationItem.rightBarButtonItem = self.closeButton;
    [self setPaddings];
    [self layoutAddProblemNavigationView];
    [self layoutAddProblemLocationView];
    [self layoutAddProblemNameView];
    [self layoutAddProblemTypeView];
    [self layoutAddProblemDescriptionView];
    [self layoutAddProblemSolutionView];
    
    [self.view addSubview:_addProblemLocationView];
    [self.view addSubview:_addProblemNavigationView];
    [self.view addSubview:_addProblemNameView];
    [self.view addSubview:_addProblemTypeView];
    [self.view addSubview:_addProblemDescriptionView];
    [self.view addSubview:_addProblemSolutionView];
    
    NSLog(@"%@", _addProblemSolutionView);
    [self slideViewFromRight:_addProblemNavigationView withPadding:padding];
    [self slideViewFromRight:_addProblemLocationView withPadding:paddingWithNavigationView];
    
    _curView = _addProblemLocationView;
    _prevView = nil;
    _nextView = _addProblemNameView;
    _prevButton.hidden = YES;
    
}

- (void)hideAddProblemNavigationView {
    [self.addProblemNavigationView removeFromSuperview];
}

- (void)setPaddings {
    padding = self.navigationController.navigationBar.frame.size.height +
    [UIApplication sharedApplication].statusBarFrame.size.height;
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    paddingWithNavigationView = padding + ADDPROBLEMNAVIGATIONVIEWHEIGHT;
}

- (void)layoutAddProblemNavigationView {
    
    [_addProblemNavigationView setFrame:CGRectMake(0, padding, screenWidth, ADDPROBLEMNAVIGATIONVIEWHEIGHT)];
}

-(void)layoutAddProblemLocationView {
    
    [_addProblemLocationView setFrame:CGRectMake(0, paddingWithNavigationView, screenWidth, ADDPROBLEMLOCATIONHEIGHT)];
}

-(void)layoutAddProblemNameView {
    
    [_addProblemNameView setFrame:CGRectMake(screenWidth, padding, screenWidth, ADDPROBLEMNAMEHEIGHT)];
}

-(void)layoutAddProblemTypeView {
    
    [_addProblemTypeView setFrame:CGRectMake(screenWidth, padding, screenWidth, ADDPROBLEMTYPEHEIGHT)];
}

-(void)layoutAddProblemDescriptionView {
    
    [_addProblemDescriptionView setFrame:CGRectMake(screenWidth, padding, screenWidth, ADDPROBLEMDESCRIPTIONHEIGHT)];
}

-(void)layoutAddProblemSolutionView {
    
    [_addProblemSolutionView setFrame:CGRectMake(screenWidth, padding, screenWidth, ADDPROBLEMSOLUTIONHEIGHT)];
}



- (IBAction)addProblemButton:(id)sender {
    [self showAddProblemView];
    _nextButton.hidden = NO;
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
        self.markers = [MapViewController markersFromProblems:problems];
        [self drawMarkers];
    }];
}

- (void)customSetup
{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
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

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.mapView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 5,
                                        0,
                                        self.bottomLayoutGuide.length + 5,
                                        0);
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



#pragma mark - AddProblem

- (void)loadNibs {
    _addProblemNavigationView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemNavigationView" owner:self options:nil][0];
    _addProblemLocationView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemLocationView" owner:self options:nil][0];
    _addProblemNameView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemNameView" owner:self options:nil][0];
    _addProblemTypeView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemTypeView" owner:self options:nil][0];
    _addProblemDescriptionView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemDescriptionView" owner:self options:nil][0];
    _addProblemSolutionView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemSolutionView" owner:self options:nil][0];
    _addProblemPhotoView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemPhotoView" owner:self options:nil][0];
}

@end

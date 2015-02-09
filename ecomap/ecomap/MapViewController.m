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

// Gallery

@property (nonatomic, strong) NSArray *pageImages;
@property (nonatomic, strong) NSMutableArray *pageViews;

- (void)loadVisiblePages;
- (void)loadPage:(NSInteger)page;
- (void)purgePage:(NSInteger)page;

//////////////////////////////////////////////////////////////////////////////////


@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSSet *markers;

//AddProblemProperties
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) UIBarButtonItem *closeButton;

//AddProblemViews
@property (nonatomic, strong) UIView* addProblemNavigationView;
@property (nonatomic, strong) UIView* addProblemLocationView;
@property (nonatomic, strong) UIView* addProblemNameView;
@property (nonatomic, strong) UIView* addProblemTypeView;
@property (nonatomic, strong) UIView* addProblemDescriptionView;
@property (nonatomic, strong) UIView* addProblemSolutionView;
@property (nonatomic, strong) UIView* addProblemPhotoView;
@property (nonatomic) BOOL nextButtonTaped;


@property (nonatomic, strong) UIView* curView;
@property (nonatomic, strong) UIView* prevView;
@property (nonatomic, strong) UIView* nextView;

@property (nonatomic, strong) NSArray *problemTypes;
@property (weak, nonatomic) IBOutlet UIPickerView *problemTypesPickerVIew;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    [self mapSetup];
    [self loadNibs];
//    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
}

#pragma mark - PickerView

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _problemTypes[row];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 7;
}

#pragma mark - PageControlViewButtons

- (IBAction)nextButtonTap:(UIButton *)sender {
    _prevButton.hidden = NO;
    _nextButtonTaped = YES;
    _pageControl.currentPage = _pageControl.currentPage + 1;
    
    [self slideViewToLeft:_curView];
    
    self.curView = _nextView;
    
    [self switchPage];
}
- (IBAction)choseExistingPhotoButton:(UIButton *)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Code here to work with media
    NSLog(@"YEY");
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self layoutView:_curView];
//    [self layoutView:_addProblemNavigationView];
//    [self.view setNeedsDisplay];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
}

//-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:^{}];
    return YES;
}

- (IBAction)makePhotoButton:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)prevButtonTap:(UIButton *)sender {
    _nextButton.hidden = NO;
    _nextButtonTaped = NO;
    _pageControl.currentPage = _pageControl.currentPage - 1;
    [self slideViewToRight:_curView];
    self.curView = _prevView;
    [self switchPage];

}

- (void)closeButtonPresed:(id *)sender {
    
    [self slideViewToRight:_curView];
    [self slideViewToRight:_addProblemNavigationView];
    
  //  self.navigationItem.rightBarButtonItem = nil;
    _pageControl.currentPage = 0;
}

- (void)switchPage{
    switch (_pageControl.currentPage) {
        case 0:
            _prevButton.hidden = YES;
            _nextView = _addProblemNameView;
            break;
        case 1:
            _nextView = _addProblemTypeView;
            _prevView = _addProblemLocationView;
            break;
        case 2:
            _nextView = _addProblemDescriptionView;
            _prevView = _addProblemNameView;
            break;
        case 3:
            _nextView = _addProblemSolutionView;
            _prevView = _addProblemTypeView;
            break;
        case 4:
            _prevView = _addProblemDescriptionView;
            _nextView = _addProblemPhotoView;
            break;
        case 5:
            _prevView = _addProblemSolutionView;
            _nextButton.hidden = YES;
            break;
        default:
            break;
    }
}



#pragma mark - AddProblemAnimation

- (void)slideViewFromRight:(UIView *)view {
    [self slideView:view from:YES right:YES];
}

- (void)slideViewFromLeft:(UIView *)view {
    
    [self slideView:view from:YES right:NO];
}

- (void)slideViewToRight:(UIView *)view {
    
    [self slideView:view from:NO right:YES];
}

- (void)slideViewToLeft:(UIView *)view {
    [self slideView:view from:NO right:NO];
}


- (void)slideView:(UIView*)view from:(BOOL)from right:(BOOL)right {
    CGFloat pad;
    if (view == _addProblemNavigationView)
        pad = padding;
    else
        pad = paddingWithNavigationView;
    CGRect rectOne;
    CGRect rectTwo;
    
    if (from) {             // slide from
        rectOne.origin.x = right ? screenWidth * 2 : -screenWidth * 2;
        rectTwo.origin.x = 0;
    } else {                // slide to
        rectOne.origin.x = 0;
        rectTwo.origin.x = right ? screenWidth : -screenWidth;
    }
    
    rectOne.origin.y = pad;
    rectOne.size.width = screenWidth;
    rectOne.size.height = [self getViewHeight:view];
    
    rectTwo.origin.y = pad;
    rectTwo.size.width = rectOne.size.width;
    rectTwo.size.height = rectOne.size.height;
    
    [view setFrame:rectOne];
    NSLog(@"%@", [view constraints]);
//    [view removeConstraints:[view constraints]];
    [UIView animateWithDuration:0.5
                     animations:^{
                         [view setFrame:rectTwo];
                     }
                     completion:^(BOOL ok){if (!from)[view removeFromSuperview];}];
}

- (void)orientationChanged:(id *)sender {
    [self setPaddings];    
    [self layoutView:_curView];
    [self layoutView:_addProblemNavigationView];
    [self.mapView setFrame: [UIScreen mainScreen].bounds];
}

- (void)showAddProblemView {
    
    // Close button SetUp
    self.closeButton = [[UIBarButtonItem alloc] init];
    self.closeButton.title = @"Close";
    [self.closeButton setAction:@selector(closeButtonPresed:)];
    [self.closeButton setTarget:self];
    self.navigationItem.rightBarButtonItem = self.closeButton;
    
    
    [self setPaddings];
    [self.view addSubview:_addProblemNavigationView];
    [self slideViewFromRight:_addProblemNavigationView];
    
    self.curView = _addProblemLocationView;
    _prevView = nil;
    _nextView = _addProblemNameView;
    _prevButton.hidden = YES;
    
}

- (void)setCurView:(UIView *)curView {
    _curView = curView;
    [self.view addSubview:_curView];
    if (_nextButtonTaped) {
        [self slideViewFromRight:_curView];
    } else {
        [self slideViewFromLeft:_curView];
    }
}

#pragma mark - ViewLayouts

- (void)setPaddings {
    padding = self.navigationController.navigationBar.frame.size.height +
    [UIApplication sharedApplication].statusBarFrame.size.height;
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    paddingWithNavigationView = padding + ADDPROBLEMNAVIGATIONVIEWHEIGHT;
}


- (void)layoutView:(UIView *)view {
    CGFloat pad;
    CGFloat height = [self getViewHeight:view];
    if (view == _addProblemNavigationView)
        pad = padding;
    else
        pad = paddingWithNavigationView;
    [view setFrame:CGRectMake(0, pad, screenWidth, height)];
}

- (CGFloat)getViewHeight:(UIView *)view {
    CGFloat height = 0.0;
    if (view == _addProblemNavigationView)
        height = ADDPROBLEMNAVIGATIONVIEWHEIGHT;
    else if (view == _addProblemLocationView)
        height = ADDPROBLEMLOCATIONHEIGHT;
    else if (view == _addProblemNameView)
        height = ADDPROBLEMNAMEHEIGHT;
    else if (view == _addProblemTypeView)
        height = ADDPROBLEMTYPEHEIGHT;
    else if (view == _addProblemDescriptionView)
        height = ADDPROBLEMDESCRIPTIONHEIGHT;
    else if (view == _addProblemSolutionView)
        height = ADDPROBLEMSOLUTIONHEIGHT;
    else if (view == _addProblemPhotoView)
        height = ADDPROBLEMPHOTOHEIGHT;
    return height;
}

- (IBAction)addProblemButton:(id)sender {
    [self showAddProblemView];
    _nextButton.hidden = NO;
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
    [self layoutView:_curView];
    [self layoutView:_addProblemNavigationView];
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
    [_problemTypesPickerVIew selectRow:4 inComponent:0 animated:NO];
    _problemTypes = [NSArray arrayWithObjects:@"Проблеми лісів", @"Сміттєзвалища", @"Незаконна забудова",
                     @"Проблеми водойм", @"Загрози біорізноманіттю", @"Браконьєрство", @"Інші проблеми", nil];

}

#pragma mark - PhotoView

- (void)loadVisiblePages {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Update the page control
    self.pageControl.currentPage = page;
    
    // Work out which pages we want to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    for (NSInteger i=lastPage+1; i<self.pageImages.count; i++) {
        [self purgePage:i];
    }
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Load an individual page, first seeing if we've already loaded it
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        frame = CGRectInset(frame, 10.0f, 0.0f);
        
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:page]];
        newPageView.contentMode = UIViewContentModeScaleAspectFit;
        newPageView.frame = frame;
        [self.scrollView addSubview:newPageView];
        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}




#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages which are now on screen
    [self loadVisiblePages];
}

@end

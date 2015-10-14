
//
//  AddProblemViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 10.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AddProblemViewController.h"
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "EcomapFetcher+PostProblem.h"
#import "EcomapProblem.h"
#import "EcomapProblemDetails.h"
#import "InfoActions.h"
#import "EcomapLocalPhoto.h"
#import "SlideAnimator.h"
#import "MenuViewController.h"
#import "AFNetworking.h"

@interface AddProblemViewController () {
    CGFloat padding;
    CGFloat paddingWithNavigationView;
    CGFloat screenWidth;
}

// Outlets
@property (weak, nonatomic) IBOutlet UIButton *addProblemButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceToButton;
@property (nonatomic) UIBarButtonItem *closeButton;

@property (weak, nonatomic) IBOutlet UIButton *goToUkraineButton;

// NavigationViews

@property (nonatomic) ConstHeightViewController* curView;
@property (nonatomic) ConstHeightViewController* prevView;
@property (nonatomic) ConstHeightViewController* nextView;
@property (nonatomic) BOOL userIsInTheMiddleOfAddingProblem;

// Views

@property (nonatomic) AddProblemNavigationViewController *addProblemNavigation;
@property (nonatomic) AddProblemDescriptionViewController *addProblemDescription;
@property (nonatomic) AddProblemLocationViewController *addProblemLocation;
@property (nonatomic) AddProblemNameViewController *addProblemName;
@property (nonatomic) AddProblemPhotoViewController *addProblemPhoto;
@property (nonatomic) AddProblemSolutionViewController *addProblemSolution;
@property (nonatomic) AddProblemTypeViewController *addProblemType;

// MapMarker

@property (nonatomic) GMSMarker *marker;

@end

@implementation AddProblemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userIsInTheMiddleOfAddingProblem = false;
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    padding = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    //Pavlo
    
    [self.view bringSubviewToFront:self.goToUkraineButton];
    
    
}


- (void)nextPage {
    if (![self checkWetherCurrentFieldFilled]) {
        return;
    }
    self.addProblemNavigation.prevButton.hidden = NO;
    self.addProblemNavigation.pageControl.currentPage = self.addProblemNavigation.pageControl.currentPage + 1;
    
    [SlideAnimator slideViewToLeft:self.curView withPadding:padding];
    self.curView = self.nextView;
    [SlideAnimator slideViewFromRight:self.curView withPadding:padding];
    [self switchPage];
}

- (void)prevPage {
    self.addProblemNavigation.nextButton.hidden = NO;
    self.addProblemNavigation.pageControl.currentPage = self.addProblemNavigation.pageControl.currentPage - 1;
    [SlideAnimator slideViewToRight:self.curView withPadding:padding];
    self.curView = self.prevView;
    [SlideAnimator slideViewFromLeft:self.curView withPadding:padding];
    [self switchPage];
}

// If field filled allow switch to next page

- (BOOL)checkWetherCurrentFieldFilled {
    BOOL fieldFilled = YES;
    NSString *alertText;
    switch (self.addProblemNavigation.pageControl.currentPage) {
        case 0:
            if (!self.marker) {
                fieldFilled = NO;
                alertText = NSLocalizedString(@"Необхiдно обрати мiсцезнаходження проблеми", @"You have to add problem location");
            }
            break;
        case 1:
            if ([self.addProblemName.problemName.text isEqualToString:@""]) {
                fieldFilled = NO;
                alertText = NSLocalizedString(@"Необхiдно ввести назву проблеми", @"You have to enter the name of the problem");
            }
            break;
        default:
            break;
    }
    if (!fieldFilled) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:alertText delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    return fieldFilled;
}


- (IBAction)showUkrainePlacement:(id)sender {
   self.mapView.camera = [GMSCameraPosition cameraWithLatitude:50
                longitude:30
                     zoom:5];
}

#pragma mark - Buttons

- (IBAction)addProblemButtonTap:(UIButton *)sender {
    if([EcomapLoggedUser currentLoggedUser]) {
        if (!self.userIsInTheMiddleOfAddingProblem) {
            [self loadNibs];
            [self showAddProblemView];
            self.addProblemPhoto.rootController = self;
            self.addProblemNavigation.nextButton.hidden = NO;
            UIButton *button = sender;
            button.hidden = YES;
            CGRect buttonFrame = button.frame;
            buttonFrame.origin.y += 50;
            
            self.topSpaceToButton.constant = 10;
            
            [button setNeedsUpdateConstraints];
            [button setFrame:buttonFrame];
            self.userIsInTheMiddleOfAddingProblem = true;
            self.mapView.userInteractionEnabled = YES;
            
        } else {
            
            self.topSpaceToButton.constant = 77;
            [self.addProblemButton setNeedsUpdateConstraints];
            
            [self postProblem];                     // not implemented
            self.userIsInTheMiddleOfAddingProblem = false;
            [self closeButtonTap:nil];
            [sender setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        }
        
    } else {
        //show action sheet to login
        [InfoActions showLogitActionSheetFromSender:sender
                           actionAfterSuccseccLogin:^{
                               [self addProblemButtonTap:sender];
                           }];
    }
    
}

- (void)closeButtonTap:(id *)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocateMeDidTap" object:nil];
    self.marker.map = nil;
    self.marker = nil;
    self.topSpaceToButton.constant = 77;
    [self.addProblemButton setNeedsUpdateConstraints];
    self.mapView.settings.myLocationButton = YES;
    self.addProblemButton.hidden = NO;
    [SlideAnimator slideViewToRight:self.curView withPadding:padding];
    [SlideAnimator slideViewToRight:self.addProblemNavigation withPadding:padding];
    self.navigationItem.rightBarButtonItem = nil;
    self.addProblemNavigation.pageControl.currentPage = 0;
    self.userIsInTheMiddleOfAddingProblem = NO;
    [self.addProblemButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self loadProblems];
}

- (void)switchPage{
    
    switch (self.addProblemNavigation.pageControl.currentPage) {
        case 0:
            self.addProblemNavigation.prevButton.hidden = YES;
            self.nextView = self.addProblemName;
            break;
        case 1:
            self.nextView = self.addProblemType;
            self.prevView = self.addProblemLocation;
            self.addProblemButton.hidden = YES;
            [self.addProblemButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
            break;
        case 2:
            self.nextView = self.addProblemDescription;
            self.prevView = self.addProblemName;
            self.addProblemButton.hidden = NO;
            [self.addProblemButton setImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
            
            break;
        case 3:
            self.nextView = self.addProblemSolution;
            self.prevView = self.addProblemType;
            break;
        case 4:
            self.prevView = self.addProblemDescription;
            self.nextView = self.addProblemPhoto;

            break;
        case 5:
            self.prevView = self.addProblemSolution;
            self.addProblemNavigation.nextButton.hidden = YES;
            break;
        default:
            break;
    }
}

- (void)orientationChanged:(id *)sender {
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    padding = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    [self.curView layoutView:padding];
    [self.addProblemNavigation layoutView:padding];
}

#pragma mark - SwipesGesures

- (void)rightSwipe {
    if (self.addProblemNavigation.pageControl.currentPage > 0)
        [self prevPage];
    
}
- (void)leftSwipe {
    if (self.addProblemNavigation.pageControl.currentPage < 5)
        [self nextPage];
}


- (void)showAddProblemView {

    UISwipeGestureRecognizer *swipeRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe)];
    UISwipeGestureRecognizer *swipeRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe)];
    
    swipeRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:swipeRecognizerRight];
    [self.view addGestureRecognizer:swipeRecognizerLeft];
    

    // Close button SetUp
    
    self.mapView.settings.myLocationButton = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locateMeDidTap) name:@"LocateMeDidTap" object:nil];
    self.closeButton = [[UIBarButtonItem alloc] init];
    self.closeButton.title = NSLocalizedString(@"Відмініти", @"Cancel bar button");
    [self.closeButton setAction:@selector(closeButtonTap:)];
    [self.closeButton setTarget:self];
    self.navigationItem.rightBarButtonItem = self.closeButton;
    [self.view addSubview:self.addProblemNavigation.view];

    [SlideAnimator slideViewFromRight:self.addProblemNavigation withPadding:padding];

    self.curView = self.addProblemLocation;

    [SlideAnimator slideViewFromRight:self.curView withPadding:padding];
    
    self.prevView = nil;
    self.nextView = self.addProblemName;
    self.addProblemNavigation.prevButton.hidden = YES;

    
}

#define PROBLEM_LOCATION_STRING NSLocalizedString(@"Мiсцезнаходження проблеми", @"Problem location")
- (void)locateMeDidTap {
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Доступ до геопозицiї", @"Location Services access")
                                                                       message:NSLocalizedString(@"Для доступу до вашої геопозиції необхидно зайти до налаштувань та дозволити додатку доступ до вашої геопозиції", @"Please allow the application access to your location service to locate your current pisition")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Відмініти", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *openAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Вiдкрити налаштування", @"Open settings")
                                                             style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }];
        [alert addAction:cancelAction];
        [alert addAction:openAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        CLLocation *location = self.mapView.myLocation;
        CLLocationCoordinate2D coordinate = [location coordinate];
        
        if (self.userIsInTheMiddleOfAddingProblem) {
            if ([self.curView isKindOfClass:[AddProblemLocationViewController class]]) {
                if (!self.marker) {
                    self.marker = [[GMSMarker alloc] init];
                    self.marker.title = PROBLEM_LOCATION_STRING;
                    self.marker.map = self.mapView;
                }
                [self.marker setPosition:coordinate];
                GMSCameraPosition *position = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:17];
                GMSCameraUpdate *update = [GMSCameraUpdate setCamera:position];
                [self.mapView moveCamera:update];
            }
        }

    }

}

#pragma mark - ProblemPost


- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {

    if (self.userIsInTheMiddleOfAddingProblem) {
        if ([self.curView isKindOfClass:[AddProblemLocationViewController class]]) {
            if (!self.marker) {
                self.marker = [[GMSMarker alloc] init];
                self.marker.title = PROBLEM_LOCATION_STRING;
                self.marker.map = self.mapView;
            }
            [self.marker setPosition:coordinate];
        }
    }
}


- (void)postProblem {
    
   
    NSDictionary *params = @{ECOMAP_PROBLEM_TITLE     : self.addProblemName.problemName.text,
                             ECOMAP_PROBLEM_CONTENT    : self.addProblemDescription.textView.text ? self.addProblemDescription.textView.text : @"",
                             ECOMAP_PROBLEM_PROPOSAL : self.addProblemSolution.textView.text ? self.addProblemSolution.textView.text : @"",
                             ECOMAP_PROBLEM_LATITUDE : @(self.marker.position.latitude),
                             ECOMAP_PROBLEM_LONGITUDE : @(self.marker.position.longitude),
                             ECOMAP_PROBLEM_ID : @(4),
                             ECOMAP_PROBLEM_TYPE_ID : @([self.addProblemType.pickerView selectedRowInComponent:0] + 1)
                             };
    
    EcomapProblem *problem = [[EcomapProblem alloc] initWithProblem: params];
    EcomapProblemDetails *details = [[EcomapProblemDetails alloc] initWithProblem: params];
    details.photos = self.addProblemPhoto.photos;
    
  
    [EcomapFetcher problemPost:problem problemDetails:details user:[EcomapLoggedUser currentLoggedUser] OnCompletion:^(NSString *result, NSError *error) {
        NSLog(@"%@",error);
    }];
 
    
    [self loadProblems];
    
}

- (void)setCurView:(ConstHeightViewController *)curView {
    _curView = curView;
    [self.view addSubview:_curView.view];
}

#pragma mark - AddProblemNibs

- (void)loadNibs {
    self.addProblemNavigation = [[AddProblemNavigationViewController alloc] initWithNibName:@"AddProblemNavigationView" bundle:nil];
    self.addProblemNavigation.delegate = self;
    self.addProblemLocation = [[AddProblemLocationViewController alloc] initWithNibName:@"AddProblemLocationView" bundle:nil];
    self.addProblemName = [[AddProblemNameViewController alloc] initWithNibName:@"AddProblemNameView" bundle:nil];
    self.addProblemDescription = [[AddProblemDescriptionViewController alloc] initWithNibName:@"AddProblemDescriptionView" bundle:nil];
    self.addProblemType = [[AddProblemTypeViewController alloc] initWithNibName:@"AddProblemTypeView" bundle:nil];
    self.addProblemSolution = [[AddProblemSolutionViewController alloc] initWithNibName:@"AddProblemSolutionView" bundle:nil];
    self.addProblemPhoto = [[AddProblemPhotoViewController alloc] initWithNibName:@"AddProblemPhotoView" bundle:nil];

}

@end
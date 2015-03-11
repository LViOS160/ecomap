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
@interface AddProblemViewController ()
{
    CGFloat padding;
    CGFloat paddingWithNavigationView;
    CGFloat screenWidth;
}

// Outlets
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *addProblemButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceToButton;
@property (nonatomic) UIBarButtonItem *closeButton;

// NavigationViews

@property (nonatomic) UIViewController* curView;
@property (nonatomic) UIViewController* prevView;
@property (nonatomic) UIViewController* nextView;
@property (nonatomic) BOOL userIsInTheMiddleOfAddingProblem;

// Views
//adsasdasd
//asdadasd
@property (nonatomic) UIView* addProblemNavigationView;
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
}


// If field filled allow switch to next page

- (BOOL)checkWetherCurrentFieldFilled {
    BOOL fieldFilled = YES;
    NSString *alertText;
    switch (self.pageControl.currentPage) {
        case 0:
            if (!self.marker) {
                fieldFilled = NO;
                alertText = @"Необхiдно обрати мiсцезнаходження проблеми";
            }
            break;
        case 1:
            if ([self.addProblemName.problemName.text isEqualToString:@""]) {
                fieldFilled = NO;
                alertText = @"Необхiдно ввести назву проблеми";
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

#pragma mark - Buttons

- (IBAction)addProblemButtonTap:(UIButton *)sender {
    if([EcomapLoggedUser currentLoggedUser]) {
        if (!self.userIsInTheMiddleOfAddingProblem) {
            [self loadNibs];
            [self showAddProblemView];
            self.addProblemPhoto.rootController = self;
            self.nextButton.hidden = NO;
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

- (IBAction)nextButtonTap:(UIButton *)sender {
    if (![self checkWetherCurrentFieldFilled]) {
        return;
    }
    self.prevButton.hidden = NO;
    self.pageControl.currentPage = self.pageControl.currentPage + 1;
    
    [self slideViewToLeft:self.curView.view];
    self.curView = self.nextView;
    [self slideViewFromRight:self.curView.view];
    [self switchPage];
}

- (IBAction)prevButtonTap:(UIButton *)sender {
    self.nextButton.hidden = NO;
    self.pageControl.currentPage = self.pageControl.currentPage - 1;
    [self slideViewToRight:self.curView.view];
    self.curView = self.prevView;
    [self slideViewFromLeft:self.curView.view];
    [self switchPage];
    
}

- (void)closeButtonTap:(id *)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.marker.map = nil;
    self.marker = nil;
    self.topSpaceToButton.constant = 77;
    
    [self.addProblemButton setNeedsUpdateConstraints];
    
    self.mapView.settings.myLocationButton = YES;
    self.addProblemButton.hidden = NO;
    [self slideViewToRight:self.curView.view];
    [self slideViewToRight:self.addProblemNavigationView];
    self.navigationItem.rightBarButtonItem = nil;
    self.pageControl.currentPage = 0;
    self.userIsInTheMiddleOfAddingProblem = NO;
    [self.addProblemButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
}

- (void)switchPage{
    switch (self.pageControl.currentPage) {
        case 0:
            self.prevButton.hidden = YES;
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
            self.nextButton.hidden = YES;
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
    if (view == self.addProblemNavigationView)
        pad = padding;
    else
        pad = paddingWithNavigationView;
    CGRect rectOne;
    CGRect rectTwo;
    
    if (from) {             // slide from
        rectOne.origin.x = right ? screenWidth*2  : -screenWidth*2 ;
        rectTwo.origin.x = 0;
    } else {                // slide to
        rectOne.origin.x = 0;
        rectTwo.origin.x = right ? screenWidth : -screenWidth ;
    }
    
    rectOne.origin.y = pad;
    rectOne.size.width = screenWidth;
    rectOne.size.height = [self getViewHeight:view];
    
    rectTwo.origin.y = pad;
    rectTwo.size.width = rectOne.size.width;
    rectTwo.size.height = rectOne.size.height;
    
    [view setFrame:rectOne];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [view setFrame:rectTwo];
                     }
                     completion:^(BOOL ok){
                         if (!from)[view removeFromSuperview];
                     }];
}

- (void)orientationChanged:(id *)sender {
    [self setPaddings];
    [self layoutView:self.curView.view];
    [self layoutView:self.addProblemNavigationView];
}

#pragma mark - SwipesGesures

- (void)rightSwipe {
    if (self.pageControl.currentPage > 0)
        [self prevButtonTap:nil];
    
}
- (void)leftSwipe {
    if (self.pageControl.currentPage < 5)
        [self nextButtonTap:nil];
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
    self.closeButton.title = @"Вiдмiнити";
    [self.closeButton setAction:@selector(closeButtonTap:)];
    [self.closeButton setTarget:self];
    self.navigationItem.rightBarButtonItem = self.closeButton;
    [self setPaddings];
    [self.view addSubview:self.addProblemNavigationView];
    [self slideViewFromRight:self.addProblemNavigationView];

    self.curView = self.addProblemLocation;

    [self slideViewFromRight:self.curView.view];
    
    self.prevView = nil;
    self.nextView = self.addProblemName;
    self.prevButton.hidden = YES;

    
}

- (void)locateMeDidTap {
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Доступ до геопозицiї" message:@"Для використання цієї функції необхiдно зайти до налаштувань та дозволити додатку доступ до вашої геопозиції" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Вiдмiнити" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Вiдкрити налаштування" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }];
        [alert addAction:cancelAction];
        [alert addAction:openAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [self.locationManager startUpdatingLocation];

        CLLocation *location = self.locationManager.location;
        CLLocationCoordinate2D coordinate = [location coordinate];
        
        if (self.userIsInTheMiddleOfAddingProblem) {
            if ([self.curView isKindOfClass:[AddProblemLocationViewController class]]) {
                if (!self.marker) {
                    self.marker = [[GMSMarker alloc] init];
                    self.marker.title = @"Мiсцезнаходження проблеми";
                    self.marker.map = self.mapView;
                }
                [self.marker setPosition:coordinate];
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
                self.marker.title = @"Мiсцезнаходження проблеми";
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
    details.photos = self.addProblemPhoto.photos;;
    [EcomapFetcher problemPost:problem problemDetails:details user:[EcomapLoggedUser currentLoggedUser] OnCompletion:^(NSString *result, NSError *error) {
        [self loadProblems];
    }];
}

- (void)setCurView:(UIViewController *)curView {
    _curView = curView;
    [self.view addSubview:_curView.view];
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
    if (view == self.addProblemNavigationView)
        pad = padding;
    else
        pad = paddingWithNavigationView;
    [view setFrame:CGRectMake(0, pad, screenWidth, height)];
}




#pragma mark - AddProblemNibs

- (void)loadNibs {
    self.addProblemNavigationView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemNavigationView" owner:self options:nil][0];
    self.addProblemLocation = [[AddProblemLocationViewController alloc] initWithNibName:@"AddProblemLocationView" bundle:nil];
    self.addProblemName = [[AddProblemNameViewController alloc] initWithNibName:@"AddProblemNameView" bundle:nil];
    self.addProblemDescription = [[AddProblemDescriptionViewController alloc] initWithNibName:@"AddProblemDescriptionView" bundle:nil];
    self.addProblemType = [[AddProblemTypeViewController alloc] initWithNibName:@"AddProblemTypeView" bundle:nil];
    self.addProblemSolution = [[AddProblemSolutionViewController alloc] initWithNibName:@"AddProblemSolutionView" bundle:nil];
    self.addProblemPhoto = [[AddProblemPhotoViewController alloc] initWithNibName:@"AddProblemPhotoView" bundle:nil];


}

- (CGFloat)getViewHeight:(UIView *)view {

    CGFloat height = 0.0;
    if (view == self.addProblemNavigationView)
        height = ADDPROBLEMNAVIGATIONVIEWHEIGHT;
    else if (view == self.addProblemLocation.view)
        height = ADDPROBLEMLOCATIONHEIGHT;
    else if (view == self.addProblemName.view)
        height = ADDPROBLEMNAMEHEIGHT;
    else if (view == self.addProblemType.view)
        height = ADDPROBLEMTYPEHEIGHT;
    else if (view == self.addProblemDescription.view)
        height = ADDPROBLEMDESCRIPTIONHEIGHT;
    else if (view == self.addProblemSolution.view)
        height = ADDPROBLEMSOLUTIONHEIGHT;
    else if (view == self.addProblemPhoto.view)
        height = ADDPROBLEMPHOTOHEIGHT;
    return height;
}




@end

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
#import "MenuViewController.h"
#import "AFNetworking.h"
#import "EcomapRevisionCoreData.h"
#import "EcomapCoreDataControlPanel.h"

@interface AddProblemViewController ()
{
    CGFloat padding;
    CGFloat paddingWithNavigationView;
    CGFloat screenWidth;
}

// Outlets
@property (weak, nonatomic) IBOutlet UIButton *addProblemButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceToButton;
@property (nonatomic) UIBarButtonItem *closeButton;

@property (weak, nonatomic) IBOutlet UIButton *goToUkraineButton;

//



// MapMarker

@property (nonatomic) GMSMarker *marker;


@end

@implementation AddProblemViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    padding = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    [self.propositionLable setHidden:YES];
    [self.gotoNext setHidden:YES];
    [self.view bringSubviewToFront:self.goToUkraineButton];
    
}

- (void)update:(NSString *)problemName :(NSString*)problemDescription :(NSString*)problemSolution :(GMSMarker*)marker
{
    [self postProblem:problemName :problemDescription :problemSolution :marker];
}

- (void)cancel

{
    [self.propositionLable setHidden:YES];
    self.gotoNext.hidden = YES;
    self.addProblemButton.hidden = NO;
    self.propositionLable.hidden = YES;
}


- (IBAction)showUkrainePlacement:(id)sender
{
   self.mapView.camera = [GMSCameraPosition cameraWithLatitude:50
                longitude:30
                     zoom:5];
    [self loadProblems];
}

#pragma mark - Buttons

- (IBAction)addProblemButtonTap:(UIButton *)sender
{
    if ([EcomapLoggedUser currentLoggedUser])
    {
        self.propositionLable.hidden = NO;
        self.gotoNext.hidden = NO;
            UIButton *button = sender;
            //button.hidden = YES;
            CGRect buttonFrame = button.frame;
            buttonFrame.origin.y += 50;
            self.topSpaceToButton.constant = 10;
            [button setNeedsUpdateConstraints];
            [button setFrame:buttonFrame];
            self.mapView.userInteractionEnabled = YES;
    }
    
    else
    {
        [InfoActions showLogitActionSheetFromSender:sender
                           actionAfterSuccseccLogin:^{
                               [self addProblemButtonTap:sender];
                           }];
    }
}

- (void)closeButtonTap:(id *)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LocateMeDidTap" object:nil];
    self.marker.map = nil;
    self.marker = nil;
    self.topSpaceToButton.constant = 77;
    [self.addProblemButton setNeedsUpdateConstraints];
    self.mapView.settings.myLocationButton = YES;
    self.addProblemButton.hidden = NO;
    self.navigationItem.rightBarButtonItem = nil;
    [self.addProblemButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
   
}


- (void)orientationChanged:(id *)sender
{
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    padding = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
   
}




#define PROBLEM_LOCATION_STRING NSLocalizedString(@"Мiсцезнаходження проблеми", @"Problem location")
- (void)locateMeDidTap
{


}




/*-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addProblem"])
    {
        AddProblemModalController *modalContr = (AddProblemModalController*)segue.destinationViewController;
        [modalContr setCord:self.cord];
    }
}*/


#pragma mark - ProblemPost
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
            if (!self.marker)
            {
                self.marker = [[GMSMarker alloc] init];
                self.marker.title = PROBLEM_LOCATION_STRING;
                self.marker.map = self.mapView;
            }
    
            [self setCord:coordinate];
            [self.marker setPosition:coordinate];
}

- (void)postProblem:(NSString *)problemName :(NSString*)problemDescription :(NSString*)problemSolution :(GMSMarker*)marker
{
    self.addProblemButton.hidden = NO;
    NSDictionary *params = @{ECOMAP_PROBLEM_TITLE     : problemName,
                             ECOMAP_PROBLEM_CONTENT    : problemDescription,
                             ECOMAP_PROBLEM_PROPOSAL : problemSolution,
                             ECOMAP_PROBLEM_LATITUDE : @(marker.position.latitude),
                             ECOMAP_PROBLEM_LONGITUDE : @(marker.position.longitude),
                             ECOMAP_PROBLEM_ID : @(4),
                             ECOMAP_PROBLEM_TYPE_ID : @(2)
                             };
    
    EcomapProblem *problem = [[EcomapProblem alloc] initWithProblem: params];
    EcomapProblemDetails *details = [[EcomapProblemDetails alloc] initWithProblem: params];

    [EcomapFetcher problemPost:problem problemDetails:details user:[EcomapLoggedUser currentLoggedUser] OnCompletion:^(NSString *result, NSError *error) {
        NSLog(@" ProblemloadCOMPLETE:  %@",error);
        
        EcomapRevisionCoreData *RevisionObject = [[EcomapRevisionCoreData alloc] init];
        [RevisionObject checkRevison];
        [self loadProblems];
    }];
    
    
}



@end
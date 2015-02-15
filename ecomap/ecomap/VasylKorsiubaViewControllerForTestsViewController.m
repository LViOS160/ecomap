//
//  VasylKorsiubaViewControllerForTestsViewController.m
//  ecomap
//
//  Created by Vasya on 2/10/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "VasylKorsiubaViewControllerForTestsViewController.h"
#import "EcomapFetcher.h"
#import "EcomapLoggedUser.h"
#import "EcomapProblemDetails.h"
#import "EcomapPhoto.h"
#import "EcomapURLFetcher.h"
#import "IDMPhotoBrowser.h"

//Setup DDLog
#import "CocoaLumberjack.h"
//#import "GlobalLoggerLevel.h"

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface VasylKorsiubaViewControllerForTestsViewController () <IDMPhotoBrowserDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *ShowAllPhotosButton;
@property (strong, nonatomic) EcomapProblemDetails *problemDetails;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation VasylKorsiubaViewControllerForTestsViewController

-(IBAction)loadProblem:(id)sender
{
    //252, 229
    [EcomapFetcher loadProblemDetailsWithID:229
                               OnCompletion:^(EcomapProblemDetails *problemDetails, NSError *error) {
                                   if (!error) {
                                       _problemDetails = problemDetails;
                                       [self scrollViewSetup];
                                   } else
                                   {
                                       DDLogError(@"Error loading problem ditails for photo browser. %@", error);
                                   }
                               }];
}

-(void)viewDidLoad
{
    DDLogError(@"This is an error.");
    DDLogWarn(@"This is a warning.");
    DDLogInfo(@"This is just a message.");
    DDLogVerbose(@"This is a verbose message.");
    
    [self scrollViewSetup];
}

#define HORIZONTAL_OFFSET 24.0f
#define VERTICAL_OFFSET 10.0f
#define BUTTON_HEIGHT 80.0f
#define BUTTON_WIDTH 80.0f
#define BUTTONS_OFFSET 1.5

- (void)scrollViewSetup 
{
    //self.scrollView.backgroundColor = [UIColor lightGrayColor];
    
    //Set ScrollView Initial offset
    CGFloat contentOffSet = HORIZONTAL_OFFSET;
    
    NSArray *photosDitailsArray = self.problemDetails.photos;
    
    //Check if we nees to display add button
    if ([photosDitailsArray count] < 10) {
        [self addButtonToScrollViewWithImage:[UIImage imageNamed:@"addButtonImage.png"]
                                      offset:contentOffSet
                                         tag:0];
        contentOffSet += BUTTON_WIDTH + HORIZONTAL_OFFSET;
    }
    
    //Array to hold the images to displayed in the scrollView
    NSArray *imageNames = [NSArray arrayWithObjects:@"button1.jpg",
                           @"button2.jpg",@"button1.jpg",
                           @"button2.jpg", nil];
    
    if ([photosDitailsArray count]) {
        int count = 1;
        for (EcomapPhoto *photoDitails in photosDitailsArray)
        {
            [self addButtonToScrollViewWithImage:[UIImage imageNamed:imageNames[count -1]]
                                          offset:contentOffSet
                                             tag:count];
            contentOffSet += BUTTON_WIDTH + HORIZONTAL_OFFSET;
            //Increase the count value
            count++;
        }
    } else {
        DDLogWarn(@"No photos for problem");
    }

    //Set contentView
    self.scrollView.contentSize = CGSizeMake(contentOffSet, self.scrollView.frame.size.height);
    
    
    
    
    
//    for (NSString *singleImageFilename in imageNames) {
//        
//        //Create button
//        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        customButton.adjustsImageWhenHighlighted = NO;
//        customButton.tag = count;
//        customButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
//        customButton.backgroundColor = [UIColor blackColor];
//        [customButton setBackgroundImage:[UIImage imageNamed:singleImageFilename] forState:UIControlStateNormal];
//        [customButton addTarget:self
//                         action:@selector(buttonWithImageOnScreenPressed:)
//               forControlEvents:UIControlEventTouchUpInside];
//        customButton.frame = buttonViewFrame;
//        
//        [self.scrollView addSubview:customButton];
//        contentOffSet += customButton.frame.size.width * 1.5;
//        self.scrollView.contentSize = CGSizeMake(contentOffSet, self.scrollView.frame.size.height);
//        
//    }
}

-(void)addButtonToScrollViewWithImage:(UIImage *)image offset:(CGFloat)offset tag:(NSUInteger)tag
{
    //Set button frame
    CGRect buttonViewFrame = CGRectMake(offset, VERTICAL_OFFSET, BUTTON_WIDTH, BUTTON_HEIGHT);
    
    //Create button
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.adjustsImageWhenHighlighted = NO;
    customButton.tag = tag;
    customButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    customButton.backgroundColor = tag != 0 ? [UIColor blackColor] : [UIColor clearColor];
    [customButton setBackgroundImage:image forState:UIControlStateNormal];
    //add target-action
    if (tag == 0) {
        [customButton addTarget:self
                         action:@selector(buttonToAddImagePressed:)
               forControlEvents:UIControlEventTouchUpInside];
    } else {
        [customButton addTarget:self
                         action:@selector(buttonWithImageOnScreenPressed:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    
    customButton.frame = buttonViewFrame;
    
    [self.scrollView addSubview:customButton];
}

- (void)buttonToAddImagePressed:(id)sender
{
    DDLogVerbose(@"Add image button pressed");
}

- (void)buttonWithImageOnScreenPressed:(id)sender
{
    UIButton *buttonSender = (UIButton*)sender;
    
    NSArray *photosDitailsArray = self.problemDetails.photos;
    // Create an array to store IDMPhoto objects
    NSMutableArray *photos = [NSMutableArray new];
    
    IDMPhoto *photo;
    
    //Fill array with IDMPhoto objects
    if ([photosDitailsArray count]) {
        for (EcomapPhoto *photoDitails in photosDitailsArray)
        {
            photo = [IDMPhoto photoWithURL:[EcomapURLFetcher URLforLargePhotoWithLink:photoDitails.link]];
            if (photoDitails.caption ) {
                photo.caption = photoDitails.caption;
            }
            [photos addObject:photo];
        }
    } else {
        DDLogWarn(@"No photos for problem");
    }
    
    // Create and setup browser
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos animatedFromView:sender]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
    browser.delegate = self;
    browser.displayActionButton = YES;
    browser.displayArrowButton = YES;
    browser.displayCounterLabel = YES;
    browser.usePopAnimation = YES;
    browser.scaleImage = buttonSender.currentImage;
    [browser setInitialPageIndex:(buttonSender.tag - 1)];
    
    // Show modaly
    [self presentViewController:browser animated:YES completion:nil];
}

- (IBAction)login:(id)sender {
    [EcomapFetcher loginWithEmail:@"clic@ukr.net"
                      andPassword:@"eco"
                     OnCompletion:^(EcomapLoggedUser *user, NSError *error) {
                         if (!error) {
                             NSLog(@"User role: %@", user.role);
                             
                             //Read current logged user
                             EcomapLoggedUser *loggedUser = [EcomapLoggedUser currentLoggedUser];
                             NSLog(@"User ID: %d", loggedUser.userID);
                             
                         } else {
                             NSLog(@"Error to login: %@", error);
                         }
                     }];
}

- (IBAction)currentUser:(id)sender {
    EcomapLoggedUser *loggedUser = [EcomapLoggedUser currentLoggedUser];
    NSLog(@"Email: %@", loggedUser.email);
}

- (IBAction)logout:(id)sender {
    [EcomapFetcher logoutUser:[EcomapLoggedUser currentLoggedUser] OnCompletion:^(BOOL result, NSError *error) {
        
    }];
}
- (IBAction)loadAllProblems:(id)sender {
    [EcomapFetcher loadAllProblemsOnCompletion:^(NSArray *problems, NSError *error) {
        if (!error) {
            NSLog(@"Loaded success! %d problems", [problems count] + 1);
        } else {
            NSLog(@"Error loading problems: %@", error);
        }
        
    }];
}
- (IBAction)loadProblemWithId:(id)sender {
    [EcomapFetcher loadProblemDetailsWithID:1
                               OnCompletion:^(EcomapProblemDetails *problemDetails, NSError *error) {
                                   if (!error) {
                                       NSLog(@"Loaded success! Details for 1 problem");
                                       NSLog(@"Titile %@", problemDetails.title);
                                   } else {
                                       NSLog(@"Error loading problem details: %@", error);
                                   }
                               }];
}

- (IBAction)showAllPhotos:(id)sender {
    UIButton *buttonSender = (UIButton*)sender;
    
    NSArray *photosDitailsArray = self.problemDetails.photos;
    // Create an array to store IDMPhoto objects
    NSMutableArray *photos = [NSMutableArray new];
    
    IDMPhoto *photo;
    
    //Fill array with IDMPhoto objects
    if ([photosDitailsArray count]) {
        for (EcomapPhoto *photoDitails in photosDitailsArray)
        {
            photo = [IDMPhoto photoWithURL:[EcomapURLFetcher URLforLargePhotoWithLink:photoDitails.link]];
            if (photoDitails.caption) {
                photo.caption = photoDitails.caption;
            }
            [photos addObject:photo];
        }
    } else {
        DDLogWarn(@"No photos for problem");
    }
    
    // Create and setup browser
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos animatedFromView:sender]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
    browser.delegate = self;
    browser.displayActionButton = YES;
    browser.displayArrowButton = YES;
    browser.displayCounterLabel = YES;
    browser.usePopAnimation = YES;
    //browser.scaleImage = buttonSender.currentImage;
    
    // Show
    [self presentViewController:browser animated:YES completion:nil];
}

@end

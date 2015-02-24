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
#import "EMThumbnailImageStore.h"

//Setup DDLog
//#import "CocoaLumberjack.h"
#import "GlobalLoggerLevel.h"
//static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface VasylKorsiubaViewControllerForTestsViewController () <IDMPhotoBrowserDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *ShowAllPhotosButton;
@property (strong, nonatomic) EcomapProblemDetails *problemDetails;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) NSInteger initialPageIndex;

@end

@implementation VasylKorsiubaViewControllerForTestsViewController

-(IBAction)loadProblem:(id)sender
{
    //252, 229
    [EcomapFetcher loadProblemDetailsWithID:229
                               OnCompletion:^(EcomapProblemDetails *problemDetails, NSError *error) {
                                   if (!error) {
                                       _problemDetails = problemDetails;
                                       [self updateScrollView];
                                   } else
                                   {
                                       DDLogError(@"Error loading problem ditails for photo browser. %@", [error localizedDescription]);
                                       [self showAlertViewOfError:error];
                                   }
                               }];
}

-(void)viewDidLoad
{
    DDLogError(@"This is an error.");
    DDLogWarn(@"This is a warning.");
    DDLogInfo(@"This is just a message.");
    DDLogVerbose(@"This is a verbose message.");
    
    //[self updateScrollView];
}


//Show error to the user in UIAlertView
- (void)showAlertViewOfError:(NSError *)error
{
    NSString *alertTitle = nil;
    NSString *errorMessage = nil;  //human-readable dwscription of the error
    switch (error.code / 100) {
        case 5:
            alertTitle = @"Ecomap server error!";
            errorMessage = @"There are technical problems on server. We are working to fix it. Please try again later."; 
            break;
            
        default:
            alertTitle = @"Error";
            errorMessage = [error localizedDescription];  //human-readable dwscription of the error
            break;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:errorMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


#pragma mark - Scroll View Gallery
#define HORIZONTAL_OFFSET 24.0f
#define VERTICAL_OFFSET 10.0f
#define BUTTON_HEIGHT 80.0f
#define BUTTON_WIDTH 80.0f

- (void)updateScrollView 
{
    //Set ScrollView Initial offset
    CGFloat contentOffSet = HORIZONTAL_OFFSET;
    
    NSArray *photosDitailsArray = self.problemDetails.photos;
    
    if (photosDitailsArray) {
        
        if (![photosDitailsArray count]) {
            DDLogVerbose(@"No photos for problem");
        }
        
        //Count is tag for view. tag == 0 is for 'add image' button
        for (int count = 0; count <= [photosDitailsArray count]; count++)
        {
            NSString *link = nil;
            if (count != 0) {
                EcomapPhoto *photoDitails = photosDitailsArray[count - 1];
                link = photoDitails.link;
            }
   
            //Create button
            [self addButtonToScrollViewWithImageOnLink:link
                                                offset:contentOffSet
                                                   tag:count];
            contentOffSet += BUTTON_WIDTH + HORIZONTAL_OFFSET;
        }
    }

    //Set contentView
    self.scrollView.contentSize = CGSizeMake(contentOffSet, self.scrollView.frame.size.height);
}

-(void)addButtonToScrollViewWithImageOnLink:(NSString *)link offset:(CGFloat)offset tag:(NSUInteger)tag
{
    //Set button frame
    CGRect buttonViewFrame = CGRectMake(offset, VERTICAL_OFFSET, BUTTON_WIDTH, BUTTON_HEIGHT);
    
    //Create button
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.adjustsImageWhenHighlighted = NO;
    customButton.tag = tag;
    customButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    customButton.frame = buttonViewFrame;
    if (tag == 0) {
        //Set background color
        customButton.backgroundColor = [UIColor clearColor];
        //Set image
        [customButton setBackgroundImage:[UIImage imageNamed:@"addButtonImage.png"]
                                forState:UIControlStateNormal];
        //Add target-action
        [customButton addTarget:self
                         action:@selector(buttonToAddImagePressed:)
               forControlEvents:UIControlEventTouchUpInside];
        DDLogVerbose(@"'Add image' button created");
    } else {
        //Set background color
        customButton.backgroundColor = [UIColor blackColor];
        
        //Set image. First look in cache
        UIImage *thumnailImage = [[EMThumbnailImageStore sharedStore] imageForKey:link];
        
        if (!thumnailImage) {
            //Star loading spinner
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            activityIndicator.center = CGPointMake(BUTTON_WIDTH / 2, BUTTON_HEIGHT / 2);
            [customButton addSubview:activityIndicator];
            [activityIndicator startAnimating];
            
            //Set image in background
            [EcomapFetcher loadSmallImagesFromLink:link
                                      OnCompletion:^(UIImage *image, NSError *error) {
                                          if (!error) {
                                              [customButton setBackgroundImage:image
                                                                      forState:UIControlStateNormal];
                                          } else { DDLogError(@"Error loadind image at URL: %@", [error localizedDescription]);
                                              [self showAlertViewOfError:error];
                                          }
                                          
                                          //Stop loadind spinner
                                          [activityIndicator stopAnimating];
                                      }];

        } else {
            //Set image from cache
            [customButton setBackgroundImage:thumnailImage
                                    forState:UIControlStateNormal];
        }
                //Add target-action
        [customButton addTarget:self
                         action:@selector(buttonWithImageOnScreenPressed:)
               forControlEvents:UIControlEventTouchUpInside];
        DDLogVerbose(@"Button with photo number %d created", tag);
    }

    
    
    [self.scrollView addSubview:customButton];
}

- (void)buttonToAddImagePressed:(id)sender
{
    DDLogVerbose(@"'Add image' button pressed");
}

- (void)buttonWithImageOnScreenPressed:(id)sender
{
    UIButton *buttonSender = (UIButton*)sender;
    
    self.initialPageIndex = buttonSender.tag - 1;
    DDLogVerbose(@"Button with photo number %d pressed", buttonSender.tag);
    
    NSArray *photosDitailsArray = self.problemDetails.photos;
    // Create an array to store IDMPhoto objects
    NSMutableArray *photos = [NSMutableArray new];
    
    IDMPhoto *photo;
    
    //Fill array with IDMPhoto objects
    for (EcomapPhoto *photoDitails in photosDitailsArray)
    {
        photo = [IDMPhoto photoWithURL:[EcomapURLFetcher URLforLargePhotoWithLink:photoDitails.link]];
        if (photoDitails.caption ) {
            photo.caption = photoDitails.caption;
        }
        [photos addObject:photo];
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

-(void)photoBrowser:(IDMPhotoBrowser *)photoBrowser didShowPhotoAtIndex:(NSUInteger)index
{
    if (self.initialPageIndex != index) self.scrollView.contentOffset = CGPointMake((BUTTON_WIDTH + HORIZONTAL_OFFSET) * (index + 1) - (BUTTON_WIDTH + HORIZONTAL_OFFSET), 0);
}


#pragma mark - Login
- (IBAction)login:(id)sender {
    [EcomapFetcher loginWithEmail:@"clic@ukr.net"
                      andPassword:@"eco"
                     OnCompletion:^(EcomapLoggedUser *user, NSError *error) {
                         if (!error) {
                             DDLogVerbose(@"User role: %@", user.role);
                             
                             //Read current logged user
                             EcomapLoggedUser *loggedUser = [EcomapLoggedUser currentLoggedUser];
                             DDLogVerbose(@"User ID: %d", loggedUser.userID);
                             
                         } else {
                             DDLogVerbose(@"Error to login: %@", error);
                         }
                     }];
}

- (IBAction)currentUser:(id)sender {
    EcomapLoggedUser *loggedUser = [EcomapLoggedUser currentLoggedUser];
    DDLogVerbose(@"Email: %@", loggedUser.email);
}

- (IBAction)logout:(id)sender {
    [EcomapFetcher logoutUser:[EcomapLoggedUser currentLoggedUser] OnCompletion:^(BOOL result, NSError *error) {
        
    }];
}
- (IBAction)loadAllProblems:(id)sender {
    [EcomapFetcher loadAllProblemsOnCompletion:^(NSArray *problems, NSError *error) {
        if (!error) {
            DDLogVerbose(@"Loaded success! %d problems", [problems count] + 1);
        } else {
            DDLogVerbose(@"Error loading problems: %@", error);
        }
        
    }];
}
- (IBAction)loadProblemWithId:(id)sender {
    [EcomapFetcher loadProblemDetailsWithID:1
                               OnCompletion:^(EcomapProblemDetails *problemDetails, NSError *error) {
                                   if (!error) {
                                       DDLogVerbose(@"Loaded success! Details for 1 problem");
                                       DDLogVerbose(@"Titile %@", problemDetails.title);
                                   } else {
                                       DDLogVerbose(@"Error loading problem details: %@", error);
                                   }
                               }];
}

- (IBAction)showAllPhotos:(id)sender {
    self.scrollView.contentOffset = CGPointMake((BUTTON_WIDTH + HORIZONTAL_OFFSET) * 2 - (BUTTON_WIDTH + HORIZONTAL_OFFSET), 0);
}

@end

//
//  ProblemViewController.m
//  ecomap
//
//  Created by Inna Labuskaya on 2/14/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ProblemViewController.h"
#import "EcomapFetcher.h"
#import "EcomapURLFetcher.h"
#import "EcomapPhoto.h"
#import "IDMPhotoBrowser.h"
#import "EcomapLoggedUser.h"
#import "EMThumbnailImageStore.h"

//Setup DDLog
#import "GlobalLoggerLevel.h"

typedef enum : NSUInteger {
    DetailedViewType,
    ActivityViewType,
    ComentViewType,
} ViewType;

@interface ProblemViewController() <IDMPhotoBrowserDelegate>

@property (nonatomic, strong) EcomapProblemDetails *problemDetails;
@property (weak, nonatomic) IBOutlet UILabel *severityLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewPhotoGallary;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@end

@implementation ProblemViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateEmptyView];
    [self updateHeader];
    [self loadProblemDetails:nil];
}


- (void)loadProblemDetails:(void(^)())onFinish
{
    [EcomapFetcher loadProblemDetailsWithID:self.problem.problemID
                               OnCompletion:^(EcomapProblemDetails *problemDetails, NSError *error) {
                                   self.problemDetails = problemDetails;
                                   [self updateUI:DetailedViewType];
                                   [self updateHeader];
                                   [self updateScrollView];
                               }];
}

- (IBAction)segmentControlChanged:(UISegmentedControl *)sender
{
    switch(sender.selectedSegmentIndex)
    {
        case 0:
            [self updateUI:DetailedViewType];
            break;
        case 1:
            [self updateUI:ActivityViewType];
            break;
        case 2:
            [self updateUI:ComentViewType];
            break;
    }
}

/*- (IBAction)detailedClick:(id)sender
{
    [self updateUI:DetailedViewType];
}

- (IBAction)activityClick:(id)sender
{
    [self updateUI:ActivityViewType];
}

- (IBAction)comentClick:(id)sender
{
    [self updateUI:ComentViewType];
}*/

- (IBAction)likeClick:(UIButton*)sender
{
    if(self.problemDetails) {
        sender.enabled = NO;
        [EcomapFetcher addVoteForProblem:self.problemDetails
                                withUser:[EcomapLoggedUser currentLoggedUser]
                            OnCompletion:^(NSError *error) {
                                if (!error) {
                                    [self loadProblemDetails:^{
                                        sender.enabled = YES;
                                    }];
                                } else {
                                    sender.enabled = YES;
                                }
                            }];
    }
}

- (void)updateUI:(ViewType)type
{
    if(self.problemDetails) {
        switch(type){
            case DetailedViewType:
                [self updateDetailedView];
                break;
            case ActivityViewType:
                [self updateActivityView];
                break;
            case ComentViewType:
                [self updateComentView];
                break;
        }
    } else {
        [self updateErrorView];
    }
}

- (void)updateHeader
{
    self.title = self.problem.title;
    self.severityLabel.text = [self severityString];
    self.statusLabel.attributedText = [self statusString];
    [self.likeButton setTitle:[self likeString] forState:UIControlStateNormal];
}

- (NSString*)severityString
{
    if (self.problemDetails) {
        NSMutableString *severity = [[NSMutableString alloc] init];
        NSString *blackStars = [@"" stringByPaddingToLength:self.problemDetails.severity withString:@"★" startingAtIndex:0];
        NSString *whiteStars = [@"" stringByPaddingToLength:5-self.problemDetails.severity withString:@"☆" startingAtIndex:0];
        [severity appendString:blackStars];
        [severity appendString:whiteStars];
        return severity;
    } else {
        return @"☆☆☆☆☆";
    }
}

- (NSAttributedString *)statusString
{
    if (self.problemDetails) {
        if(self.problem.isSolved) {
            return [[NSAttributedString alloc] initWithString:@"вирішена"
                                                   attributes:@{
                                                                NSForegroundColorAttributeName:[UIColor greenColor]
                                                                    }];
        } else {
            return [[NSAttributedString alloc] initWithString:@"не вирішена"
                                                   attributes:@{
                                                                NSForegroundColorAttributeName:[UIColor redColor]
                                                                }];
        }
    } else {
        return [[NSAttributedString alloc] initWithString:@"Завантаження..."];
    }
}

- (NSString *)likeString
{
    return [NSString stringWithFormat:@"♡%lu", self.problemDetails.votes];
}

- (void)updateDetailedView
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]init];
    NSAttributedString *contentHeader = [[NSAttributedString alloc]
                                         initWithString:@"Опис проблеми:\n"
                                         attributes:@{
                                                      NSFontAttributeName: [UIFont boldSystemFontOfSize:13]
                                                      }];
    NSString *contentString = [self.problemDetails.content isEqual:[NSNull null]]? @"": self.problemDetails.content;
    NSAttributedString *content = [[NSAttributedString alloc]
                                   initWithString:[contentString stringByAppendingString:@"\n"]
                                   attributes:@{
                                                NSFontAttributeName: [UIFont systemFontOfSize:13]
                                                }];
    
    NSAttributedString *proposalHeader = [[NSAttributedString alloc]
                                         initWithString:@"Пропозиції щодо вирішення:\n"
                                         attributes:@{
                                                      NSFontAttributeName: [UIFont boldSystemFontOfSize:13]
                                                      }];
    NSString *proposalString = [self.problemDetails.proposal isEqual:[NSNull null]]? @"": self.problemDetails.proposal;
    NSAttributedString *proposal = [[NSAttributedString alloc]
                                   initWithString:[proposalString stringByAppendingString:@"\n"]
                                   attributes:@{
                                                NSFontAttributeName: [UIFont systemFontOfSize:13]
                                                }];

    [text appendAttributedString:contentHeader];
    [text appendAttributedString:content];
    [text appendAttributedString:proposalHeader];
    [text appendAttributedString:proposal];
    self.descriptionText.attributedText = text;
    [self.descriptionText setContentOffset:CGPointZero animated:YES];
}

- (void)updateActivityView
{
    
}

- (void)updateComentView
{
    
}

- (void)updateEmptyView
{
    
}

- (void)updateErrorView
{
    
}

#pragma mark - Scroll View Gallery setup
#define HORIZONTAL_OFFSET 12.0f
#define VERTICAL_OFFSET 10.0f
#define BUTTON_HEIGHT 80.0f
#define BUTTON_WIDTH 80.0f

- (void)updateScrollView
{
    //Set ScrollView Initial offset
    CGFloat contentOffSet = 0;
    
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
    self.scrollViewPhotoGallary.contentSize = CGSizeMake((contentOffSet - HORIZONTAL_OFFSET), self.scrollViewPhotoGallary.frame.size.height);
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
        //customButton.backgroundColor = [UIColor clearColor];
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
        //customButton.backgroundColor = [UIColor blackColor];
        
        //Set image. First look in cache
        UIImage *thumnailImage = [[EMThumbnailImageStore sharedStore] imageForKey:link];
        
        if (!thumnailImage) {
            //Set temp image
            [customButton setBackgroundImage:[UIImage imageNamed:@"EmptyButton.png"]
                                    forState:UIControlStateNormal];
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
                                          } else {
                                              DDLogError(@"Error loadind image at URL: %@", [error localizedDescription]);
                                              
                                              //set image "no preview avaliable"
                                              [customButton setBackgroundImage:[UIImage imageNamed:@"NoPreviewButton.png"]
                                                                      forState:UIControlStateNormal];
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
    
    
    
    [self.scrollViewPhotoGallary addSubview:customButton];
}

- (void)buttonToAddImagePressed:(id)sender
{
    DDLogVerbose(@"'Add image' button pressed");
}

- (void)buttonWithImageOnScreenPressed:(id)sender
{
    UIButton *buttonSender = (UIButton*)sender;
    
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
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos animatedFromView:buttonSender]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
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

//IDMPhotoBrowser delegate method
//Calculate new offset for scrollViewPhotoGallary
-(void)photoBrowser:(IDMPhotoBrowser *)photoBrowser didDismissAtPageIndex:(NSUInteger)index
{
        //Calculate max horisontal offset
        float maxHorisontalOffset = self.scrollViewPhotoGallary.contentSize.width - self.scrollViewPhotoGallary.bounds.size.width;
        CGPoint maxOffset = CGPointMake(maxHorisontalOffset, 0);
        
        //Calculate desire offset (to place last viewed image in the middale of the screen)
        float button_X_CoordinateAtLeftPositionInScrollView = (BUTTON_WIDTH + HORIZONTAL_OFFSET) * (index + 1);
        float scrollViewCenter_X_Coordinate = self.scrollViewPhotoGallary.bounds.size.width / 2;
        float buttonCenter_X_Coordinate = BUTTON_WIDTH / 2;
        CGPoint desireOffset = CGPointMake(button_X_CoordinateAtLeftPositionInScrollView - scrollViewCenter_X_Coordinate + buttonCenter_X_Coordinate, 0);
        
        //Check if we can use desire offset
        //Chech right offset limits
        CGPoint newOffset = desireOffset.x > maxOffset.x ? maxOffset : desireOffset;
        //Check left offset limits
        newOffset = newOffset.x < 0 ? CGPointZero : newOffset;
        
        //Set new offset animated
        [self.scrollViewPhotoGallary setContentOffset:newOffset animated:YES];
}

@end

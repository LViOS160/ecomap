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

//Setup DDLog
#import "CocoaLumberjack.h"

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

typedef enum : NSUInteger {
    DetailedViewType,
    ActivityViewType,
    ComentViewType,
} ViewType;

@interface ProblemViewController()

@property (nonatomic, strong) EcomapProblemDetails *problemDetails;
@property (weak, nonatomic) IBOutlet UILabel *severityLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewPhotoGallary;

@end

@implementation ProblemViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateEmptyView];
    [self updateHeader];
    [EcomapFetcher loadProblemDetailsWithID:self.problem.problemID
                               OnCompletion:^(EcomapProblemDetails *problemDetails, NSError *error) {
                                   self.problemDetails = problemDetails;
                                   [self updateUI:DetailedViewType];
                                   [self updateHeader];
                                   [self updateScrollView];
                               }];
}

- (IBAction)detailedClick:(id)sender
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
}

- (IBAction)likeClick:(id)sender
{
    
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
    self.likeButton.titleLabel.text = [self likeString];
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
    NSAttributedString *content = [[NSAttributedString alloc]
                                   initWithString:[self.problemDetails.content stringByAppendingString:@"\n"]
                                   attributes:@{
                                                NSFontAttributeName: [UIFont systemFontOfSize:13]
                                                }];
    
    NSAttributedString *proposalHeader = [[NSAttributedString alloc]
                                         initWithString:@"Пропозиції щодо вирішення:\n"
                                         attributes:@{
                                                      NSFontAttributeName: [UIFont boldSystemFontOfSize:13]
                                                      }];
    NSAttributedString *proposal = [[NSAttributedString alloc]
                                   initWithString:[self.problemDetails.proposal stringByAppendingString:@"\n"]
                                   attributes:@{
                                                NSFontAttributeName: [UIFont systemFontOfSize:13]
                                                }];

    [text appendAttributedString:contentHeader];
    [text appendAttributedString:content];
    [text appendAttributedString:proposalHeader];
    [text appendAttributedString:proposal];
    self.descriptionText.attributedText = text;
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

#pragma mark - ScrollView setup
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
        
        if (![photosDitailsArray count]) DDLogVerbose(@"No photos for problem");
        
        //Count is tag for view. tag == 0 is for add button
        for (int count = 0; count <= [photosDitailsArray count]; count++)
        {
            UIImage *image = (count == 0) ? [UIImage imageNamed:@"addButtonImage.png"] : [UIImage imageNamed:@"photo"];
            //Create button
            [self addButtonToScrollViewWithImage:image
                                          offset:contentOffSet
                                             tag:count];
            contentOffSet += BUTTON_WIDTH + HORIZONTAL_OFFSET;
        }
    }
    
    //Set contentView
    self.scrollViewPhotoGallary.contentSize = CGSizeMake(contentOffSet, self.scrollViewPhotoGallary.frame.size.height);
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
    customButton.backgroundColor = (tag != 0) ? [UIColor blackColor] : [UIColor clearColor];
    [customButton setBackgroundImage:image forState:UIControlStateNormal];
    //add target-action
    if (tag == 0) {
        [customButton addTarget:self
                         action:@selector(buttonToAddImagePressed:)
               forControlEvents:UIControlEventTouchUpInside];
        DDLogVerbose(@"'Add image' button created");
    } else {
        [customButton addTarget:self
                         action:@selector(buttonWithImageOnScreenPressed:)
               forControlEvents:UIControlEventTouchUpInside];
        DDLogVerbose(@"Button with photo number %d created", tag);
    }
    
    customButton.frame = buttonViewFrame;
    
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
    //browser.delegate = self;
    browser.displayActionButton = YES;
    browser.displayArrowButton = YES;
    browser.displayCounterLabel = YES;
    browser.usePopAnimation = YES;
    browser.scaleImage = buttonSender.currentImage;
    [browser setInitialPageIndex:(buttonSender.tag - 1)];
    
    // Show modaly
    [self presentViewController:browser animated:YES completion:nil];
}

@end

//
//  ProblemViewController.m
//  ecomap
//
//  Created by Inna Labuskaya on 2/14/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ProblemViewController.h"
#import "EcomapFetcher.h"

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
@property (weak, nonatomic) IBOutlet UIView *photoViewContainer;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

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

@end

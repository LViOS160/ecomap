//
//  AddProblemPhotoViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 04.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AddProblemPhotoViewController.h"
#import "PhotoViewController.h"
#import "Defines.h"
#import "InfoActions.h"

@interface AddProblemPhotoViewController() <PhotoViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *photos;

@end

@implementation AddProblemPhotoViewController

static const double ButtonXOffset = 8.0;
static const double ButtonYOffset = 8.0;
static const double ButtonWidth = 80.0;
static const double ButtonHeight = 80.0;
static const NSUInteger MaxPhotos = 5;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
}

- (void)addPhotoTap:(id)sender {
    if (self.rootController) {
        if (self.photos.count < MaxPhotos) {
            PhotoViewController *viewController = [self.rootController.storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
            viewController.delegate = self;
            viewController.maxPhotos = MaxPhotos - self.photos.count;
            [self.rootController presentViewController:viewController animated:YES completion:nil];
        } else {
           [InfoActions showAlertWithTitile:@"Увага!"
                                 andMessage:[NSString stringWithFormat:@"Ви можете додати максимум %lu фото", MaxPhotos]];
        }
    }
}

- (void)photoViewControllerDidCancel:(PhotoViewController *)viewController
{
    [self.rootController dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoViewControllerDidFinish:(PhotoViewController *)viewController withImageDescriptions:(NSArray *)imageDescriptions
{
    [self.rootController dismissViewControllerAnimated:YES completion:nil];
    if (self.photos == nil) {
        self.photos = imageDescriptions;
    } else {
        self.photos = [self.photos arrayByAddingObjectsFromArray:imageDescriptions];
    }
    [self updateUI];
}

- (void)updateUI
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIButton *addButton = [self buttonWithImageDescription:nil
                                                       tag:-1
                                                     frame:[self frameForIndex:0]];
    [self.scrollView addSubview:addButton];
    [self.photos enumerateObjectsUsingBlock:^(EcomapLocalPhoto *imageDescription, NSUInteger idx, BOOL *stop) {
        UIButton *button = [self buttonWithImageDescription:imageDescription
                                                        tag:idx
                                                      frame:[self frameForIndex:idx+1]];
        [self.scrollView addSubview:button];
    }];
    self.scrollView.contentSize =
        CGSizeMake((ButtonXOffset + ButtonWidth) * (self.photos.count + 1),
                   self.scrollView.frame.size.height);
}

-(UIButton*)buttonWithImageDescription:(EcomapLocalPhoto*)photo
                                   tag:(NSInteger)tag
                                 frame:(CGRect)frame
{
    UIButton *customButton =[UIButton buttonWithType:UIButtonTypeCustom];
    customButton.adjustsImageWhenHighlighted = NO;
    customButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    customButton.frame = frame;
    customButton.tag = tag;
    if (photo) {
        [customButton setBackgroundImage:photo.image
                                forState:UIControlStateNormal];
    } else {
        [customButton setBackgroundImage:[UIImage imageNamed:@"addButtonImage.png"]
                                forState:UIControlStateNormal];
        [customButton addTarget:self
                         action:@selector(addPhotoTap:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return customButton;
}

- (CGRect)frameForIndex:(NSInteger)index
{
    return CGRectMake(ButtonXOffset + (ButtonXOffset + ButtonWidth) * index, ButtonYOffset, ButtonWidth, ButtonHeight);
}


@end

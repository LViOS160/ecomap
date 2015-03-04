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

@interface AddProblemViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    CGFloat padding;
    CGFloat paddingWithNavigationView;
    CGFloat screenWidth;
}

//AddProblemProperties
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
//@property (weak, nonatomic) IBOutlet UIPickerView *problemTypesPickerVIew;
@property (weak, nonatomic) IBOutlet UIButton *addProblemButton;

@property (nonatomic, strong) UIBarButtonItem *closeButton;


//AddProblemViews
@property (nonatomic, strong) UIView* addProblemNavigationView;
@property (nonatomic, strong) UIView* addProblemLocationView;
//@property (nonatomic, strong) UIView* addProblemNameView;
//@property (nonatomic, strong) UIView* addProblemTypeView;
//@property (nonatomic, strong) UIView* addProblemDescriptionView;
//@property (nonatomic, strong) UIView* addProblemSolutionView;
//@property (nonatomic, strong) UIView* addProblemPhotoView;
@property (nonatomic, strong) UIView* curView;
@property (nonatomic, strong) UIView* prevView;
@property (nonatomic, strong) UIView* nextView;




@property AddProblemDescriptionViewController *addProblemDescription;
@property AddProblemLocationViewController *addProblemLocation;
@property AddProblemNameViewController *addProblemName;
@property AddProblemPhotoViewController *addProblemPhoto;
@property AddProblemSolutionViewController *addProblemSolution;
@property AddProblemTypeViewController *addProblemType;
@end

@implementation AddProblemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}


#pragma mark - Buttons Actions

- (IBAction)makePhoto:(id)sender
{
#if !(TARGET_IPHONE_SIMULATOR)
    UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
    uiipc.delegate = self;
    uiipc.mediaTypes = @[(NSString *)kUTTypeImage];
    uiipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    uiipc.allowsEditing = NO;
    [self presentViewController:uiipc animated:YES completion:NULL];
#endif
    
}

- (IBAction)gallery:(id)sender
{
    UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
    uiipc.delegate = self;
    uiipc.mediaTypes = @[(NSString *)kUTTypeImage];
    uiipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    uiipc.allowsEditing = NO;
    [self presentViewController:uiipc animated:YES completion:NULL];
    
}



#pragma mark - PageControlViewButtons

- (IBAction)nextButtonTap:(UIButton *)sender {
    self.prevButton.hidden = NO;
    self.pageControl.currentPage = self.pageControl.currentPage + 1;
    
    [self slideViewToLeft:self.curView];
    self.curView = self.nextView;
    [self slideViewFromRight:self.curView];
    [self switchPage];
}

- (IBAction)prevButtonTap:(UIButton *)sender {
    self.nextButton.hidden = NO;
    self.pageControl.currentPage = self.pageControl.currentPage - 1;
    [self slideViewToRight:self.curView];
    self.curView = self.prevView;
    [self slideViewFromLeft:self.curView];
    [self switchPage];
    
}

- (void)closeButtonTap:(id *)sender {
    self.addProblemButton.enabled = YES;
    [self slideViewToRight:self.curView];
    [self slideViewToRight:self.addProblemNavigationView];
    self.navigationItem.rightBarButtonItem = nil;
    self.pageControl.currentPage = 0;
}

- (void)switchPage{
    switch (self.pageControl.currentPage) {
        case 0:
            self.prevButton.hidden = YES;
            self.nextView = self.addProblemName.view;
            break;
        case 1:
            self.nextView = self.addProblemType.view;
            self.prevView = self.addProblemLocation.view;
            break;
        case 2:
            self.nextView = self.addProblemDescription.view;
            self.prevView = self.addProblemName.view;
            break;
        case 3:
            self.nextView = self.addProblemSolution.view;
            self.prevView = self.addProblemType.view;
            break;
        case 4:
            self.prevView = self.addProblemDescription.view;
            self.nextView = self.addProblemPhoto.view;
            break;
        case 5:
            self.prevView = self.addProblemSolution.view;
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
    [self layoutView:self.curView];
    [self layoutView:self.addProblemNavigationView];
}

- (void)showAddProblemView {
    
    // Close button SetUp
    self.closeButton = [[UIBarButtonItem alloc] init];
    self.closeButton.title = @"Close";
    [self.closeButton setAction:@selector(closeButtonTap:)];
    [self.closeButton setTarget:self];
    self.navigationItem.rightBarButtonItem = self.closeButton;
    [self setPaddings];
    [self.view addSubview:self.addProblemNavigationView];
    [self slideViewFromRight:self.addProblemNavigationView];
    NSLog(@"%@", self.addProblemLocation);
    NSLog(@"%@", self.addProblemLocation.view);
//    [self addChildViewController:self.addProblemLocation];
    
    self.curView = self.addProblemLocation.view;
    
    [self slideViewFromRight:self.curView];
    self.prevView = nil;
    self.nextView = self.addProblemName.view;
    self.prevButton.hidden = YES;
    
}

- (IBAction)addProblemButtonTap:(id)sender {
    [self loadNibs];

    self.nextButton.hidden = NO;
    UIButton *button = sender;
    button.enabled = NO;
}

- (void)setCurView:(UIView *)curView {
    _curView = curView;
    [self.view addSubview:self.curView];
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
//    self.addProblemLocationView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemLocationView" owner:self options:nil][0];
    
    
    self.addProblemName = [[AddProblemNameViewController alloc] initWithNibName:@"AddProblemNameView" bundle:nil];
    self.addProblemDescription = [[AddProblemDescriptionViewController alloc] initWithNibName:@"AddProblemDescriptionView" bundle:nil];
    self.addProblemType = [[AddProblemTypeViewController alloc] initWithNibName:@"AddProblemTypeView" bundle:nil];
    self.addProblemSolution = [[AddProblemSolutionViewController alloc] initWithNibName:@"AddProblemSolutionView" bundle:nil];
    self.addProblemPhoto = [[AddProblemPhotoViewController alloc] initWithNibName:@"AddProblemPhotoView" bundle:nil];

    [self showAddProblemView];
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
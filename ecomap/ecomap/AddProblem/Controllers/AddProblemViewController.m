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
#import "AddProblemDescriptionViewController.h"

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
@property (weak, nonatomic) IBOutlet UIPickerView *problemTypesPickerVIew;
@property (weak, nonatomic) IBOutlet UIButton *addProblemButton;

@property (nonatomic, strong) UIBarButtonItem *closeButton;
@property (nonatomic, strong) NSArray *problemTypes;

//AddProblemViews
@property (nonatomic, strong) UIView* addProblemNavigationView;
@property (nonatomic, strong) UIView* addProblemLocationView;
@property (nonatomic, strong) UIView* addProblemNameView;
@property (nonatomic, strong) UIView* addProblemTypeView;
@property (nonatomic, strong) UIView* addProblemDescriptionView;
@property (nonatomic, strong) UIView* addProblemSolutionView;
@property (nonatomic, strong) UIView* addProblemPhotoView;
@property (nonatomic, strong) AddProblemDescriptionViewController* addProblemDescription;
@property (nonatomic, strong) UIView* curView;
@property (nonatomic, strong) UIView* prevView;
@property (nonatomic, strong) UIView* nextView;




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

#pragma mark - PickerView

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.problemTypes[row];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 7;
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
            self.nextView = self.addProblemNameView;
            break;
        case 1:
            self.nextView = self.addProblemTypeView;
            self.prevView = self.addProblemLocationView;
            break;
        case 2:
            self.nextView = self.addProblemDescriptionView;
            self.prevView = self.addProblemNameView;
            break;
        case 3:
            self.nextView = self.addProblemSolutionView;
            self.prevView = self.addProblemTypeView;
            break;
        case 4:
            self.prevView = self.addProblemDescriptionView;
            self.nextView = self.addProblemPhotoView;
            break;
        case 5:
            self.prevView = self.addProblemSolutionView;
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
    self.curView = self.addProblemLocationView;
    [self slideViewFromRight:self.curView];
    self.prevView = nil;
    self.nextView = self.addProblemNameView;
    self.prevButton.hidden = YES;
    
}

- (IBAction)addProblemButtonTap:(id)sender {
//    [self loadNibs];
//    [self showAddProblemView];
//    self.nextButton.hidden = NO;
//    UIButton *button = sender;
//    button.enabled = NO;
    [self addChildViewController:self.addProblemDescription];
}

- (void)setCurView:(UIView *)curView {
    self.curView = curView;
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
    self.addProblemDescription = [[AddProblemDescriptionViewController alloc] initWithNibName:@"AddProblemDescriptionView" bundle:nil];
    self.addProblemNavigationView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemNavigationView" owner:self options:nil][0];
    self.addProblemLocationView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemLocationView" owner:self options:nil][0];
    self.addProblemNameView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemNameView" owner:self options:nil][0];
    self.addProblemTypeView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemTypeView" owner:self options:nil][0];
    self.addProblemDescriptionView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemDescriptionView" owner:self options:nil][0];
    self.addProblemSolutionView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemSolutionView" owner:self options:nil][0];
    self.addProblemPhotoView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemPhotoView" owner:self options:nil][0];
    [self.problemTypesPickerVIew selectRow:4 inComponent:0 animated:NO];
    self.problemTypes = [NSArray arrayWithObjects:@"Проблеми лісів", @"Сміттєзвалища", @"Незаконна забудова",
                     @"Проблеми водойм", @"Загрози біорізноманіттю", @"Браконьєрство", @"Інші проблеми", nil];
    
}

- (CGFloat)getViewHeight:(UIView *)view {
    CGFloat height = 0.0;
    if (view == self.addProblemNavigationView)
        height = ADDPROBLEMNAVIGATIONVIEWHEIGHT;
    else if (view == self.addProblemLocationView)
        height = ADDPROBLEMLOCATIONHEIGHT;
    else if (view == self.addProblemNameView)
        height = ADDPROBLEMNAMEHEIGHT;
    else if (view == self.addProblemTypeView)
        height = ADDPROBLEMTYPEHEIGHT;
    else if (view == self.addProblemDescriptionView)
        height = ADDPROBLEMDESCRIPTIONHEIGHT;
    else if (view == self.addProblemSolutionView)
        height = ADDPROBLEMSOLUTIONHEIGHT;
    else if (view == self.addProblemPhotoView)
        height = ADDPROBLEMPHOTOHEIGHT;
    return height;
}




@end

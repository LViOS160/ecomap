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
@property (weak, nonatomic) IBOutlet UIPickerView *problemTypesPickerVIew;
@property (weak, nonatomic) IBOutlet UIButton *addProblemButton;

@property (strong, nonatomic) UIBarButtonItem *closeButton;
@property (nonatomic, strong) NSArray *problemTypes;
@property (nonatomic) BOOL isNextButtonTaped;

//AddProblemViews
@property (nonatomic, strong) UIView* addProblemNavigationView;
@property (nonatomic, strong) UIView* addProblemLocationView;
@property (nonatomic, strong) UIView* addProblemNameView;
@property (nonatomic, strong) UIView* addProblemTypeView;
@property (nonatomic, strong) UIView* addProblemDescriptionView;
@property (nonatomic, strong) UIView* addProblemSolutionView;
@property (nonatomic, strong) UIView* addProblemPhotoView;
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
    return _problemTypes[row];
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
    _prevButton.hidden = NO;
    _isNextButtonTaped = YES;
    _pageControl.currentPage = _pageControl.currentPage + 1;
    
    [self slideViewToLeft:_curView];
    self.curView = _nextView;
    [self slideViewFromRight:_curView];
    [self switchPage];
}

- (IBAction)prevButtonTap:(UIButton *)sender {
    _nextButton.hidden = NO;
    _isNextButtonTaped = NO;
    _pageControl.currentPage = _pageControl.currentPage - 1;
    [self slideViewToRight:_curView];
    self.curView = _prevView;
    [self slideViewFromLeft:_curView];
    [self switchPage];
    
}

- (void)closeButtonTap:(id *)sender {
    _addProblemButton.enabled = YES;
    [self slideViewToRight:_curView];
  //  _curView = nil;
    [self slideViewToRight:_addProblemNavigationView];
//    _addProblemNavigationView = nil;
    self.navigationItem.rightBarButtonItem = nil;
    _pageControl.currentPage = 0;
}

- (void)switchPage{
    switch (_pageControl.currentPage) {
        case 0:
            _prevButton.hidden = YES;
            _nextView = _addProblemNameView;
            break;
        case 1:
            _nextView = _addProblemTypeView;
            _prevView = _addProblemLocationView;
            break;
        case 2:
            _nextView = _addProblemDescriptionView;
            _prevView = _addProblemNameView;
            break;
        case 3:
            _nextView = _addProblemSolutionView;
            _prevView = _addProblemTypeView;
            break;
        case 4:
            _prevView = _addProblemDescriptionView;
            _nextView = _addProblemPhotoView;
            break;
        case 5:
            _prevView = _addProblemSolutionView;
            _nextButton.hidden = YES;
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
    if (view == _addProblemNavigationView)
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
    [self layoutView:_curView];
    [self layoutView:_addProblemNavigationView];
}

- (void)showAddProblemView {
    
    // Close button SetUp
    self.closeButton = [[UIBarButtonItem alloc] init];
    self.closeButton.title = @"Close";
    [self.closeButton setAction:@selector(closeButtonTap:)];
    [self.closeButton setTarget:self];
    self.navigationItem.rightBarButtonItem = self.closeButton;
    [self setPaddings];
    [self.view addSubview:_addProblemNavigationView];
    [self slideViewFromRight:_addProblemNavigationView];    
    self.curView = _addProblemLocationView;
    [self slideViewFromRight:_curView];
    _prevView = nil;
    _nextView = _addProblemNameView;
    _prevButton.hidden = YES;
    
}

- (IBAction)addProblemButtonTap:(id)sender {
    [self loadNibs];
    [self showAddProblemView];
    _nextButton.hidden = NO;
    UIButton *button = sender;
    button.enabled = NO;
}

- (void)setCurView:(UIView *)curView {
    _curView = curView;
    [self.view addSubview:_curView];
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
    if (view == _addProblemNavigationView)
        pad = padding;
    else
        pad = paddingWithNavigationView;
    [view setFrame:CGRectMake(0, pad, screenWidth, height)];
}




#pragma mark - AddProblemNibs

- (void)loadNibs {
    _addProblemNavigationView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemNavigationView" owner:self options:nil][0];
    _addProblemLocationView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemLocationView" owner:self options:nil][0];
    _addProblemNameView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemNameView" owner:self options:nil][0];
    _addProblemTypeView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemTypeView" owner:self options:nil][0];
    _addProblemDescriptionView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemDescriptionView" owner:self options:nil][0];
    _addProblemSolutionView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemSolutionView" owner:self options:nil][0];
    _addProblemPhotoView = [[NSBundle mainBundle] loadNibNamed:@"AddProblemPhotoView" owner:self options:nil][0];
    [_problemTypesPickerVIew selectRow:4 inComponent:0 animated:NO];
    _problemTypes = [NSArray arrayWithObjects:@"Проблеми лісів", @"Сміттєзвалища", @"Незаконна забудова",
                     @"Проблеми водойм", @"Загрози біорізноманіттю", @"Браконьєрство", @"Інші проблеми", nil];
    
}

- (CGFloat)getViewHeight:(UIView *)view {
    CGFloat height = 0.0;
    if (view == _addProblemNavigationView)
        height = ADDPROBLEMNAVIGATIONVIEWHEIGHT;
    else if (view == _addProblemLocationView)
        height = ADDPROBLEMLOCATIONHEIGHT;
    else if (view == _addProblemNameView)
        height = ADDPROBLEMNAMEHEIGHT;
    else if (view == _addProblemTypeView)
        height = ADDPROBLEMTYPEHEIGHT;
    else if (view == _addProblemDescriptionView)
        height = ADDPROBLEMDESCRIPTIONHEIGHT;
    else if (view == _addProblemSolutionView)
        height = ADDPROBLEMSOLUTIONHEIGHT;
    else if (view == _addProblemPhotoView)
        height = ADDPROBLEMPHOTOHEIGHT;
    return height;
}




@end

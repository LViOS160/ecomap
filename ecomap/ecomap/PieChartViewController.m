//
//  PieChartViewController.m
//  EcomapStatistics
//
//  Created by ohuratc on 03.02.15.
//  Copyright (c) 2015 Huralnyk. All rights reserved.
//

#import "PieChartViewController.h"
#import "EcomapRevealViewController.h"
#import "XYPieChart.h"
#import "EcomapURLFetcher.h"
#import "EcomapPathDefine.h"
#import "EcomapStatsParser.h"
#import "GeneralStatsTopLabelView.h"

#define NUMBER_OF_TOP_LABELS 4

@interface PieChartViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *statsRangeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *topLabelSpinner;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *pieChartSpinner;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *slices;
@property (nonatomic, strong) NSArray *sliceColors;

@end

@implementation PieChartViewController

#pragma mark - Properties

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width * NUMBER_OF_TOP_LABELS, _scrollView.bounds.size.height);
    _scrollView.scrollEnabled = NO;
}

- (void)setStatsForPieChart:(NSArray *)statsForPieChart
{
    _statsForPieChart = statsForPieChart;
    [self.pieChartSpinner stopAnimating];
    [self drawPieChart];
}

- (void)setGeneralStats:(NSArray *)generalStats
{
    _generalStats = generalStats;
    [self.topLabelSpinner stopAnimating];
}

#pragma mark - Gesture Handlers

- (IBAction)swipeRight:(UISwipeGestureRecognizer *)sender
{
    self.pageControl.currentPage--;
    [self switchPage];
}

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender
{
    self.pageControl.currentPage++;
    [self switchPage];
}

- (IBAction)touchPageControl:(UIPageControl *)sender
{
    [self switchPage];
}

- (IBAction)changeRangeOfShowingStats:(UISegmentedControl *)sender
{
    [self fetchStats];
}

#pragma mark - Generating Data

- (void)generateTopLabelViews
{
    for(int i = 0; i < NUMBER_OF_TOP_LABELS; i++)
    {
        GeneralStatsTopLabelView *topLabelView = [[GeneralStatsTopLabelView alloc] init];
        topLabelView.numberOfInstances = [EcomapStatsParser integerForNumberLabelForInstanceNumber:i inStatsArray:self.generalStats];
        topLabelView.nameOfInstances = [EcomapStatsParser stringForNameLabelForInstanceNumber:i];
        topLabelView.frame = CGRectMake(0 + i * self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        [self.scrollView addSubview:topLabelView];
    }
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width * NUMBER_OF_TOP_LABELS, _scrollView.bounds.size.height);
}

- (UIColor *)getSliceColorForProblemType:(NSNumber *)problemTypeID
{
    NSInteger iProblemTypeID = [problemTypeID integerValue];
    
    switch (iProblemTypeID) {
        case 1: return [UIColor colorWithRed:9/255.0 green:91/255.0 blue:15/255.0 alpha:1];
        case 2: return [UIColor colorWithRed:35/255.0 green:31/255.0 blue:32/255.0 alpha:1];
        case 3: return [UIColor colorWithRed:152/255.0 green:68/255.0 blue:43/255.0 alpha:1];
        case 4: return [UIColor colorWithRed:27/255.0 green:154/255.0 blue:214/255.0 alpha:1];
        case 5: return [UIColor colorWithRed:113/255.0 green:191/255.0 blue:68/255.0 alpha:1];
        case 6: return [UIColor colorWithRed:255/255.0 green:171/255.0 blue:9/255.0 alpha:1];
        case 7: return [UIColor colorWithRed:80/255.0 green:9/255.0 blue:91/255.0 alpha:1];
    }
    
    return [UIColor clearColor];
}

- (NSArray *)generateSliceColors
{
    NSMutableArray *mutableSliceColors = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [self.statsForPieChart count]; i++)
    {
        NSDictionary *problems = self.statsForPieChart[i];
        NSNumber *problemID = [NSNumber numberWithInteger:[[problems valueForKey:@"id"] integerValue]];
        UIColor *sliceColor = [self getSliceColorForProblemType:problemID];
        [mutableSliceColors addObject:sliceColor];
    }
    
    return mutableSliceColors;
}

- (void)switchPage
{
    [self.scrollView scrollRectToVisible:CGRectMake(self.pageControl.currentPage * self.scrollView.bounds.size.width,
                                                    0,
                                                    self.scrollView.bounds.size.width,
                                                    self.scrollView.bounds.size.height)
                                animated:YES];
}

#pragma mark - Drawing Pie Chart

- (void)drawPieChart
{
    self.slices = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [self.statsForPieChart count]; i++)
    {
        NSDictionary *problems = self.statsForPieChart[i];
        NSNumber *number = [NSNumber numberWithInteger:[[problems valueForKey:ECOMAP_PROBLEM_VALUE] integerValue]];
        [self.slices addObject:number];
    }
    
    [self.pieChartView setDelegate:self];
    [self.pieChartView setDataSource:self];
    [self.pieChartView setAnimationSpeed:1.0];
    [self.pieChartView setShowPercentage:NO];
    [self.pieChartView setPieCenter:CGPointMake(self.pieChartView.bounds.size.width /2 , self.pieChartView.bounds.size.height / 2)];
    [self.pieChartView setUserInteractionEnabled:NO];
    [self.pieChartView setLabelColor:[UIColor whiteColor]];
    
    self.sliceColors = [self generateSliceColors];
    
    [self.pieChartView reloadData];
}

#pragma mark - Fetching

- (void)fetchStats
{
    [self.pieChartSpinner startAnimating];
    
    NSURL *url = [EcomapURLFetcher URLforStatsForParticularPeriod:[EcomapStatsParser getPeriodForStatsByIndex:self.statsRangeSegmentedControl.selectedSegmentIndex]];
    dispatch_queue_t fetchQ = dispatch_queue_create("fetchQ", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSArray *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                       options:0
                                                                         error:NULL];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statsForPieChart = propertyListResults;
        });
    });
    
}

- (void)fetchGeneralStats
{
    self.generalStats = nil;
    
    [self.topLabelSpinner startAnimating];
    
    NSURL *url = [EcomapURLFetcher URLforGeneralStats];
    dispatch_queue_t fetchGSQ = dispatch_queue_create("fetchGSQ", NULL);
    dispatch_async(fetchGSQ, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSArray *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                       options:0
                                                                         error:NULL];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.generalStats = propertyListResults;
            [self generateTopLabelViews];
        });
    });
}

#pragma mark - UIScroll View Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return self.slices.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[self.slices objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [self.sliceColors objectAtIndex:(index % self.sliceColors.count)];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will select slice at index %lu",(unsigned long)index);
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will deselect slice at index %lu",(unsigned long)index);
}
- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did deselect slice at index %lu",(unsigned long)index);
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did select slice at index %lu",(unsigned long)index);
}

#pragma mark - Initialization

- (void)customSetup
{
    EcomapRevealViewController *revealViewController = (EcomapRevealViewController *)self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchStats];
    [self fetchGeneralStats];
    [self customSetup];
}

@end

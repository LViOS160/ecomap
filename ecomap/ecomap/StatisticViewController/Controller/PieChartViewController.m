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
#import "EcomapStatsFetcher.h"
#import "EcomapURLFetcher.h"
#import "EcomapPathDefine.h"
#import "EcomapStatsParser.h"
#import "GeneralStatsTopLabelView.h"
#import "GlobalLoggerLevel.h"

#define NUMBER_OF_TOP_LABELS 4

@interface PieChartViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *statsRangeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *topLabelSpinner;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *pieChartSpinner;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

// Data for drawing the Pie Chart
@property (nonatomic, strong) NSMutableArray *slices;
@property (nonatomic, strong) NSArray *sliceColors;

@end

@implementation PieChartViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
    
    
    [super viewDidLoad];
    
    // Download data from Ecomap server to draw General Stats Top Labels
    [self fetchGeneralStats];
    
    // Download data from Ecomap server to draw the Pie Chart
    [self fetchStatsForPieChart];

    // Set up reveal button
    [self customSetup];
    
    Statistics *ob = [Statistics sharedInstanceStatistics];
    
    [self setSlices:[ob countAllProblemsCategory]];
    //self.slices = [NSMutableArray arrayWithArray: ob.allProblemsPieChart];
    
    
   [self drawPieChart];
}

- (void)customSetup
{
    EcomapRevealViewController *revealViewController = (EcomapRevealViewController *)self.revealViewController;
    if(revealViewController) {
        [self.revealButtonItem setTarget:self.revealViewController];
        [self.revealButtonItem setAction:@selector(revealToggle:)];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self resizeTopLabelViews];
    self.pieChartView.pieRadius = [self pieChartRadius];
    [self drawPieChart];
    [self switchPage];
}

#pragma mark - Properties

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * NUMBER_OF_TOP_LABELS, self.scrollView.bounds.size.height);
    _scrollView.scrollEnabled = NO;
}

- (void)setStatsForPieChart:(NSArray *)statsForPieChart
{
    _statsForPieChart = statsForPieChart;
    [self.pieChartSpinner stopAnimating];
    self.pieChartView.pieRadius = [self pieChartRadius];
    [self drawPieChart];
}

- (void)setGeneralStats:(NSArray *)generalStats
{
    _generalStats = generalStats;
    [self.topLabelSpinner stopAnimating];
}

#pragma mark - User Interaction Handlers

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
    [self fetchStatsForPieChart];
}

#pragma mark - Utility Methods

- (void)generateTopLabelViews
{
    for(int i = 0; i < NUMBER_OF_TOP_LABELS; i++) {
        GeneralStatsTopLabelView *topLabelView = [[GeneralStatsTopLabelView alloc] init];
        topLabelView.numberOfInstances = [EcomapStatsParser integerForNumberLabelForInstanceNumber:i inGeneralStatsArray:self.generalStats];
        topLabelView.nameOfInstances = [EcomapStatsParser stringForNameLabelForInstanceNumber:i];
        topLabelView.frame = CGRectMake(0 + i * self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        [self.scrollView addSubview:topLabelView];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * NUMBER_OF_TOP_LABELS, self.scrollView.bounds.size.height);
}

- (void)resizeTopLabelViews
{
    int i = 0;
    
    for(UIView *subView in self.scrollView.subviews) {
            if([subView isKindOfClass:[GeneralStatsTopLabelView class]]) {
            [subView setFrame:CGRectMake(0 + i * self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
            i++;
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * NUMBER_OF_TOP_LABELS, self.scrollView.bounds.size.height);

}

- (void)switchPage
{
    [self.scrollView scrollRectToVisible:CGRectMake(self.pageControl.currentPage * self.scrollView.bounds.size.width,
                                                    0,
                                                    self.scrollView.bounds.size.width,
                                                    self.scrollView.bounds.size.height)
                                animated:YES];
}

// Convert NSInteger to EcomapStatsTimePeriod
- (EcomapStatsTimePeriod)periodForStatsByIndex:(NSInteger)index
{
    switch(index) {
        case 0: return EcomapStatsForLastDay;
        case 1: return EcomapStatsForLastWeek;
        case 2: return EcomapStatsForLastMonth;
        case 3: return EcomapStatsForLastYear;
        case 4: return EcomapStatsForAllTheTime;
        default: return EcomapStatsForAllTheTime;
    }
}

#pragma mark - Drawing Pie Chart

#define DEFAULT_DIAMETER_OF_PIE_CHART_FRAME 375.00
#define DEFAULT_RADIUS_OF_PIE_CHART 148.00

- (CGFloat)radiusScaleFactor {
    if(self.pieChartView.bounds.size.height < self.pieChartView.bounds.size.width) {
        return self.pieChartView.bounds.size.height / DEFAULT_DIAMETER_OF_PIE_CHART_FRAME;
    } else {
        return self.pieChartView.bounds.size.width / DEFAULT_DIAMETER_OF_PIE_CHART_FRAME;
    }
}

- (CGFloat)pieChartRadius {
    return [self radiusScaleFactor] * DEFAULT_RADIUS_OF_PIE_CHART;
}

- (void)drawPieChart
{
    self.slices;
    // Set data to draw the Pie Chart
  /*  self.slices = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [self.statsForPieChart count]; i++) {
        NSDictionary *problems = self.statsForPieChart[i];
        NSNumber *number = [NSNumber numberWithInteger:[[problems valueForKey:ECOMAP_PROBLEM_VALUE] integerValue]];
        [self.slices addObject:number];
    }*/
    
    [self.pieChartView setDelegate:self];
    [self.pieChartView setDataSource:self];
    [self.pieChartView setAnimationSpeed:1.0];
    [self.pieChartView setShowPercentage:NO];
    [self.pieChartView setPieCenter:CGPointMake(self.pieChartView.bounds.size.width /2 , self.pieChartView.bounds.size.height / 2)];
    [self.pieChartView setUserInteractionEnabled:NO];
    [self.pieChartView setLabelColor:[UIColor whiteColor]];
    
    self.sliceColors = [self sliceColors];
    
    [self.pieChartView reloadData];
}

- (NSArray *)sliceColors
{
    NSMutableArray *mutableSliceColors = [[NSMutableArray alloc] init];
    
    for(NSDictionary *problem in self.statsForPieChart) {
        NSUInteger problemID = [[problem valueForKey:@"id"] integerValue];
        UIColor *sliceColor = [EcomapStatsParser colorForProblemType:problemID];
        [mutableSliceColors addObject:sliceColor];
    }
    
    return mutableSliceColors;
}

#pragma mark - Fetching

- (void)fetchStatsForPieChart
{
    [self.pieChartSpinner startAnimating];
    
    EcomapStatsTimePeriod timePeriod = [self periodForStatsByIndex:self.statsRangeSegmentedControl.selectedSegmentIndex];
    
    [EcomapStatsFetcher loadStatsForPeriod:timePeriod onCompletion:^(NSArray *stats, NSError *error) {
        if(!error) {
            self.statsForPieChart = stats;
            [self.pieChartSpinner stopAnimating];
        } else {
            DDLogError(@"Error: %@", error);
        }
    }];
}

- (void)fetchGeneralStats
{
    self.generalStats = nil;
    [self.topLabelSpinner startAnimating];
    
    [EcomapStatsFetcher loadGeneralStatsOnCompletion:^(NSArray *stats, NSError *error) {
        if(!error) {
            self.generalStats = stats;
            [self.topLabelSpinner stopAnimating];
            [self generateTopLabelViews];
        } else {
            DDLogError(@"Error: %@", error);
        }
    }];
}

#pragma mark - UIScroll View Delegate

// Disable zooming in scroll view
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return [self.slices count];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[self.slices objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [UIColor blueColor];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
    DDLogVerbose(@"will select slice at index %lu",(unsigned long)index);
}

- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
    DDLogVerbose(@"will deselect slice at index %lu",(unsigned long)index);
}

- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
    DDLogVerbose(@"did deselect slice at index %lu",(unsigned long)index);
}

- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    DDLogVerbose(@"did select slice at index %lu",(unsigned long)index);
}

@end

//
//  PieChartViewController.m
//  EcomapStatistics
//
//  Created by ohuratc on 03.02.15.
//  Copyright (c) 2015 Huralnyk. All rights reserved.
//

#import "PieChartViewController.h"
#import "XYPieChart.h"
#import "EcomapURLFetcher.h"
#import "EcomapPathDefine.h"

@interface PieChartViewController ()

@property (weak, nonatomic) IBOutlet UILabel *numOfProblemsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfVotesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfCommentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfPhotosLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *statsRangeSegmentedControl;

@property(nonatomic, strong) NSMutableArray *slices;
@property(nonatomic, strong) NSArray        *sliceColors;

@end

@implementation PieChartViewController

-(void)setStatsForPieChart:(NSArray *)statsForPieChart
{
    [self redrawPieChart];
    _statsForPieChart = statsForPieChart;
}

- (IBAction)changeRangeOfShowingStats:(UISegmentedControl *)sender
{
    [self fetchStats];
}

- (void)updateUI
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self changeRangeOfShowingStats:self.statsRangeSegmentedControl];
    [self fetchStats];
    [self redrawPieChart];
}

- (void)redrawPieChart
{
    NSLog(@"Redraw Pie Chart");
    self.slices = [[NSMutableArray alloc] init];
    
    NSLog(@"Stats count = %lu", (unsigned long)[self.statsForPieChart count]);
    
    for(int i = 0; i < [self.statsForPieChart count]; i++)
    {
        NSDictionary *problems = self.statsForPieChart[i];
        NSNumber *number = [NSNumber numberWithInteger:[[problems valueForKey:ECOMAP_PROBLEM_VALUE] integerValue]];
        NSLog(@"number = %@", number);
        [self.slices addObject:number];
    }
    
    [self.pieChartView setDataSource:self];
    [self.pieChartView setStartPieAngle:M_PI_2];
    [self.pieChartView setAnimationSpeed:1.0];
    [self.pieChartView setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:24]];
    [self.pieChartView setLabelRadius:160];
    [self.pieChartView setShowPercentage:YES];
    [self.pieChartView setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [self.pieChartView setPieCenter:CGPointMake(240, 240)];
    [self.pieChartView setUserInteractionEnabled:NO];
    [self.pieChartView setLabelShadowColor:[UIColor blackColor]];
    
    self.sliceColors =[NSArray arrayWithObjects:
                       [UIColor colorWithRed:246/255.0 green:155/255.0 blue:0/255.0 alpha:1],
                       [UIColor colorWithRed:129/255.0 green:195/255.0 blue:29/255.0 alpha:1],
                       [UIColor colorWithRed:62/255.0 green:173/255.0 blue:219/255.0 alpha:1],
                       [UIColor colorWithRed:229/255.0 green:66/255.0 blue:115/255.0 alpha:1],
                       [UIColor colorWithRed:148/255.0 green:141/255.0 blue:139/255.0 alpha:1],nil];
    
    [self.pieChartView reloadData];
}

- (void)fetchStats
{
    NSURL *url = [EcomapURLFetcher URLforStatsParticularPeriod:[self getPeriodForStats]];
    dispatch_queue_t fetchQ = dispatch_queue_create("fetchQ", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSArray *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                   options:0
                                                                     error:NULL];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statsForPieChart = propertyListResults;
            //NSLog(@"%@", propertyListResults);
        });
    });

}

-(EcomapStatsTimePeriod)getPeriodForStats
{
    switch(self.statsRangeSegmentedControl.selectedSegmentIndex) {
        case 0: return EcomapStatsForLastDay;
        case 1: return EcomapStatsForLastWeek;
        case 2: return EcomapStatsForLastMonth;
        case 3: return EcomapStatsForLastYear;
        case 4: return EcomapStatsForAllTheTime;
        default: return EcomapStatsForAllTheTime;
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateUI];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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


@end

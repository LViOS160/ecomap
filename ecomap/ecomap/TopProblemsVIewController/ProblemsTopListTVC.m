//
//  ProblemsTopListTVC.m
//  EcomapStatistics
//
//  Created by ohuratc on 04.02.15.
//  Copyright (c) 2015 Huralnyk. All rights reserved.
//

#import "ProblemsTopListTVC.h"
#import "EcomapStatsFetcher.h"
#import "EcomapProblemDetails.h"
#import "EcomapURLFetcher.h"
#import "EcomapStatsParser.h"
#import "EcomapPathDefine.h"
#import "EcomapRevealViewController.h"
#import "ProblemViewController.h"

//Setup DDLog
#import "GlobalLoggerLevel.h"

@interface ProblemsTopListTVC ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *kindOfTopChartSegmentedControl;
@property (strong, nonatomic) NSArray *currentChart;
@property (nonatomic) EcomapKindfOfTheProblemsTopList kindOfTopChart;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *tableSpinner;

@end

@implementation ProblemsTopListTVC

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // We're starting with hidden table, because we don't have data to populate it
    self.tableView.hidden = YES;
    
    // Download data from Ecomap server to populate "Top Of The Problems" chart
    [self fetchChartsOfTheTopProblems];
    
    // Set up kind of "Top Of The Problems" chart
    // we want to display and draw it
    [self changeKindOfTopChart:self.kindOfTopChartSegmentedControl];
    
    // Set up reveal button
    [self customSetup];
}

- (void)customSetup
{
    EcomapRevealViewController *revealViewController = (EcomapRevealViewController *)self.revealViewController;
    if (revealViewController)
    {
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector(revealToggle:)];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark - Properties

- (void)setCurrentChart:(NSArray *)problems
{
    // Evety time when table data source is changed, redraw the table.
    _currentChart = problems;
    [self.tableView reloadData];
}

#pragma mark - User Interaction Handlers

- (IBAction)changeKindOfTopChart:(UISegmentedControl *)sender
{
    switch(sender.selectedSegmentIndex) {
        case 0:
            self.kindOfTopChart = EcomapMostVotedProblemsTopList;
            self.navigationItem.title = ECOMAP_MOST_VOTED_PROBLEMS_CHART_TITLE;
            break;
        case 1:
            self.kindOfTopChart = EcomapMostSevereProblemsTopList;
            self.navigationItem.title = ECOMAP_MOST_SEVERE_PROBLEMS_CHART_TITLE;
            break;
        case 2:
            self.kindOfTopChart = EcomapMostCommentedProblemsTopList;
            self.navigationItem.title = ECOMAP_MOST_COMMENTED_PROBLEMS_CHART_TITLE;
            break;
    }
    
    [self changeChart];
}

#pragma mark - Utility Methods

- (void)changeChart
{
    NSArray *chart = [EcomapStatsParser paticularTopChart:self.kindOfTopChart
                                                           from:self.charts];
    self.currentChart = chart;
}

#pragma mark - Fetching

- (void)fetchChartsOfTheTopProblems
{
    [self.tableSpinner startAnimating];
    [EcomapStatsFetcher loadTopChartsOnCompletion:^(NSArray *charts, NSError *error) {
        if(!error) {
            self.charts = charts;
            [self.tableSpinner stopAnimating];
            
            // Show the table
            self.tableView.hidden = NO;
            
            [self changeChart];
        }
    }];
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.currentChart count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Top Problem Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Display data in the cell
    
    NSDictionary *problem = self.currentChart[indexPath.row];
    
    UILabel *problemTitleLabel = (UILabel *)[cell viewWithTag:100];
    problemTitleLabel.text = [NSString stringWithFormat:@"%@", [problem valueForKey: ECOMAP_PROBLEM_TITLE]];
    
    UILabel *problemScoreLabel = (UILabel *)[cell viewWithTag:101];
    problemScoreLabel.text = [EcomapStatsParser scoreOfProblem:problem forChartType:self.kindOfTopChart];
    
    UIImageView *problemScoreImageView = (UIImageView *)[cell viewWithTag:102];
    problemScoreImageView.image = [EcomapStatsParser scoreImageOfProblem:problem forChartType:self.kindOfTopChart];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([segue.identifier isEqualToString:@"Show Problem"]) {
        if([segue.destinationViewController isKindOfClass:[ProblemViewController class]]) {
            ProblemViewController *problemVC = segue.destinationViewController;
            NSDictionary *problem = self.currentChart[indexPath.row];
            problemVC.problemID = [[problem valueForKey:ECOMAP_PROBLEM_ID] integerValue];
        }
    }
}

@end

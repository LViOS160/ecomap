//
//  ProblemsTopListTVC.m
//  EcomapStatistics
//
//  Created by ohuratc on 04.02.15.
//  Copyright (c) 2015 Huralnyk. All rights reserved.
//

#import "ProblemsTopListTVC.h"
#import "EcomapFetcher.h"
#import "EcomapProblemDetails.h"
#import "EcomapURLFetcher.h"
#import "EcomapStatsParser.h"
#import "EcomapPathDefine.h"
#import "EcomapRevealViewController.h"

@interface ProblemsTopListTVC ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *kindOfTopChartSegmentedControl;
@property (nonatomic) EcomapKindfOfTheProblemsTopList kindOfTopChart;
@property (strong, nonatomic) NSArray *charts;
@property (strong, nonatomic) IBOutlet UITableView *topChartTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;


@end

@implementation ProblemsTopListTVC

#pragma mark - Properties

- (NSArray *)charts
{
    if(!_charts) _charts = [[NSArray alloc] init];
    return _charts;
}

- (void)setProblems:(NSArray *)problems
{
    _problems = problems;
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
    
    [self drawChart];
}

#pragma mark - Utility Methods

- (void)drawChart
{
    NSArray *problems = [EcomapStatsParser getPaticularTopChart:self.kindOfTopChart
                                                           from:self.charts];
    self.problems = problems;
}

#pragma mark - Fetching

- (void)fetchProblems
{
    [EcomapFetcher loadTopChartsOnCompletion:^(NSArray *charts, NSError *error) {
        if(!error) {
            self.charts = charts;
            [self drawChart];
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
    return [self.problems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Ecomap Problem Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *problem = self.problems[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [problem valueForKey: ECOMAP_PROBLEM_TITLE]];
    cell.textLabel.text = [EcomapStatsParser getTitleForParticularTopChart:self.kindOfTopChart fromProblem:problem];
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchProblems];
    [self changeKindOfTopChart:self.kindOfTopChartSegmentedControl];
    [self customSetup];
}

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

@end

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
#import "ProblemViewController.h"

//Setup DDLog
#import "GlobalLoggerLevel.h"

// Testing

#import "EcomapAdminFetcher.h"
#import "EcomapLoggedUser.h"
#import "EcomapEditableProblem.h"

@interface ProblemsTopListTVC ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *kindOfTopChartSegmentedControl;
@property (nonatomic) EcomapKindfOfTheProblemsTopList kindOfTopChart;
@property (strong, nonatomic) NSArray *charts;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

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
    
    static NSString *cellIdentifier = @"Top Problem Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Display data in the cell
    
    NSDictionary *problem = self.problems[indexPath.row];
    
    UILabel *problemTitleLabel = (UILabel *)[cell viewWithTag:100];
    problemTitleLabel.text = [NSString stringWithFormat:@"%@", [problem valueForKey: ECOMAP_PROBLEM_TITLE]];
    
    UILabel *problemScoreLabel = (UILabel *)[cell viewWithTag:101];
    problemScoreLabel.text = [EcomapStatsParser scoreOfProblem:problem forChartType:self.kindOfTopChart];
    
    UIImageView *problemScoreImageView = (UIImageView *)[cell viewWithTag:102];
    problemScoreImageView.image = [EcomapStatsParser scoreImageOfProblem:problem forChartType:self.kindOfTopChart];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([segue.identifier isEqualToString:@"Show Problem"]) {
        if([segue.destinationViewController isKindOfClass:[ProblemViewController class]]) {
            ProblemViewController *problemVC = segue.destinationViewController;
            NSDictionary *problem = self.problems[indexPath.row];
            problemVC.problemID = [[problem valueForKey:ECOMAP_PROBLEM_ID] integerValue];
        }
    }
}

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchProblems];
    [self changeKindOfTopChart:self.kindOfTopChartSegmentedControl];
    [self customSetup];
    
#warning Admin's API Testing
    
    EcomapEditableProblem *eProblem = [[EcomapEditableProblem alloc] init];
    
    eProblem.content = @"It's a problem with content";
    eProblem.solved = YES;
    eProblem.proposal = @"We should be creative about proposals";
    eProblem.severity = 5;
    eProblem.title = @"Not 2, but title of problem";
    
    [EcomapAdminFetcher changeProblem:238 withNewProblem:eProblem onCompletion:^(NSData *result, NSError *error) {
        if(error) {
            DDLogError(@"ERROR: %@", error);
        } else {
            DDLogVerbose(@"Result: %@", [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:NULL]);
        }
    }];
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

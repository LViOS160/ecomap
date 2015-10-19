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
#import "EcomapTOP10.h"

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

- (void)viewDidLoad
{
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
    
    EcomapTOP10 *obj = [EcomapTOP10 sharedInstanceTOP10];
   // NSArray *chart = obj.allProblems;
    [obj sortAllProblems];
    self.currentChart = obj.problemComment;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Reload table view to clear all selection
    [self.tableView reloadData];
}

- (void)customSetup
{
    EcomapRevealViewController *revealViewController = (EcomapRevealViewController *)self.revealViewController;
    if (revealViewController)
    {
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector(revealToggle:)];
        [self.navigationController.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        [self.navigationController.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
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
    switch(sender.selectedSegmentIndex)
    {
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
    EcomapTOP10 *obj = [EcomapTOP10 sharedInstanceTOP10];
    [obj sortAllProblems];
    if (self.kindOfTopChart == EcomapMostCommentedProblemsTopList)
    {
        self.charts = obj.problemComment;
    }
    else if (self.kindOfTopChart == EcomapMostSevereProblemsTopList)
    {
        self.charts = obj.problemSeverity;
    }
    else if (self.kindOfTopChart == EcomapMostVotedProblemsTopList)
    {
        self.charts = obj.problemVote;
    }
    [self.tableView reloadData];
}

#pragma mark - Fetching

- (void)fetchChartsOfTheTopProblems
{
    [self.tableSpinner startAnimating];
           if(!self.currentChart)
        {
            self.charts = self.currentChart;
            [self.tableSpinner stopAnimating];
            
            // Show the table
            self.tableView.hidden = NO;
            
            [self changeChart];
        }
}

#pragma mark - UITableView Data Source & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.currentChart count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Top Problem Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    // Display data in the cell
    
    EcomapProblem *problem = (EcomapProblem*)self.charts[indexPath.row];
    UILabel *problemTitleLabel = (UILabel *)[cell viewWithTag:100];
    problemTitleLabel.text = [NSString stringWithFormat:@"%@", problem.title];
    UILabel *problemScoreLabel = (UILabel *)[cell viewWithTag:101];
    NSString* cont;
    cont =[self scoreOfProblem:problem];
    problemScoreLabel.text = cont;
    UIImageView *problemScoreImageView = (UIImageView *)[cell viewWithTag:102];
    problemScoreImageView.image = [EcomapStatsParser scoreImageOfProblem:problem forChartType:self.kindOfTopChart];
    
    return cell;
}

- (NSString*) scoreOfProblem: (EcomapProblem*)problem
{
    NSString* scoreOfProblem;
    if (self.kindOfTopChart == EcomapMostVotedProblemsTopList)
    {
        scoreOfProblem = [NSString stringWithFormat:@"%lu",problem.vote];
    }
    else if (self.kindOfTopChart == EcomapMostSevereProblemsTopList)
    {
         scoreOfProblem = [NSString stringWithFormat:@"%lu",problem.severity];
    }
    else if (self.kindOfTopChart == EcomapMostCommentedProblemsTopList)
    {
        scoreOfProblem = [NSString stringWithFormat:@"%lu",problem.numberOfComments];
    }
    return scoreOfProblem;
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([segue.identifier isEqualToString:@"Show Problem"])
    {
        if ([segue.destinationViewController isKindOfClass:[ProblemViewController class]])
        {
            ProblemViewController *problemVC = segue.destinationViewController;
            EcomapProblem *problem = self.charts[indexPath.row];
            problemVC.problemID = problem.problemID;
        }
    }
}

@end

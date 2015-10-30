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
#import "TOP10.h"
#import "AppDelegate.h"
#import "EcomapFetchedResultController.h"

@interface ProblemsTopListTVC ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *kindOfTopChartSegmentedControl;
@property (strong, nonatomic) NSArray *currentChart;
@property (nonatomic) EcomapKindfOfTheProblemsTopList kindOfTopChart;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *tableSpinner;

@property(nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ProblemsTopListTVC

@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Initialization

- (NSFetchedResultsController *)fetchedResultsController:(NSString*)sorting {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    
    NSString *entityName = @"Problem";
    NSString *sortBy = sorting;
    
    
    NSFetchRequest *fetchRequest = [EcomapFetchedResultController requestWithEntityName:entityName sortBy:sortBy limit:10];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:appDelegate.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:entityName];
    
    
    
    self.fetchedResultsController = theFetchedResultsController;
    self.fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [self.charts addObject:anObject];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.charts removeObject:anObject];
            break;
            
        case NSFetchedResultsChangeUpdate:
            self.charts[indexPath.row] = anObject;
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
}

-(void)loadProblems
{
    
//    self.arrayWithProblems = [NSMutableArray new];
//    NSMutableArray *allProblems = [NSMutableArray arrayWithArray:[self.fetchedResultsController fetchedObjects]];
//    for (Problem *problem in allProblems)
//    {
//        EcomapProblem *ecoProblem = [[EcomapProblem alloc] initWithProblemFromCoreData:problem];
//        [self.arrayWithProblems addObject:ecoProblem];
//        
//    }
//    
//    self.currentAllProblems = [[NSSet alloc] initWithArray:self.arrayWithProblems];
//    [self renewMap:self.currentAllProblems];
    
}


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
    
    self.currentChart = self.charts;
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
    if (self.kindOfTopChart == EcomapMostCommentedProblemsTopList)
    {
        NSManagedObjectContext* context = [AppDelegate sharedAppDelegate].managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Problem"
                                       inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                                  initWithKey:@"numberOfComments" ascending:NO];
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fetchRequest setFetchLimit:10];
        self.charts = [context executeFetchRequest:fetchRequest error:nil];
    }
    else if (self.kindOfTopChart == EcomapMostSevereProblemsTopList)
    {
        NSManagedObjectContext* context = [AppDelegate sharedAppDelegate].managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Problem"
                                       inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                                  initWithKey:@"severity" ascending:NO];
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fetchRequest setFetchLimit:10];
        self.charts = [context executeFetchRequest:fetchRequest error:nil];
    }
    else if (self.kindOfTopChart == EcomapMostVotedProblemsTopList)
    {
        NSManagedObjectContext* context = [AppDelegate sharedAppDelegate].managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Problem"
                                       inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                                  initWithKey:@"numberOfVotes" ascending:NO];
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fetchRequest setFetchLimit:10];
        self.charts = [context executeFetchRequest:fetchRequest error:nil];
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
    
    Problem *problem = (Problem*)self.charts[indexPath.row];
    UILabel *problemTitleLabel = (UILabel *)[cell viewWithTag:100];
    problemTitleLabel.text =  problem.title;
    UILabel *problemScoreLabel = (UILabel *)[cell viewWithTag:101];
    NSString* cont;
    cont =[self scoreOfProblem:problem];
    problemScoreLabel.text = cont;
    UIImageView *problemScoreImageView = (UIImageView *)[cell viewWithTag:102];
    problemScoreImageView.image = [EcomapStatsParser scoreImageOfProblem:problem forChartType:self.kindOfTopChart];
    
    return cell;
}

- (NSString*) scoreOfProblem: (Problem*)problem
{
    NSString* scoreOfProblem;
    if (self.kindOfTopChart == EcomapMostVotedProblemsTopList)
    {
        scoreOfProblem = [NSString stringWithFormat:@"%@",problem.numberOfVotes];
    }
    else if (self.kindOfTopChart == EcomapMostSevereProblemsTopList)
    {
         scoreOfProblem = [NSString stringWithFormat:@"%@",problem.severity];
    }
    else if (self.kindOfTopChart == EcomapMostCommentedProblemsTopList)
    {
        scoreOfProblem = [NSString stringWithFormat:@"%@",problem.numberOfComments];
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
            Problem *problem = self.charts[indexPath.row];
            problemVC.problemID = [problem.idProblem integerValue];
        }
    }
}

@end

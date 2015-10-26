//
//  ResourcesViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ResourcesViewController.h"
#import "EcomapRevealViewController.h"
#import "EcomapFetcher.h"
#import "ResourceCell.h"
#import "ResourceDetails.h"
#import "EcomapFetcher.h"
#import "EcomapResources.h"
#import "EcomapAlias.h"
#import "EcomapPathDefine.h"
#import "GlobalLoggerLevel.h"
#import "EcomapCoreDataControlPanel.h"

#import "AppDelegate.h"
#import "Resource.h"


@interface ResourcesViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;

@end

@implementation ResourcesViewController


- (void)customSetup
{
    EcomapRevealViewController *revealViewController = (EcomapRevealViewController *)self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        [self.navigationController.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    }

}
//
//#pragma mark - TableView
//
//
//// refreshing method - Spinner refreshing while data loading
//

- (IBAction)refreshing
{
    [self.refreshControl beginRefreshing];
    [EcomapFetcher loadResourcesOnCompletion:^(NSArray *resources, NSError *error)      //class method from ecomapFetcher
     {
         if (!error && resources && resources.count > 0)
         {
             EcomapCoreDataControlPanel *resourcesIntoCD = [EcomapCoreDataControlPanel sharedInstance];
             resourcesIntoCD.resourcesFromWeb = resources;
             [resourcesIntoCD loadResources];
         }
         else
         {
             DDLogVerbose(@"ERROR");
         }
         
         [self.refreshControl endRefreshing];
     }
     ];
}

#pragma mark - For WebView

-(void)webrefreshingOnCompletion:(void (^)(NSString *descriptionRes, NSError *error))completionHandler     // return the content of recource/alias .....
{
    //self.currentPath = @"id";
    
    [EcomapFetcher loadAliasOnCompletion:^(NSArray *alias, NSError *error) {
        if (!error)
        {
            EcomapAlias *ecoal = nil;
            ecoal=alias.firstObject;
            completionHandler(ecoal.content, nil);
            
        }
        else
        {
            DDLogVerbose(@"Error");
        }
        
        
    } String:self.currentPath];
    
}


#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowDetails"])
    {
        ResourceDetails *detailviewcontroller = [segue destinationViewController];        // Choose the content depending on the number of row in TableView(and as result its find the alias)
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        NSInteger row = [myIndexPath row];
        self.currentPath = self.pathes[row];
        [self webrefreshingOnCompletion:^(NSString *descriptionRes, NSError *error) {
            detailviewcontroller.details = descriptionRes;
        }];
        
    }
    
    
}

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customSetup];
    [self refreshing];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    

    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Resource" inManagedObjectContext:self.managedObjectContext];
    
    [request setEntity:description];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"resourceID" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [request setSortDescriptors:sortDescriptors];
    
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    
    NSManagedObjectContext* context = appDelegate.managedObjectContext;
    self.managedObjectContext = context;
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]
                                                             initWithFetchRequest:request
                                                             managedObjectContext:self.managedObjectContext
                                                             sectionNameKeyPath:nil
                                                             cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Resource *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = object.title;
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
}

@end

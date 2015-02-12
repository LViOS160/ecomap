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
#import  "EcomapFetcher.h"
#import "EcomapResources.h"
#import "EcomapAlias.h"
#import "EcomapPathDefine.h"
@interface ResourcesViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;

@end

@implementation ResourcesViewController

@synthesize titleRes = _titleRes;

#pragma mark - Init

-(NSString *)currentPath
{
    if(!_currentPath)
        _currentPath=[[NSString alloc]init];
    return _currentPath;
}


-(void)setTitleRes:(NSMutableArray *)titleRes
{
    _titleRes = titleRes;
    [self.tableView reloadData];
}

-(NSMutableArray *)titleRes
{
    
    if(!_titleRes)
        _titleRes = [[NSMutableArray alloc]init];
    return _titleRes;
}

-(NSString *)descriptionRes
{
    if(!_descriptionRes)
        _descriptionRes = [[NSString alloc]init];
    return _descriptionRes;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    [self refreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - TableView


// refreshing method - Spinner refreshing while data loading

- (IBAction)refreshing {
    [self.refreshControl beginRefreshing];
    [EcomapFetcher loadResourcesOnCompletion:^(NSArray *resources, NSError *error)      //class method from ecomapFetcher
     {
         if(!error)
         {
             
             NSMutableArray *titlesOfResources = [[NSMutableArray alloc]init];
             NSMutableArray *aliasesFromResources = [[NSMutableArray alloc]init];
             EcomapResources *ecoResources = [[EcomapResources alloc]init];
             for(id result in resources)
             {    ecoResources = result;
                 [titlesOfResources addObject:ecoResources.titleRes];              // fill the array of Titles of resources
                 [aliasesFromResources addObject:ecoResources.alias];              // fill the array of aliases
                 
                 
             }
             self.titleRes = [[NSMutableArray alloc]initWithArray:titlesOfResources];
             self.pathes = [[NSArray alloc]initWithArray:aliasesFromResources];
             [self.refreshControl endRefreshing];
         }
         else
         {
             NSLog(@"ERROR");
             
         }
     }
     
     ];
    
    
}

#pragma mark - For WebView

-(void)webrefreshingOnCompletion:(void (^)(NSString *descriptionRes, NSError *error))completionHandler     // return the content of recource/alias .....
{
    
    
    [EcomapFetcher loadAliasOnCompletion:^(NSArray *alias, NSError *error) {
        if(!error)
        {
            EcomapAlias *ecoal = [[EcomapAlias alloc]init];
            ecoal=alias.firstObject;
            completionHandler(ecoal.content, nil);
            
        }
        else{
            NSLog(@"Error");
        }
        
        
    } String:self.currentPath];
    
}


#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"ShowDetails"])
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.titleRes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ResourceCell";
    ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    NSInteger row=[indexPath row];
    cell.TitleLabel.text = self.titleRes[row];
    return cell;
}





@end

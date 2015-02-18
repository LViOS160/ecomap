//
//  ProblemActivityViewController.m
//  ecomap
//
//  Created by Inna Labuskaya on 2/19/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ProblemActivityViewController.h"
#import "EcomapComments.h"

@interface ProblemActivityViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *activityTable;
@property (strong, nonatomic) NSArray *activities;

@end

@implementation ProblemActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.activityTable.delegate = self;
    self.activityTable.dataSource = self;
}

- (void)setProblemDetails:(EcomapProblemDetails *)problemDetails
{
    NSMutableArray *activities = [NSMutableArray array];
    for(EcomapComments *comment in problemDetails.comments) {
        if (comment.activityTypes_Id != 5) {
            [activities addObject:comment];
        }
    }
    self.activities = activities;
    [self.activityTable reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.activities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    EcomapComments *comment = [self.activities objectAtIndex:indexPath.row];
    cell.textLabel.text = comment.content;
    
    return cell;
}

@end

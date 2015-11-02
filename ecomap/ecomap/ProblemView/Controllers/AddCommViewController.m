//
//  AddCommViewController.m
//  ecomap
//
//  Created by Mikhail on 2/19/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AddCommViewController.h"
#import "CommentCell.h"
#import "EcomapFetcher.h"
#import "ContainerViewController.h"
#import "EcomapActivity.h"
#import "EcomapCommentaries.h"
#import "EcomapLoggedUser.h"
#import "EcomapProblemDetails.h"
#import "Defines.h"
#import "EcomapUserFetcher.h"
#import "GlobalLoggerLevel.h"
#import "EcomapUserFetcher.h"
#import "EcomapAdminFetcher.h"
#import "InfoActions.h"
#import "AFNetworking.h"

#import "EcomapFetchedResultController.h"
#import "EcomapCoreDataControlPanel.h"
#import "AppDelegate.h"


@interface AddCommViewController () <UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) NSMutableArray* comments;
@property (nonatomic,strong) EcomapProblemDetails * ecoComment;
@property (nonatomic,strong) NSString *problemma;
@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;
@property (nonatomic,strong) UIAlertView *alertView;
@property (nonatomic) NSUInteger currentIDInButton;

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void)editComment:(id)sender;

@end

@implementation AddCommViewController

@synthesize fetchedResultsController = _fetchedResultsController;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addCommentButton.enabled = NO;
    
    //Buttons images localozation
    UIImage *addButtonImage = [UIImage imageNamed:NSLocalizedString(@"AddCommentButtonUKR", @"Add comment button image")];
    [self.addCommentButton setImage:addButtonImage forState:UIControlStateNormal];
   
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Editing comment..." message:@"Edit your comment:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    self.alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [self fetchedResultsController];
    
    [self updateUI];
}




- (NSFetchedResultsController *) fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [EcomapFetchedResultController requestForCommentsWithProblemID:self.problem_ID];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:self.managedObjectContext
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
    
    self.fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.myTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.myTableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self.myTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            [self.myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate:
        {
            [self configureCell:[self.myTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove:
        {
            [self.myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.myTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}


-(void)reload
{
    [self updateUI];
}

-(void)updateUI
{
    self.myTableView.allowsMultipleSelectionDuringEditing = NO;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.estimatedRowHeight = 54.0;
    self.myTableView.rowHeight = UITableViewAutomaticDimension;
    self.textField.delegate = self;
    self.textField.text = @"Add comment";
    self.textField.textColor = [UIColor lightGrayColor];
    self.myTableView.tableFooterView =[[UIView alloc] initWithFrame:CGRectZero];
    [self.myTableView reloadData];
}

-(void)setProblemDetails:(EcomapProblemDetails *)problemDetails
{        
    NSMutableArray *comments = [NSMutableArray array];
     for(EcomapActivity *oneComment in problemDetails.comments )
    {
        if(oneComment.activityTypes_Id ==5)
        {
            [comments addObject:oneComment];
            NSLog(@"(%@, %@ %lu)",oneComment.userName,oneComment.userSurname,(unsigned long)oneComment.usersID);
        }
        self.problemma = [NSString stringWithFormat:@"%lu",(unsigned long)oneComment.problemsID];
    }
        self.comments = comments;
        DDLogVerbose(@"%lu",(unsigned long)self.comments.count);
        [self.myTableView reloadData];
}




- (IBAction)pressAddComment:(id)sender
{
    NSString * fromTextField = self.textField.text;
    EcomapLoggedUser *userIdent = [EcomapLoggedUser currentLoggedUser];
    
    if(userIdent)
    {
        [[NetworkActivityIndicator sharedManager] startActivity];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFJSONRequestSerializer *jsonRequestSerializer = [AFJSONRequestSerializer serializer];
        [manager setRequestSerializer:jsonRequestSerializer];
        NSDictionary *cont = @{ @"content":fromTextField};

        NSInteger problemID = [self.problem_ID integerValue];
        
        [manager POST:[EcomapURLFetcher URLforAddComment:problemID] parameters:cont success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             [EcomapFetcher loadEverything];
         }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"%@",error);
         }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NetworkActivityIndicator sharedManager]endActivity];
        });
        
        [InfoActions showPopupWithMesssage:NSLocalizedString(@"Коментар додано", @"Comment added")];
    }
    
    else
    {
        //show action sheet to login
        [InfoActions showLogitActionSheetFromSender:sender
                           actionAfterSuccseccLogin:^{
                               [self pressAddComment:sender];
                           }];
        return;
    }
    
    if ([self.textField isFirstResponder])
    {
        self.textField.text = @"";
        [self textViewDidEndEditing:self.textField];
    }
}


#pragma  -mark Placeholder

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([self.textField.text isEqualToString:@"Add comment"])
    {
        self.textField.text = @"";
        self.textField.textColor = [UIColor blackColor];
       // self.addCommentButton.enabled = YES;
    }
    [self.textField becomeFirstResponder];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if([self.textField.text isEqualToString:@""])
    {
        self.textField.text = @"Add comment";
        self.textField.textColor = [UIColor lightGrayColor];
        self.addCommentButton.enabled = NO;
    }
    
    [self.textField resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.addCommentButton.enabled = [self.textField.text length]>0;
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count == 0 ? 1 : self.fetchedResultsController.fetchedObjects.count;
}


- (void)configureCell:(CommentCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Comment *object = self.fetchedResultsController.fetchedObjects[indexPath.row];
    
    cell.commentContent.text = object.content;
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    formatter.doesRelativeDateFormatting = YES;
    NSLocale *ukraineLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"uk"];
    [formatter setLocale:ukraineLocale];
    NSString *personalInfo = [NSString stringWithFormat:@"%@", object.created_by];
    NSString *dateInfo = [NSString stringWithFormat:@"%@",object.created_date]; // or modified date
    cell.personInfo.text = personalInfo;
    cell.dateInfo.text = dateInfo;
    EcomapLoggedUser *loggedUser = [EcomapLoggedUser currentLoggedUser];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedResultsController.fetchedObjects.count == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"Коментарі відсутні";
        return cell;
    }
    else if (indexPath.row < self.fetchedResultsController.fetchedObjects.count)
    {
        Comment *object = self.fetchedResultsController.fetchedObjects[indexPath.row];
        
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
        cell.commentContent.text = object.content;
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        formatter.doesRelativeDateFormatting = YES;
        NSLocale *ukraineLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"uk"];
        [formatter setLocale:ukraineLocale];
        NSString *personalInfo = [NSString stringWithFormat:@"%@", object.created_by];
        NSString *dateInfo = [NSString stringWithFormat:@"%@",object.created_date]; // or modified date
        cell.personInfo.text = personalInfo;
        cell.dateInfo.text = dateInfo;
        EcomapLoggedUser *loggedUser = [EcomapLoggedUser currentLoggedUser];
        
        if(loggedUser && ([loggedUser.name isEqualToString:object.created_by] || [loggedUser.role isEqualToString:@"admin"]))
        {
            [self makeButtonForCell:cell];
        }
        
        return cell;
    }
    
    return nil;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *content = [self.alertView textFieldAtIndex:0].text;
        EcomapCommentaries *ob = [EcomapCommentaries sharedInstance];
        NSNumber *num = [[ob.comInfo objectAtIndex:self.currentIDInButton] valueForKey:@"id"];
        
        [EcomapFetcher editComment:[num integerValue] withContent:content onCompletion:^(NSError *error)
        {
            if (!error)
            {
                [EcomapFetcher updateComments:ob.problemsID controller:self];
                [self.myTableView reloadData];
            }
        }];
    }
}


-(void)editComment:(id)sender
{
    UIButton *senderButton = (UIButton *)sender;
    UITableViewCell *buttonCell = (UITableViewCell *)[senderButton superview];
    NSIndexPath* pathOfTheCell = [self.myTableView indexPathForCell:buttonCell];
    CommentCell *cell = [self.myTableView cellForRowAtIndexPath:pathOfTheCell];
    NSInteger row = pathOfTheCell.row;
    self.currentIDInButton = row;
    UITextField *textField = [self.alertView textFieldAtIndex:0];
    [textField setText:cell.commentContent.text];
    [self.alertView show];
}



- (void)makeButtonForCell:(UITableViewCell *)cell
{
    UIButton *addEditButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addEditButton.frame = CGRectMake(cell.frame.size.width*1/2, cell.frame.origin.y, cell.frame.size.width/8, cell.frame.size.height);
    addEditButton.backgroundColor = [UIColor greenColor];
    [addEditButton setTitle:@"Edit" forState:UIControlStateNormal];
    [cell addSubview:addEditButton];
    [addEditButton addTarget:self
                        action:@selector(editComment:)
              forControlEvents:UIControlEventTouchUpInside];
}

// Override to support conditional editing of the table view.leView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.fetchedResultsController.fetchedObjects.count)
    {
        return NO;
    }
    
    EcomapLoggedUser *userIdent = [EcomapLoggedUser currentLoggedUser];
    
    Comment *object = self.fetchedResultsController.fetchedObjects[indexPath.row];
    if([userIdent.name isEqualToString:object.created_by] || [userIdent.role isEqualToString:@"admin"])
    {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    EcomapCommentaries *ob = [EcomapCommentaries sharedInstance];
    
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSNumber *num = [[ob.comInfo objectAtIndex:indexPath.row] valueForKey:@"id"];
        
        [EcomapFetcher deleteComment:[num integerValue] onCompletion:^(NSError *error)
         {
             if (!error)
             {
                 if(ob.comInfo.count ==1)
                 {
                     [ob setComInfo:nil];
                 }
                 [EcomapFetcher updateComments:ob.problemsID controller:self];
                 [UIView transitionWithView:tableView
                                   duration:2
                                    options:UIViewAnimationOptionTransitionCrossDissolve
                                 animations:^(void)
                  {
                      [tableView reloadData];
                  }
                                 completion:nil];
             }
         }];
    }
}
 
@end

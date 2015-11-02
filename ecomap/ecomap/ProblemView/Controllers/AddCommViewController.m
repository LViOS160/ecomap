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
@property (nonatomic,strong) NSString *createdComment;


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




- (NSFetchedResultsController *) fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
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


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.myTableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.myTableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.myTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
           [self configureCell:[self.myTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
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

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if([self.textField.text isEqualToString:@"Add comment"])
    {
        self.textField.text = @"";
        self.textField.textColor = [UIColor blackColor];
       // self.addCommentButton.enabled = YES;
    }
    [self.textField becomeFirstResponder];
    
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if([self.textField.text isEqualToString:@""])
    {
        self.textField.text = @"Add comment";
        self.textField.textColor = [UIColor lightGrayColor];
        self.addCommentButton.enabled = NO;
    }
    
    [self.textField resignFirstResponder];
 

}
-(void)textViewDidChange:(UITextView *)textView
{
    self.addCommentButton.enabled = [self.textField.text length]>0;
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   // [self.arrayOfCommentsForParticularProblem removeAllObjects];
    
//    for (Comment *com in self.fetchedResultsController.fetchedObjects)
//    {
//        
//        NSLog(@"Problem ID from core data %@", com.id_of_problem);
//        
//        if ([self.problem_ID isEqual:com.id_of_problem])
//        {
//            NSLog(@"Comment ID = %@  and Problem ID = %@", com.comment_id, com.id_of_problem);
//        
//            if (!self.arrayOfCommentsForParticularProblem)
//            {
//                self.arrayOfCommentsForParticularProblem = [[NSMutableArray alloc]initWithObjects:com, nil];
//            }
//            else
//            {
//                [self.arrayOfCommentsForParticularProblem addObject:com];
//            }
//        }
//    }
    
//    NSLog(@"Number of rows %ld", (long)self.arrayOfCommentsForParticularProblem.count);
//    NSLog(@"Array of comments %@", self.arrayOfCommentsForParticularProblem);
//    
    return self.fetchedResultsController.fetchedObjects.count == 0 ? 1 : self.fetchedResultsController.fetchedObjects.count;
}


- (void)configureCell:(CommentCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Comment *object = self.fetchedResultsController.fetchedObjects[indexPath.row];
    
    ///CommentCell *cell = [self.myTableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    
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



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    EcomapLoggedUser *userIdent = [EcomapLoggedUser currentLoggedUser];
    
    Comment *object = self.fetchedResultsController.fetchedObjects[indexPath.row];
    if([userIdent.name isEqualToString:object.created_by] || [userIdent.role isEqualToString:@"admin"])
       {
            return YES;
       }
        return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
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
 
    



/*- (NSArray<UITableViewRowAction *>*)tableView:(nonnull UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewRowAction *editAction;
    editAction = [UITableViewRowAction
                       rowActionWithStyle:UITableViewRowActionStyleNormal
                       title:@" Edit "
                       handler:^(UITableViewRowAction * __nonnull action, NSIndexPath * __nonnull indexPath)
    {
        UITextField *textField = [self.alertView textFieldAtIndex:0];
        CommentCell *cell = [self.myTableView cellForRowAtIndexPath:indexPath];
        [textField setText:cell.commentContent.text];
        [self.alertView show];
    }];
    editAction.backgroundColor = [UIColor greenColor];
    
    UITableViewRowAction *deleteAction;
    deleteAction = [UITableViewRowAction
                       rowActionWithStyle:UITableViewRowActionStyleNormal
                       title:@"Delete"
                       handler:^(UITableViewRowAction * __nonnull action, NSIndexPath * __nonnull indexPath)
    {
                           
        EcomapCommentaries *ob = [EcomapCommentaries sharedInstance];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFJSONRequestSerializer *jsonRequestSerializer = [AFJSONRequestSerializer serializer];
        [manager setRequestSerializer:jsonRequestSerializer];
        NSNumber *num = [[ob.comInfo objectAtIndex:indexPath.row] valueForKey:@"id"];
        [manager DELETE:[EcomapURLFetcher URLforChangeComment:[num integerValue]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
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
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            NSLog(@"%@",error);
        }];

     }];
    
    deleteAction.backgroundColor = [UIColor redColor];
    
    return @[ deleteAction, editAction ];
}*/






/*-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"CommentCell";
    CommentCell *cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if(!cell)
    {
        cell = [[CommentCell alloc]init];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    cell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height+=1;
    return height;
}

*/




/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end

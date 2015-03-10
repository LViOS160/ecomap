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
#import "EcomapComments.h"
#import "EcomapCommentaries.h"
#import "EcomapLoggedUser.h"
#import "EcomapProblemDetails.h"
#import "Defines.h"
#import "EcomapUserFetcher.h"
#import "GlobalLoggerLevel.h"
#import "EcomapUserFetcher.h"
#import "EcomapAdminFetcher.h"
#import "InfoActions.h"



@interface AddCommViewController () <UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
@property (nonatomic,strong) NSMutableArray* comments;
@property (nonatomic,strong) EcomapProblemDetails * ecoComment;
@property (nonatomic,strong) NSString *problemma;
@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;

@end

@implementation AddCommViewController



- (void)didReceiveMemoryWarning
{
[super didReceiveMemoryWarning];
}


- (void)viewDidLoad {
    
    [EcomapUserFetcher loginWithEmail:@"admin@.com" andPassword:@"admin" OnCompletion:^(EcomapLoggedUser *loggedUser, NSError *error) {
        
    }];
    [super viewDidLoad];
    self.addCommentButton.enabled = NO;
    [self updateUI];
   
    // Do any additional setup after loading the view.
}

-(void)updateUI
{   self.myTableView.allowsMultipleSelectionDuringEditing = NO;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.estimatedRowHeight = 54.0;
    self.myTableView.rowHeight = UITableViewAutomaticDimension;
    self.textField.delegate = self;
    self.textField.text = @"Add comment";
    self.textField.textColor = [UIColor lightGrayColor];
   
}



-(void)setProblemDetails:(EcomapProblemDetails *)problemDetails
{
    NSMutableArray *comments = [NSMutableArray array];
     for(EcomapComments *oneComment in problemDetails.comments )
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




- (IBAction)pressAddComment:(id)sender  {
    
        NSString * fromTextField = self.textField.text;
        EcomapLoggedUser *userIdent = [EcomapLoggedUser currentLoggedUser];
        NSString * userID = [NSString stringWithFormat:@"%lu",(unsigned long)userIdent.userID];
    
    if(userIdent) {
        if([fromTextField isEqual:@""]) {
            [InfoActions showAlertOfError:NSLocalizedString(@"Будь-ласка, введіть коментар", @"Please, enter your comment")];
            
        } else {
            
            [EcomapFetcher createComment:userID
                                 andName:userIdent.name
                              andSurname:userIdent.surname
                              andContent:fromTextField
                            andProblemId:self.problemma OnCompletion:^(EcomapCommentaries *obj, NSError *error)
             {
                 
                 if(error)
                     DDLogError(@"Error adding comment:%@", [error localizedDescription]);
                 else
                     [[NSNotificationCenter defaultCenter] postNotificationName:PROBLEMS_DETAILS_CHANGED object:self];
                 [InfoActions showPopupWithMesssage:NSLocalizedString(@"Коментар додано", @"Comment added")];
                 
             }];
            
        }

    } else {
        //show action sheet to login
        [InfoActions showLogitActionSheetFromSender:sender
                           actionAfterSuccseccLogin:^{
                               [self pressAddComment:sender];
                           }];
        return;
    }

    if ([self.textField isFirstResponder]) {
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
    self.addCommentButton.enabled = YES;
}


#pragma mark - Table View


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.comments.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    if(!cell)
        cell = [[CommentCell alloc] init];
    EcomapComments *commentaires = [self.comments objectAtIndex:indexPath.row];
    cell.commentContent.text= commentaires.problemContent;
   
    NSDateFormatter *formatter = [NSDateFormatter new];    // Date Fornatter things
    formatter.dateStyle = NSDateFormatterMediumStyle;      //
    formatter.timeStyle = NSDateFormatterShortStyle;       //
    formatter.doesRelativeDateFormatting = YES;            //
    NSLocale *ukraineLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"uk"];
    [formatter setLocale:ukraineLocale];                   //
    
    NSString *personalInfo = [NSString stringWithFormat:@"%@ %@",commentaires.userName, commentaires.userSurname];
    NSString *dateInfo = [NSString stringWithFormat:@" %@",[formatter stringFromDate:commentaires.date]];
    cell.personInfo.text = personalInfo;
    cell.dateInfo.text = dateInfo;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    EcomapLoggedUser *userIdent = [EcomapLoggedUser currentLoggedUser];
    if([userIdent.role isEqualToString:@"administrator"])
        return YES;
    else
        return NO;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
          if(editingStyle == UITableViewCellEditingStyleDelete)
    {
         EcomapComments *commentaries = [self.comments objectAtIndex:indexPath.row];
        NSUInteger number = commentaries.commentID;
        [ EcomapAdminFetcher deleteComment:number onCompletion:^(NSError *error) {
            if(!error)
            [[NSNotificationCenter defaultCenter] postNotificationName:PROBLEMS_DETAILS_CHANGED object:self];
        }];
        
    }
    
    
}



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

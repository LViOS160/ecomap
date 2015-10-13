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


@interface AddCommViewController () <UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
@property (nonatomic,strong) NSMutableArray* comments;
@property (nonatomic,strong) EcomapProblemDetails * ecoComment;
@property (nonatomic,strong) NSString *problemma;
@property (weak, nonatomic) IBOutlet UIButton *addCommentButton;

@property AddCommViewController *ob;

@end

@implementation AddCommViewController



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}







- (void)viewDidLoad {
    
    self.ob = self;
    
    //[EcomapUserFetcher loginWithEmail:@"admin@.com" andPassword:@"admin" OnCompletion:^(EcomapLoggedUser *loggedUser, NSError *error) {
        
    //}];
    [super viewDidLoad];
    self.addCommentButton.enabled = NO;
    
    
    [self updateUI];
    
    //Buttons images localozation
    UIImage *addButtonImage = [UIImage imageNamed:NSLocalizedString(@"AddCommentButtonUKR", @"Add comment button image")];
    [self.addCommentButton setImage:addButtonImage
                           forState:UIControlStateNormal];
   
    
    EcomapCommentaries* ob = [EcomapCommentaries sharedInstance];
    
   // [self.comments initWithArray: [ob comInfo]];
    
    // Do any additional setup after loading the view.
}

-(void)reload
{
    [self updateUI];
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
    //[self.myTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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




- (IBAction)pressAddComment:(id)sender  {
    
        NSString * fromTextField = self.textField.text;
        EcomapLoggedUser *userIdent = [EcomapLoggedUser currentLoggedUser];
        NSString * userID = [NSString stringWithFormat:@"%lu",(unsigned long)userIdent.userID];
    
    if(userIdent) {
        
#warning Roma has to remove this dispatching
        
     //   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            EcomapCommentaries *ob = [EcomapCommentaries sharedInstance];
            [[NetworkActivityIndicator sharedManager] startActivity];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            AFJSONRequestSerializer *jsonRequestSerializer = [AFJSONRequestSerializer serializer];
            [manager setRequestSerializer:jsonRequestSerializer];
            NSString *baseUrl = @"http://176.36.11.25:8000/api/problems/";
            NSString *middle = [baseUrl stringByAppendingFormat:@"%lu",(unsigned long)[ob problemsID]];
            NSString *final = [middle stringByAppendingString:@"/comments"];
           
            NSDictionary *cont = @{ @"content":fromTextField};
            
            [manager POST:final parameters:cont success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"ura");
                [EcomapFetcher updateComments:[ob problemsID] controller:self];
                
               
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                
                NSLog(@"%@",error);
            }];
            
     //   });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NetworkActivityIndicator sharedManager]endActivity];
        });
        
    
       [InfoActions showPopupWithMesssage:NSLocalizedString(@"Коментар додано", @"Comment added")];

        
        
        
        
        /*
            [EcomapFetcher createComment:userID
                                 andName:userIdent.name
                              andSurname:userIdent.surname
                              andContent:fromTextField
                            andProblemId:self.problemma OnCompletion:^(EcomapCommentaries *obj, NSError *error)
             {
                 
                 if(error)
                 {
                     DDLogError(@"Error adding comment:%@", [error localizedDescription]);
                 }
                 else
                 {
                     [[NSNotificationCenter defaultCenter] postNotificationName:PROBLEMS_DETAILS_CHANGED object:self];
                 }
                 [InfoActions showPopupWithMesssage:NSLocalizedString(@"Коментар додано", @"Comment added")];
                 
             }];*/
        
        
            
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
    EcomapCommentaries* ob = [EcomapCommentaries sharedInstance];
    if(ob.comInfo.count == 0)
    {
         return 1;
    }
    else
    {
        return ob.comInfo.count;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EcomapCommentaries* ob = [EcomapCommentaries sharedInstance];
    if(ob.comInfo.count == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"Коментарі відсутні";
        return cell;
    }
    else
    {//EcomapCommentaries *commentair = [self.comments objectAtIndex:indexPath.row];
         EcomapCommentaries* ob = [EcomapCommentaries sharedInstance];
        
        
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
        NSInteger row = indexPath.row;
        
        cell.commentContent.text= [[ob.comInfo  objectAtIndex:row] valueForKey:@"content"];
        NSDateFormatter *formatter = [NSDateFormatter new];    // Date Fornatter things
        formatter.dateStyle = NSDateFormatterMediumStyle;      //
        formatter.timeStyle = NSDateFormatterShortStyle;       //
        formatter.doesRelativeDateFormatting = YES;            //
        NSLocale *ukraineLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"uk"];
        [formatter setLocale:ukraineLocale];                   //
        
       NSString *personalInfo = [NSString stringWithFormat:@"%@", [[ob.comInfo  objectAtIndex:row] valueForKey:@"created_by"]];
                                 
     NSString *dateInfo = [NSString stringWithFormat:@"%@",[[ob.comInfo  objectAtIndex:row] valueForKey:@"created_date"]];
       cell.personInfo.text = personalInfo;
       cell.dateInfo.text = dateInfo;
        //[cell setNeedsUpdateConstraints];
        //[cell updateConstraintsIfNeeded];
        return cell;
    }
    
   
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    EcomapLoggedUser *userIdent = [EcomapLoggedUser currentLoggedUser];
 /*   if([userIdent.role isEqualToString:@"user"] && self.comments.count >0)
        return YES;
    else*/
    EcomapCommentaries* ob = [EcomapCommentaries sharedInstance];
    if([userIdent.name isEqualToString:[[ob.comInfo objectAtIndex:indexPath.row] valueForKey:@"created_by"]]){
        return YES;
    }
    
        return NO;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    EcomapCommentaries *ob = [EcomapCommentaries sharedInstance];
          if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        // EcomapActivity *commentaries = [self.comments objectAtIndex:indexPath.row];
       // NSUInteger number = commentaries.commentID;
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFJSONRequestSerializer *jsonRequestSerializer = [AFJSONRequestSerializer serializer];
        [manager setRequestSerializer:jsonRequestSerializer];
        NSString *baseUrl = @"http://176.36.11.25:8000/api/comments/";
       NSNumber *num = [[ob.comInfo objectAtIndex:indexPath.row] valueForKey:@"id"];
        NSString *middle = [baseUrl stringByAppendingFormat:@"%@",num];
        
        
        
        
        [manager DELETE:middle parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"ura");
           
            [EcomapFetcher updateComments:ob.problemsID controller:self];
            [UIView transitionWithView:tableView
                              duration:2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^(void)
             {
                 [tableView reloadData];
             }
                            completion:nil];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            
            NSLog(@"%@",error);
        }];

       // [tableView reloadData];
        
        
        /*[ EcomapAdminFetcher deleteComment:number onCompletion:^(NSError *error) {
            if(!error)
            [[NSNotificationCenter defaultCenter] postNotificationName:PROBLEMS_DETAILS_CHANGED object:self];
        }];*/
        
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

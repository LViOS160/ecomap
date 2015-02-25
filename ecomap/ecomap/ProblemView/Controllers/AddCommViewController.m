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
#import "EcomapCommentsChild.h"
#import "EcomapLoggedUser.h"
#import "EcomapProblemDetails.h"
#import "Defines.h"
#import "GlobalLoggerLevel.h"


@interface AddCommViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray* comments;
@property (nonatomic,strong) EcomapProblemDetails * ecoComment;
@property (nonatomic,strong) NSString *problemma;



//@property (nonatomic,strong) EcomapCommentsChild *uploadComment;

@end

@implementation AddCommViewController



-(void)setEcoComment:(EcomapProblemDetails *)ecoComment
{
    
}
- (void)viewDidLoad {
    
    [EcomapFetcher loginWithEmail:@"clic@ukr.net"
                      andPassword:@"eco"
                     OnCompletion:^(EcomapLoggedUser *user, NSError *error) {
                         if (!error) {
                             DDLogVerbose(@"User role: %@", user.role);
                             
                             //Read current logged user
                             
                             
                             
                         } else {
                             DDLogVerbose(@"Error to login: %@", error);
                         }
                     }]; 

    [super viewDidLoad];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
   
    
    // Do any additional setup after loading the view.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)pressAddComment:(id)sender  {
  
    NSString * fromTextField = self.textField.text;
  EcomapLoggedUser *userIdent = [EcomapLoggedUser currentLoggedUser];
 NSString * userID = [NSString stringWithFormat:@"%lu",(unsigned long)userIdent.userID];
    
    NSString *probId = self.problemma;
    if(userIdent)
    {
    [EcomapFetcher createComment:userID andName:userIdent.name andSurname:userIdent.surname andContent:fromTextField andProblemId:probId OnCompletion:^(EcomapCommentsChild *obj, NSError *error) {
   
        if(error)
            DDLogVerbose(@"Trouble");
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:PROBLEMS_DETAILS_CHANGED object:self];

    }];
    
    NSDictionary *dict = @{@"Content":fromTextField, @"ActivityTypes_Id":@5,@"userName":userIdent.name,@"userSurname":userIdent.surname};
   EcomapCommentsChild *comment = [[EcomapCommentsChild alloc] initWithInfo:dict];
    comment.problemContent = fromTextField;
    comment.userName = userIdent.name;
    comment.userSurname = userIdent.surname;
    NSUInteger counter = self.comments.count;
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    comment.date = today;
    [self.comments insertObject:comment atIndex:counter];
     NSLog(@"%@",self.comments.lastObject);
   [self.myTableView reloadData];
    
   
      }
    else
        NSLog(@"USER IS NOT REGISTERED");
       
    
    if ([self.textField isFirstResponder]) {
        self.textField.text = @"";
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
   // DDLogVerbose(@"%d",self.comments.count);
    return self.comments.count;
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     
  CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
     if(!cell)
         cell = [[CommentCell alloc] init];
     EcomapComments *commentZ = [self.comments objectAtIndex:indexPath.row];
   //  NSInteger row=[indexPath row]
    cell.commentContent.text= commentZ.problemContent;
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
     NSString *personalInfo = [NSString stringWithFormat:@"%@ %@ %@",commentZ.userName, commentZ.userSurname,[formatter stringFromDate:commentZ.date]];
      cell.personInfo.text = personalInfo;
     
 
 return cell;
 }


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
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

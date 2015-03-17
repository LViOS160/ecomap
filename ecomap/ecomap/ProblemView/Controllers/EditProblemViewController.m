//
//  EditProblemViewController.m
//  ecomap
//
//  Created by Inna Labuskaya on 3/17/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EditProblemViewController.h"

@interface EditProblemViewController ()

@end

@implementation EditProblemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *rbb = [[UIBarButtonItem alloc] initWithTitle:@"Зберегти" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTouch:)];
    UIBarButtonItem *lbb = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonTouch:)];
    [self.navigationItem setRightBarButtonItem:rbb animated:YES];
    [self.navigationItem setLeftBarButtonItem:lbb animated:YES];
  
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveButtonTouch:(id)sender
{
}

- (void)closeButtonTouch:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

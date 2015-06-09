//
//  AboutViewController.m
//  ecomap
//
//  Created by Vasyl Kotsiuba on 6/9/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AboutViewController.h"
#import "EcomapRevealViewController.h"

@interface AboutViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)customSetup
{
    EcomapRevealViewController *revealViewController = (EcomapRevealViewController *)self.revealViewController;
    if(revealViewController) {
        [self.revealButtonItem setTarget:self.revealViewController];
        [self.revealButtonItem setAction:@selector(revealToggle:)];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
}
@end

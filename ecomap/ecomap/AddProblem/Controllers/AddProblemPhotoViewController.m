//
//  AddProblemPhotoViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 04.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AddProblemPhotoViewController.h"
#import "PhotoViewController.h"
#import "Defines.h"

@interface AddProblemPhotoViewController() <PhotoViewControllerDelegate>

@end

@implementation AddProblemPhotoViewController

- (IBAction)addPhotoTap:(id)sender {
    if (self.rootController) {
        PhotoViewController *viewController = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:nil];
        viewController.delegate = self;
        [self.rootController presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)photoViewControllerDidCancel:(PhotoViewController *)viewController
{
    [self.rootController dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoViewControllerDidFinish:(PhotoViewController *)viewController withImageDescriptions:(NSArray *)imageDescriptions
{
    //imageDescriptions - array of EcomapLocalPhoto
    [self.rootController dismissViewControllerAnimated:YES completion:nil];
}
@end

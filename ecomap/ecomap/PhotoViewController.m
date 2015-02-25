//
//  PhotoViewController.m
//  ecomap
//
//  Created by Inna Labuskaya on 2/24/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "PhotoViewController.h"
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface PhotoViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *imageDescriptions;
@property (nonatomic, strong) UITextView *messageBox;
@property(nonatomic, strong) UITextField *activeField;

@end

@implementation PhotoViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.imageDescriptions = [NSMutableArray array];
    //Set gesture recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchUpinside:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //setup keyboard notifications
    [self registerForKeyboardNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.activeField resignFirstResponder];
    [self deregisterForKeyboardNotifications];
}

#pragma mark - keyborad managment
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)deregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent
#define KEYBOARD_TO_TEXTFIELD_SPACE 8.0
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //Increase scroll view contetn size by keyboard size
    CGRect contetntViewRect = self.activeField.superview.superview.frame;
    contetntViewRect.size.height += keyboardSize.height;
}
  

#pragma mark - text field delegate
// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
}


- (IBAction)galleryTap:(id)sender
{
    UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
    uiipc.delegate = self;
    uiipc.mediaTypes = @[(NSString *)kUTTypeImage];
    uiipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    uiipc.allowsEditing = NO;
    [self presentViewController:uiipc animated:YES completion:NULL];
}

- (IBAction)cameraTap:(id)sender
{
#if !(TARGET_IPHONE_SIMULATOR)
    UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
    uiipc.delegate = self;
    uiipc.mediaTypes = @[(NSString *)kUTTypeImage];
    uiipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    uiipc.allowsEditing = NO;
    [self presentViewController:uiipc animated:YES completion:NULL];
#endif
}

- (IBAction)chooseTap:(id)sender
{
    [self.delegate photoViewControllerDidFinish:self withImageDescriptions:self.imageDescriptions];
}

- (IBAction)cancelTap:(id)sender
{
    [self.delegate photoViewControllerDidCancel:self];
}

#pragma mark - Image Picker Controller Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if(!image) image = info[UIImagePickerControllerOriginalImage];
    LocalImageDescription *descr = [[LocalImageDescription alloc] initWithImage:image];
    [self.imageDescriptions addObject:descr];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table View Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.imageDescriptions removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

#pragma mark - Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imageDescriptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    LocalImageDescription *descr = self.imageDescriptions[indexPath.row];
    cell.textLabel.text = descr.imageDescription;
    cell.imageView.image = descr.image;
    
    UITextField *myTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 10, 125, 25)];
    myTextField.adjustsFontSizeToFitWidth = NO;
    myTextField.backgroundColor = [UIColor clearColor];
    myTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    myTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    myTextField.textAlignment = UITextAlignmentRight;
    myTextField.keyboardType = UIKeyboardAppearanceDefault;
    myTextField.returnKeyType = UIReturnKeyDone;
    myTextField.clearButtonMode = UITextFieldViewModeNever;
    myTextField.delegate = self;
    cell.accessoryView = myTextField;
    myTextField.placeholder = @"Add description";
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    return true;
}

#pragma mark - UITextViewDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (void)touchUpinside:(UITapGestureRecognizer *)sender {
    [self.activeField resignFirstResponder];
    NSLog(@"Tap");
}


@end

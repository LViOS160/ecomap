//
//  AddProblemModalController.m
//  ecomap
//
//  Created by Admin on 29.10.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AddProblemModalController.h"
#import "AddProblemViewController.h"
@interface AddProblemModalController ()

@end

@implementation AddProblemModalController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.thisMap.userInteractionEnabled = YES;
    [self.currentView setContentSize:CGSizeMake(300, 2000)];
    [self.view addSubview:self.currentView];
    [self setMap];
    [self.thisMap setDelegate:self];
    [self setMarker];
    self.problemList = @[@"Сміттєзвалища", @"Проблема лісів", @"Браконьєрство"];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.problemList count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.problemList[row];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self currentView] endEditing:YES];
    [[self view] endEditing:YES];

}

- (void)setMarker
{
    if (!self.marker) {
        self.marker = [[GMSMarker alloc] init];
        self.marker.map = self.thisMap;
    }
    [self.marker setPosition:self.cord];
}


- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
   
            if (!self.marker) {
                self.marker = [[GMSMarker alloc] init];
                self.marker.map = self.thisMap;
            }
            [self.marker setPosition:coordinate];
}


- (void)setMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:50.46012686633918
                                                            longitude:30.52173614501953
                                                                 zoom:6];
    self.thisMap = [GMSMapView mapWithFrame:self.mapView.frame camera:camera];
    self.thisMap.myLocationEnabled = YES;
    self.thisMap.settings.myLocationButton = YES;
    self.thisMap.settings.compassButton = YES;
    [self.mapView addSubview:self.thisMap];
}



- (IBAction)confirm:(id)sender
{
    self.updatedelegate = self.Controller;
    [self.updatedelegate update:self.nameOfProblems.text
              :self.descriptionOfProblem.text
              :self.solvetion.text
              :self.marker];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{  
    self.updatedelegate = self.Controller;
    [self.updatedelegate cancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end

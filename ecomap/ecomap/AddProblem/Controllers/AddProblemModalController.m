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
    [self.currentView setContentSize:CGSizeMake(300, 1000)];
    [self.view addSubview:self.currentView];
    [self setMap];
    [self.thisMap setDelegate:self];
    [self setMarker];
    
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
    AddProblemViewController *ob = [[AddProblemViewController alloc] init];
    self.updatedelegate = ob;
    [ob update:self.nameOfProblems.text
              :self.descriptionOfProblem.text
              :self.solvetion.text
              :self.marker];
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

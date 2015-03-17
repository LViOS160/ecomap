//
//  ViewController.h
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GClusterManager.h"
#import "SRWebSocket.h"
#import "ProblemViewController.h"

@interface MapViewController : UIViewController <GMSMapViewDelegate, SRWebSocketDelegate>

@property (nonatomic, strong) GMSMapView *mapView;
-(void)loadProblems;

@end


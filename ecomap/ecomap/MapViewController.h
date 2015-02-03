//
//  ViewController.h
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TileOverlay.h"

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic, strong) TileOverlay* overlay;

@end


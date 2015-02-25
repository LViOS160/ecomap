//
//  PieChartViewController.h
//  EcomapStatistics
//
//  Created by ohuratc on 03.02.15.
//  Copyright (c) 2015 Huralnyk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"

@interface PieChartViewController : UIViewController <XYPieChartDelegate, XYPieChartDataSource>

@property (strong, nonatomic) NSArray *statsForPieChart; // of stats NSDictionary
@property (strong, nonatomic) NSArray *generalStats; // of stats NSDictionary
@property (strong, nonatomic) IBOutlet XYPieChart *pieChartView;

@end

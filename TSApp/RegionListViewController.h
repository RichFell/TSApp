//
//  RegionListViewController.h
//  TSApp
//
//  Created by Rich Fellure on 10/6/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Region.h"
#import "CDRegion.h"

@class RegionListViewController;

@protocol RegionListVCDelegate <NSObject>

-(void)regionListVC:(RegionListViewController *)viewController selectedRegion:(CDRegion *)region;

@end

@interface RegionListViewController : UIViewController

@property id<RegionListVCDelegate>delegate;

@end

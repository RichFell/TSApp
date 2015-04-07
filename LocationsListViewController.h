//
//  LocationsListViewController.h
//  TSApp
//
//  Created by Rich Fellure on 8/10/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Region.h"
#import "Location.h"
@class LocationsListViewController, CDLocation;
@protocol LocationsListVCDelegate <NSObject>

-(void)locationListVC:(LocationsListViewController *)viewController didChangeLocation:(CDLocation *)location;
-(void)didGetNewDirections:(NSArray *)directions;

@end

@interface LocationsListViewController : UIViewController
@property id<LocationsListVCDelegate>delegate;
@property CDRegion *currentRegion;
@end

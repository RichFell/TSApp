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
@class LocationsListViewController;
@protocol LocationsListVCDelegate <NSObject>

-(void)didDeleteLocation:(CDLocation *)deletedLocation;
-(void)didMoveLocation:(CDLocation *)movedLocation;
-(void)didAddNewLocation:(CDLocation *)newLocation;
-(void)didGetNewDirections:(NSArray *)directions;

@end

@interface LocationsListViewController : UIViewController
@property id<LocationsListVCDelegate>delegate;
-(void)giveCurrentRegion:(CDRegion *)region;

@end

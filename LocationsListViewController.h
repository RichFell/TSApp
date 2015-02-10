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

@protocol LocationsListVCDelegate <NSObject>

-(void)didDeleteLocation:(Location *)deletedLocation;
-(void)didMoveLocation:(Location *)movedLocation;
-(void)didAddNewLocation:(Location *)newLocation;
-(void)didGetNewDirections:(NSArray *)directions;

@end

@interface LocationsListViewController : UIViewController
@property id<LocationsListVCDelegate>delegate;

@end

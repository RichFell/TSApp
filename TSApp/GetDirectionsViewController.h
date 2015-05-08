//
//  LocationSelectionViewController.h
//  TSApp
//
//  Created by Rich Fellure on 4/7/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GetDirectionsViewController, CDLocation;

@protocol LocationSelectionVCDelegate <NSObject>

-(void)locationSelectionVC:(GetDirectionsViewController *)viewController didTapDone:(BOOL)done;
-(void)locationSelectionVC:(GetDirectionsViewController *)viewController isSettingStartingLocation:(BOOL)isStartingLocation;

@end

@interface GetDirectionsViewController : UIViewController

@property id<LocationSelectionVCDelegate>delegate;
@property BOOL selectFirstPosition;
@property CDLocation *currentLocation;

@end

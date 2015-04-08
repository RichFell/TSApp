//
//  LocationSelectionViewController.h
//  TSApp
//
//  Created by Rich Fellure on 4/7/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LocationSelectionViewController, CDLocation;

@protocol LocationSelectionVCDelegate <NSObject>

-(void)locationSelectionVC:(LocationSelectionViewController *)viewController didTapDone:(BOOL)done;

@end

@interface LocationSelectionViewController : UIViewController

@property id<LocationSelectionVCDelegate>delegate;
@property BOOL selectFirstPosition;

-(void)giveALocation:(CDLocation *)location;

@end

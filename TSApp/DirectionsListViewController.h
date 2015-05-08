//
//  DirectionsListViewController.h
//  TSApp
//
//  Created by Rich Fellure on 4/5/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CDLocation, DirectionsListViewController, DirectionSet;

@protocol DirectionsListVCDelegate <NSObject>

-(void)directionListVC:(DirectionsListViewController *)viewController finishedSelection:(DirectionSet *)set;

@end

@interface DirectionsListViewController : UIViewController

@property CDLocation *selectedLocation;
@property id<DirectionsListVCDelegate>delegate;

+(instancetype)storyboardInstance;

@end

//
//  MapViewController.h
//  TSApp
//
//  Created by Rich Fellure on 10/6/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MapViewControllerDelegate <NSObject>

-(void)openList;
-(void)closeList;

@end

@interface MapViewController : UIViewController

@property id<MapViewControllerDelegate> delegate;
@end

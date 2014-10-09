//
//  RegionListViewController.h
//  TSApp
//
//  Created by Rich Fellure on 10/6/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Region.h"

@protocol RegionListVCDelegate <NSObject>

-(void)didSelectRegion: (Region *)selectedRegion;

@end

@interface RegionListViewController : UIViewController

@property id<RegionListVCDelegate> delegate;
@property NSMutableArray *regionsArray;
+(RegionListViewController *)newStoryboardInstance;

@end

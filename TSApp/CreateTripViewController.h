//
//  CreateTripViewController.h
//  TSApp
//
//  Created by Rich Fellure on 11/30/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Region.h"
#import "CDRegion.h"
@class CreateTripViewController;

@protocol CreateTripVCDelegate <NSObject>

-(void)createTripViewController:(CreateTripViewController *)viewController didSaveNewRegion:(CDRegion *)region;

@end

@interface CreateTripViewController : UIViewController

@property id<CreateTripVCDelegate>delegate;

@end

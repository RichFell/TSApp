//
//  Direction.h
//  TSApp
//
//  Created by Rich Fellure on 9/1/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Direction : NSObject

@property NSString *direction;
@property NSString *distance;
@property float startingLatitude;
@property float startingLongitude;
@property float endingLatitude;
@property float endingLongitude;

@end

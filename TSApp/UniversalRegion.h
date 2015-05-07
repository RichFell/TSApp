//
//  UniversalRegion.h
//  TSApp
//
//  Created by Rich Fellure on 5/7/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CDRegion;

@interface UniversalRegion : NSObject

@property CDRegion *currentRegion;

+(id)sharedInstance;

@end

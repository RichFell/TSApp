//
//  UserDefaults.h
//  TSApp
//
//  Created by Rich Fellure on 11/28/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDRegion.h"

@interface UserDefaults : NSObject

+(void)setDefaultRegion:(CDRegion *)region;
+(void)getDefaultRegionWithBlock: (void(^)(CDRegion *region, NSError *error))completionHandler;
@end

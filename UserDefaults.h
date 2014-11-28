//
//  UserDefaults.h
//  TSApp
//
//  Created by Rich Fellure on 11/28/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Region.h"

@interface UserDefaults : NSObject

+(void)setDefaultRegion:(Region *) theRegion;
+(void)getDefaultRegionWithBlock: (void(^)(Region *region, NSError *error))completionHandler;
@end

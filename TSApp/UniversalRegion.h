//
//  UniversalRegion.h
//  TSApp
//
//  Created by Rich Fellure on 12/7/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "Region.h"

@interface UniversalRegion : Region

@property Region *region;
@property NSArray *locations;
+(id)sharedRegion;
@end

//
//  UniversalRegion.m
//  TSApp
//
//  Created by Rich Fellure on 12/7/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "UniversalRegion.h"

@implementation UniversalRegion

@synthesize region;
@synthesize locations;
@synthesize currentLocation;

+(id)sharedRegion
{
    static UniversalRegion *sharedMyRegion = nil;
    @synchronized(self)
    {
        if (sharedMyRegion == nil)
        {
            sharedMyRegion = [[self alloc]init];
        }
    }
    return sharedMyRegion;
}

@end

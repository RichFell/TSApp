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

+(id)sharedRegion
{
    static Region *sharedMyRegion = nil;
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

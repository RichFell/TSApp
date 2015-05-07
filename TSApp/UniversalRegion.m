//
//  UniversalRegion.m
//  TSApp
//
//  Created by Rich Fellure on 5/7/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "UniversalRegion.h"

@implementation UniversalRegion


+(id)sharedInstance {
    static UniversalRegion *sharedRegion = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRegion = [self new];
    });
    return sharedRegion;
}


@end

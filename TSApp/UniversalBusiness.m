//
//  UniversalBusiness.m
//  TSApp
//
//  Created by Rich Fellure on 5/8/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "UniversalBusiness.h"

@implementation UniversalBusiness

+(instancetype)sharedInstance {
    static UniversalBusiness *sharedBusiness = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBusiness = [self new];
        sharedBusiness.currentBusinesses = [NSMutableArray new];
    });
    return sharedBusiness;
}

@end

//
//  UserDefaults.m
//  TSApp
//
//  Created by Rich Fellure on 11/28/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "UserDefaults.h"
#import "AppDelegate.h"

@implementation UserDefaults

static NSString *const kDefaultRegion = @"defaultRegion";

///Sets the default Region.objectId in NSUserDefaults
+(void)setDefaultRegion:(CDRegion *)theRegion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:theRegion.objectId forKey:kDefaultRegion];
    [NSUserDefaults.standardUserDefaults synchronize];
}


@end

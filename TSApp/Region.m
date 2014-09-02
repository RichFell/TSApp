//
//  Region.m
//  TSApp
//
//  Created by Rich Fellure on 8/12/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "Region.h"
#import <Parse/PFObject+Subclass.h>

@implementation Region

+(NSString *)parseClassName
{
    return @"Region";
}

@dynamic name;
@dynamic user;
@dynamic completed;
//@dynamic nearLeftLat;
//@dynamic nearLeftLong;
//@dynamic nearRightLat;
//@dynamic nearRightLong;
//@dynamic farLeftLat;
//@dynamic farLeftLong;
//@dynamic farRightLat;
//@dynamic farRightLong;

@end

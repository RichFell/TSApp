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

+(void)queryForRegionsWithBlock:(void (^)(NSArray *regions, NSError *error))completionHandler
{
    PFQuery *query = [Region query];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        completionHandler(objects, error);
    }];
}

+(void)createRegion:(NSString *)regionName compeletion:(void (^)(Region *, NSError *))completionHandler
{
    Region *theRegion = [[Region alloc]init];
    theRegion.name = regionName;
    theRegion.user = [PFUser currentUser];
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

//
//  Region.m
//  TSApp
//
//  Created by Rich Fellure on 8/12/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "Region.h"
#import <Parse/PFObject+Subclass.h>
#import "Location.h"

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

-(void)deleteRegionWithBlock:(void (^)(BOOL, NSError *))completionHandler
{
    [Location queryForLocations:self completed:^(NSArray *locations, NSError *error) {
        if (error == nil)
        {
            for (Location *location in locations)
            {
                [location deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                }];
            }
        }
        completionHandler(true, error);
    }];
}

-(void)switchRegionCompletedStatusWithBlock:(void (^)(BOOL, NSError *))completionHandler
{
    if (self.completed == false)
    {
        self.completed = true;
    }
    else
    {
        self.completed = false;
    }

    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completionHandler(succeeded, error);
    }];
}

@end









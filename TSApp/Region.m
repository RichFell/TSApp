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
#import "MapModel.h"

@implementation Region

+(NSString *)parseClassName
{
    return @"Region";
}

@dynamic name;
@dynamic user;
@dynamic completed;
@dynamic destinationPoint;


+(void)queryForRegionsWithBlock:(void (^)(NSArray *regions, NSError *error))completionHandler
{
    PFQuery *query = [Region query];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        completionHandler(objects, error);
    }];
}

+(void)createRegion:(NSString *)regionName withGeoPoint:(PFGeoPoint *)geoPoint compeletion:(void (^)(Region *, NSError *))completionHandler
{
    Region *theRegion = [[Region alloc]init];
    theRegion.name = regionName;
    theRegion.destinationPoint = geoPoint;
    theRegion.user = [PFUser currentUser];
    theRegion.completed = false;
    [theRegion saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completionHandler(theRegion, error);
    }];
}

+(void)queryForRegionWithObjectId:(NSString *)objectId completion:(void (^)(Region *, NSError *))completionHandler
{
    PFQuery *query = [Region query];
    [query whereKey:@"objectId" equalTo:objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        completionHandler((Region *)object, error);
    }];
}
-(void)deleteRegionWithBlock:(void (^)(BOOL, NSError *))completionHandler
{
    [self deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completionHandler(succeeded, error);
    }];
}

-(void)switchRegionCompletedStatusWithBlock:(void (^)(BOOL, NSError *))completionHandler
{
    self.completed = false ? false : true;

    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completionHandler(succeeded, error);
    }];
}

@end









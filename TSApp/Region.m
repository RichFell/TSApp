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
@dynamic objectID;


+(void)queryForRegionsWithBlock:(void (^)(NSArray *regions, NSError *error))completionHandler
{
    PFQuery *query = [Region query];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        completionHandler(objects, error);
    }];
}

-(instancetype)initWithName:(NSString *)name destinationPoint:(PFGeoPoint *)point andObjectID:(NSString *)objID {
    self = [super init];
    self.name = name;
    self.destinationPoint = point;
    self.user = [PFUser currentUser];
    self.completed = false;
    self.objectID = objID;
    return self;
}

+(void)createRegion:(NSString *)regionName withGeoPoint:(PFGeoPoint *)geoPoint andObjectID:(NSString *)objID compeletion:(void (^)(Region *, NSError *))completionHandler
{
    Region *theRegion = [[Region alloc]initWithName:regionName destinationPoint:geoPoint andObjectID:objID];
    [theRegion saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completionHandler(theRegion, error);
    }];
}

+(void)queryForRegionWithObjectId:(NSString *)objectId completion:(void (^)(Region *, NSError *))completionHandler
{
    PFQuery *query = [Region query];
    [query whereKey:@"objectID" equalTo:objectId];
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
    self.completed = !self.completed;

    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completionHandler(succeeded, error);
    }];
}

@end









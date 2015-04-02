//
//  Location.m
//  TSApp
//
//  Created by Rich Fellure on 8/12/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "Location.h"

@implementation Location

+(NSString *)parseClassName
{
    return @"Location";
}

@dynamic name;
@dynamic index;
@dynamic coordinate;
@dynamic hasVisited;
@dynamic region;
@dynamic address;

-(instancetype)initWithName:(NSString *)name andCoordinate: (CLLocationCoordinate2D)coordinate currentRegion:(Region *)region andAddress:(NSString *)address andIndex:(NSNumber *)index andID:(NSString *)objectId {
    self = [super init];
    self.name = name;
    PFGeoPoint *geoPoint = [PFGeoPoint new];
    geoPoint.latitude = coordinate.latitude;
    geoPoint.longitude = coordinate.longitude;
    self.coordinate = geoPoint;
    self.index = index;
    self.address = address;
    self.region = region;
    self.hasVisited = @0;
    return self;
}

+(void)createLocation:(CLLocationCoordinate2D)coordinate andName:(NSString *)name atIndex:(NSNumber *)index currentRegion:(CDRegion *)region andAddress:(NSString *)theAddress withID:(NSString *)iD completion:(void (^)(Location *, NSError *))completionHandler
{
    [Region queryForRegionWithObjectId:region.objectId completion:^(Region *defaultRegion, NSError *error) {
        Location *newLocation = [[Location alloc] initWithName:name andCoordinate:coordinate currentRegion:defaultRegion andAddress:theAddress andIndex:index andID:iD];
        [newLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded == false) {
                [newLocation saveEventually];
            }
            completionHandler(newLocation, error);
        }];
    }];
}

+(void)queryForLocations:(Region *)region completed:(void (^)(NSArray *, NSError *))completionHandler
{
    PFQuery *query = [Location query];
    [query whereKey:@"region" equalTo:region];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        completionHandler(objects, error);
    }];
}

+(void)deleteLocationWithID:(NSString *)obID completed:(void (^)(BOOL, NSError *))completionHandler
{
    [Location queryForLocationWithID:obID completed:^(Location *location, NSError *error) {
        if (location) {
            [location deleteEventually];
        }
    }];
}

+(void)changeVisitedStatusForLocationWithID:(NSString *)obID WithBlock:(void (^)(BOOL, NSError *))completionHandler {
    [Location queryForLocationWithID:obID completed:^(Location *location, NSError *error) {
        if (location) {
            location.hasVisited = [location.hasVisited  isEqual: @0] ? @1 : @0;
            [location saveEventually];
        }
        completionHandler(error ? false: true, error);
    }];
}

+(void)queryForLocationWithID:(NSString *)obID completed:(void(^)(Location *location, NSError *error))completionHandler {
    PFQuery *query = [Location query];
    [query whereKey:@"objectID" equalTo:obID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        completionHandler((Location *)object, error);
    }];
}

-(void)changeIndexOfLocations:(NSArray *)locations completion:(void (^)(BOOL, NSError *))completionHandler
{
    for (Location *aLocation in locations)
    {
        NSUInteger index = [locations indexOfObject:aLocation] + 1;
        aLocation.index = [NSNumber numberWithUnsignedInteger:index];
        [aLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            completionHandler(succeeded, error);
        }];
    }
}


@end

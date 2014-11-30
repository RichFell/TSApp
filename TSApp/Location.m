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
@dynamic objectID;
@dynamic region;

+(void )createLocation: (CLLocationCoordinate2D) coordinate array: (NSMutableArray *)array currentRegion: (Region *)region completion: (void (^)(Location *theLocation, NSError *error))completionHandler;
{
    Location *newLocation = [[Location alloc]init];
//    newLocation.longitude = [NSNumber numberWithDouble:coordinate.longitude];
//    newLocation.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    PFGeoPoint *geoPoint = [[PFGeoPoint alloc]init];
    geoPoint.latitude = coordinate.latitude;
    geoPoint.longitude = coordinate.longitude;
    newLocation.coordinate = geoPoint;
    newLocation.name = @"";
    NSUInteger index = array.count + 1;
    newLocation.index = [NSNumber numberWithUnsignedInteger:index];
    newLocation.hasVisited = @0;
    newLocation.region = region;
    [newLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        completionHandler(newLocation, error);
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

-(void)deleteLocationWithBlock:(NSArray *)locations completed:(void (^)(BOOL, NSError *))completionHandler
{
    [self deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded == true)
        {
            [self changeIndexOfLocations:locations completion:^(BOOL result, NSError *error) {
                completionHandler(result, error);
            }];
        }
        else
        {
            completionHandler(succeeded, error);
        }
    }];
}

-(void)changeVisitedStatusWithBlock:(void (^)(BOOL, NSError *))completionHandler
{
    if ([self.hasVisited isEqual: @0])
    {
        self.hasVisited = @1;
    }
    else
    {
        self.hasVisited = @0;
    }

    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        completionHandler(succeeded, error);
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
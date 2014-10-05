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
@dynamic latitude;
@dynamic longitude;
@dynamic hasVisited;
@dynamic objectID;
@dynamic region;

+(void )createLocation: (CLLocationCoordinate2D) coordinate array: (NSMutableArray *)array currentRegion: (Region *)region completion: (void (^)(Location *theLocation, NSError *error))completionHandler;
{
    Location *newLocation = [[Location alloc]init];
    newLocation.longitude = [NSNumber numberWithDouble:coordinate.longitude];
    newLocation.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    newLocation.name = @"";
    NSUInteger index = array.count + 1;
    newLocation.index = [NSNumber numberWithUnsignedInteger:index];
    newLocation.hasVisited = @0;
    newLocation.region = region;
    [newLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        completionHandler(newLocation, error);
    }];
}

-(void)deleteLocationWithBlock:(void (^)(BOOL, NSError *))completionHandler
{
    [self deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completionHandler(succeeded, error);
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


@end

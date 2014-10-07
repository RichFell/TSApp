//
//  ParseModel.m
//  TSApp
//
//  Created by Rich Fellure on 8/7/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "ParseModel.h"



@implementation ParseModel

#pragma mark - Signup and login users

#pragma mark - Create, query Region

//-(void)deleteRegion:(Region *)region
//{
//    [region deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (error)
//        {
//            NSLog(@"%@", error);
//        }
//    }];
//}

//-(void)queryForRegions
//{
//    PFQuery *query = [Region query];
//    [query whereKey:rwfRegionToUser equalTo:[User currentUser]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//
//        if (error == nil)
//        {
//
//            [self.delegate didFinishRegionsQuery:objects];
//        }
//        else
//        {
//            NSLog(@"%@", error);
//        }
//    }];
//}

#pragma mark - Create Location
//-(void)createLocation: (CLLocationCoordinate2D) coordinate array:(NSMutableArray *)array currentRegion: (Region *)region
//{
//    Location *location = [Location object];
//
//    NSNumber *latitude = [NSNumber numberWithDouble:coordinate.latitude];
//    NSNumber *longitude = [NSNumber numberWithDouble:coordinate.longitude];
//    NSUInteger index = array.count + 1;
//    NSNumber *number = [NSNumber numberWithUnsignedInteger:index];
//
//    location.name = @"";
//    location.hasVisited = @0;
//    location.longitude = longitude;
//    location.latitude = latitude;
//    location.index = number;
//    location.region = region;
//    NSLog(@"moving to saveInBackground for the Location: %@", location);
//
//    [location saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (error == nil)
//        {
////            NSLog(@"%@", location);
////            [self.delegate didCreateLocation:location];
//        }
//        else
//        {
//            NSLog(@"%@", error);
//        }
//    }];
//
//
//}

//-(void)queryForLocations: (Region *)region
//{
//    PFQuery *query = [Location query];
//    [query whereKey:rwfLocationToRegion equalTo:region];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//
//        if (error == nil)
//        {
//
//            NSMutableArray *locations = [NSMutableArray arrayWithArray:objects];
//            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:rwfLocationIndex ascending:YES];
//            NSArray *array = [NSArray arrayWithObject:sortDescriptor];
//            [locations sortUsingDescriptors:array];
//            [self.delegate didQueryLocations:locations];
//        }
//        
//        else
//        {
//            NSLog(@"%@", error);
//        }
//    }];
//}

//-(void)removeLocation:(Location *)location
//{
//    [location deleteInBackground];
//}

//TODO: Refactor for changes
-(void)moveObject:(PFObject *)object toIndexPath:(NSIndexPath *)destinationIndexPath
{
//    [self.locations removeObject:object];
//    [self.locations insertObject:object atIndex:destinationIndexPath.row];
//    for (Location *aLocation in self.locations)
//    {
//        NSUInteger index = [self.locations indexOfObject:aLocation] + 1;
//        NSNumber *number = [NSNumber numberWithUnsignedInteger:index];
//        aLocation.index = number;
//        [aLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (error)
//            {
//                NSLog(@"%@", error);
//            }
//        }];
//    }

    [self.delegate didMoveLocationsIndex];
}

//-(void)changeVisitedStatusOfLocation:(Location *)location
//{
//    if ([location.hasVisited  isEqual: @0])
//    {
//        location.hasVisited = @1;
//    }
//    else
//    {
//        location.hasVisited = @0;
//    }
//
//    [location saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (error)
//        {
//            NSLog(@"%@", error);
//        }
//    }];
//
//}

@end

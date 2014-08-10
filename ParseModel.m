//
//  ParseModel.m
//  TSApp
//
//  Created by Rich Fellure on 8/7/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "ParseModel.h"

@implementation ParseModel


-(void)createRegion:(NSString *)name
{
    self.currentRegion = [PFObject objectWithClassName:rwfRegionString];
    self.currentRegion[rwfRegionNameString] = name;
    [self.currentRegion saveInBackground];
}

-(void)createLocation: (CLLocationCoordinate2D) coordinate
{
    PFObject *location = [PFObject objectWithClassName:rwfLocationParseClass];

    NSNumber *latitude = [NSNumber numberWithDouble:coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:coordinate.longitude];
    [location setObject:latitude  forKey: rwfLatitude];
    [location setObject:longitude forKey: rwfLongitude];
    [location setObject:self.currentRegion forKey:rwfLocationToRegion];
    [location saveInBackground];

    [self.currentRegion addObject:location forKey:rwfLocations];
    [self.currentRegion saveInBackground];
}

-(void)queryForRegions
{
    PFQuery *query = [PFQuery queryWithClassName:rwfRegionString];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (error == nil)
        {
             [self.delegate didFinishRegionsQuery:objects];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }];
}

-(void)queryForLocations: (NSString *)regionNameString
{
    PFQuery *query = [PFQuery queryWithClassName: rwfLocationParseClass];
    [query whereKey:rwfLocationToRegion equalTo:self.currentRegion];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (error == nil)
        {
            [self.delegate didQueryLocations:objects];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }];
}


@end

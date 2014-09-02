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
-(void)userSignUp: (NSString *)username andPassword: (NSString *)password andEmail:(NSString *)email
{
    PFUser *user = [User user];
    user.username = username;
    user.password = password;
    user.email = email;

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            NSLog(@"%@", error);

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"The Username or Password you are trying to use are taken please try again" message:nil delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else
        {
            [self.delegate didSignUp];
        }
    }];
}

-(void)userLogin:(NSString *)username withPassword:(NSString *)password
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {

        if (error)
        {
            NSLog(@"%@", error);

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Username or Password entered are incorrect" message:nil delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else
        {
            [self.delegate didLogin];
        }
    }];
}

#pragma mark - Create, query Region
-(void)createRegion:(NSString *)regionName
{
    Region *region = [Region object];
    region.name = regionName;
    region.user = [User currentUser];
    region.completed = NO;
    [region saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            NSLog(@"%@", error);
        }
        else
        {
            [self.delegate didCreateRegion:region];
        }
    }];
}

-(void)editRegion:(Region *)region completedType:(BOOL)completed
{
    region.completed = completed;

    [region saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        if (error)
        {
            NSLog(@"%@", error);
        }
        else
        {
            NSLog(@"It saved in the background and such");
        }
    }];
}

-(void)deleteRegion:(Region *)region
{
    [region deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            NSLog(@"%@", error);
        }
    }];
}

-(void)queryForRegions
{
    PFQuery *query = [Region query];
    [query whereKey:rwfRegionToUser equalTo:[User currentUser]];
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

#pragma mark - Create Location
-(void)createLocation: (CLLocationCoordinate2D) coordinate array:(NSMutableArray *)array currentRegion: (Region *)region
{
    Location *location = [Location object];

    NSNumber *latitude = [NSNumber numberWithDouble:coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:coordinate.longitude];
    NSUInteger index = array.count + 1;
    NSNumber *number = [NSNumber numberWithUnsignedInteger:index];

    location.name = @"";
    location.hasVisited = @0;
    location.longitude = longitude;
    location.latitude = latitude;
    location.index = number;
    location.region = region;
    NSLog(@"moving to saveInBackground for the Location: %@", location);

    [location saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error == nil)
        {
//            NSLog(@"%@", location);
//            [self.delegate didCreateLocation:location];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }];


}

-(void)queryForLocations: (Region *)region
{
    PFQuery *query = [Location query];
    [query whereKey:rwfLocationToRegion equalTo:region];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (error == nil)
        {

            NSMutableArray *locations = [NSMutableArray arrayWithArray:objects];
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:rwfLocationIndex ascending:YES];
            NSArray *array = [NSArray arrayWithObject:sortDescriptor];
            [locations sortUsingDescriptors:array];
            [self.delegate didQueryLocations:locations];
        }
        
        else
        {
            NSLog(@"%@", error);
        }
    }];
}

-(void)removeLocation:(Location *)location
{
    [location deleteInBackground];
}

-(void)reorderLocationsArray:(NSIndexPath *)startingIndexPath endIndex:(NSIndexPath *)endingIndexPath array: (NSArray *)array
{

    for (Location *aLocation in array)
    {
        NSUInteger index = [array indexOfObject:aLocation] + 1;
        NSNumber *number = [NSNumber numberWithUnsignedInteger:index];
        aLocation.index = number;
        [aLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error)
            {
                NSLog(@"%@", error);
            }
        }];
    }

    [self.delegate didMoveLocationsIndex];
}

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

-(void)changeVisitedStatusOfLocation:(Location *)location
{
    if ([location.hasVisited  isEqual: @0])
    {
        location.hasVisited = @1;
    }
    else
    {
        location.hasVisited = @0;
    }

    [location saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            NSLog(@"%@", error);
        }
    }];

}

@end

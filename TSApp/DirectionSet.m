//
//  DirectionSet.m
//  TSApp
//
//  Created by Rich Fellure on 4/6/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "DirectionSet.h"
#import "Direction.h"
#import "AppDelegate.h"


@implementation DirectionSet

@dynamic locationTo;
@dynamic locationFrom;
@dynamic directions;
@synthesize directionsArray;

-(NSArray *)directionsArray {
    return [self.directions allObjects];
}

-(instancetype)initWithDirections:(NSArray *)directions andStartingLocation:(CDLocation *)startingLocation andEndingLocation:(CDLocation *)endingLocation {
    AppDelegate *appdel = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *moc = appdel.managedObjectContext;
    self = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([DirectionSet class]) inManagedObjectContext:moc];
    [self addDirections:[NSSet setWithArray:directions]];
    self.locationTo = startingLocation;
    self.locationFrom = endingLocation;
    [moc save:nil];
    return self;
}

+(NSArray *)fetchDirectionSetWithStartingLocation:(CDLocation *)startingLocation andEndingLocation:(CDLocation *)endingLocation {
    AppDelegate *appdel = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *moc = appdel.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([DirectionSet class])];
    request.predicate = [NSPredicate predicateWithFormat:@"locationTo == %@ && locationFrom == %@", startingLocation, endingLocation];
    return [moc executeFetchRequest:request error:nil];
}

@end

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
#import "CDLocation.h"


@implementation DirectionSet

@dynamic locationTo;
@dynamic locationFrom;
@dynamic directions;
@synthesize directionsArray;

-(NSArray *)directionsArray {
    return [self sortArrayByIndex:[self.directions allObjects]];
}

-(NSArray *)sortArrayByIndex:(NSArray *)arrayToSort {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

+(void)createNewDirectionSetWithDirections:(NSArray *)directions andStartingLocation:(CDLocation *)startingLocation andEndingLocation:(CDLocation *)endingLocation {
    DirectionSet *directionSet = [[DirectionSet alloc]initWithDirections:directions andStartingLocation:startingLocation andEndingLocation:endingLocation];
    [directionSet.managedObjectContext save:nil];
}

-(instancetype)initWithDirections:(NSArray *)directions andStartingLocation:(CDLocation *)startingLocation andEndingLocation:(CDLocation *)endingLocation {
    AppDelegate *appdel = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *moc = appdel.managedObjectContext;
    self = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([DirectionSet class]) inManagedObjectContext:moc];
    [self addDirections:[NSSet setWithArray:directions]];
    self.locationTo = startingLocation;
    self.locationFrom = endingLocation;
    return self;
}

+(NSArray *)fetchDirectionSetsWithLocation:(CDLocation *)location {
    AppDelegate *appdel = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *moc = appdel.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([DirectionSet class])];
    request.predicate = [NSPredicate predicateWithFormat:@"locationTo.objectId == %@ || locationFrom.objectId == %@", location.objectId, location.objectId];
    return [self separateToAndFromDirectionSets:[moc executeFetchRequest:request error:nil] forLocation:location];
}

+(NSArray *)separateToAndFromDirectionSets:(NSArray *)directionSets forLocation:(CDLocation *)location {
    NSMutableArray *toArray = [NSMutableArray new];
    NSMutableArray *fromArray = [NSMutableArray new];
    for (DirectionSet *directionSet in directionSets) {
        if ([directionSet.locationFrom isEqual:location]) {
            [fromArray addObject:directionSet];
        }
        else {
            [toArray addObject:directionSet];
        }
    }
    return @[fromArray, toArray];
}

@end

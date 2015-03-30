//
//  CDRegion.m
//  TSApp
//
//  Created by Rich Fellure on 3/21/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "CDRegion.h"
#import "CDLocation.h"
#import "AppDelegate.h"
#import "Region.h"


@implementation CDRegion

@dynamic name;
@dynamic completed;
@dynamic longitude;
@dynamic latitude;
@dynamic locations;
@synthesize vistedLocations = _vistedLocations;
@synthesize notVisitedLocations = _notVisitedLocations;


#pragma mark - Getter and setter methods for certain properties.
-(NSArray *)vistedLocations {
    NSMutableArray *array = [NSMutableArray new];
    for (CDLocation *location in self.locations) {
        if (location.hasVisited == true) {
            [array addObject:location];
        }
    }
    return [self sortArrayByIndex:array];
}

-(void)setVistedLocations:(NSArray *)vistedLocations {
    _vistedLocations = self.vistedLocations;
}

-(NSArray *)notVisitedLocations {
    NSMutableArray *array = [NSMutableArray new];
    for (CDLocation *location in self.locations) {
        if (location.hasVisited == false) {
            [array addObject:location];
        }
    }
    return [self sortArrayByIndex:array];
}

-(void)setNotVisitedLocations:(NSArray *)notVisited {
    _notVisitedLocations = self.notVisitedLocations;
}

-(BOOL)hasCompleted {
    return [self.completed boolValue];
}

-(void)setHasCompleted:(BOOL)hasCompleted {
    self.completed = [NSNumber numberWithBool:hasCompleted];
}

//Used to sort our visited and notVisited Arrays.
-(NSArray *)sortArrayByIndex:(NSArray *)arrayToSort {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

-(instancetype)initWithName:(NSString *)name andGeoPoint:(PFGeoPoint *)geoPoint {
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    self = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CDRegion class]) inManagedObjectContext:appDelegate.managedObjectContext];
    self.name = name;
    self.longitude = [NSNumber numberWithDouble:geoPoint.longitude];
    self.latitude = [NSNumber numberWithDouble: geoPoint.latitude];
    return self;
}

+(void)createNewRegionWithName:(NSString *)name andGeoPoint:(PFGeoPoint *)geoPoint completed:(void(^)(BOOL result, CDRegion *region))completionHandler {
    CDRegion *region = [[CDRegion alloc]initWithName:name andGeoPoint:geoPoint];
    [region.managedObjectContext save:nil];
    [Region createRegion:name withGeoPoint:geoPoint compeletion:^(Region *newRegion, NSError *error) {
        completionHandler(error ? false : true, region);
    }];
}

+(void)fetchRegionsWithBlock:(void(^)(NSArray * sortedRegions))completed {
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:NSStringFromClass([CDRegion class])];
    NSSortDescriptor *sortDiscriptor = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:true];
    request.sortDescriptors = @[sortDiscriptor];
    NSArray *fullArray = [moc executeFetchRequest:request error:nil];

    completed(@[[CDRegion visitedOrNotVisitedArray:false fromArray:fullArray], [CDRegion visitedOrNotVisitedArray:true fromArray:fullArray]]);

}

//Helper method used for return Array of CDRegion objects that have either been visited, or not visited depending on what is specified in the visited parameter.
+(NSArray *)visitedOrNotVisitedArray:(BOOL)visited fromArray:(NSArray *)array {
    NSMutableArray *mArray = [NSMutableArray new];
    for (CDRegion *region in array) {
        if (region.hasCompleted == visited) {
            [mArray addObject:region];
        }
    }
    return mArray;
}

@end












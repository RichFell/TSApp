//
//  CDRegion.m
//  TSApp
//
//  Created by Rich Fellure on 3/21/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "CDRegion.h"
#import "AppDelegate.h"
#import "Region.h"
#import "Location.h"


@implementation CDRegion

static NSString *const kDefaultRegion = @"defaultRegion";

@dynamic name;
@dynamic completed;
@dynamic longitude;
@dynamic latitude;
@dynamic locations;
@dynamic objectId;
@synthesize sortedArrayOfLocations = _sortedArrayOfLocations;
@synthesize allLocations = _allLocations;


#pragma mark - Getter and setter methods for certain properties.
-(NSArray *)sortedArrayOfLocations {
    NSMutableArray *visited = [NSMutableArray new];
    NSMutableArray *notVisited = [NSMutableArray new];
    for (CDLocation *location in self.locations) {
        if (location.hasVisited == true) {
            [visited addObject:location];
        }
        else {
            [notVisited addObject:location];
        }
    }
    return @[[self sortArrayByIndex:notVisited], [self sortArrayByIndex:visited]];
}

-(void)setSortedArrayOfLocations:(NSArray *)arrayOfLocations {
    _sortedArrayOfLocations = self.sortedArrayOfLocations;
}

-(NSArray *)allLocations {
    return [self.locations allObjects];
}

-(void)setAllLocations:(NSArray *)allLocations {
    for (CDLocation *location in allLocations) {
        if (![self.locations containsObject:location]) {
            [self addLocationsObject:location];
        }
    }
}

-(BOOL)hasCompleted {
    return [self.completed boolValue];
}

-(void)setHasCompleted:(BOOL)hasCompleted {
    self.completed = [NSNumber numberWithBool:hasCompleted];
}

-(CLLocationCoordinate2D)coordinate {
    return  CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

-(void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    self.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    self.longitude = [NSNumber numberWithDouble:coordinate.longitude];
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

+(CDRegion *)createNewRegionWithName:(NSString *)name andGeoPoint:(PFGeoPoint *)geoPoint {
    CDRegion *region = [[CDRegion alloc]initWithName:name andGeoPoint:geoPoint];

    [Region createRegion:name withGeoPoint:geoPoint andObjectID:[NSString stringWithFormat:@"%@", region.objectID] compeletion:^(Region *newRegion, NSError *error) {
        region.objectId = newRegion.objectId;
        [region.managedObjectContext save:nil];
    }];
    return region;
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

-(void)removeLocationFromLocations:(CDLocation *)location completed:(void(^)(BOOL result))completionHandler {
    [self removeLocationsObject:location];
    [Location deleteLocationWithID:[NSString stringWithFormat:@"%@",(location.objectID)] completed:^(BOOL result, NSError *error) {
    }];
    [self.managedObjectContext deleteObject:location];
    [self.managedObjectContext save:nil];
    completionHandler(true);
}

///Gets the default Region by seeing if there is a default Region, and if there is then doing a query for it based on the stored objectId
+(void)getDefaultRegionWithBlock:(void (^)(CDRegion *, NSError *))completionHandler {
    if ([NSUserDefaults.standardUserDefaults objectForKey:kDefaultRegion] != nil) {
        NSString *defaultId = [NSUserDefaults.standardUserDefaults objectForKey:kDefaultRegion];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", defaultId];
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:NSStringFromClass([CDRegion class])];
        request.predicate = predicate;
        AppDelegate *appDel = [[UIApplication sharedApplication]delegate];
        NSManagedObjectContext *moc = appDel.managedObjectContext;
        NSArray *regions = [moc executeFetchRequest:request error:nil];
        completionHandler(regions[0], nil);
    }
    else {
        completionHandler(nil, nil);
    }
}

@end












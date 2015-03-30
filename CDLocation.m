//
//  CDLocation.m
//  TSApp
//
//  Created by Rich Fellure on 3/21/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "CDLocation.h"
#import "CDRegion.h"
#import "AppDelegate.h"
#import "Location.h"


@implementation CDLocation

@dynamic name;
@dynamic index;
@dynamic id;
@dynamic visited;
@dynamic latitude;
@dynamic longitude;
@dynamic engAddress;
@dynamic localAddress;
@dynamic region;
@dynamic objectId;

-(BOOL)hasVisited {
    return [self.visited boolValue];
}

-(void)setHasVisited:(BOOL)hasVisited {
    self.visited = [NSNumber numberWithBool:hasVisited];
}

-(CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

-(void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    self.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    self.longitude = [NSNumber numberWithDouble:coordinate.longitude];
}

-(instancetype)initWithName:(NSString *)name atCoordinate:(CLLocationCoordinate2D)coordinate atIndex:(NSNumber *)index forRegion:(CDRegion *)region atAddress:(NSString *)address {
    AppDelegate *appDel = [[UIApplication sharedApplication] delegate];
    self = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([CDLocation class]) inManagedObjectContext:appDel.managedObjectContext];
    self.name = name;
    self.region = region;
    self.localAddress = address;
    self.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    self.longitude = [NSNumber numberWithDouble:coordinate.longitude];
    self.index = index;
    return self;
}

+(void)createNewLocationWithName:(NSString *)name atCoordinate:(CLLocationCoordinate2D)coordinate atIndex:(NSNumber *)index forRegion:(CDRegion *)region atAddress:(NSString *)address completion:(void(^)(CDLocation *location, BOOL result))completionHandler {
    CDLocation *nLocation = [[CDLocation alloc]initWithName:name atCoordinate:coordinate atIndex:index forRegion:region atAddress:address];
    [nLocation.managedObjectContext save:nil];
    [Location createLocation:coordinate andName:name atIndex:index currentRegion:region andAddress:address withID:[NSString stringWithFormat:@"%@",nLocation.objectID] completion:^(Location *location, NSError *error) {
        nLocation.objectId = location.objectID;
        completionHandler(nLocation, error ? false : true);
    }];
}

@end

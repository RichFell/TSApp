//
//  CDLocation.h
//  TSApp
//
//  Created by Rich Fellure on 4/6/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class CDRegion, Direction;

@interface CDLocation : NSManagedObject

@property (nonatomic, retain) NSString * engAddress;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * localAddress;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSNumber * visited;
@property (nonatomic, retain) NSSet *directionsFrom;
@property (nonatomic, retain) NSSet *directionsTo;
@property (nonatomic, retain) CDRegion *region;
@property BOOL hasVisited;
@property CLLocationCoordinate2D coordinate;

+(void)createNewLocationWithName:(NSString *)name atCoordinate:(CLLocationCoordinate2D)coordinate atIndex:(NSNumber *)index forRegion:(CDRegion *)region atAddress:(NSString *)address completion:(void(^)(CDLocation *location, BOOL result))completionHandler;

-(instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate andName:(NSString *)name atIndex:(NSNumber *)index forRegion:(CDRegion *)region atAddress:(NSString *)address;

-(instancetype)initWithDefault:(CLLocationCoordinate2D)coordinate;

-(void)saveLocation;

@end

@interface CDLocation (CoreDataGeneratedAccessors)

- (void)addDirectionsFromObject:(Direction *)value;
- (void)removeDirectionsFromObject:(Direction *)value;
- (void)addDirectionsFrom:(NSSet *)values;
- (void)removeDirectionsFrom:(NSSet *)values;

- (void)addDirectionsToObject:(Direction *)value;
- (void)removeDirectionsToObject:(Direction *)value;
- (void)addDirectionsTo:(NSSet *)values;
- (void)removeDirectionsTo:(NSSet *)values;






@end

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

@class CDRegion;

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
@property (nonatomic, retain) CDRegion *region;
@property (nonatomic, retain) NSSet *directionSetTo;
@property (nonatomic, retain) NSSet *directionSetsFrom;

@property BOOL hasVisited;
@property CLLocationCoordinate2D coordinate;

+(void)createNewLocationWithName:(NSString *)name atCoordinate:(CLLocationCoordinate2D)coordinate atIndex:(NSNumber *)index forRegion:(CDRegion *)region atAddress:(NSString *)address completion:(void(^)(CDLocation *location, BOOL result))completionHandler;

-(instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate andName:(NSString *)name atIndex:(NSNumber *)index forRegion:(CDRegion *)region atAddress:(NSString *)address;

-(instancetype)initWithDefault:(CLLocationCoordinate2D)coordinate;

-(void)saveLocation;
@end

@interface CDLocation (CoreDataGeneratedAccessors)

- (void)addDirectionSetToObject:(NSManagedObject *)value;
- (void)removeDirectionSetToObject:(NSManagedObject *)value;
- (void)addDirectionSetTo:(NSSet *)values;
- (void)removeDirectionSetTo:(NSSet *)values;

- (void)addDirectionSetsFromObject:(NSManagedObject *)value;
- (void)removeDirectionSetsFromObject:(NSManagedObject *)value;
- (void)addDirectionSetsFrom:(NSSet *)values;
- (void)removeDirectionSetsFrom:(NSSet *)values;

@end

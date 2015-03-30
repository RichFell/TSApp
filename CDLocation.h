//
//  CDLocation.h
//  TSApp
//
//  Created by Rich Fellure on 3/21/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDRegion;

@interface CDLocation : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * visited;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * engAddress;
@property (nonatomic, retain) NSString * localAddress;
@property (nonatomic, retain) CDRegion *region;
@property (nonatomic, retain) NSString *objectId;
@property BOOL hasVisited;
@property CLLocationCoordinate2D coordinate;

+(void)createNewLocationWithName:(NSString *)name atCoordinate:(CLLocationCoordinate2D)coordinate atIndex:(NSNumber *)index forRegion:(CDRegion *)region atAddress:(NSString *)address completion:(void(^)(CDLocation *location, BOOL result))completionHandler;

@end

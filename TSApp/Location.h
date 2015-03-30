//
//  Location.h
//  TSApp
//
//  Created by Rich Fellure on 8/12/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Parse/Parse.h>
#import "Region.h"
#import "CDRegion.h"

@interface Location : PFObject <PFSubclassing>

+(NSString *)parseClassName;


@property NSString *name;
@property NSNumber *index;
@property NSString *objectID;
@property NSNumber *hasVisited;
@property PFObject *region;
@property PFGeoPoint *coordinate;
@property NSString *address;

+(void)createLocation:(CLLocationCoordinate2D)coordinate andName:(NSString *)name atIndex:(NSNumber *)index currentRegion:(CDRegion *)region andAddress:(NSString *)theAddress withID:(NSString *)iD completion:(void (^)(Location *, NSError *))completionHandler;

+(void)queryForLocations:(Region *) region completed: (void(^)(NSArray * locations, NSError *error))completionHandler;

-(void)deleteLocationWithBlock: (NSArray *)locations completed:(void(^)(BOOL result, NSError *error))completionHandler;
-(void)changeVisitedStatusWithBlock: (void(^)(BOOL result, NSError *error))completionHandler;
-(void)changeIndexOfLocations: (NSArray *)locations completion: (void(^)(BOOL result, NSError *error))completionHandler;
@end


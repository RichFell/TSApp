//
//  Location.h
//  TSApp
//
//  Created by Rich Fellure on 8/12/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Parse/Parse.h>
#import "Region.h"

@interface Location : PFObject <PFSubclassing>

+(NSString *)parseClassName;


@property NSString *name;
@property NSNumber *index;
@property NSString *objectID;
@property NSNumber *hasVisited;
@property PFObject *region;
@property PFGeoPoint *coordinate;

+(void )createLocation: (CLLocationCoordinate2D) coordinate andName:(NSString *)name array: (NSMutableArray *)array currentRegion: (Region *)region completion: (void (^)(Location *theLocation, NSError *error))completionHandler;

+(void)queryForLocations:(Region *) region completed: (void(^)(NSArray * locations, NSError *error))completionHandler;

-(void)deleteLocationWithBlock: (NSArray *)locations completed:(void(^)(BOOL result, NSError *error))completionHandler;
-(void)changeVisitedStatusWithBlock: (void(^)(BOOL result, NSError *error))completionHandler;
-(void)changeIndexOfLocations: (NSArray *)locations completion: (void(^)(BOOL result, NSError *error))completionHandler;
@end


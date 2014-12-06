//
//  Region.h
//  TSApp
//
//  Created by Rich Fellure on 8/12/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Parse/Parse.h>

@interface Region : PFObject <PFSubclassing>

+(NSString *) parseClassName;

@property NSString *name;
@property PFUser *user;
@property BOOL completed;
@property PFGeoPoint *destinationPoint;

+(void)queryForRegionsWithBlock: (void(^)(NSArray *regions, NSError *error))completionHandler;
+(void)queryForRegionWithObjectId: (NSString *)objectId completion: (void(^)(Region *defaultRegion, NSError *error))completionHandler;
+(void)createRegion:(NSString *) regionName withGeoPoint:(PFGeoPoint *)geoPoint compeletion: (void(^)(Region *newRegion, NSError *error))completionHandler;

-(void)deleteRegionWithBlock: (void(^)(BOOL result, NSError *error))completionHandler;
-(void)switchRegionCompletedStatusWithBlock: (void(^)(BOOL result, NSError *error))completionHandler;

@end







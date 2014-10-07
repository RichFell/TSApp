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
//@property NSNumber *nearLeftLong;
//@property NSNumber *nearLeftLat;
//@property NSNumber *nearRightLong;
//@property NSNumber *nearRightLat;
//@property NSNumber *farLeftLong;
//@property NSNumber *farLeftLat;
//@property NSNumber *farRightLong;
//@property NSNumber *farRightLat;

+(void)queryForRegionsWithBlock: (void(^)(NSArray *regions, NSError *error))completionHandler;
+(void)createRegion:(NSString *) regionName compeletion: (void(^)(Region *newRegion, NSError *error))completionHandler;

-(void)deleteRegionWithBlock: (void(^)(BOOL result, NSError *error))completionHandler;
-(void)switchRegionCompletedStatusWithBlock: (void(^)(BOOL result, NSError *error))completionHandler;

@end







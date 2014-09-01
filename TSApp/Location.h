//
//  Location.h
//  TSApp
//
//  Created by Rich Fellure on 8/12/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Parse/Parse.h>

@interface Location : PFObject <PFSubclassing>

+(NSString *)parseClassName;
@property NSString *name;
@property NSNumber *index;
@property NSString *objectID;
@property NSNumber *latitude;
@property NSNumber *longitude;
@property NSNumber *hasVisited;
@property PFObject *region;
@end

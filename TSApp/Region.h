//
//  Region.h
//  TSApp
//
//  Created by Rich Fellure on 8/12/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Parse/Parse.h>
#import "Location.h"

@interface Region : PFObject <PFSubclassing>

+(NSString *) parseClassName;

@property NSString *name;
@property PFUser *user;
//@property NSNumber *nearLeftLong;
//@property NSNumber *nearLeftLat;
//@property NSNumber *nearRightLong;
//@property NSNumber *nearRightLat;
//@property NSNumber *farLeftLong;
//@property NSNumber *farLeftLat;
//@property NSNumber *farRightLong;
//@property NSNumber *farRightLat;

@end

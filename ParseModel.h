//
//  ParseModel.h
//  TSApp
//
//  Created by Rich Fellure on 8/7/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ParseModel : NSObject

-(void)createRegion:(NSString *) name;
-(void )createLocation;

@property PFObject *currentRegion;

@end

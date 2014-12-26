//
//  Direction.h
//  TSApp
//
//  Created by Rich Fellure on 9/1/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Direction : NSObject

@property NSString *step;
@property NSString *distance;
@property float startingLatitude;
@property float startingLongitude;
@property float endingLatitude;
@property float endingLongitude;

+(instancetype)initWithDictionary:(NSDictionary *)dictionary;
+(void)getDirectionsWithCoordinate:(CLLocationCoordinate2D)startingPosition andEndingPosition:(CLLocationCoordinate2D)endPosition andBlock:(void (^)(NSArray *, NSError *))completionHandler;

@end

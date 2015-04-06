//
//  Direction.h
//  TSApp
//
//  Created by Rich Fellure on 4/6/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class CDLocation;

@interface Direction : NSManagedObject

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * steps;
@property (nonatomic, retain) NSNumber * totalTime;
@property (nonatomic, retain) CDLocation *fromLocation;
@property (nonatomic, retain) CDLocation *toLocation;
@property (nonatomic, retain)float startingLatitude;
@property (nonatomic, retain)float startingLongitude;
@property (nonatomic, retain)float endingLatitude;
@property (nonatomic, retain)float endingLongitude;

+(void)getDirectionsWithCoordinate:(CLLocationCoordinate2D)startingPosition andEndingPosition:(CLLocationCoordinate2D)endPosition withTypeOfTransportation:(NSString *)transportation andBlock:(void (^)(NSArray *, NSError *))completionHandler;

/*

 From Direction.h
 @property NSString *step;
 @property NSString *distance;
 @property NSString *duration;


 +(instancetype)initWithDictionary:(NSDictionary *)dictionary;

 */

@end

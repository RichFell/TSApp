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

@class DirectionSet, CDLocation;

@interface Direction : NSManagedObject

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * steps;
@property (nonatomic, retain) NSNumber * totalTime;
@property (nonatomic, retain) NSNumber * startingLatitude;
@property (nonatomic, retain) NSNumber * startingLongitude;
@property (nonatomic, retain) NSNumber * endingLatitude;
@property (nonatomic, retain) NSNumber * endingLongitude;
@property (nonatomic, retain) DirectionSet *directionSet;

/**
 Description: Makes call to GoogleDirections API in order to return the information for the Directions
 :startingPosition: CLLocationCoordinate2D that is the beginning location for the directions being asked for
 :endingPosition: CLLocationCoordinate2D that is the ending location for the directions being asked for.
 :transportation: The transportation type the the user is wanting to use
 */
 +(void)getDirectionsWithCoordinate:(CLLocationCoordinate2D)startingPosition andEndingPosition:(CLLocationCoordinate2D)endPosition withTypeOfTransportation:(NSString *)transportation andBlock:(void (^)(NSArray *, NSError *))completionHandler;

@end

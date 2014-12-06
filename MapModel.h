//
//  MapModel.h
//  TSApp
//
//  Created by Rich Fellure on 8/7/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>


@interface MapModel : NSObject

//@property CLPlacemark *searchedPlacemark;
//@property CLLocationCoordinate2D selectedLocation;
//@property NSArray *directions;
//
//-(CLLocationCoordinate2D)requestSelectedLocation;
//-(NSArray *)returnDirections;
+(void)geocodeString:(NSString *)theString withBlock: (void (^)(CLLocationCoordinate2D coordinate, NSError *error))completionHandler;
+(void)reverseGeoCode: (CLLocationCoordinate2D) location withBlock: (void(^)(GMSReverseGeocodeResponse *response, NSError *error))completionHandler;
+(void)getDirectionsWithCoordinate: (CLLocationCoordinate2D)startingPosition andEndingPosition: (CLLocationCoordinate2D)endPosition andBlock:(void(^)(NSArray *directionArray, NSError *error))completionHandler;

@end
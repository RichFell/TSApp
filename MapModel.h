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

+(void)geocodeString:(NSString *)theString withBlock: (void (^)(CLLocationCoordinate2D coordinate, NSError *error))completionHandler;
+(void)reverseGeoCode: (CLLocationCoordinate2D) location withBlock: (void(^)(GMSReverseGeocodeResponse *response, NSError *error))completionHandler;

@end
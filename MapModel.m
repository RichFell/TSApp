//
//  MapModel.m
//  TSApp
//
//  Created by Rich Fellure on 8/7/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "MapModel.h"


@implementation MapModel

+(void)geocodeString:(NSString *)theString withBlock:(void (^)(CLLocationCoordinate2D, NSError *))completionHandler
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder geocodeAddressString:theString completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks[0];
        completionHandler(placemark.location.coordinate, error);
    }];
}

+(void)reverseGeoCode:(CLLocationCoordinate2D)location withBlock:(void (^)(GMSReverseGeocodeResponse *, NSError *))completionHandler
{
    [[GMSGeocoder geocoder]reverseGeocodeCoordinate:location completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
        completionHandler(response, error);
    }];

}


@end

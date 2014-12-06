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

+(void)getDirectionsWithCoordinate:(CLLocationCoordinate2D)startingPosition andEndingPosition:(CLLocationCoordinate2D)endPosition andBlock:(void (^)(NSArray *, NSError *))completionHandler
{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&key=AIzaSyCLR3ztaPMZugnESkzeeAWWTkxbHTpgCPA", startingPosition.latitude, startingPosition.longitude, endPosition.latitude, endPosition.longitude];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSError *jsonError = nil;

            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];

            NSArray *theDirections = [NSArray arrayWithArray:dictionary[@"routes"]];

            completionHandler(theDirections, connectionError);
    }];
}

@end

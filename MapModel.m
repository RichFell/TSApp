//
//  MapModel.m
//  TSApp
//
//  Created by Rich Fellure on 8/7/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "MapModel.h"


@implementation MapModel


-(void)setupLocationManager
{

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

-(void)geocodeString: (NSString *)address
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error != nil)
        {
            NSLog(@"error");
        }
        else
        {
            self.searchedPlacemark = (CLPlacemark *)placemarks[0];
            [self.delegate didGeocodeString:self.searchedPlacemark.location.coordinate];
        }
    }];
}

-(void)reverseGeocode:(CLLocationCoordinate2D)location
{
    [[GMSGeocoder geocoder]reverseGeocodeCoordinate:location completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
        if (error != nil)
        {
            NSLog(@"Reverse Geocoder Error: %@", error);
        }
        else
        {
            NSLog(@"%@", response.firstResult);

            [self.delegate didReverseGeocode:response];
        }
    }];

}

-(CLPlacemark *)returnSearchedPlacemark
{
    return self.searchedPlacemark;
}

//-(void)selectLocation:(CLLocationCoordinate2D)location
//{
//    self.selectedLocation = location;
//  
//}

-(CLLocationCoordinate2D)requestSelectedLocation
{
    return self.selectedLocation;
}

#pragma mark - CLLocationManagerDelegate Method
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation  *location in locations)
    {
        if (location.verticalAccuracy < 100 && location.horizontalAccuracy < 100)
        {
            [self.delegate didFindNewLocation:location];
            [self.locationManager stopUpdatingLocation];
        }
    }
}

-(void)getDirections:(CLLocationCoordinate2D)startingPosition endingPosition:(CLLocationCoordinate2D)endPosition
{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&key=AIzaSyCLR3ztaPMZugnESkzeeAWWTkxbHTpgCPA", startingPosition.latitude, startingPosition.longitude, endPosition.latitude, endPosition.longitude];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError)
        {
            NSLog(@"%@", connectionError);
        }
        else
        {
            NSError *jsonError = nil;

            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];

//            NSArray *directionsArray = dictionary[@"routes"];
            self.directions = [NSArray arrayWithArray:dictionary[@"routes"]];

            NSLog(@"%@", self.directions);

            [self.delegate didGetDirections:self.directions];
        }
    }];
}

-(NSArray *)returnDirections
{
    return self.directions;
}

@end

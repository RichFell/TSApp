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

@end

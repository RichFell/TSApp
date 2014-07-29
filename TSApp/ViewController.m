//
//  ViewController.m
//  TSApp
//
//  Created by Richard Fellure on 7/19/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController ()<GMSMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate>
@property CLLocation *currentLocation;
@property CLLocationManager *locationmanager;
@property GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.locationmanager = [[CLLocationManager alloc] init];
    self.locationmanager.delegate = self;
    [self.locationmanager startUpdatingLocation];

    self.mapView = [[GMSMapView alloc] initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    [self.mapView animateToZoom:10.0];
    [self.view addSubview: self.mapView];

    [self.view bringSubviewToFront:self.textField];
    [self.view sendSubviewToBack:self.mapView];

    self.textField.delegate = self;

}

#pragma mark -GMSMapViewDelegate methods

-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    //continuously gets called as the camera is moving
}

-(void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    //only gets called once when camera begins moving
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    [[GMSGeocoder geocoder]reverseGeocodeCoordinate:CLLocationCoordinate2DMake(position.target.latitude, position.target.longitude) completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
        if (error)
        {
            NSLog(@"Reverse Geocoder Error: %@", error);
        }
        else
        {
            //Do stuff with the reverse geoCode
        }
    }];
}

-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = coordinate;
    marker.map = self.mapView;

    [self reverseGeocode:coordinate];
}

# pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{

    for (CLLocation *location in locations)
    {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000)
        {
            self.currentLocation = location;
            [self.locationmanager stopUpdatingLocation];
            [self.mapView animateToLocation:location.coordinate];
        }
    }
}

#pragma mark - UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self geoCodeLocation:textField.text];
    [self.textField resignFirstResponder];
    return true;
}

#pragma mark - Helper method to setup GMSMapView and the CameraPosition

-(void)setupMapAndCamera:(CLLocation *)location
{

    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:6];

    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = cameraPosition.target;
    marker.snippet = @"Snippet?..Really?";
    self.mapView.mapType = kGMSTypeNormal;
    marker.map = self.mapView;
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = 0;
}

#pragma mark - CLGeoCoder

-(void)geoCodeLocation: (NSString *) address
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count > 0)
        {
            CLPlacemark *placemark = (CLPlacemark *)[placemarks objectAtIndex:0];

            [self.mapView animateToLocation:placemark.location.coordinate];
        }
    }];
}

#pragma mark - GMSGeocoder for reverse Geocode

-(void)reverseGeocode:(CLLocationCoordinate2D )location
{
    [[GMSGeocoder geocoder]reverseGeocodeCoordinate:location completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
        if (error)
        {
            NSLog(@"Reverse Geocoder Error: %@", error);
        }
        else
        {
            NSLog(@"ReverseGeocodeResponse %@", response);
        }
    }];

}
@end

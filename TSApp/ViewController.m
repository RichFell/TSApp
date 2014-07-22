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
    NSLog(@"Changing camera position");
}

-(void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    NSLog(@"willMove is being called");
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
    NSLog(@"happened in CLLocationManagerDelegate method");
}

#pragma mark - UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return true;
}

#pragma mark - Helper method to setup GMSMapView and the CameraPosition

-(void)setupMapAndCamera:(CLLocation *)location
{

    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:6];

//    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:cameraPosition];

    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = cameraPosition.target;
    marker.snippet = @"Snippet?..Really?";
    self.mapView.mapType = kGMSTypeNormal;
    marker.map = self.mapView;
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = 0;
}

@end

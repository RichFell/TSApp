//
//  ViewController.m
//  TSApp
//
//  Created by Richard Fellure on 7/19/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import "ParseModel.h"
#import "MapModel.h"


@interface ViewController ()<GMSMapViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, MapModelDelegate>
@property GMSMapView *mapView;
@property UITextField *alertTextField;
@property ParseModel *parseModel;
@property MapModel *mapModel;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mapModel = [[MapModel alloc] init];
    [self.mapModel setupLocationManager];
    self.mapModel.delegate = self;

    self.mapView = [[GMSMapView alloc] initWithFrame:self.view.frame];
    self.mapView.delegate = self;

    [self.mapView animateToZoom:10.0];
    [self.view addSubview: self.mapView];

    [self.view bringSubviewToFront:self.textField];
    [self.view sendSubviewToBack:self.mapView];

    self.textField.delegate = self;

    self.parseModel = [[ParseModel alloc] init];

}

#pragma mark -GMSMapViewDelegate methods

-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.mapModel reverseGeocode:coordinate];
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    NSLog(@"marker: %@", marker);
}

# pragma mark - MapModelDelegate Methods


-(void)didFindNewLocation:(CLLocation *)location
{
    [self.mapView animateToLocation:location.coordinate];
}

-(void)didGeocodeString:(CLLocationCoordinate2D)coordinate
{
    [self.mapView animateToLocation:coordinate];
}

-(void)didReverseGeocode:(GMSReverseGeocodeResponse *)reverseGeocode
{

    [self placeMarker:reverseGeocode.firstResult.coordinate string:reverseGeocode.firstResult.description];

}

#pragma mark - UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.mapModel geocodeString:textField.text];
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
    self.mapView.myLocationEnabled = YES;
}

#pragma mark - Bar Button action and AlertView delegate method

- (IBAction)onButtonPressedCreateRegion:(UIBarButtonItem *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Name this region" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].keyboardType = UIKeyboardAppearanceDefault;
    self.alertTextField = [alertView textFieldAtIndex:0];

    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [self.parseModel createRegion:self.alertTextField.text];
    }
}

#pragma mark - Button Action
- (IBAction)onButtonPressedPlaceMarker:(UIButton *)sender
{
    CLPlacemark *placemark = [self.mapModel returnSearchedPlacemark];
    [self placeMarker:placemark.location.coordinate string:placemark.description];
}

#pragma mark - Helper Method for placing Markers

-(void)placeMarker:(CLLocationCoordinate2D)coordinate string: (NSString *)string
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = coordinate;
    marker.map = self.mapView;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.tappable = YES;
    marker.snippet = string;
}

@end

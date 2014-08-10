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


@interface ViewController ()<GMSMapViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, MapModelDelegate, UITableViewDataSource, UITableViewDelegate, ParseModelDataSource>

@property GMSMapView *mapView;
@property UITextField *alertTextField;
@property ParseModel *parseModel;
@property MapModel *mapModel;
@property NSArray *regionArray;

@property (weak, nonatomic) IBOutlet UIButton *markerButton;
@property (weak, nonatomic) IBOutlet UIButton *userLocationButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tableViewControllerButton;

@end

@implementation ViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mapModel = [[MapModel alloc] init];
    self.mapModel.delegate = self;
    self.mapView.myLocationEnabled = YES;
//    self.mapView.settings.myLocationButton = YES;

    self.mapView = [[GMSMapView alloc] initWithFrame:self.view.frame];
    self.mapView.delegate = self;

    [self.mapView animateToZoom:10.0];
    [self.view addSubview: self.mapView];

    [self.view bringSubviewToFront:self.textField];
    [self.view bringSubviewToFront:self.markerButton];
    [self.view bringSubviewToFront:self.userLocationButton];
    [self.view sendSubviewToBack:self.mapView];

    self.textField.delegate = self;

    self.parseModel = [[ParseModel alloc] init];
    self.parseModel.delegate = self;

    self.tableViewControllerButton.tag = 0;

    self.tableView.hidden = YES;

}

#pragma mark -GMSMapViewDelegate methods

-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.mapModel reverseGeocode:coordinate];
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    [self.mapModel setLocation:marker.position];

    return true;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    NSLog(@"marker: %@", marker);
}

# pragma mark - MapModelDelegate Methods


-(void)didFindNewLocation:(CLLocation *)location
{
    [self.mapView animateToLocation:location.coordinate];
    [self placeMarker:location.coordinate string:rwfLocationString];
}

-(void)didGeocodeString:(CLLocationCoordinate2D)coordinate
{
    [self.mapView animateToLocation:coordinate];
}

-(void)didReverseGeocode:(GMSReverseGeocodeResponse *)reverseGeocode
{

    [self placeMarker:reverseGeocode.firstResult.coordinate string:reverseGeocode.firstResult.description];

}

#pragma mark - ParseModelDataSource Delegate Methods

-(void)didFinishRegionsQuery:(NSArray *)regions
{
    self.regionArray = [NSArray arrayWithArray:regions];
    [self.tableView reloadData];
}

-(void)didQueryLocations:(NSArray *)locations
{
    for (PFObject *location in locations)
    {
//        [self placeMarker:location  string:<#(NSString *)#>];
    }
}

#pragma mark - UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.mapModel geocodeString:textField.text];
    [self.textField resignFirstResponder];
    return true;
}

#pragma mark - UITableViewDataSource Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rwfCellIdentifier];
    PFObject *region = [self.regionArray objectAtIndex:indexPath.row];

    cell.textLabel.text = [region objectForKey: rwfRegionNameString];

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.regionArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView.hidden = true;
}

#pragma mark - Helper method to setup GMSMapView and the CameraPosition

-(void)setupMapAndCamera:(CLLocation *)location
{

    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:6];

    self.mapView.mapType = kGMSTypeNormal;
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

- (IBAction)addSelectedLocationOnPressed:(UIButton *)sender
{
    CLLocationCoordinate2D location = [self.mapModel requestSelectedLocation];
    [self.parseModel createLocation:location];
}

- (IBAction)onPressedGoToUserLocation:(UIButton *)sender
{
    [self.mapModel setupLocationManager];
}

- (IBAction)onPressedShowTableView:(UIBarButtonItem *)sender
{
    if (self.tableViewControllerButton.tag == 0)
    {
        self.tableView.hidden = NO;
        [self.view bringSubviewToFront:self.tableView];
        [self.parseModel queryForRegions];
        self.tableViewControllerButton.tag = 1;
    }
    else if (self.tableViewControllerButton.tag == 1)
    {
        self.tableView.hidden = YES;
        self.tableViewControllerButton.tag = 2;
    }
    else
    {
        self.tableView.hidden = NO;
        self.tableViewControllerButton.tag = 1;
    }

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

    [self.mapView setSelectedMarker:marker];
}

@end

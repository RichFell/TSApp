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
#import "LocationsListViewController.h"
#import "DirectionsViewController.h"
#import "Direction.h"
#import "RegionTableViewCell.h"
#import "NetworkErrorAlert.h"


@interface ViewController ()<GMSMapViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, MapModelDelegate, UITableViewDataSource, UITableViewDelegate, ParseModelDataSource>

@property GMSMapView *mapView;
@property UITextField *alertTextField;
@property ParseModel *parseModel;
@property MapModel *mapModel;
@property NSMutableArray *regionArray;
@property NSMutableArray *locationsArray;
@property Region *currentRegion;
@property CLLocationCoordinate2D selectedLocation;
@property NSMutableArray *markers;
@property NSMutableArray *directions;

@property (weak, nonatomic) IBOutlet UIButton *markerButton;
@property (weak, nonatomic) IBOutlet UIButton *userLocationButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tableViewControllerButton;
@property (weak, nonatomic) IBOutlet UIButton *locationsButton;

#define tsNotVisitedImage @"PlaceHolderImage"
#define tsHasVisitedImage @"CheckMarkImage"

@end

@implementation ViewController


//TODO: Need to figure out how want to setup saving locations to itenarary
//TODO: Figure out full look and feel. Getting to a point where it will save time in the long run to now get the UI laid out
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.locationsArray = [NSMutableArray array];
    self.regionArray = [NSMutableArray array];
    self.directions = [NSMutableArray array];

    self.mapModel = [[MapModel alloc] init];
    self.mapModel.delegate = self;
    self.mapView.myLocationEnabled = YES;

    self.mapView = [[GMSMapView alloc] initWithFrame:self.view.frame];
    self.mapView.delegate = self;

    [self.mapView animateToZoom:10.0];
    [self.view addSubview: self.mapView];

    [self.view bringSubviewToFront:self.textField];
    [self.view bringSubviewToFront:self.markerButton];
    [self.view bringSubviewToFront:self.userLocationButton];
    [self.view sendSubviewToBack:self.mapView];
    [self.view bringSubviewToFront:self.locationsButton];

    self.textField.delegate = self;

    self.parseModel = [[ParseModel alloc] init];
    self.parseModel.delegate = self;

    self.tableViewControllerButton.tag = 0;

    self.tableView.hidden = YES;

    self.markers = [NSMutableArray array];

}

#pragma mark -GMSMapViewDelegate methods

-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.mapModel reverseGeocode:coordinate];
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{

    //TODO: Make it so that when tap on the marker then window displays
    return true;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    self.selectedLocation = marker.position;
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

-(void)didCreateRegion:(Region *)region
{
    [self.regionArray addObject:region];
    [self.tableView reloadData];
}

-(void)didFinishRegionsQuery:(NSMutableArray *)regions
{
    self.regionArray = [regions mutableCopy];
    [self.tableView reloadData];
}

-(void)didQueryLocations:(NSArray *)locations
{

    [self.locationsArray removeAllObjects];
    GMSMutablePath *path = [GMSMutablePath path];

    for (Location *location in locations)
    {
        //TODO: make a custom window to add in a button to tap onto the location for info, or if that will be the way to save
        double latitude = location.latitude.doubleValue;
        double longitude = location.longitude.doubleValue;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        NSString *markerSnippet = location.name;
        [self placeMarker:coordinate string:markerSnippet];

        [path addCoordinate:coordinate];
    }
    self.locationsArray = [locations mutableCopy];
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:40.0];

    [self.mapView moveCamera:update];

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
    RegionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rwfCellIdentifier];
    Region *region = [self.regionArray objectAtIndex:indexPath.row];

    if (region.completed == true)
    {
        cell.completedButton.tag = 1;
        [cell.completedButton setBackgroundImage:[UIImage imageNamed:tsHasVisitedImage] forState:UIControlStateNormal];
    }
    else
    {
        cell.completedButton.tag = 0;
        [cell.completedButton setBackgroundImage:[UIImage imageNamed:tsNotVisitedImage] forState:UIControlStateNormal];
    }

    NSLog(@"Cell Button Tag: %li", (long)cell.completedButton.tag);
    cell.textLabel.text = region.name;

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.regionArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView.hidden = true;
    [self.mapView clear];

    self.currentRegion = [self.regionArray objectAtIndex:indexPath.row];
    [Location queryForLocations:self.currentRegion completed:^(NSArray *locations, NSError *error) {
        if (error == nil)
        {
            //TODO: something with the array of Locations given back
        }
        else
        {
            //TODO: show the Network error alert
        }
    }];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
//        [self.parseModel deleteRegion:[self.regionArray objectAtIndex:indexPath.row]];
        Region *regionToDelete = [self.regionArray objectAtIndex:indexPath.row];
        [regionToDelete deleteRegionWithBlock:^(BOOL result, NSError *error) {
            if (error == nil)
            {
                [self.regionArray removeObject:regionToDelete];
            }
            else
            {
                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
            }
        }];
    }
}

#pragma mark - Helper method to setup GMSMapView and the CameraPosition

-(void)setupMapAndCamera:(CLLocation *)location
{

//    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:6];

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
        [Region createRegion:self.alertTextField.text compeletion:^(Region *newRegion, NSError *error) {
            if (error != nil)
            {
                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
            }
        }];
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
    [Location createLocation:self.selectedLocation array:self.locationsArray currentRegion:self.currentRegion completion:^(Location *theLocation, NSError *error) {
        if (error != nil)
        {
            [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
        }
    }];
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
        [Region queryForRegionsWithBlock:^(NSArray *regions, NSError *error) {
            if (error != nil)
            {
                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
            }
        }];
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

#pragma mark - place PolyLine method

-(void)placePolyLine: (NSArray *)array
{
    GMSMutablePath *path = [GMSMutablePath path];

    for (Direction *direction in self.directions)
    {
        [path addLatitude:direction.startingLatitude longitude:direction.startingLongitude];
        [path addLatitude:direction.endingLatitude longitude:direction.endingLongitude];
    }

    GMSPolyline *polyLine = [GMSPolyline polylineWithPath:path];
    polyLine.strokeWidth = 8.0;
    polyLine.map = self.mapView;
}

#pragma mark - PrepareForSegue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LocationsListViewController *nextVC = segue.destinationViewController;

    nextVC.locations = self.locationsArray;
    nextVC.region = self.currentRegion;
}

-(IBAction)unwindSegue:(UIStoryboardSegue *)segue
{
    DirectionsViewController *directionVC = segue.sourceViewController;
    self.directions = directionVC.listOfDirections;
    [self placePolyLine:self.directions];
}

- (IBAction)onTappedSetCompletedForRegion:(UIButton *)sender
{

    RegionTableViewCell *cell = (RegionTableViewCell *)[[[sender superview]superview]superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Region *selectedRegion = [self.regionArray objectAtIndex:indexPath.row];

    if (sender.tag == 0)
    {
        [sender setBackgroundImage:[UIImage imageNamed:tsHasVisitedImage] forState:UIControlStateNormal];
        [selectedRegion switchRegionCompletedStatusWithBlock:^(BOOL result, NSError *error) {
            if (error != nil)
            {
                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
            }
        }];
        sender.tag = 1;
    }
    else
    {
        [sender setBackgroundImage:[UIImage imageNamed:tsNotVisitedImage] forState:UIControlStateNormal];

        [selectedRegion switchRegionCompletedStatusWithBlock:^(BOOL result, NSError *error) {
            if (error != nil)
            {
                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
            }
        }];
        sender.tag = 0;
    }
}

@end











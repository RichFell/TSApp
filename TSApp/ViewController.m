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
#import "MapModel.h"
#import "LocationsListViewController.h"
#import "DirectionsViewController.h"
#import "Direction.h"
#import "RegionTableViewCell.h"
#import "NetworkErrorAlert.h"


@interface ViewController ()<GMSMapViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property GMSMapView *mapView;
@property UITextField *alertTextField;
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


@end

@implementation ViewController

static NSString *const kCellIdentifier = @"CellID";
static NSString *const tsNotVisitedImage = @"PlaceHolderImage";
static NSString *const tsHasVisitiedImage = @"CheckMarkImage";

//TODO: Need to figure out how want to setup saving locations to itenarary
//TODO: Figure out full look and feel. Getting to a point where it will save time in the long run to now get the UI laid out
- (void)viewDidLoad
{
    [super viewDidLoad];


    self.tableViewControllerButton.tag = 0;
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
        double latitude = location.coordinate.latitude;
        double longitude = location.coordinate.longitude;
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
//    [self.mapModel geocodeString:textField.text];
    [MapModel geocodeString:textField.text withBlock:^(CLLocationCoordinate2D coordinate, NSError *error) {
        if (error)
        {
            [NetworkErrorAlert showAlertForViewController:self];
        }
        else
        {

        }
    }];
    [self.textField resignFirstResponder];
    return true;
}

#pragma mark - UITableViewDataSource Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RegionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    Region *region = [self.regionArray objectAtIndex:indexPath.row];

    if (region.completed == true)
    {
        cell.completedButton.tag = 1;
        [cell.completedButton setBackgroundImage:[UIImage imageNamed:tsHasVisitiedImage] forState:UIControlStateNormal];
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
        [Region createRegion:self.alertTextField.text withGeoPoint:nil compeletion:^(Region *newRegion, NSError *error) {

            if (error)
            {
                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
            }
            else
            {
                
            }
        }];
    }
}

#pragma mark - Button Action
- (IBAction)onButtonPressedPlaceMarker:(UIButton *)sender
{
    //TODO: Need to store the SearchePlacemark elseWhere
//    CLPlacemark *placemark = [self.mapModel returnSearchedPlacemark];
//    [self placeMarker:placemark.location.coordinate string:placemark.description];
}

- (IBAction)addSelectedLocationOnPressed:(UIButton *)sender
{

}

- (IBAction)onPressedGoToUserLocation:(UIButton *)sender
{
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
        [sender setBackgroundImage:[UIImage imageNamed:tsHasVisitiedImage] forState:UIControlStateNormal];
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











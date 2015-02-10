//
//  MapViewController.m
//  TSApp
//
//  Created by Rich Fellure on 10/6/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

//TODO: Go through all error message handling

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h> 
#import "User.h"
#import "MapModel.h"
#import "RegionListViewController.h"
#import "Location.h"
#import "Region.h"
#import "NetworkErrorAlert.h"
#import "UserDefaults.h"
#import "UniversalRegion.h"
#import "Direction.h"
#import "LocationsListViewController.h"

static NSString *const kStoryboardID = @"Main";

@interface MapViewController ()<GMSMapViewDelegate, UITextFieldDelegate, LocationsListVCDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *regionBarButtonItem;
@property GMSMapView *mapView;
@property NSMutableArray *locationsArray;
@property NSMutableArray *markers;
@property RegionListViewController *regionListVC;
@property Region *currentRegion;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBottomeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property CGFloat startingImageViewConstant;
@property CGFloat startingContainerBottomConstant;
@property CGPoint panStartPoint;
@property (weak, nonatomic) IBOutlet UIImageView *slidingImageView;
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@end

@implementation MapViewController

static NSString *const kNotVisitedImage = @"PlacHolderImage";
static NSString *const kHasVisitedImage = @"CheckMarkImage";
static NSString *const rwfLocationString = @"Tap to save destination";
static NSString *const kUpArrowImage = @"TSOrangeUpArrow";
static NSString *const kDownArrowImage = @"TSOrangeDownArrow";
static CGFloat const kConstraintConstantBuffer = 40.0;
static CGFloat const kImageViewConstraintConstantOpen = 70.0;
static CGFloat const kMapZoom = 10.0;
static CGFloat const kAnimationDuration = 0.5;
static NSString *const kDefaultRegion = @"defaultRegion";
static NSString *const kNewLocationNotification = @"NewLocationNotification";
static float const kMapLocationZoom = 20.0;

+(MapViewController *)storyboardInstanceOfMapVC
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboardID bundle:nil];
    MapViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    return mapVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setup];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:true];
    [self queryForTrip];
}

#pragma mark - Helper Methods

-(void)setup
{
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestAlwaysAuthorization];
    self.locationsArray = [NSMutableArray array];
    self.mapView = [[GMSMapView alloc] initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.markers = [NSMutableArray array];

    [self.mapView animateToZoom:kMapZoom];
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    self.regionBarButtonItem.tag = 0;

    self.imageViewTopConstraint.constant = self.view.frame.size.height - kConstraintConstantBuffer;
    self.containerBottomeConstraint.constant = -self.view.frame.size.height + kConstraintConstantBuffer;
    self.startingContainerBottomConstant = self.containerBottomeConstraint.constant;
    self.startingImageViewConstant = self.imageViewTopConstraint.constant;
    self.slidingImageView.image = [UIImage imageNamed:kUpArrowImage];
    [[NSNotificationCenter defaultCenter]addObserverForName:@"ChangeLocationNotification" object:nil queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *note) {

    }];

}

-(void)placeMarker:(PFGeoPoint *)geoPoint string: (NSString *)string
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    Location *location = [self locationForCoordinate:coordinate];
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    marker.map = self.mapView;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.tappable = YES;
    if (location.address == nil)
    {
        
    }
    marker.title = location ? location.name : @"Tap to create new destination" ;
    marker.snippet = location ? location.address : string;
    marker.icon = [location.hasVisited isEqualToNumber:@0] ? [GMSMarker markerImageWithColor:[UIColor redColor]] : [GMSMarker markerImageWithColor:[UIColor blueColor]];

    [self.mapView setSelectedMarker:marker];
}

-(void)queryForTrip
{
    if ([NSUserDefaults.standardUserDefaults objectForKey:kDefaultRegion] != nil)
    {
        [UserDefaults getDefaultRegionWithBlock:^(Region *region, NSError *error) {
            if (error == nil && region != nil)
            {
                self.title = region.name;
                self.currentRegion = region;

                UniversalRegion *sharedRegion = [UniversalRegion sharedRegion];
                sharedRegion.region = region;
                CLLocationCoordinate2D destinationCoordinate = CLLocationCoordinate2DMake(region.destinationPoint.latitude, region.destinationPoint.longitude);
                [self.mapView animateToLocation:destinationCoordinate];
                [self performQueryForLocationsWithRegion:region];

            }
            else
            {
                [NetworkErrorAlert showAlertForViewController:self];
            }
        }];

    }
    else
    {
        [self.mapView animateToLocation:self.mapView.myLocation.coordinate];
    }

}

-(void)performQueryForLocationsWithRegion: (Region *)theRegion
{

    [Location queryForLocations:theRegion completed:^(NSArray *locations, NSError *error) {
        if (error == nil)
        {
            self.locationsArray = [locations mutableCopy];
            UniversalRegion *sharedRegion = [UniversalRegion sharedRegion];
            sharedRegion.locations = locations;
            for (Location *location in locations)
            {
                [self placeMarker:location.coordinate string:location.name];
            }
        }
        else
        {
            //TODO: Here is where two alerts are being shown if there is a network error
            [NetworkErrorAlert showAlertForViewController:self];
        }
    }];
}

#pragma mark - GMSMapViewDelegate Methods

-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [MapModel reverseGeoCode:coordinate withBlock:^(GMSReverseGeocodeResponse *response, NSError *error) {
        if (error)
        {
            [NetworkErrorAlert showAlertForViewController:self];
        }
        else
        {
            PFGeoPoint *geoPoint = [[PFGeoPoint alloc]init];
            geoPoint.latitude = response.firstResult.coordinate.latitude;
            geoPoint.longitude = response.firstResult.coordinate.longitude;

            [self refreshMarkers];
            [self placeMarker:geoPoint string:response.firstResult.thoroughfare];
        }
    }];
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{

    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(marker.position.latitude, marker.position.longitude);
    Location *location = [self locationForCoordinate:coordinate];
    marker.snippet = location.address ? location.address : @"No address";
    marker.tappable = true;
    return false;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    [self displayAlertToCreateNewLocation:marker.position];
}

-(void)displayAlertToCreateNewLocation: (CLLocationCoordinate2D) coordinate
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Do you want to save this location?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"New Destination's name";
    }];
    UIAlertAction *saveAction =[UIAlertAction actionWithTitle:@"SAVE" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        UITextField *nameTextfield = [alert.textFields firstObject];
        [self reverseGeocodeCoordinate:coordinate andName:nameTextfield.text];

    }];
    [alert addAction:saveAction];

    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:noAction];

    [self presentViewController:alert animated:true completion:nil];
}

-(void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate andName:(NSString *)theName
{
    [MapModel reverseGeoCode:coordinate withBlock:^(GMSReverseGeocodeResponse *response, NSError *error) {
        if (error)
        {
            [NetworkErrorAlert showAlertForViewController:self];
        }
        else
        {
            [self createNewLocationWithName:theName andAddress:response.firstResult.thoroughfare andCoordinate:coordinate];
        }
    }];
}

-(void)createNewLocationWithName:(NSString *)theName andAddress:(NSString *)theAddress andCoordinate:(CLLocationCoordinate2D)coordinate
{
    [Location createLocation:coordinate andName:theName array:self.locationsArray currentRegion:self.currentRegion andAddress:theAddress completion:^(Location *theLocation, NSError *error) {

        if (error)
        {
            [NetworkErrorAlert showAlertForViewController:self];
        }
        else
        {
            [self.locationsArray addObject:theLocation];
            [self refreshMarkers];
            [[NSNotificationCenter defaultCenter]postNotificationName:kNewLocationNotification object:nil];
        }
    }];

}

#pragma mark - TextFieldDelegate methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [MapModel geocodeString:textField.text withBlock:^(CLLocationCoordinate2D coordinate, NSError *error) {
        if (error) {
            [NetworkErrorAlert showAlertForViewController:self];
        }
        else
        {
            [self.mapView animateToLocation:coordinate];
            [self.mapView animateToZoom:kMapLocationZoom];
            [self placeMarker:[PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude] string:@"Tap to save destination"];
        }
    }];
    [textField resignFirstResponder];
    return true;
}

#pragma mark - IBAction and methods to control the sliding of the container view
- (IBAction)onArrowTapped:(UITapGestureRecognizer *)sender {
    if ([sender locationInView:self.view].y > self.view.frame.size.height / 2) {
        [self animateContainerUp];
    }
    else {
        [self animateContainerDown];
    }
}

-(void)animateContainerUp {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.containerBottomeConstraint.constant = 0;
        self.imageViewTopConstraint.constant = kImageViewConstraintConstantOpen;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.slidingImageView.image = [UIImage imageNamed:kDownArrowImage];
    }];
}

-(void)animateContainerDown {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.containerBottomeConstraint.constant = -self.view.frame.size.height + kConstraintConstantBuffer;
        self.imageViewTopConstraint.constant = self.view.frame.size.height - kConstraintConstantBuffer;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.slidingImageView.image = [UIImage imageNamed:kUpArrowImage];
    }];
}

-(Location *)locationForCoordinate:(CLLocationCoordinate2D)coordinate
{
    for (Location *location in self.locationsArray)
    {
        CLLocationCoordinate2D locationsCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        if (locationsCoordinate.latitude ==  coordinate.latitude && locationsCoordinate.longitude == coordinate.longitude)
        {
             return location;
        }
    }
    return nil;
}

-(void)refreshMarkers
{
    [self.mapView clear];
    for (Location *location in self.locationsArray)
    {
        [self placeMarker:location.coordinate string:location.address];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LocationListSegue"]) {
        LocationsListViewController *locationVC = segue.destinationViewController;
        locationVC.delegate = self;
    }
}
#pragma mark - LocationListVCDelegate Methods

-(void)didMoveLocation:(Location *)movedLocation {
    [self resetAllMarkers];
}

-(void)didDeleteLocation:(Location *)deletedLocation {
    [self.locationsArray removeObject:deletedLocation];
    [self resetAllMarkers];
}

-(void)didAddNewLocation:(Location *)newLocation {
    [self.locationsArray addObject:newLocation];
    [self resetAllMarkers];
}

-(void)didGetNewDirections:(NSArray *)directions {
    [self resetAllMarkers];
    GMSMutablePath *path = [GMSMutablePath path];

    for (Direction *direction in directions)
    {
        [path addLatitude:direction.startingLatitude longitude:direction.startingLongitude];
        [path addLatitude:direction.endingLatitude longitude:direction.endingLongitude];
    }

    GMSPolyline *polyLine = [GMSPolyline polylineWithPath:path];
    polyLine.strokeWidth = 5.0;
    polyLine.map = self.mapView;
}

#pragma  mark -resetAllMarkers method
-(void)resetAllMarkers {
    
    [self.mapView clear];
    for (Location *location in self.locationsArray) {
        [self placeMarker:location.coordinate string:location.name];
    }
}

@end

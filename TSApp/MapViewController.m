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
#import "CDLocation.h"
#import "TSMarker.h"
#import "AppDelegate.h"

static NSString *const kStoryboardID = @"Main";

@interface MapViewController ()<GMSMapViewDelegate, UITextFieldDelegate, LocationsListVCDelegate, RegionListVCDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *regionBarButtonItem;
@property GMSMapView *mapView;
@property NSMutableArray *locationsArray;
@property NSMutableArray *markers;
@property RegionListViewController *regionListVC;
@property CDRegion *currentRegion;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBottomeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property CGFloat startingImageViewConstant;
@property CGFloat startingContainerBottomConstant;
@property CGPoint panStartPoint;
@property (weak, nonatomic) IBOutlet UIImageView *slidingImageView;
@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property LocationsListViewController *locationsVC;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];

    [self fetchDefaultRegion];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:true];
    self.title = self.currentRegion ? self.currentRegion.name : @"TravelSages";
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
}

-(void)placeMarker:(CLLocationCoordinate2D)coordinate string: (NSString *)string
{
    TSMarker *marker = [[TSMarker alloc]initWithPosition:coordinate withSnippet:string forMap:self.mapView];
    [self.mapView setSelectedMarker:marker];
}

-(void)placeMarkerForLocation:(CDLocation *)location {
    TSMarker *marker = [[TSMarker alloc]initWithLocation:location];
    marker.map = self.mapView;
    [self.mapView setSelectedMarker:marker];
}

-(void)fetchDefaultRegion {
    [UserDefaults getDefaultRegionWithBlock:^(CDRegion *region, NSError *error) {
        self.currentRegion = region;
        self.title = region.name;
        [self.locationsVC giveCurrentRegion:region];
        [self resetAllMarkers];
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
            [self resetAllMarkers];
            [self placeMarker:response.firstResult.coordinate string:response.firstResult.thoroughfare];
        }
    }];
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    TSMarker *theMarker = (TSMarker *)marker;
    NSLog(@"%@", theMarker.location);
    if (!theMarker.location) {
        [self displayAlertToCreateNewLocation:marker.position];
    }
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

    [CDLocation createNewLocationWithName:theName atCoordinate:coordinate atIndex:@0 forRegion:self.currentRegion atAddress:theAddress completion:^(CDLocation *location, BOOL result) {
        [self resetAllMarkers];
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
            [self placeMarker:coordinate string:@"Tap to save destination"];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LocationListSegue"]) {
        self.locationsVC = segue.destinationViewController;
        self.locationsVC.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"RegionList"]) {
        RegionListViewController *regionVC = segue.destinationViewController;
        regionVC.delegate = self;
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
    for (CDLocation *location in self.currentRegion.allLocations) {
        [self placeMarkerForLocation:location];
    }
}

#pragma mark- RegionsListVCDelegate
-(void)regionListVC:(RegionListViewController *)viewController selectedRegion:(CDRegion *)region {
    self.currentRegion = region;
    [self.mapView animateToLocation:region.coordinate];
    [self resetAllMarkers];
}

@end

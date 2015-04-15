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
#import "Direction.h"
#import "LocationsListViewController.h"
#import "CDLocation.h"
#import "TSMarker.h"
#import "DirectionsViewController.h"
#import "DirectionSet.h"

static NSString *const kStoryboardID = @"Main";

@interface MapViewController ()<GMSMapViewDelegate, UITextFieldDelegate, LocationsListVCDelegate, RegionListVCDelegate>

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UIBarButtonItem *regionBarButtonItem;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBottomeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *slidingImageView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *searchView;

#pragma mark - Variables
@property (nonatomic) CDRegion *currentRegion;
@property CGFloat startingImageViewConstant;
@property CGFloat startingContainerBottomConstant;
@property CGPoint panStartPoint;
@property CLLocationManager *locationManager;
@property GMSMapView *mapView;
@property NSMutableArray *locationsArray;
@property NSMutableArray *markers;
@property RegionListViewController *regionListVC;

@end

@implementation MapViewController

static NSString *const kNotVisitedImage = @"PlacHolderImage";
static NSString *const kHasVisitedImage = @"CheckMarkImage";
static NSString *const rwfLocationString = @"Tap to save destination";
static CGFloat const kMapZoom = 10.0;
static float const kMapLocationZoom = 20.0;

#pragma mark - Getters and Setters
-(void)setCurrentRegion:(CDRegion *)currentRegion {
    _currentRegion = currentRegion;
    [self resetAllMarkers];
}

#pragma mark - View LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    [self fetchDefaultRegion];
    [self setupNotificationListeners];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:true];
    self.title = self.currentRegion ? self.currentRegion.name : @"TravelSages";
    self.segmentControl.selectedSegmentIndex = 0;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ListSegue"]) {
        UINavigationController *navVC = segue.destinationViewController;
        LocationsListViewController * locationsVC = navVC.childViewControllers.firstObject;
        locationsVC.delegate = self;
        locationsVC.currentRegion = self.currentRegion;
    }
    else if([segue.destinationViewController isKindOfClass: [RegionListViewController class]]) {
        RegionListViewController *regionVC = segue.destinationViewController;
        regionVC.delegate = self;
    }
}

#pragma mark - Helper Methods

-(void)setup
{
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestAlwaysAuthorization];
    self.locationsArray = [NSMutableArray array];
    self.mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.searchView.frame), CGRectGetMaxY(self.searchView.frame), CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.searchView.frame))];
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.markers = [NSMutableArray array];

    [self.mapView animateToZoom:kMapZoom];
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];

    self.imageViewTopConstraint.constant = self.view.frame.size.height - self.slidingImageView.frame.size.height;
    self.containerBottomeConstraint.constant = -self.view.frame.size.height + self.slidingImageView.frame.size.height;
    self.startingContainerBottomConstant = self.containerBottomeConstraint.constant;
    self.startingImageViewConstant = self.imageViewTopConstraint.constant;
    self.slidingImageView.image = [UIImage imageNamed:kUpArrowImage];
}

-(void)setupNotificationListeners {
    [[NSNotificationCenter defaultCenter] addObserverForName:kSelectedDirectionNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSDictionary *info = note.userInfo;
        DirectionSet *dSet = info[kDirectionSetKey];
        [self placePolylineForDirections:dSet.directionsArray];
    }];
}

-(void)placeMarker:(CLLocationCoordinate2D)coordinate string: (NSString *)string
{
    TSMarker *marker = [[TSMarker alloc]initWithPosition:coordinate withSnippet:string forMap:self.mapView];
    [self.mapView setSelectedMarker:marker];
}

-(void)placeMarkerForLocation:(CDLocation *)location {
    TSMarker *marker = [[TSMarker alloc]initWithLocation:location];
    marker.map = self.mapView;
}

-(void)fetchDefaultRegion {
    [CDRegion getDefaultRegionWithBlock:^(CDRegion *region, NSError *error) {
        self.currentRegion = region;
        self.title = region.name;
        [self animateMapViewToRegion:region];
    }];
}

-(void)animateMapViewToRegion:(CDRegion *)region {
    if (region.allLocations.count > 0) {
        GMSCoordinateBounds *bounds = [GMSCoordinateBounds new];
        for (CDLocation *location in region.allLocations) {
            bounds = [bounds includingCoordinate:location.coordinate];
        }
//        GMSCameraPosition *cameraPos = [self.mapView cameraForBounds:bounds insets:UIEdgeInsetsZero];
        [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0]];
    }
    else {
        [self.mapView animateToLocation:region.coordinate];
        [self.mapView animateToZoom:12.0];
    }
}

-(void)placePolylineForDirections:(NSArray *)directions {
    [self resetAllMarkers];
    GMSMutablePath *path = [GMSMutablePath path];

    for (Direction *direction in directions)
    {
        [path addCoordinate:direction.startingCoordinate];
        [path addCoordinate:direction.endingCoordinate];
    }

    GMSPolyline *polyLine = [GMSPolyline polylineWithPath:path];
    polyLine.strokeWidth = 5.0;
    polyLine.map = self.mapView;
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

#pragma mark - IBActions
- (IBAction)onArrowTapped:(UITapGestureRecognizer *)sender {
    if ([sender locationInView:self.view].y > self.view.frame.size.height / 2) {
        [self animateContainerUp];
    }
    else {
        [self animateContainerDown];
    }
}

- (IBAction)segementSelectOnTap:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        [self performSegueWithIdentifier:@"ListSegue" sender:nil];
    }
}


#pragma mark - Helper Methods for sliding of the container view

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
        self.containerBottomeConstraint.constant = -self.view.frame.size.height + self.slidingImageView.frame.size.height;
        self.imageViewTopConstraint.constant = self.view.frame.size.height - self.slidingImageView.frame.size.height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.slidingImageView.image = [UIImage imageNamed:kUpArrowImage];
    }];
}

#pragma mark - LocationListVCDelegate Methods
-(void)locationListVC:(LocationsListViewController *)viewController didChangeLocation:(CDLocation *)location {
    [self resetAllMarkers];
}

-(void)didGetNewDirections:(NSArray *)directions {
    [self placePolylineForDirections:directions];
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
}

@end

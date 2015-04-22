//
//  MapViewController.m
//  TSApp
//
//  Created by Rich Fellure on 10/6/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

//TODO: Go through all error message handling
//TODO: Need to go through and clean up the headers, this is a mess, lets make it cleaner, and smarter. Shouldn't need this many imports.

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
#import "YPBusiness.h"
#import "SearchTableViewController.h"


@interface MapViewController ()<GMSMapViewDelegate, UITextFieldDelegate, LocationsListVCDelegate, RegionListVCDelegate, SearchTableViewDelegate>

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UIBarButtonItem *regionBarButtonItem;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *slidingImageView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *directionsTopConstraint;

#pragma mark - Variables
@property (nonatomic) CDRegion *currentRegion;
@property CGFloat startingImageViewConstant;
@property CGFloat startingContainerBottomConstant;
@property CGPoint panStartPoint;
@property CLLocationManager *locationManager;
@property GMSMapView *mapView;
@property RegionListViewController *regionListVC;
@property NSMutableArray *businessesPlaced;
@property SearchTableViewController *searchVC;
@property NSMutableArray *markerArray;

@end

@implementation MapViewController

#pragma mark - local constant variables
static NSString *const kNotVisitedImage = @"PlacHolderImage";
static NSString *const kHasVisitedImage = @"CheckMarkImage";
static NSString *const rwfLocationString = @"Tap to save destination";


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
    self.markerArray = [NSMutableArray array];
    self.businessesPlaced = [NSMutableArray new];
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestAlwaysAuthorization];
    self.mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.searchView.frame), CGRectGetMaxY(self.searchView.frame), CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.searchView.frame))];
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;

    [self.mapView animateToZoom:kMapViewZoom];
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];

    self.imageViewTopConstraint.constant = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.slidingImageView.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame);
    self.containerBottomConstraint.constant = -self.view.frame.size.height + self.slidingImageView.frame.size.height;
    self.startingContainerBottomConstant = self.containerBottomConstraint.constant;
    self.startingImageViewConstant = self.imageViewTopConstraint.constant;
    self.slidingImageView.image = [UIImage imageNamed:kUpArrowImage];
}

-(void)setupNotificationListeners {
    [[NSNotificationCenter defaultCenter] addObserverForName:kSelectedDirectionNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSDictionary *info = note.userInfo;
        NSArray *directions = info[kDirectionArrayKey];
        [self placePolylineForDirections:directions];
    }];
}

-(void)placeMarker:(CLLocationCoordinate2D)coordinate string: (NSString *)string
{
    TSMarker *marker = [[TSMarker alloc]initWithPosition:coordinate withSnippet:string forMap:self.mapView];
    marker.icon = [GMSMarker markerImageWithColor:[UIColor customOrange]];
    [self.mapView setSelectedMarker:marker];
}

-(void)placeMarkerForLocation:(CDLocation *)location {
    [self markerCreate:nil orLocation:location];
}

-(void)placeMarkerForBusiness:(YPBusiness *)business {
    [self markerCreate:business orLocation:nil];
    [self.businessesPlaced addObject:business];
}

-(void)markerCreate:(YPBusiness *)business orLocation:(CDLocation *)location {
    TSMarker *marker = business ? [[TSMarker alloc]initWithBusiness:business] : [[TSMarker alloc]initWithLocation:location];
    marker.map = self.mapView;
    [self.markerArray addObject:marker];
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
        [self animateMapViewToLocations:region.allLocations];
    }
    else {
        [self.mapView animateToLocation:region.coordinate];
        [self.mapView animateToZoom:kMapViewZoom];
    }
}

-(void)animateMapViewToLocations:(NSArray *)locations {
    GMSCoordinateBounds *bounds = [GMSCoordinateBounds new];
    for (CDLocation *location in locations) {
        bounds = [bounds includingCoordinate:location.coordinate];
    }
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:kMapViewPadding]];
}

-(void)animateMapViewToDirections:(NSArray *)directions {
    GMSCoordinateBounds *bounds = [GMSCoordinateBounds new];
    for (Direction *direction in directions) {
        bounds = [bounds includingCoordinate:direction.startingCoordinate];
        bounds = [bounds includingCoordinate:direction.endingCoordinate];
    }
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:kMapViewPadding]];
}

-(void)placePolylineForDirections:(NSArray *)directions {
    [self resetAllMarkers];
    GMSMutablePath *path = [GMSMutablePath path];

    for (Direction *direction in directions) {
        [path addCoordinate:direction.startingCoordinate];
        [path addCoordinate:direction.endingCoordinate];
    }

    GMSPolyline *polyLine = [GMSPolyline polylineWithPath:path];
    polyLine.strokeWidth = kMapViewPolylineWidth;
    polyLine.map = self.mapView;

    [self animateMapViewToDirections:directions];
}

#pragma mark - GMSMapViewDelegate Methods

-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [MapModel reverseGeoCode:coordinate withBlock:^(GMSReverseGeocodeResponse *response, NSError *error) {
        if (!response) {
            [NetworkErrorAlert showAlertForViewController:self];
        }
        else {
            [self resetAllMarkers];
            [self placeMarker:response.firstResult.coordinate string:response.firstResult.thoroughfare];
        }
    }];
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    TSMarker *theMarker = (TSMarker *)marker;
    if (theMarker.business) {
        [self displayAlertToCreateNewLocation:theMarker.position orBusiness: theMarker.business];
    }
    if (!theMarker.location) {
        [self displayAlertToCreateNewLocation:marker.position orBusiness:nil];
    }
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    [YPBusiness fetchBusinessesFromYelpForBounds:mapView.projection.visibleRegion.farLeft andSEBounds:mapView.projection.visibleRegion.nearRight andCompareAgainstBusinesses:self.businessesPlaced completed:^(NSArray *businesses) {
                                           for (YPBusiness *business in businesses) {
                                               [self placeMarkerForBusiness:business];
        }
    }];

}

#pragma mark - Map related helper methods

-(void)displayAlertToCreateNewLocation: (CLLocationCoordinate2D) coordinate orBusiness:(YPBusiness *)business
{
    NSString *message = business ? business.address : nil;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Do you want to save this location?"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    if (!business) {
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"New Destination's name";
        }];
    }

    UIAlertAction *saveAction =[UIAlertAction actionWithTitle:@"SAVE"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {

                                                          if (business) {
                                                              [CDLocation createNewLocationWithName:business.name
                                                                                       atCoordinate:business.coordinate
                                                                                            atIndex:[NSNumber numberWithInteger: self.currentRegion.allLocations.count]
                                                                                          forRegion:self.currentRegion atAddress:business.address
                                                                                         completion:^(CDLocation *location, BOOL result) {
                                                                                             [self resetAllMarkers];
            }];
        }
        else {
            UITextField *nameTextfield = [alert.textFields firstObject];
            [self reverseGeocodeCoordinate:coordinate andName:nameTextfield.text];
        }
    }];
    [alert addAction:saveAction];

    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:noAction];

    [self presentViewController:alert animated:true completion:nil];
}

-(void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate andName:(NSString *)theName
{
    [MapModel reverseGeoCode:coordinate withBlock:^(GMSReverseGeocodeResponse *response, NSError *error) {
        if (!response)
        {
            [NetworkErrorAlert showAlertForViewController:self];
        }
        else
        {
            [CDLocation createNewLocationWithName:theName
                                     atCoordinate:coordinate
                                          atIndex:@0
                                        forRegion:self.currentRegion
                                        atAddress:response.firstResult.thoroughfare
                                       completion:^(CDLocation *location, BOOL result) {
                                            [self resetAllMarkers];
            }];
        }
    }];
}

-(void)resetAllMarkers {
    [self.mapView clear];
    for (YPBusiness *business in self.businessesPlaced) {
        [self markerCreate:business orLocation:nil];
    }
    for (CDLocation *location in self.currentRegion.allLocations) {
        [self placeMarkerForLocation:location];
    }
}

#pragma mark - TextFieldDelegate methods
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    SearchTableViewController *searchVC = [[SearchTableViewController alloc] initFromCallerFrame:self.searchView.frame];
    self.searchVC = searchVC;
    self.searchVC.businesses = self.businessesPlaced;
    self.searchVC.locations = self.currentRegion.allLocations;
    self.searchVC.delegate = self;
    [self.view addSubview:searchVC.view];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self.searchVC inputText:textField.text];
    return true;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [MapModel geocodeString:textField.text withBlock:^(CLLocationCoordinate2D coordinate, NSError *error) {
        if (error) {
            [NetworkErrorAlert showAlertForViewController:self];
        }
        else {
            [self.mapView animateToLocation:coordinate];
            [self.mapView animateToZoom:kMapViewZoom];
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
        self.containerBottomConstraint.constant = 0;
        self.imageViewTopConstraint.constant = kImageViewConstraintConstantOpen;
        self.directionsTopConstraint.constant = -CGRectGetHeight(self.slidingImageView.frame);
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.slidingImageView.image = [UIImage imageNamed:kDownArrowImage];
    }];
}

-(void)animateContainerDown {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.containerBottomConstraint.constant = -self.view.frame.size.height + self.slidingImageView.frame.size.height;
        self.imageViewTopConstraint.constant = self.startingImageViewConstant;
        self.directionsTopConstraint.constant = 1.0;
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

#pragma mark- RegionsListVCDelegate
-(void)regionListVC:(RegionListViewController *)viewController selectedRegion:(CDRegion *)region {
    self.currentRegion = region;
    [self.mapView animateToLocation:region.coordinate];
}

#pragma mark - SearchTableViewDelegate
-(void)searchTableVC:(SearchTableViewController *)viewController didSelectASearchOption:(SelectionType)type forEitherBusiness:(YPBusiness *)business orLocation:(CDLocation *)location {
    switch (type) {
        case Select_Location:
            [self animateToLocation:location];
            break;
        case Select_Business:
            [self animateToBusiness:business];
            break;

        default:
            break;
    }

    [UIView animateWithDuration:0.0 animations:^{
        self.searchVC.view.frame = CGRectMake(CGRectGetMinX(self.searchVC.view.frame), CGRectGetMinY(self.searchVC.view.frame), CGRectGetWidth(self.searchVC.view.frame), 0.0);
    } completion:^(BOOL finished) {
        [self.searchVC.view removeFromSuperview];
    }];
    [self.searchTextField resignFirstResponder];
}

-(void)animateToLocation:(CDLocation *)location {
    for (TSMarker *marker in self.markerArray) {
        if (marker.location != nil) {
            if ([marker.location.objectId isEqualToString:location.objectId]) {
                [self.mapView animateToLocation:location.coordinate];
                [self.mapView setSelectedMarker:marker];
            }
        }
    }
}

-(void)animateToBusiness:(YPBusiness *)business {
    for (TSMarker *marker in self.markerArray) {
        if (marker.business != nil) {
            if ([marker.business.businessId isEqualToString:business.businessId]) {
                [self.mapView animateToLocation:business.coordinate];
                [self.mapView setSelectedMarker:marker];
            }
        }
    }
}

@end

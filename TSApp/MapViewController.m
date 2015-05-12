//
//  MapViewController.m
//  TSApp
//
//  Created by Rich Fellure on 10/6/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

//TODO: Go through all error message handling
//TODO: Need to go through and clean up the headers, this is a mess, lets make it cleaner, and smarter. Shouldn't need this many imports.
//TODO: Refine search so that it pulls from Yelp and makes calls with the text that has been entered. Could even go ahead, and add these to the map as they are searched for.
//TODO: setup the grids for the map

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>
#import "User.h"
#import "MapModel.h"
#import "RegionListViewController.h"
#import "Alert.h"
#import "UserDefaults.h"
#import "Direction.h"
#import "LocationsListViewController.h"
#import "CDLocation.h"
#import "TSMarker.h"
#import "DirectionsViewController.h"
#import "DirectionSet.h"
#import "Business.h"
#import "SearchTableViewController.h"



@interface MapViewController ()<GMSMapViewDelegate, UISearchBarDelegate, LocationsListVCDelegate, RegionListVCDelegate, SearchTableViewDelegate>

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UIBarButtonItem *regionBarButtonItem;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *slidingImageView;
//@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *directionsTopConstraint;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *closeBarButton;


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
@property NSMutableArray *businessMarkers;
@property NSMutableArray *locationMarkers;
@property TSMarker *longTapMarker;

@end

@implementation MapViewController

#pragma mark - local constant variables
static NSString *const kNotVisitedImage = @"PlacHolderImage";
static NSString *const kHasVisitedImage = @"CheckMarkImage";
static NSString *const rwfLocationString = @"Tap to save destination";


#pragma mark - Getters and Setters
-(void)setCurrentRegion:(CDRegion *)currentRegion {
    _currentRegion = currentRegion;
    [self resetAllLocationMarkers];
}

#pragma mark - View LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    BOOL hasBeenRun = [[NSUserDefaults standardUserDefaults] boolForKey:kHasBeenRun];
    if (!hasBeenRun) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(41.878483, -87.638772);
        [self.mapView animateToLocation:coordinate];
    }
    else {
        [self fetchDefaultRegion];
    }
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
    self.locationMarkers = [NSMutableArray array];
    self.businessMarkers = [NSMutableArray array];
    self.businessesPlaced = [NSMutableArray new];
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestAlwaysAuthorization];
    self.mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.searchView.frame),
                                                                CGRectGetMaxY(self.searchView.frame),
                                                                CGRectGetWidth(self.view.frame),
                                                                CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.searchView.frame))];
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;

    [self.mapView animateToZoom:kMapViewZoom];
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];

    self.imageViewTopConstraint.constant = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.slidingImageView.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame);
    self.containerBottomConstraint.constant = -CGRectGetHeight(self.view.frame) + CGRectGetHeight(self.slidingImageView.frame);
    self.startingContainerBottomConstant = self.containerBottomConstraint.constant;
    self.startingImageViewConstant = self.imageViewTopConstraint.constant;
    self.slidingImageView.image = [UIImage imageNamed:kUpArrowImage];
}

-(void)setupNotificationListeners {
    [[NSNotificationCenter defaultCenter] addObserverForName:kSelectedDirectionNotification
                                                      object:nil queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        NSDictionary *info = note.userInfo;
        NSArray *directions = info[kDirectionArrayKey];
        [self placePolylineForDirections:directions];
    }];

    [[NSNotificationCenter defaultCenter]addObserverForName:kCreatedFirstTrip
                                                     object:nil
                                                      queue:[NSOperationQueue mainQueue]
                                                 usingBlock:^(NSNotification *note) {
        [self fetchDefaultRegion];
    }];
}

-(void)placeMarker:(CLLocationCoordinate2D)coordinate string: (NSString *)string {
    TSMarker *marker = [[TSMarker alloc]initWithPosition:coordinate
                                             withSnippet:string
                                                  forMap:self.mapView];
    marker.icon = [GMSMarker markerImageWithColor:[UIColor customOrange]];
    [self.mapView setSelectedMarker:marker];
    self.longTapMarker.map = nil;
    self.longTapMarker = marker;
}

-(void)placeMarkerForLocation:(CDLocation *)location {
    [self markerCreate:nil orLocation:location setMarker:false];
}

-(void)placeMarkerForBusiness:(Business *)business setMarker:(BOOL)isSet {
    [self markerCreate:business orLocation:nil setMarker:isSet];
    [self.businessesPlaced addObject:business];
}

-(void)markerCreate:(Business *)business orLocation:(CDLocation *)location setMarker:(BOOL)isSet{
    TSMarker *marker = business ? [[TSMarker alloc]initWithBusiness:business] : [[TSMarker alloc]initWithLocation:location];
    marker.map = self.mapView;
    if (business) {
        [self.businessMarkers addObject:marker];
    }
    else {
        [self.locationMarkers addObject:marker];
    }

    if (isSet) {
        [self.mapView setSelectedMarker:marker];
    }
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
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds
                                                         withPadding:kMapViewPadding]];
}

-(void)animateMapViewToDirections:(NSArray *)directions {
    GMSCoordinateBounds *bounds = [GMSCoordinateBounds new];
    for (Direction *direction in directions) {
        bounds = [bounds includingCoordinate:direction.startingCoordinate];
        bounds = [bounds includingCoordinate:direction.endingCoordinate];
    }
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds
                                                         withPadding:kMapViewPadding]];
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
            [Alert showAlertForViewController:self];
        }
        else {
            [self placeMarker:response.firstResult.coordinate
                       string:response.firstResult.thoroughfare];
        }
    }];
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    if (self.currentRegion) {
        TSMarker *theMarker = (TSMarker *)marker;
        [self displayAlertToCreateNewLocation:theMarker.position
                                   orBusiness:theMarker.business
                                    forMarker:theMarker];
    }
    else {

    }

}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    [Business fetchBusinessesFromYelpForBounds:mapView.projection.visibleRegion.farLeft
                                   andSEBounds:mapView.projection.visibleRegion.nearRight
                   andCompareAgainstBusinesses:self.businessesPlaced
                                     completed:^(NSArray *businesses) {
                                           for (Business *business in businesses) {
                                               [self placeMarkerForBusiness:business setMarker:false];
        }
    }];

}

#pragma mark - Map related helper methods

-(void)displayAlertToCreateNewLocation: (CLLocationCoordinate2D) coordinate orBusiness:(Business *)business forMarker:(TSMarker *) marker
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
                                                                                             [self resetAllLocationMarkers];
            }];
        }
        else {
            UITextField *nameTextfield = [alert.textFields firstObject];
            [self reverseGeocodeMarker:marker andName:nameTextfield.text];
        }
    }];
    [alert addAction:saveAction];

    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:noAction];

    [self presentViewController:alert animated:true completion:nil];
}

-(void)reverseGeocodeMarker:(TSMarker *)marker andName:(NSString *)theName
{
    [MapModel reverseGeoCode:marker.position withBlock:^(GMSReverseGeocodeResponse *response, NSError *error) {
        if (!response)
        {
            [Alert showAlertForViewController:self];
        }
        else
        {
            [CDLocation createNewLocationWithName:theName
                                     atCoordinate:marker.position
                                          atIndex:@0
                                        forRegion:self.currentRegion
                                        atAddress:response.firstResult.thoroughfare
                                       completion:^(CDLocation *location, BOOL result) {
                                           marker.map = nil;
                                            [self resetAllLocationMarkers];
            }];
        }
    }];
}

-(void)resetAllLocationMarkers {
    for (TSMarker *marker in self.locationMarkers) {
        marker.map = nil;
    }
    for (CDLocation *location in self.currentRegion.allLocations) {
        [self placeMarkerForLocation:location];
    }
}

-(void)resetAllMarkers {
    [self.mapView clear];
    for (Business *business in self.businessesPlaced) {
        [self markerCreate:business orLocation:nil setMarker:false];
    }
    [self resetAllLocationMarkers];
}

-(void)displayAlertForNoRegion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"You need to create a Trip before you can save a Destination." message:@"Select the 'plus' button in the top right corner to create a new Trip, then you will be able to save Destinations for your trip." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:dismissAction];
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark - SearchBarDelegate methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.searchVC inputText:searchText];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchVC = [[SearchTableViewController alloc] initFromCallerFrame:self.searchView.frame];
    self.searchVC.businesses = self.businessesPlaced;
    self.searchVC.locations = self.currentRegion.allLocations;
    self.searchVC.delegate = self;
    [self.view addSubview:self.searchVC.view];
    [self.navigationItem setLeftBarButtonItem:self.closeBarButton];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [MapModel geocodeString:searchBar.text withBlock:^(CLLocationCoordinate2D coordinate, NSError *error) {
        if (error) {
            [Alert showAlertForViewController:self];
        }
        else {
            [self.mapView animateToLocation:coordinate];
            [self.mapView animateToZoom:kMapViewZoom];
            [self placeMarker:coordinate string:@"Tap to save destination"];
        }
    }];
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchVC resetArray];

    //This doesn't work like I expected, need to find the correct method for when the 'x' is tapped on the searchBar.
}

#pragma mark - IBActions
- (IBAction)onArrowTapped:(UITapGestureRecognizer *)sender {
    if ([sender locationInView:self.view].y > CGRectGetHeight(self.view.frame) / 2) {
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

- (IBAction)closeSearchTableViewOnTap:(UIBarButtonItem *)sender {
    [self animateSearchViewClosed];
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
        self.containerBottomConstraint.constant = -CGRectGetHeight(self.view.frame) + CGRectGetHeight(self.slidingImageView.frame);
        self.imageViewTopConstraint.constant = self.startingImageViewConstant;
        self.directionsTopConstraint.constant = 1.0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.slidingImageView.image = [UIImage imageNamed:kUpArrowImage];
    }];
}

#pragma mark - LocationListVCDelegate Methods
-(void)locationListVC:(LocationsListViewController *)viewController didChangeLocation:(CDLocation *)location {
    [self resetAllLocationMarkers];
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
-(void)searchTableVC:(SearchTableViewController *)viewController didSelectASearchOption:(SelectionType)type forEitherBusiness:(Business *)business orLocation:(CDLocation *)location {
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
    [self animateSearchViewClosed];
    [self.view endEditing:true];
}

-(void)animateSearchViewClosed {
    [UIView animateWithDuration:0.5 animations:^{
        self.searchVC.view.frame = CGRectMake(CGRectGetMinX(self.searchVC.view.frame),
                                              CGRectGetMinY(self.searchVC.view.frame),
                                              CGRectGetWidth(self.searchVC.view.frame),
                                              0.0);
    } completion:^(BOOL finished) {
        [self.searchVC.view removeFromSuperview];
        [self.navigationItem setLeftBarButtonItem:nil];
        [self.view endEditing:true];
    }];
}

-(void)animateToLocation:(CDLocation *)location {
    NSSet *set = [NSSet setWithArray:self.locationMarkers];
    for (TSMarker *marker in set) {
        if ([marker.location.objectId isEqualToString:location.objectId]) {
            GMSCameraPosition *cameraPos = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                                          zoom:kMapViewZoomLocation];
            [self.mapView setCamera:cameraPos];
            [self.mapView setSelectedMarker:marker];
        }
    }
}

-(void)animateToBusiness:(Business *)business {
    NSSet *set = [NSSet setWithArray:self.businessMarkers];
    BOOL isDisplayed = false;
    for (TSMarker *marker in set) {
        if ([marker.business.businessId isEqualToString:business.businessId]) {
            [self.mapView setSelectedMarker:marker];
            isDisplayed = true;
        }
    }
    if (!isDisplayed) {
        [self placeMarkerForBusiness:business setMarker:true];
    }
    GMSCameraPosition *cameraPos = [GMSCameraPosition cameraWithTarget:business.coordinate
                                                                  zoom:kMapViewZoomLocation];
    [self.mapView setCamera:cameraPos];
}

@end

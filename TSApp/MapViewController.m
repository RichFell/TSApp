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

@interface MapViewController ()<GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *regionBarButtonItem;
@property GMSMapView *mapView;
@property NSMutableArray *locationsArray;
@property CLLocationCoordinate2D selectedLocation;
@property NSMutableArray *markers;
@property NSMutableArray *directions;
@property RegionListViewController *regionListVC;
@property Region *currentRegion;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBottomeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property CGFloat startingImageViewConstant;
@property CGFloat startingContainerBottomConstant;
@property CGPoint panStartPoint;
@property (weak, nonatomic) IBOutlet UIImageView *slidingImageView;
@property CLLocationManager *locationManager;

@end

@implementation MapViewController

static NSString *const kNotVisitedImage = @"PlacHolderImage";
static NSString *const kHasVisitedImage = @"CheckMarkImage";
static NSString *const rwfLocationString = @"Current Location";
static NSString *const kUpArrowImage = @"TSOrangeUpArrow";
static NSString *const kDownArrowImage = @"TSOrangeDownArrow";
static CGFloat const kConstraintConstantBuffer = 40.0;
static CGFloat const kImageViewConstraintConstantOpen = 70.0;
static CGFloat const kMapZoom = 10.0;
static CGFloat const kAnimationDuration = 0.5;

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
    self.directions = [NSMutableArray array];
    self.mapView = [[GMSMapView alloc] initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = YES;
    NSLog(@"myLocation: %@", self.mapView.myLocation);
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

-(void)placeMarker:(PFGeoPoint *)geoPoint string: (NSString *)string
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    marker.map = self.mapView;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.tappable = YES;
    marker.title = string;

    [self.mapView setSelectedMarker:marker];
}

-(void)queryForTrip
{
    [UserDefaults getDefaultRegionWithBlock:^(Region *region, NSError *error) {
        if (error == nil && region != nil)
        {
            self.title = region.name;
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

-(void)spanToTheTripDestination
{
    
}

-(void)performQueryForLocationsWithRegion: (Region *)theRegion
{

    [Location queryForLocations:theRegion completed:^(NSArray *locations, NSError *error) {
        if (error == nil)
        {
            self.locationsArray = [locations mutableCopy];
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
            [self placeMarker:geoPoint string:rwfLocationString];
        }
    }];
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{

    //TODO: Make it so that when tap on the marker then window displays
    marker.snippet = @"snippet";
    marker.tappable = true;
    NSLog(@"Tapped on marker");
    return true;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    self.selectedLocation = marker.position;
}

#pragma mark - IBAction and methods to control the sliding of the container view
- (IBAction)didStartSlidingUpContainer:(UIPanGestureRecognizer *)sender
{
    CGPoint currentPosition;
    switch (sender.state)
    {
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = [sender locationInView:self.view];
            break;

        case UIGestureRecognizerStateChanged:
            currentPosition = [sender translationInView:self.view];
            CGFloat deltaY = self.panStartPoint.y + currentPosition.y;
            self.imageViewTopConstraint.constant = deltaY;
            self.containerBottomeConstraint.constant = -deltaY;
            break;

        case UIGestureRecognizerStateEnded:
            if (self.imageViewTopConstraint.constant < self.view.frame.size.height/2)
            {
                [self animateContainerUp];
            }
            else
            {
                [self animateContainerDown];
            }
            break;
        case UIGestureRecognizerStateCancelled:
            break;

        default:
            break;
    }
}

-(void)animateContainerUp
{
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.containerBottomeConstraint.constant = 0;
        self.imageViewTopConstraint.constant = kImageViewConstraintConstantOpen;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.slidingImageView.image = [UIImage imageNamed:kDownArrowImage];
    }];
}

-(void)animateContainerDown
{
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.containerBottomeConstraint.constant = -self.view.frame.size.height + kConstraintConstantBuffer;
        self.imageViewTopConstraint.constant = self.view.frame.size.height - kConstraintConstantBuffer;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.slidingImageView.image = [UIImage imageNamed:kUpArrowImage];
    }];
}



@end

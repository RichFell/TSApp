//
//  MapViewController.m
//  TSApp
//
//  Created by Rich Fellure on 10/6/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h> 
#import "User.h"
#import "MapModel.h"
#import "RegionListViewController.h"
#import "Location.h"
#import "Region.h"
#import "NetworkErrorAlert.h"

@interface MapViewController ()<GMSMapViewDelegate, MapModelDelegate, RegionListVCDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property GMSMapView *mapView;
@property MapModel *mapModel;
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


#define kNotVisitedImage @"PlacHolderImage"
#define kHasVisitedImage @"CheckMarkImage"
#define rwfLocationString @"Current Location"

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setup];
}

#pragma mark - Helper Methods

-(void)setup
{
    self.locationsArray = [NSMutableArray array];
    self.directions = [NSMutableArray array];
    self.mapModel = [[MapModel alloc] init];
    self.mapModel.delegate = self;
    self.mapView.myLocationEnabled = true;
    self.markers = [NSMutableArray array];

    self.mapView = [[GMSMapView alloc] initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    [self.mapView animateToZoom:10.0];
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];

    self.regionListVC = [RegionListViewController newStoryboardInstance];
    self.regionListVC.delegate = self;
    self.leftBarButtonItem.tag = 0;

    self.title = self.currentRegion.name;

    self.imageViewTopConstraint.constant = self.view.frame.size.height - 40;
    self.containerBottomeConstraint.constant = -self.view.frame.size.height + 40;
    self.startingContainerBottomConstant = self.containerBottomeConstraint.constant;
    self.startingImageViewConstant = self.imageViewTopConstraint.constant;
}

-(void)placeMarker:(PFGeoPoint *)geoPoint string: (NSString *)string
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    marker.map = self.mapView;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.tappable = YES;
    marker.snippet = string;

    [self.mapView setSelectedMarker:marker];
}

#pragma mark - GMSMapViewDelegate Methods

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

#pragma mark - MapModelDelegate methods

-(void)didFindNewLocation:(CLLocation *)location
{
    [self.mapView animateToLocation:location.coordinate];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:location];
    [self placeMarker:geoPoint string:rwfLocationString];
}

-(void)didGeocodeString:(CLLocationCoordinate2D)coordinate
{
    [self.mapView animateToLocation:coordinate];
}

-(void)didReverseGeocode:(GMSReverseGeocodeResponse *)reverseGeocode
{
    PFGeoPoint *geoPoint = [[PFGeoPoint alloc]init];
    geoPoint.latitude = reverseGeocode.firstResult.coordinate.latitude;
    geoPoint.longitude = reverseGeocode.firstResult.coordinate.longitude;
    [self placeMarker:geoPoint string:rwfLocationString];
}

#pragma mark - RegionListVCDelegate Method

-(void)didSelectRegion:(Region *)selectedRegion
{
    [Location queryForLocations:selectedRegion completed:^(NSArray *locations, NSError *error) {
        if (error == nil)
        {
            self.locationsArray = [locations mutableCopy];

            for (Location *location in self.locationsArray)
            {
                [self placeMarker:location.coordinate string:location.name];
            }
        }
        else
        {
            [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
        }
    }];
    self.currentRegion = selectedRegion;
    [self.delegate closeList];
}
- (IBAction)slideOpenLocationListOnTapped:(UIBarButtonItem *)sender
{
    if (sender.tag == 0)
    {
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
        sender.tag = 1;
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
        sender.tag = 0;
    }
}

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
    [UIView animateWithDuration:0.5 animations:^{
        self.containerBottomeConstraint.constant = 0;
        self.imageViewTopConstraint.constant = 60;
        [self.view layoutIfNeeded];

    }];
}

-(void)animateContainerDown
{
    [UIView animateWithDuration:0.5 animations:^{
        self.containerBottomeConstraint.constant = -self.view.frame.size.height + 40;
        self.imageViewTopConstraint.constant = self.view.frame.size.height - 40;
        [self.view layoutIfNeeded];
    }];
}



@end

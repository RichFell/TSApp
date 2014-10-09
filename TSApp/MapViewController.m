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

@property GMSMapView *mapView;
@property MapModel *mapModel;
@property NSMutableArray *locationsArray;
@property CLLocationCoordinate2D selectedLocation;
@property NSMutableArray *markers;
@property NSMutableArray *directions;
@property RegionListViewController *regionListVC;
@property Region *currentRegion;

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
}

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
//    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:location];
//    [self placeMarker:geoPoint string:rwfLocationString];
}

-(void)didGeocodeString:(CLLocationCoordinate2D)coordinate
{
    [self.mapView animateToLocation:coordinate];
}

-(void)didReverseGeocode:(GMSReverseGeocodeResponse *)reverseGeocode
{
//    [self placeMarker:reverseGeocode.firstResult.coordinate string:rwfLocationString];
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
//                [self placeMarker:location.coordinate string:location.name];
            }
        }
        else
        {
            [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
        }
    }];
    self.currentRegion = selectedRegion;
}


@end

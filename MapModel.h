//
//  MapModel.h
//  TSApp
//
//  Created by Rich Fellure on 8/7/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

@protocol MapModelDelegate <NSObject>

@optional -(void)didFindNewLocation: (CLLocation *)location;
@optional -(void)didGeocodeString: (CLLocationCoordinate2D )coordinate;
@optional -(void)didReverseGeocode: (GMSReverseGeocodeResponse *)reverseGeocode;
@optional -(void)didGetDirections: (NSArray *)directionArray;

@end

@interface MapModel : NSObject<CLLocationManagerDelegate>

@property id<MapModelDelegate> delegate;
@property CLLocationManager *locationManager;
@property CLPlacemark *searchedPlacemark;
@property CLLocationCoordinate2D selectedLocation;
@property NSArray *directions;

-(void)setupLocationManager;
-(void)geocodeString: (NSString *)address;
-(void)reverseGeocode: (CLLocationCoordinate2D) location;
-(CLPlacemark *)returnSearchedPlacemark;
-(CLLocationCoordinate2D)requestSelectedLocation;
-(void)getDirections: (CLLocationCoordinate2D)startingPosition endingPosition: (CLLocationCoordinate2D)endPosition;
-(NSArray *)returnDirections;

@end
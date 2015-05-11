//
//  TSMarker.h
//  TSApp
//
//  Created by Rich Fellure on 3/30/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
@class CDLocation, Business;

typedef NS_ENUM(NSInteger, MarkerType) {
    Marker_New,
    Marker_Visited,
    Marker_NotVisited,
    Marker_Business
};

@interface TSMarker : GMSMarker

@property CDLocation *location;
@property Business *business;
@property MarkerType markerType;

-(instancetype)initWithLocation:(CDLocation *)location;
-(instancetype)initWithPosition:(CLLocationCoordinate2D)position withSnippet:(NSString *)snippet forMap:(GMSMapView *)mapView;
-(instancetype)initWithBusiness:(Business *)business;
@end

//
//  TSMarker.h
//  TSApp
//
//  Created by Rich Fellure on 3/30/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "CDLocation.h"
@interface TSMarker : GMSMarker
@property CDLocation *location;

-(instancetype)initWithLocation:(CDLocation *)location;
-(instancetype)initWithPosition:(CLLocationCoordinate2D)position withSnippet:(NSString *)snippet forMap:(GMSMapView *)mapView;
@end

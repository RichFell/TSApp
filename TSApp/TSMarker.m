//
//  TSMarker.m
//  TSApp
//
//  Created by Rich Fellure on 3/30/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "TSMarker.h"
#import "CDLocation.h"
#import "YPBusiness.h"

@implementation TSMarker

-(instancetype)initWithLocation:(CDLocation *)location {
    self = [super init];
    self.position = location.coordinate;
    self.location = location;
    self.tappable = true;
    self.snippet = location.localAddress;
    self.appearAnimation = kGMSMarkerAnimationPop;
    self.title = location.name;
    self.markerType = !location.hasVisited ? Marker_NotVisited : Marker_Visited;
    self.icon = location.hasVisited == true ? [GMSMarker markerImageWithColor:[UIColor blueColor]] : [GMSMarker markerImageWithColor:[UIColor redColor]];

    return self;
}

-(instancetype)initWithPosition:(CLLocationCoordinate2D)position withSnippet:(NSString *)snippet forMap:(GMSMapView *)mapView {
    self = [super init];
    self.position = position;
    self.snippet = snippet;
    self.map = mapView;
    self.title = @"Tap here to save this location.";
    self.snippet = @"If you tap, you can save this location to access later.";
    self.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
    self.markerType = Marker_NotVisited;
    self.appearAnimation = kGMSMarkerAnimationPop;
    return self;
}

-(instancetype)initWithBusiness:(YPBusiness *)business {
    self = [super init];
    self.business = business;
    self.position = business.coordinate;
    self.icon = [UIImage imageNamed:@"Business"];
    self.markerType = Marker_Business;
    self.tappable = true;
    self.appearAnimation = kGMSMarkerAnimationPop;
    self.title = business.name;
    self.snippet = business.address;
    return self;
}

@end

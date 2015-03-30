//
//  TSMarker.m
//  TSApp
//
//  Created by Rich Fellure on 3/30/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "TSMarker.h"

@implementation TSMarker

-(instancetype)initWithLocation:(CDLocation *)location {
    self = [super init];
    self.position = location.coordinate;
    self.location = location;
    self.tappable = true;
    self.snippet = location.localAddress;
    self.appearAnimation = kGMSMarkerAnimationPop;
    self.title = location.name;
    self.icon = location.hasVisited == true ? [GMSMarker markerImageWithColor:[UIColor blueColor]] : [GMSMarker markerImageWithColor:[UIColor redColor]];

    return self;
}

-(instancetype)initWithPosition:(CLLocationCoordinate2D)position withSnippet:(NSString *)snippet forMap:(GMSMapView *)mapView {
    self = [super init];
    self.position = position;
    self.snippet = snippet;
    self.map = mapView;
    self.title = @"Tap here to save this location.";
    self.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
    self.appearAnimation = kGMSMarkerAnimationPop;
    return self;
}

@end

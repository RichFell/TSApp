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
@end

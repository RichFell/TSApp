//
//  ParseModel.h
//  TSApp
//
//  Created by Rich Fellure on 8/7/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@protocol ParseModelDataSource <NSObject>

@optional-(void)didFinishRegionsQuery: (NSArray *)regions;
@optional-(void)didQueryLocations: (NSArray *)locations;

@end

@interface ParseModel : NSObject


-(void)createRegion:(NSString *) name;
-(void )createLocation: (CLLocationCoordinate2D) coordinate;
-(void)queryForRegions;
-(void)queryForLocations: (NSString *)regionNameString;

#define rwfLongitude @"longitude"
#define rwfLatitude @"latitude"
#define rwfLocations @"locations"
#define rwfLocationString @"Current Location"
#define rwfLocationParseClass @"Location"
#define rwfCellIdentifier @"CellID"
#define rwfRegionString @"Region"
#define rwfRegionNameString @"name"
#define rwfLocationToRegion @"region"
@property id<ParseModelDataSource> delegate;
@property PFObject *currentRegion;

@end

//
//  ParseModel.h
//  TSApp
//
//  Created by Rich Fellure on 8/7/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Location.h"
#import "Region.h"
#import "User.h"

@protocol ParseModelDataSource <NSObject>

@optional-(void)didCreateRegion: (Region *)region;
@optional-(void)didFinishRegionsQuery: (NSArray *)regions;
@optional-(void)didCreateLocation: (Location *)location;
@optional-(void)didQueryLocations: (NSArray *)locations;
@optional-(void)reorderedLocations;
@optional-(void)didMoveLocationsIndex;
@optional-(void)didSignUp;
@optional-(void)didLogin;

@end

@interface ParseModel : NSObject

-(void)userSignUp: (NSString *)username andPassword: (NSString *)password andEmail: (NSString *)email;
-(void)userLogin: (NSString *)username withPassword: (NSString *)password;
-(void)reorderLocationsArray:(NSIndexPath *)startingIndexPath endIndex: (NSIndexPath *) edingIndexPath array: (NSArray *)array;
-(void)moveObject: (PFObject *)object toIndexPath: (NSIndexPath *)destingationIndexPath;

@property id<ParseModelDataSource> delegate;


#define rwfLocationString @"Current Location"
#define rwfCellIdentifier @"CellID"
#define rwfLocationTableViewCellID @"Cell"
#define rwfLocationToRegion @"region"
#define rwfLocationIndex @"index"
#define rwfRegionToUser @"user"


@end

//
//  CDRegion.h
//  TSApp
//
//  Created by Rich Fellure on 3/21/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CDRegion : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSSet *locations;
@property (nonatomic, retain) NSString *objectId;
@property NSArray *arrayOfLocations;
@property BOOL hasCompleted;

/**
 Description: Creates a new CDRegion in Core Data, as well as will save a new Region object to Parse
 :name: NSString parameter which is the name of the Region
 :geoPoint: The PFGeoPoint where the user wants this trip to be fore
 :returns: BOOL telling whether it saved successfully to Parse, the newly created CDRegion
 */
+(void)createNewRegionWithName:(NSString *)name andGeoPoint:(PFGeoPoint *)geoPoint completed:(void(^)(BOOL result, CDRegion *region))completionHandler;

/**
 Description: Called to fetch the CDRegion objects stored in Core Data. Sorts the Regions by their name, then will create an array of arrays. The arrays are the Regions that have not been marked as visited, and an array of CDRegion objects that have been marked as visited.
 :sortedRegions: The array of arrays that will be returned.
 */
+(void)fetchRegionsWithBlock:(void(^)(NSArray * sortedRegions))completed;


@end

@interface CDRegion (CoreDataGeneratedAccessors)

- (void)addLocationsObject:(NSManagedObject *)value;
- (void)removeLocationsObject:(NSManagedObject *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end

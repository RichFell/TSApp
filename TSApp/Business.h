//
//  YPBusiness.h
//  TSApp
//
//  Created by Rich Fellure on 4/16/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreLocation/CoreLocation.h>
#import "UniversalBusiness.h"

@interface Business : NSObject

@property NSString *name;
@property NSString *address;
@property CLLocationCoordinate2D coordinate;
@property NSString *businessId;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 Description: Class method that makes a call to the Yelp API in order to find the businesses within the given bounds. It is important to note that Yelp restricts the returned results to 20 businesses at a time.
 :nwCoordinate: The coordinate representing the top left corner of the region in which we want results for.
 :seCoordinate: The coordinate representing the bottom right corner of the region in which we want results for.
 :businesses: The array of businesses that have already been returned by Yelp. Use this in order to restrict what we return to only being Business objects that don't already have a point on the map.
 */
+(void)fetchBusinessesFromYelpForBounds:(CLLocationCoordinate2D)nwCoordinate andSEBounds:(CLLocationCoordinate2D)seCoordinate andCompareAgainstBusinesses:(NSArray *)businesses completed:(void (^)(NSArray *))completionHandler;


//+(void)fetchBusinessesFromYelpMatchingName:(NSString *)name
//                                notInArray:(NSArray *) businessesArray
//                                 completed:(void(^)(NSArray *businesses))completionHandler;


/**
 Description: Class method that is used to execute a MKLocalSearch, and return the results
 :text: This is the string that will be used to search for
 :businsesses: The array of business that will be returned, if the search is succesful.
 :error: The error that will be returned if something goes wrong executing the search.
 */
+(void)executeSearchForBusinessMatchingText:(NSString *)text completed:(void(^)(NSArray *businesses, NSError *error))completionHandler;

@end

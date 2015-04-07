//
//  DirectionSet.h
//  TSApp
//
//  Created by Rich Fellure on 4/6/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDLocation, Direction;

@interface DirectionSet : NSManagedObject

@property (nonatomic, retain) CDLocation *locationTo;
@property (nonatomic, retain) CDLocation *locationFrom;
@property (nonatomic, retain) NSSet *directions;
@property (nonatomic) NSArray *directionsArray;

+(void)createNewDirectionSetWithDirections:(NSArray *)directions andStartingLocation:(CDLocation *)startingLocation andEndingLocation: (CDLocation *)endingLocation;

+(NSArray *)fetchDirectionSetsWithLocation:(CDLocation *)location;

@end

@interface DirectionSet (CoreDataGeneratedAccessors)

- (void)addDirectionsObject:(Direction *)value;
- (void)removeDirectionsObject:(Direction *)value;
- (void)addDirections:(NSSet *)values;
- (void)removeDirections:(NSSet *)values;

@end

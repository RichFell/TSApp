//
//  DirectionsViewController.m
//  TSApp
//
//  Created by Rich Fellure on 8/31/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "DirectionsViewController.h"
#import "Direction.h"
#import "NSString+StringCategory.h"

@interface DirectionsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DirectionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];


    NSArray *someDirections = [NSArray array];
    self.listOfDirections = [NSMutableArray array];
    NSArray *anotherArray = [NSArray array];

    for (NSDictionary *dictionsary in self.directions)
    {
        someDirections = [NSArray arrayWithArray:dictionsary[@"legs"]];
//        [someDirections arrayByAddingObjectsFromArray:dictionsary[@"legs"]];
    }

    NSLog(@"SOMEDIRECTIONS: %@", someDirections);

    for (NSDictionary *anotherDictionary in someDirections)
    {
//        [self.listOfDirections arrayByAddingObjectsFromArray:anotherDictionary[@"steps"]];
        anotherArray = [NSArray arrayWithArray:anotherDictionary[@"steps"]];
    }

    for (NSDictionary *thisDictionary in anotherArray)
    {
        Direction *direction = [[Direction alloc] init];

        NSString *directionString = [thisDictionary[@"html_instructions"] stringByStrippingHtml];
        direction.direction = directionString;
        direction.startingLatitude = [thisDictionary[@"start_location"][@"lat"] floatValue];
        direction.startingLongitude = [thisDictionary[@"start_location"][@"lng"]floatValue];
        direction.endingLatitude = [thisDictionary[@"end_location"][@"lat"]floatValue];
        direction.endingLongitude = [thisDictionary[@"end_location"][@"lng"]floatValue];
        direction.distance = thisDictionary[@"distance"][@"text"];

        [self.listOfDirections addObject:direction];
    }

    NSLog(@"DIRECTIONS: %@", self.listOfDirections);

}

#pragma mark - UITableViewDataSource methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];

    Direction *direction = [self.listOfDirections objectAtIndex:indexPath.row];

    cell.textLabel.text = direction.direction;

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listOfDirections.count;
}

@end

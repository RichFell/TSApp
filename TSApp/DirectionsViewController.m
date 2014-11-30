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

static NSString *const kCellID = @"CellID";

- (void)viewDidLoad
{
    [super viewDidLoad];


    NSArray *someDirections = [NSArray array];
    self.listOfDirections = [NSMutableArray array];
    NSArray *anotherArray = [NSArray array];

    for (NSDictionary *dictionsary in self.directions)
    {
        someDirections = [NSArray arrayWithArray:dictionsary[@"legs"]];

    }

    NSLog(@"SOMEDIRECTIONS: %@", someDirections);

    for (NSDictionary *anotherDictionary in someDirections)
    {
        anotherArray = [NSArray arrayWithArray:anotherDictionary[@"steps"]];
    }

    for (NSDictionary *thisDictionary in anotherArray)
    {
        Direction *direction = [Direction initWithDictionary:thisDictionary];

        [self.listOfDirections addObject:direction];
    }

    NSLog(@"DIRECTIONS: %@", self.listOfDirections);

}

#pragma mark - UITableViewDataSource methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];

    Direction *direction = [self.listOfDirections objectAtIndex:indexPath.row];

    cell.textLabel.text = direction.direction;

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listOfDirections.count;
}

@end

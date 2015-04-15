//
//  DirectionsListViewController.m
//  TSApp
//
//  Created by Rich Fellure on 4/5/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "DirectionsListViewController.h"
#import "Direction.h"
#import "DirectionSet.h"
#import "CDLocation.h"
#import "HeaderTableViewCell.h"

@interface DirectionsListViewController ()<UITableViewDataSource, UITableViewDelegate>

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

#pragma mark - Variables
@property NSArray *directionSets;
@property NSArray *titleArray;
@end

@implementation DirectionsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.selectedLocation.name;
    self.titleArray = @[@"From Location", @"To Location"];
    self.directionSets = [DirectionSet fetchDirectionSetsWithLocation:self.selectedLocation];
    [self.tableView reloadData];
}

#pragma mark - TableViewDataSource/Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    DirectionSet *directionSet = self.directionSets[indexPath.section][indexPath.row];
    if (indexPath.section == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"To:%@", directionSet.locationTo.name];
    }
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"From: %@", directionSet.locationFrom.name];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.directionSets[section];
    return array.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderTableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    headerCell.headerTitleLabel.text = self.titleArray[section];
    return headerCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 57.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.navigationController popViewControllerAnimated:true];
    NSDictionary *info = @{kDirectionArrayKey: self.directionSets[indexPath.section][indexPath.row]};
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedDirectionNotification object:nil userInfo:info];
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

@end

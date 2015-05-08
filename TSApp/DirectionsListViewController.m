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
#import "HeaderView.h"

@interface DirectionsListViewController ()<UITableViewDataSource, UITableViewDelegate>

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;

#pragma mark - Variables
@property NSArray *directionSets;
@property NSArray *titleArray;
@end

@implementation DirectionsListViewController

+(instancetype)storyboardInstance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([DirectionsListViewController class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.selectedLocation.name;
    self.titleArray = @[@"From Location", @"To Location"];
    self.directionSets = [DirectionSet fetchDirectionSetsWithLocation:self.selectedLocation];
    [self.tableView reloadData];
}

#pragma Actions
- (IBAction)closeViewOnTap:(UIButton *)sender {
    [self.delegate directionListVC:self finishedSelection:nil];
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
    HeaderView *headerView = [[HeaderView alloc]initWithFrame:tableView.frame];
    headerView.headerLabel.text = self.titleArray[section];
    if ([self.directionSets[section] count] <= 0) {
        headerView = nil;
    }
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    CGFloat height = [self.directionSets[section] count] <= 0 ? 0 : 57.0;
    return height;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.directionSets.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController popViewControllerAnimated:true];
    DirectionSet *dSet = self.directionSets[indexPath.section][indexPath.row];
    NSDictionary *info = @{kDirectionArrayKey: dSet.directionsArray};
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedDirectionNotification object:nil userInfo:info];
    [self.parentViewController.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

@end

//
//  SearchTableViewController.m
//  TSApp
//
//  Created by Rich Fellure on 4/20/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "SearchTableViewController.h"
#import "YPBusiness.h"
#import "CDLocation.h"
#import "HeaderView.h"

@interface SearchTableViewController ()

@property NSArray *displayArray;
@property NSArray *titleArray;

@end

@implementation SearchTableViewController

static NSString *const kCellId = @"CellID";

-(instancetype)initFromCallerFrame:(CGRect)frame {
    self = [super initWithStyle:UITableViewStylePlain];
    self.view.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame), CGRectGetWidth(frame), 200.0);
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleArray = @[@"Saved Locations", @"From Yelp"];
}

-(void)inputText:(NSString *)text {
    NSArray *businessesArray = [self filteredBusinessesByText:text];
    NSArray *locationsArray = [self filterLocationsByText:text];
    self.displayArray = @[locationsArray, businessesArray];
    [self.tableView reloadData];
}

-(NSArray *)filteredBusinessesByText:(NSString *)text {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS %@ OR address CONTAINS %@", text, text];
    return [self.businesses filteredArrayUsingPredicate:predicate];
}

-(NSArray *)filterLocationsByText:(NSString *)text {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS %@ OR localAddress CONTAINS %@", text, text];
    return [self.locations filteredArrayUsingPredicate:predicate];
}

#pragma mark - Table view data source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellId];
    }
    if (indexPath.section == 0) {
        CDLocation *location = self.displayArray[indexPath.section][indexPath.row];
        cell.textLabel.text = location.name;
    }
    else {
        YPBusiness *business = self.displayArray[indexPath.section][indexPath.row];
        cell.textLabel.text = business.name;
    }

    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderView *headerView = [[HeaderView alloc]initWithFrame:tableView.frame];
    headerView.headerLabel.text = self.titleArray[section];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kTableViewHeaderHeight;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.displayArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arrayForSection = self.displayArray[section];
    return arrayForSection.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CDLocation *location = self.displayArray[indexPath.section][indexPath.row];
        [self.delegate searchTableVC:self didSelectASearchOption:Select_Location forEitherBusiness:nil orLocation:location];
    }
    else {
        YPBusiness *business = self.displayArray[indexPath.section][indexPath.row];
        [self.delegate searchTableVC:self didSelectASearchOption:Select_Business forEitherBusiness:business orLocation:nil];
    }
}

@end

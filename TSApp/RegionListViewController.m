//
//  RegionListViewController.m
//  TSApp
//
//  Created by Rich Fellure on 10/6/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

//TODO: There needs to be a new file that will work to help control the constraints used depending on the device sizes. Hopefully can avoid needing too much adjustment if possible.
#import "RegionListViewController.h"
#import "NetworkErrorAlert.h"
#import "MapViewController.h"
#import "UserDefaults.h"
#import "RegionTableViewCell.h"
#import "CreateTripViewController.h"
#import "HeaderTableViewCell.h"
#import "CDRegion.h"

@interface RegionListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *regionsArray;
@property NSArray *titleArray;
@end

@implementation RegionListViewController

static NSString *const kRegionListVC = @"RegionListViewController";
static NSString *const kCellID = @"CellID";
static NSString *const kVisitedKey = @"Completed";
static NSString *const kNeedToVisitKey = @"Haven't Completed";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self queryForTrips];
    self.titleArray = @[kNeedToVisitKey, kVisitedKey];
}

#pragma mark - Helper methods

-(void)queryForTrips
{
    self.regionsArray = [NSMutableArray array];
    [CDRegion fetchRegionsWithBlock:^(NSArray *sortedRegions) {
        self.regionsArray = [NSMutableArray arrayWithArray:sortedRegions];
    }];
}

#pragma mark - TableView Delegate methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RegionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    CDRegion *region = self.regionsArray[indexPath.section][indexPath.row];

    cell.infoLabel.text = region.name;
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    HeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    NSString *title = self.titleArray[section];
    cell.headerTitleLabel.text = title;
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.titleArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.regionsArray.count == 0 ? @[] : self.regionsArray[section];
    return array.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    Region *region = self.regionsArray[indexPath.section][indexPath.row];
    [UserDefaults setDefaultRegion:region];
    [self.navigationController popViewControllerAnimated:true];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Region *region = self.regionsArray[indexPath.section][indexPath.row];
        [region deleteRegionWithBlock:^(BOOL result, NSError *error) {
            if (error)
            {
                [NetworkErrorAlert showAlertForViewController:self];
            }
            else
            {
                [self.regionsArray[indexPath.section] removeObject:region];
                [self.tableView reloadData];
            }
        }];
    }
}

@end

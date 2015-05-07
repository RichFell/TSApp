//
//  RegionListViewController.m
//  TSApp
//
//  Created by Rich Fellure on 10/6/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "RegionListViewController.h"
#import "NetworkErrorAlert.h"
#import "MapViewController.h"
#import "UserDefaults.h"
#import "RegionTableViewCell.h"
#import "CreateTripViewController.h"
#import "HeaderView.h"


@interface RegionListViewController ()<UITableViewDataSource, UITableViewDelegate, CreateTripVCDelegate>

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CreateSegue"]) {
        CreateTripViewController *createVC = segue.destinationViewController;
        createVC.delegate = self;
    }
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
    if ([self.regionsArray[section] count] <= 0) {
        return 0;
    }
    return kTableViewHeaderHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    HeaderView *headerView = [[HeaderView alloc] initWithFrame:tableView.frame];
    headerView.headerLabel.text = self.titleArray[section];
    if ([self.regionsArray[section] count] <= 0) {
        headerView = nil;
    }

    return headerView;
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
    CDRegion *region = self.regionsArray[indexPath.section][indexPath.row];
    [UserDefaults setDefaultRegion:region];
    [self.delegate regionListVC:self selectedRegion:region];
    [self.navigationController popViewControllerAnimated:true];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

    }
}

#pragma mark - CreateTripVCDelegate
-(void)createTripViewController:(CreateTripViewController *)viewController didSaveNewRegion:(CDRegion *)region {
    [self.navigationController popViewControllerAnimated:true];
    [self.delegate regionListVC:self selectedRegion:region];
}

@end

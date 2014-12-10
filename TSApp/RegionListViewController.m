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

@interface RegionListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSDictionary *regionDictionary;
@property NSMutableArray *regionsArray;

@end

@implementation RegionListViewController

static NSString *const kMainStoryboard = @"Main";
static NSString *const kRegionListVC = @"RegionListViewController";
static NSString *const kCellID = @"CellID";
static NSString *const kVisitedKey = @"Completed";
static NSString *const kNeedToVisitKey = @"Haven't Completed";

+(RegionListViewController *)newStoryboardInstance
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kMainStoryboard bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:kRegionListVC];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.regionDictionary = [NSDictionary new];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:true];
    [self queryForTrips];
}

#pragma mark - Helper methods

-(void)queryForTrips
{
    self.regionsArray = [NSMutableArray array];
    [Region queryForRegionsWithBlock:^(NSArray *regions, NSError *error) {
        if (error == nil)
        {
            [self createDictionaryOfRegions:regions];
        }
        else
        {
            //TODO: Here is an error message for us to evaluate
            [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
        }
    }];
}

-(void)createDictionaryOfRegions:(NSArray *)theRegions
{
    NSMutableArray *needToVisitRegions = [NSMutableArray array];
    NSMutableArray *visitedRegions = [NSMutableArray array];
    for (Region *region in theRegions)
    {
        if (region.completed == true)
        {
            [visitedRegions addObject:region];
        }
        else
        {
            [needToVisitRegions addObject:region];
        }
    }
    self.regionDictionary = @{kNeedToVisitKey: needToVisitRegions, kVisitedKey: visitedRegions};
    [self.tableView reloadData];

}

#pragma mark - TableView Delegate methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RegionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    Region *region = [self correctArrayForSection:indexPath.section][indexPath.row];

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
    NSString *title = [self.regionDictionary allKeys][section];
    cell.headerTitleLabel.text = title;
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.regionDictionary allKeys].count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self correctArrayForSection:section].count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    Region *region = [self.regionsArray objectAtIndex:indexPath.row];
    [UserDefaults setDefaultRegion:region];
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Dictionary Helper Methods

-(NSArray *)correctArrayForSection:(NSInteger)section
{
    return section == 0 ? self.regionDictionary[kNeedToVisitKey] : self.regionDictionary[kVisitedKey];
}

@end

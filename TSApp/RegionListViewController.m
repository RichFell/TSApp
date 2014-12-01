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

@interface RegionListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RegionListViewController

static NSString *const kMainStoryboard = @"Main";
static NSString *const kRegionListVC = @"RegionListViewController";
static NSString *const kCellID = @"CellID";

+(RegionListViewController *)newStoryboardInstance
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kMainStoryboard bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:kRegionListVC];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

#pragma mark - Helper methods

-(void)setup
{
    self.regionsArray = [NSMutableArray array];
    [Region queryForRegionsWithBlock:^(NSArray *regions, NSError *error) {
        if (error == nil)
        {
            self.regionsArray = [regions mutableCopy];
            [self.tableView reloadData];
        }
        else
        {
            //TODO: Here is an error message for us to evaluate
            [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
        }
    }];
}

#pragma mark - TableView Delegate methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    Region *region = [self.regionsArray objectAtIndex:indexPath.row];

    cell.textLabel.text = region.name;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.regionsArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    Region *region = [self.regionsArray objectAtIndex:indexPath.row];
    [UserDefaults setDefaultRegion:region];
    [self dismissViewControllerAnimated:true completion:nil];
}

@end

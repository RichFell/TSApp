//
//  SearchTableViewController.m
//  TSApp
//
//  Created by Rich Fellure on 4/20/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "SearchTableViewController.h"
#import "Business.h"
#import "CDLocation.h"
#import "HeaderView.h"
#import "Alert.h"

@interface SearchTableViewController ()

@property (nonatomic)NSArray *displayArray;
@property NSArray *titleArray;

@end

@implementation SearchTableViewController
{
    NSTimer *searchTimer;
    NSString *searchText;
}

static float const kTimerTimeInterval = 0.5;
static NSString *const kCellId = @"CellID";

-(void)setDisplayArray:(NSArray *)displayArray {
    _displayArray = displayArray;
    [self.tableView reloadData];
}

-(instancetype)initFromCallerFrame:(CGRect)frame {
    self = [super initWithStyle:UITableViewStylePlain];
    self.view.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame), CGRectGetWidth(frame), 200.0);
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleArray = @[@"Saved Locations", @"Search Results"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:true];
    self.displayArray = @[self.locations, self.businesses];
}


#pragma mark - Public instance methods
-(void)inputText:(NSString *)text {

    //Using the timer because we want to make network calls to find matching locations as text is entered, but we don't want to fire them everytime a letter is entered. This approach will help to limit the number of calls that go through.
    searchText = text;
    [self sortArrays];
    if (searchTimer) {
        [searchTimer invalidate];
    }
    searchTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerTimeInterval
                                                   target:self
                                                 selector:@selector(searchForText)
                                                 userInfo:nil repeats:false];
    //If we clear the text, want to just show the original arrays, and stop the timer, so no network call is made
    if (text.length <= 0) {
        [searchTimer invalidate];
        self.displayArray = @[self.locations, self.businesses];
    }
}

-(void)resetArray {
    self.displayArray = @[self.locations, self.businesses];
}

#pragma mark - Array sorting methods
-(void)sortArrays {
    NSMutableArray *businessesArray = [[self filteredBusinessesByText:searchText] mutableCopy];
    NSArray *locationsArray = [self filterLocationsByText:searchText];
    self.displayArray = @[locationsArray, businessesArray];
    [self.tableView reloadData];
}

-(void)searchForText {

    [Business executeSearchForBusinessMatchingText:searchText
                                         completed:^(NSArray *businesses, NSError *error) {
        if (businesses) {
            NSMutableArray *businessesArray = self.displayArray[1];
            [businessesArray addObjectsFromArray:businesses];
        }
        else if(error) {
            [Alert showNetworkAlertWithError:error withViewController:self];
        }
    }];

}

-(NSArray *)filteredBusinessesByText:(NSString *)text {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ OR address contains[cd] %@", text, text];
    return [self.businesses filteredArrayUsingPredicate:predicate];
}

-(NSArray *)filterLocationsByText:(NSString *)text {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ OR localAddress contains[cd] %@", text, text];
    return [self.locations filteredArrayUsingPredicate:predicate];
}

#pragma mark - Table view data source
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellId];
    }
    if (indexPath.section == 0) {
        CDLocation *location = self.displayArray[indexPath.section][indexPath.row];
        cell.textLabel.text = location.name;
        cell.detailTextLabel.text = location.localAddress;
    }
    else {
        Business *business = self.displayArray[indexPath.section][indexPath.row];
        cell.textLabel.text = business.name;
        cell.detailTextLabel.text = business.address;
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
        Business *business = self.displayArray[indexPath.section][indexPath.row];
        [self.delegate searchTableVC:self didSelectASearchOption:Select_Business forEitherBusiness:business orLocation:nil];
    }
}

@end

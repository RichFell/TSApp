//
//  LocationsListViewController.m
//  TSApp
//
//  Created by Rich Fellure on 8/10/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "LocationsListViewController.h"
#import "LocationTableViewCell.h"
#import "MapModel.h"
#import "DirectionsViewController.h"
#import "NetworkErrorAlert.h"
#import "UserDefaults.h"
#import "HeaderTableViewCell.h"


@interface LocationsListViewController ()<UITableViewDataSource, UITableViewDelegate, LocationTVCellDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIButton *setDestinationsButton;
@property (weak, nonatomic) IBOutlet UIButton *callDirectionsButton;
@property (weak, nonatomic) IBOutlet UILabel *locationTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationOneLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *directionsButton;

@property UIView *locationsView;
@property UITextField *locationOneTextField;
@property UITextField *locationTwoTextField;
@property UIButton *produceDirectionsButton;

@property int destinationSelector;
@property Location *startingLocation;
@property Location *endingLocation;
@property NSArray *directionsArray;
@property Region *region;
@property NSDictionary *dictionary;
@property NSMutableArray *allLocations;

@end

@implementation LocationsListViewController

static NSString *const kDirectionsSegue = @"DirectionsSegue";
static NSString *const kLocationCellId = @"LocationTableViewCell";
static NSString *const kNeedToVisitString = @"Need To Visit";
static NSString *const kVisitedString = @"Visited";
static NSString *const kHeaderCellID = @"headerCell";
static NSString *const kDefaultRegion = @"defaultRegion";
static NSString *const kNewLocationNotification = @"NewLocationNotification";
static NSString *const kPlaceHolderImageName = @"PlaceHolderImage";
static NSString *const kCheckMarkImageName = @"CheckMarkImage";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.setDestinationsButton.tag = 0;
    self.destinationSelector = 0;
    self.callDirectionsButton.enabled = false;
    self.allLocations = [NSMutableArray new];

    self.view.backgroundColor = [UIColor customTableViewBackgroundGrey];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.setDestinationsButton.backgroundColor = [UIColor customOrange];
    self.callDirectionsButton.backgroundColor = [UIColor customOrange];
    [self.setDestinationsButton setTintColor:[UIColor darkGrayColor]];
    [self reduceDirectionsViewInViewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserverForName:kNewLocationNotification object:nil queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *note) {
        [self queryForLocations];
    }];
    [self queryForLocations];
}

-(void)sortLocations:(NSArray *)theLocations
{
    NSMutableArray *visitedArray = [NSMutableArray new];
    NSMutableArray *notVisitedArray = [NSMutableArray new];

    for (Location *location in theLocations)
    {
        if ([location.hasVisited isEqual: @0])
        {
            [notVisitedArray addObject:location];
        }
        else
        {
            [visitedArray addObject:location];
        }
    }

    self.dictionary = @{kNeedToVisitString: notVisitedArray, kVisitedString: visitedArray};
    [self.tableView reloadData];
}

-(void)queryForLocations
{
    if ([NSUserDefaults.standardUserDefaults objectForKey:kDefaultRegion])
    {
        [UserDefaults getDefaultRegionWithBlock:^(Region *region, NSError *error) {
            [Location queryForLocations:region completed:^(NSArray *locations, NSError *error) {
                if (error)
                {
                    [NetworkErrorAlert showAlertForViewController:self];
                }
                else
                {
                    [self sortLocations:locations];
                }
            }];
            
        }];
    }

}

#pragma mark - UITableViewDataSource Delegate Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLocationCellId];
    NSArray *locations = [self arrayForSection:indexPath.section];

    Location *location = [locations objectAtIndex:indexPath.row];

    cell.infoLabel.text = location.name;
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.addressLabel.text = location.address ? location.address : @"No Address";
    cell.visitedButton.imageView.image =  [location.hasVisited  isEqual: @1] ? [UIImage imageNamed:kCheckMarkImageName] : [UIImage imageNamed:kPlaceHolderImageName];

    int position = (int)indexPath.row;
    cell.countLabel.text = [NSString stringWithFormat:@"%d", position + 1];

    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    HeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHeaderCellID];
    NSArray *keyArray = [self.dictionary allKeys];
    NSString *key = keyArray[section];
    cell.headerTitleLabel.text = key;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *keyArray = [self.dictionary allKeys];
    return keyArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arrayToCount = [self arrayForSection:section];
    return arrayToCount.count;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO: Need to update to delete from Arrays within the dictionary
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSArray *locations = [self arrayForSection:indexPath.section];
        Location *location = locations[indexPath.row];
        [location deleteLocationWithBlock:locations completed:^(BOOL result, NSError *error) {

            if (error)
            {
                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
            }
            else
            {
                [self onSuccessfulDeleteAtIndexPath:indexPath ofLocation:location];
            }
        }];
    }
}

-(void)onSuccessfulDeleteAtIndexPath:(NSIndexPath *)indexPath ofLocation:(Location *)location
{
    [self.dictionary[[self keyForSection:indexPath.section]] removeObject:location];
    NSMutableArray *firstArray = [self.dictionary[kNeedToVisitString] mutableCopy];
    [firstArray addObjectsFromArray:self.dictionary[kVisitedString]];
    UniversalRegion *sharedRegion = [UniversalRegion sharedRegion];
    sharedRegion.locations = firstArray;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ChangeLocationNotification" object:nil];
    [self.tableView reloadData];

}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return true;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
//
//    Location *location = [self.locations objectAtIndex:sourceIndexPath.row];
//    [self.locations removeObject: location];
//    [self.locations insertObject:location atIndex:destinationIndexPath.row];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (self.setDestinationsButton.tag == 1)
    {
        if (self.destinationSelector == 0)
        {
            self.destinationSelector = 1;
//            self.startingLocation = [self.locations objectAtIndex:indexPath.row];

            cell.backgroundColor = [UIColor blueColor];
        }
        else
        {
            self.destinationSelector = 0;
//            self.endingLocation = [self.locations objectAtIndex:indexPath.row];

            cell.backgroundColor = [UIColor greenColor];

            self.callDirectionsButton.enabled = true;
        }
    }
}

#pragma mark - LocationTableViewCellDelegate method
-(void)didTapVisitedButtonAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO: update for the dictionary
    NSMutableArray *locations = [[self arrayForSection:indexPath.section]mutableCopy];
    Location *location = locations[indexPath.row];
    [location changeVisitedStatusWithBlock:^(BOOL result, NSError *error) {
        if (error)
        {
            [NetworkErrorAlert showAlertForViewController:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeLocationNotification" object:nil];
            [self moveLocation:location FromSection:indexPath.section];
        }
    }];

}
#pragma mark - ParseModelDataSource methods

-(void)didMoveLocationsIndex
{
    [self.tableView reloadData];
}

#pragma mark = MapModelDelegate

-(void)didGetDirections:(NSArray *)directionArray
{
    self.directionsArray = [NSArray arrayWithArray:directionArray];

    [self performSegueWithIdentifier:kDirectionsSegue sender:self];
}

#pragma mark - IBActions


- (IBAction)onPressedEnterEditingMode:(UIBarButtonItem *)sender
{
    if (sender.tag == 0)
    {
        self.tableView.editing = YES;
        sender.tag = 1;
    }
    else
    {
        self.tableView.editing = NO;
        sender.tag = 0;
    }
}

- (IBAction)onPressedSetDestinations:(UIButton *)sender
{
    if (sender.tag == 0)
    {
        sender.tag = 1;
        [sender setBackgroundColor:[UIColor orangeColor]];
    }
    else
    {
        sender.tag = 0;
        [sender setBackgroundColor:[UIColor clearColor]];
    }
}

- (IBAction)receiveDirections:(UIButton *)sender
{
    if (self.startingLocation != nil && self.endingLocation != nil)
    {
        CLLocationCoordinate2D startingCoordinate = CLLocationCoordinate2DMake(self.startingLocation.coordinate.latitude, self.startingLocation.coordinate.longitude);
        CLLocationCoordinate2D endingCoordinate = CLLocationCoordinate2DMake(self.endingLocation.coordinate.latitude, self.endingLocation.coordinate.longitude);

//        [self.mapModel getDirections: startingCoordinate endingPosition:endingCoordinate];
        [MapModel getDirectionsWithCoordinate:startingCoordinate andEndingPosition:endingCoordinate andBlock:^(NSArray *directionArray, NSError *error) {
            if (error)
            {
                [NetworkErrorAlert showAlertForViewController:self];
            }
            else
            {

            }
        }];
    }
}
- (IBAction)getDirectionsOnTapped:(UIButton *)sender
{

}
- (IBAction)didTapOnLocationOneLabel:(UITapGestureRecognizer *)sender
{

    
}

- (IBAction)didTapOnLocationTwoLabel:(UITapGestureRecognizer *)sender
{

}

-(void)reduceDirectionsViewInViewDidLoad
{
    self.goButtonWidthConstraint.constant = 0.0;
    self.topViewHeightConstraint.constant = self.locationOneLabel.frame.size.height + 20;
    self.locationTwoLabel.hidden = true;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DirectionsViewController *directionVC = segue.destinationViewController;
    directionVC.directions = [NSArray arrayWithArray:self.directionsArray];
}

-(NSString *)keyForSection:(NSInteger)section
{
    return section == 0 ? kNeedToVisitString : kVisitedString;
}

-(NSString *)keyForOppositeSection:(NSInteger)section
{
    return section == 0 ? kVisitedString : kNeedToVisitString;
}

-(NSArray *)arrayForSection:(NSInteger)section
{
    return section == 0 ? self.dictionary[kNeedToVisitString] : self.dictionary[kVisitedString];
}

-(void)moveLocation:(Location *)location FromSection:(NSInteger)section
{
    NSMutableArray *forSection = section == 1 ? [self.dictionary[kVisitedString] mutableCopy] : [self.dictionary[kNeedToVisitString] mutableCopy];
    [forSection removeObject:location];
    NSMutableArray *toSection = section == 1 ? [self.dictionary[kNeedToVisitString]mutableCopy] : [self.dictionary[kVisitedString]mutableCopy];
    [toSection addObject:location];
    [self.dictionary[[self keyForSection:section]] removeObject:location];
    [self.dictionary[[self keyForOppositeSection:section]] addObject:location];
    [self.tableView reloadData];
}

@end

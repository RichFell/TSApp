//
//  LocationsListViewController.m
//  TSApp
//
//  Created by Rich Fellure on 8/10/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "LocationsListViewController.h"
#import "LocationTableViewCell.h"
#import "DirectionsViewController.h"
#import "NetworkErrorAlert.h"
#import "UserDefaults.h"
#import "HeaderTableViewCell.h"
#import "Direction.h"
#import <CoreLocation/CoreLocation.h>
#import "DirectionTableViewCell.h"


@interface LocationsListViewController ()<UITableViewDataSource, UITableViewDelegate, LocationTVCellDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *callDirectionsButton;
@property (weak, nonatomic) IBOutlet UILabel *locationTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationOneLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *directionsButton;
@property (weak, nonatomic) IBOutlet UIButton *transitButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *transportationButtons;

@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
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
@property BOOL wantDirections;
@property BOOL endingDestination;
@property BOOL displayDirections;
@property NSString *typeOfTransportation;

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
static NSString *const kDirectionsCellID = @"DirectionCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.endingDestination = false;
    self.displayDirections = false;
    self.typeOfTransportation = @"driving";
    self.destinationSelector = 0;
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    self.callDirectionsButton.enabled = false;
    self.allLocations = [NSMutableArray new];
    self.wantDirections = false;
    self.view.backgroundColor = [UIColor customTableViewBackgroundGrey];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.callDirectionsButton.backgroundColor = [UIColor customOrange];
    [self reduceDirectionsViewInViewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserverForName:kNewLocationNotification object:nil queue:NSOperationQueuePriorityNormal usingBlock:^(NSNotification *note) {
        [self queryForLocations];
    }];
    [self queryForLocations];
}

#pragma mark - helper methods
-(void)sortLocations:(NSArray *)theLocations {
    NSMutableArray *visitedArray = [NSMutableArray new];
    NSMutableArray *notVisitedArray = [NSMutableArray new];

    for (Location *location in theLocations) {
        if ([location.hasVisited isEqual: @0]) {
            [notVisitedArray addObject:location];
        }
        else {
            [visitedArray addObject:location];
        }
    }

    self.dictionary = @{kNeedToVisitString: notVisitedArray, kVisitedString: visitedArray};
    [self.tableView reloadData];
}

-(void)queryForLocations {
    if ([NSUserDefaults.standardUserDefaults objectForKey:kDefaultRegion]) {
        [UserDefaults getDefaultRegionWithBlock:^(Region *region, NSError *error) {
            [Location queryForLocations:region completed:^(NSArray *locations, NSError *error) {
                if (error) {
                    [NetworkErrorAlert showAlertForViewController:self];
                }
                else {
                    [self sortLocations:locations];
                }
            }];
            
        }];
    }
}

///Removes the deleted destination(Location) from the correct array after a successful delete
-(void)onSuccessfulDeleteAtIndexPath:(NSIndexPath *)indexPath ofLocation:(Location *)location {
    [self.dictionary[[self keyForSection:indexPath.section]] removeObject:location];
    NSMutableArray *firstArray = [self.dictionary[kNeedToVisitString] mutableCopy];
    [firstArray addObjectsFromArray:self.dictionary[kVisitedString]];
    UniversalRegion *sharedRegion = [UniversalRegion sharedRegion];
    sharedRegion.locations = firstArray;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ChangeLocationNotification" object:nil];
    [self.tableView reloadData];
}

///Returns the correct cell we want to display whether we want to show directions, or to show the destinations
-(UITableViewCell *)returnCorrectCellforIndexpath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView
{
    if (self.displayDirections) {
        DirectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDirectionsCellID];
        Direction *direction = self.directionsArray[indexPath.row];
        cell.directionLabel.text = direction.step;
        cell.posLabel.text = [NSString stringWithFormat:@"%li", (long)indexPath.row + 1];
        cell.disLabel.text = direction.distance;
        cell.durLabel.text = direction.duration;
        return cell;
    }
    else {
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
}

#pragma mark - UITableViewDataSource Delegate Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self returnCorrectCellforIndexpath:indexPath forTableView:tableView];

    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHeaderCellID];
    NSArray *keyArray = [self.dictionary allKeys];
    NSString *key = keyArray[section];
    cell.headerTitleLabel.text = key;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.displayDirections) {
        return 0.0;
    }
    else {
        return 40.0;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.displayDirections) {
        return 1;
    }
    else {
        NSArray *keyArray = [self.dictionary allKeys];
        return keyArray.count;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.displayDirections) {
        return self.directionsArray.count;
    }
    else {
        NSArray *arrayToCount = [self arrayForSection:section];
        return arrayToCount.count;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: Need to update to delete from Arrays within the dictionary
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *locations = [self arrayForSection:indexPath.section];
        Location *location = locations[indexPath.row];
        [location deleteLocationWithBlock:locations completed:^(BOOL result, NSError *error) {

            if (error) {
                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
            }
            else {
                [self onSuccessfulDeleteAtIndexPath:indexPath ofLocation:location];
            }
        }];
    }
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (self.wantDirections) {
        if (self.destinationSelector == 0) {
            self.endingLocation = self.dictionary[[self keyForSection:indexPath.section]][indexPath.row];
            self.locationTwoLabel.text = self.endingLocation.address;
            cell.backgroundColor = [UIColor blueColor];
            self.directionsButton.enabled = true;
        }
        else {
            self.startingLocation = self.dictionary[[self keyForSection:indexPath.section]][indexPath.row];
            self.locationOneLabel.text = self.startingLocation.address;
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
        if (error) {
            [NetworkErrorAlert showAlertForViewController:self];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeLocationNotification" object:nil];
            [self moveLocation:location FromSection:indexPath.section];
        }
    }];

}

#pragma mark - LocationManagerDelegate methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            self.currentLocation = location;
            [self.locationManager stopUpdatingLocation];
        }
    }
}

#pragma mark - IBActions


- (IBAction)onPressedEnterEditingMode:(UIBarButtonItem *)sender {
    if (sender.tag == 0) {
        self.tableView.editing = YES;
        sender.tag = 1;
    }
    else {
        self.tableView.editing = NO;
        sender.tag = 0;
    }
}

- (IBAction)onPressedSetDestinations:(UIButton *)sender {
    if (sender.tag == 0) {
        sender.tag = 1;
        [sender setBackgroundColor:[UIColor orangeColor]];
    }
    else {
        sender.tag = 0;
        [sender setBackgroundColor:[UIColor clearColor]];
    }
}

- (IBAction)getDirectionsOnTapped:(UIButton *)sender {
    CLLocationCoordinate2D startingCoordinate = CLLocationCoordinate2DMake(self.startingLocation.coordinate.latitude, self.startingLocation.coordinate.longitude);
    CLLocationCoordinate2D endingCoordinate = CLLocationCoordinate2DMake(self.endingLocation.coordinate.latitude, self.endingLocation.coordinate.longitude);
    [Direction getDirectionsWithCoordinate:startingCoordinate andEndingPosition:endingCoordinate withTypeOfTransportation:self.typeOfTransportation andBlock:^(NSArray *directionArray    , NSError *error) {
        if (error) {
            [NetworkErrorAlert showAlertForViewController:self];
        }
        else {
            self.directionsArray = [NSArray arrayWithArray:directionArray];
            UniversalRegion *sharedRegion = [UniversalRegion sharedRegion];
            sharedRegion.directions = directionArray;
            [self.tableView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayPolyLine" object:nil];
        }
    }];

}
- (IBAction)didTapOnLocationOneLabel:(UITapGestureRecognizer *)sender {
    [self expandDirectionsView];
    if (self.endingDestination) {
        self.endingDestination = false;
        self.locationOneLabel.backgroundColor = [UIColor lightGrayColor];
        self.locationTwoLabel.backgroundColor = [UIColor whiteColor];
    }

    if (self.startingLocation == nil) {
        self.startingLocation = [Location new];
        self.startingLocation.coordinate = [PFGeoPoint geoPointWithLocation: self.currentLocation];
    }
}

- (IBAction)didTapOnLocationTwoLabel:(UITapGestureRecognizer *)sender {
    self.endingDestination = true;
    self.locationTwoLabel.backgroundColor = [UIColor lightGrayColor];
}

- (IBAction)switchTableViewDisplayOnTapped:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.displayDirections = false;
    }
    else {
        self.displayDirections = true;
    }
    [self.tableView reloadData];
}

- (IBAction)switchModeOnTransOnTapped:(UIButton *)sender {

    switch (sender.tag) {
        case 0:
            //Selected to use Transit
            self.typeOfTransportation = @"transit";
            break;
        case 1:
            //Selected to Drive
            self.typeOfTransportation = @"driving";
            break;
        case 2:
            //Selected to Walk
            self.typeOfTransportation = @"walking";
            break;
        case 3:
            //Selected to Bike
            self.typeOfTransportation = @"bicycling";
            break;
        default:
            break;
    }

}


#pragma mark - Methods for movement of directionsView
-(void)reduceDirectionsViewInViewDidLoad {
    self.goButtonWidthConstraint.constant = 0.0;
    self.topViewHeightConstraint.constant = self.locationOneLabel.frame.size.height + 20;
    self.locationTwoLabel.hidden = true;
    for (UIButton *button in self.transportationButtons) {
        button.hidden = true;
    }
}

//Expands directions View to display the full view and button animated
-(void)expandDirectionsView {
    if (self.wantDirections == false) {
        [UIView animateWithDuration:0.3 animations:^{
            self.goButtonWidthConstraint.constant = 40.0;
            self.topViewHeightConstraint.constant = self.locationOneLabel.frame.size.height + self.locationTwoLabel.frame.size.height + self.transitButton.frame.size.height + 60;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.locationTwoLabel.hidden = false;
            for (UIButton *button in self.transportationButtons) {
                button.hidden = false;
            }
        }];
        self.wantDirections = true;
    }
    else {
        self.wantDirections = false;
        [UIView animateWithDuration:0.3 animations:^{
            [self reduceDirectionsViewInViewDidLoad];
            [self.view layoutIfNeeded];
        }];
    }
}


#pragma mark - methods for finding correct key or value for dictionary
-(NSString *)keyForSection:(NSInteger)section {
    return section == 0 ? kNeedToVisitString : kVisitedString;
}

-(NSString *)keyForOppositeSection:(NSInteger)section {
    return section == 0 ? kVisitedString : kNeedToVisitString;
}

-(NSArray *)arrayForSection:(NSInteger)section {
    return section == 0 ? self.dictionary[kNeedToVisitString] : self.dictionary[kVisitedString];
}

#pragma mark - method for moving position of locations
-(void)moveLocation:(Location *)location FromSection:(NSInteger)section {
    NSMutableArray *forSection = section == 1 ? [self.dictionary[kVisitedString] mutableCopy] : [self.dictionary[kNeedToVisitString] mutableCopy];
    [forSection removeObject:location];
    NSMutableArray *toSection = section == 1 ? [self.dictionary[kNeedToVisitString]mutableCopy] : [self.dictionary[kVisitedString]mutableCopy];
    [toSection addObject:location];
    [self.dictionary[[self keyForSection:section]] removeObject:location];
    [self.dictionary[[self keyForOppositeSection:section]] addObject:location];
    [self.tableView reloadData];
}

@end

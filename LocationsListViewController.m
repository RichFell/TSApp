//
//  LocationsListViewController.m
//  TSApp
//
//  Created by Rich Fellure on 8/10/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "LocationsListViewController.h"
#import "LocationTableViewCell.h"
#import "NetworkErrorAlert.h"
#import "UserDefaults.h"
#import "HeaderTableViewCell.h"
#import "Direction.h"
#import <CoreLocation/CoreLocation.h>
#import "DirectionTableViewCell.h"
#import "MapModel.h"
#import "CDLocation.h"

@interface LocationsListViewController ()<UITableViewDataSource, UITableViewDelegate, LocationTVCellDelegate, CLLocationManagerDelegate, UISearchBarDelegate>

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goButtonWidthConstraint;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *transportationButtons;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarOne;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarTwo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

#pragma mark - Variables
@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property CDLocation *startingLocation;
@property CDLocation *endingLocation;
@property NSArray *directionsArray;
@property BOOL wantDirections;
@property BOOL displayDirections;
@property BOOL firstTapOnCurrentPosition;
@property BOOL selectFirstPostion;
@property NSString *typeOfTransportation;
@property NSArray *titleArray;

@end

@implementation LocationsListViewController

#pragma mark - Constants
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
static NSString *const kChangeLocationNotif = @"ChangeLocationNotification";
static NSString *const kDisplayPolyLineNotif = @"DisplayPolyLine";


#pragma mark - View LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.displayDirections = false;
    self.firstTapOnCurrentPosition = true;
    self.typeOfTransportation = @"driving";
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    self.wantDirections = false;
    self.searchBarOne.text = @"Current Location";
    self.titleArray = @[kNeedToVisitString, kVisitedString];
    self.view.backgroundColor = [UIColor customTableViewBackgroundGrey];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self reduceDirectionsViewInViewDidLoad];
    [self.tableView reloadData];
}

#pragma mark - helper methods
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
        CDLocation *location = self.currentRegion.sortedArrayOfLocations[indexPath.section][indexPath.row];
        if (location == self.startingLocation) {
            cell.backgroundColor = [UIColor greenColor];
        }
        else if (location == self.endingLocation) {
            cell.backgroundColor = [UIColor blueColor];
        }
        else {
            cell.backgroundColor = [UIColor whiteColor];
        }

        cell.infoLabel.text = location.name;
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.addressLabel.text = location.localAddress ? location.localAddress : @"No Address";
        cell.visitedButton.imageView.image =  location.hasVisited == false ? [UIImage imageNamed:kCheckMarkImageName] : [UIImage imageNamed:kPlaceHolderImageName];
        int position = (int)indexPath.row;
        cell.countLabel.text = [NSString stringWithFormat:@"%d", position + 1];
        return cell;
    }
}

///does the call for directions between the startingCoordinate and the endingCoordinate
-(void)askForDirections {

    NSString *directionType = self.typeOfTransportation != nil ? self.typeOfTransportation : @"driving";
    [Direction getDirectionsWithCoordinate:self.startingLocation.coordinate andEndingPosition:self.endingLocation.coordinate withTypeOfTransportation:directionType andBlock:^(NSArray *directionArray, NSError *error) {
        if (directionArray != nil) {
            self.directionsArray = [NSArray arrayWithArray:directionArray];
            [self.delegate didGetNewDirections:self.directionsArray];
            self.segmentedControl.momentary = NO;
            self.segmentedControl.selectedSegmentIndex = 1;
            self.displayDirections = true;
            [self.tableView reloadData];
        }
        else {
            [NetworkErrorAlert showAlertForViewController:self];
        }
    }];
}

#pragma mark - UITableViewDataSource Delegate Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self returnCorrectCellforIndexpath:indexPath forTableView:tableView];
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHeaderCellID];
    cell.headerTitleLabel.text = self.titleArray[section];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.displayDirections ? 0.0 : 40.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.displayDirections ? 1 : self.titleArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.currentRegion.sortedArrayOfLocations[section];
    return self.displayDirections ? self.directionsArray.count : array.count;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CDLocation *location = self.currentRegion.sortedArrayOfLocations[indexPath.section][indexPath.row];
        [self.currentRegion removeLocationFromLocations:location completed:^(BOOL result) {
            [self.tableView reloadData];
        }];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.displayDirections) {
        return false;
    }
    else {
        return true;
    }
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return false;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CDLocation *selectedLocation = self.currentRegion.sortedArrayOfLocations[indexPath.section][indexPath.row];

    if (self.wantDirections) {
        if (!self.selectFirstPostion) {
            self.endingLocation = selectedLocation;
            self.searchBarTwo.text = self.endingLocation.localAddress;
            cell.backgroundColor = [UIColor blueColor];
        }
        else {
            self.startingLocation = selectedLocation;
            self.searchBarOne.text = self.startingLocation.localAddress;
            cell.backgroundColor = [UIColor greenColor];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

#pragma mark - LocationTableViewCellDelegate method
-(void)didTapVisitedButtonAtIndexPath:(NSIndexPath *)indexPath
{
    CDLocation *location = self.currentRegion.sortedArrayOfLocations[indexPath.section][indexPath.row];
    location.hasVisited = !location.hasVisited;
    [self.tableView reloadData];
    [self.delegate didMoveLocation:location];
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
- (IBAction)getDirectionsOnTapped:(UIButton *)sender {
    [self askForDirections];
}

- (IBAction)switchTableViewDisplayOnTapped:(UISegmentedControl *)sender {

    self.displayDirections = sender.selectedSegmentIndex == 0 ? false : true;
    [self.tableView reloadData];
}

- (IBAction)switchModeOnTransOnTapped:(UIButton *)sender {
    for (UIButton *button in self.transportationButtons) {
        [button setHighlighted: false];
    }
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
    [sender setHighlighted:true];
    for (UIButton * button in self.transportationButtons) {
        button.backgroundColor = button.highlighted == true ? [UIColor orangeColor] : [UIColor clearColor];
    }
}


#pragma mark - Methods for movement of directionsView
-(void)reduceDirectionsViewInViewDidLoad {
    self.goButtonWidthConstraint.constant = 0.0;
    self.topViewHeightConstraint.constant = self.searchBarOne.frame.size.height + 20;
    self.searchBarTwo.hidden = true;
    for (UIButton *button in self.transportationButtons) {
        button.hidden = true;
    }
}

//Expands directions View to display the full view and button animated
-(void)expandDirectionsView {
    if (self.wantDirections == false) {
        [UIView animateWithDuration:0.3 animations:^{
            self.goButtonWidthConstraint.constant = 40.0;
            UIButton *button = self.transportationButtons[0];
            CGFloat buttonHeight = button.frame.size.height;
            self.topViewHeightConstraint.constant = self.searchBarOne.frame.size.height + self.searchBarTwo.frame.size.height + buttonHeight + 20.0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.searchBarTwo.hidden = false;
            [self.view endEditing:true];
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

#pragma mark - searchBarDelegate Methods
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if ([searchBar isEqual:self.searchBarOne]) {
        if (self.firstTapOnCurrentPosition == true) {
            CDLocation *location = [[CDLocation alloc]initWithDefault:self.currentLocation.coordinate];
            self.startingLocation = location;
            self.firstTapOnCurrentPosition = !self.firstTapOnCurrentPosition;
            [self expandDirectionsView];
        }
        else {
            self.selectFirstPostion = true;
        }
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [MapModel geocodeString:searchBar.text withBlock:^(CLLocationCoordinate2D coordinate, NSError *error) {
        if (error) {
            [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
        }
        else {

            NSArray *array = self.currentRegion.sortedArrayOfLocations[0];
            NSNumber *index = [NSNumber numberWithLong:array.count];
            CDLocation *location = [[CDLocation alloc]initWithCoordinate:coordinate andName:@"" atIndex:index forRegion:self.currentRegion atAddress:searchBar.text];
            [self askToSaveLocationAlert:location];
            if ([searchBar isEqual:self.searchBarOne]) {
                self.startingLocation = location;
            }
            else {
                self.endingLocation = location;
            }
            [self askForDirections];
        }
    }];
}


#pragma mark - Save Location Alerts
-(void)askToSaveLocationAlert:(CDLocation *)location {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Would you like to save this to your location list?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self saveLocationAlertForLocation:location];
    }];
    [alertController addAction:yesAction];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:noAction];
    [self presentViewController:alertController animated:true completion:nil];
}

-(void)saveLocationAlertForLocation:(CDLocation *)location {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Give the Location a name" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Add name here";
    }];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields[0];
        location.name = textField.text;
        [location saveLocation];
    }];
    [alertController addAction:saveAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction: cancelAction];
    [self presentViewController:alertController animated:true completion:nil];
}


@end

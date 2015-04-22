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
#import "Direction.h"
#import <CoreLocation/CoreLocation.h>
#import "MapModel.h"
#import "CDLocation.h"
#import "DirectionsViewController.h"
#import "DirectionsListViewController.h"
#import "DirectionSet.h"
#import "LocationSelectionViewController.h"
#import "HeaderView.h"

@interface LocationsListViewController ()<UITableViewDataSource, UITableViewDelegate, LocationTVCellDelegate, CLLocationManagerDelegate, LocationSelectionVCDelegate>

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *slidingImageView;
@property (weak, nonatomic) IBOutlet UIButton *getDirectionsButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *directionContainterTopConstraint;

#pragma mark - Variables
@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property BOOL wantDirections;
@property BOOL displayDirections;
@property BOOL firstTapOnCurrentPosition;
@property (nonatomic) BOOL selectFirstPosition;
@property NSString *typeOfTransportation;
@property NSArray *titleArray;
@property CGFloat startingContainerBottomConstant;
@property CGFloat startingImageViewConstant;
@property DirectionsViewController *directionsVC;
@property LocationSelectionViewController *locationSelectionVC;

@end

@implementation LocationsListViewController

#pragma getters and setters
-(BOOL)selectFirstPostion {
    return self.locationSelectionVC.selectFirstPosition;
}

#pragma mark - Constants

static NSString *const kLocationCellId = @"LocationTableViewCell";
static NSString *const kHeaderCellID = @"headerCell";
static NSString *const kDirectionsCellID = @"DirectionCell";
static NSString *const kCheckMarkImageName = @"CheckMarkImage";
static NSString *const kDirectionSegue = @"DirectionSegue";

#pragma mark - static variables
static CGFloat topViewStartingHeight;
static NSIndexPath *startingIndexPath;
static NSIndexPath *endingIndexPath;

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
    self.titleArray = @[kNeedToVisitString, kVisitedString];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self reduceDirectionsViewInViewDidLoad];
    self.segmentedControl.selectedSegmentIndex = 1;
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:true];
    self.imageViewTopConstraint.constant = self.view.frame.size.height - self.slidingImageView.frame.size.height;
    self.containerViewBottomConstraint.constant = -self.view.frame.size.height + self.slidingImageView.frame.size.height;
    self.startingContainerBottomConstant = self.containerViewBottomConstraint.constant;
    self.startingImageViewConstant = self.imageViewTopConstraint.constant;
    self.slidingImageView.image = [UIImage imageNamed:kUpArrowImage];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[DirectionsViewController class]]) {
        self.directionsVC = segue.destinationViewController;
    }
    else if ([segue.destinationViewController isKindOfClass:[DirectionsListViewController class]]) {
        DirectionsListViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        vc.selectedLocation = self.currentRegion.sortedArrayOfLocations[indexPath.section][indexPath.row];
    }
    else if ([segue.destinationViewController isKindOfClass:[LocationSelectionViewController class]]) {
        self.locationSelectionVC = segue.destinationViewController;
        self.locationSelectionVC.delegate = self;
    }
}
#pragma mark - helper methods



#pragma mark - Helper Methods for sliding of the container view

-(void)animateContainerUp {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.containerViewBottomConstraint.constant = 0;
        self.imageViewTopConstraint.constant = kImageViewConstraintConstantOpen;
        self.directionContainterTopConstraint.constant = -CGRectGetHeight(self.slidingImageView.frame);
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.slidingImageView.image = [UIImage imageNamed:kDownArrowImage];
    }];
}

-(void)animateContainerDown {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.containerViewBottomConstraint.constant = -self.view.frame.size.height + self.slidingImageView.frame.size.height;
        self.imageViewTopConstraint.constant = self.view.frame.size.height - self.slidingImageView.frame.size.height;
        self.directionContainterTopConstraint.constant = 1.0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.slidingImageView.image = [UIImage imageNamed:kUpArrowImage];
    }];
}

#pragma mark - UITableViewDataSource Delegate Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLocationCellId];
    CDLocation *location = self.currentRegion.sortedArrayOfLocations[indexPath.section][indexPath.row];
    cell.backgroundColor = [indexPath isEqual: startingIndexPath] ? [UIColor lightGrayColor] : [indexPath isEqual: endingIndexPath] ? [UIColor darkGrayColor] : [UIColor whiteColor];
    cell.infoLabel.text = location.name;
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.addressLabel.text = location.localAddress ? location.localAddress : @"No Addres    s";
    [cell.visitedButton setImage: location.hasVisited == true ? [UIImage imageNamed:kCheckMarkImageName] : [UIImage imageNamed:kPlaceHolderImage] forState:UIControlStateNormal];
    int position = (int)indexPath.row;
    cell.countLabel.text = [NSString stringWithFormat:@"%d", position + 1];
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderView *headerView = [[HeaderView alloc]initWithFrame:tableView.frame];
    headerView.headerLabel.text = self.titleArray[section];

    if (self.currentRegion.sortedArrayOfLocations.count <= 0) {
        headerView = nil;
    }
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.currentRegion.sortedArrayOfLocations.count <= 0) {
        return 0;
    }
    return kTableViewHeaderHeight;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.titleArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.currentRegion.sortedArrayOfLocations[section];
    return array.count;
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
        [self.locationSelectionVC giveALocation:selectedLocation];
        if (!self.selectFirstPostion) {
            cell.backgroundColor = [UIColor customDarkGrey];
            endingIndexPath = indexPath;
        }
        else {
            cell.backgroundColor = [UIColor customLightGrey];
            startingIndexPath = indexPath;
        }
    }
    else {
        [self performSegueWithIdentifier:kDirectionSegue sender:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

#pragma mark - LocationTableViewCellDelegate method
-(void)didTapVisitedButtonAtIndexPath:(NSIndexPath *)indexPath
{
    CDLocation *location = self.currentRegion.sortedArrayOfLocations[indexPath.section][indexPath.row];
    location.hasVisited = !location.hasVisited;
    [self.tableView reloadData];
    [self.delegate locationListVC:self didChangeLocation:location];
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

- (IBAction)expandDirectionsViewOnTap:(UIButton *)sender {
    [self expandDirectionsView];
}

- (IBAction)flipBackToMapOnTap:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    }
}

- (IBAction)arrowTapped:(UITapGestureRecognizer *)sender {
    if ([sender locationInView:self.view].y > self.view.frame.size.height / 2) {
        [self animateContainerUp];
    }
    else {
        [self animateContainerDown];
    }
}

#pragma mark - Methods for movement of directionsView
-(void)reduceDirectionsViewInViewDidLoad {
    topViewStartingHeight = self.topContainerHeightConstraint.constant;
    self.topContainerHeightConstraint.constant = 0.0;

}

//Expands directions View to display the full view and button animated
-(void)expandDirectionsView {
    self.wantDirections = true;
    self.getDirectionsButton.hidden = true;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.tableViewTopConstraint.constant = topViewStartingHeight - self.getDirectionsButton.frame.size.height;
        self.topContainerHeightConstraint.constant = topViewStartingHeight;
        [self.view layoutIfNeeded];
    }];
}

-(void)animateDirectionsViewClosed {
    self.wantDirections = false;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.topContainerHeightConstraint.constant = 0.0;
        self.tableViewTopConstraint.constant = kTSSpacing;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            self.getDirectionsButton.hidden = false;
        }
    }];
}

#pragma mark - LocationSelectVCDelegate Methods
-(void)locationSelectionVC:(LocationSelectionViewController *)viewController didTapDone:(BOOL)done {
    [self animateDirectionsViewClosed];
}

-(void)locationSelectionVC:(LocationSelectionViewController *)viewController isSettingStartingLocation:(BOOL)isStartingLocation {
    self.selectFirstPosition = isStartingLocation;
}

@end

//
//  LocationsListViewController.m
//  TSApp
//
//  Created by Rich Fellure on 8/10/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "LocationsListViewController.h"
#import "LocationTableViewCell.h"
#import "ParseModel.h"
#import "MapModel.h"
#import "DirectionsViewController.h"
#import "NetworkErrorAlert.h"


@interface LocationsListViewController ()<UITableViewDataSource, UITableViewDelegate, ParseModelDataSource, MapModelDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIButton *setDestinationsButton;
@property (weak, nonatomic) IBOutlet UIButton *callDirectionsButton;

@property UIView *locationsView;
@property UITextField *locationOneTextField;
@property UITextField *locationTwoTextField;
@property UIButton *produceDirectionsButton;

@property ParseModel *aParseModel;
@property MapModel *mapModel;
@property int destinationSelector;
@property Location *startingLocation;
@property Location *endingLocation;
@property NSArray *directionsArray;

@end

@implementation LocationsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.aParseModel = [[ParseModel alloc]init];
    self.aParseModel.delegate = self;

    self.navigationItem.title = self.region.name;
    UINavigationItem *item = self.navBar.items[0];
    item.title = self.region.name;

    self.setDestinationsButton.tag = 0;
    self.destinationSelector = 0;

    self.mapModel = [[MapModel alloc]init];
    self.mapModel.delegate = self;

    self.callDirectionsButton.enabled = false;

    self.view.backgroundColor = [UIColor customTableViewBackgroundOrange];
    self.tableView.backgroundColor = [UIColor clearColor];
}

#pragma mark - UITableViewDataSource Delegate Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rwfLocationTableViewCellID];

    Location *location = [self.locations objectAtIndex:indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    cell.button.tag = 0;

    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", location.index];

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locations.count;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Location *location = [self.locations objectAtIndex:indexPath.row];
        [location deleteLocationWithBlock:self.locations completed:^(BOOL result, NSError *error) {

            if (error == nil)
            {
                [self.locations removeObject:location];
                [self.tableView reloadData];
            }
            else
            {
                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
            }
        }];
    }
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return true;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.aParseModel reorderLocationsArray:sourceIndexPath endIndex:destinationIndexPath array:self.locations];

    Location *location = [self.locations objectAtIndex:sourceIndexPath.row];
    [self.locations removeObject: location];
    [self.locations insertObject:location atIndex:destinationIndexPath.row];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (self.setDestinationsButton.tag == 1)
    {
        if (self.destinationSelector == 0)
        {
            self.destinationSelector = 1;
            self.startingLocation = [self.locations objectAtIndex:indexPath.row];

            cell.backgroundColor = [UIColor blueColor];
        }
        else
        {
            self.destinationSelector = 0;
            self.endingLocation = [self.locations objectAtIndex:indexPath.row];

            cell.backgroundColor = [UIColor greenColor];

            self.callDirectionsButton.enabled = true;
        }
    }
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

    [self performSegueWithIdentifier:@"DirectionsSegue" sender:self];
}

#pragma mark - IBActions

- (IBAction)onPressedDismissViewController:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}

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
- (IBAction)onPressedChangeVisitedImage:(UIButton *)sender
{
//    UIButton *button = (UIButton *)sender;
//
//    LocationTableViewCell *cell = (LocationTableViewCell *)[[sender superview]superview];
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    Location *selectedLocation = [self.locations objectAtIndex:indexPath.row];
//
//    if (button.tag == 0)
//    {
//        [button setImage: [UIImage imageNamed:@"placemarker_Image"] forState:UIControlStateNormal];
//        [selectedLocation changeVisitedStatusWithBlock:^(BOOL result, NSError *error) {
//            if (error != nil)
//            {
//                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
//            }
//        }];
//        button.tag = 1;
//    }
//    else
//    {
//        [button setImage:[UIImage imageNamed:@"UserLocation_Image"] forState:UIControlStateNormal];
//        [selectedLocation changeVisitedStatusWithBlock:^(BOOL result, NSError *error) {
//            if (error != nil)
//            {
//                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
//            }
//        }];
//        button.tag = 0;
//    }
}

- (IBAction)onPressedSetDestinations:(UIButton *)sender
{
    if (sender.tag == 0)
    {
        sender.tag = 1;
        [sender setBackgroundColor:[UIColor orangeColor]];
        [self presentNewLocationsView];
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

        [self.mapModel getDirections: startingCoordinate endingPosition:endingCoordinate];
    }
}

-(void)presentNewLocationsView
{

    self.locationsView = [[UIView alloc]initWithFrame:CGRectMake(10.0, 50.0, 300.0, 80.0)];
    self.locationsView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.locationsView];

    //TODO: Need to make it so that when the View is presented, the TableView moves down, and when dismissed, the tableView moves back. For some reason changing the frame is not having the desired effect. Need to get this worked out.
    self.tableView.frame = CGRectMake(0.0, 230.0, 320.0, 400.0);

//    [self.view addSubview:self.tableView];

    self.locationOneTextField = [[UITextField alloc]initWithFrame:CGRectMake(5.0, 10.0, 70.0, 30.0)];
    [self.locationsView addSubview:self.locationOneTextField];
    [self.locationsView bringSubviewToFront:self.locationOneTextField];

    self.locationTwoTextField = [[UITextField alloc]initWithFrame:CGRectMake(40.0, 10.0, 70.0, 30.0)];
    [self.locationsView addSubview:self.locationTwoTextField];
    [self.locationsView bringSubviewToFront:self.locationTwoTextField];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DirectionsViewController *directionVC = segue.destinationViewController;
    directionVC.directions = [NSArray arrayWithArray:self.directionsArray];
}


@end

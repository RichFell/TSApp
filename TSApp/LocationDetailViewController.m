//
//  LocationDetailViewController.m
//  TSApp
//
//  Created by Rich Fellure on 5/1/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "LocationDetailViewController.h"
#import "CDLocation.h"

@class TSButton;

@interface LocationDetailViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *directionContainerTopConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *getDirectionsButTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *directionContainerBottomConstraint;


@property (weak, nonatomic) IBOutlet TSButton *getDirectionsButton;
@property (weak, nonatomic) IBOutlet TSButton *saveDirectionsButton;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;


@end

@implementation LocationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.selectedLocation.name;
    self.addressLabel.text = self.selectedLocation.localAddress;
}

@end

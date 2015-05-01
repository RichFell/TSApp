//
//  FirstTripViewController.m
//  TSApp
//
//  Created by Rich Fellure on 4/26/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "FirstTripViewController.h"
#import "CreateTripViewController.h"

@interface FirstTripViewController ()<CreateTripVCDelegate>

@end

@implementation FirstTripViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}
- (IBAction)showCreateTripVCOnTap:(UIButton *)sender {
    CreateTripViewController *createVC = [CreateTripViewController storyboardInstance];
    createVC.delegate = self;
    UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:createVC];
    [self presentViewController:navVc animated:true completion:nil];
}

-(void)createTripViewController:(CreateTripViewController *)viewController didSaveNewRegion:(CDRegion *)region {
    //TODO: Need to find a more elegant way of accomplishing this.
    [[NSNotificationCenter defaultCenter]postNotificationName:kCreatedFirstTrip object:nil];
    [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:false completion:nil];
}

@end

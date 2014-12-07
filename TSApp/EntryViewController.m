//
//  EntryViewController.m
//  TSApp
//
//  Created by Rich Fellure on 12/5/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "EntryViewController.h"
#import <FacebookSDK/FaceBookSDK.h> 
#import <Parse/Parse.h>

@interface EntryViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsCollection;

@end

@implementation EntryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupButtonBackground];
}

-(void)setupButtonBackground
{
    for (UIButton *button in self.buttonsCollection)
    {
        button.backgroundColor = [UIColor customOrange];
    }
}

+(EntryViewController *)newStoryboardInstance
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"EntryViewController"];
}


- (IBAction)connectWithFacebookOnTapped:(UIButton *)sender
{

}

@end

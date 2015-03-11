//
//  EntryViewController.m
//  TSApp
//
//  Created by Rich Fellure on 12/5/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "EntryViewController.h"
#import <Parse/Parse.h>
#import "NetworkErrorAlert.h"
#import "FBSessionManager.h"

@interface EntryViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsCollection;

@end

@implementation EntryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupButtonBackground];
}

-(void)setupButtonBackground {
    for (UIButton *button in self.buttonsCollection) {
        button.backgroundColor = [UIColor customOrange];
    }
}

+(EntryViewController *)newStoryboardInstance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"EntryViewController"];
}


- (IBAction)connectWithFacebookOnTapped:(UIButton *)sender {
    [FBSessionManager createNewSessionWithBlock:^(BOOL result, NSError *error) {
        if (result == true) {

        }
        else {
            [self showAlertWithTitle:@"There was a problem" andMessage:error.localizedDescription];
        }
    }];
}

-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end

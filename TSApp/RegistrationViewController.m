//
//  RegistrationViewController.m
//  TSApp
//
//  Created by Rich Fellure on 12/5/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "RegistrationViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "NetworkErrorAlert.h"
#import "RegistrationViewController.h"

@interface RegistrationViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordTextFieldOne;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextFieldTwo;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;

@end

@implementation RegistrationViewController

+(RegistrationViewController *)storyboardInstance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"RegistrationVC"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.createAccountButton.backgroundColor = [UIColor customOrange];
    self.passwordTextFieldOne.backgroundColor = [UIColor customLightGrey];
    self.passwordTextFieldTwo.backgroundColor = [UIColor customLightGrey];
    self.usernameTextField.backgroundColor = [UIColor customLightGrey];

}

- (IBAction)createAccountOnTapped:(UIButton *)sender {
    if ([self.passwordTextFieldOne.text isEqualToString:self.passwordTextFieldTwo.text]) {

        [User createUserWithUserName:self.usernameTextField.text withPassword:self.passwordTextFieldOne.text andEmail:nil completion:^(BOOL result, NSError *error) {
            if (!result) {
                [NetworkErrorAlert showAlertForViewController:self];
            }
            else {
                [[NSUserDefaults standardUserDefaults]setBool:true forKey:kHasBeenRun];
                [self performSegueWithIdentifier:@"FirstTripSegue" sender:nil];
            }
        }];
    }
}

#pragma mark - TextField Delegate methods
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return true;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.passwordTextFieldTwo) {
        [self moveTheView:0];
    }
    else if (textField == self.passwordTextFieldOne) {
        [self moveTheView:1];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:true];
    return true;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self moveTheView:2];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

#pragma mark - helper method
-(void)moveTheView:(int)decider
{
    CGFloat y;

    switch (decider) {
        case 0:
            y = -100.0;
            break;
        case 1:
            y = -50.0;
            break;
        case 2:
            y = 0.0;
        default:
            break;
    }

    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

@end

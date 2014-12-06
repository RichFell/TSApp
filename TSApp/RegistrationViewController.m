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

@interface RegistrationViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordTextFieldOne;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextFieldTwo;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@end

@implementation RegistrationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)createAccountOnTapped:(UIButton *)sender
{
    if ([self.passwordTextFieldOne.text isEqualToString:self.passwordTextFieldTwo.text])
    {
        [User signUpNewUserWithUsername:self.usernameTextField.text withPassword:self.passwordTextFieldTwo.text withEmail:nil andCompletion:^(PFUser *user, NSError *error) {
            if (error)
            {
                [NetworkErrorAlert showAlertForViewController:self];
            }
            else
            {
                [self performSegueWithIdentifier:@"loggedInSegue" sender:self];
            }
        }];
    }

}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return true;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:true];
    return true;
}

@end

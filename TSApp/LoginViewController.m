//
//  LoginViewController.m
//  TSApp
//
//  Created by Rich Fellure on 8/21/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "User.h"

@interface LoginViewController ()<UITextFieldDelegate, FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

static NSString *const kMoveForwardSegue = @"LoginSegue";
static CGFloat const kYForKeyboardAnimation = -200.0;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupElements];
}

- (IBAction)onPressedLogin:(UIButton *)sender
{
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (error == nil)
        {
            [self didLogin];
        }
        else
        {
            //TODO: Here is an error message for us to evaluate
            [self errorMessage:@"Sorry either the username or password entered were incorrect, please try again" andMessage:@"If you forgot your username or password, you can use the forgot password button to receive a change of password email"];
        }
    }];
}

-(void)setupElements
{
    self.usernameTextField.backgroundColor = [UIColor customLightGrey];
    self.passwordTextField.backgroundColor = [UIColor customLightGrey];
    self.loginButton.backgroundColor = [UIColor customOrange];
}


-(void)didLogin
{
    [self performSegueWithIdentifier:kMoveForwardSegue sender:self];
}

#pragma mark - TextField Delegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0, kYForKeyboardAnimation, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
//    [self.parseModel userSignUp:user.name andPassword:user.password andEmail:user.email];
}

-(void)errorMessage: (NSString *)title andMessage: (NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message: message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:true];
}

@end

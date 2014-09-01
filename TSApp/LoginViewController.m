//
//  LoginViewController.m
//  TSApp
//
//  Created by Rich Fellure on 8/21/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "LoginViewController.h"
#import "ParseModel.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>


@interface LoginViewController ()<ParseModelDataSource, UITextFieldDelegate, FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet FBLoginView *fbLoginView;

@property ParseModel *parseModel;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.parseModel = [[ParseModel alloc] init];
    self.parseModel.delegate = self;
    self.signUpButton.tag = 0;
    self.emailTextField.hidden = YES;
}

- (IBAction)onPressedLogin:(UIButton *)sender
{
    [self.parseModel userLogin:self.usernameTextField.text withPassword:self.passwordTextField.text];
}

- (IBAction)onPressedSignUp:(UIButton *)sender
{
    if (self.signUpButton.tag == 0)
    {
        self.emailTextField.hidden = NO;
        self.signUpButton.tag = 1;
    }
    else
    {
        self.emailTextField.hidden = YES;
        [self.parseModel userSignUp:self.usernameTextField.text andPassword:self.passwordTextField.text andEmail:self.emailTextField.text];
    }
}

-(void)didLogin
{
    [self performSegueWithIdentifier:@"moveForward" sender:self];
}

-(void)didSignUp
{
    [self performSegueWithIdentifier:@"moveForward" sender:self];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    return YES;
}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
//    [self.parseModel userSignUp:user.name andPassword:user.password andEmail:user.email];
}

@end

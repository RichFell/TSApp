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
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet FBLoginView *fbLoginView;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.signUpButton.tag = 0;
    self.emailTextField.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidChangeFrameNotification object:nil queue:nil usingBlock:^(NSNotification *note) {

        NSDictionary *info = [note userInfo];
        CGPoint from = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin;
        CGPoint to = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
        CGFloat height;
        double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue];
        CGRect rect = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];

        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        {
            height = to.x - from.x;
        }
        else
        {
            height = to.y - from.y;
        }

        [UIView animateWithDuration:duration animations:^{
            self.view.frame = CGRectMake(0, rect.origin.y - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }];
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
            [self errorMessage:@"Sorry either the username or password entered were incorrect, please try again" andMessage:@"If you forgot your username or password, you can use the forgot password button to receive a change of password email"];
        }
    }];
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
        [User signUpNewUserWithUsername:self.usernameTextField.text withPassword:self.passwordTextField.text withEmail:self.emailTextField.text andCompletion:^(PFUser *user, NSError *error) {
            if (error == nil)
            {
                [self didSignUp];
            }
            else
            {
                [self errorMessage:@"There was an issue submitting for your new account" andMessage:@"This might be a network error, make sure you have either a connection to the internet via your cellular provider, or are connected to wifi"];
            }
        }];
       
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

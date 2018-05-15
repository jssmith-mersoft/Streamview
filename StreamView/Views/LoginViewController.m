//
//  LoginViewController.m
//  StreamView
//
//  Created by Jeff Smith on 4/2/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//


#import "LoginViewController.h"
#import "SWRevealViewController.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *loginTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UILabel *errorMessageTextField;
@end

@implementation LoginViewController{
     AppDelegate *appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
     [[appDelegate moveClient] setDelegate:self];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enteredPressed:(id)sender {
    [[appDelegate moveClient] unregister];
    [[appDelegate moveClient] register:_loginTextField.text];
    /*
    if ([_loginTextField.text isEqualToString:@"a"] && [_passwordTextField.text isEqualToString:@"a"]) {
        NSLog(@"logged in");
        
        [[appDelegate moveClient] unregister];
        [[appDelegate moveClient] register:@"screen"];
        
    } else {
         NSLog(@"Not Logged in");
    }
     */
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"Finsihed Editing");
}

- (void)connectionConnected {
    NSLog(@"DEMO APP: Connection Connected");
    
}
- (void)connectionFailed:(NSError *)message {
    NSLog(@"DEMO APP: Connection Failed");
}
- (void)connectionClosed {
    NSLog(@"DEMO APP: Connection Closed");
}

- (void)promptForAnswerCall:(NSString*)callId caller:(NSString*)CID {}
- (void)onConnecting {}
- (void)onDeclining {}
- (void)onUnanswered {}
- (void)onReset {}
- (void)onError:(NSString*)message title:(NSString*)title {}
- (void)onCallId:(NSString *)callId withPeer:(NSString*)peerId {}
- (void)registrationBroken {
     NSLog(@"DEMO APP:Received Bade Login (registrationBroken)");
    //put up some message
    _errorMessageTextField.hidden = NO;
}
- (void)registrationReceived:(NSString *)id withReg:(MoveRegistration*)reg {
    
    NSLog(@"DEMO APP:Received Login (registration)");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"StreamView" bundle:nil];
    SWRevealViewController *pvc = [storyboard instantiateViewControllerWithIdentifier:@"Reveal"];
    [pvc setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:pvc animated:YES completion:nil];
}
- (void)registrationUpdate:(NSString *)id withReg:(MoveRegistration*)reg {
    NSLog(@"DEMO APP:Received registration update");
}
- (void)registrationSubscribe:(NSString *)id withReg:(MoveRegistration*)reg {
    NSLog(@"DEMO APP:Received Sub");
}
- (void)accountReceived:(MoveAccount *)account {}
- (void)invalidAccountReceived:(NSString*)username contact:(NSString*)contact {
    NSLog(@"DEMO APP:Received invalid account");
}
- (void)notificationReceived:(MoveNotification *)notification{
    NSLog(@"DEMO APP:Received notification");
}
- (void)rawMessageReceived:(NSString *)message {
        NSLog(@"DEMO APP: Raw Message Received: %@", message);
}
- (void)unexpectedMoveError:(NSString*)message title:(NSString*)title hangup:(BOOL)hangup {
    NSLog(@"DEMO APP:Received unexpected Move Error");
}

@end


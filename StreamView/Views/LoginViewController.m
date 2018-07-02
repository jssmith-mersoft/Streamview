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
@property (strong, nonatomic) IBOutlet UIButton *bigMButton;
@property (strong, nonatomic) IBOutlet UITextField *loginTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UILabel *errorMessageTextField;

@property (strong, nonatomic)  NSString *moveURL;
@end

@implementation LoginViewController{
     AppDelegate *appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate moveClient] == nil || ![[appDelegate moveClient] isConnected]) {
        NSLog(@"Connecting to Move");
        // Set up Move Client
        [appDelegate setMoveClient: [[MoveClient alloc] init]];
    }
    [[appDelegate moveClient] setDelegate:self];
    [[appDelegate moveClient] setQuality:QualityHigh];
    
    
    // Do any additional setup after loading the view, typically from a nib.
    _moveURL = kMoveURL;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enteredPressed:(id)sender {
    [[appDelegate moveClient] connectToMove:_moveURL];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"Finsihed Editing");
}
- (IBAction)mPressed:(id)sender {
    [UIView beginAnimations:@"Flip" context:nil];
    [UIView setAnimationDuration:2.0];
    _bigMButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    [UIView commitAnimations];
    
    _loginTextField.text = @"jssmith";
    //_moveURL = @"wss://dev.mersoft.chat:3443/ws";
    //_moveURL = @"wss://move-dev.mersoft.biz/ws";
    //_moveURL = @"wss://192.168.86.240:3443/ws";
     _moveURL = kMoveURLdev;
    NSLog(@"Switch to dev move server %@",_moveURL);
    /*
    [appDelegate setMoveClient: [[MoveClient alloc] init]];
    [[appDelegate moveClient] setQuality:QualityHigh];
    [[appDelegate moveClient] connectToMove:kAltMoveURL];
     
     */
}

- (void)connectionConnected {
    NSLog(@"DEMO APP: Connection Connected");
     [[appDelegate moveClient] register:_loginTextField.text];
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


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
@property (strong, nonatomic) IBOutlet UISwitch *switchPepper;


@property (strong, nonatomic)  NSString *moveURL;
@property (strong, nonatomic)  NSString *token;
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
    
    if ([_switchPepper isOn]) {
        _moveURL = kMoveURLPepper;
    } else {
        _moveURL = kMoveURL;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enteredPressed:(id)sender {
    
    if([_switchPepper isOn]) {
        NSString* url = @"https://dev.api.pepperos.io/authentication/byEmail";
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:@"POST"];
        
        // 64bit encode momentum:username and password to make the basic auth header
        NSString *authStr = [NSString stringWithFormat:@"momentum:%@:%@", _loginTextField.text, _passwordTextField.text];
        NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
       // [request setValue:authValue forHTTPHeaderField:@"Authorization"];
         NSLog(@" the auth header is %@",authValue);
        
        //[request setAllHTTPHeaderFields:@{@"authorization":@"Basic bW9tZW50dW06c3RhZ2luZzMucGVwcGVyQGdtYWlsLmNvbTpQZXBwZXIxMjM0NQ==",@"content-type":@"application/json"}];
        [request setAllHTTPHeaderFields:@{@"authorization":authValue,@"content-type":@"application/json"}];
        //[request setHTTPBody:body];
       // [request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
        [request setURL:[NSURL URLWithString:url]];
        
        NSError *error = nil;
        NSHTTPURLResponse *responseCode = nil;
        
        NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
        
        if([responseCode statusCode] != 200){
            NSLog(@"Error getting %@, HTTP status code %li", url, [responseCode statusCode]);
            return;
        }
        NSError *err = nil;
        //NSString *output = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:oResponseData options:NSJSONReadingAllowFragments error:&err];
        
        //NSLog(@"the results are %@",jsonData[@"token"]);
        NSLog(@"the results are %@",jsonData);
        NSDictionary *pepperUser = jsonData[@"pepperUser"];
        NSLog(@"the accountID are %@",pepperUser[@"account_id"]);
        
         _token = pepperUser[@"account_id"];
        appDelegate.vendor = YES;
        
        if ([appDelegate moveClient].connected){
            [[appDelegate moveClient] register:_loginTextField.text withToken:_token vendor:@"pepper"];
        } else {
            [[appDelegate moveClient] connectToMove:_moveURL];
        }
    } else {
        if ([appDelegate moveClient].connected){
            [[appDelegate moveClient] register:_loginTextField.text];
        } else {
            [[appDelegate moveClient] connectToMove:_moveURL];
        }
    }
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

     _moveURL = kMoveURLdev;
    NSLog(@"Switch to dev move server %@",_moveURL);
    /*
    [appDelegate setMoveClient: [[MoveClient alloc] init]];
    [[appDelegate moveClient] setQuality:QualityHigh];
    [[appDelegate moveClient] connectToMove:kAltMoveURL];
     */
}
- (IBAction)VendorSwitchUpdate:(id)sender {
    _loginTextField.text = @"demo";
     _moveURL = kMoveURL;
}

- (void)connectionConnected {
    if (appDelegate.vendor) {
        [[appDelegate moveClient] register:_loginTextField.text withToken:_token vendor:@"pepper"];
    } else {
         NSLog(@"DEMO APP: Connected to MersoftMove - registering as %@",_loginTextField.text);
        [[appDelegate moveClient] register:_loginTextField.text];
    }
    
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
     NSLog(@"DEMO APP:Received Bad Login (registrationBroken)");
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


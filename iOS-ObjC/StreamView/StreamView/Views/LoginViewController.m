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
@property (strong, nonatomic) IBOutlet UIView *contentView;


@property (strong, nonatomic)  NSString *moveURL;
@property (strong, nonatomic)  NSString *token;
@end

@implementation LoginViewController{
     AppDelegate *appDelegate;
     UITextField *activeField;
     CGRect lastframe;
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
    _loginTextField.delegate = self;
    _passwordTextField.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enteredPressed:(id)sender {
    
    if([_switchPepper isOn]) {
        //NSString* url = @"https://api.pepperos.io/authentication/byEmail";
        NSString* url = @"https://staging.api.pepperos.io/authentication/byEmail";
        //NSString* url = @"https://dev.api.pepperos.io/authentication/byEmail";
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
        
        NSLog(@"the token is %@",jsonData[@"token"]);
        NSLog(@"the data are %@",jsonData);
        NSDictionary *pepperUser = jsonData[@"pepperUser"];
        
        NSLog(@"the accountID are %@",pepperUser[@"account_id"]);
        NSDictionary *cognitoProfile = jsonData[@"cognitoProfile"];
        
         _token = cognitoProfile[@"Token"];
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
     if ([_switchPepper isOn]) {
         _loginTextField.text = @"staging3.pepper@gmail.com";
         _passwordTextField.text = @"Pepper12345";
         _moveURL = kMoveURLPepper;
     } else {
        _loginTextField.text = @"demo";
         _passwordTextField.text = @"Mersoft1!";
        _moveURL = kMoveURL;
     }
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
    
    [[appDelegate moveClient] setToken:[appDelegate fireBaseToken]];
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
-(void)addDevice:(NSDictionary *)data deviceID:(NSString*)deviceID {
    NSLog(@"DEMO APP:New Device added: %@", deviceID);
}
- (void)unexpectedMoveError:(NSString*)message title:(NSString*)title hangup:(BOOL)hangup {
    NSLog(@"DEMO APP:Received unexpected Move Error");
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.view endEditing:YES];
    return YES;
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    lastframe= self.contentView.frame;
    NSLog(@"before keybord %@",NSStringFromCGRect(self.contentView.frame));
    
    // Assign new frame to your view
    CGRect newFrame = lastframe;
    newFrame.origin.y += -110;
    NSLog(@"new frame %@",NSStringFromCGRect(newFrame));
    /*
    [self.contentView setFrame:newFrame]; //here taken -110 for example i.e. your view will be scrolled to -110. change its value according to your requirement.
    */
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    NSLog(@"after keybord lastFrame %@",NSStringFromCGRect(lastframe));
    /*
    [self.contentView setFrame:lastframe];
     */
}

@end


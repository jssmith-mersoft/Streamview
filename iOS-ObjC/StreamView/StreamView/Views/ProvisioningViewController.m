//
//  ProvisioningViewController.m
//  StreamView
//
//  Created by Jeff Smith on 5/10/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//

#import "ProvisioningViewController.h"
#import "SWRevealViewController.h"


@interface ProvisioningViewController ()
@property (strong, nonatomic) IBOutlet UITextField *ssidTextField;

@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *serverTextField;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UISwitch *loggingSwitch;
@property (strong, nonatomic) IBOutlet UILabel *serverLabel;
@property (strong, nonatomic) IBOutlet UIImageView *qrImageView;
@end

@implementation ProvisioningViewController {
    AppDelegate *appDelegate;
}

- (void)viewDidLoad {
    _barButton.target = self.revealViewController;
    _barButton.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //_ssidTextField.text = @"Clydasdale";
    //_passwordTextField.text = @"coffeecup";
    _ssidTextField.text = @"TOF-WiFi";
    _passwordTextField.text = @"Tofasco1661";
    _nameTextField.text = @"DemoCam1";
    //_serverTextField.text = @"ws://move-dev.mersoft.biz/ws";
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)devbutton:(id)sender {
    _ssidTextField.text = @"Mersoft";
    _passwordTextField.text = @"p0p.c0rn";
    _serverTextField.text = @"";
    _serverLabel.hidden = true;
    _serverTextField.hidden = true;
}
- (IBAction)prodbutton:(id)sender {
    _ssidTextField.text = @"Demo-Devices";
    _passwordTextField.text = @"coff33cup";
    _serverTextField.hidden = false;
    _serverLabel.hidden = false;
    _serverTextField.text = @"ws://dev.mersoft.chat:3443/ws";
}

- (IBAction)generate:(id)sender {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    NSMutableString* qrMessage = [NSMutableString new];
    [qrMessage appendString:@"{"];
    NSLog(@"the SSID is %@ and  the password is %@",_ssidTextField.text,_passwordTextField.text);
    if ([_ssidTextField.text length] > 0) {
        NSString *trimmedSID = [_ssidTextField.text stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *trimmedPASS = [_passwordTextField.text stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [qrMessage appendFormat:@"\"wifi\":{\"ssid\":\"%@\",\"password\":\"%@\"},",trimmedSID,trimmedPASS];
    }
    NSLog(@"the client is %@",appDelegate.moveClient.currentReg.registrationId);
    [qrMessage appendFormat:@"\"name\":\"%@\",",_nameTextField.text];
    NSLog(@"the client is %@",appDelegate.moveClient.currentReg.registrationId);
    [qrMessage appendFormat:@"\"client\":\"%@\",",appDelegate.moveClient.currentReg.registrationId];
    NSLog(@"the account is %@",appDelegate.moveClient.currentReg.registrationId);
    [qrMessage appendFormat:@"\"account\":\"%@\",",appDelegate.moveClient.currentReg.accountId];
    
    if (_serverTextField.text.length > 0) {
        NSLog(@"the server is %@",_serverTextField.text);
        [qrMessage appendFormat:@"\"server\":\"%@\",",_serverTextField.text];
    }
    [qrMessage appendFormat:@"\"debug\":%@",(_loggingSwitch.isOn ? @"true":@"false")];
    [qrMessage appendString:@"}"];
    // Generation of QR code image
    NSData *qrCodeData = [qrMessage dataUsingEncoding:NSISOLatin1StringEncoding]; // recommended encoding
    CIFilter *qrCodeFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrCodeFilter setValue:qrCodeData forKey:@"inputMessage"];
    [qrCodeFilter setValue:@"M" forKey:@"inputCorrectionLevel"]; //default of L,M,Q & H modes
    
    CIImage *qrCodeImage = qrCodeFilter.outputImage;
    
    CGRect imageSize = CGRectIntegral(qrCodeImage.extent); // generated image size
    CGSize outputSize = CGSizeMake(240.0, 240.0); // required image size
    CIImage *imageByTransform = [qrCodeImage imageByApplyingTransform:CGAffineTransformMakeScale(outputSize.width/CGRectGetWidth(imageSize), outputSize.height/CGRectGetHeight(imageSize))];
    
    UIImage *qrCodeImageByTransform = [UIImage imageWithCIImage:imageByTransform];
    self.qrImageView.image = qrCodeImageByTransform;
    /*
    // Generation of bar code image
    CIFilter *barCodeFilter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    NSData *barCodeData = [info dataUsingEncoding:NSASCIIStringEncoding]; // recommended encoding
    [barCodeFilter setValue:barCodeData forKey:@"inputMessage"];
    [barCodeFilter setValue:[NSNumber numberWithFloat:7.0] forKey:@"inputQuietSpace"]; //default whitespace on sides of barcode
    
    CIImage *barCodeImage = barCodeFilter.outputImage;
    self.imgViewBarCode.image = [UIImage imageWithCIImage:barCodeImage];
     */
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

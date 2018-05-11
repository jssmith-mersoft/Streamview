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
@property (strong, nonatomic) IBOutlet UISwitch *loggingSwitch;
@property (strong, nonatomic) IBOutlet UIImageView *qrImageView;
@end

@implementation ProvisioningViewController

- (void)viewDidLoad {
    _barButton.target = self.revealViewController;
    _barButton.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)generate:(id)sender {
    NSMutableString* qrMessage = [NSMutableString new];

    NSLog(@"the SSID is %@",_ssidTextField.text);
    [qrMessage appendFormat:@"{\"ssid:\":\"%@\",",_ssidTextField.text];
    NSLog(@"the password is %@",_passwordTextField.text);
    [qrMessage appendFormat:@"\"password:\":\"%@\",",_passwordTextField.text];
    NSLog(@"the account is %@",_passwordTextField.text);
    [qrMessage appendFormat:@"\"account:\":\"%@\",",@"123"];
    if (_serverTextField.text.length > 0) {
        NSLog(@"the server is %@",_serverTextField.text);
        [qrMessage appendFormat:@"\"server:\":\"%@\",",_serverTextField.text];
    }
    [qrMessage appendFormat:@"\"logging\":%@}",(_loggingSwitch.isOn ? @"true":@"false")];
    
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

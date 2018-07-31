//
//  CameraSettingsViewController.m
//  StreamView
//
//  Created by Jeff Smith on 6/14/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//

#import "CameraSettingsViewController.h"
#import "SWRevealViewController.h"

@interface CameraSettingsViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButton;
@property (strong, nonatomic) IBOutlet UILabel *labelDeviceID;
@property (strong, nonatomic) IBOutlet UILabel *labelCamerID;
@property (strong, nonatomic) IBOutlet UILabel *labelCreated;
@property (strong, nonatomic) IBOutlet UILabel *labelAccount;
@property (strong, nonatomic) IBOutlet UILabel *labelType;
@property (strong, nonatomic) IBOutlet UILabel *labelVersion;
@property (strong, nonatomic) IBOutlet UILabel *labelWifiSSID;

@property (strong, nonatomic) IBOutlet UITextField *textFieldName;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchPIRDistance;
@property (strong, nonatomic) IBOutlet UISwitch *switchDND;
@property (strong, nonatomic) IBOutlet UISwitch *switchImageFlip;
@property (strong, nonatomic) IBOutlet UISwitch *switchPrivacyMode;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchRecordDur;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchSirenDur;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchVideoImage;
@property (strong, nonatomic) IBOutlet UISwitch *switchNightVision;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchTimeZone;
@property (strong, nonatomic) IBOutlet UITextField *textName;

@end

@implementation CameraSettingsViewController {
     AppDelegate *appDelegate;
}

- (void)viewDidLoad {
     appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    /*
    _barButton.target = self.revealViewController;
    _barButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
     */
    [super viewDidLoad];
    
    
    NSLog(@"The deviceID = %@",_deviceID);
    [_labelDeviceID setText:_deviceID];
    
    //get the config
    [[appDelegate moveClient] setDelegate:self];
    [[appDelegate moveClient] getConfig:_deviceID];
    
    //populate the config in view
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissView:(id)sender {
   // [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)notificationReceived:(MoveNotification *)notification  {
    NSLog(@"Got notification");
}
- (IBAction)changedName:(id)sender {
    [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"name": _textName.text}];
}
- (IBAction)changedDND:(id)sender {
    if ([_switchDND isOn]) {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"DND": @true}];
    } else {
         [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"DND": @false}];
    }
}
- (IBAction)changedPIRDistance:(id)sender {
    if (_switchPIRDistance.selectedSegmentIndex == 0) {
         [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"PIRdistance": @"LOW"}];
    } else if(_switchPIRDistance.selectedSegmentIndex == 1) {
         [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"PIRdistance": @"MEDIUM"}];
    } else if(_switchPIRDistance.selectedSegmentIndex == 2) {
         [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"PIRdistance": @"HIGH"}];
    }
   
    //[[appDelegate moveClient] updateConfig:_deviceID withData:@{@"PIRdistance": "HIGHT"}];
}
- (IBAction)changedPIRZone:(id)sender {
    [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"PIRZoneMode": @"7"}];
}
- (IBAction)changedFlipImage:(id)sender {
    if ([_switchImageFlip isOn]) {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"imageFlip": @"2"}];
    } else {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"imageFlip": @"0"}];
    }
}
- (IBAction)changedPrivacyMode:(id)sender {
     if ([_switchPrivacyMode isOn]) {
         [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"privacyMode": @true}];
     } else {
         [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"privacyMode": @false}];
     }
}
- (IBAction)changedRecordDur:(id)sender {
    if (_switchRecordDur.selectedSegmentIndex == 0) {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"recordDur": @"SHORT"}];
    } else if (_switchRecordDur.selectedSegmentIndex == 1) {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"recordDur": @"LONG"}];
    }
}
- (IBAction)changedSirenDur:(id)sender {
    [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"sirenDur": @"SHORT"}];
}
- (IBAction)changedVideoImage:(id)sender {
    if (_switchVideoImage.selectedSegmentIndex == 0) {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"videoImage": @"LOW"}];
    } else if (_switchVideoImage.selectedSegmentIndex == 2) {
         [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"videoImage": @"MEDIUM"}];
    } else if (_switchVideoImage.selectedSegmentIndex == 3) {
         [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"videoImage": @"HIGH"}];
    }
}
- (IBAction)changedNightVision:(id)sender {
    if ([_switchNightVision isOn]) {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"nightVision": @true}];
    } else {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"nightVision": @false}];
    }
        
}
- (IBAction)changedDebug:(id)sender {
    [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"debug": @false}];
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

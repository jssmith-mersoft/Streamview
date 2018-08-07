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
@property (strong, nonatomic) IBOutlet UILabel *labelCameraID;
@property (strong, nonatomic) IBOutlet UILabel *labelCreated;
@property (strong, nonatomic) IBOutlet UILabel *labelAccount;
@property (strong, nonatomic) IBOutlet UILabel *labelType;
@property (strong, nonatomic) IBOutlet UILabel *labelVersion;
@property (strong, nonatomic) IBOutlet UILabel *labelWifiSSID;

@property (strong, nonatomic) IBOutlet UITextField *textFieldName;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchPIRDistance;
@property (strong, nonatomic) IBOutlet UISwitch *switchDND;
//@property (strong, nonatomic) IBOutlet UISwitch *switchImageFlip;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchImageFlip;
@property (strong, nonatomic) IBOutlet UISwitch *switchPrivacyMode;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchRecordDur;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchSirenDur;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchVideoImage;
@property (strong, nonatomic) IBOutlet UISwitch *switchNightVision;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchTimeZone;
@property (strong, nonatomic) IBOutlet UITextField *textName;
@property (strong, nonatomic) IBOutlet UISwitch *switchZone1;
@property (strong, nonatomic) IBOutlet UISwitch *switchZone2;
@property (strong, nonatomic) IBOutlet UISwitch *switchZone3;

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

- (void)configChange:(NSDictionary *)data {
    NSLog(@"DEMO APP: got configupdate : %@", data);
    /*
     account = 5b23227fb534b60007b7181b;
     "camera_id" = 4D016B7PAZCCF3C;
     created = "2018-08-03T01:43:33.454Z";
     "device_id" = "Stream-DB11-bdhr6h9sj49ds5arcoug";
     id = 5b63b345fdeeca000b713196;
     parms =     {
     DND = 0;
     PIRZoneMode = 7;
     PIRdistance = MEDIUM;
     debug = 0;
     description = "<null>";
     imageFlip = 0;
     language = eng;
     motion = 0;
     name = lobby;
     nightVision = 0;
     privacyMode = 0;
     recordDur = SHORT;
     sirenDur = SHORT;
     timezone = "-7";
     videoImage = HIGH;
     wifi =         {
     password = "p0p.c0rn";
     ssid = Mersoft;
     };
     };
     type = DB11;
     updated = "2018-08-06T22:40:16.653Z";
     version = "0.1.12";
     */
    
    if (data[@"account"] != nil) {
        _labelAccount.text = (NSString*)data[@"account"];
    }
    if (data[@"camera_id"] != nil) {
        _labelCameraID.text = (NSString*)data[@"camera_id"];
    }
    if (data[@"type"] != nil) {
        _labelType.text = (NSString*)data[@"type"];
    }
    if (data[@"version"] != nil) {
        _labelVersion.text = (NSString*)data[@"version"];
    }
    if (data[@"updated"] != nil) {
        _labelCreated.text = (NSString*)data[@"updated"];
    }
    if (data[@"parms"] != nil) {
        NSDictionary* parms = (NSDictionary*)data[@"parms"];
        
        if (parms[@"name"] != nil) {
            _textName.text = (NSString*)parms[@"name"];
        }
    }
}

- (void)configChange:(NSDictionary *)data deviceID:(NSString*)deviceID {
    NSLog(@"DEMO APP: got configupdate : %@", data);
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
         [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"PIRdistance": @"MEDL"}];
    } else if(_switchPIRDistance.selectedSegmentIndex == 2) {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"PIRdistance": @"MEDIUM"}];
    } else if(_switchPIRDistance.selectedSegmentIndex == 3) {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"PIRdistance": @"MEDH"}];
    } else if(_switchPIRDistance.selectedSegmentIndex == 4) {
         [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"PIRdistance": @"HIGH"}];
    }
   
    //[[appDelegate moveClient] updateConfig:_deviceID withData:@{@"PIRdistance": "HIGHT"}];
}
- (IBAction)changedPIRZone:(id)sender {
    
    int zoneValue = 0;
    if ([_switchZone1 isOn]) {
        zoneValue +=1;
    }
    if ([_switchZone2 isOn]) {
        zoneValue +=2;
    }
    if ([_switchZone3 isOn]) {
        zoneValue +=4;
    }
    NSString* ZoneString = [NSString stringWithFormat:@"%i", zoneValue];

    [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"PIRZoneMode": ZoneString}];
}
- (IBAction)changedFlipImage:(id)sender {
    if (_switchImageFlip.selectedSegmentIndex == 0) {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"imageFlip": @"0"}];
    } else if (_switchImageFlip.selectedSegmentIndex == 2) {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"imageFlip": @"1"}];
    } else if (_switchImageFlip.selectedSegmentIndex == 3) {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"imageFlip": @"2"}];
    } else if (_switchImageFlip.selectedSegmentIndex == 4) {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"imageFlip": @"3"}];
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

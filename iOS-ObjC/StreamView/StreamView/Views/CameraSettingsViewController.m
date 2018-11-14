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
@property (strong, nonatomic) IBOutlet UISwitch *switchDebug;
@property (strong, nonatomic) IBOutlet UISwitch *switchWaterMark;
@property (strong, nonatomic) IBOutlet UISwitch *switchTimeStamp;
@property (strong, nonatomic) IBOutlet UISegmentedControl *switchImageMotion;

@property BOOL setup;

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
    
    _setup = true;
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
    NSLog(@"Got notification - camera settings");
}

- (void)configChange:(NSDictionary *)data {
    NSLog(@"DEMO APP: got configupdate : %@", data);
    
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
        if (parms[@"firmwareVersion"] != nil) {
            _labelVersion.text = (NSString*)parms[@"firmwareVersion"];
        }
        
         if (parms[@"debug"] != nil) {
            [_switchDebug setOn:parms[@"debug"]];
        }
        
        if (parms[@"DND"] != nil) {
            NSLog(@"DND is a NOT string %@ %@", NSStringFromClass([[parms valueForKey:@"DND"] class]),[parms valueForKey:@"DND"]);
            if (parms[@"DND"] > 0) {
                [_switchDND setOn:YES];
            } else {
                [_switchDND setOn:NO];
            }
        }
        
        if (parms[@"nightVision"] != nil) {
            NSLog(@"nightVision is a %@ %@", NSStringFromClass([[parms valueForKey:@"nightVision"] class]),[parms valueForKey:@"nightVision"]);
            if (parms[@"nightVision"] > 0) {
                [_switchNightVision setOn:YES];
            } else {
                [_switchNightVision setOn:NO];
            }
        }
        
        
        if (parms[@"privacyMode"] != nil) {
            NSLog(@"privacyMode is a %@ %@", NSStringFromClass([[parms valueForKey:@"privacyMode"] class]),[parms valueForKey:@"privacyMode"]);
            if (parms[@"privacyMode"] > 0) {
                 NSLog(@"privacyMode Turning on");
                [_switchPrivacyMode setOn:YES];
            } else {
                NSLog(@"privacyMode Turning off");
                [_switchPrivacyMode setOn:NO];
            }
        }
        
        //NSLog(@"timeZone is %@", parms[@"timeZone"], class_getClassName([parms[@"timeZone"] class]));
        if (parms[@"timeZone"] != nil) {
            NSLog(@"timeZone is a %@ %@", [parms valueForKey:@"timeZone"], NSStringFromClass([[parms valueForKey:@"timeZone"] class]));
            NSString *tz = (NSString*) parms[@"timeZone"];
            if ([tz isEqualToString:@"PST8PDT"]) {
                [_switchTimeZone setSelectedSegmentIndex:0];
            } else if ([tz isEqualToString:@"MST7MDT"]) {
                [_switchTimeZone setSelectedSegmentIndex:1];
            } else if ([tz isEqualToString:@"CST6CDT"]) {
                [_switchTimeZone setSelectedSegmentIndex:2];
            } else if ([tz isEqualToString:@"EST5EDT"]) {
                [_switchTimeZone setSelectedSegmentIndex:3];
            }
        }
        
        if (parms[@"imageFlip"] != nil) {
            NSLog(@"imageFlip is a %@ %@", [parms valueForKey:@"imageFlip"], NSStringFromClass([[parms valueForKey:@"imageFlip"] class]));
            
            NSString *imageFlip; //= (NSString*) parms[@"imageFlip"];
            if ([NSStringFromClass([[parms valueForKey:@"imageFlip"] class]) containsString:@"NSCFNumber"]) {
                imageFlip = [(NSNumber*)parms[@"imageFlip"] stringValue];
            }
            
            if ([imageFlip isEqualToString:@"0"]) {
                [_switchImageFlip setSelectedSegmentIndex:0];
            } else if ([imageFlip  isEqualToString:@"1"]) {
                [_switchImageFlip setSelectedSegmentIndex:1];
            } else if ([imageFlip  isEqualToString:@"2"]) {
                [_switchImageFlip setSelectedSegmentIndex:2];
            } else if ([imageFlip  isEqualToString:@"3"]) {
                [_switchImageFlip setSelectedSegmentIndex:3];
            }
        }
        

        if (parms[@"imageMotion"] != nil) {
            NSLog(@"imageMotion is a %@ %@", [parms valueForKey:@"imageMotion"], NSStringFromClass([[parms valueForKey:@"imageMotion"] class]));
            
            NSString *imageMotion = (NSString*) parms[@"imageMotion"];
            if ([imageMotion isEqualToString:@"LOW"]) {
                [_switchImageMotion setSelectedSegmentIndex:0];
            } else if ([imageMotion isEqualToString:@"MED"]) {
                [_switchImageMotion setSelectedSegmentIndex:1];
            } else if ([imageMotion isEqualToString:@"HIGH"]) {
                [_switchImageMotion setSelectedSegmentIndex:2];
            }
        }
        
        if (parms[@"imageQuality"] != nil) {
            NSLog(@"imageQuality is a %@ %@", [parms valueForKey:@"imageQuality"], NSStringFromClass([[parms valueForKey:@"imageQuality"] class]));
            
            NSString *imageQuality =  (NSString*) parms[@"imageQuality"];
            if ([imageQuality isEqualToString:@"LOW"]) {
                [_switchVideoImage setSelectedSegmentIndex:0];
            } else if ([imageQuality isEqualToString:@"MED"]) {
                [_switchVideoImage setSelectedSegmentIndex:1];
            } else if ([imageQuality isEqualToString:@"HIGH"]) {
                [_switchVideoImage setSelectedSegmentIndex:2];
            }
        }
        
        if (parms[@"sirenDur"] != nil) {
             NSLog(@"sirenDur is a %@ %@", [parms valueForKey:@"sirenDur"], NSStringFromClass([[parms valueForKey:@"sirenDur"] class]));
             NSString *imageQuality =  (NSString*) parms[@"sirenDur"];
             if ([imageQuality isEqualToString:@"5 secs"]) {
                 [_switchVideoImage setSelectedSegmentIndex:0];
             } else if ([imageQuality isEqualToString:@"10 secs"]) {
                 [_switchVideoImage setSelectedSegmentIndex:1];
             } else if ([imageQuality isEqualToString:@"15 secs"]) {
                 [_switchVideoImage setSelectedSegmentIndex:2];
             } else if ([imageQuality isEqualToString:@"30 secs"]) {
                 [_switchVideoImage setSelectedSegmentIndex:3];
             } else if ([imageQuality isEqualToString:@"1 min"]) {
                 [_switchVideoImage setSelectedSegmentIndex:4];
             } else if ([imageQuality isEqualToString:@"2 min"]) {
                 [_switchVideoImage setSelectedSegmentIndex:5];
             } else if ([imageQuality isEqualToString:@"5 min"]) {
                 [_switchVideoImage setSelectedSegmentIndex:6];
             }
        }
        
        if (parms[@"recordDur"] != nil) {
            NSLog(@"recordDur is a %@ %@", [parms valueForKey:@"recordDur"], NSStringFromClass([[parms valueForKey:@"recordDur"] class]));
            
             NSString *imageQuality =  (NSString*) parms[@"recordDur"];
             if ([imageQuality isEqualToString:@"SHORT"]) {
             [_switchRecordDur setSelectedSegmentIndex:1];
             } else if ([imageQuality isEqualToString:@"LONG"]) {
                 [_switchRecordDur setSelectedSegmentIndex:0];
             }
        }
        
        
        /*
        
         PIRZoneMode = 7;
         chime = 150;
         imageMotionGrid =         (
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303,
                                   4194303
                                   );
        
        */
     _setup = false;
    }
}

- (void)configChange:(NSDictionary *)data deviceID:(NSString*)deviceID {
    NSLog(@"DEMO APP: got configupdate : %@    %@", data, deviceID);
}

- (void)SdCardInfo:(NSDictionary *)data{
    NSLog(@"DEMO APP: got configupdate ");
    if (data != nil) {
        /*
         "available":"4036032",
         "files":["image","kernel.img"],
         "kind":"msdos",
         "percent":"1%",
         "size":"4095680",
         "used":"59648"
         */
        NSLog(@"======================== SD-card info ==================================");
        NSLog(@"avaiable Space in bytes: %@",data[@"available"]);
        NSLog(@"used Space in bytes: %@",data[@"used"]);
        NSLog(@"total Space in bytes: %@",data[@"size"]);
        NSLog(@"percent Space used: %@",data[@"percent"]);
        NSLog(@"List of files: %@",data[@"files"]);
        NSLog(@"Kinda of SD-card: %@",data[@"kind"]);
    } else {
        NSLog(@"No SD-Card Present");
    }
}
- (void)SdCardFormat:(NSString*)status{
    
}
- (void)SdCardDeleteFile:(NSString*)status{
    ///UGH---what's the filename???
    if ([status isEqualToString:@"true"]){
        NSLog(@"file files was deleted");
    } else {
        NSLog(@"file files was deleted");
    }
}

- (IBAction)changedName:(id)sender {
    if (!_setup) {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"name": _textName.text}];
    }
}
- (IBAction)changedDND:(id)sender {
    if (!_setup) {
        if ([_switchDND isOn]) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"DND": @true}];
        } else {
             [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"DND": @false}];
        }
    }
}
- (IBAction)changedPIRDistance:(id)sender {
    if (!_setup) {
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
    }
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

    if (!_setup) {
       [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"PIRZoneMode": ZoneString}];
    }
}

- (IBAction)changedFlipImage:(id)sender {
    if (!_setup) {
        if (_switchImageFlip.selectedSegmentIndex == 0) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"imageFlip": @"0"}];
        } else if (_switchImageFlip.selectedSegmentIndex == 1) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"imageFlip": @"1"}];
        } else if (_switchImageFlip.selectedSegmentIndex == 2) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"imageFlip": @"2"}];
        } else if (_switchImageFlip.selectedSegmentIndex == 3) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"imageFlip": @"3"}];
        }
    }
}
- (IBAction)changedPrivacyMode:(id)sender {
    if (!_setup) {
         if ([_switchPrivacyMode isOn]) {
             [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"privacyMode": @true}];
         } else {
             [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"privacyMode": @false}];
         }
    }
}
- (IBAction)changedRecordDur:(id)sender {
    if (!_setup) {
        if (_switchRecordDur.selectedSegmentIndex == 0) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"recordDur": @"SHORT"}];
        } else if (_switchRecordDur.selectedSegmentIndex == 1) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"recordDur": @"LONG"}];
        }
    }
}
- (IBAction)changedSirenDur:(id)sender {
    if (!_setup) {
        [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"sirenDur": @"SHORT"}];
    }
}
- (IBAction)changedVideoImage:(id)sender {
    if (!_setup) {
        if (_switchVideoImage.selectedSegmentIndex == 0) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"imageQuality": @"LOW"}];
        } else if (_switchVideoImage.selectedSegmentIndex == 1) {
             [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"imageQuality": @"MEDIUM"}];
        } else if (_switchVideoImage.selectedSegmentIndex == 2) {
             [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"imageQuality": @"HIGH"}];
        }
    }
}
- (IBAction)changedNightVision:(id)sender {
    if (!_setup) {
        if ([_switchNightVision isOn]) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"nightVision": @true}];
        } else {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"nightVision": @false}];
        }
    }
}
- (IBAction)changedDebug:(id)sender {
    if (!_setup) {
        if ( [_switchDebug isOn]) {
             [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"debug":@true}];
        } else {
             [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"debug":@false}];
        }
    }
}
- (IBAction)changedTimeZone:(id)sender {
    if (!_setup) {
        if (_switchTimeZone.selectedSegmentIndex == 0) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"timeZone": @"PST8PDT"}];
        } else if (_switchTimeZone.selectedSegmentIndex == 1) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"timeZone": @"MST7MDT"}];
        } else if (_switchTimeZone.selectedSegmentIndex == 2) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"timeZone": @"CST6CDT"}];
        } else if (_switchTimeZone.selectedSegmentIndex == 3) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"timeZone": @"EST5EDT"}];
        }
    }
}

- (IBAction)changeWaterMark:(id)sender {
    if (!_setup) {
         if ( [_switchWaterMark isOn]) {
             [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"watermark": @"true"}];
         } else {
              [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"watermark": @"false"}];
         }
    }
}
- (IBAction)changeTimeStamp:(id)sender {
    if (!_setup) {
        if ( [_switchTimeStamp isOn]) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"timeStamp": @"true"}];
        } else {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"timeStamp": @"false"}];
        }
    }
}

- (IBAction)changeImageMotion:(id)sender {
    if (!_setup) {
        if (_switchImageMotion.selectedSegmentIndex == 0) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"timeZone": @"LOW"}];
        } else if (_switchImageMotion.selectedSegmentIndex == 1) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"timeZone": @"MED"}];
        } else if (_switchImageMotion.selectedSegmentIndex == 2) {
            [[appDelegate moveClient] updateConfig:_deviceID withData:@{@"timeZone": @"HIGH"}];
        }
    }
}
- (IBAction)miscDevButton:(id)sender {
    [[appDelegate moveClient] sdCardInfo:_deviceID];
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

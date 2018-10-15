//
//  CameraSettingsViewController.h
//  StreamView
//
//  Created by Jeff Smith on 6/14/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoveClient.h"
#import "AppDelegate.h"

@interface CameraSettingsViewController : UIViewController <MoveConnectionDelegate>
@property (nonatomic) NSString* deviceID;

- (void)notificationReceived:(MoveNotification *)notification;
@end

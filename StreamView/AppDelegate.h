//
//  AppDelegate.h
//  StreamView
//
//  Created by Jeff Smith on 4/2/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoveClient.h"
#import "Reachability.h"

#define kMoveURL @"wss://move-dev.mersoft.biz/ws"
//#define kMoveURL @"wss://172.16.30.66:3443/ws"
#define kStreamURL @"https://stream.mersoft.biz"
//#define kMoveURL @"wss://172.16.30.240:3443/ws"
//#define kMoveURL @"wss://192.168.86.22:3443/ws"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property MoveClient *moveClient;
@property (nonatomic, assign) BOOL hasInet;

@end


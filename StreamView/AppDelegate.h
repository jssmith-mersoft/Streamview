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
#define kMoveURLPepper @"wss://dev.move.pepperos.io/ws"
//#define kMoveURLPepper @"wss://172.16.30.66:3443/ws"

#define kMoveURLdev @"wss://172.16.30.66:3443/ws"
#define kStreamURL @"https://stream.mersoft.biz"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property MoveClient *moveClient;
@property (nonatomic, assign) BOOL vendor;
@property (nonatomic, assign) BOOL hasInet;

@end


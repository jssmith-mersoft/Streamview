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
#import "Firebase.h"

//#define kMoveURL @"wss://192.168.2.1:3443/ws"
#define kMoveURL @"wss://move-dev.mersoft.biz/ws"
//Dev
#define kMoveURLPepper @"wss://dev.move.pepperos.io/ws"
#define kPepperAPIURL @"https://dev.api.pepperos.io/authentication/byEmail";
//Stage
//#define kMoveURLPepper @"wss://stage.move.pepperos.io/ws"
//#define kPepperAPIURL @"https://staging.api.pepperos.io/authentication/byEmail";
//Prod
//#define kMoveURLPepper @"wss://prod.move.pepperos.io/ws"
//#define kMoveURLPepper @"wss://MoveS-EcsEl-FAHU33N6TOZ7-1713815330.us-west-2.elb.amazonaws.com/ws"
//#define kPepperAPIURL @"https://api.pepperos.io/authentication/byEmail";

#define kMoveURLdev @"ws://172.16.30.66:3000/ws"
//#define kMoveURLdev @"wss://192.168.86.41:3443/ws"
#define kStreamURL @"https://stream.mersoft.biz"

@interface AppDelegate : UIResponder <UIApplicationDelegate, FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;

@property MoveClient *moveClient;
@property NSString *fireBaseToken;
@property (nonatomic, assign) BOOL vendor;
@property (nonatomic, assign) BOOL hasInet;

@end

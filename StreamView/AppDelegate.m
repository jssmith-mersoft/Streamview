//
//  AppDelegate.m
//  StreamView
//
//  Created by Jeff Smith on 4/2/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//

#import "AppDelegate.h"
#import "PreviewViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setUpRechability];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)setUpRechability
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if (remoteHostStatus == NotReachable){
        NSLog(@"no");
        self.hasInet-=NO;
    } else if  (remoteHostStatus == ReachableViaWiFi) {
        NSLog(@"wifi");
        self.hasInet-=YES;
        [[self moveClient] renegotiate];
    }
    else if (remoteHostStatus == ReachableViaWWAN) {
        NSLog(@"cell");
        self.hasInet-=YES;
    }
}

- (void) handleNetworkChange:(NSNotification *)notice
{
    Reachability* reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if (remoteHostStatus == NotReachable){
        NSLog(@"no");
        self.hasInet-=NO;
    } else if  (remoteHostStatus == ReachableViaWiFi) {
        NSLog(@"wifi");
        self.hasInet-=YES;
        [[self moveClient] reconnect];  //move the Move Websocket for signaling to wifi
        [[self moveClient] renegotiate];//move current PeerConnects to wifi
    }
    else if (remoteHostStatus == ReachableViaWWAN) {
        NSLog(@"cell");
        self.hasInet-=YES;
    }
    
    //    if (self.hasInet) {
    //        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Net avail" message:@"" delegate:self cancelButtonTitle:OK_EN otherButtonTitles:nil, nil];
    //        [alert show];
    //    }
}

@end

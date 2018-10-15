//
//  LoginViewController.h
//  StreamView
//
//  Created by Jeff Smith on 4/2/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//

#ifndef LoginViewController_h
#define LoginViewController_h


//@import WebRTC;
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

#import "AppDelegate.h"
#import "MoveClient.h"





@interface LoginViewController : UIViewController <UITextFieldDelegate, MoveConnectionDelegate>

#pragma mark - MoveConnectionDelegate
- (void)connectionConnected;
- (void)connectionFailed:(NSError *)message;
- (void)connectionClosed;
- (void)promptForAnswerCall:(NSString*)callId caller:(NSString*)CID;
- (void)onConnecting;
- (void)onDeclining;
- (void)onUnanswered;
- (void)onReset;
- (void)onError:(NSString*)message title:(NSString*)title;
- (void)onCallId:(NSString *)callId withPeer:(NSString*)peerId;
- (void)registrationBroken;
- (void)registrationReceived:(NSString *)id withReg:(MoveRegistration*)reg;
- (void)registrationUpdate:(NSString *)id withReg:(MoveRegistration*)reg;
- (void)registrationSubscribe:(NSString *)id withReg:(MoveRegistration*)reg;
- (void)accountReceived:(MoveAccount *)account;
- (void)invalidAccountReceived:(NSString*)username contact:(NSString*)contact;
- (void)notificationReceived:(MoveNotification *)notification;
- (void)rawMessageReceived:(NSString *)message;
- (void)unexpectedMoveError:(NSString*)message title:(NSString*)title hangup:(BOOL)hangup;
@end
#endif /* LoginViewController_h */

//
//  PreviewViewController.h
//  StreamView
//
//  Created by Jeff Smith on 4/2/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//

#ifndef PreviewViewController_h
#define PreviewViewController_h

@import WebRTC;
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "MoveClient.h"
#import "AppDelegate.h"
#import "DemoOnCallViewController.h"

@interface PreviewViewController : UIViewController  <MoveConnectionDelegate, DemoOnCallViewControllerDelegate, AVPlayerViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *Collection_view;

@property NSString *remoteConnectionId;
@property NSString *localConnectionId;

#pragma mark - MoveConnectionDelegate
- (void)connectionConnected;
- (void)connectionFailed:(NSError *)message;
- (void)connectionClosed;
- (void)onReady;
- (void)onCalling;
- (void)promptForAnswerCall:(NSString*)callId caller:(NSString*)CID;
- (void)onOffering;
- (void)onAnswering;
- (void)onConnecting;
- (void)onDeclining;
- (void)onHangup:(NSString*) callId;
- (void)onUnanswered;
- (void)onCancelled;
- (void)onReset;
- (void)onError:(NSString*)message title:(NSString*)title;
- (void)addLocalVideoTrack:(id)localVideoTrack;
- (void)addRemoteVideoTrack:(id)remoteVideoTrack callId:(NSString *)callID peerId:(NSString *)peerID;
- (void)removeRemoteVideoTrack:(id)remoteVideoTrack callId:(NSString *)callID peerId:(NSString *)peerID;
- (void)onCallId:(NSString *)callId withPeer:(NSString*)peerId;
- (void)onForwardResponse:(NSString *)connectionId callId:(NSString *)callId;
- (void)setupForwardJoinCall:(NSString *)callId peerId:(NSString *)peerId;
- (void)onSetupResponse:(NSString *)connectionId;
- (void)onHangupPeer:(NSString *)connectionId connections:(NSNumber *)connections;
- (void)videoFrozen:(BOOL)isFrozen;
- (void)registrationBroken;
- (void)registrationReceived:(NSString *)id withReg:(MoveRegistration*)reg;
- (void)registrationUpdate:(NSString *)id withReg:(MoveRegistration*)reg;
- (void)registrationSubscribe:(NSString *)id withReg:(MoveRegistration*)reg;
- (void)accountReceived:(MoveAccount *)account;
- (void)invalidAccountReceived:(NSString*)username contact:(NSString*)contact;
- (void)historyReceived:(NSArray *)history;
- (void)contactsReceived:(NSArray *)contacts;
- (void)messagesReceived:(NSArray *)messages;
- (void)notificationReceived:(MoveNotification *)notification;
- (void)rawMessageReceived:(NSString *)message;
- (void)unexpectedMoveError:(NSString*)message title:(NSString*)title hangup:(BOOL)hangup;
- (void)addVideoCallRecord:(NSString*)callHistoryID duration:(double)duration location:(NSString*)location
              dateReceived:(NSDate*)date dest:(NSString*)dest wasMissed:(BOOL)wasMissed wasOutgoing:(BOOL)wasOutgoing;

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

#pragma mark - OnCallViewContollerDelegate
- (void)muteCall:(BOOL)muted;
- (void)freezeCall:(BOOL)frozen;
- (void)flipCamera:(BOOL)cameraIsFront;
- (void)endCall:(NSString*)callId;



@end

#endif /* PreviewViewController_h */

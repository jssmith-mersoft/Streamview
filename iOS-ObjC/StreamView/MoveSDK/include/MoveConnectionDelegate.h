//
//  MoveServerDelegate.h
//  Move1
//
//  Created by Jeff Smith on 2/3/14.
//  Copyright (c) 2014 Mersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoveRegistration.h"
#import "MoveService.h"
#import "MoveSubscription.h"
#import "MoveAccount.h"
#import "MoveContact.h"
#import "MoveHistory.h"
#import "MoveMessage.h"
#import "MoveMessage.h"
#import "MoveNotification.h"

@protocol MoveConnectionDelegate<NSObject>

/*! \mainpage Move iOS SDK
 *
 * \section intro_sec Introduction
 *
 * The purpose of this document is to describe the client library for Mersoft move so that customers can integrate the features of Mersoft move into their clients.
 *
 * \section sys_diagram System Diagram
 *
 * Below is a diagram depicting the interaction between Mersoft move and a client, in this case, a set-top box.
 *
 * \image html system_diagram.png
 * \image latex system_diagram.png
 *
 * \section client_overview Mersoft move Client Overview
 *
 *Mersoft move is an asynchronous Pub-Sub (publish/subscribe) system that revolves around contacts and business rules while keeping historical information. These concepts make it an ideal system for implementing WebRTC. Clients register for and subscribe to notifications, the registrations can be used to store and retrieve contacts. Contacts are optional but can enhance sending, receiving messages and their history.
 *
 *It starts with initializing the Object and connecting it to a URL, followed by registering and subscribing for services and notifications.
 *
 * \section example_sec Mersoft move Client examples
 *
 * The following 5 steps are needed to successfully implement move into an existing client.
 *
 *\subsection step1 1 Connect:
 *Connect to a Mersoft move server with the connect command. This builds the web socket between the client and the server.
 *\subsection step2 2 Register:
 *Register with an account id and device id for notifications and service.
 *\subsection step3 3 Implement Callbacks & set needed properties:
 *Implement the call back functions so your application can react to an event, such as onReady or onVideo.  Some properties are required for features like WebRTC such as setting the location of where to play local and remote video.
 *\subsection step4 4 Handle notifications or Make calls:
 *Make method calls for your application:
 Send inter-application messages
 Start a call
 *\subsection step5 5 Unregistering:
 *Call the unregistration method to remove the device from notifications. This is optional, the system will forget about the registration after a configurable time to live setting.
 *
 * etc...
 */

/**
 The callback after the moveClient has been connected.
 @par Example:
 @code{.m}
 - (void)connectionConnected {
     NSLog(@"connected to Move");
     connectionFailed = NO;
     
     if(connectionAlert) {
     [connectionAlert dismissWithClickedButtonIndex:0 animated:NO];
         connectionAlert = nil;
     }
     
     [[[AppDelegate appDelegate] moveClient] register:@"screen" contact:@"1234"];
 }
 @endcode
 */
- (void)connectionConnected;
/**
 The callback after the moveClient has failed.

 @param message Contains the Error message for the failure.
 @par Example:
 @code{.m}
 - (void)connectionFailed:(NSError *)message {
     NSLog(@"FAILED TO CONNECT TO MOVE");
     [self connectionClosed];
 }
 @endcode
 */
- (void)connectionFailed:(NSError *)message;
/**
 If or when the move connection closes, a connectionClosed callback will be executed.
 @par Example:
 @code{.m}
 - (void)connectionClosed{
     NSLog(@"connected to Move has closed");
     
     //wait three secs..... then reconnect
     [self.moveClient performSelector:@selector(reconnect) withObject:nil afterDelay:3.0];
 }
 @endcode
 */
- (void)connectionClosed;

// Required for WebRTC
/**
 Notifies the client that the peer on a call is ready to setup the call.
 @par Example:
 @code{.m}
 - (void)onReady
 {
     NSLog(@"WebRTC Ready");
 }
 @endcode
 */
- (void)onReady;
@optional
- (void)onCalling;

/**
 If the onPromptForAnswerCall is defined, move notifies the client application that a call has been requested, otherwise, move will auto-answer the call.

 @param callId ID of the call
 @param CID CID of the caller
 @par Example:
 @code{.m}
 - (void)promptForAnswerCall:callID caller:destCID {
     NSLog(@"DEMO APP: WebRTC Accepting");
 }
 @endcode
 */
- (void)promptForAnswerCall:(NSString*)callId caller:(NSString*)CID;

- (void)onOffering;
/**
 Called when move client is answering a webrtc offer
 */
- (void)onAnswering;

/**
 Called when move client is connecting a webrtc session
 */
- (void)onConnecting;

/**
 Called when move client is hanging up a call

 @param callId Call id of call being hung up
 */
- (void)onHangup:(NSString*) callId;

- (void)onUnanswered;

/**
 Called when move client receives a call cancelled notification

 @param callId Call id of call that was cancelled
 */
- (void)onCancelled:(NSString*)callId;


/**
 Called after a call has ended and the view can be reset
 */
- (void)onReset;


/**
 Called when an error has occured

 @param message Description of error
 @param title Title of error
 */
- (void)onError:(NSString*)message title:(NSString*)title;


/**
 Called when the move client has received a local video track from the camera.

 @param localVideoTrack Local video track returned by move client.
 */
- (void)addLocalVideoTrack:(id)localVideoTrack;


/**
 Called when a remote stream is received. Includes the video track as well as the call id and the peer CID.

 @param remoteVideoTrack Remote video track received from peer
 @param callID Call id of call that track originates from
 @param peerID Peer CID of peer that is sending track
 */
- (void)addRemoteVideoTrack:(id)remoteVideoTrack callId:(NSString *)callID peerId:(NSString *)peerID;
- (void)addRemoteAudioTrack:(id)remoteAudioTrack callId:(NSString *)callID peerId:(NSString *)peerID;

/**
 Called when a peer disconnects and no longer provides a video track

 @param remoteVideoTrack Remote video track that is being disconnected
 @param callID Call id of call that track originates from
 @param peerID Peer CID of peer that is ending the track
 */
- (void)removeRemoteVideoTrack:(id)remoteVideoTrack callId:(NSString *)callID peerId:(NSString *)peerID;
- (void)removeRemoteAudioTrack:(id)remoteAudioTrack callId:(NSString *)callID peerId:(NSString *)peerID;


/**
 Called when a new call has been offered, or a peer is requesting a call.

 @param callId Call id of call
 @param cid peer CID of caller
 */
- (void)onCallId:(NSString *)callId withPeer:(NSString*)cid;


/**
 Called upon the response of the stream server to a forward request.

 @param connectionId CID of the stream peer
 @param callId Call ID of the call created by stream
 */
- (void)onForwardResponse:(NSString *)connectionId callId:(NSString *)callId;

/**
 Called upon the response of the stream server to a setup request.

 @param connectionId CID of the stream peer
 */
- (void)onSetupResponse:(NSString *)connectionId;


/**
 Called upon receiving a 'hangup-peer' message.

 @param connectionId CID of the peer that has hungup
 @param connections Current count of connections on the call
 */
- (void)onHangupPeer:(NSString *)connectionId connections:(NSNumber *)connections;

/**
 Called upon receiving a 'monitor' message.
 
 @param connectionId CID of the peer requesting to join call
 @param connections Current count of connections on the call
 */
- (void)onMonitorPeer:(NSString *)connectionId connections:(NSNumber *)connections;


/**
 Called upon receiving a call wide notification.

 @param name Message 'name' field
 @param value Message contents
 @param connectionId CID of the peer from which the message originated
 */
- (void)onCallNotify:(NSString *)name value:(NSString *)value  connection:(NSString *)connectionId;


/**
 Called upon pausing a remote or local video stream.

 @param isFrozen True if paused, false if unpaused
 @param connectionId CID of the peer that has paused
 @param clientPosition 'Remote' if client was a remote stream, 'local' if local stream paused
 */
- (void)videoFrozen:(BOOL)isFrozen connection:(NSString *)connectionId client:(NSString *)clientPosition;

/**
 Called upon muting a remote or local video stream.
 
 @param isMuted True if muted, false if muted
 @param connectionId CID of the peer that has muted
 @param clientPosition 'Remote' if client was a remote stream, 'local' if local stream muted
 */
- (void)audioMuted:(BOOL)isMuted connection:(NSString *)connectionId client:(NSString *)clientPosition;

/**
 Called if registration update returns with an error.
 */
- (void)registrationBroken;
/**
 The callback after the moveClient has registered

 @param id The Id of the registration
 @param reg The move registration object
 @par Example:
 @code{.m}
 - (void)registrationReceived:(NSString *)id withReg:(MoveRegistration*)reg
 {
     NSLog(@"Move Client:received registrations");
     UIWindow *window = [UIApplication sharedApplication].keyWindow;
     if([window.rootViewController isKindOfClass:[ViewController class]]) {
         ViewController *rootViewController = window.rootViewController;
         [rootViewController setCode:reg.tn];
     }
 }
 @endcode
 */
- (void)registrationReceived:(NSString *)id withReg:(MoveRegistration*)reg;

/**
 Called after receiving a registration update response

 @param id CID given by update
 @param reg MoveRegistration object of new registration
 */
- (void)registrationUpdate:(NSString *)id withReg:(MoveRegistration*)reg;
/**
 The callback after the moveClient has subscribed


 @param id The Id of the registration
 @param reg The move registration object
 @par Example:
 @code{.m}
 - (void)registrationSubscribe:(NSString *)id withReg:(MoveRegistration*)reg
 {
     NSLog(@"Move Client:received a subscribtion");
 }
 @endcode
 */
- (void)registrationSubscribe:(NSString *)id withReg:(MoveRegistration*)reg;

/**
 The callback after the moveClient has request Thumbnails for a device
 
 
 @param url The URL of the Image
 @param deviceID The device that the thumbnail image belongs to
 @par Example:
 @code{.m}
 - (void)cameraThumnailURLReceived:(NSString *))url deviceID:(NSString*)deviceID;
 {
 NSLog(@"Move Client:received a cameraThumnailURLReceived for %@",deviceID);
 }
 @endcode
 */
- (void)cameraThumnailURLReceived:(NSString *)url deviceID:(NSString*)deviceID;
/**
 The callback for unsolsited notifications
 
 @param notification The move notification object
 @par Example:
 @code{.m}
 - (void)notificationReceived:(MoveNotification *)notification
 {
 NSLog(@"Move Client:received a notification");
 }
 @endcode
 */
- (void)notificationReceived:(NSDictionary*)notification;
/**
 The callback for unsolsited notifications
 
 @param notification The move NSDictionary object
 @par Example:
 @code{.m}
 - (void)notificationReceived:(MoveNotification *)notification
 {
 NSLog(@"Move Client:received a notification");
 }
 @endcode
 */
- (void)retrieveEventHistory:(NSArray *)events;

/**
 The callback for a config change
 
 @param data The a dictionary of the device Configuration
 @par Example:
 @code{.m}
 - (void)configChange:(NSDictionary *)device
 {
 NSLog(@"Yea...I got a config");
 }
 
 Device looks like
 {
 "account":"5b0e21af9398812031b6aca0",
 "camera_id":"DB4D016B5PAZ57E4C",
 "created":"2018-06-27T13:04:43.34-05:00",
 "device_id":"Stream-DB11-bcpt3eqe0a5pjcfiov5g",
 "id":"5b33d1bb4e028b99b1eab6ce",
 "parms":{
 "DND":false,
 "PIRZoneMode":7,
 "PIRdistance":"LOW",
 "debug":false,
 "description":null,
 "imageFlip":"1",
 "language":"eng",
 "name":"camera-DB4D016B5PAZ57E4C",
 "nightVision":false,
 "privacyMode":false,
 "recordDur":"SHORT",
 "sirenDur":"SHORT",
 "timezone":"-7",
 "videoImage":"HIGH",
 "wifi":{
 "password":"coff33cup",
 "ssid":"Demo Devices"
 }
 },
 "type":"DB11",
 "updated":"2018-06-29T10:51:47.114-05:00",
 "version":"0.0.92"
 }
 ]
 @endcode
 */
- (void)configChange:(NSDictionary *)data;

/*
 **
 The callback for a config change
 
 @param data The a dictionary of the changes to the device Configuration
 @param deviceID The devicesID for what is getting changes
 @par Example:
 @code{.m}
 - (void)configChange:(NSDictionary *)data
 {
 NSLog(@"Yea...I got a config change");
 }
 
 Data looks like
 {
 "imageFlip":"1",
 }
 ]
 @endcode
 */
- (void)configChange:(NSDictionary *)data deviceID:(NSString*)deviceID;

- (void)addDevice:(NSDictionary *)data deviceID:(NSString*)deviceID;

- (void)addDeviceFail:(NSString*)cameraID ErrorMessage:(NSString*)errorMessage;

/*
 **
 The callback for a RecordVideoEvent
 
 @param eventID The event that holds the recordings
 @param deviceID The devicesID for what is doing the recording
 @param deviceID The thumbnamilURL for the thumbnail of the event
 @param deviceID The recordedVideoURL for the recording of the event
 @par Example:
 @code{.m}
 - (void)RecordVideoEvent:(NSString *)eventID  deviceID:(NSString*)deviceID  thumbnailURL:(NSString*)thumbnailURL recordedVideoURL:(NSString*)recordedVideoURL
 {
    NSLog(@"Yea...I got a RecordVideoEvent");
 }
 @endcode
 */
- (void)RecordVideoEvent:(NSString *)eventID  deviceID:(NSString*)deviceID  thumbnailURL:(NSString*)thumbnailURL recordedVideoURL:(NSString*)recordedVideoURL;
/*
 **
 The callback for a SnapShotEvent
 
 @param eventID The event that holds the recordings
 @param deviceID The devicesID for what is doing the recording
 @param deviceID The thumbnamilURL for the thumbnail of the event
 @par Example:
 @code{.m}
 - (void)SnapShotEvent:(NSString *)eventID  deviceID:(NSString*)deviceID  thumbnailURL:(NSString*)thumbnailURL
 {
 NSLog(@"Yea...I got a RecordVideoEvent");
 }
 @endcode
 */
- (void)SnapShotEvent:(NSString *)eventID  deviceID:(NSString*)deviceID  thumbnailURL:(NSString*)thumbnailURL;

-(void)StopRecordVideoEvent:(NSString *)eventID  deviceID:(NSString*)deviceID;
-(void)PlaySirenEvent:(NSString *)eventID  deviceID:(NSString*)deviceID;
-(void)StopPlaySirenEvent:(NSString *)eventID  deviceID:(NSString*)deviceID;

- (void)accountReceived:(MoveAccount *)account;
- (void)invalidAccountReceived:(NSString*)username contact:(NSString*)contact;
- (void)historyReceived:(NSArray *)history;
- (void)contactsReceived:(NSArray *)contacts;
- (void)messagesReceived:(NSArray *)messages;
- (void)rawMessageReceived:(NSString *)message;
- (void)unexpectedMoveError:(NSString*)message title:(NSString*)title hangup:(BOOL)hangup;
- (void)addVideoCallRecord:(NSString*)callHistoryID duration:(double)duration location:(NSString*)location
              dateReceived:(NSDate*)date dest:(NSString*)dest wasMissed:(BOOL)wasMissed wasOutgoing:(BOOL)wasOutgoing;
- (void)SignalInfo:(NSDictionary *)data;
- (void)SdCardInfo:(NSDictionary *)data;
- (void)SdCardFormat:(NSString*)status;
- (void)SdCardDeleteFile:(NSString*)status;

- (void)messagesReceived:(NSArray *)messages;

@end

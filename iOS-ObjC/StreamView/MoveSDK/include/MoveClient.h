//
//  MoveServerDelegate.h
//  Move1
//
//  Created by Jeff Smith on 2/3/14.
//  Copyright (c) 2014 Mersoft. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "MoveConnectionDelegate.h"
#import "MoveContact.h"
#import "MoveHistory.h"
#import "MoveMessage.h"
#import "MoveAccount.h"
#import "MoveRegistration.h"
#import "MoveNotification.h"
#import "MoveWRTC.h"
@import WebRTC;

@class RTCSessionDescription;

@interface MoveClient : NSObject

typedef enum {
    QualityNone = 1,
    QualityLow,
    QualityMedium,
    QualityHigh
} Quality;

@property (nonatomic, assign, getter = isInitiator) BOOL initiator;
@property (nonatomic, assign, getter = isWebRTCSetup) BOOL webRTCSetup;
@property(readonly) NSString * ipaddress;
@property (nonatomic, copy) NSString* myLocation;
@property (nonatomic, copy) NSString* loginName;
/**
 True to send audio, false to disable sending audio
 */
@property (nonatomic) BOOL sendAudio;
/**
 True to receive audio, false to disable receiving audio
 */
@property (nonatomic) BOOL receiveAudio;
/**
 True to send video, false to disable sending video
 */
@property (nonatomic) BOOL sendVideo;
/**
 True to receive video, false to disable receiving video
 */
@property (nonatomic) BOOL receiveVideo;
@property (nonatomic) BOOL offer;

// WebRTC Call Variables (temps help with interrupted calls)
@property (nonatomic, copy) NSMutableDictionary* calls;
@property (nonatomic, copy) NSString* deviceToken;
@property (nonatomic, copy) NSString* deviceId;
@property (readonly) MoveRegistration* currentReg;
@property (nonatomic) NSTimer* registration_refreshTimer;

/**
 Creates websocket and connects to move server. When the connection is connected the MoveConnectionDelegate method of connectionConnected will be called.

 @param ipaddress URL for move Servers
 @par Example:
 @code{.m}
 #define kMoveURL @"ws://move.mersoft.biz:3000/ws"
 
 NSLog(@"App is starting: %@",kMoveURL);
 self.moveClient = [[MoveClient alloc] init];
 self.moveClient.delegate = self;
 
 [self.moveClient connectToMove:kMoveURL];
 @endcode
 */
- (void)connectToMove:(NSString *)ipaddress;
- (void)reconnect;
- (NSString*)getServer;

/**
 Move registers an account for notification. The account can provide a preset ID (like email address or telephone number) or dynamic IDs for notifications.

 @param userId Account ID.
 @par Example:
 @code{.m}
 [[self moveClient] register:@"screen"];
 @endcode
 */
- (void)register:(NSString*)userId;
- (void)register:(NSString*)userId withToken:(NSString*)token vendor:(NSString*)vendor;

/**
 Unregisters the move session to prevent future notifications.  
 
 @par Example:
 @code{.m}
    [[self moveClient] unregister];
 @endcode
 */
- (void)unregister;


- (void) getConfig:(NSString *)deviceID;
- (void) updateConfig:(NSString *)deviceID  withData:(NSDictionary *)data;

- (void) getCameraURL:(NSString *)deviceID;
- (void) retrieveEventHistory;
- (void) retrieveEventHistory:(NSInteger)page;
- (void) retrieveEventHistoryByDevice:(NSString *)deviceID;
- (void) retrieveEventById:(NSString *)eventID;
- (void) createEvent:(NSString *)eventType forDevice:(NSString*)deviceID;
- (void) deleteEvent:(NSString*)id;

- (void)sendCameraNotif:(NSString *)deviceID class:(NSString*)class data:(NSDictionary*)data;
- (void)signalInfo:(NSString *)deviceID;
- (void)sdCardInfo:(NSString *)deviceID;
- (void)sdCardFormat:(NSString *)deviceID;
- (void)sdCardDeleteFile:(NSString *)deviceID filename:(NSString *)filename;
- (void)sdCardUploadFile:(NSString *)deviceID filename:(NSString *)filename;



- (void)join;

- (void) addAccount:(NSDictionary*)accountInfo regId:(NSString*)regId;

- (void) getContacts;
- (void) addContact:(MoveContact *)newContact;
- (void) deleteContact:(MoveContact *)Contact;
- (void) updateContact:(MoveContact *)Contact;

- (void) getMessages;
- (void) sendMessages:(MoveMessage*)message;
- (void) deleteMessages:(MoveMessage*)message;


    
- (void) getHistory;

- (void)sendToService:(NSString*)toServiceID withData:(NSDictionary*)data withClass:(NSString*)className;
- (void)sendP2PMessage:(NSString*)toPhoneNumber withMessage:(NSString*)message withCallerID:(NSString*)callerIdLabel;
- (void)sendCallMessage:(NSString*)toPhoneNumber withMessage:(NSString*)message withCallerID:(NSString*)callerIdLabel;
- (void)sendKeepAliveMessage;

- (void)close;

// WebRTC Call Progression and Signaling
/**
 With iOS, there is an additional step from the other SDKs, to setup the apple frameworks and establish the camera.

 @param pl The UIView for displaying the local video (mirror).
 @param useFrontCamera True for Front Camera, False for Back Camera
 @par Example:
 @code{.m}
    [self.moveClient WebRTCSetupwithPreviewLayer:self.localVideoView camera:YES];
 @endcode
 */
-(void) setupWithPreviewLayer:(UIView*)pl camera:(BOOL)useFrontCamera;

-(AVCaptureSession*) getCaptureSession;

/**
 Creates or joins a specified room

 @param roomID name of the room
 @param owner if true room will close when user hangs up, if false room will persist after hangup
 @par Example:
 @code{.m}
 [self.moveClient joinRoom:callID owner:owner];
 @endcode
 */
-(void) joinRoom:(NSString*)roomID owner:(BOOL)owner;

/**
 This creates a call in move and notifies the account (if subscribed for incoming call) on any device.

 @param dest The Id for the destination of the Call. Who to send the call request to.
 @param type This describes the type of ID, like TN or email address
 @param message A message to send with the call offer. (client may or may not use it)
 @par Example:
 @code{.m}
 [self.moveClient placeCall:dest destType:destType message:message];
 @endcode
 */
-(void) placeCall:(NSString*)dest destType:(NSString *)type message:(NSString*)message;

-(void) startCall:(NSDictionary *)candidates call:(NSString*)callID peer:(NSString*)CID;
-(void) makeOffer:(NSString*)callID toPeer:(NSString *)CID;
-(void) processIncomingCall:(NSString*)callID dest:(NSString*)dest location:(NSString*)location destCID:(NSString*)destCID;

/**
 Accept call from specified call and caller

 @param callID Call ID of the call to be accept
 @param CID CID of caller
 @par Example:
 @code{.m}        
 [self.moveClient acceptCall:callID peer:peerID];
 @endcode
 */
-(void) acceptCall:(NSString*)callID peer:(NSString*)CID;

/**
 Decline call from specified call and caller

 @param callID Call ID of the call to be declined
 @param CID CID of caller
 @par Example:
 @code{.m}
 [self.moveClient declineCall:callID peer:peerID];
 @endcode
 */
-(void) declineCall:(NSString*)callID peer:(NSString*)CID;

/**
 Tells move to signal to the other legs of the call that you would like to hang up. This sends a message to the other clients to start the hangup process. onHangup is called when other peers in the call respond to the hangup call request.

 @param callID Call ID of the call to be hungup
 @par Example:
 @code{.m}
    [self.moveClient hangupCall:callID];
 @endcode
 */
-(void) hangupCall:(NSString*)callID;

-(void) hangupPeer:(NSString*)callId;

/**
 Joins an existing call/room

 @param callID Call ID of the call to be joined
 @par Example:
 @code{.m}
 [self.moveClient monitorCall:callId];
 @endcode
 */
-(void) monitorCall:(NSString *)callID;


/**
 Used to join a stream session after a forward join is called.

 @param callID Call ID of stream session
 @param CID CID of stream session
 @par Example:
 @code{.m}
 [self.moveClient monitorCallForward:streamCallID peer:streamSessionCID];
 @endcode
 */
-(void) monitorCallForward:(NSString *)callID peer:(NSString *)CID;

-(void) streamForward;
-(void) streamSetup:(NSString *)RTSPUrl;
-(void) startMonitor:(NSString *)callID withPeer:(NSString *)CID;
-(void) resetStates:(NSString*)callID;
-(void)sendCallNotify:(NSString*)name withValue:(NSString*)value;
-(RTCSessionDescription *) descriptionForDescription:(RTCSessionDescription *)description
                                 preferredVideoCodec:(NSString *)codec;
/**
 Sets the desired call quanity, places limits resolution and framerate

 @param constraint Quality level as defined by Quality property
 @par Example:
 @code{.m}
  [[self moveClient] setQuality:QualityHigh];
 @endcode
 */
-(void) setQuality:(Quality)constraint;

/**
 Renegotiates all peer connections. Useful for when network connectivity changes.
 @par Example:
 @code{.m}
 [[self moveClient] renegotiate];
 @endcode
 */
-(void)renegotiate;

-(void)renegotiate:(NSString*)callID peer:(NSString*)CID;

// WebRTC Stream Helpers
/**
 Mutes or unmutes audio stream

 @param muted true to mute, false to unmute
 @par Example:
 @code{.m}
 [[self moveClient] mute:muted];
 @endcode
 */
- (void) mute:(BOOL)muted;

// WebRTC Stream Helpers
/**
 Mutes or unmutes audio all remote streams on a call
 
 @param muted true to mute, false to unmute
 @par Example:
 @code{.m}
 [[self moveClient] mute:muted call:callID];
 @endcode
 */
- (void) muteRemote:(BOOL)muted call:(NSString*)callID;

/**
 Pauses or unpauses sending video

 @param frozen true to pause video, false to resume video
 @par Example:
 @code{.m}
 [[self moveClient] freeze:frozen];
 @endcode
 */
- (void) freeze:(BOOL)frozen;
/**
 Allows switching between front and rear cameras (when present)

 @param front true to use front camera, false to use back
 @par Example:
 @code{.m}
 [[self moveClient] flipCamera:cameraIsFront];
 @endcode
 */
- (void) flipCamera:(BOOL)front;

- (void) setToken:(NSString *)token;
- (void) deleteToken:(NSString *)token;

////////////////////////

//helpers
+ (BOOL) connectedToInternet;
@property (getter=isConnected) BOOL connected;
@property (getter=isRegistered) BOOL registered;
@property (nonatomic, weak) id<MoveConnectionDelegate> delegate;

+(NSDate *)dateForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString;

@end

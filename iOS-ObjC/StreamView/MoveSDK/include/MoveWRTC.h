//
//  MoveWRTC.h
//  Move1
//
//  Created by Jeff Smith on 2/6/14.
//  Copyright (c) 2014 Mersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol MoveMessage<NSObject>
- (void)sendSdp:(NSString *)message call:(NSString*)callID peer:(NSString*)CID;
- (void)sendIceCandidate:(NSString *)candidate withId:(NSString*)id  withLabel:(NSNumber*)label call:(NSString*)callID peer:(NSString*)CID;
- (void)updateIce:(NSString *)message call:(NSString*)callID peer:(NSString*)CID;
- (void)didReceiveRemoteVideoTrack:(id)remoteVideoTrack call:(NSString*)callID peer:(NSString*)CID;
- (void)didReceiveRemoteAudioTrack:(id)remoteAudioTrack call:(NSString*)callID peer:(NSString*)CID;
- (void)didReceiveLocalVideoTrack:(id)localVideoTrack call:(NSString*)callID peer:(NSString*)CID;
// - (void)removePeerConnection:(id)peerConnection;
- (void)unexpectedMoveMessageError:(NSString*)message title:(NSString*)title;
- (void)onConnectionLost:(NSString*)callID peer:(NSString*)CID;
- (BOOL)isCallInitiator;
@end

@interface MoveWRTC : NSObject

@property (nonatomic) BOOL receiveAudio;
@property (nonatomic) BOOL receiveVideo;
@property (nonatomic) NSString* callID;
@property (nonatomic) NSString* CID;

- (id)initWithDelegate:(id<MoveMessage>)delegate call:(NSString*)callID peer:(NSString*)CID;
+ (NSString *)firstMatch:(NSRegularExpression *)pattern withString:(NSString *)string;
+ (NSString *)preferISAC:(NSString *)origSDP;

@end

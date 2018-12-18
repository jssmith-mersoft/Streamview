//
//  DemoOnCallViewController.h
//  move-sdk-demo
//
//  Created by Josh Marchello on 11/14/16.
//  Copyright © 2016 Mersoft. All rights reserved.
//

@import WebRTC;
#import <UIKit/UIKit.h>

@protocol DemoOnCallViewControllerDelegate <NSObject>

- (void)muteCall:(BOOL)muted;
- (void)muteRemoteCall:(BOOL)muted callId:(NSString*)callId;
- (void)freezeCall:(BOOL)frozen;
- (void)flipCamera:(NSString*)deviceID;
- (void)endCall:(NSString*)callId;

@end

@interface DemoOnCallViewController : UIViewController <RTCEAGLVideoViewDelegate>

@property (nonatomic, weak) id<DemoOnCallViewControllerDelegate> delegate;
@property (nonatomic, strong) RTCEAGLVideoView *localVideoView;
//@property (nonatomic, strong) RTCEAGLVideoView *remoteVideoView;
@property (strong, nonatomic) RTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) RTCVideoTrack *remoteVideoTrack;
@property (nonatomic, copy) NSMutableDictionary* remoteViews;
@property (nonatomic, copy) NSMutableDictionary* remoteVideoTracks;

@property (nonatomic) NSString *callID;
@property (nonatomic) NSString *deviceID;
@property IBOutlet UILabel *callIDLabel;

- (void) setLocalVideoView:(RTCEAGLVideoView *)localVideoView;
//- (void) setRemoteVideoView:(RTCEAGLVideoView *)remoteVideoView;
- (void) setLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;
- (void) setRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack callId:(NSString *)callID peerId:(NSString *)peerID;
- (void) unsetRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack callId:(NSString *)callID peerId:(NSString *)peerID;
- (void) setRemoteAudioTrack:(RTCVideoTrack *)remoteVideoTrack callId:(NSString *)callID peerId:(NSString *)peerID;
- (void) unsetRemoteAudioTrack:(RTCVideoTrack *)remoteVideoTrack callId:(NSString *)callID peerId:(NSString *)peerID;

- (void) viewDidLoad;

@end


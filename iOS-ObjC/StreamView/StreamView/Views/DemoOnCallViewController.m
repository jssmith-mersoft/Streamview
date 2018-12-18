//
//  DemoOnCallViewController.m
//  move-sdk-demo
//
//  Created by Josh Marchello on 11/14/16.
//  Copyright © 2016 Mersoft. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import "DemoOnCallViewController.h"

// Padding space for local video view with its parent.
static CGFloat const kLocalViewPaddingSide = 15;
static CGFloat const kLocalViewPaddingBottom = 65;

@interface DemoOnCallViewController ()

//timer
@property NSTimer *clockTicks;
@property NSTimer *callTicks;
@property NSDate *start_date;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UILabel *callTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *remoteMuteButton;
@property (strong, nonatomic) IBOutlet UIButton *muteButton;

@end

@implementation DemoOnCallViewController {
    CGSize _localVideoSize;
    CGSize _remoteVideoSize;
    BOOL remoteMuted;
    BOOL muted;
    BOOL frozen;
    BOOL cameraIsFront;
}

- (void) setCallID:(NSString *)callID {
    _callID = callID;
    [_callIDLabel setText:_callID];
}

- (void) setDeviceID:(NSString *)deviceID {
    _deviceID = deviceID;
    [_callIDLabel setText:_deviceID];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"DEMO APP: LOADING ONCALLVIEW...");
    
    // Do some setup for the video views
    [self.view addSubview:_localVideoView];
    [self.view sendSubviewToBack:_localVideoView];
    _remoteViews = [[ NSMutableDictionary alloc] init];
    _remoteVideoTracks = [[ NSMutableDictionary alloc] init];
    [self startTimer];
}

- (void)viewDidDisappear:(BOOL)animated{
    [_callTicks invalidate];
    _callTicks = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setLocalVideoView:(RTCEAGLVideoView *)localVideoView {
    _localVideoView = localVideoView;
    [self.view sendSubviewToBack:_localVideoView];
    [_localVideoView setDelegate:self];
}

- (void) setLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
    _localVideoTrack = localVideoTrack;
    [_localVideoTrack addRenderer:_localVideoView];
}

- (void) setRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack callId:(NSString *)callID peerId:(NSString *)peerID{
    NSLog(@"DEMO APP: setRemoteVideoTrack %@ peer %@", remoteVideoTrack.source, peerID);
    if(_localVideoTrack == nil){
        [_localVideoView removeFromSuperview];
    }
    
    NSLog(@"DEMO APP: setRemoteVideoTrack adding a new view!");
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect fullScreenFrame = CGRectMake(0, 0, screenWidth, screenHeight);
    RTCEAGLVideoView* newView = [[RTCEAGLVideoView alloc] initWithFrame:fullScreenFrame];
    //newView.transform = CGAffineTransformMakeScale(-1, 1);
    [self.view addSubview:newView];
    [self.view sendSubviewToBack:newView];
    
    _remoteViews[peerID] = newView;
    _remoteVideoTracks[peerID] = remoteVideoTrack;
    [newView setDelegate:self];
    
    [remoteVideoTrack addRenderer:newView];
    [self updateVideoViewLayout];
    
}

- (void) unsetRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack callId:(NSString *)callID peerId:(NSString *)peerID{
    NSLog(@"DEMO APP: unsetRemoteVideoTrack %@ peer %@", remoteVideoTrack.source, peerID);
    [_remoteViews[peerID] removeFromSuperview];
    _remoteViews[peerID] = nil;
    [_remoteViews removeObjectForKey:peerID];
    _remoteVideoTracks[peerID] = nil;
    [_remoteVideoTracks removeObjectForKey:peerID];
    [self updateVideoViewLayout];
}

- (void) setRemoteAudioTrack:(RTCVideoTrack *)remoteVideoTrack callId:(NSString *)callID peerId:(NSString *)peerID {
    
    //turn off remote sound
    remoteMuted = YES;
    [_delegate muteRemoteCall:remoteMuted callId:_callID];
    [_remoteMuteButton setImage:[UIImage imageNamed:@"icon_speaker_off"] forState:UIControlStateNormal];
    
    //turn mic off
    muted = YES;
    [_delegate muteCall:muted];
    [_muteButton setImage:[UIImage imageNamed:@"icon_mic_off"] forState:UIControlStateNormal];
    
     NSLog(@"DEMO APP: setRemoteAudioTrack peer %@", peerID);
}
- (void) unsetRemoteAudioTrack:(RTCVideoTrack *)remoteVideoTrack callId:(NSString *)callID peerId:(NSString *)peerID {
     NSLog(@"DEMO APP: unsetRemoteAudioTrack peer %@", peerID);
}

- (void)updateVideoViewLayout {
    NSLog(@"DEMO APP: Local Size: %@", NSStringFromCGSize(_localVideoSize));
    NSLog(@"DEMO APP: Remote Size: %@", NSStringFromCGSize(_remoteVideoSize));
    
    CGSize defaultAspectRatio = CGSizeMake(2, 3);
    CGSize localAspectRatio = CGSizeEqualToSize(_localVideoSize, CGSizeZero) ?
    defaultAspectRatio : _localVideoSize;
    CGSize remoteAspectRatio = CGSizeEqualToSize(_remoteVideoSize, CGSizeZero) ?
    defaultAspectRatio : _remoteVideoSize;
    
    
    //Arrange in 2xi layout
    NSInteger i = 1;
    NSInteger count = [_remoteViews allKeys].count;
    NSInteger numberOfRows = ceil((float)count / 2.0) ;
    
    for(id view in _remoteViews){
        BOOL firstFrameOnRow = (i % 2) == 0 ? false : true;
        NSInteger numberOnRow = (i == count && firstFrameOnRow) ? 1 : 2;
        NSInteger row = ceil((float)i / 2.0);
        
        NSInteger width = self.view.bounds.size.width / ((numberOnRow > 1) ? 2 : 1);
        NSInteger height = self.view.bounds.size.height / numberOfRows;
        double x = width * (firstFrameOnRow ? 0 : 1);
        double y = height * (row - 1);
        
        CGRect size = CGRectMake(x, y, width, height);
        CGRect remoteVideoFrame = AVMakeRectWithAspectRatioInsideRect(remoteAspectRatio, size);
        
        ((RTCEAGLVideoView*) _remoteViews[view]).frame = remoteVideoFrame;
        [self.view sendSubviewToBack:((RTCEAGLVideoView*) _remoteViews[view])];
        i++;
    }
    
    CGRect localVideoFrame = AVMakeRectWithAspectRatioInsideRect(localAspectRatio, self.view.bounds);
    localVideoFrame.size.width = localVideoFrame.size.width / 4;
    localVideoFrame.size.height = localVideoFrame.size.height / 4;
    localVideoFrame.origin.x = CGRectGetMaxX(self.view.bounds)
    - localVideoFrame.size.width - kLocalViewPaddingSide;
    localVideoFrame.origin.y = CGRectGetMaxY(self.view.bounds)
    - localVideoFrame.size.height - kLocalViewPaddingBottom;
    
    self.localVideoView.frame = localVideoFrame;
}

#pragma mark - Handlers

- (IBAction)muteButtonTapped:(UIButton*)sender {
    if(!muted) {
        muted = YES;
        [_delegate muteCall:muted];
        [sender setImage:[UIImage imageNamed:@"icon_mic_off"] forState:UIControlStateNormal];
    } else {
        muted = NO;
        [_delegate muteCall:muted];
        [sender setImage:[UIImage imageNamed:@"icon_mic_on"] forState:UIControlStateNormal];
    }
}
- (IBAction)remoteMuteButtonTapped:(UIButton*)sender {
    if(!remoteMuted) {
        remoteMuted = YES;
        [_delegate muteRemoteCall:remoteMuted callId:_callID];
        [sender setImage:[UIImage imageNamed:@"icon_speaker_off"] forState:UIControlStateNormal];
    } else {
        remoteMuted = NO;
         [_delegate muteRemoteCall:remoteMuted callId:_callID];
        [sender setImage:[UIImage imageNamed:@"icon_speaker_on"] forState:UIControlStateNormal];
    }
}

- (IBAction)freezeButtonTapped:(UIButton*)sender {
    if(!frozen) {
        frozen = YES;
        [_delegate freezeCall:frozen];
        [sender setImage:[UIImage imageNamed:@"icon-play"] forState:UIControlStateNormal];
    } else {
        frozen = NO;
        [_delegate freezeCall:frozen];
        [sender setImage:[UIImage imageNamed:@"icon-pause"] forState:UIControlStateNormal];
    }
}

- (IBAction)flipCameraButtonTapped:(UIButton*)sender {
    [_delegate flipCamera:@""];
}

- (IBAction)endButtonTapped:(id)sender {
    [_delegate endCall:_callID];
    [self stopTimer];
}


#pragma mark - RTCEAGLVideoViewDelegate

- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size {
    if (videoView == self.localVideoView) {
        NSLog(@"DEMO APP: Local Video View size has changed");
        _localVideoSize = size;
    } else {
        NSLog(@"DEMO APP: Remote Video View size has changed");
        _remoteVideoSize = size;
         [self stopTimer];
    }
    
    [self updateVideoViewLayout];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Time
-(void)startTimer{
    _start_date = [NSDate date];
    _clockTicks = [NSTimer scheduledTimerWithTimeInterval:1.0/100.0
                                                   target:self
                                                 selector:@selector(updateTimer)
                                                 userInfo:nil
                                                  repeats:YES];
    _callTicks = [NSTimer scheduledTimerWithTimeInterval:1.0/100.0
                                                   target:self
                                                 selector:@selector(updateCallTimer)
                                                 userInfo:nil
                                                  repeats:YES];
}
-(void)stopTimer{
    [_clockTicks invalidate];
    _clockTicks = nil;
     NSLog(@"***********************************************************************");
    [self updateTimer];
    NSLog(@"***********************************************************************");
    
}

-(void)updateTimer{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:_start_date];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    _timerLabel.text = timeString;
    NSLog(@"timer = %@",timeString);
}

-(void)updateCallTimer{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:_start_date];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    _callTimeLabel.text = timeString;
}



@end


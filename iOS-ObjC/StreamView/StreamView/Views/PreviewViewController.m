 //
//  PreviewViewController.m
//  StreamView
//
//  Created by Jeff Smith on 4/2/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//

#import "PreviewViewController.h"
#import "SWRevealViewController.h"
#import "CameraSettingsViewController.h"

@interface PreviewViewController () <UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property NSMutableArray *address_Arr;
@property NSMutableArray *label_Arr;
@property NSMutableArray *url_Arr;
@property NSMutableArray *image_Arr;
@property NSTimer *thumbNailTimer;
@property NSTimer *refreshTimer;
@property (strong, nonatomic) IBOutlet UICollectionView *accountCameras;

@end

@implementation PreviewViewController {
    AppDelegate *appDelegate;
    DemoOnCallViewController *onCallViewController;
    NSString *callID;
    NSString *peerID;
    BOOL isBroadcaster;
    BOOL incomingCall;
    BOOL incall;
    AVPlayer *hlsPlayer;
    AVPlayerViewController *hlsPlayerController;
}

@synthesize Collection_view;

- (void)viewDidAppear:(BOOL)animated {
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate moveClient] setDelegate:self];
}


- (void)viewDidLoad {
    
    _address_Arr = [[NSMutableArray alloc] init];
    _label_Arr   = [[NSMutableArray alloc] init];
    _url_Arr     = [[NSMutableArray array] init];
    _image_Arr   = [[NSMutableArray array] init];
    
    // lbl.text = @"00.00.00.000";
    incall = false;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    /*
    if ([appDelegate moveClient] == nil || ![[appDelegate moveClient] isConnected]) {
        NSLog(@"Connecting to Move");
        // Set up Move Client
        [appDelegate setMoveClient: [[MoveClient alloc] init]];
        [[appDelegate moveClient] setDelegate:self];
        [[appDelegate moveClient] setQuality:QualityHigh];
        [[appDelegate moveClient] connectToMove:kMoveURL];
    }
     */
    
     [[appDelegate moveClient] setDelegate:self];
    
    //get the camera servives
    [self getCameraThumbURL];
    
    //parse the services to find the cameras
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(refreshThumbs) userInfo:nil repeats:YES];
    _thumbNailTimer = [NSTimer scheduledTimerWithTimeInterval:(20*60.0) target:self selector:@selector(getCameraThumbURL) userInfo:nil repeats:YES];
 
    
    [super viewDidLoad];
    
    _barButton.target = self.revealViewController;
    _barButton.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

-(void)getCameraInfo {
    for (NSString* cameraAddress in _address_Arr) {
        NSLog(@"sending message to camera %@",cameraAddress);
       // [[appDelegate moveClient] sendToService:cameraAddress withData:@{ @"item1" : @"one", @"item2" : @"two"} withClass:@"getCameraInfo"];
    }
    //- (void)sendToService:(NSString*)toServiceID withData:(NSDictionary*)data withClass:(NSString*)className;
}

-(void)refreshThumbs {
    if (!incall) {
        NSLog(@"Refreshing images");
        [_accountCameras reloadItemsAtIndexPaths:_accountCameras.indexPathsForVisibleItems];
    }
}

-(void)getCameraThumbURL {
    NSLog(@"get images urls");
    MoveRegistration* currReg = [[appDelegate moveClient] currentReg];
    NSArray* cameraServiceArray = [currReg getCameras];
    
    //clear all arrays
    [_label_Arr removeAllObjects];
    [_image_Arr removeAllObjects];
    [_url_Arr removeAllObjects];
    [_address_Arr removeAllObjects];
    
    for (MoveService* itService in cameraServiceArray) {
        [_label_Arr addObject:[itService name]];
        [_image_Arr addObject:[NSNull null]];
        [_url_Arr addObject:[NSNull null]];
        
        
        //Ask for an URL
        NSArray *addrArray = [[itService addresses] allObjects];
        for (MoveServiceAddress* msa in addrArray) {
            [_address_Arr addObject:[msa address]];
            [[appDelegate moveClient] getCameraURL: [msa address]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _address_Arr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Call_ID" forIndexPath:indexPath];
    
    UIImageView *Image_View = ( UIImageView *)[cell viewWithTag:100];
    UILabel *Label = (UILabel *) [cell viewWithTag:101];
    UIButton *ConfigButton = (UIButton *) [cell viewWithTag:101];
    
    //load image
    Label.text = [_address_Arr objectAtIndex:indexPath.row];
    if ([[_address_Arr objectAtIndex:indexPath.row] isEqualToString:@"ALL"]) {
        Image_View.image = Nil;
        NSLog(@"Load the ALL pictures");
        Image_View.image= [UIImage imageNamed:@"AllCameras"];
        Image_View.contentMode = UIViewContentModeScaleAspectFit;
    } else  {
        [self loadImage:indexPath.row intoImageView:Image_View];
        if (_image_Arr[indexPath.row] != [NSNull null]) {
            Image_View.image = _image_Arr[indexPath.row];
            Image_View.contentMode = UIViewContentModeScaleAspectFill;
        } else {
            Image_View.image = nil;
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void) loadImage:(NSInteger)row intoImageView:(UIImageView*)imageView {
    //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"yyyyMMddHHmmss"];
    //NSDate *currentDate = [NSDate date];
    //NSString *dateString = [formatter stringFromDate:currentDate];
    
    if ([_url_Arr count] > row) {
        dispatch_async(dispatch_get_global_queue(0,0), ^{
           // NSString *fileURL =[NSString stringWithFormat:@"%@&%@",_url_Arr[row],dateString];
            //NSLog(@"the image for row %@",(long)row);
            NSError* error = nil;
            if (_url_Arr[row] != [NSNull null]) {
                NSLog(@"***********************************************************************************");
                NSLog(@"URL is %@",_url_Arr[row]);
                NSLog(@"***********************************************************************************");
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_url_Arr[row]] options:NSDataReadingUncached error:&error];
                //NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:_url_Arr[row]]];
                if ( data == nil )
                    return;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image =  [UIImage imageWithData: data];
                    _image_Arr[row] =  [UIImage imageWithData: data];
                });
            }
        
        });
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfItems = [collectionView numberOfItemsInSection:0];
    if (numberOfItems > 3) {
        numberOfItems = 3;
    }
    return CGSizeMake(CGRectGetWidth(collectionView.frame), (CGRectGetHeight(collectionView.frame))/numberOfItems);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* deviceid = [_address_Arr objectAtIndex:indexPath.row];
    NSLog(@"Touch happend on path %@",deviceid);
    
    [[appDelegate moveClient] setReceiveAudio:YES];
    [[appDelegate moveClient] setReceiveVideo:YES];
    [[appDelegate moveClient] setSendAudio:NO];
    [[appDelegate moveClient] setSendVideo:NO];
    
    self.remoteConnectionId  = deviceid;
    if (![deviceid isEqualToString:@"ALL"]) {
        [self setupOutgoingCall];
    } else {
        [self joinRoom:@"camera"];
    }
}
- (IBAction)cameraConfigButtonDown:(id)sender {
     [self performSegueWithIdentifier:@"showDeviceDetails" sender:sender];
}
- (IBAction)manualSnapShot:(id)sender {
    UICollectionViewCell* cell = (UICollectionViewCell*)[[sender superview] superview];
    NSIndexPath *indexPath = [self.Collection_view indexPathForCell:cell];
    NSInteger  selectedDeviceRow= [indexPath row];
    
    [[appDelegate moveClient] createEvent:@"SnapShot" forDevice:[_address_Arr objectAtIndex:selectedDeviceRow]];
}
- (IBAction)manualRecord:(id)sender {
    UICollectionViewCell* cell = (UICollectionViewCell*)[[sender superview] superview];
    NSIndexPath *indexPath = [self.Collection_view indexPathForCell:cell];
    NSInteger  selectedDeviceRow= [indexPath row];
    
    [[appDelegate moveClient] createEvent:@"RecordVideo" forDevice:[_address_Arr objectAtIndex:selectedDeviceRow]];
}
- (IBAction)playSiren:(id)sender {
    UICollectionViewCell* cell = (UICollectionViewCell*)[[sender superview] superview];
    NSIndexPath *indexPath = [self.Collection_view indexPathForCell:cell];
    NSInteger  selectedDeviceRow= [indexPath row];
    
    [[appDelegate moveClient] createEvent:@"PlaySiren" forDevice:[_address_Arr objectAtIndex:selectedDeviceRow]];
}

- (IBAction)stopSiren:(id)sender {
    UICollectionViewCell* cell = (UICollectionViewCell*)[[sender superview] superview];
    NSIndexPath *indexPath = [self.Collection_view indexPathForCell:cell];
    NSInteger  selectedDeviceRow= [indexPath row];
    
    [[appDelegate moveClient] createEvent:@"StopSiren" forDevice:[_address_Arr objectAtIndex:selectedDeviceRow]];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([[segue identifier] isEqualToString:@"showDeviceDetails"]) {
        
        UICollectionViewCell* cell = (UICollectionViewCell*)[[sender superview] superview];
        NSIndexPath *indexPath = [self.Collection_view indexPathForCell:cell];
        NSInteger  selectedDeviceRow= [indexPath row];
        
        CameraSettingsViewController* cameraSettingViewController = [segue destinationViewController];
        
        
        cameraSettingViewController.deviceID = [_address_Arr objectAtIndex:selectedDeviceRow];
    }
}


//**************************************************************************************************************************

- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

- (void) initOnCallViewController {
    onCallViewController = nil;
    onCallViewController = [[DemoOnCallViewController alloc] init];
    [onCallViewController setDelegate:self];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect fullScreenFrame = CGRectMake(0, 0, screenWidth, screenHeight);
    //[onCallViewController setRemoteVideoView:[[RTCEAGLVideoView alloc] initWithFrame:fullScreenFrame]];
    //Setting up the local view as fullscreen for now. This will be adjusted dynamically in the onCallController;
    [onCallViewController setLocalVideoView:[[RTCEAGLVideoView alloc] initWithFrame:fullScreenFrame]];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction) startCall:(id)sender {

}
/*
- (IBAction) startCall:(id)sender {
    [self setRemoteConnectionId:[[_remoteConnectionIdInput text] uppercaseString]];
    
    // Starting call via CallKit
    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:[self remoteConnectionId]];
    CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:[NSUUID UUID] handle:handle];
    [startCallAction setVideo:YES];
    
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:startCallAction];
    
    [callController requestTransaction:transaction completion:^(NSError *error) {
        if (error) {
            NSLog(@"DEMO APP: Error requesting transaction: %@", error);
        } else {
            NSLog(@"DEMO APP: Requested Transaction Successfully");
        }
    }];
}
*/

- (void) setupOutgoingCall {
    incomingCall = NO;
    NSLog(@"DEMO APP: Setting up call to %@", [self remoteConnectionId]);
    
    [self initOnCallViewController];
    [[appDelegate moveClient] setReceiveAudio:YES];
    [[appDelegate moveClient] setReceiveVideo:YES];
    [[appDelegate moveClient] setSendAudio:YES];
    [[appDelegate moveClient] setSendVideo:NO];
    [[appDelegate moveClient] setupWithPreviewLayer:[onCallViewController localVideoView] camera:YES];
    
    if([[appDelegate moveClient] isWebRTCSetup]) {
        NSLog(@"On Call View is ready, Starting call...");
        [[appDelegate moveClient] placeCall:[self remoteConnectionId] destType:@"TN" message:@"Camera"];
        [self presentViewController:onCallViewController animated:YES completion:nil];
        incall =true;
        [[appDelegate moveClient] mute:true];
    } else {
        onCallViewController = nil;
        NSLog(@"DEMO APP: Starting Call failed, WebRTC not ready");
    }
}

- (void) setupIncomingCall {
    incomingCall = YES;
    [[appDelegate moveClient] setReceiveAudio:YES];
    [[appDelegate moveClient] setReceiveVideo:YES];
    [[appDelegate moveClient] setSendAudio:YES];
    [[appDelegate moveClient] setSendVideo:YES];
    [self initOnCallViewController];
    [[appDelegate moveClient] setupWithPreviewLayer:[onCallViewController localVideoView] camera:YES];
    
    if([[appDelegate moveClient] isWebRTCSetup]) {
        [[appDelegate moveClient] acceptCall:callID peer:peerID];
        // [[appDelegate moveClient] processState:@"accept"];
        [self presentViewController:onCallViewController animated:YES completion:nil];
    } else {
        [[appDelegate moveClient] declineCall:callID peer:peerID];
        
        //        [[appDelegate moveClient] processState:@"decline"];
        onCallViewController = nil;
        NSLog(@"DEMO APP: Accepting Call failed, WebRTC not ready");
    }
}

- (void)getStreamForwardCallId {
    NSString *sessionId = [[NSUUID UUID] UUIDString];
    NSString *url = [NSString stringWithFormat:@"%@/forward?name=camera1&guid=%@&filename=.m3u8", kStreamURL, sessionId];
    NSString *authcode = @"DEMO20171118";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:authcode forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"requestReply: %@", responseString);
        NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *jsonError;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError) {
            NSLog(@"ERROR: %@", jsonError);
        } else {
            [self onForwardResponse:[responseDict valueForKey:@"cid"] callId:[responseDict valueForKey:@"CALL_ID"]];
        }
    }] resume];
}

- (void)startForwardJoin:(NSString*)callID{
    isBroadcaster = NO;
    [[appDelegate moveClient] setReceiveAudio:YES];
    [[appDelegate moveClient] setReceiveVideo:YES];
    [[appDelegate moveClient] setSendAudio:YES];
    [[appDelegate moveClient] setSendVideo:YES];
    //MOVECLIENT SETS setSendAudio and setSendVideo to false after preview layer is setup.
   // callID = [_callIdInput text];
    
    NSString* moveClientCID = [appDelegate moveClient].currentReg.registrationId;
    
    NSString *sessionId = [[NSUUID UUID] UUIDString];
    NSString *url = [NSString stringWithFormat:@"%@/forward?name=camera1&guid=%@&filename=.m3u8&room=%@&cid=%@", kStreamURL, sessionId, callID, moveClientCID];
    NSString *authcode = @"84CE47335D000";
    NSLog(@"DEMO APP:calling forward with url:  %@", url);
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:authcode forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"requestReply: %@", responseString);
        NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *jsonError;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonError];
        NSLog(@"DEMO APP: got forward join response:  %@", [responseDict description]);
        
        if (jsonError) {
            NSLog(@"ERROR: %@", jsonError);
        } else {
            [self setupForwardJoinCall:responseDict[@"CALL_ID"] peerId:responseDict[@"cid"]];
        }
    }] resume];
}

- (void)joinRoom:(NSString*)callID {
    isBroadcaster = YES;
    [[appDelegate moveClient] setReceiveAudio:YES];
    [[appDelegate moveClient] setReceiveVideo:YES];
    [[appDelegate moveClient] setSendAudio:NO];
    [[appDelegate moveClient] setSendVideo:NO];
    
    [self initOnCallViewController];
    [[appDelegate moveClient] setupWithPreviewLayer:[onCallViewController localVideoView] camera:YES];
    [self presentViewController:onCallViewController animated:YES completion:nil];
    
    //callID = [_roomIdInput text];
    BOOL owner = false;
    [[appDelegate moveClient] joinRoom:callID owner:owner];
}

- (void)startStream {
    isBroadcaster = YES;
    [[appDelegate moveClient] setReceiveAudio:YES];
    [[appDelegate moveClient] setReceiveVideo:YES];
    [[appDelegate moveClient] setSendAudio:YES];
    [[appDelegate moveClient] setSendVideo:YES];
    
    [self getStreamForwardCallId];
    //    [[appDelegate moveClient] streamForward];
}

- (void)startMonitor:(NSString*)callID {
    isBroadcaster = NO;
    [[appDelegate moveClient] setReceiveAudio:YES];
    [[appDelegate moveClient] setReceiveVideo:YES];
    [[appDelegate moveClient] setSendAudio:NO];
    [[appDelegate moveClient] setSendVideo:NO];
    //callID = [_callIdInput text];
    [self setupForwardCall:callID];
    //    [[appDelegate moveClient] monitorCall:callID];
}

- (void)startHLSMonitor:(NSString*)callID {
    isBroadcaster = NO;
    //callID = [_callIdInput text];
    NSLog(@"Starting HLS Monitor Call using CallID: %@", callID);
    NSString *streamURL = [NSString stringWithFormat:@"%@/demo/%@.m3u8", kStreamURL, callID];
    hlsPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:streamURL]];
    hlsPlayerController = [[AVPlayerViewController alloc] init];
    [hlsPlayerController setPlayer:hlsPlayer];
    [hlsPlayerController setDelegate:self];
    [hlsPlayerController setShowsPlaybackControls:false];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UIButton *endButton = [[UIButton alloc] initWithFrame:CGRectMake(5, screenSize.height - 55, screenSize.width - 10, 50)];
    [endButton setBackgroundColor:[UIColor redColor]];
    [endButton setTitle:@"End" forState:UIControlStateNormal];
    [endButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [endButton addTarget:self action:@selector(endHLSMonitor:) forControlEvents:UIControlEventTouchUpInside];
    [[hlsPlayerController view] addSubview:endButton];
    [self presentViewController:hlsPlayerController animated:YES completion:^{
        [hlsPlayer play];
    }];
}

- (void)endHLSMonitor:(id)sender {
    [hlsPlayer pause];
    [self dismissViewControllerAnimated:YES completion:^{
        hlsPlayer = nil;
        hlsPlayerController = nil;
    }];
}

#pragma mark - MoveConnectionDelegate
- (void)connectionConnected {
    NSLog(@"DEMO APP: Connection Connected");
    
    [[appDelegate moveClient] unregister];
    [[appDelegate moveClient] register:@"screen"];
}
- (void)connectionFailed:(NSError *)message {
    NSLog(@"DEMO APP: Connection Failed");
}
- (void)connectionClosed {
    NSLog(@"DEMO APP: Connection Closed");
}
- (void)onReady {
    NSLog(@"DEMO APP: WebRTC Ready");
}
- (void)onCalling {
    NSLog(@"DEMO APP: WebRTC Calling");
}
- (void)promptForAnswerCall:callID caller:destCID {
    NSLog(@"DEMO APP: WebRTC Accepting");
    
    //    __block NSString* newCaller = [[appDelegate moveClient] tempWebRTCDest];
    //    __block NSString* caller = [[appDelegate moveClient] webRTCDest];
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //    if([[appDelegate moveClient] isWebRTCSetup]) {
    //
    //        NSString* message = [NSString stringWithFormat:@"There is an incoming video call from %@. Answering the call will end your current call with %@.", dest, current];
    //
    //        UIAlertController *incomingCallAlertController = [UIAlertController alertControllerWithTitle:@"Incoming Video Call" message:message preferredStyle:UIAlertControllerStyleAlert];
    //        UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
    //            // End current call and answer new call
    //            [[appDelegate moveClient] processState:@"hangup"];
    //
    //            // Loop until the hangup is complete... probably not the best technique
    //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //                while ([[appDelegate moveClient] webRTCState]) {}
    //                dispatch_async(dispatch_get_main_queue(), ^{
    //                    NSLog(@"DEMO APP: Accepting new call");
    //                    [[appDelegate moveClient] setupWithPreviewLayer:[onCallViewController localVideoView] remoteView:[onCallViewController remoteVideoView] camera:YES];
    //                    [[appDelegate moveClient] processState:@"accept"];
    //                });
    //            });
    //        }];
    //
    //        UIAlertAction *declineAction = [UIAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
    //            [[appDelegate moveClient] processState:@"decline"];
    //        }];
    //
    //        [incomingCallAlertController addAction:acceptAction];
    //        [incomingCallAlertController addAction:declineAction];
    //        [onCallViewController presentViewController:incomingCallAlertController animated:YES completion:nil];
    //
    //    } else {
    //        incomingCallViewController = [[DemoIncomingCallViewController alloc] init];
    //        [incomingCallViewController setCallerId:[[appDelegate moveClient] webRTCDest]];
    //        [incomingCallViewController setDelegate:self];
    //        [incomingCallViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    //        [self presentViewController:incomingCallViewController animated:YES completion:nil];
    //    }
}
- (void)onOffering {
    NSLog(@"DEMO APP: WebRTC Offering");
    //    [[appDelegate moveClient] makeOffer];
}
- (void)onAnswering {
    NSLog(@"DEMO APP: WebRTC Answering");
}
- (void)onConnecting {
    NSLog(@"DEMO APP: WebRTC Connection");
}
- (void)onDeclining {
    NSLog(@"DEMO APP: WebRTC Declining");
}
- (void)onHangup:(NSString*) callId {
    NSLog(@"DEMO APP: WebRTC Ending");
    
    if ([UIApplication sharedApplication].keyWindow.rootViewController != self) {
        [onCallViewController dismissViewControllerAnimated:YES completion:nil];
        
        
    }
    incall = false;
    onCallViewController = nil;
}
- (void)onUnanswered {
    NSLog(@"DEMO APP: WebRTC Unanswered");
}
- (void)onCancelled {
    NSLog(@"DEMO APP: WebRTC Cancelled");
}
- (void)onReset {
    NSLog(@"DEMO APP: WebRTC Reset");
     if ([UIApplication sharedApplication].keyWindow.rootViewController != self) {
         [onCallViewController dismissViewControllerAnimated:YES completion:nil];
     }
    onCallViewController = nil;
}
- (void)onError:(NSString*)message title:(NSString*)title {
    NSLog(@"DEMO APP: WebRTC Error: %@: %@", title, message);
}
- (void)addLocalVideoTrack:(id)localVideoTrack {
    NSLog(@"DEMO APP: Adding Local Video Track");
    if([appDelegate moveClient].receiveVideo){
        [onCallViewController setLocalVideoTrack:localVideoTrack];
    } else {
        [onCallViewController setRemoteVideoTrack:localVideoTrack];
    }
}
- (void)addRemoteVideoTrack:(id)remoteVideoTrack callId:callId peerId:peerId {
    NSLog(@"DEMO APP: Add remote Video Track");
    [onCallViewController setRemoteVideoTrack:remoteVideoTrack callId:callId peerId:peerId];
}

- (void)removeRemoteVideoTrack:(id)remoteVideoTrack callId:(NSString *)callId peerId:(NSString *)peerId{
    [onCallViewController unsetRemoteVideoTrack:remoteVideoTrack callId:callId peerId:peerId];
}

- (void)onCallId:(NSString *)callId withPeer:cid{
    NSLog(@"DEMO APP: Call ID: %@ peer: %@", callId, cid);
    callID = callId;
    peerID = cid;
    if (onCallViewController != nil) {
        [onCallViewController setCallID:callID];
    }
}

- (void)onForwardResponse:(NSString *)connectionId callId:(NSString *)callId{
    NSLog(@"DEMO APP: Forward Response -> %@", connectionId);
    _remoteConnectionId = connectionId;
    [self setupForwardJoinCall:callId peerId:connectionId];
}


- (void) setupForwardJoinCall:(NSString *)callId peerId:(NSString *)peerId {
    dispatch_async(dispatch_get_main_queue(), ^{
        incomingCall = NO;
        NSLog(@"DEMO APP: Forward Join Response -> callid: %@ peerId %@", callId, peerId);
        
        [self initOnCallViewController];
        [[appDelegate moveClient] setupWithPreviewLayer:[onCallViewController localVideoView] camera:YES];
        
        if([[appDelegate moveClient] isWebRTCSetup]) {
            NSLog(@"On Call View is ready, Starting call...");
            [[appDelegate moveClient] monitorCallForward:callId peer:peerId];
            [self presentViewController:onCallViewController animated:YES completion:nil];
        } else {
            onCallViewController = nil;
            NSLog(@"DEMO APP: Starting Call failed, WebRTC not ready");
        }
    });
}

- (void) setupForwardCall:(NSString *)callId {
    incomingCall = NO;
    NSLog(@"DEMO APP: Setting up call to %@", [self remoteConnectionId]);
    
    [self initOnCallViewController];
    [[appDelegate moveClient] setupWithPreviewLayer:[onCallViewController localVideoView] camera:YES];
    
    if([[appDelegate moveClient] isWebRTCSetup]) {
        NSLog(@"On Call View is ready, Starting call...");
        [[appDelegate moveClient] monitorCall:callId];
        [self presentViewController:onCallViewController animated:YES completion:nil];
    } else {
        onCallViewController = nil;
        NSLog(@"DEMO APP: Starting Call failed, WebRTC not ready");
    }
}

- (void)onSetupResponse:(NSString *)connectionId {
    NSLog(@"DEMO APP: Setup Response -> %@", connectionId);
    _remoteConnectionId = connectionId;
    [self setupOutgoingCall];
}

- (void)onHangupPeer:(NSString *)connectionId connections:(NSNumber *)connections {
    NSLog(@"DEMO APP: Hang up Peer: %@ connections remaining: %@", connectionId, connections);
}

- (void)onMonitorPeer:(NSString *)connectionId connections:(NSNumber *)connections{
    NSLog(@"DEMO APP: Monitor Peer: %@ connections: %@", connectionId, connections);
}

// Optional MoveConnectionDelegate methods
- (void)videoFrozen:(BOOL)isFrozen {
    NSLog(@"DEMO APP: Video Frozen? %@", (isFrozen ? @"YES" : @"NO"));
}
- (void)registrationBroken {
    NSLog(@"DEMO APP: Registration Broken");
}
- (void)registrationReceived:(NSString *)id withReg:(MoveRegistration*)reg {
    NSLog(@"DEMO APP: Registration Received. REG: %@", reg.tn);
    
    [self setLocalConnectionId:reg.tn];
    //[_localConnectionIdLabel setText:[NSString stringWithFormat:@"Connection ID: %@", [self localConnectionId]]];
}
- (void)registrationUpdate:(NSString *)id withReg:(MoveRegistration*)reg {
    NSLog(@"DEMO APP: Registration Updated. ID: %@ | REG: %@", id, reg);
}
- (void)registrationSubscribe:(NSString *)id withReg:(MoveRegistration*)reg {
    NSLog(@"DEMO APP: Registration Subscribe. ID: %@ | REG: %@", id, reg);
}
- (void)accountReceived:(MoveAccount *)account {
    NSLog(@"DEMO APP: Account Received: %@", account);
}
- (void)invalidAccountReceived:(NSString*)username contact:(NSString*)contact {
    NSLog(@"DEMO APP: Invalid Account Received. USERNAME: %@ | CONTACT: %@", username, contact);
}
- (void)historyReceived:(NSArray *)history {
    NSLog(@"DEMO APP: History Recived");
}
- (void)contactsReceived:(NSArray *)contacts {
    NSLog(@"DEMO APP: Contacts Recieved");
}
- (void)messagesReceived:(NSArray *)messages {
    NSLog(@"DEMO APP: Messages Received");
}
- (void)notificationReceived:(MoveNotification *)notification {
    NSLog(@"DEMO APP: Notification Received: %@", notification);
    [self getCameraInfo];
}
- (void)rawMessageReceived:(NSString *)message {
    //    NSLog(@"DEMO APP: Raw Message Received: %@", message);
}
- (void)unexpectedMoveError:(NSString*)message title:(NSString*)title hangup:(BOOL)hangup {
    NSLog(@"DEMO APP: Unexpected Move Error - %@: %@", title, message);
}
- (void)addVideoCallRecord:(NSString*)callHistoryID duration:(double)duration location:(NSString*)location
              dateReceived:(NSDate*)date dest:(NSString*)dest wasMissed:(BOOL)wasMissed wasOutgoing:(BOOL)wasOutgoing {
    NSLog(@"DEMO APP: Add Video Call Record");
}

- (void)onCallNotify:(NSString *)name value:(NSString *)value connection:(NSString *)connectionId {
    NSLog(@"DEMO APP: oncall notify: %@", value);
}

- (void)onCancelled:(NSString *)callId {
    NSLog(@"DEMO APP: onCancelled: %@", callId);
}

- (void)cameraThumnailURLReceived:(NSString *)url deviceID:(NSString*)deviceID {
    for (int i=0; i< [_address_Arr count]; i++) {
        NSLog(@"DEMO APP: trying to match deviceIDs to store URL %@ = %@", (NSString*)_address_Arr[i], deviceID);
        if ([(NSString*)_address_Arr[i] isEqualToString:deviceID]) {
            NSLog(@"DEMO APP: got URL for : %@", deviceID);
            //NSString *unEncodeURL = [url stringByRemovingPercentEncoding];
            NSLog(@"URL for getting camera %@ thumbmail is %@",deviceID,url);
            [_url_Arr insertObject:url atIndex:i];
            break;
        }
    }
    [self refreshThumbs];
}

- (void)configChange:(NSDictionary *)data {
     NSLog(@"DEMO APP: got configupdate : %@", data);
}
- (void)configChange:(NSDictionary *)data deviceID:(NSString*)deviceID {
    NSLog(@"DEMO APP: got configupdate : %@   %d", data, deviceID);
}

-(void)RecordVideoEvent:(NSString *)eventID  deviceID:(NSString*)deviceID  thumbnailURL:(NSString*)thumbnailURL recordedVideoURL:(NSString*)recordedVideoURL {
     NSLog(@"DEMO APP: got RecordVideoEvent : %@", deviceID);
}
- (void)SnapShotEvent:(NSString *)eventID  deviceID:(NSString*)deviceID  thumbnailURL:(NSString*)thumbnailURL {
     NSLog(@"DEMO APP: got SnapShotEvent : %@", deviceID);
}

-(void)StopRecordVideoEvent:(NSString *)eventID  deviceID:(NSString*)deviceID {
    NSLog(@"DEMO APP: got StopRecordVideoEvent: %@", deviceID);
}

-(void)PlaySirenEvent:(NSString *)eventID  deviceID:(NSString*)deviceID {
    NSLog(@"DEMO APP: got PlaySirenEvent: %@", deviceID);
}

-(void)StopPlaySirenEvent:(NSString *)eventID  deviceID:(NSString*)deviceID {
    NSLog(@"DEMO APP: got StopPlaySirenEvent: %@", deviceID);
}

- (void)addDevice:(NSDictionary *)data deviceID:(NSString*)deviceID{
    NSLog(@"DEMO APP: got addDevice: %@", deviceID);
}

- (void)addDeviceFail:(NSString*)cameraID ErrorMessage:(NSString*)errorMessage{
    NSLog(@"DEMO APP: got addDeviceFail: %@ - %@", cameraID, errorMessage);
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - DemoOnCallViewContollerDelegate

- (void)muteCall:(BOOL)muted {
    [[appDelegate moveClient] mute:muted];
}

- (void)muteRemoteCall:(BOOL)muted callId:(NSString*)callId{
    [[appDelegate moveClient] muteRemote:muted call:callId];
}

- (void)freezeCall:(BOOL)frozen {
    [[appDelegate moveClient] freeze:frozen];
}

- (void)flipCamera:(BOOL)cameraIsFront {
    [[appDelegate moveClient] flipCamera:cameraIsFront];
}

- (void)endCall:(NSString*)callId {
    [[appDelegate moveClient] hangupCall:callId];
    
    //
    if ([UIApplication sharedApplication].keyWindow.rootViewController != self) {
        [onCallViewController dismissViewControllerAnimated:YES completion:nil];
        //[self.navigationController popViewControllerAnimated:YES];
    }
    onCallViewController = nil;
    //[self presentViewController:self animated:YES completion:nil];
   // [self.parentViewController presentViewController:self animated:YES completion:nil];

}

/*
#pragma mark - DemoProviderServiceDelegate

- (void) callKitDidAcceptCall {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupIncomingCall];
    });
}

- (void) callKitDidEndCall {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[appDelegate moveClient] hangupCall:callID];
        
        if (onCallViewController != nil && [onCallViewController isBeingPresented]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            onCallViewController = nil;
        }
    });
}

- (void) callKitDidSwitchCalls {
    // End current call and answer new call
    [[appDelegate moveClient] hangupCall:callID];
    
    // Loop until the hangup is complete... probably not the best technique
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //        while ([[appDelegate moveClient] webRTCState]) {}
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"DEMO APP: Accepting new call");
            [self dismissViewControllerAnimated:NO completion:nil];
            [self setupIncomingCall];
        });
    });
}

- (void) callKitDidStartCall {
    [self setupOutgoingCall];
}
*/

@end

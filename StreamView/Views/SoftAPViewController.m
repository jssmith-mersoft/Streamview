//
//  SoftAPViewController.m
//  StreamView
//
//  Created by Jeff Smith on 6/10/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//

#import "SoftAPViewController.h"
#import "SWRevealViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
@import NetworkExtension;

@interface SoftAPViewController () <UITableViewDelegate,UITableViewDataSource,NSStreamDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButton;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtSSID;
@property (strong, nonatomic) IBOutlet UILabel *lblCameraID;
@property (strong, nonatomic) IBOutlet UITableView *tblNetworks;

@property (strong, nonatomic) IBOutlet UIView *WaitView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property NSMutableArray *networkArray;
@end

@implementation SoftAPViewController {
    AppDelegate *appDelegate;
    NSString* currentSSID;
    NSString* provisioningSSID;
    Boolean onRealWifi;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    Boolean sendReady;
    
    NEHotspotConfiguration * currentNetworkConfig;
}

- (void)viewDidLoad {
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
   // [[appDelegate moveClient] close];
     _networkArray = [[NSMutableArray alloc] init];
    _barButton.target = self.revealViewController;
    _barButton.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    
    [_tblNetworks setDelegate:self];
    [_tblNetworks setDataSource:self];
    [super viewDidLoad];
    
    onRealWifi = TRUE;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@" network interfaces count %d", [ifs count]);
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            NSLog(@"ifnam= %@",ifnam);
            NSLog(@"info= %@",info);
            currentSSID = info[@"SSID"];
        }
        
    }
    sendReady = FALSE;
}
-(void)viewWillDisappear:(BOOL)animated{
    //Put the network back
    //reconnect to Move
    if (onRealWifi == FALSE) {
        NSLog(@"removign Config for SID :%@",provisioningSSID);
        [[NEHotspotConfigurationManager sharedManager] removeConfigurationForSSID:provisioningSSID];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)ConnectToSoftAP:(id)sender {
    NSLog(@"connect to SoftAP");
    
    provisioningSSID = @"KNOX-DB4A064D2PAZ7D883";
    NEHotspotConfiguration *configuration = [[NEHotspotConfiguration
                                              alloc] initWithSSID:provisioningSSID];
    configuration.joinOnce = YES;
    
    [[NEHotspotConfigurationManager sharedManager] applyConfiguration:configuration completionHandler:^(NSError *_Nullable error){
        NSLog(@"Conn to SoftAP");   // anInteger outside variables
        _WaitView.hidden=NO;
        //_spinner.startAnimating();
        [NSTimer scheduledTimerWithTimeInterval:2.0f
                                         target:self
                                       selector: @selector(connection)
                                       userInfo:nil
                                        repeats:NO];
        onRealWifi = FALSE;
     }];
}


- (IBAction)GetNetworks:(id)sender {
    NSLog(@"get networks");
    [self GetNetworks];
}

-(void) GetNetworks {
    
    [self sendToAP:@"{\"req\": \"list wifi\"}"];
}

- (IBAction)ConnectToSoftAPWifi:(id)sender {

}

- (IBAction)SetNetwork:(id)sender {
    NSLog(@"set network %@ %@",_txtSSID.text,_txtPassword.text);
    NSString* command = [NSString stringWithFormat:@"{\"req\": \"set wifi\", \"ssid\": \"%@\", \"password\": \"%@\"}",_txtSSID.text,_txtPassword.text];
    [self sendToAP:command];
    //Disconnect
    if (onRealWifi == FALSE) {
        NSLog(@"removign Config for SID :%@",provisioningSSID);
        [[NEHotspotConfigurationManager sharedManager] removeConfigurationForSSID:provisioningSSID];
    }
    //connect to Move again
    //[[appDelegate moveClient] reconnect];
}
- (IBAction)GetCameraID:(id)sender {
    NSLog(@"get camera ID");
    [self sendToAP:@"{\"req\": \"get device id\"}"];
}
- (IBAction)SetAccountID:(id)sender {
    NSLog(@"set accoount");
    NSString* command = [NSString stringWithFormat:@"{\"req\": \"set account id\",\"value\":\"%@\"}",[[appDelegate moveClient] currentReg].accountId];
    [self sendToAP:command];
}


- (IBAction)SetServer:(id)sender {
    NSLog(@"set server");
    //NSString* command = [NSString stringWithFormat:@"{\"req\": \"set server\",\"value\":\"ws://192.168.86.240:3000/ws\"}"];
    NSString* command = [NSString stringWithFormat:@"{\"req\": \"set server\",\"value\":\"ws://172.16.30.66:3000/ws\"}"];
    [self sendToAP:command];
    
}
- (IBAction)ExitSsoftAP:(id)sender {
    NSLog(@"exit soft AP");
    NSString* command = [NSString stringWithFormat:@"{\"req\": \"exit\"}"];
    [self sendToAP:command];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_networkArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"adding to table row %@",indexPath);
    static NSString *MyIdentifier = @"network";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
    [cell.textLabel setText: [_networkArray objectAtIndex:indexPath.row]];
     return cell;
                
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Selected row of section %d",(int)indexPath.row);
    _txtSSID.text = _networkArray[indexPath.row];
    if ([_networkArray[indexPath.row] caseInsensitiveCompare:@"pepperWifi"]==NSOrderedSame) {
        [_txtPassword setText:@"Pepper12345"];
    } else if ([_networkArray[indexPath.row] caseInsensitiveCompare:@"Clydesdale"]==NSOrderedSame) {
        [_txtPassword setText:@"coffeecup"];
    }else if ([_networkArray[indexPath.row] caseInsensitiveCompare:@"Mersoft"]==NSOrderedSame) {
        [_txtPassword setText:@"p0p.c0rn"];
    }
}

- (void)connection
{
    NSLog(@"has network %@",appDelegate.hasInet ? @"true" : @"false");
    if (appDelegate.hasInet) {
         NSLog(@"setting up telnet connection");
        //_spinner.stopAnimating()
        _WaitView.hidden=YES;
        if(inputStream && outputStream)
            [self close];

        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)@"192.168.8.1", 5053, &readStream, &writeStream);
       
        inputStream = (__bridge_transfer NSInputStream *)readStream;
        outputStream = (__bridge_transfer NSOutputStream *)writeStream;
        
        [inputStream setDelegate:self];
        [outputStream setDelegate:self];
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [inputStream open];
        [outputStream open];
        
        NSLog(@"Get the Network list in one sec");
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self
                                       selector: @selector(GetNetworks)
                                       userInfo:nil
                                        repeats:NO];
    } else {
        NSLog(@"Waiting for AP Network");
        [NSTimer scheduledTimerWithTimeInterval:0.5f
                                         target:self
                                       selector: @selector(connection)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)close {
    NSLog(@"Closing streams.");
    
    [inputStream close];
    [outputStream close];
    
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream setDelegate:nil];
    [outputStream setDelegate:nil];
    
    //[inputStream release];
    //[outputStream release];
    
    inputStream = nil;
    outputStream = nil;
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event {
    //NSLog(@"stream event received.");
    
    switch(event) {
        case NSStreamEventHasSpaceAvailable: {
            if(stream == outputStream) {
               // NSLog(@"started OutputStream.");
            }
            break;
        }
        case NSStreamEventHasBytesAvailable: {
            if(stream == inputStream) {
                NSLog(@"started inputStream.");
                
                uint8_t buf[1024];
                long len = 0;
                
                len = [inputStream read:buf maxLength:1024];
                
                if(len > 0) {
                    NSMutableData* data=[[NSMutableData alloc] initWithLength:0];
                    [data appendBytes: (const void *)buf length:len];
                    NSString *s = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

                    [self readFromAP:s];
                }
            }
            break;
        }
        case NSStreamEventErrorOccurred: {
            if(stream == inputStream) {
                NSLog(@"NSStreamEventErrorOccurred inputStream.");
            }
            if(stream == outputStream) {
                NSLog(@"NSStreamEventErrorOccurred outputStream.");
            }
            break;
        }
        case NSStreamEventOpenCompleted: {
            if(stream == inputStream) {
                NSLog(@"NSStreamEventOpenCompleted inputStream.");
                sendReady = TRUE;
                
                //NSLog(@"auto get networks");
                //[self sendToAP:@"{\"req\": \"list wifi\"}"];
            }
            if(stream == outputStream) {
                NSLog(@"NSStreamEventOpenCompleted outputStream.");
            }
            break;
        }
        default: {
            //NSLog(@"unhandled stream event: %@", event);
            break;
        }
    }
}

- (void)readFromAP:(NSString *)string {
    NSLog(@"AP-recevied: %@", string);
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization
                     JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    NSString* res = (NSString*) jsonObject[@"res"];
    if ([res caseInsensitiveCompare:@"list wifi"]==NSOrderedSame) {
        NSArray* values = (NSArray*)jsonObject[@"values"];
        if([values class] != [NSNull class]) {
            for(id network in values) {
                NSLog(@"ssid=%@ strength=%@", network[@"ssid"],network[@"strength"]);
                if ([((NSString*)network[@"ssid"]) compare:@""]) {
                    [_networkArray addObject:network[@"ssid"]];
                }
            }
        }
        [_tblNetworks reloadData];
        
        [self SetAccountID:nil];
    } else if ([res caseInsensitiveCompare: @"get device id"]==NSOrderedSame) {
        _lblCameraID.text = [NSString stringWithFormat:@"Camera ID is %@",jsonObject[@"value"]];
    }else if ([res caseInsensitiveCompare: @"set account id"]==NSOrderedSame) {
        NSLog(@"account ID is set");
        [self SetServer:nil];
    }
}

- (void)sendToAP:(NSString *)s {
    uint8_t *buf = (uint8_t *)[s UTF8String];
    
    [outputStream write:buf maxLength:strlen((char *)buf)];
    
    NSLog(@"AP-send: %@", s);
}
- (void)GetLocalNetworkList {
    /*
    void *airportHandle;
    
    NSArray *keys = [NSArray arrayWithObjects:@"SCAN_RSSI_THRESHOLD", @"SSID_STR", nil];
    NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInt:-100], ssid, nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSArray *found;
    
    
    int openResult = Apple80211Open(&airportHandle);
    NSLog(@"Openning wifi interface %@", (openResult == 0?@"succeeded":@"failed"));
    
    int bindResult = Apple80211BindToInterface(airportHandle, @IF_NAME);
    
    int scanResult = Apple80211Scan(airportHandle, &found, params);
    
    NSDictionary *network;
    
    // get the first network found
    network = [found objectAtIndex:0];
    int associateResult = Apple80211Associate(airportHandle, network,NULL);
    
    Apple80211Close(airportHandle);
    */
}

@end

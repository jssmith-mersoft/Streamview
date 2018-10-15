//
//  EventsViewController.m
//  StreamView
//
//  Created by Jeff Smith on 5/11/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//

#import "EventsViewController.h"
#import "SWRevealViewController.h"

@interface EventsViewController () <UITableViewDelegate, UITableViewDataSource,MoveConnectionDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButton;
@property (strong, nonatomic) IBOutlet UITableView *eventTable;
@property (nonatomic, strong) NSArray *moveEvents;
@property NSInteger eventPage;
@end

@implementation EventsViewController {
        AppDelegate *appDelegate;
}

- (void)viewDidLoad {
    _eventPage = 0;
    _barButton.target = self.revealViewController;
    _barButton.action = @selector(revealToggle:);
    [[self eventTable] setDelegate:self];
    [[self eventTable] setDataSource:self];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
   
    // Do any additional setup after loading the view.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate moveClient] setDelegate:self];
    
    [[appDelegate moveClient] retrieveEventHistory];
    
     [super viewDidLoad];
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self moveEvents] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"adding to table row %@",indexPath);
    NSDictionary* currentEvent = [self.moveEvents objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    
    
    if ([(NSString*)currentEvent[@"type"] isEqualToString:@"SnapShot"]) {
        cell.textLabel.text = @"Picture Taken";
    } else if ([(NSString*)currentEvent[@"type"] isEqualToString:@"RecordVideo"]) {
        cell.textLabel.text = @"Recorded Video";
    } else if ([(NSString*)currentEvent[@"type"] isEqualToString:@"PlaySound"]) {
        cell.textLabel.text = @"Played Sound";
    } else if ([(NSString*)currentEvent[@"type"] isEqualToString:@"PlaySiren"]) {
        cell.textLabel.text = @"Played Siren";
    } else if ([(NSString*)currentEvent[@"type"] isEqualToString:@"StopSiren"]) {
        cell.textLabel.text = @"Siren stopped";
    } else if ([(NSString*)currentEvent[@"type"] isEqualToString:@"StopRecordVideo"]) {
        cell.textLabel.text = @"Video recording stopped";
    } else if ([(NSString*)currentEvent[@"type"] isEqualToString:@"Reboot"]) {
        cell.textLabel.text = @"Device Reboot";
    } else if ([(NSString*)currentEvent[@"type"] isEqualToString:@"Reset"]) {
        cell.textLabel.text = @"Device Reset";
    } else if ([(NSString*)currentEvent[@"type"] isEqualToString:@"Motion"]) {
        cell.textLabel.text =[NSString stringWithFormat:@"%@  %@", @"Motion Detected",(NSString*)currentEvent[@"updated"] ];
    } else if ([(NSString*)currentEvent[@"type"] isEqualToString:@"DoorBell"]) {
        cell.textLabel.text = @"DoorBell Pressed";
    } else if ([(NSString*)currentEvent[@"type"] isEqualToString:@"Offline"]) {
        cell.textLabel.text = @"Device Offline";
    } else if ([(NSString*)currentEvent[@"type"] isEqualToString:@"Online"]) {
        cell.textLabel.text = @"Device Online";
    } else if ([(NSString*)currentEvent[@"type"] isEqualToString:@"FirmwareUpdate"]) {
        cell.textLabel.text = @"Firmware Updated";
    }
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSError* error = nil;
        NSString* url = (NSString*)currentEvent[@"media_thumbnail_url"];
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:NSDataReadingUncached error:&error];
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image =  [UIImage imageWithData: data];
                [cell setNeedsDisplay];
            });
        }
    });
     //[[appDelegate moveClient] ];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    NSLog(@"selected %@",indexPath);
    NSDictionary* selectedEvent = (NSDictionary*)[_moveEvents objectAtIndex:indexPath.row];
    [[appDelegate moveClient] retrieveEventById:selectedEvent[@"id"]];
}

- (void)retrieveEventHistory:(NSArray *)events {
    NSLog(@"Got Events");
    _moveEvents = events;
    [[self eventTable] reloadData];
}

- (IBAction)deleteEvent:(id)sender {
    
    UITableViewCell* cell = (UITableViewCell*)[[sender superview] superview];
    NSIndexPath *indexPath = [self.eventTable indexPathForCell:cell];
    NSInteger  selectedDeviceRow = [indexPath row];
    
    NSLog(@"deleting row  %ld",(long)selectedDeviceRow);
    NSDictionary* selectedEvent = (NSDictionary*)[_moveEvents objectAtIndex:selectedDeviceRow];
    [[appDelegate moveClient] deleteEvent:selectedEvent[@"id"]];
    [[appDelegate moveClient] retrieveEventHistory:_eventPage];
}
- (IBAction)previousEvents:(id)sender {
    if (_eventPage > 0) {
        _eventPage--;
        [[appDelegate moveClient] retrieveEventHistory:_eventPage];
    }
}
- (IBAction)nextEvents:(id)sender {
    if ([_moveEvents count] >19) {
        _eventPage++;
        [[appDelegate moveClient] retrieveEventHistory:_eventPage];
    }
}

- (void)onReady{
}
- (void)connectionClosed {
}
- (void)connectionFailed:(NSError *)message{
}
- (void)connectionConnected{
}
@end

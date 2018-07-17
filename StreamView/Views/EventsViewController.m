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
@property (nonatomic, strong) NSMutableArray *moveEvents;
@end

@implementation EventsViewController {
        AppDelegate *appDelegate;
}

- (void)viewDidLoad {
    _barButton.target = self.revealViewController;
    _barButton.action = @selector(revealToggle:);
    
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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
     static NSString *CellIdentifier = @"EventCell";
    NSDictionary* currentEvent = [self.moveEvents objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = (NSString*)currentEvent[@"description"];
    
    return nil;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.moveEvents count];
}

- (void)retrieveEventHistory:(NSArray *)events {
    NSLog(@"Got Events");
    [[self moveEvents] arrayByAddingObjectsFromArray:events];
    [[self eventTable] reloadData];
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

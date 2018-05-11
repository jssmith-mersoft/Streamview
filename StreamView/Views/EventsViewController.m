//
//  EventsViewController.m
//  StreamView
//
//  Created by Jeff Smith on 5/11/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//

#import "EventsViewController.h"
#import "SWRevealViewController.h"

@interface EventsViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButton;

@end

@implementation EventsViewController

- (void)viewDidLoad {
    _barButton.target = self.revealViewController;
    _barButton.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

@end

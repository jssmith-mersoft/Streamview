//
//  AccountViewController.m
//  StreamView
//
//  Created by Jeff Smith on 5/11/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//

#import "AccountViewController.h"
#import "SWRevealViewController.h"

@interface AccountViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButton;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;
@property (strong, nonatomic) IBOutlet UILabel *accountidLabel;
@property (strong, nonatomic) IBOutlet UILabel *createdLabel;
@property (strong, nonatomic) IBOutlet UILabel *rawOut;
@end

@implementation AccountViewController{
    AppDelegate *appDelegate;
}

- (void)viewDidLoad {
    _barButton.target = self.revealViewController;
    _barButton.action = @selector(revealToggle:);
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _nameLabel.text = appDelegate.moveClient.currentReg.username;
    _accountidLabel.text = appDelegate.moveClient.currentReg.accountId;

    _rawOut.text = [NSString stringWithFormat:@"CID = %@",appDelegate.moveClient.currentReg.registrationId];
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

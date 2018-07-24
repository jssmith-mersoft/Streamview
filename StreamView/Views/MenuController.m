//
//  MenuController.m
//  StreamView
//
//  Created by Jeff Smith on 5/9/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//

#import "MenuController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"

@implementation MenuTableViewCell
@end

@interface MenuController ()

@end

@implementation MenuController {
    NSArray *menu;
    AppDelegate *appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.vendor) {
        menu = @[@"account",@"camera",@"provisioningQR",@"provisioningAP"];
    } else {
        menu = @[@"account",@"camera",@"events",@"recordings",@"provisioningQR",@"provisioningAP",@"mersoft"];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [menu count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *callIdentifier = [menu objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:callIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation
 - (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
 {
     if([segue isKindOfClass:[SWRevealViewControllerSegueSetController class] ]){
         UIViewController *dvc = [segue destinationViewController];
         UINavigationController *navCtrl = (UINavigationController *) self.revealViewController.frontViewController;
         [navCtrl setViewControllers:@[dvc] animated:NO];
         [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
     }
 }

@end

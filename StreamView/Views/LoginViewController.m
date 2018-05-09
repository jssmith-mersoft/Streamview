//
//  LoginViewController.m
//  StreamView
//
//  Created by Jeff Smith on 4/2/18.
//  Copyright © 2018 Mersoft. All rights reserved.
//


#import "LoginViewController.h"
#import "PreviewViewController.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *loginTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@end

@implementation LoginViewController{}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enteredPressed:(id)sender {
    if ([_loginTextField.text isEqualToString:@"a"] && [_passwordTextField.text isEqualToString:@"a"]) {
        NSLog(@"logged in");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"StreamView" bundle:nil];
        PreviewViewController *pvc = [storyboard instantiateViewControllerWithIdentifier:@"Preview"];
        [pvc setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:pvc animated:YES completion:nil];
    } else {
         NSLog(@"Not Logged in");
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"Finsihed Editing");
}

@end


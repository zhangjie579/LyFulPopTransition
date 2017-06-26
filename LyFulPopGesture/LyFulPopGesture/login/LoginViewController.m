//
//  LoginViewController.m
//  003
//
//  Created by 张杰 on 2017/6/24.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LoginViewController.h"
#import "ForgetViewController.h"
#import "LyTabBarController.h"
#import "UINavigationController+lyFulPopGesture.h"

@interface LoginViewController ()
- (IBAction)login:(id)sender;
- (IBAction)forget:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.ly_navBarHidden = YES;
}

- (IBAction)login:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LyTabBarController *vc = [story instantiateViewControllerWithIdentifier:@"LyTabBarController"];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
//    [UIApplication sharedApplication].keyWindow.rootViewController = vc;
}

- (IBAction)forget:(id)sender {
    [self.navigationController pushViewController:[[ForgetViewController alloc] init] animated:YES];
}
@end

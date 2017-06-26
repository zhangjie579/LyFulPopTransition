//
//  ViewController.m
//  003
//
//  Created by 张杰 on 2017/5/18.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "ViewController.h"
#import "TwoViewController.h"
#import "UINavigationController+lyFulPopGesture.h"

@interface ViewController ()

- (IBAction)push:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ly_currentTabBarControl = YES;
//    [self popGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self update:[UIColor lightGrayColor]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self update:[UIColor yellowColor]];
}


- (IBAction)push:(id)sender {
    TwoViewController *vc = [[TwoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

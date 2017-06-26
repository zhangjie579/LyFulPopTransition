//
//  TwoViewController.m
//  003
//
//  Created by 张杰 on 2017/6/22.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "TwoViewController.h"
#import "ThreeViewController.h"
#import "UINavigationController+lyFulPopGesture.h"

@interface TwoViewController ()

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.ly_fulPopGestureHidden = YES;
//    self.ly_navBarHidden = YES;
    
    self.title = @"two";
    self.view.backgroundColor = [UIColor blueColor];
    
    UIButton *btn = [[UIButton alloc] init];
    btn.backgroundColor = [UIColor orangeColor];
    btn.frame = CGRectMake(100, 100, 100, 100);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    self.navigationController.navigationBar.hidden = NO;
}

- (void)btnClick
{
    [self.navigationController pushViewController:[[ThreeViewController alloc] init] animated:YES];
}


@end

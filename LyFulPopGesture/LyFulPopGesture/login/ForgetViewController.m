//
//  ForgetViewController.m
//  003
//
//  Created by 张杰 on 2017/6/24.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "ForgetViewController.h"
#import "UINavigationController+lyFulPopGesture.h"

@interface ForgetViewController ()

@end

@implementation ForgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self update:[UIColor whiteColor]];
}

@end

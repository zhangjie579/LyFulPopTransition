//
//  ThreeViewController.m
//  003
//
//  Created by 张杰 on 2017/6/23.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "ThreeViewController.h"
#import "UINavigationController+lyFulPopGesture.h"

@interface ThreeViewController ()

@property(nonatomic,strong)UINavigationBar *navBar;

@end

@implementation ThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"three";
    self.view.backgroundColor = [UIColor whiteColor];

//    self.ly_fulPopGestureHidden = YES;
    
    self.navBar.barTintColor = [UIColor redColor];
//    [self.view addSubview:self.navBar];
}

- (UINavigationBar *)navBar
{
    if (!_navBar) {
        _navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    }
    return _navBar;
}

@end

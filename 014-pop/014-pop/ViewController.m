//
//  ViewController.m
//  014-pop
//
//  Created by 张杰 on 2017/6/26.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "ViewController.h"
#import "TwoViewController.h"
#import "LyTransitionAnimation.h"

@interface ViewController ()<UINavigationControllerDelegate>

@property(nonatomic,strong)LyTransitionAnimation                *transitionAnimation;

- (IBAction)push:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.navigationController.delegate = self;
}

// 代理方法1：
// 返回一个实现了UIViewControllerAnimatedTransitioning协议的对象，即完成转场动画的对象
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC
{
    self.transitionAnimation.navigationController = navigationController;
    self.transitionAnimation.operation = operation;
    return self.transitionAnimation;
}

// 代理方法2
// 返回一个实现了UIViewControllerInteractiveTransitioning协议的对象，即完成动画交互（动画进度）的对象
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return nil;
}

- (IBAction)push:(id)sender {
    [self.navigationController pushViewController:[[TwoViewController alloc] init] animated:YES];
}

- (LyTransitionAnimation *)transitionAnimation
{
    if (!_transitionAnimation) {
        _transitionAnimation = [[LyTransitionAnimation alloc] init];
    }
    return _transitionAnimation;
}

@end

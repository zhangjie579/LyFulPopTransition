//
//  TwoViewController.m
//  014-pop
//
//  Created by 张杰 on 2017/6/26.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "TwoViewController.h"
#import "LyTransitionAnimation.h"
#import "SwipeInteractiveTransition.h"

@interface TwoViewController ()<UINavigationControllerDelegate>

@property(nonatomic,strong)LyTransitionAnimation                *transitionAnimation;
@property(nonatomic,strong)SwipeInteractiveTransition           *swpieTransition;

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.delegate = self;
    [self.swpieTransition wireToViewController:self];
    
}

// 代理方法1：
// 返回一个实现了UIViewControllerAnimatedTransitioning协议的对象    ，即完成转场动画的对象
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
    return self.swpieTransition.interacting ? self.swpieTransition : nil;
}

- (LyTransitionAnimation *)transitionAnimation
{
    if (!_transitionAnimation) {
        _transitionAnimation = [[LyTransitionAnimation alloc] init];
    }
    return _transitionAnimation;
}

- (SwipeInteractiveTransition *)swpieTransition
{
    if (!_swpieTransition) {
        _swpieTransition = [[SwipeInteractiveTransition alloc] init];
    }
    return _swpieTransition;
}

@end

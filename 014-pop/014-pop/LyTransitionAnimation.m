//
//  LyTransitionAnimation.m
//  014-pop
//
//  Created by 张杰 on 2017/6/26.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "LyTransitionAnimation.h"

@implementation LyTransitionAnimation

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.4;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    //1.from,to的vc
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //1.1.frame
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    //这里只用toFrome，from的一直为0
    CGRect toFrome = [transitionContext finalFrameForViewController:toVc];
    
    //2.contentView
    UIView *containerView = [transitionContext containerView];
    
    if (self.operation == UINavigationControllerOperationPush)
    {
        /*
         1.push的话,toVc的x从screenWidth到0
         2.直接add，toVc即可
         */
        toVc.view.frame = CGRectOffset(toFrome, screenSize.width, 0);
        
        [containerView addSubview:toVc.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toVc.view.frame = toFrome;
        } completion:^(BOOL finished) {
            // 当动画执行完时，这个方法必须要调用，否则系统会认为你的其余操作都在动画执行过程中
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
    else if (self.operation == UINavigationControllerOperationPop)
    {
        /*
         1.pop的话,fromVC的x从0到screenWidth
         2.这需要把toVc添加到fromVC的下面
         */
        CGRect finishFrame = CGRectOffset(toFrome, screenSize.width, 0);
        
        [containerView insertSubview:toVc.view belowSubview:fromVc.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromVc.view.frame = finishFrame;
//            fromVc.view.transform = CGAffineTransformMakeTranslation([UIScreen mainScreen].bounds.size.width, 0);
        } completion:^(BOOL finished) {
            // 当动画执行完时，这个方法必须要调用，否则系统会认为你的其余操作都在动画执行过程中
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

@end

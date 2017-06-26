//
//  SwipeInteractiveTransition.m
//  014-pop
//
//  Created by 张杰 on 2017/6/26.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "SwipeInteractiveTransition.h"

@interface SwipeInteractiveTransition ()

@property(nonatomic,strong)UIPercentDrivenInteractiveTransition *interactiveTransition;
@property(nonatomic,  weak)UIViewController *presentingVC;

@end

@implementation SwipeInteractiveTransition

- (void)wireToViewController:(UIViewController *)viewController
{
    self.presentingVC = viewController;
    viewController.view.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(backHandle:)];
    [viewController.view addGestureRecognizer:panGesture];
}

//注意:如果不写这个会，pop取消的时候，返回会闪一闪的
-(CGFloat)completionSpeed
{
    return 1 - self.percentComplete;
}

- (void)backHandle:(UIPanGestureRecognizer *)recognizer
{
    [self customControllerPopHandle:recognizer];
}

- (void)customControllerPopHandle:(UIPanGestureRecognizer *)recognizer
{
    if(self.presentingVC.navigationController.childViewControllers.count == 1) return;
    
    // _interactiveTransition就是代理方法2返回的交互对象，我们需要更新它的进度来控制POP动画的流程。（以手指在视图中的位置与屏幕宽度的比例作为进度）
    CGFloat process = [recognizer translationInView:self.presentingVC.view].x / self.presentingVC.view.bounds.size.width;
    process = MIN(1.0, MAX(0.0, process));
    
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        // 此时，创建一个UIPercentDrivenInteractiveTransition交互对象，来控制整个过程中动画的状态
        self.interacting = YES;
        [self.presentingVC.navigationController popViewControllerAnimated:YES];
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self updateInteractiveTransition:process]; // 更新手势完成度
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded ||recognizer.state == UIGestureRecognizerStateCancelled)
    {
        self.interacting = NO;
        // 手势结束时，若进度大于0.5就完成pop动画，否则取消
        if(process > 0.5)
        {
            [self finishInteractiveTransition];
        }
        else
        {
//            self.completionSpeed = 1 - self.percentComplete;
            [self cancelInteractiveTransition];
        }
        
        self.interactiveTransition = nil;
    }
}

@end

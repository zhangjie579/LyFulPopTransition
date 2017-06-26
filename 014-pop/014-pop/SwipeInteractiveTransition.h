//
//  SwipeInteractiveTransition.h
//  014-pop
//
//  Created by 张杰 on 2017/6/26.
//  Copyright © 2017年 张杰. All rights reserved.
//  手势侧滑

#import <UIKit/UIKit.h>

@interface SwipeInteractiveTransition : UIPercentDrivenInteractiveTransition

@property (nonatomic, assign) BOOL interacting;
- (void)wireToViewController:(UIViewController*)viewController;

@end

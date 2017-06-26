//
//  LyTransitionAnimation.h
//  014-pop
//
//  Created by 张杰 on 2017/6/26.
//  Copyright © 2017年 张杰. All rights reserved.
//  push,pop转场动画

#import <UIKit/UIKit.h>

@interface LyTransitionAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property(nonatomic,assign)UINavigationControllerOperation  operation;
@property(nonatomic,weak  )UINavigationController           *navigationController;


@end

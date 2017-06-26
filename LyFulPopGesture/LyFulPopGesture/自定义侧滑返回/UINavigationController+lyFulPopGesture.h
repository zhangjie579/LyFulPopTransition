//
//  UINavigationController+lyFulPopGesture.h
//  LyFulPopGesture
//
//  Created by 张杰 on 2017/6/24.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (lyFulPopGesture)

@property(nonatomic,strong)UIPanGestureRecognizer *panGesture;
@property(nonatomic,assign)BOOL ly_currentTabBarControl;//当前是否为tabBarControl

@end

@interface UIViewController (lyFulPopGesture)

- (void)update:(UIColor *)color;

@property(nonatomic,assign)BOOL ly_fulPopGestureHidden;//全屏侧滑手势状态
@property(nonatomic,assign)BOOL ly_navBarHidden;//是否隐藏导航栏
@property(nonatomic,assign)BOOL ly_currentTabBarControl;//当前是否为tabBarControl

@end

/*注意:
 1.如果有UITabBarController的话，要将它颜色设置为clearColor不然会遮住
*/

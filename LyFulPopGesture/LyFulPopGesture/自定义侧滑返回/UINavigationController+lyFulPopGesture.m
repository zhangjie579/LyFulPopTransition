//
//  UINavigationController+lyFulPopGesture.m
//  LyFulPopGesture
//
//  Created by 张杰 on 2017/6/24.
//  Copyright © 2017年 张杰. All rights reserved.
//

#import "UINavigationController+lyFulPopGesture.h"
#import <objc/message.h>
#import "LyAnimationObjc.h"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface UINavigationController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@property(nonatomic,strong)UIImageView                 *screenshotImgView;//截图view
@property(nonatomic,strong)UIView                      *coverView;//遮罩view
@property(nonatomic,strong)NSMutableArray<UIImage *>   *screenshotImgs;//截图image


@property(nonatomic,strong)UIImage                     *nextVCScreenShotImg;
@property(nonatomic,strong)LyAnimationObjc             *animationObjc;
@end

@implementation UINavigationController (lyFulPopGesture)

+ (void)load
{
    [self exchangeMethod];
}

//交换方法
+ (void)exchangeMethod
{
    Method orgin_push = class_getInstanceMethod([UINavigationController class], @selector(pushViewController:animated:));
    Method exchange_push = class_getInstanceMethod([UINavigationController class], @selector(ly_pushViewController:animated:));
    method_exchangeImplementations(orgin_push, exchange_push);
    
    Method orgin_popView = class_getInstanceMethod([UINavigationController class], @selector(popToViewController:animated:));
    Method exchange_popView = class_getInstanceMethod([UINavigationController class], @selector(ly_popToViewController:animated:));
    method_exchangeImplementations(orgin_popView, exchange_popView);
    
    Method orgin_popRoot = class_getInstanceMethod([UINavigationController class], @selector(popToRootViewControllerAnimated:));
    Method exchange_popRoot = class_getInstanceMethod([UINavigationController class], @selector(ly_popToRootViewControllerAnimated:));
    method_exchangeImplementations(orgin_popRoot, exchange_popRoot);
    
    Method orgin_pop = class_getInstanceMethod([UINavigationController class], @selector(popViewControllerAnimated:));
    Method exchange_pop = class_getInstanceMethod([UINavigationController class], @selector(ly_popViewControllerAnimated:));
    method_exchangeImplementations(orgin_pop, exchange_pop); 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(-0.8, 0);
    self.view.layer.shadowOpacity = 0.6;
    
    //1.侧滑返回手势
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRec:)];
    self.panGesture.delegate = self;
    
    [self.view addGestureRecognizer:self.panGesture];
    //边缘侧滑
//    _panGestureRec = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRec:)];
//    _panGestureRec.edges = UIRectEdgeLeft;
//    // 为导航控制器的view添加Pan手势识别器
//    [self.view addGestureRecognizer:_panGestureRec];
    
    //2.创建截图的ImageView
    self.screenshotImgView = [[UIImageView alloc] init];
    // app的frame是包括了状态栏高度的frame
    self.screenshotImgView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    
    //3.创建截图上面的黑色半透明遮罩
    self.coverView = [[UIView alloc] init];
    self.coverView.frame = self.screenshotImgView.frame;
    self.coverView.backgroundColor = [UIColor blackColor];
    
    //4.数组
    self.screenshotImgs = [[NSMutableArray alloc] init];
    
    //5.动画
    self.animationObjc = [[LyAnimationObjc alloc] init];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC
{
    self.animationObjc.navigationOperation = operation;
    self.animationObjc.currentTabBarControl = self.ly_currentTabBarControl;
    self.animationObjc.navigationController = self;
    
    return self.animationObjc;
}

#pragma mark - 监听手势的方法,只要是有手势就会执行
- (void)panGestureRec:(UIPanGestureRecognizer *)panGestureRec
{
    if (self.visibleViewController == self.viewControllers[0]) return;
    
    /*
     1.self.view.window是将要显示的view
     2.self.view是要离开的view,手势做用的view
     */
    
    //2.判断手势各个阶段
    switch (panGestureRec.state) {
        case UIGestureRecognizerStateBegan://开始拖拽阶段
            //1.add遮罩,截图的view
            //2.设置截图view的image
            [self dragBegin];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
            /* 结束拖拽阶段
             1.判断拖拽的距离，看看是否pop
             2.还原的话
             动画中
             *手势做用的view的transform清空
             *截图view的transform改为-screenW
             *遮罩透明度还原
             动画结束
             *移除截图view，遮罩view
             3.pop
             动画中
             *手势做用的view的transform为screenW
             *截图view的transform为0
             *遮罩透明度0
             动画结束
             *手势做用的view的transform清空
             *截图view,遮罩view，remove
             *remove最后一张截图的image
             *执行pop,动画为no
             */
            [self dragEnd];
            break;
            
        default:
            /*正在拖拽阶段
             1.手势pan做用上的view，transform为手势移动的距离x
             2.需要判断移动的x是否 > 0
             3.截图view的transform为（-screenW + 手势移动的距离x）* 0.6
             4.遮罩view的透明度
             */
            [self dragging:panGestureRec];
            break;
    }
}

//开始拖动,添加图片和遮罩
- (void)dragBegin
{
    //注意:这里是self.view.window而不是self.view，因为self是导航栏
    [self.view.window insertSubview:self.screenshotImgView atIndex:0];
    [self.view.window insertSubview:self.coverView aboveSubview:self.screenshotImgView];
    
    self.screenshotImgView.image = self.screenshotImgs.lastObject;
}

// 默认的将要变透明的遮罩的初始透明度(全黑)
#define kDefaultAlpha 0.6
// 当拖动的距离,占了屏幕的总宽高的3/4时, 就让imageview完全显示，遮盖完全消失
#define kTargetTranslateScale 0.75
#pragma mark 正在拖动,动画效果的精髓,进行位移和透明度变化
- (void)dragging:(UIPanGestureRecognizer *)pan
{
    //1.手指移动的位移
    CGFloat offsetX = [pan translationInView:self.view].x;
    
    //2.让整个view跟着平移,UILayoutContainerView
    if (offsetX > 0) {
        self.view.transform = CGAffineTransformMakeTranslation(offsetX, 0);
    }
    
    //3.判断平移的大小
    //计算目前手指拖动位移占屏幕总的宽高的比例,当这个比例达到3/4时, 就让imageview完全显示，遮盖完全消失
    
    if (offsetX < ScreenWidth) {
        
        //注意:截图view,它开始位置是-ScreenWidth，手势往右,那么它也慢慢往右移动offsetX
        self.screenshotImgView.transform = CGAffineTransformMakeTranslation((offsetX - ScreenWidth) * 0.6, 0);
    }
    
    double currentTranslateScaleX = offsetX / self.view.frame.size.width;
    // 让遮盖透明度改变,直到减为0,让遮罩完全透明,默认的比例-(当前平衡比例/目标平衡比例)*默认的比例
    double alpha = kDefaultAlpha - (currentTranslateScaleX / kTargetTranslateScale) * kDefaultAlpha;
    self.coverView.alpha = alpha;
}

#pragma mark 结束拖动,判断结束时拖动的距离作相应的处理,并将图片和遮罩从父控件上移除
- (void)dragEnd
{
    // 取出挪动的距离
    CGFloat translateX = self.view.transform.tx;
    // 取出宽度
    CGFloat width = self.view.frame.size.width;
    
    //注意:这个是手势作用上面的view
    //self.view
    
    if (translateX <= 40)//回归最开始的状态
    {
        // 如果手指移动的距离还不到屏幕的一半,往左边挪 (弹回)
        [UIView animateWithDuration:0.3 animations:^{
            // 重要~~让被右移的view弹回归位,只要清空transform即可办到
            self.view.transform = CGAffineTransformIdentity;
            
            // 让imageView大小恢复默认的translation
            self.screenshotImgView.transform = CGAffineTransformMakeTranslation(-ScreenWidth, 0);
            
            // 让遮盖的透明度恢复默认的alpha 1.0
            self.coverView.alpha = kDefaultAlpha;
        } completion:^(BOOL finished) {
            // 重要,动画完成之后,每次都要记得 移除两个view,下次开始拖动时,再添加进来
            [self.screenshotImgView removeFromSuperview];
            [self.coverView removeFromSuperview];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            //1.移除手势做用的view
            self.view.transform = CGAffineTransformMakeTranslation(width, 0);
            //2.截图view由-ScreenWidth到0,就显示出来了
            self.screenshotImgView.transform = CGAffineTransformIdentity;
            //3.遮罩透明度
            self.coverView.alpha = 0;
            
        } completion:^(BOOL finished) {
            //1.重要~~让被右移的view完全挪到屏幕的最右边,结束之后,还要记得清空view的transform,不然下次再次开始drag时会出问题,因为view的transform没有归零
            self.view.transform = CGAffineTransformIdentity;
            //2.重要,动画完成之后,每次都要记得 移除两个view,下次开始拖动时,再添加进来
            [self.screenshotImgView removeFromSuperview];
            [self.coverView removeFromSuperview];
            
            //3.执行正常的Pop操作:移除栈顶控制器,让真正的前一个控制器成为导航控制器的栈顶控制器
            [self popViewControllerAnimated:NO];
            
            //4.重要~记得这时候,可以移除截图数组里面最后一张没用的截图了
            [self.animationObjc removeLastScreenShot];
        }];
    }
}

#pragma mark - 重写父类方法
- (void)ly_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 只有在导航控制器里面有子控制器的时候才需要截图
    if (self.viewControllers.count >= 1) {
        
        viewController.hidesBottomBarWhenPushed = YES;
        
        // 调用自定义方法,使用上下文截图
        [self screenShot];
    }
    
    [self ly_pushViewController:viewController animated:animated];
}

- (UIViewController *)ly_popViewControllerAnimated:(BOOL)animated
{
    NSInteger index = self.viewControllers.count;
    NSString * className = nil;
    if (index >= 2) {
        className = NSStringFromClass([self.viewControllers[index -2] class]);
    }
    
    if (self.screenshotImgs.count >= index - 1) {
        [self.screenshotImgs removeLastObject];
    }
    
    return [self ly_popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)ly_popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSInteger removeCount = 0;
    for (NSInteger i = self.viewControllers.count - 1; i > 0; i--) {
        if (viewController == self.viewControllers[i]) {
            break;
        }
        
        [self.screenshotImgs removeLastObject];
        removeCount ++;
        
    }
    self.animationObjc.removeCount = removeCount;
    
    return [self ly_popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)ly_popToRootViewControllerAnimated:(BOOL)animated
{
    [self.screenshotImgs removeAllObjects];
    [self.animationObjc removeAllScreenShot];
    
    return [self ly_popToRootViewControllerAnimated:animated];
}

#pragma mark - tool
//截图
- (void)screenShot
{
    //1.将要被截图的view,即是窗口根控制器(必须不含状态栏,默认ios7中控制器是包含了状态栏的)
//    UIViewController *rootViewController = self.view.window.rootViewController;
    UIViewController *rootViewController = self.topViewController;
    
    //2.开启上下文
    UIGraphicsBeginImageContextWithOptions(rootViewController.view.frame.size, NO, 0.0);
    
    //3.要裁剪的矩形范围
    CGRect rect = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    
    //4.判读是导航栏是否有上层的Tabbar  决定截图的对象
//    if (self.tabBarController == rootViewController)
    if (self.ly_currentTabBarControl)
    {
        //如果为tabBarController,必须将view的背景色设为clearColor不然会挡住截图的view
        rootViewController.tabBarController.view.backgroundColor = [UIColor clearColor];
        [rootViewController.tabBarController.view drawViewHierarchyInRect:rect afterScreenUpdates:NO];
//        [rootViewController.view drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    }
    else
    {
        [self.view drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    }
    
    //5.从上下文中,取出UIImage
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    
    //6.添加截取好的图片到图片数组
    if (snapshot) {
        [self.screenshotImgs addObject:snapshot];
    }
}

#pragma mark - set/get
static char ly_panGesture;
- (UIPanGestureRecognizer *)panGesture
{
    return objc_getAssociatedObject(self, &ly_panGesture);
}

- (void)setPanGesture:(UIPanGestureRecognizer *)panGesture
{
    if (panGesture != self.panGesture) {
        objc_setAssociatedObject(self, &ly_panGesture, panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

static char ly_screenshotImgView;
- (UIImageView *)screenshotImgView
{
    return objc_getAssociatedObject(self, &ly_screenshotImgView);
}

- (void)setScreenshotImgView:(UIImageView *)screenshotImgView
{
    if (screenshotImgView != self.screenshotImgView) {
        objc_setAssociatedObject(self, &ly_screenshotImgView, screenshotImgView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

static char ly_screenshotImgs;
- (NSMutableArray<UIImage *> *)screenshotImgs
{
    return objc_getAssociatedObject(self, &ly_screenshotImgs);
}

- (void)setScreenshotImgs:(NSMutableArray<UIImage *> *)screenshotImgs
{
    if (screenshotImgs != self.screenshotImgs) {
        objc_setAssociatedObject(self, &ly_screenshotImgs, screenshotImgs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

static char ly_coverView;
- (UIView *)coverView
{
    return objc_getAssociatedObject(self, &ly_coverView);
}

- (void)setCoverView:(UIView *)coverView
{
    if (coverView != self.coverView) {
        objc_setAssociatedObject(self, &ly_coverView, coverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

static char ly_animationObjc;
- (LyAnimationObjc *)animationObjc
{
    return objc_getAssociatedObject(self, &ly_animationObjc);
}

- (void)setAnimationObjc:(LyAnimationObjc *)animationObjc
{
    if (animationObjc != self.animationObjc) {
        objc_setAssociatedObject(self, &ly_animationObjc, animationObjc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

static char navCurrentTabBarControl;
- (BOOL)ly_currentTabBarControl
{
    NSInteger i = [objc_getAssociatedObject(self, &navCurrentTabBarControl) integerValue];
    return i == 0 ? NO : YES;
}

- (void)setLy_currentTabBarControl:(BOOL)ly_currentTabBarControl
{
    objc_setAssociatedObject(self, &navCurrentTabBarControl, @(ly_currentTabBarControl), OBJC_ASSOCIATION_ASSIGN);
}

@end

/*-------------------------------------------------------------------------------------------------------------------*/
#pragma mark - UIViewController
/*-------------------------------------------------------------------------------------------------------------------*/

@implementation UIViewController (lyFulPopGesture)

+ (void)load
{
    Method viewWillAppear = class_getInstanceMethod([UIViewController class], @selector(viewWillAppear:));
    Method ly_viewWillAppear = class_getInstanceMethod([UIViewController class], @selector(ly_viewWillAppear:));
    method_exchangeImplementations(viewWillAppear, ly_viewWillAppear);
    
    Method viewWillDisappear = class_getInstanceMethod([UIViewController class], @selector(viewWillDisappear:));
    Method ly_viewWillDisappear = class_getInstanceMethod([UIViewController class], @selector(ly_viewWillDisappear:));
    method_exchangeImplementations(viewWillDisappear, ly_viewWillDisappear);
}

- (void)ly_viewWillAppear:(BOOL)animated
{
    self.navigationController.panGesture.enabled = !self.ly_fulPopGestureHidden;
    self.navigationController.navigationBar.hidden = self.ly_navBarHidden;
    self.navigationController.ly_currentTabBarControl = self.ly_currentTabBarControl;
    
    [self ly_viewWillAppear:animated];
}

- (void)ly_viewWillDisappear:(BOOL)animated
{
    self.navigationController.panGesture.enabled = self.ly_fulPopGestureHidden;
    self.navigationController.navigationBar.hidden = !self.ly_navBarHidden;
    self.navigationController.ly_currentTabBarControl = !self.ly_currentTabBarControl;
    
    [self ly_viewWillDisappear:animated];
}

- (void)update:(UIColor *)color
{
    self.navigationController.navigationBar.barTintColor = color;
    
//    [self.navigationController.navigationBar setBackgroundImage:[self createImageWithColor:color] forBarMetrics:UIBarMetricsDefault];
}

- (UIImage *)createImageWithColor:(UIColor *) color;
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

static char fulPopGestureHidden;
- (BOOL)ly_fulPopGestureHidden
{
    NSInteger enable = [objc_getAssociatedObject(self, &fulPopGestureHidden) integerValue];
    return enable == 0 ? NO : YES;
}

- (void)setLy_fulPopGestureHidden:(BOOL)ly_fulPopGestureHidden
{
    objc_setAssociatedObject(self, &fulPopGestureHidden, @(ly_fulPopGestureHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static char navBarHidden;
- (BOOL)ly_navBarHidden
{
    NSInteger enable = [objc_getAssociatedObject(self, &navBarHidden) integerValue];
    return enable == 0 ? NO : YES;
}

- (void)setLy_navBarHidden:(BOOL)ly_navBarHidden
{
    objc_setAssociatedObject(self, &navBarHidden, @(ly_navBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static char currentTabBarControl;
- (BOOL)ly_currentTabBarControl
{
    NSInteger i = [objc_getAssociatedObject(self, &currentTabBarControl) integerValue];
    return i == 0 ? NO : YES;
}

- (void)setLy_currentTabBarControl:(BOOL)ly_currentTabBarControl
{
    objc_setAssociatedObject(self, &currentTabBarControl, @(ly_currentTabBarControl), OBJC_ASSOCIATION_ASSIGN);
}

@end



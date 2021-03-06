//
// REFrostedViewController.m
// RESideMenu
//
// Copyright (c) 2013-2014 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "RESideMenu.h"
#import "UIViewController+RESideMenu.h"
#import "RECommonFunctions.h"

typedef NS_ENUM(NSUInteger, RESideMenuActiveSide)
{
    RESideMenuActiveSideLeft,
    RESideMenuActiveSideRight,
};

@interface RESideMenu ()

@property (strong, readwrite, nonatomic) UIImageView *backgroundImageView;
@property (assign, readwrite, nonatomic) BOOL visible;
@property (assign, readwrite, nonatomic) BOOL leftMenuVisible;
@property (assign, readwrite, nonatomic) BOOL rightMenuVisible;
@property (assign, readwrite, nonatomic) CGPoint originalPoint;
@property (strong, readwrite, nonatomic) UIButton *contentButton;
@property (strong, readwrite, nonatomic) UIView *menuViewContainer;
@property (strong, readwrite, nonatomic) UIView *contentViewContainer;
@property (assign, readwrite, nonatomic) BOOL didNotifyDelegate;

@property (assign, readwrite, nonatomic) RESideMenuActiveSide activeSide;

@property (assign, readonly, nonatomic) CGFloat contentViewWidth;
@property (assign, readonly, nonatomic) CGFloat contentViewHeight;
@property (assign, readonly, nonatomic) CGFloat contentViewOffsetCenterX;
@property (assign, readonly, nonatomic) CGFloat contentViewOffsetCenterY;

@property (assign, readonly, nonatomic) CGFloat contentViewScaleValue;

@property (assign, readonly, nonatomic) CGFloat contentViewInPortraitScale;
@property (assign, readonly, nonatomic) CGFloat contentViewInPortraitOffsetCenterX;
@property (assign, readonly, nonatomic) CGFloat contentViewInPortraitOffsetCenterY;
@property (assign, readonly, nonatomic) CGFloat contentViewInLandscapeScaleValue;
@property (assign, readonly, nonatomic) CGFloat contentViewInLandscapeOffsetCenterX;
@property (assign, readonly, nonatomic) CGFloat contentViewInLandscapeOffsetCenterY;

@property (assign, readonly, nonatomic) CGFloat leftMenuPortraitContentViewScale;
@property (assign, readonly, nonatomic) CGFloat leftMenuPortraitContentViewOffsetCenterX;
@property (assign, readonly, nonatomic) CGFloat leftMenuPortraitContentViewOffsetCenterY;
@property (assign, readonly, nonatomic) CGFloat rightMenuPortraitContentViewScale;
@property (assign, readonly, nonatomic) CGFloat rightMenuPortraitContentViewOffsetCenterX;
@property (assign, readonly, nonatomic) CGFloat rightMenuPortraitContentViewOffsetCenterY;
@property (assign, readonly, nonatomic) CGFloat leftMenuLandscapeContentViewScale;
@property (assign, readonly, nonatomic) CGFloat leftMenuLandscapeContentViewOffsetCenterX;
@property (assign, readonly, nonatomic) CGFloat leftMenuLandscapeContentViewOffsetCenterY;
@property (assign, readonly, nonatomic) CGFloat rightMenuLandscapeContentViewScale;
@property (assign, readonly, nonatomic) CGFloat rightMenuLandscapeContentViewOffsetCenterX;
@property (assign, readonly, nonatomic) CGFloat rightMenuLandscapeContentViewOffsetCenterY;

@end

@implementation RESideMenu

#pragma mark -
#pragma mark Instance lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

#if __IPHONE_8_0
- (void)awakeFromNib
{
    if (self.contentViewStoryboardID) {
        self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.contentViewStoryboardID];
    }
    if (self.leftMenuViewStoryboardID) {
        self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.leftMenuViewStoryboardID];
    }
    if (self.rightMenuViewStoryboardID) {
        self.rightMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.rightMenuViewStoryboardID];
    }
}
#endif

- (void)commonInit
{
    _menuViewContainer = [[UIView alloc] init];
    _contentViewContainer = [[UIView alloc] init];
    
    _animationDuration = 0.35f;
    _interactivePopGestureRecognizerEnabled = YES;
  
    _menuViewControllerTransformation = CGAffineTransformMakeScale(1.5f, 1.5f);
    
    _scaleContentView = YES;
    _scaleBackgroundImageView = YES;
    _scaleMenuView = YES;
    _fadeMenuView = YES;
    
    _parallaxEnabled = YES;
    _parallaxMenuMinimumRelativeValue = -15;
    _parallaxMenuMaximumRelativeValue = 15;
    _parallaxContentMinimumRelativeValue = -25;
    _parallaxContentMaximumRelativeValue = 25;
    
    _bouncesHorizontally = YES;
    
    _panGestureEnabled = YES;
    _panFromEdge = YES;
    _panMinimumOpenThreshold = 60.0;
    
    _contentViewShadowEnabled = NO;
    _contentViewShadowColor = [UIColor blackColor];
    _contentViewShadowOffset = CGSizeZero;
    _contentViewShadowOpacity = 0.4f;
    _contentViewShadowRadius = 8.0f;
    _contentViewFadeOutAlpha = 1.0f;

//    self.contentViewInLandscapeOffsetCenterX = 30.f;
//    self.contentViewInPortraitOffsetCenterX  = 30.f;
//    self.contentViewScaleValue = 0.7f;
    
    _leftMenuPortraitContentViewDistanceTop = 50;
    _leftMenuPortraitContentViewDistanceBottom = 50;
    _leftMenuPortraitContentViewDistanceSide = 50;
    _rightMenuPortraitContentViewDistanceTop = 50;
    _rightMenuPortraitContentViewDistanceBottom = 50;
    _rightMenuPortraitContentViewDistanceSide = 50;
    _leftMenuLandscapeContentViewDistanceTop = 50;
    _leftMenuLandscapeContentViewDistanceBottom = 50;
    _leftMenuLandscapeContentViewDistanceSide = 50;
    _rightMenuLandscapeContentViewDistanceTop = 50;
    _rightMenuLandscapeContentViewDistanceBottom = 50;
    _rightMenuLandscapeContentViewDistanceSide = 50;
}

#pragma mark -
#pragma mark Public methods

- (id)initWithContentViewController:(UIViewController *)contentViewController leftMenuViewController:(UIViewController *)leftMenuViewController rightMenuViewController:(UIViewController *)rightMenuViewController
{
    self = [self init];
    if (self) {
        _contentViewController = contentViewController;
        _leftMenuViewController = leftMenuViewController;
        _rightMenuViewController = rightMenuViewController;
    }
    return self;
}

- (void)presentLeftMenuViewController
{
    [self presentMenuViewContainerWithMenuViewController:self.leftMenuViewController];
    [self showLeftMenuViewController];
}

- (void)presentRightMenuViewController
{
    [self presentMenuViewContainerWithMenuViewController:self.rightMenuViewController];
    [self showRightMenuViewController];
}

- (void)hideMenuViewController
{
    [self hideMenuViewControllerAnimated:YES];
}

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated
{
    if (_contentViewController == contentViewController)
    {
        return;
    }
    
    if (!animated) {
        [self setContentViewController:contentViewController];
    } else {
        [self addChildViewController:contentViewController];
        contentViewController.view.alpha = 0;
        contentViewController.view.frame = self.contentViewContainer.bounds;
        [self.contentViewContainer addSubview:contentViewController.view];
        [UIView animateWithDuration:self.animationDuration animations:^{
            contentViewController.view.alpha = 1;
        } completion:^(BOOL finished) {
            [self hideViewController:self.contentViewController];
            [contentViewController didMoveToParentViewController:self];
            _contentViewController = contentViewController;

            [self statusBarNeedsAppearanceUpdate];
            [self updateContentViewShadow];
            
            if (self.visible) {
                [self addContentViewControllerMotionEffects];
            }
        }];
    }
}

#pragma mark View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.image = self.backgroundImage;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView;
    });
    self.contentButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectNull];
        [button addTarget:self action:@selector(hideMenuViewController) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.menuViewContainer];
    [self.view addSubview:self.contentViewContainer];
    
    self.menuViewContainer.frame = self.view.bounds;
    self.menuViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.leftMenuViewController) {
        [self addChildViewController:self.leftMenuViewController];
        self.leftMenuViewController.view.frame = self.view.bounds;
        self.leftMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.menuViewContainer addSubview:self.leftMenuViewController.view];
        [self.leftMenuViewController didMoveToParentViewController:self];
    }
    
    if (self.rightMenuViewController) {
        [self addChildViewController:self.rightMenuViewController];
        self.rightMenuViewController.view.frame = self.view.bounds;
        self.rightMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.menuViewContainer addSubview:self.rightMenuViewController.view];
        [self.rightMenuViewController didMoveToParentViewController:self];
    }
    
    self.contentViewContainer.frame = self.view.bounds;
    self.contentViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    self.menuViewContainer.alpha = !self.fadeMenuView ?: 0;
    if (self.scaleBackgroundImageView)
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    
    [self addMenuViewControllerMotionEffects];
    
    if (self.panGestureEnabled) {
        self.view.multipleTouchEnabled = NO;
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        panGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:panGestureRecognizer];
    }
    
    [self updateContentViewShadow];
}

#pragma mark -
#pragma mark Private methods

- (void)presentMenuViewContainerWithMenuViewController:(UIViewController *)menuViewController
{
    self.menuViewContainer.transform = CGAffineTransformIdentity;
    if (self.scaleBackgroundImageView) {
        self.backgroundImageView.transform = CGAffineTransformIdentity;
        self.backgroundImageView.frame = self.view.bounds;
    }
    self.menuViewContainer.frame = self.view.bounds;
    if (self.scaleMenuView) {
        self.menuViewContainer.transform = self.menuViewControllerTransformation;
    }
    self.menuViewContainer.alpha = !self.fadeMenuView ?: 0;
    if (self.scaleBackgroundImageView)
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    
    if ([self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
        [self.delegate sideMenu:self willShowMenuViewController:menuViewController];
    }
}

- (void)showLeftMenuViewController
{
    if (!self.leftMenuViewController) {
        return;
    }
    
    self.activeSide = RESideMenuActiveSideLeft;
    
    [self.leftMenuViewController beginAppearanceTransition:YES animated:YES];
    self.leftMenuViewController.view.hidden = NO;
    self.rightMenuViewController.view.hidden = YES;
    [self.view.window endEditing:YES];
    [self addContentButton];
    [self updateContentViewShadow];
    [self resetContentViewScale];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (self.scaleContentView) {
            self.contentViewContainer.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        } else {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
        }

        self.contentViewContainer.center = CGPointMake(self.contentViewOffsetCenterX + self.contentViewWidth,
                                                       self.contentViewOffsetCenterY + self.contentViewHeight / 2);
        self.menuViewContainer.alpha = !self.fadeMenuView ?: 1.0f;
        self.contentViewContainer.alpha = self.contentViewFadeOutAlpha;
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        if (self.scaleBackgroundImageView)
            self.backgroundImageView.transform = CGAffineTransformIdentity;
            
    } completion:^(BOOL finished) {
        [self addContentViewControllerMotionEffects];
        [self.leftMenuViewController endAppearanceTransition];
        
        if (!self.visible && [self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didShowMenuViewController:)]) {
            [self.delegate sideMenu:self didShowMenuViewController:self.leftMenuViewController];
        }
        
        self.visible = YES;
        self.leftMenuVisible = YES;
    }];
    
    [self statusBarNeedsAppearanceUpdate];
}

- (void)showRightMenuViewController
{
    if (!self.rightMenuViewController) {
        return;
    }

    self.activeSide = RESideMenuActiveSideRight;

    [self.rightMenuViewController beginAppearanceTransition:YES animated:YES];
    self.leftMenuViewController.view.hidden = YES;
    self.rightMenuViewController.view.hidden = NO;
    [self.view.window endEditing:YES];
    [self addContentButton];
    [self updateContentViewShadow];
    [self resetContentViewScale];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (self.scaleContentView) {
            self.contentViewContainer.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        } else {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
        }
        self.contentViewContainer.center = CGPointMake(-self.contentViewOffsetCenterX,
                                                       self.contentViewOffsetCenterY + self.contentViewHeight / 2);
        
        self.menuViewContainer.alpha = !self.fadeMenuView ?: 1.0f;
        self.contentViewContainer.alpha = self.contentViewFadeOutAlpha;
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        if (self.scaleBackgroundImageView)
            self.backgroundImageView.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        [self.rightMenuViewController endAppearanceTransition];
        if (!self.rightMenuVisible && [self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didShowMenuViewController:)]) {
            [self.delegate sideMenu:self didShowMenuViewController:self.rightMenuViewController];
        }
        
        self.visible = !(YES
            && self.contentViewContainer.frame.size.width == self.view.bounds.size.width
            && self.contentViewContainer.frame.size.height == self.view.bounds.size.height
            && CGRectGetMidX(self.contentViewContainer.frame) == CGRectGetMidX(self.view.bounds)
            && CGRectGetMidY(self.contentViewContainer.frame) == CGRectGetMidY(self.view.bounds)
        );
        self.rightMenuVisible = self.visible;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [self addContentViewControllerMotionEffects];
    }];
    
    [self statusBarNeedsAppearanceUpdate];
}

- (void)hideViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)hideMenuViewControllerAnimated:(BOOL)animated
{
    BOOL rightMenuVisible = self.rightMenuVisible;
    UIViewController *visibleMenuViewController = rightMenuVisible ? self.rightMenuViewController : self.leftMenuViewController;
    [visibleMenuViewController beginAppearanceTransition:NO animated:animated];
    if ([self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willHideMenuViewController:)]) {
        [self.delegate sideMenu:self willHideMenuViewController:rightMenuVisible ? self.rightMenuViewController : self.leftMenuViewController];
    }
    
    self.visible = NO;
    self.leftMenuVisible = NO;
    self.rightMenuVisible = NO;
    [self.contentButton removeFromSuperview];
    
    __typeof (self) __weak weakSelf = self;
    void (^animationBlock)(void) = ^{
        __typeof (weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.contentViewContainer.transform = CGAffineTransformIdentity;
        strongSelf.contentViewContainer.frame = strongSelf.view.bounds;
        if (strongSelf.scaleMenuView) {
            strongSelf.menuViewContainer.transform = strongSelf.menuViewControllerTransformation;
        }
        strongSelf.menuViewContainer.alpha = !self.fadeMenuView ?: 0;
        strongSelf.contentViewContainer.alpha = 1;

        if (strongSelf.scaleBackgroundImageView) {
            strongSelf.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
        }
        if (strongSelf.parallaxEnabled) {
            IF_IOS7_OR_GREATER(
               for (UIMotionEffect *effect in strongSelf.contentViewContainer.motionEffects) {
                   [strongSelf.contentViewContainer removeMotionEffect:effect];
               }
            );
        }
    };
    void (^completionBlock)(void) = ^{
        __typeof (weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [visibleMenuViewController endAppearanceTransition];
        if (!strongSelf.visible && [strongSelf.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [strongSelf.delegate respondsToSelector:@selector(sideMenu:didHideMenuViewController:)]) {
            [strongSelf.delegate sideMenu:strongSelf didHideMenuViewController:rightMenuVisible ? strongSelf.rightMenuViewController : strongSelf.leftMenuViewController];
        }
    };
    
    if (animated) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:self.animationDuration animations:^{
            animationBlock();
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            completionBlock();
        }];
    } else {
        animationBlock();
        completionBlock();
    }
    [self statusBarNeedsAppearanceUpdate];
}

- (void)addContentButton
{
    if (self.contentButton.superview)
        return;

    self.contentButton.autoresizingMask = UIViewAutoresizingNone;
    self.contentButton.frame = self.contentViewContainer.bounds;
    self.contentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentViewContainer addSubview:self.contentButton];
}

- (void)statusBarNeedsAppearanceUpdate
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [UIView animateWithDuration:0.3f animations:^{
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }];
    }
}

- (void)updateContentViewShadow
{
    if (self.contentViewShadowEnabled) {
        CALayer *layer = self.contentViewContainer.layer;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:layer.bounds];
        layer.shadowPath = path.CGPath;
        layer.shadowColor = self.contentViewShadowColor.CGColor;
        layer.shadowOffset = self.contentViewShadowOffset;
        layer.shadowOpacity = self.contentViewShadowOpacity;
        layer.shadowRadius = self.contentViewShadowRadius;
    }
}

- (void)resetContentViewScale
{
    CGAffineTransform t = self.contentViewContainer.transform;
    CGFloat scale = sqrt(t.a * t.a + t.c * t.c);
    CGRect frame = self.contentViewContainer.frame;
    self.contentViewContainer.transform = CGAffineTransformIdentity;
    self.contentViewContainer.transform = CGAffineTransformMakeScale(scale, scale);
    self.contentViewContainer.frame = frame;
}

#pragma mark -
#pragma mark iOS 7 Motion Effects (Private)

- (void)addMenuViewControllerMotionEffects
{
    if (self.parallaxEnabled) {
        IF_IOS7_OR_GREATER(
           for (UIMotionEffect *effect in self.menuViewContainer.motionEffects) {
               [self.menuViewContainer removeMotionEffect:effect];
           }
           UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
           interpolationHorizontal.minimumRelativeValue = @(self.parallaxMenuMinimumRelativeValue);
           interpolationHorizontal.maximumRelativeValue = @(self.parallaxMenuMaximumRelativeValue);
           
           UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
           interpolationVertical.minimumRelativeValue = @(self.parallaxMenuMinimumRelativeValue);
           interpolationVertical.maximumRelativeValue = @(self.parallaxMenuMaximumRelativeValue);
           
           [self.menuViewContainer addMotionEffect:interpolationHorizontal];
           [self.menuViewContainer addMotionEffect:interpolationVertical];
        );
    }
}

- (void)addContentViewControllerMotionEffects
{
    if (self.parallaxEnabled) {
        IF_IOS7_OR_GREATER(
            for (UIMotionEffect *effect in self.contentViewContainer.motionEffects) {
               [self.contentViewContainer removeMotionEffect:effect];
            }
            [UIView animateWithDuration:0.2 animations:^{
                UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
                interpolationHorizontal.minimumRelativeValue = @(self.parallaxContentMinimumRelativeValue);
                interpolationHorizontal.maximumRelativeValue = @(self.parallaxContentMaximumRelativeValue);

                UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
                interpolationVertical.minimumRelativeValue = @(self.parallaxContentMinimumRelativeValue);
                interpolationVertical.maximumRelativeValue = @(self.parallaxContentMaximumRelativeValue);

                [self.contentViewContainer addMotionEffect:interpolationHorizontal];
                [self.contentViewContainer addMotionEffect:interpolationVertical];
            }];
        );
    }
}

#pragma mark -
#pragma mark UIGestureRecognizer Delegate (Private)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    IF_IOS7_OR_GREATER(
       if (self.interactivePopGestureRecognizerEnabled && [self.contentViewController isKindOfClass:[UINavigationController class]]) {
           UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
           if (navigationController.viewControllers.count > 1 && navigationController.interactivePopGestureRecognizer.enabled) {
               return NO;
           }
       }
    );
  
    if (self.panFromEdge && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && !self.visible) {
        CGPoint point = [touch locationInView:gestureRecognizer.view];
        if (point.x < 20.0 || point.x > self.view.frame.size.width - 20.0) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -
#pragma mark Pan gesture recognizer (Private)

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if ([self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didRecognizePanGesture:)])
        [self.delegate sideMenu:self didRecognizePanGesture:recognizer];
    
    if (!self.panGestureEnabled) {
        return;
    }
    
    CGPoint point = [recognizer translationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self updateContentViewShadow];
        
        self.originalPoint = CGPointMake(self.contentViewContainer.center.x - CGRectGetMidX(self.contentViewContainer.bounds),
                                         self.contentViewContainer.center.y - CGRectGetMidY(self.contentViewContainer.bounds));
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformIdentity;
            self.backgroundImageView.frame = self.view.bounds;
        }
        self.menuViewContainer.frame = self.view.bounds;
        [self addContentButton];
        [self.view.window endEditing:YES];
        self.didNotifyDelegate = NO;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (!self.bouncesHorizontally && self.visible) {
            if (self.contentViewContainer.frame.origin.x > self.contentViewContainer.frame.size.width / 2.0) {
                point.x = MIN(0.0, point.x);
            }
            if (self.contentViewContainer.frame.origin.x < -(self.contentViewContainer.frame.size.width / 2.0)) {
                point.x = MAX(0.0, point.x);
            }
        }

        // Limit size
        if (point.x < 0) {
            point.x = MAX(point.x, -[UIScreen mainScreen].bounds.size.height);
        } else {
            point.x = MIN(point.x, [UIScreen mainScreen].bounds.size.height);
        }
        [recognizer setTranslation:point inView:self.view];
        
        if (!self.didNotifyDelegate) {
            if (point.x > 0) {
                if (!self.visible && [self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
                    self.activeSide = RESideMenuActiveSideLeft;
                    [self.delegate sideMenu:self willShowMenuViewController:self.leftMenuViewController];
                }
            }
            if (point.x < 0) {
                if (!self.visible && [self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
                    self.activeSide = RESideMenuActiveSideRight;
                    [self.delegate sideMenu:self willShowMenuViewController:self.rightMenuViewController];
                }
            }
            self.didNotifyDelegate = YES;
        }

        CGPoint center;
        CGFloat offset;
        if (self.activeSide == RESideMenuActiveSideLeft) {
            center = CGPointMake(self.contentViewOffsetCenterX + self.contentViewWidth,
                                 self.contentViewOffsetCenterY + self.contentViewHeight / 2);
            offset = point.x;
        } else {
            center = CGPointMake(-self.contentViewOffsetCenterX,
                                 self.contentViewOffsetCenterY + self.contentViewHeight / 2);
            offset = -point.x;
        }

        if (self.visible) {
            offset = fabs(center.x - CGRectGetMidX(self.view.bounds)) - point.x;
        } else {
            offset = point.x;
        }

        CGFloat delta = offset / fabs(center.x - CGRectGetMidX(self.view.bounds));

        delta = MIN(fabs(delta), 1.6);

//        CGFloat self.contentViewScale;
//        CGFloat self.contentViewOffsetCenterX;
//        CGFloat self.contentViewOffsetCenterX;
        
        CGFloat contentViewScale = self.scaleContentView ? 1 - ((1 - self.contentViewScaleValue) * delta) : 1;
        CGFloat backgroundViewScale = 1.7f - (0.7f * delta);
        CGFloat menuViewScale = 1.5f - (0.5f * delta);

        if (!self.bouncesHorizontally) {
            contentViewScale = MAX(contentViewScale, self.contentViewScaleValue);
            backgroundViewScale = MAX(backgroundViewScale, 1.0);
            menuViewScale = MAX(menuViewScale, 1.0);
        }
        
        self.menuViewContainer.alpha = !self.fadeMenuView ?: delta;
        self.contentViewContainer.alpha = 1 - (1 - self.contentViewFadeOutAlpha) * delta;
        
        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformMakeScale(backgroundViewScale, backgroundViewScale);
        }
        
        if (self.scaleMenuView) {
            self.menuViewContainer.transform = CGAffineTransformMakeScale(menuViewScale, menuViewScale);
        }
        
        if (self.scaleBackgroundImageView) {
            if (backgroundViewScale < 1) {
                self.backgroundImageView.transform = CGAffineTransformIdentity;
            }
        }

        if (contentViewScale > 1)
        {
            contentViewScale = (1 - (contentViewScale - 1));
        }

        CGFloat contentViewOffsetCenterY = self.visible
            ? (-(1 - MIN(1, delta)) * self.contentViewOffsetCenterY)
            : (MIN(1, delta) * self.contentViewOffsetCenterY);

        self.contentViewContainer.transform = CGAffineTransformMakeTranslation(0, 0);
        self.contentViewContainer.transform = CGAffineTransformTranslate(self.contentViewContainer.transform, point.x, contentViewOffsetCenterY);
        self.contentViewContainer.transform = CGAffineTransformScale(self.contentViewContainer.transform, contentViewScale, contentViewScale);
        
        self.leftMenuViewController.view.hidden = CGRectGetMidX(self.contentViewContainer.frame) < CGRectGetMidX(self.view.bounds);
        self.rightMenuViewController.view.hidden = CGRectGetMidX(self.contentViewContainer.frame) > CGRectGetMidX(self.view.bounds);
        
        if (!self.leftMenuViewController && CGRectGetMidX(self.contentViewContainer.frame) > CGRectGetMidX(self.view.bounds)) {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
            self.contentViewContainer.frame = self.view.bounds;
            self.visible = NO;
            self.leftMenuVisible = NO;
        } else  if (!self.rightMenuViewController && CGRectGetMidX(self.contentViewContainer.frame) < CGRectGetMidX(self.view.bounds)) {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
            self.contentViewContainer.frame = self.view.bounds;
            self.visible = NO;
            self.rightMenuVisible = NO;
        }
        
        [self statusBarNeedsAppearanceUpdate];
    }
    
   if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.didNotifyDelegate = NO;
        if (self.panMinimumOpenThreshold > 0 && (
            (CGRectGetMidX(self.contentViewContainer.frame) < CGRectGetMidX(self.view.bounds) && CGRectGetMidX(self.contentViewContainer.frame) > CGRectGetMidX(self.view.bounds) - self.panMinimumOpenThreshold) ||
            (CGRectGetMidX(self.contentViewContainer.frame) > CGRectGetMidX(self.view.bounds) && CGRectGetMidX(self.contentViewContainer.frame) < CGRectGetMidX(self.view.bounds) + self.panMinimumOpenThreshold))
        ) {
            [self hideMenuViewController];
        }
        else if (CGRectGetMidX(self.contentViewContainer.frame) == CGRectGetMidX(self.view.bounds)) {
            [self hideMenuViewControllerAnimated:NO];
        }
        else {
            if ([recognizer velocityInView:self.view].x > 0) {
                if (CGRectGetMidX(self.contentViewContainer.frame) < CGRectGetMidX(self.view.bounds)) {
                    [self hideMenuViewController];
                } else {
                    if (self.leftMenuViewController) {
                        [self showLeftMenuViewController];
                    }
                }
            } else {
                if (CGRectGetMidX(self.contentViewContainer.frame) < CGRectGetMidX(self.view.bounds) + 20) {
                    if (self.rightMenuViewController) {
                        [self showRightMenuViewController];
                    }
                } else {
                    [self hideMenuViewController];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark Setters

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    if (self.backgroundImageView)
        self.backgroundImageView.image = backgroundImage;
}

- (void)setContentViewController:(UIViewController *)contentViewController
{
    if (!_contentViewController) {
        _contentViewController = contentViewController;
        return;
    }
    [self hideViewController:_contentViewController];
    _contentViewController = contentViewController;
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    [self updateContentViewShadow];
    
    if (self.visible) {
        [self addContentViewControllerMotionEffects];
    }
}

- (void)setLeftMenuViewController:(UIViewController *)leftMenuViewController
{
    if (!_leftMenuViewController) {
        _leftMenuViewController = leftMenuViewController;
        return;
    }
    [self hideViewController:_leftMenuViewController];
    _leftMenuViewController = leftMenuViewController;
   
    [self addChildViewController:self.leftMenuViewController];
    self.leftMenuViewController.view.frame = self.view.bounds;
    self.leftMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuViewContainer addSubview:self.leftMenuViewController.view];
    [self.leftMenuViewController didMoveToParentViewController:self];
    
    [self addMenuViewControllerMotionEffects];
    [self.view bringSubviewToFront:self.contentViewContainer];
}

- (void)setRightMenuViewController:(UIViewController *)rightMenuViewController
{
    if (!_rightMenuViewController) {
        _rightMenuViewController = rightMenuViewController;
        return;
    }
    [self hideViewController:_rightMenuViewController];
    _rightMenuViewController = rightMenuViewController;
    
    [self addChildViewController:self.rightMenuViewController];
    self.rightMenuViewController.view.frame = self.view.bounds;
    self.rightMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuViewContainer addSubview:self.rightMenuViewController.view];
    [self.rightMenuViewController didMoveToParentViewController:self];
    
    [self addMenuViewControllerMotionEffects];
    [self.view bringSubviewToFront:self.contentViewContainer];
}

#pragma mark -
#pragma mark View Controller Rotation handler

- (BOOL)shouldAutorotate
{
    return self.contentViewController.shouldAutorotate;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.visible) {
        self.menuViewContainer.bounds = self.view.bounds;
        self.contentViewContainer.transform = CGAffineTransformIdentity;
        self.contentViewContainer.frame = self.view.bounds;
        
        if (self.scaleContentView) {
            self.contentViewContainer.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        } else {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
        }
        
        CGPoint center;
        if (self.leftMenuVisible) {
            center = CGPointMake(self.contentViewOffsetCenterX + self.contentViewWidth,
                                 self.contentViewOffsetCenterY + self.contentViewHeight / 2);
        } else {
            center = CGPointMake(-self.contentViewOffsetCenterX,
                                 self.contentViewOffsetCenterY + self.contentViewHeight / 2);
        }
        
        self.contentViewContainer.center = center;
    }
    
    [self updateContentViewShadow];
}

#pragma mark -
#pragma mark Status Bar Appearance Management

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIStatusBarStyle statusBarStyle = UIStatusBarStyleDefault;
    IF_IOS7_OR_GREATER(
       statusBarStyle = self.visible ? self.menuPreferredStatusBarStyle : self.contentViewController.preferredStatusBarStyle;
       if (self.contentViewContainer.frame.origin.y > 10) {
           statusBarStyle = self.menuPreferredStatusBarStyle;
       } else {
           statusBarStyle = self.contentViewController.preferredStatusBarStyle;
       }
    );
    return statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    BOOL statusBarHidden = NO;
    IF_IOS7_OR_GREATER(
        statusBarHidden = self.visible ? self.menuPrefersStatusBarHidden : self.contentViewController.prefersStatusBarHidden;
        if (self.contentViewContainer.frame.origin.y > 10) {
            statusBarHidden = self.menuPrefersStatusBarHidden;
        } else {
            statusBarHidden = self.contentViewController.prefersStatusBarHidden;
        }
    );
    return statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    UIStatusBarAnimation statusBarAnimation = UIStatusBarAnimationNone;
    IF_IOS7_OR_GREATER(
        statusBarAnimation = self.visible ? self.leftMenuViewController.preferredStatusBarUpdateAnimation : self.contentViewController.preferredStatusBarUpdateAnimation;
        if (self.contentViewContainer.frame.origin.y > 10) {
            statusBarAnimation = self.leftMenuViewController.preferredStatusBarUpdateAnimation;
        } else {
            statusBarAnimation = self.contentViewController.preferredStatusBarUpdateAnimation;
        }
    );
    return statusBarAnimation;
}

#pragma mark -
#pragma mark Offset calculations

- (CGFloat)contentViewWidth
{
    return (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) || UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])
        ? CGRectGetWidth(self.view.frame)
        : CGRectGetHeight(self.view.frame);
}

- (CGFloat)contentViewHeight
{
    return (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) || UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])
        ? CGRectGetHeight(self.view.frame)
        : CGRectGetWidth(self.view.frame);
}

- (CGFloat)contentViewScaleValue
{
    return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])
        ? self.contentViewInLandscapeScale
        : self.contentViewInPortraitScale;
}

- (CGFloat)contentViewOffsetCenterX
{
    return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])
        ? self.contentViewInLandscapeOffsetCenterX
        : self.contentViewInPortraitOffsetCenterX;
}

- (CGFloat)contentViewOffsetCenterY
{
    return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])
        ? self.contentViewInLandscapeOffsetCenterY
        : self.contentViewInPortraitOffsetCenterY;
}

#pragma mark -
#pragma mark Legacy offset handling

#define RESideMenu_Define_Offsets(orientation__, property__) \
    - (CGFloat)contentViewIn ## orientation__ ## property__ \
    { \
        return _activeSide == RESideMenuActiveSideLeft \
            ? self.leftMenu ## orientation__ ## ContentView ## property__ \
            : self.rightMenu ## orientation__ ## ContentView ## property__; \
    }

RESideMenu_Define_Offsets(Portrait, Scale)
RESideMenu_Define_Offsets(Portrait, OffsetCenterX)
RESideMenu_Define_Offsets(Portrait, OffsetCenterY)
RESideMenu_Define_Offsets(Landscape, Scale)
RESideMenu_Define_Offsets(Landscape, OffsetCenterX)
RESideMenu_Define_Offsets(Landscape, OffsetCenterY)

#undef RESideMenu_Define_Offsets

#pragma mark - New offset calculations

#define RESideMenu_Define_Offsets(mode__) \
    - (CGFloat)mode__ ## ContentViewScale \
    { \
        return 1.0f - (self.mode__ ## ContentViewDistanceTop + self.mode__ ## ContentViewDistanceBottom) / self.contentViewHeight; \
    } \
    - (CGFloat)mode__ ## ContentViewOffsetCenterX \
    { \
        return self.contentViewWidth * self.mode__ ## ContentViewScale / 2 - self.mode__ ## ContentViewDistanceSide; \
    } \
    - (CGFloat)mode__ ## ContentViewOffsetCenterY \
    { \
        return (self.mode__ ## ContentViewDistanceTop - self.mode__ ## ContentViewDistanceBottom) / 2; \
    }

RESideMenu_Define_Offsets(leftMenuPortrait)
RESideMenu_Define_Offsets(leftMenuLandscape)
RESideMenu_Define_Offsets(rightMenuPortrait)
RESideMenu_Define_Offsets(rightMenuLandscape)

#undef RESideMenu_Define_Offsets

@end

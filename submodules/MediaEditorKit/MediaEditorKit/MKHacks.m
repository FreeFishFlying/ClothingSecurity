#import "MKHacks.h"
#import "LegacyComponentsInternal.h"
#import "TGAnimationBlockDelegate.h"
#import "FreedomUIKit.h"
#import <objc/runtime.h>

static float animationDurationFactor = 1.0f;
static float secondaryAnimationDurationFactor = 1.0f;
static bool forceSystemCurve = false;


static bool forcePerformWithAnimationFlag = false;


@interface UIView (TGHacks)

+ (void)telegraph_setAnimationDuration:(NSTimeInterval)duration;

@end

@implementation UIView (TGHacks)

+ (void)telegraph_setAnimationDuration:(NSTimeInterval)duration
{
    [self telegraph_setAnimationDuration:(duration * animationDurationFactor)];
}

+ (void)telegraph_animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    if (forceSystemCurve) {
        options |= (7 << 16);
    }
    [self telegraph_animateWithDuration:duration * secondaryAnimationDurationFactor delay:delay options:options animations:animations completion:completion];
}

+ (void)TG_performWithoutAnimation_maybeNot:(void (^)(void))actionsWithoutAnimation
{
    if (actionsWithoutAnimation)
    {
        if (forcePerformWithAnimationFlag)
            actionsWithoutAnimation();
        else
            [self TG_performWithoutAnimation_maybeNot:actionsWithoutAnimation];
    }
}

@end

#pragma mark -

@implementation MKHacks

static UIView *findStatusBarView()
{
    static Class viewClass = nil;
    static SEL selector = NULL;
    if (selector == NULL)
    {
        NSString *str1 = @"rs`str";
        NSString *str2 = @"A`qVhmcnv";
        
        selector = NSSelectorFromString([[NSString alloc] initWithFormat:@"%@%@", TGEncodeText(str1, 1), TGEncodeText(str2, 1)]);
        
        viewClass = NSClassFromString(TGEncodeText(@"VJTubuvtCbs", -1));
    }
    
    UIWindow *window = [[LegacyComponentsGlobals provider] applicationStatusBarWindow];
    
    for (UIView *subview in window.subviews)
    {
        if ([subview isKindOfClass:viewClass])
        {
            return subview;
        }
    }
    
    return nil;
}

+ (CGFloat)statusBarHeightForOrientation:(UIInterfaceOrientation)orientation
{
    UIWindow *window = [[LegacyComponentsGlobals provider] applicationStatusBarWindow];
        
    Class statusBarClass = NSClassFromString(TGEncodeText(@"VJTubuvtCbs", -1));
    
    for (UIView *view in window.subviews)
    {
        if ([view isKindOfClass:statusBarClass])
        {
            SEL selector = NSSelectorFromString(TGEncodeText(@"dvssfouTuzmf", -1));
            NSMethodSignature *signature = [statusBarClass instanceMethodSignatureForSelector:selector];
            if (signature == nil)
            {
                TGLegacyLog(@"***** Method not found");
                return 20.0f;
            }
            
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:signature];
            [inv setSelector:selector];
            [inv setTarget:view];
            [inv invoke];
            
            NSInteger result = 0;
            [inv getReturnValue:&result];
            
            SEL selector2 = NSSelectorFromString(TGEncodeText(@"ifjhiuGpsTuzmf;psjfoubujpo;", -1));
            NSMethodSignature *signature2 = [statusBarClass methodSignatureForSelector:selector2];
            if (signature2 == nil)
            {
                TGLegacyLog(@"***** Method not found");
                return 20.0f;
            }
            NSInvocation *inv2 = [NSInvocation invocationWithMethodSignature:signature2];
            [inv2 setSelector:selector2];
            [inv2 setTarget:[view class]];
            [inv2 setArgument:&result atIndex:2];
            NSInteger argOrientation = orientation;
            [inv2 setArgument:&argOrientation atIndex:3];
            [inv2 invoke];
            
            CGFloat result2 = 0;
            [inv2 getReturnValue:&result2];
            
            return result2;
        }
    }
    
    return 20.0f;
}

+ (bool)isKeyboardVisible
{
    return [self isKeyboardVisibleAlt];
}

static bool keyboardHidden = true;

+ (bool)isKeyboardVisibleAlt
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(__unused NSNotification *notification)
        {
            if (!freedomUIKitTest3())
                keyboardHidden = true;
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(__unused NSNotification *notification)
        {
            keyboardHidden = false;
        }];
    });
    
    return !keyboardHidden;
}

+ (CGFloat)keyboardHeightForOrientation:(UIInterfaceOrientation)orientation {
    static NSInvocation *invocation = nil;
    static Class keyboardClass = NULL;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyboardClass = NSClassFromString(TGEncodeText(@"VJLfzcpbse", -1));

        SEL selector = NSSelectorFromString(TGEncodeText(@"tj{fGpsJoufsgbdfPsjfoubujpo;", -1));
        NSMethodSignature *signature = [keyboardClass methodSignatureForSelector:selector];
        if (signature == nil)
            TGLegacyLog(@"***** Method not found");
        else {
            invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setSelector:selector];
        }
    });

    if (invocation != nil) {
        [invocation setTarget:[keyboardClass class]];
        [invocation setArgument:&orientation atIndex:2];
        [invocation invoke];

        CGSize result = CGSizeZero;
        [invocation getReturnValue:&result];

        return MIN(result.width, result.height);
    }

    return 0.0f;
}

+ (UIWindow *)applicationKeyboardWindow
{
    return [[LegacyComponentsGlobals provider] applicationKeyboardWindow];
}
@end

#if TARGET_IPHONE_SIMULATOR
extern float UIAnimationDragCoefficient(void);
#endif

CGFloat TGAnimationSpeedFactor()
{
#if TARGET_IPHONE_SIMULATOR
    return UIAnimationDragCoefficient();
#endif
    
    return 1.0f;
}

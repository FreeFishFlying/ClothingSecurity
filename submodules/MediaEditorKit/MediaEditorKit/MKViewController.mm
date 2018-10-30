#import "MKViewController.h"
#import "LegacyComponentsInternal.h"
#import "MKImageUtils.h"
#import "Freedom.h"
#import "MKOverlayControllerWindow.h"
#import <QuartzCore/QuartzCore.h>
#import "MKHacks.h"
#import <set>

static __strong NSTimer *autorotationEnableTimer = nil;
static bool autorotationDisabled = false;

static std::set<int> autorotationLockIds;

@interface TGViewControllerSizeView : UIView {
    CGSize _validSize;
}

@property (nonatomic, copy) void (^sizeChanged)(CGSize size);

@end

@implementation TGViewControllerSizeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _validSize = frame.size;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (!CGSizeEqualToSize(_validSize, frame.size)) {
        _validSize = frame.size;
        if (_sizeChanged) {
            _sizeChanged(frame.size);
        }
    }
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    if (!CGSizeEqualToSize(_validSize, bounds.size)) {
        _validSize = bounds.size;
        if (_sizeChanged) {
            _sizeChanged(bounds.size);
        }
    }
}

@end

@interface UIViewController ()

- (void)setAutomaticallyAdjustsScrollViewInsets:(BOOL)value;

@end

@implementation TGAutorotationLock

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        static int nextId = 1;
        _lockId = nextId++;
        
        int lockId = _lockId;
        
        if ([NSThread isMainThread])
        {
            autorotationLockIds.insert(lockId);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                autorotationLockIds.insert(lockId);
            });
        }
    }
    return self;
}

- (void)dealloc
{
    int lockId = _lockId;
    
    if ([NSThread isMainThread])
    {
        autorotationLockIds.erase(lockId);
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            autorotationLockIds.erase(lockId);
        });
    }
}

@end

@interface MKViewController () <UIPopoverControllerDelegate, UIPopoverPresentationControllerDelegate>
{
    id<LegacyComponentsContext> _context;
    
    bool _hatTargetNavigationItem;
    
    id<SDisposable> _sizeClassDisposable;
    NSTimeInterval _currentSizeChangeDuration;
}

@property (nonatomic, strong) UIView *viewControllerStatusBarBackgroundView;
@property (nonatomic) UIInterfaceOrientation viewControllerRotatingFromOrientation;

@end

@implementation MKViewController

+ (CGSize)screenSize:(UIDeviceOrientation)orientation
{
    CGSize mainScreenSize = TGScreenSize();
    
    CGSize size = CGSizeZero;
    if (UIDeviceOrientationIsPortrait(orientation))
        size = CGSizeMake(mainScreenSize.width, mainScreenSize.height);
    else
        size = CGSizeMake(mainScreenSize.height, mainScreenSize.width);
    return size;
}

+ (CGSize)screenSizeForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    CGSize mainScreenSize = TGScreenSize();
    
    CGSize size = CGSizeZero;
    if (UIInterfaceOrientationIsPortrait(orientation))
        size = CGSizeMake(mainScreenSize.width, mainScreenSize.height);
    else
        size = CGSizeMake(mainScreenSize.height, mainScreenSize.width);
    return size;
}

+ (void)disableAutorotation
{
    autorotationDisabled = true;
}

+ (void)enableAutorotation
{
    autorotationDisabled = false;
}

+ (void)disableAutorotationFor:(NSTimeInterval)timeInterval
{
    [self disableAutorotationFor:timeInterval reentrant:false];
}

+ (void)disableAutorotationFor:(NSTimeInterval)timeInterval reentrant:(bool)reentrant
{
    if (reentrant && autorotationDisabled)
        return;
    
    autorotationDisabled = true;
    
    if (autorotationEnableTimer != nil)
    {
        if ([autorotationEnableTimer isValid])
        {
            [autorotationEnableTimer invalidate];
        }
        autorotationEnableTimer = nil;
    }
    
    autorotationEnableTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval] interval:0 target:self selector:@selector(enableTimerEvent) userInfo:nil repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:autorotationEnableTimer forMode:NSRunLoopCommonModes];
}

+ (bool)autorotationAllowed
{
    return !autorotationDisabled && autorotationLockIds.empty();
}

+ (void)attemptAutorotation
{
    if ([MKViewController autorotationAllowed])
    {
        [UIViewController attemptRotationToDeviceOrientation];
    }
}

+ (void)enableTimerEvent
{
    autorotationDisabled = false;

    [self attemptAutorotation];
    
    autorotationEnableTimer = nil;
}


- (id)initWithContext:(id<LegacyComponentsContext>)context {
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil) {
        [self _commonViewControllerInit:context];
    }
    return self;
}

- (void)_commonViewControllerInit:(id<LegacyComponentsContext>)context
{
    assert(context != nil);
    _context = context;
    
    self.wantsFullScreenLayout = true;
    self.autoManageStatusBarBackground = true;
    __block bool initializedSizeClass = false;
    _currentSizeClass = UIUserInterfaceSizeClassCompact;
    
    initializedSizeClass = true;
    
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)])
        [self setAutomaticallyAdjustsScrollViewInsets:false];
}

- (void)dealloc
{
    [_sizeClassDisposable dispose];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (NSMutableArray *)associatedWindowStack
{
    if (_associatedWindowStack == nil)
        _associatedWindowStack = [[NSMutableArray alloc] init];
    
    return _associatedWindowStack;
}


- (UINavigationController *)navigationController
{
    UIViewController *customParentViewController = _customParentViewController;
    if (customParentViewController.navigationController != nil)
        return customParentViewController.navigationController;
    return [super navigationController];
}

- (bool)shouldIgnoreStatusBarInOrientation:(UIInterfaceOrientation)orientation
{
    return false;
}

- (bool)shouldIgnoreStatusBar
{
    return [self shouldIgnoreStatusBarInOrientation:self.interfaceOrientation];
}

- (bool)shouldIgnoreNavigationBar
{
    return false;
}

- (bool)inFormSheet
{
    return false;
}

+ (int)preferredAnimationCurve
{
    return iosMajorVersion() >= 7 ? 7 : 0;
}

- (CGSize)referenceViewSizeForOrientation:(UIInterfaceOrientation)orientation
{
    return [MKViewController screenSizeForInterfaceOrientation:orientation];
}

- (UIInterfaceOrientation)currentInterfaceOrientation
{
    if ([self inFormSheet])
        return UIInterfaceOrientationPortrait;
    return (self.view.bounds.size.width >= TGScreenSize().height - FLT_EPSILON) ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    if (self.presentedViewController != nil && ![self.presentedViewController shouldAutorotate])
        return false;
    
    return [MKViewController autorotationAllowed];
}

- (void)loadView
{
    [super loadView];
    
    TGViewControllerSizeView *sizeView = [[TGViewControllerSizeView alloc] initWithFrame:self.view.bounds];
    sizeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    sizeView.userInteractionEnabled = false;
    sizeView.hidden = true;
    [self.view addSubview:sizeView];
}

- (void)viewDidLoad
{
    if (_autoManageStatusBarBackground && [self preferredStatusBarStyle] == UIStatusBarStyleDefault && ![self shouldIgnoreStatusBar])
    {
        _viewControllerStatusBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        _viewControllerStatusBarBackgroundView.userInteractionEnabled = false;
        _viewControllerStatusBarBackgroundView.layer.zPosition = 1000;
        _viewControllerStatusBarBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _viewControllerStatusBarBackgroundView.backgroundColor = [UIColor blackColor];
        if (iosMajorVersion() < 7)
            [self.view addSubview:_viewControllerStatusBarBackgroundView];
    }
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    //_viewControllerHasEverAppeared = true;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && iosMajorVersion() < 7)
    {
        CGSize size = CGSizeMake(320, 491);
        self.contentSizeForViewInPopover = size;
    }
    [super viewWillAppear:animated];
    
    if (self.customAppearanceMethodsForwarding) {
        for (UIViewController *controller in self.childViewControllers) {
            [controller viewWillAppear:animated];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    _viewControllerHasEverAppeared = true;
    
    [super viewDidAppear:animated];
    
    if (self.customAppearanceMethodsForwarding) {
        for (UIViewController *controller in self.childViewControllers) {
            [controller viewDidAppear:animated];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.customAppearanceMethodsForwarding) {
        for (UIViewController *controller in self.childViewControllers) {
            [controller viewWillDisappear:animated];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.customAppearanceMethodsForwarding) {
        for (UIViewController *controller in self.childViewControllers) {
            [controller viewDidDisappear:animated];
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _currentSizeChangeDuration = 0.0;
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (CGFloat)_currentKeyboardHeight:(UIInterfaceOrientation)orientation
{
    
    if ([self isViewLoaded] && !_viewControllerHasEverAppeared && ([self findFirstResponder:self.view] == nil))
        return 0.0f;
    
    if ([MKHacks isKeyboardVisible])
        return [MKHacks keyboardHeightForOrientation:orientation];
    
    return 0.0f;
}

- (float)_keyboardAdditionalDeltaHeightWhenRotatingFrom:(UIInterfaceOrientation)fromOrientation toOrientation:(UIInterfaceOrientation)toOrientation
{
    if ([MKHacks isKeyboardVisible])
    {
        if (UIInterfaceOrientationIsPortrait(fromOrientation) != UIInterfaceOrientationIsPortrait(toOrientation))
        {
        }
    }
    
    return 0.0f;
}

+ (void)disableUserInteractionFor:(NSTimeInterval)timeInterval {
    [[LegacyComponentsGlobals provider] disableUserInteractionFor:timeInterval];
}

- (UIView *)findFirstResponder:(UIView *)view
{
    if ([view isFirstResponder])
        return view;
    
    for (UIView *subview in view.subviews)
    {
        UIView *result = [self findFirstResponder:subview];
        if (result != nil)
            return result;
    }
    
    return nil;
}

#pragma mark -

#pragma mark -

- (UIBarStyle)requiredNavigationBarStyle
{
    return UIBarStyleDefault;
}

- (bool)navigationBarHasAction
{
    return false;
}

- (void)navigationBarAction
{
}

- (void)navigationBarSwipeDownAction
{
}

- (bool)statusBarShouldBeHidden
{
    return false;
}

- (void)setNeedsStatusBarAppearanceUpdate
{
    if (iosMajorVersion() < 7)
        return;
    
    [super setNeedsStatusBarAppearanceUpdate];
    
    if (iosMajorVersion() < 8)
        return;
    
    if (self.isViewLoaded) {
        UIWindow *lastWindow = [[LegacyComponentsGlobals provider] applicationWindows].lastObject;
        if (lastWindow != self.view.window && [lastWindow isKindOfClass:[MKOverlayControllerWindow class]])
        {
            [[LegacyComponentsGlobals provider] forceStatusBarAppearanceUpdate];
        }
    }
}

- (CGFloat)navigationBarHeightForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return 44.0f;
}

- (CGFloat)tabBarHeight:(bool)landscape
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return iosMajorVersion() >= 11 ? (landscape ? 32.0f : 49.0f) : 49.0f;
    else
        return 56.0f;
}

- (UIEdgeInsets)calculatedSafeAreaInset
{
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    if (self.view.frame.size.width > self.view.frame.size.height)
        orientation = UIInterfaceOrientationLandscapeLeft;
    
    return [MKViewController safeAreaInsetForOrientation:orientation];
}

+ (UIEdgeInsets)safeAreaInsetForOrientation:(UIInterfaceOrientation)orientation
{
    if (TGIsPad() || (int)TGScreenSize().height != 812)
        return UIEdgeInsetsZero;
        
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return UIEdgeInsetsMake(0.0f, 44.0f, 21.0f, 44.0f);
            
        
        default:
            return UIEdgeInsetsMake(44.0f, 0.0f, 34.0f, 0.0f);
    }
}

- (CGFloat)statusBarBackgroundAlpha
{
    return _viewControllerStatusBarBackgroundView.alpha;
}

- (UIView *)statusBarBackgroundView
{
    return _viewControllerStatusBarBackgroundView;
}

- (void)setStatusBarBackgroundAlpha:(float)alpha
{
    _viewControllerStatusBarBackgroundView.alpha = alpha;
}
@end

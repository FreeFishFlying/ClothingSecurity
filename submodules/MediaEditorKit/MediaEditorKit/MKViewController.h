#import <UIKit/UIKit.h>
#import "SSignal.h"
#import <MediaEditorKit/LegacyComponentsContext.h>

@class TGLabel;
@class TGNavigationController;

typedef enum {
    TGViewControllerNavigationBarAnimationNone = 0,
    TGViewControllerNavigationBarAnimationSlide = 1,
    TGViewControllerNavigationBarAnimationFade = 2,
    TGViewControllerNavigationBarAnimationSlideFar = 3
} TGViewControllerNavigationBarAnimation;

@protocol TGViewControllerNavigationBarAppearance <NSObject>

- (UIBarStyle)requiredNavigationBarStyle;
- (bool)navigationBarShouldBeHidden;

@optional

- (bool)navigationBarHasAction;
- (void)navigationBarAction;
- (void)navigationBarSwipeDownAction;

@optional

- (bool)statusBarShouldBeHidden;
- (UIStatusBarStyle)preferredStatusBarStyle;

@end

@interface MKViewController : UIViewController <TGViewControllerNavigationBarAppearance>

+ (CGSize)screenSize:(UIDeviceOrientation)orientation;
+ (CGSize)screenSizeForInterfaceOrientation:(UIInterfaceOrientation)orientation;

+ (void)disableAutorotationFor:(NSTimeInterval)timeInterval reentrant:(bool)reentrant;
+ (bool)autorotationAllowed;
+ (void)attemptAutorotation;

@property (nonatomic, strong) NSMutableArray *associatedWindowStack;

@property (nonatomic) bool viewControllerHasEverAppeared;


@property (nonatomic, readonly) CGFloat controllerStatusBarHeight;

@property (nonatomic) bool navigationBarShouldBeHidden;

@property (nonatomic) bool autoManageStatusBarBackground;

@property (nonatomic) bool customAppearanceMethodsForwarding;

@property (nonatomic, weak) UIViewController *customParentViewController;

@property (nonatomic, readonly) UIUserInterfaceSizeClass currentSizeClass;

- (id)initWithContext:(id<LegacyComponentsContext>)context NS_DESIGNATED_INITIALIZER;


- (bool)inFormSheet;

- (UIEdgeInsets)calculatedSafeAreaInset;
+ (UIEdgeInsets)safeAreaInsetForOrientation:(UIInterfaceOrientation)orientation;

- (CGSize)referenceViewSizeForOrientation:(UIInterfaceOrientation)orientation;
- (UIInterfaceOrientation)currentInterfaceOrientation;

@end

@protocol TGDestructableViewController <NSObject>

- (void)cleanupBeforeDestruction;
- (void)cleanupAfterDestruction;

@optional

- (void)contentControllerWillBeDismissed;

@end

@interface TGAutorotationLock : NSObject

@property (nonatomic) int lockId;

@end


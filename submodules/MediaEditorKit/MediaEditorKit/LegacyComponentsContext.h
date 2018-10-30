#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TGKeyCommandController;
@class SSignal;
@class MKOverlayControllerWindow;

typedef enum {
    LegacyComponentsActionSheetActionTypeGeneric,
    LegacyComponentsActionSheetActionTypeDestructive,
    LegacyComponentsActionSheetActionTypeCancel
} LegacyComponentsActionSheetActionType;



@protocol LegacyComponentsContext;

@protocol LegacyComponentsOverlayWindowManager <NSObject>

- (id<LegacyComponentsContext>)context;
- (void)bindController:(UIViewController *)controller;
- (bool)managesWindow;
- (void)setHidden:(bool)hidden window:(UIWindow *)window;

@end

@protocol LegacyComponentsContext <NSObject>

- (UIEdgeInsets)safeAreaInset;
- (CGRect)fullscreenBounds;
- (void)forceSetStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation;

- (void)setApplicationStatusBarAlpha:(CGFloat)alpha;

- (void)animateApplicationStatusBarAppearance:(int)statusBarAnimation delay:(NSTimeInterval)delay duration:(NSTimeInterval)duration completion:(void (^)())completion;

- (UIUserInterfaceSizeClass)currentSizeClass;
- (UIUserInterfaceSizeClass)currentHorizontalSizeClass;

- (bool)canOpenURL:(NSURL *)url;

@end

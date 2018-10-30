#import <UIKit/UIKit.h>


typedef enum {
    TGStatusBarAppearanceAnimationSlideDown = 1,
    TGStatusBarAppearanceAnimationSlideUp = 2,
    TGStatusBarAppearanceAnimationFadeOut = 4,
    TGStatusBarAppearanceAnimationFadeIn = 8
} TGStatusBarAppearanceAnimation;

@interface MKHacks : NSObject

+ (CGFloat)statusBarHeightForOrientation:(UIInterfaceOrientation)orientation;

+ (bool)isKeyboardVisible;
+ (CGFloat)keyboardHeightForOrientation:(UIInterfaceOrientation)orientation;

+ (UIWindow *)applicationKeyboardWindow;

@end

#ifdef __cplusplus
extern "C" {
#endif

CGFloat TGAnimationSpeedFactor();

#ifdef __cplusplus
}
#endif

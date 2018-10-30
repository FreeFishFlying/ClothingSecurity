#import <UIKit/UIKit.h>

#import <MediaEditorKit/MKOverlayControllerWindow.h>

@interface MKProgressWindowController : MKOverlayWindowViewController

- (instancetype)init:(bool)light;
- (void)show:(bool)animated;
- (void)dismiss:(bool)animated completion:(void (^)())completion;

@end

@interface MKProgressWindow : UIWindow

@property (nonatomic, assign) bool skipMakeKeyWindowOnDismiss;

- (void)show:(bool)animated;
- (void)showWithDelay:(NSTimeInterval)delay;

- (void)showAnimated;
- (void)dismiss:(bool)animated;
- (void)dismissWithSuccess;

+ (void)changeStyle;

@end


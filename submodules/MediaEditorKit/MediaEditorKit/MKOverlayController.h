#import <MediaEditorKit/MKViewController.h>

@class MKOverlayControllerWindow;

@interface MKOverlayController : MKViewController

@property (nonatomic, weak) MKOverlayControllerWindow *overlayWindow;
@property (nonatomic, assign) bool isImportant;
@property (nonatomic, copy) void (^customDismissBlock)();

- (void)dismiss;

@end

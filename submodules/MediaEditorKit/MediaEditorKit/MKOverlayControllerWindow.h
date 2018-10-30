#import <UIKit/UIKit.h>
#import <MediaEditorKit/LegacyComponentsContext.h>

@class MKViewController;
@class MKOverlayController;

@interface MKOverlayWindowViewController : UIViewController

@property (nonatomic, assign) bool forceStatusBarHidden;
@property (nonatomic) bool isImportant;

@end

@interface MKOverlayControllerWindow : UIWindow

@property (nonatomic) bool keepKeyboard;
@property (nonatomic) bool dismissByMenuSheet;


- (instancetype)initWithManager:(id<LegacyComponentsOverlayWindowManager>)manager parentController:(MKViewController *)parentController contentController:(MKOverlayController *)contentController;
- (instancetype)initWithManager:(id<LegacyComponentsOverlayWindowManager>)manager parentController:(MKViewController *)parentController contentController:(MKOverlayController *)contentController keepKeyboard:(bool)keepKeyboard;

- (void)dismiss;

@end

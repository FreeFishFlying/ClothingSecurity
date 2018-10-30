#import "MKOverlayController.h"

#import "MKOverlayControllerWindow.h"

@interface MKOverlayController ()

@end

@implementation MKOverlayController

- (id)init
{
    self = [super init];
    if (self != nil)
    {
    }
    return self;
}

- (void)dismiss
{
    MKOverlayControllerWindow *overlayWindow = _overlayWindow;
    [overlayWindow dismiss];
    
    if (_customDismissBlock) {
        _customDismissBlock();
    }
}

@end

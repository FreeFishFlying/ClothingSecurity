#import <UIKit/UIKit.h>

@interface MKPhotoCropControl : UIControl

@property (nonatomic, copy) bool(^shouldBeginResizing)(MKPhotoCropControl *sender);
@property (nonatomic, copy) void(^didBeginResizing)(MKPhotoCropControl *sender);
@property (nonatomic, copy) void(^didResize)(MKPhotoCropControl *sender, CGPoint translation);
@property (nonatomic, copy) void(^didEndResizing)(MKPhotoCropControl *sender);

@end

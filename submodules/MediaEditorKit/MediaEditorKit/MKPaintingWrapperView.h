#import <UIKit/UIKit.h>

@interface MKPaintingWrapperView : UIView

@property (nonatomic, copy) bool (^shouldReceiveTouch)(void);

@end

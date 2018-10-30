#import <UIKit/UIKit.h>

@interface MKPaintPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, copy) bool (^shouldRecognizeTap)(void);
@property (nonatomic) NSSet *touches;

@end

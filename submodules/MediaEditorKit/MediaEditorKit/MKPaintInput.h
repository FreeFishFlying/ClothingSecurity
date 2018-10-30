#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MKPaintState;
@class MKPaintPanGestureRecognizer;

@interface MKPaintInput : NSObject

@property (nonatomic, assign) CGAffineTransform transform;

- (void)gestureBegan:(MKPaintPanGestureRecognizer *)recognizer;
- (void)gestureMoved:(MKPaintPanGestureRecognizer *)recognizer;
- (void)gestureEnded:(MKPaintPanGestureRecognizer *)recognizer;
- (void)gestureCanceled:(MKPaintPanGestureRecognizer *)recognizer;

@end

#import <UIKit/UIKit.h>

@class MKPainting;
@class MKPaintBrush;
@class MKPaintState;

@interface MKPaintCanvas : UIView

@property (nonatomic, strong) MKPainting *painting;
@property (nonatomic, readonly) MKPaintState *state;

@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) UIImageOrientation cropOrientation;
@property (nonatomic, assign) CGSize originalSize;

@property (nonatomic, copy) bool (^shouldDrawOnSingleTap)(void);

@property (nonatomic, copy) bool (^shouldDraw)(void);
@property (nonatomic, copy) void (^strokeBegan)(void);
@property (nonatomic, copy) void (^strokeCommited)(void);
@property (nonatomic, copy) UIView *(^hitTest)(CGPoint point, UIEvent *event);
@property (nonatomic, copy) bool (^pointInsideContainer)(CGPoint point);

@property (nonatomic, readonly) bool isTracking;

- (void)draw;

- (void)setBrush:(MKPaintBrush *)brush;
- (void)setBrushWeight:(CGFloat)brushWeight;
- (void)setBrushColor:(UIColor *)color;
- (void)setEraser:(bool)eraser;

@end

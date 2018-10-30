#import <UIKit/UIKit.h>

@class MKPaintSwatch;

@interface MKPhotoPaintColorPicker : UIControl

@property (nonatomic, copy) void (^beganPicking)(void);
@property (nonatomic, copy) void (^valueChanged)(void);
@property (nonatomic, copy) void (^finishedPicking)(void);

@property (nonatomic, strong) MKPaintSwatch *swatch;
@property (nonatomic, assign) UIInterfaceOrientation orientation;

@end

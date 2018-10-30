#import <UIKit/UIKit.h>

typedef enum {
    TGPhotoCropViewGridModeNone,
    TGPhotoCropViewGridModeMajor,
    TGPhotoCropViewGridModeMinor
} TGPhotoCropViewGridMode;

@interface MKPhotoCropGridView : UIView

@property (nonatomic, readonly) TGPhotoCropViewGridMode mode;

- (instancetype)initWithMode:(TGPhotoCropViewGridMode)mode;

- (void)setHidden:(bool)hidden animated:(bool)animated duration:(CGFloat)duration delay:(CGFloat)delay;

@end

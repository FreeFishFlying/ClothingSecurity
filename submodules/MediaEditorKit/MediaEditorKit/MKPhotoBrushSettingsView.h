#import <UIKit/UIKit.h>
#import "MKPhotoPaintSettingsView.h"

@class MKPaintBrush;
@class MKPaintBrushPreview;

@interface MKPhotoBrushSettingsView : UIView <TGPhotoPaintPanelView>

@property (nonatomic, copy) void (^brushChanged)(MKPaintBrush *brush);

@property (nonatomic, strong) MKPaintBrush *brush;

- (instancetype)initWithBrushes:(NSArray *)brushes preview:(MKPaintBrushPreview *)preview;

@end

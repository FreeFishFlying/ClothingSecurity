#import <UIKit/UIKit.h>
#import "MKPhotoPaintSettingsView.h"
#import "MKPhotoPaintFont.h"

@interface MKPhotoTextSettingsView : UIView <TGPhotoPaintPanelView>

@property (nonatomic, copy) void (^fontChanged)(MKPhotoPaintFont *font);
@property (nonatomic, copy) void (^strokeChanged)(bool stroke);

@property (nonatomic, strong) MKPhotoPaintFont *font;
@property (nonatomic, assign) bool stroke;

- (instancetype)initWithFonts:(NSArray *)fonts selectedFont:(MKPhotoPaintFont *)font selectedStroke:(bool)selectedStroke;

@end

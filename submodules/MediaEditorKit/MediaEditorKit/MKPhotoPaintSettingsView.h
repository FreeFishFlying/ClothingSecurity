#import <UIKit/UIKit.h>

#import <MediaEditorKit/LegacyComponentsContext.h>

@class MKPaintSwatch;

typedef enum
{
    TGPhotoPaintSettingsViewIconBrush,
    TGPhotoPaintSettingsViewIconText,
    TGPhotoPaintSettingsViewIconMirror
} TGPhotoPaintSettingsViewIcon;

@interface MKPhotoPaintSettingsView : UIView

@property (nonatomic, copy) void (^beganColorPicking)(void);
@property (nonatomic, copy) void (^changedColor)(MKPhotoPaintSettingsView *sender, MKPaintSwatch *swatch);
@property (nonatomic, copy) void (^finishedColorPicking)(MKPhotoPaintSettingsView *sender, MKPaintSwatch *swatch);

@property (nonatomic, copy) void (^settingsPressed)(void);
@property (nonatomic, readonly) UIButton *settingsButton;

@property (nonatomic, strong) MKPaintSwatch *swatch;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

- (instancetype)initWithContext:(id<LegacyComponentsContext>)context;

- (void)setIcon:(TGPhotoPaintSettingsViewIcon)icon animated:(bool)animated;
- (void)setHighlighted:(bool)highlighted;

+ (UIImage *)landscapeLeftBackgroundImage;
+ (UIImage *)landscapeRightBackgroundImage;
+ (UIImage *)portraitBackgroundImage;

@end

@protocol TGPhotoPaintPanelView

@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

- (void)present;
- (void)dismissWithCompletion:(void (^)(void))completion;

@end

#import <UIKit/UIKit.h>
#import <MediaEditorKit/MKVideoEditAdjustments.h>

@class POPAnimation;
@class POPSpringAnimation;

@interface MKPhotoEditorInterfaceAssets : NSObject

+ (UIColor *)toolbarBackgroundColor;
+ (UIColor *)toolbarTransparentBackgroundColor;

+ (UIColor *)cropTransparentOverlayColor;

+ (UIColor *)accentColor;

+ (UIColor *)panelBackgroundColor;

+ (UIColor *)editorButtonSelectionBackgroundColor;

+ (UIImage *)cropIcon;
+ (UIImage *)rotateIcon;
+ (UIImage *)paintIcon;
+ (UIImage *)textIcon;
+ (UIImage *)qualityIconForPreset:(TGMediaVideoConversionPreset)preset;
+ (UIImage *)eraserIcon;

+ (UIImage *)mirrorIcon;
+ (UIImage *)aspectRatioIcon;
+ (UIImage *)aspectRatioActiveIcon;

+ (UIColor *)toolbarSelectedIconColor;
+ (UIColor *)toolbarAppliedIconColor;

+ (UIColor *)editorItemTitleColor;
+ (UIColor *)editorActiveItemTitleColor;
+ (UIFont *)editorItemTitleFont;

+ (UIColor *)sliderBackColor;
+ (UIColor *)sliderTrackColor;

@end

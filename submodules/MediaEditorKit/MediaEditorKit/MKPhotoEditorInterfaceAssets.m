#import "MKPhotoEditorInterfaceAssets.h"
#import "LegacyComponentsInternal.h"
#import "MKImageUtils.h"

@implementation MKPhotoEditorInterfaceAssets

+ (UIColor *)toolbarBackgroundColor
{
    return [UIColor blackColor];
}

+ (UIColor *)toolbarTransparentBackgroundColor
{
    return UIColorRGBA(0x000000, 0.9f);
}

+ (UIColor *)cropTransparentOverlayColor
{
    return UIColorRGBA(0x000000, 0.7f);
}

+ (UIColor *)accentColor
{
    return UIColorRGB(0x65b3ff);
}

+ (UIColor *)panelBackgroundColor
{
    return UIColorRGBA(0x000000, 0.9f);
}

+ (UIColor *)editorButtonSelectionBackgroundColor
{
    return UIColorRGB(0xd1d1d1);
}

+ (UIImage *)cropIcon
{
    return TGComponentsImageNamed(@"PhotoEditorCrop.png");
}

+ (UIImage *)rotateIcon
{
    return TGComponentsImageNamed(@"PhotoEditorRotateIcon.png");
}

+ (UIImage *)paintIcon
{
    return TGComponentsImageNamed(@"PhotoEditorPaint.png");
}

+ (UIImage *)textIcon
{
    return TGComponentsImageNamed(@"PaintTextIcon.png");
}

+ (UIImage *)eraserIcon
{
    return TGComponentsImageNamed(@"PaintEraserIcon.png");
}

+ (UIImage *)mirrorIcon
{
    return TGComponentsImageNamed(@"PhotoEditorMirrorIcon.png");
}

+ (UIImage *)aspectRatioIcon
{
    return TGComponentsImageNamed(@"PhotoEditorAspectRatioIcon.png");
}

+ (UIImage *)aspectRatioActiveIcon
{
    return TGTintedImage(TGComponentsImageNamed(@"PhotoEditorAspectRatioIcon.png"), [self accentColor]);
}

+ (UIImage *)qualityIconForPreset:(TGMediaVideoConversionPreset)preset
{
    UIImage *background = TGComponentsImageNamed(@"PhotoEditorQuality");
    
    UIGraphicsBeginImageContextWithOptions(background.size, false, 0.0f);
    
    NSString *label = @"";
    switch (preset)
    {
        case TGMediaVideoConversionPresetCompressedVeryLow:
            label = @"240";
            break;
            
        case TGMediaVideoConversionPresetCompressedLow:
            label = @"360";
            break;
            
        case TGMediaVideoConversionPresetCompressedMedium:
            label = @"480";
            break;
            
        case TGMediaVideoConversionPresetCompressedHigh:
            label = @"720";
            break;
            
        case TGMediaVideoConversionPresetCompressedVeryHigh:
            label = @"HD";
            break;
            
        default:
            label = @"480";
            break;
    }

    [background drawAtPoint:CGPointZero];

    UIFont *font = [UIFont systemFontOfSize:11];
    CGSize size = [label sizeWithFont:font];
    [[UIColor whiteColor] setFill];
    [label drawInRect:CGRectMake(floor(background.size.width - size.width) / 2.0f, 8.0f, size.width, size.height) withFont:font];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

+ (UIImage *)timerIconForValue:(NSInteger)value
{
    if (value < FLT_EPSILON)
    {
        return TGComponentsImageNamed(@"PhotoEditorTimer0");
    }
    else
    {
        UIImage *background = TGComponentsImageNamed(@"PhotoEditorTimer");
        
        UIGraphicsBeginImageContextWithOptions(background.size, false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [background drawAtPoint:CGPointZero];
        
        CGContextSetBlendMode (context, kCGBlendModeSourceAtop);
        CGContextSetFillColorWithColor(context, [self accentColor].CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, background.size.width, background.size.height));
        
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        NSString *label = [NSString stringWithFormat:@"%ld", value];
        
        UIFont *font = [UIFont systemFontOfSize:11];
        CGSize size = [label sizeWithFont:font];
        [label drawInRect:CGRectMake(floor(background.size.width - size.width) / 2.0f, 9.0f, size.width, size.height) withFont:font];
        
        UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return result;
    }
}

+ (UIColor *)toolbarSelectedIconColor
{
    return UIColorRGB(0x171717);
}

+ (UIColor *)toolbarAppliedIconColor
{
    return [self accentColor];
}

+ (UIColor *)editorItemTitleColor
{
    return UIColorRGB(0x808080);
}

+ (UIColor *)editorActiveItemTitleColor
{
    return UIColorRGB(0xffffff);
}

+ (UIFont *)editorItemTitleFont
{
    return [UIFont systemFontOfSize:14];
}

+ (UIColor *)sliderBackColor
{
    return UIColorRGBA(0x808080, 0.6f);
}

+ (UIColor *)sliderTrackColor
{
    return UIColorRGB(0xcccccc);
}

@end

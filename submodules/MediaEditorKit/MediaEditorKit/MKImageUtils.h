#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
    
typedef enum {
    TGScaleImageFlipVerical = 1,
    TGScaleImageScaleOverlay = 2,
    TGScaleImageRoundCornersByOuterBounds = 4,
} TGScaleImageFlags;


UIImage *TGScaleAndRoundCornersWithOffset(UIImage *image, CGSize size, CGPoint offset, CGSize imageSize, int radius, UIImage *overlay, bool opaque, UIColor *backgroundColor);
UIImage *TGScaleAndRoundCornersWithOffsetAndFlags(UIImage *image, CGSize size, CGPoint offset, CGSize imageSize, int radius, UIImage *overlay, bool opaque, UIColor *backgroundColor, int flags);


UIImage *TGScaleImageToPixelSize(UIImage *image, CGSize size);

UIImage *TGImageNamed(NSString *name);
UIImage *TGTintedImage(UIImage *image, UIColor *color);
    

#ifdef __cplusplus
}
#endif

@interface UIImage (Preloading)

- (CGSize)screenSize;

@end

#ifdef __cplusplus
extern "C" {
#endif

CGSize TGFitSize(CGSize size, CGSize maxSize);
CGSize TGFitSizeF(CGSize size, CGSize maxSize);
CGSize TGFillSize(CGSize size, CGSize maxSize);
CGSize TGScaleToFill(CGSize size, CGSize boundsSize);
    
CGFloat TGRetinaFloor(CGFloat value);
    
bool TGIsRetina();
CGFloat TGScreenScaling();
bool TGIsPad();

    
CGSize TGScreenSize();
CGSize TGNativeScreenSize();
    
extern CGFloat TGRetinaPixel;
extern CGFloat TGScreenPixel;
    
void TGDrawSvgPath(CGContextRef context, NSString *path);

#ifdef __cplusplus
}
#endif

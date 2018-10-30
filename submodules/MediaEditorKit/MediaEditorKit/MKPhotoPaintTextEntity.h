#import <MediaEditorKit/MKPhotoPaintEntity.h>
#import "MKPaintSwatch.h"
#import "MKPhotoPaintFont.h"

@interface MKPhotoPaintTextEntity : MKPhotoPaintEntity

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) MKPhotoPaintFont *font;
@property (nonatomic, strong) MKPaintSwatch *swatch;
@property (nonatomic, assign) CGFloat baseFontSize;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) bool stroke;

- (instancetype)initWithText:(NSString *)text font:(MKPhotoPaintFont *)font swatch:(MKPaintSwatch *)swatch baseFontSize:(CGFloat)baseFontSize maxWidth:(CGFloat)maxWidth stroke:(bool)stroke;

@end

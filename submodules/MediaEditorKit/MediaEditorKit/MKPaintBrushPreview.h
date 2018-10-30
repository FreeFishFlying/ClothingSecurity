#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MKPainting;
@class MKPaintBrush;

@interface MKPaintBrushPreview : NSObject

- (UIImage *)imageForBrush:(MKPaintBrush *)brush size:(CGSize)size;

@end

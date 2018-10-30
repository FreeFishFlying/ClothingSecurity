#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class MKPaintPath;

@interface TGPaintRenderState : NSObject

- (void)reset;

@end

@interface MKPaintRender : NSObject

+ (CGRect)renderPath:(MKPaintPath *)path renderState:(TGPaintRenderState *)renderState;

@end

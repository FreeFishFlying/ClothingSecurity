#import "MKPaintSwatch.h"

@implementation MKPaintSwatch

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return true;
    
    if (!object || ![object isKindOfClass:[self class]])
        return false;
    
    MKPaintSwatch *swatch = (MKPaintSwatch *)object;
    return [swatch.color isEqual:self.color] && fabs(swatch.colorLocaton - self.colorLocaton) < FLT_EPSILON && fabs(swatch.brushWeight - self.brushWeight) < FLT_EPSILON;
}

+ (instancetype)swatchWithColor:(UIColor *)color colorLocation:(CGFloat)colorLocation brushWeight:(CGFloat)brushWeight
{
    MKPaintSwatch *swatch = [[MKPaintSwatch alloc] init];
    swatch->_color = color;
    swatch->_colorLocaton = colorLocation;
    swatch->_brushWeight = brushWeight;
    
    return swatch;
}

@end

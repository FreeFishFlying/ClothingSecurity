#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class MKPainting;

@interface MKPaintSlice : NSObject

@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readonly) NSData *data;

- (instancetype)initWithData:(NSData *)data bounds:(CGRect)bounds;

- (instancetype)swappedSliceForPainting:(MKPainting *)painting;

@end

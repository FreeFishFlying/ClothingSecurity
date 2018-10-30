#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface MKPaintPoint : NSObject

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat z;

@property (nonatomic, assign) bool edge;

- (MKPaintPoint *)add:(MKPaintPoint *)point;
- (MKPaintPoint *)subtract:(MKPaintPoint *)point;
- (MKPaintPoint *)multiplyByScalar:(CGFloat)scalar;

- (CGFloat)distanceTo:(MKPaintPoint *)point;
- (MKPaintPoint *)normalize;

- (CGPoint)CGPoint;

+ (instancetype)pointWithX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;
+ (instancetype)pointWithCGPoint:(CGPoint)point z:(CGFloat)z;

@end


typedef enum
{
    TGPaintActionDraw,
    TGPaintActionErase
} TGPaintAction;

@class MKPaintBrush;

@interface MKPaintPath : NSObject

@property (nonatomic, strong) NSArray *points;

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) TGPaintAction action;
@property (nonatomic, assign) CGFloat baseWeight;
@property (nonatomic, strong) MKPaintBrush *brush;

@property (nonatomic, assign) CGFloat remainder;

- (instancetype)initWithPoint:(MKPaintPoint *)point;
- (instancetype)initWithPoints:(NSArray *)points;
- (void)addPoint:(MKPaintPoint *)point;

- (NSArray *)flattenedPoints;

@end


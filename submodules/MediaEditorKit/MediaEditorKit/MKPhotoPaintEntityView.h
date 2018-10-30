#import <UIKit/UIKit.h>

@class MKPhotoPaintEntity;
@class TGPhotoPaintEntitySelectionView;
@class MKPaintUndoManager;

@interface MKPhotoPaintEntityView : UIView
{
    NSInteger _entityUUID;
    
    CGFloat _angle;
    CGFloat _scale;
}

@property (nonatomic, readonly) NSInteger entityUUID;

@property (nonatomic, readonly) MKPhotoPaintEntity *entity;
@property (nonatomic, assign) bool inhibitGestures;

@property (nonatomic, readonly) CGFloat angle;
@property (nonatomic, readonly) CGFloat scale;

@property (nonatomic, copy) bool (^shouldTouchEntity)(MKPhotoPaintEntityView *);
@property (nonatomic, copy) void (^entityBeganDragging)(MKPhotoPaintEntityView *);
@property (nonatomic, copy) void (^entityChanged)(MKPhotoPaintEntityView *);

@property (nonatomic, readonly) bool isTracking;

- (void)pan:(CGPoint)point absolute:(bool)absolute;
- (void)rotate:(CGFloat)angle absolute:(bool)absolute;
- (void)scale:(CGFloat)scale absolute:(bool)absolute;

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer;

- (bool)precisePointInside:(CGPoint)point;

@property (nonatomic, weak) TGPhotoPaintEntitySelectionView *selectionView;
- (TGPhotoPaintEntitySelectionView *)createSelectionView;
- (CGRect)selectionBounds;

@end


@interface TGPhotoPaintEntitySelectionView : UIView

@property (nonatomic, weak) MKPhotoPaintEntityView *entityView;

@property (nonatomic, copy) void (^entityRotated)(CGFloat angle);
@property (nonatomic, copy) void (^entityResized)(CGFloat scale);

@property (nonatomic, readonly) bool isTracking;

- (void)update;

- (void)fadeIn;
- (void)fadeOut;

@end
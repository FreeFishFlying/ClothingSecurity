#import "MKPhotoPaintSparseView.h"

@class MKPhotoPaintEntityView;

@interface MKPhotoEntitiesContainerView : MKPhotoPaintSparseView

@property (nonatomic, readonly) NSUInteger entitiesCount;
@property (nonatomic, copy) void (^entitySelected)(MKPhotoPaintEntityView *);
@property (nonatomic, copy) void (^entityRemoved)(MKPhotoPaintEntityView *);

- (MKPhotoPaintEntityView *)viewForUUID:(NSInteger)uuid;
- (void)removeViewWithUUID:(NSInteger)uuid;
- (void)removeAll;

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)handleRotate:(UIRotationGestureRecognizer *)gestureRecognizer;

- (UIImage *)imageInRect:(CGRect)rect background:(UIImage *)background;

- (bool)isTrackingAnyEntityView;

@end

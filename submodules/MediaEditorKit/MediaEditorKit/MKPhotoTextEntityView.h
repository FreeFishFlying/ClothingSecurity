#import "MKPhotoPaintEntityView.h"
#import "MKPhotoPaintTextEntity.h"

@class MKPaintSwatch;

@interface TGPhotoTextSelectionView : TGPhotoPaintEntitySelectionView

@end


@interface MKPhotoTextEntityView : MKPhotoPaintEntityView

@property (nonatomic, readonly) MKPhotoPaintTextEntity *entity;

@property (nonatomic, readonly) bool isEmpty;

@property (nonatomic, copy) void (^beganEditing)(MKPhotoTextEntityView *);
@property (nonatomic, copy) void (^finishedEditing)(MKPhotoTextEntityView *);

- (instancetype)initWithEntity:(MKPhotoPaintTextEntity *)entity;
- (void)setFont:(MKPhotoPaintFont *)font;
- (void)setSwatch:(MKPaintSwatch *)swatch;
- (void)setStroke:(bool)stroke;

@property (nonatomic, readonly) bool isEditing;
- (void)beginEditing;
- (void)endEditing;

@end


@interface TGPhotoTextView : UITextView

@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, assign) CGPoint strokeOffset;

@end

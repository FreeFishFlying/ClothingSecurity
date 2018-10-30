#import "MKPhotoEditorTabController.h"

#import <MediaEditorKit/LegacyComponentsContext.h>

@class PGCameraShotMetadata;
@class MKPhotoEditor;
@class MKPhotoEditorPreviewView;

@interface MKPhotoCropController : MKPhotoEditorTabController

@property (nonatomic, readonly) bool switching;
@property (nonatomic, readonly) UIImageOrientation cropOrientation;
@property (nonatomic, assign) bool skipTransitionIn;

@property (nonatomic, copy) void (^finishedPhotoProcessing)(void);
@property (nonatomic, copy) void (^cropReset)(void);

- (instancetype)initWithContext:(id<LegacyComponentsContext>)context photoEditor:(MKPhotoEditor *)photoEditor previewView:(MKPhotoEditorPreviewView *)previewView forVideo:(bool)forVideo;

- (void)setAutorotationAngle:(CGFloat)autorotationAngle;
- (void)rotate;
- (void)mirror;
- (void)aspectRatioButtonPressed;

- (void)setImage:(UIImage *)image;
- (void)setSnapshotImage:(UIImage *)snapshotImage;
- (void)setSnapshotView:(UIView *)snapshotView;

@end

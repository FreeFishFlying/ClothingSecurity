#import "MKPhotoEditorTabController.h"

#import <MediaEditorKit/LegacyComponentsContext.h>

@class MKPhotoEditor;
@class MKPhotoEditorPreviewView;

@interface MKPhotoPaintController : MKPhotoEditorTabController

- (instancetype)initWithContext:(id<LegacyComponentsContext>)context photoEditor:(MKPhotoEditor *)photoEditor previewView:(MKPhotoEditorPreviewView *)previewView;

- (MKPaintingData *)paintingData;

+ (CGRect)photoContainerFrameForParentViewFrame:(CGRect)parentViewFrame toolbarLandscapeSize:(CGFloat)toolbarLandscapeSize orientation:(UIInterfaceOrientation)orientation panelSize:(CGFloat)panelSize;

@end

extern const CGFloat TGPhotoPaintTopPanelSize;
extern const CGFloat TGPhotoPaintBottomPanelSize;

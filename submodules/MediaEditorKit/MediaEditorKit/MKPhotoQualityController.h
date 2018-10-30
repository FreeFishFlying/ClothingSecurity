#import "MKPhotoEditorTabController.h"

#import <MediaEditorKit/MKVideoEditAdjustments.h>

@class MKPhotoEditor;
@class MKPhotoEditorPreviewView;
@class MKPhotoEditorController;

@interface MKPhotoQualityController : MKPhotoEditorTabController

@property (nonatomic, readonly) TGMediaVideoConversionPreset preset;

- (instancetype)initWithContext:(id<LegacyComponentsContext>)context photoEditor:(MKPhotoEditor *)photoEditor previewView:(MKPhotoEditorPreviewView *)previewView;

@end

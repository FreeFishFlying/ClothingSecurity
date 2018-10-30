#import <MediaEditorKit/MKViewController.h>

#import "MKPhotoEditorItem.h"

@class MKPhotoEditor;
@class MKPhotoEditorPreviewView;

@interface MKPhotoEditorItemController : MKViewController

@property (nonatomic, copy) void(^editorItemUpdated)(void);
@property (nonatomic, copy) void(^beginTransitionIn)(void);
@property (nonatomic, copy) void(^beginTransitionOut)(void);
@property (nonatomic, copy) void(^finishedCombinedTransition)(void);

@property (nonatomic, assign) CGFloat toolbarLandscapeSize;
@property (nonatomic, assign) bool initialAppearance;
@property (nonatomic, assign) bool skipProcessingOnCompletion;

- (instancetype)initWithContext:(id<LegacyComponentsContext>)context editorItem:(id<MKPhotoEditorItem>)editorItem photoEditor:(MKPhotoEditor *)photoEditor previewView:(MKPhotoEditorPreviewView *)previewView;

- (void)attachPreviewView:(MKPhotoEditorPreviewView *)previewView;

- (void)prepareForCombinedAppearance;
- (void)finishedCombinedAppearance;

@end

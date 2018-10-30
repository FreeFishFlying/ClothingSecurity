#import <MediaEditorKit/MediaEditorKit.h>
#import <MediaEditorKit/MKMediaEditingContext.h>
#import <MediaEditorKit/MKPhotoToolbarView.h>
#import <MediaEditorKit/LegacyComponentsContext.h>

@class SSignal;
@class PGCameraShotMetadata;
@class MKPhotoEditorController;

typedef enum {
    MKPhotoEditorControllerGenericIntent = 0,
    MKPhotoEditorControllerVideoIntent = 1
} MKPhotoEditorControllerIntent;

@interface MKPhotoEditorController : MKOverlayController

@property (nonatomic, strong) MKMediaEditingContext *editingContext;

@property (nonatomic, copy) UIView *(^beginTransitionIn)(CGRect *referenceFrame, UIView **parentView);
@property (nonatomic, copy) void (^finishedTransitionIn)(void);
@property (nonatomic, copy) UIView *(^beginTransitionOut)(CGRect *referenceFrame, UIView **parentView);
@property (nonatomic, copy) void (^finishedTransitionOut)(bool saved);

@property (nonatomic, copy) void (^beginCustomTransitionOut)(CGRect, UIView *, void(^)(void));

@property (nonatomic, copy) SSignal *(^requestThumbnailImage)(id<TGMediaEditableItem> item);
@property (nonatomic, copy) SSignal *(^requestOriginalScreenSizeImage)(id<TGMediaEditableItem> item, NSTimeInterval position);
@property (nonatomic, copy) SSignal *(^requestOriginalFullSizeImage)(id<TGMediaEditableItem> item, NSTimeInterval position);
@property (nonatomic, copy) SSignal *(^requestMetadata)(id<TGMediaEditableItem> item);
@property (nonatomic, copy) id<MKMediaEditAdjustments> (^requestAdjustments)(id<TGMediaEditableItem> item);

@property (nonatomic, copy) UIImage *(^requestImage)(void);
@property (nonatomic, copy) void (^requestToolbarsHidden)(bool hidden, bool animated);

@property (nonatomic, copy) void (^captionSet)(NSString *caption);

@property (nonatomic, copy) void (^willFinishEditing)(id<MKMediaEditAdjustments> adjustments, id temporaryRep, bool hasChanges);
@property (nonatomic, copy) void (^didFinishRenderingFullSizeImage)(UIImage *fullSizeImage);
@property (nonatomic, copy) void (^didFinishEditing)(id<MKMediaEditAdjustments> adjustments, UIImage *resultImage, UIImage *thumbnailImage, bool hasChanges);

@property (nonatomic, assign) bool confirmDismiss;
@property (nonatomic, assign) bool skipInitialTransition;
@property (nonatomic, assign) bool dontHideStatusBar;
@property (nonatomic, strong) PGCameraShotMetadata *metadata;
@property (nonatomic, assign) CGFloat cropLockedAspectRatio;

- (instancetype)initWithAsset:(id<TGMediaEditableItem>)item intent:(MKPhotoEditorControllerIntent)intent adjustments:(id<MKMediaEditAdjustments>)adjustments caption:(NSString *)caption screenImage:(UIImage *)screenImage availableTabs:(MKPhotoEditorTab)availableTabs selectedTab:(MKPhotoEditorTab)selectedTab;

- (void)dismissEditor;
- (void)applyEditor;

- (void)setInfoString:(NSString *)string;

- (void)dismissAnimated:(bool)animated;

- (CGSize)referenceViewSize;

- (CGFloat)toolbarLandscapeSize;

- (void)setToolbarHidden:(bool)hidden animated:(bool)animated;


@end

#import <MediaEditorKit/MediaEditorKit.h>

#import <MediaEditorKit/MKPhotoEditorController.h>

@protocol MKMediaEditAdjustments;

@interface MKPhotoEditorTabController : MKViewController
{
    bool _dismissing;
    UIView *_transitionView;
}

@property (nonatomic, weak) id<TGMediaEditableItem> item;
@property (nonatomic, assign) MKPhotoEditorControllerIntent intent;
@property (nonatomic, assign) CGFloat toolbarLandscapeSize;
@property (nonatomic, assign) bool initialAppearance;
@property (nonatomic, assign) bool transitionInProgress;
@property (nonatomic, assign) bool transitionInPending;
@property (nonatomic, assign) CGFloat transitionSpeed;
@property (nonatomic, readonly) bool dismissing;

@property (nonatomic, copy) UIView *(^beginTransitionIn)(CGRect *referenceFrame, UIView **parentView, bool *noTransitionView);
@property (nonatomic, copy) void(^finishedTransitionIn)(void);
@property (nonatomic, copy) UIView *(^beginTransitionOut)(CGRect *referenceFrame, UIView **parentView);
@property (nonatomic, copy) void(^finishedTransitionOut)(void);

@property (nonatomic, copy) void (^beginItemTransitionIn)(void);
@property (nonatomic, copy) void (^beginItemTransitionOut)(void);

@property (nonatomic, copy) void (^valuesChanged)(void);

@property (nonatomic, copy) void (^tabsChanged)(void);

@property (nonatomic, assign) MKPhotoEditorTab availableTabs;

@property (nonatomic, assign) MKPhotoEditorTab switchingToTab;

- (void)transitionOutSwitching:(bool)switching completion:(void (^)(void))completion;
- (void)transitionOutSaving:(bool)saving completion:(void (^)(void))completion;

- (void)prepareTransitionInWithReferenceView:(UIView *)referenceView referenceFrame:(CGRect)referenceFrame parentView:(UIView *)parentView noTransitionView:(bool)noTransitionView;
- (void)prepareTransitionOutSaving:(bool)saving;

- (void)prepareForCustomTransitionOut;

- (void)animateTransitionIn;
- (CGRect)_targetFrameForTransitionInFromFrame:(CGRect)fromFrame;
- (void)_animatePreviewViewTransitionOutToFrame:(CGRect)toFrame saving:(bool)saving parentView:(UIView *)parentView completion:(void (^)(void))completion;
- (void)_finishedTransitionInWithView:(UIView *)transitionView;

- (CGRect)transitionOutReferenceFrame;
- (UIView *)transitionOutReferenceView;
- (CGRect)transitionOutSourceFrameForReferenceFrame:(CGRect)referenceFrame orientation:(UIInterfaceOrientation)orientation;

- (CGSize)referenceViewSize;

- (UIView *)snapshotView;

- (id)currentResultRepresentation;

- (void)handleTabAction:(MKPhotoEditorTab)tab;

- (bool)isDismissAllowed;

- (void)_updateTabs;
- (MKPhotoEditorTab)activeTab;
- (MKPhotoEditorTab)highlightedTabs;

+ (CGRect)photoContainerFrameForParentViewFrame:(CGRect)parentViewFrame toolbarLandscapeSize:(CGFloat)toolbarLandscapeSize orientation:(UIInterfaceOrientation)orientation panelSize:(CGFloat)panelSize;

+ (MKPhotoEditorTab)highlightedButtonsForEditorValues:(id<MKMediaEditAdjustments>)editorValues forAvatar:(bool)forAvatar;

@end

extern const CGFloat TGPhotoEditorPanelSize;
extern const CGFloat TGPhotoEditorToolbarSize;

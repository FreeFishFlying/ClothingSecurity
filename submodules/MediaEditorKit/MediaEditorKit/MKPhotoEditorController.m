#import "MKPhotoEditorController.h"

#import "LegacyComponentsInternal.h"

#import <objc/runtime.h>

#import <MediaEditorKit/ASWatcher.h>

#import <Photos/Photos.h>

#import <MediaEditorKit/MKPhotoEditorAnimation.h>
#import "MKPhotoEditorInterfaceAssets.h"
#import <MediaEditorKit/MKPhotoEditorUtils.h>
#import <MediaEditorKit/TGPaintUtils.h>

#import <MediaEditorKit/UIImage+TG.h>

#import "MKProgressWindow.h"

#import "MKPhotoEditor.h"

#import <MediaEditorKit/MKPhotoEditorValues.h>
#import <MediaEditorKit/MKVideoEditAdjustments.h>
#import <MediaEditorKit/MKPaintingData.h>
#import <MediaEditorKit/MKMediaVideoConverter.h>

#import "MKPhotoToolbarView.h"
#import "MKPhotoEditorPreviewView.h"
#import "SSignal+Mapping.h"
#import "SSignal+Single.h"
#import <MediaEditorKit/TGMenuView.h>

#import <MediaEditorKit/TGMediaAssetsLibrary.h>
#import <MediaEditorKit/TGMediaAssetImageSignals.h>
#import "SSignal+SideEffects.h"
#import "MKPhotoPaintController.h"
#import "MKPhotoQualityController.h"
#import "MKPhotoEditorItemController.h"
#import "TGMessageImageViewOverlayView.h"
#import "MKPhotoCropController.h"
#import <MediaEditorKit/AVURLAsset+TGMediaItem.h>

@interface MKPhotoEditorController () <ASWatcher, TGViewControllerNavigationBarAppearance, UIDocumentInteractionControllerDelegate>
{
    bool _switchingTab;
    MKPhotoEditorTab _availableTabs;
    MKPhotoEditorTab _currentTab;
    MKPhotoEditorTabController *_currentTabController;
    
    UIView *_backgroundView;
    UIView *_containerView;
    UIView *_wrapperView;
    UIView *_transitionWrapperView;
    MKPhotoToolbarView *_portraitToolbarView;
    MKPhotoToolbarView *_landscapeToolbarView;
    MKPhotoEditorPreviewView *_previewView;
    
    MKPhotoEditor *_photoEditor;
    
    SQueue *_queue;
    MKPhotoEditorControllerIntent _intent;
    id<TGMediaEditableItem> _item;
    UIImage *_screenImage;
    UIImage *_thumbnailImage;
    
    id<MKMediaEditAdjustments> _initialAdjustments;
    NSString *_caption;
    
    bool _viewFillingWholeScreen;
    bool _forceStatusBarVisible;
    
    bool _ignoreDefaultPreviewViewTransitionIn;
    bool _hasOpenedPhotoTools;
    bool _hiddenToolbarView;
    
    TGMenuContainerView *_menuContainerView;
    UIDocumentInteractionController *_documentController;
    
    bool _progressVisible;
    TGMessageImageViewOverlayView *_progressView;
    
    id<LegacyComponentsContext> _context;
}

@property (nonatomic, weak) UIImage *fullSizeImage;

@end

@implementation MKPhotoEditorController

@synthesize actionHandle = _actionHandle;

- (instancetype)initWithAsset:(id<TGMediaEditableItem>)item intent:(MKPhotoEditorControllerIntent)intent adjustments:(id<MKMediaEditAdjustments>)adjustments caption:(NSString *)caption screenImage:(UIImage *)screenImage availableTabs:(MKPhotoEditorTab)availableTabs selectedTab:(MKPhotoEditorTab)selectedTab
{
    self = [super initWithContext:[MKLegacyComponentsContext shared]];
    if (self != nil)
    {
        _context = [MKLegacyComponentsContext shared];
        _actionHandle = [[ASHandle alloc] initWithDelegate:self releaseOnMainThread:true];
    
        self.autoManageStatusBarBackground = false;
        self.isImportant = true;
        
        _availableTabs = availableTabs;

        _item = item;
        _currentTab = selectedTab;
        _intent = intent;
        
        _caption = caption;
        _initialAdjustments = adjustments;
        _screenImage = screenImage;
        _confirmDismiss = true;
        _queue = [[SQueue alloc] init];
        _photoEditor = [[MKPhotoEditor alloc] initWithOriginalSize:_item.originalSize adjustments:adjustments forVideo:(intent == MKPhotoEditorControllerVideoIntent)];
        
        if (self.cropLockedAspectRatio > 0) {
            _photoEditor.cropLockedAspectRatio = self.cropLockedAspectRatio;
        }
                
        if ([adjustments isKindOfClass:[MKVideoEditAdjustments class]])
        {
            MKVideoEditAdjustments *videoAdjustments = (MKVideoEditAdjustments *)adjustments;
            _photoEditor.trimStartValue = videoAdjustments.trimStartValue;
            _photoEditor.trimEndValue = videoAdjustments.trimEndValue;
        }
        
        self.customAppearanceMethodsForwarding = true;
    }
    return self;
}

- (void)setCropLockedAspectRatio:(CGFloat)cropLockedAspectRatio {
    _cropLockedAspectRatio = cropLockedAspectRatio;
    _photoEditor.cropLockedAspectRatio = _cropLockedAspectRatio;
}

- (void)dealloc
{
    [_actionHandle reset];
}

- (void)loadView
{
    [super loadView];
    
    self.view.frame = (CGRect){ CGPointZero, [self referenceViewSize]};
    self.view.clipsToBounds = true;
    
    if (@available(iOS 11.0, *)) {
        self.view.accessibilityIgnoresInvertColors = true;
    }
    
    _wrapperView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_wrapperView];
    
    _backgroundView = [[UIView alloc] initWithFrame:_wrapperView.bounds];
    _backgroundView.alpha = 0.0f;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.backgroundColor = [MKPhotoEditorInterfaceAssets toolbarBackgroundColor];
    [_wrapperView addSubview:_backgroundView];
    
    _transitionWrapperView = [[UIView alloc] initWithFrame:_wrapperView.bounds];
    [_wrapperView addSubview:_transitionWrapperView];
    
    _containerView = [[UIView alloc] initWithFrame:CGRectZero];
    [_wrapperView addSubview:_containerView];
    
    __weak MKPhotoEditorController *weakSelf = self;
    
    void(^toolbarCancelPressed)(void) = ^
    {
        __strong MKPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf cancelButtonPressed];
    };
    
    void(^toolbarDonePressed)(void) = ^
    {
        __strong MKPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf doneButtonPressed];
    };
    
    void(^toolbarDoneLongPressed)(id) = ^(id sender)
    {
        __strong MKPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf doneButtonLongPressed:sender];
    };
    
    void(^toolbarTabPressed)(MKPhotoEditorTab) = ^(MKPhotoEditorTab tab)
    {
        __strong MKPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        switch (tab)
        {
            default:
                [strongSelf presentEditorTab:tab];
                break;
            case MKPhotoEditorPaintTab:
            case MKPhotoEditorEraserTab:
                if ([strongSelf->_currentTabController isKindOfClass:[MKPhotoPaintController class]])
                    [strongSelf->_currentTabController handleTabAction:tab];
                else
                    [strongSelf presentEditorTab:MKPhotoEditorPaintTab];
                break;
                
            case MKPhotoEditorTextTab:
                [strongSelf->_currentTabController handleTabAction:tab];
                break;
                
            case MKPhotoEditorRotateTab:
            case MKPhotoEditorMirrorTab:
            case MKPhotoEditorAspectRatioTab:
                if ([strongSelf->_currentTabController isKindOfClass:[MKPhotoCropController class]])
                    [strongSelf->_currentTabController handleTabAction:tab];
                break;
        }
    };
    
    
    MKPhotoEditorBackButton backButton = MKPhotoEditorBackButtonCancel;
    MKPhotoEditorDoneButton doneButton = MKPhotoEditorDoneButtonCheck;
    _portraitToolbarView = [[MKPhotoToolbarView alloc] initWithBackButton:backButton doneButton:doneButton solidBackground:true];
    [_portraitToolbarView setToolbarTabs:_availableTabs animated:false];
    [_portraitToolbarView setActiveTab:_currentTab];
    _portraitToolbarView.cancelPressed = toolbarCancelPressed;
    _portraitToolbarView.donePressed = toolbarDonePressed;
    _portraitToolbarView.doneLongPressed = toolbarDoneLongPressed;
    _portraitToolbarView.tabPressed = toolbarTabPressed;
    [_wrapperView addSubview:_portraitToolbarView];
    
    _landscapeToolbarView = [[MKPhotoToolbarView alloc] initWithBackButton:backButton doneButton:doneButton solidBackground:true];
    [_landscapeToolbarView setToolbarTabs:_availableTabs animated:false];
    [_landscapeToolbarView setActiveTab:_currentTab];
    _landscapeToolbarView.cancelPressed = toolbarCancelPressed;
    _landscapeToolbarView.donePressed = toolbarDonePressed;
    _landscapeToolbarView.doneLongPressed = toolbarDoneLongPressed;
    _landscapeToolbarView.tabPressed = toolbarTabPressed;
    
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
        [_wrapperView addSubview:_landscapeToolbarView];

    
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        orientation = UIInterfaceOrientationPortrait;
    
    CGRect containerFrame = [MKPhotoEditorTabController photoContainerFrameForParentViewFrame:self.view.frame toolbarLandscapeSize:TGPhotoEditorToolbarSize orientation:orientation panelSize:TGPhotoEditorPanelSize];
    CGSize fittedSize = TGScaleToSize(_photoEditor.rotatedCropSize, containerFrame.size);
    
    _previewView = [[MKPhotoEditorPreviewView alloc] initWithFrame:CGRectMake(0, 0, fittedSize.width, fittedSize.height)];
    _previewView.clipsToBounds = true;
    [_previewView setSnapshotImage:_screenImage];
    [_photoEditor setPreviewOutput:_previewView];
    [self updatePreviewView];
    
    [self presentEditorTab:_currentTab];
}

- (void)setToolbarHidden:(bool)hidden animated:(bool)animated
{
    if (self.requestToolbarsHidden == nil)
        return;
    
    if (_hiddenToolbarView == hidden)
        return;
    
    if (hidden)
    {
        [_portraitToolbarView transitionOutAnimated:animated transparent:true hideOnCompletion:false];
        [_landscapeToolbarView transitionOutAnimated:animated transparent:true hideOnCompletion:false];
    }
    else
    {
        [_portraitToolbarView transitionInAnimated:animated transparent:true];
        [_landscapeToolbarView transitionInAnimated:animated transparent:true];
    }
    
    self.requestToolbarsHidden(hidden, animated);
    _hiddenToolbarView = hidden;
}

- (BOOL)prefersStatusBarHidden
{
    if (_forceStatusBarVisible)
        return false;
    
    if ([self inFormSheet])
        return false;
    
    if (self.navigationController != nil)
        return _viewFillingWholeScreen;
    
    if (self.dontHideStatusBar)
        return false;
    
    return true;
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return [_currentTabController preferredScreenEdgesDeferringSystemGestures];
}

- (UIBarStyle)requiredNavigationBarStyle
{
    return UIBarStyleDefault;
}

- (bool)navigationBarShouldBeHidden
{
    return true;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([_currentTabController isKindOfClass:[MKPhotoCropController class]])
        return;
    
    NSTimeInterval position = 0;
    TGMediaVideoEditAdjustments *adjustments = [_photoEditor exportAdjustments];
    if ([adjustments isKindOfClass:[TGMediaVideoEditAdjustments class]])
        position = adjustments.trimStartValue;
    
    CGSize screenSize = TGNativeScreenSize();
    SSignal *signal = nil;
    if ([_photoEditor hasDefaultCropping] && (NSInteger)screenSize.width == 320)
    {
        signal = [self.requestOriginalScreenSizeImage(_item, position) filter:^bool(id image)
        {
            return [image isKindOfClass:[UIImage class]];
        }];
    }
    else
    {
        signal = [[[[self.requestOriginalFullSizeImage(_item, position) takeLast] deliverOn:_queue] filter:^bool(id image)
        {
            return [image isKindOfClass:[UIImage class]];
        }] map:^UIImage *(UIImage *image)
        {
            return TGPhotoEditorCrop(image, nil, _photoEditor.cropOrientation, _photoEditor.cropRotation, _photoEditor.cropRect, _photoEditor.cropMirrored, TGPhotoEditorScreenImageMaxSize(), _photoEditor.originalSize, true);
        }];
    }
    
    [signal startWithNext:^(UIImage *next)
    {
        [_photoEditor setImage:next forCropRect:_photoEditor.cropRect cropRotation:_photoEditor.cropRotation cropOrientation:_photoEditor.cropOrientation cropMirrored:_photoEditor.cropMirrored fullSize:false];
        
        if (_ignoreDefaultPreviewViewTransitionIn)
        {
            TGDispatchOnMainThread(^
            {
                if ([_currentTabController isKindOfClass:[MKPhotoQualityController class]])
                    [_previewView setSnapshotImageOnTransition:next];
                else
                    [_previewView setSnapshotImage:next];
            });
        }
        else
        {
            [_photoEditor processAnimated:false completion:^
            {
                TGDispatchOnMainThread(^
                {
                    [_previewView performTransitionInWithCompletion:^
                    {
                        [_previewView setSnapshotImage:next];
                    }];
                });
            }];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![self inFormSheet] && (self.navigationController != nil || self.dontHideStatusBar))
    {
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                [_context setApplicationStatusBarAlpha:0.0f];
            }];
        }
        else
        {
            [_context setApplicationStatusBarAlpha:0.0f];
        }
    }
    else if (!self.dontHideStatusBar)
    {
        if (iosMajorVersion() < 7) {
            [_context forceSetStatusBarHidden:true withAnimation:UIStatusBarAnimationNone];
        }
    }
    
    [super viewWillAppear:animated];

    [self transitionIn];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.navigationController != nil)
    {
        _viewFillingWholeScreen = true;

        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
            [self setNeedsStatusBarAppearanceUpdate];
        else
            [_context forceSetStatusBarHidden:[self prefersStatusBarHidden] withAnimation:UIStatusBarAnimationNone];
    }
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.navigationController != nil || self.dontHideStatusBar)
    {
        _viewFillingWholeScreen = false;
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
            [self setNeedsStatusBarAppearanceUpdate];
        else
            [_context forceSetStatusBarHidden:[self prefersStatusBarHidden] withAnimation:UIStatusBarAnimationNone];
        
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                [_context setApplicationStatusBarAlpha:1.0f];
            }];
        }
        else
        {
            [_context setApplicationStatusBarAlpha:1.0f];
        }
    }
    
    if ([self respondsToSelector:@selector(setNeedsUpdateOfScreenEdgesDeferringSystemGestures)])
        [self setNeedsUpdateOfScreenEdgesDeferringSystemGestures];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //strange ios6 crashfix
    if (iosMajorVersion() < 7 && !self.dontHideStatusBar)
    {
        TGDispatchAfter(0.5f, dispatch_get_main_queue(), ^
        {
            [_context forceSetStatusBarHidden:false withAnimation:UIStatusBarAnimationNone];
        });
    }
}

- (void)updateDoneButtonEnabled:(bool)enabled animated:(bool)animated
{
    [_portraitToolbarView setEditButtonsEnabled:enabled animated:animated];
    [_landscapeToolbarView setEditButtonsEnabled:enabled animated:animated];
    
    [_portraitToolbarView setDoneButtonEnabled:enabled animated:animated];
    [_landscapeToolbarView setDoneButtonEnabled:enabled animated:animated];
}

- (void)updateStatusBarAppearanceForDismiss
{
    _forceStatusBarVisible = true;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
        [self setNeedsStatusBarAppearanceUpdate];
    else
        [_context forceSetStatusBarHidden:[self prefersStatusBarHidden] withAnimation:UIStatusBarAnimationNone];
}

- (BOOL)shouldAutorotate
{
    return (!(_currentTabController != nil && ![_currentTabController shouldAutorotate]) && [super shouldAutorotate]);
}

#pragma mark - 

- (void)createEditedImageWithEditorValues:(MKPhotoEditorValues *)editorValues createThumbnail:(bool)createThumbnail saveOnly:(bool)saveOnly completion:(void (^)(UIImage *))completion
{
    if (!saveOnly)
    {
        if ([editorValues isDefaultValuesForAvatar:false])
        {
            if (self.willFinishEditing != nil)
                self.willFinishEditing(nil, [_currentTabController currentResultRepresentation], true);
            
            if (self.didFinishEditing != nil)
                self.didFinishEditing(nil, nil, nil, true);

            if (completion != nil)
                completion(nil);
            
            return;
        }
    }
    
    if (!saveOnly && self.willFinishEditing != nil)
        self.willFinishEditing(editorValues, [_currentTabController currentResultRepresentation], true);
    
    if (!saveOnly && completion != nil)
        completion(nil);
    
    UIImage *fullSizeImage = self.fullSizeImage;
    MKPhotoEditor *photoEditor = _photoEditor;
    
    SSignal *imageSignal = nil;
    if (fullSizeImage == nil)
    {
        imageSignal = [[self.requestOriginalFullSizeImage(_item, 0) filter:^bool(id result)
        {
            return [result isKindOfClass:[UIImage class]];
        }] takeLast];
    }
    else
    {
        imageSignal = [SSignal single:fullSizeImage];
    }
    
    bool hasImageAdjustments = editorValues.toolsApplied || saveOnly;
    bool hasPainting = editorValues.hasPainting;
    
    SSignal *(^imageCropSignal)(UIImage *, bool) = ^(UIImage *image, bool resize)
    {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            UIImage *paintingImage = !hasImageAdjustments ? editorValues.paintingData.image : nil;
            UIImage *croppedImage = TGPhotoEditorCrop(image, paintingImage, photoEditor.cropOrientation, photoEditor.cropRotation, photoEditor.cropRect, photoEditor.cropMirrored, TGPhotoEditorResultImageMaxSize, photoEditor.originalSize, resize);
            [subscriber putNext:croppedImage];
            [subscriber putCompletion];
            
            return nil;
        }];
    };
    
    SSignal *(^imageRenderSignal)(UIImage *) = ^(UIImage *image)
    {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
        {
            [photoEditor setImage:image forCropRect:photoEditor.cropRect cropRotation:photoEditor.cropRotation cropOrientation:photoEditor.cropOrientation cropMirrored:photoEditor.cropMirrored fullSize:true];
            [photoEditor createResultImageWithCompletion:^(UIImage *result)
            {
                if (hasPainting)
                {
                    result = TGPaintCombineCroppedImages(result, editorValues.paintingData.image, true, photoEditor.originalSize, photoEditor.cropRect, photoEditor.cropOrientation, photoEditor.cropRotation, photoEditor.cropMirrored);
                    [MKPaintingData facilitatePaintingData:editorValues.paintingData];
                }
                
                [subscriber putNext:result];
                [subscriber putCompletion];
            }];
            
            return nil;
        }];
    };

    SSignal *renderedImageSignal = [[imageSignal mapToSignal:^SSignal *(UIImage *image)
    {
        return [imageCropSignal(image, !hasImageAdjustments || hasPainting) startOn:_queue];
    }] mapToSignal:^SSignal *(UIImage *image)
    {
        if (hasImageAdjustments)
            return [[[SSignal complete] delay:0.3 onQueue:_queue] then:imageRenderSignal(image)];
        else
            return [SSignal single:image];
    }];
    
    if (saveOnly)
    {
        [[renderedImageSignal deliverOn:[SQueue mainQueue]] startWithNext:^(UIImage *image)
        {
            if (completion != nil)
                completion(image);
        }];
    }
    else
    {
        [[[[renderedImageSignal map:^id(UIImage *image)
        {
            if (!hasImageAdjustments)
            {
                if (hasPainting && self.didFinishRenderingFullSizeImage != nil)
                    self.didFinishRenderingFullSizeImage(image);

                return image;
            }
            else
            {
                if (!saveOnly && self.didFinishRenderingFullSizeImage != nil)
                    self.didFinishRenderingFullSizeImage(image);
                
                return TGPhotoEditorFitImage(image, TGPhotoEditorResultImageMaxSize);
            }
        }] map:^NSDictionary *(UIImage *image)
        {
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            if (image != nil)
                result[@"image"] = image;
            
            if (createThumbnail)
            {
                CGSize fillSize = TGPhotoThumbnailSizeForCurrentScreen();
                fillSize.width = CGCeil(fillSize.width);
                fillSize.height = CGCeil(fillSize.height);
                
                CGSize size = TGScaleToFillSize(image.size, fillSize);
                
                UIGraphicsBeginImageContextWithOptions(size, true, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetInterpolationQuality(context, kCGInterpolationMedium);
                
                [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
                
                UIImage *thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                if (thumbnailImage != nil)
                    result[@"thumbnail"] = thumbnailImage;
            }
            
            return result;
        }] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *result)
        {
            UIImage *image = result[@"image"];
            UIImage *thumbnailImage = result[@"thumbnail"];
            
            if (!saveOnly && self.didFinishEditing != nil)
                self.didFinishEditing(editorValues, image, thumbnailImage, true);
        } error:^(__unused id error)
        {
            TGLegacyLog(@"renderedImageSignal error");
        } completed:nil];
    }
}
#pragma mark - Transition

- (void)transitionIn
{
    if (self.navigationController != nil)
        return;
    
    CGFloat delay = 0;
    
    _portraitToolbarView.alpha = 0.0f;
    _landscapeToolbarView.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f delay:delay options:UIViewAnimationOptionCurveLinear animations:^
    {
        _portraitToolbarView.alpha = 1.0f;
        _landscapeToolbarView.alpha = 1.0f;
    } completion:nil];
}

- (void)transitionOutSaving:(bool)saving completion:(void (^)(void))completion
{
    [UIView animateWithDuration:0.3f animations:^
    {
        _portraitToolbarView.alpha = 0.0f;
        _landscapeToolbarView.alpha = 0.0f;
    }];
    
    _currentTabController.beginTransitionOut = self.beginTransitionOut;
    [self setToolbarHidden:false animated:true];
    
    if (self.skipInitialTransition) {
        if (completion != nil)
            completion();
        
        if (self.finishedTransitionOut != nil)
            self.finishedTransitionOut(saving);
    } else if (self.beginCustomTransitionOut != nil)
    {
        id rep = [_currentTabController currentResultRepresentation];
        if ([rep isKindOfClass:[UIImage class]])
        {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:(UIImage *)rep];
            rep = imageView;
        }
        [_currentTabController prepareForCustomTransitionOut];
        self.beginCustomTransitionOut([_currentTabController transitionOutReferenceFrame], rep, completion);
    }
    else
    {
        [_currentTabController transitionOutSaving:saving completion:^
        {
            if (completion != nil)
                completion();
            
            if (self.finishedTransitionOut != nil)
                self.finishedTransitionOut(saving);
        }];
    }
}

- (void)presentEditorTab:(MKPhotoEditorTab)tab
{    
    if (_switchingTab || (tab == _currentTab && _currentTabController != nil))
        return;
    
    bool isInitialAppearance = true;

    CGRect transitionReferenceFrame = CGRectZero;
    UIView *transitionReferenceView = nil;
    UIView *transitionParentView = nil;
    bool transitionNoTransitionView = false;
    
    UIImage *snapshotImage = nil;
    UIView *snapshotView = nil;
    
    MKPhotoEditorTabController *currentController = _currentTabController;
    if (currentController != nil)
    {
        if (![currentController isDismissAllowed])
            return;
        
        transitionReferenceFrame = [currentController transitionOutReferenceFrame];
        transitionReferenceView = [currentController transitionOutReferenceView];
        transitionNoTransitionView = false;
        
        currentController.switchingToTab = tab;
        [currentController transitionOutSwitching:true completion:^
        {
            [currentController removeFromParentViewController];
            [currentController.view removeFromSuperview];
        }];
        
        if ([currentController isKindOfClass:[MKPhotoCropController class]])
        {
            _backgroundView.alpha = 1.0f;
            [UIView animateWithDuration:0.3f animations:^
            {
                _backgroundView.alpha = 0.0f;
            } completion:nil];
        }
        
        isInitialAppearance = false;
        
        snapshotView = [currentController snapshotView];
    }
    else
    {
        if (self.beginTransitionIn != nil)
            transitionReferenceView = self.beginTransitionIn(&transitionReferenceFrame, &transitionParentView);
        
        snapshotImage = _screenImage;
    }
    
    _switchingTab = true;
    
    __weak MKPhotoEditorController *weakSelf = self;
    MKPhotoEditorTabController *controller = nil;
    switch (tab)
    {
        case MKPhotoEditorPaintTab:
        {
            MKPhotoPaintController *paintController = [[MKPhotoPaintController alloc] initWithContext:_context photoEditor:_photoEditor previewView:_previewView];
            paintController.toolbarLandscapeSize = TGPhotoEditorToolbarSize;
            
            paintController.beginTransitionIn = ^UIView *(CGRect *referenceFrame, UIView **parentView, bool *noTransitionView)
            {
                __strong MKPhotoEditorController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return nil;
                
                *referenceFrame = transitionReferenceFrame;
                *parentView = transitionParentView;
                *noTransitionView = transitionNoTransitionView;
                
                return transitionReferenceView;
            };
            paintController.finishedTransitionIn = ^
            {
                __strong MKPhotoEditorController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                if (isInitialAppearance && strongSelf.finishedTransitionIn != nil)
                    strongSelf.finishedTransitionIn();
                
                strongSelf->_switchingTab = false;
            };
            
            controller = paintController;
        }
            break;
                        
        case MKPhotoEditorCropTab:
        {
            __block UIView *initialBackgroundView = nil;
            {
                MKPhotoCropController *cropController = [[MKPhotoCropController alloc] initWithContext:_context photoEditor:_photoEditor
                                                                                               previewView:_previewView
                                                                                                  forVideo:(_intent == MKPhotoEditorControllerVideoIntent)];
                cropController.skipTransitionIn = self.skipInitialTransition;
                if (snapshotView != nil)
                    [cropController setSnapshotView:snapshotView];
                else if (snapshotImage != nil)
                    [cropController setSnapshotImage:snapshotImage];
                cropController.toolbarLandscapeSize = TGPhotoEditorToolbarSize;
                cropController.beginTransitionIn = ^UIView *(CGRect *referenceFrame, UIView **parentView, bool *noTransitionView)
                {
                    *referenceFrame = transitionReferenceFrame;
                    *noTransitionView = transitionNoTransitionView;
                    *parentView = transitionParentView;
                    
                    __strong MKPhotoEditorController *strongSelf = weakSelf;
                    if (strongSelf != nil)
                    {
                        UIView *backgroundView = nil;
                        if (isInitialAppearance)
                        {
                            UIView *backgroundSuperview = transitionParentView;
                            if (backgroundSuperview == nil)
                                backgroundSuperview = transitionReferenceView.superview.superview;
                            
                            initialBackgroundView = [[UIView alloc] initWithFrame:backgroundSuperview.bounds];
                            initialBackgroundView.alpha = 0.0f;
                            initialBackgroundView.backgroundColor = [MKPhotoEditorInterfaceAssets toolbarBackgroundColor];
                            [backgroundSuperview addSubview:initialBackgroundView];
                            backgroundView = initialBackgroundView;
                        }
                        else
                        {
                            backgroundView = strongSelf->_backgroundView;
                        }
                        
                        [UIView animateWithDuration:0.3f animations:^
                        {
                            backgroundView.alpha = 1.0f;
                        }];
                    }
                    
                    return transitionReferenceView;
                };
                cropController.finishedTransitionIn = ^
                {
                    __strong MKPhotoEditorController *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;
                    
                    if (isInitialAppearance)
                    {
                        [initialBackgroundView removeFromSuperview];
                        if (strongSelf.finishedTransitionIn != nil)
                            strongSelf.finishedTransitionIn();
                    }
                    else
                    {
                        strongSelf->_backgroundView.alpha = 0.0f;
                    }
                    strongSelf->_switchingTab = false;
                };
                cropController.cropReset = ^
                {
                    __strong MKPhotoEditorController *strongSelf = weakSelf;
                    if (strongSelf == nil)
                        return;
                    
                    [strongSelf reset];
                };
                
                if (_intent != MKPhotoEditorControllerVideoIntent)
                {
                    [[self.requestOriginalFullSizeImage(_item, 0) deliverOn:[SQueue mainQueue]] startWithNext:^(UIImage *image)
                    {
                        if (cropController.dismissing && !cropController.switching)
                            return;
                        
                        if (![image isKindOfClass:[UIImage class]] || image.degraded)
                            return;
                        
                        self.fullSizeImage = image;
                        [cropController setImage:image];
                    }];
                }
                else if (self.requestImage != nil)
                {
                    UIImage *image = self.requestImage();
                    [cropController setImage:image];
                }
                
                controller = cropController;
            }
        }
            break;
            
        case MKPhotoEditorQualityTab:
        {
            _ignoreDefaultPreviewViewTransitionIn = true;
            
            MKPhotoQualityController *qualityController = [[MKPhotoQualityController alloc] initWithContext:_context photoEditor:_photoEditor previewView:_previewView];
            qualityController.item = _item;
            qualityController.toolbarLandscapeSize = TGPhotoEditorToolbarSize;
            qualityController.beginTransitionIn = ^UIView *(CGRect *referenceFrame, UIView **parentView, bool *noTransitionView)
            {
                *referenceFrame = transitionReferenceFrame;
                *parentView = transitionParentView;
                *noTransitionView = transitionNoTransitionView;
                
                return transitionReferenceView;
            };
            qualityController.finishedTransitionIn = ^
            {
                __strong MKPhotoEditorController *strongSelf = weakSelf;
                if (strongSelf == nil)
                    return;
                
                if (isInitialAppearance && strongSelf.finishedTransitionIn != nil)
                    strongSelf.finishedTransitionIn();
                
                strongSelf->_switchingTab = false;
                strongSelf->_ignoreDefaultPreviewViewTransitionIn = false;
            };

            controller = qualityController;
        }
            break;
            
        default:
            break;
    }
    
    _currentTabController = controller;
    _currentTabController.item = _item;
    _currentTabController.intent = _intent;
    _currentTabController.initialAppearance = isInitialAppearance;
    
    if (![_currentTabController isKindOfClass:[MKPhotoPaintController class]])
        _currentTabController.availableTabs = _availableTabs;
    
    [self addChildViewController:_currentTabController];
    [_containerView addSubview:_currentTabController.view];

    _currentTabController.view.frame = _containerView.bounds;
    
    _currentTabController.beginItemTransitionIn = ^
    {
        __strong MKPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        UIInterfaceOrientation orientation = strongSelf.interfaceOrientation;
        if ([strongSelf inFormSheet])
            orientation = UIInterfaceOrientationPortrait;
        
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            [strongSelf->_portraitToolbarView transitionOutAnimated:true];
            [strongSelf->_landscapeToolbarView transitionOutAnimated:false];
        }
        else
        {
            [strongSelf->_portraitToolbarView transitionOutAnimated:false];
            [strongSelf->_landscapeToolbarView transitionOutAnimated:true];
        }
    };
    _currentTabController.beginItemTransitionOut = ^
    {
        __strong MKPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        UIInterfaceOrientation orientation = strongSelf.interfaceOrientation;
        if ([strongSelf inFormSheet])
            orientation = UIInterfaceOrientationPortrait;
        
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            [strongSelf->_portraitToolbarView transitionInAnimated:true];
            [strongSelf->_landscapeToolbarView transitionInAnimated:false];
        }
        else
        {
            [strongSelf->_portraitToolbarView transitionInAnimated:false];
            [strongSelf->_landscapeToolbarView transitionInAnimated:true];
        }
    };
    _currentTabController.valuesChanged = ^
    {
        __strong MKPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf updatePreviewView];        
    };
    _currentTabController.tabsChanged = ^
    {
        __strong MKPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf updateEditorButtons];
    };
    
    _currentTab = tab;
    
    [_portraitToolbarView setToolbarTabs:[_currentTabController availableTabs] animated:true];
    [_landscapeToolbarView setToolbarTabs:[_currentTabController availableTabs] animated:true];
    
    [self updateEditorButtons];
    
    if ([self respondsToSelector:@selector(setNeedsUpdateOfScreenEdgesDeferringSystemGestures)])
        [self setNeedsUpdateOfScreenEdgesDeferringSystemGestures];
}

- (void)updatePreviewView
{
    [_previewView setPaintingImageWithData:_photoEditor.paintingData];
    [_previewView setCropRect:_photoEditor.cropRect cropOrientation:_photoEditor.cropOrientation cropRotation:_photoEditor.cropRotation cropMirrored:_photoEditor.cropMirrored originalSize:_photoEditor.originalSize];
}

- (void)updateEditorButtons
{
    MKPhotoEditorTab activeTab = MKPhotoEditorNoneTab;
    activeTab = [_currentTabController activeTab];
    [_portraitToolbarView setActiveTab:activeTab];
    [_landscapeToolbarView setActiveTab:activeTab];
    
    MKPhotoEditorTab highlightedTabs = MKPhotoEditorNoneTab;
    highlightedTabs = [_currentTabController highlightedTabs];
    [_portraitToolbarView setEditButtonsHighlighted:highlightedTabs];
    [_landscapeToolbarView setEditButtonsHighlighted:highlightedTabs];
}

#pragma mark - Crop

- (void)reset
{
    if (_intent != MKPhotoEditorControllerVideoIntent)
        return;
    
    MKPhotoCropController *cropController = (MKPhotoCropController *)_currentTabController;
    if (![cropController isKindOfClass:[MKPhotoCropController class]])
        return;
}
#pragma mark -

- (void)dismissAnimated:(bool)animated
{
    self.view.userInteractionEnabled = false;
    
    if (animated)
    {
        const CGFloat velocity = 2000.0f;
        CGFloat duration = self.view.frame.size.height / velocity;
        CGRect targetFrame = CGRectOffset(self.view.frame, 0, self.view.frame.size.height);
        
        [UIView animateWithDuration:duration animations:^
        {
            self.view.frame = targetFrame;
        } completion:^(__unused BOOL finished)
        {
            [self dismiss];
        }];
    }
    else
    {
        [self dismiss];
    }
}

- (void)cancelButtonPressed
{
    [self dismissEditor];
}

- (void)dismissEditor
{
    if (![_currentTabController isDismissAllowed])
        return;
 
    __weak MKPhotoEditorController *weakSelf = self;
    void(^dismiss)(void) = ^
    {
        __strong MKPhotoEditorController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        strongSelf.view.userInteractionEnabled = false;
        [strongSelf->_currentTabController prepareTransitionOutSaving:false];
        if (self.presentingViewController) {
            [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
        } else if (strongSelf.navigationController != nil && [strongSelf.navigationController.viewControllers containsObject:strongSelf]) {
            [strongSelf.navigationController popViewControllerAnimated:true];
        } else {
            [strongSelf transitionOutSaving:false completion:^
            {
                [strongSelf dismiss];
            }];
        }
        
        if (strongSelf.willFinishEditing != nil)
            strongSelf.willFinishEditing(nil, nil, false);
        
        if (strongSelf.didFinishEditing != nil)
            strongSelf.didFinishEditing(nil, nil, nil, false);
    };
    
    MKPaintingData *paintingData = nil;
    if ([_currentTabController isKindOfClass:[MKPhotoPaintController class]])
        paintingData = [(MKPhotoPaintController *)_currentTabController paintingData];
    
    MKPhotoEditorValues *editorValues = paintingData == nil ? [_photoEditor exportAdjustments] : [_photoEditor exportAdjustmentsWithPaintingData:paintingData];
    
    if (self.confirmDismiss && ((_initialAdjustments == nil && (editorValues.cropOrientation != UIImageOrientationUp)) || (_initialAdjustments != nil && ![editorValues isEqual:_initialAdjustments])))
    {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"放弃修改" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dismiss();
        }]];
        [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        controller.popoverPresentationController.sourceView = self.view;
        controller.popoverPresentationController.sourceRect = [self.view convertRect:_landscapeToolbarView.cancelButtonFrame fromView:_landscapeToolbarView];
        [self presentViewController:controller animated:true completion:nil];
    }
    else
    {
        dismiss();
    }
}

- (void)doneButtonPressed
{
    [self applyEditor];
}

- (void)applyEditor
{
    if (![_currentTabController isDismissAllowed])
        return;
    
    self.view.userInteractionEnabled = false;
    [_currentTabController prepareTransitionOutSaving:true];
    
    MKPaintingData *paintingData = _photoEditor.paintingData;
    bool saving = true;
    if ([_currentTabController isKindOfClass:[MKPhotoPaintController class]])
    {
        MKPhotoPaintController *paintController = (MKPhotoPaintController *)_currentTabController;
        paintingData = [paintController paintingData];
        
        _photoEditor.paintingData = paintingData;
        
        if (paintingData != nil)
            [MKPaintingData storePaintingData:paintingData inContext:_editingContext forItem:_item forVideo:(_intent == MKPhotoEditorControllerVideoIntent)];
    }
    else if ([_currentTabController isKindOfClass:[MKPhotoQualityController class]])
    {
        MKPhotoQualityController *qualityController = (MKPhotoQualityController *)_currentTabController;
        _photoEditor.preset = qualityController.preset;
        saving = false;
        
        [[NSUserDefaults standardUserDefaults] setObject:@(qualityController.preset) forKey:@"TG_preferredVideoPreset_v0"];
    }
    
    if (_intent != MKPhotoEditorControllerVideoIntent)
    {
        MKProgressWindow *progressWindow = [[MKProgressWindow alloc] init];
        progressWindow.windowLevel = self.view.window.windowLevel + 0.001f;
        [progressWindow performSelector:@selector(showAnimated) withObject:nil afterDelay:0.5];
        
        MKPhotoEditorValues *editorValues = [_photoEditor exportAdjustmentsWithPaintingData:paintingData];
        [self createEditedImageWithEditorValues:editorValues createThumbnail:true saveOnly:false completion:^(__unused UIImage *image)
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:progressWindow selector:@selector(showAnimated) object:nil];
            [progressWindow dismiss:true];
            
            [self transitionOutSaving:true completion:^
            {
                [self dismiss];
            }];
        }];
    }
    else
    {
        MKVideoEditAdjustments *adjustments = [_photoEditor exportAdjustmentsWithPaintingData:paintingData];
        bool hasChanges = !(_initialAdjustments == nil && [adjustments isDefaultValuesForAvatar:false] && adjustments.cropOrientation == UIImageOrientationUp);
        
        if (adjustments.paintingData != nil || adjustments.hasPainting != _initialAdjustments.hasPainting)
        {
            [[SQueue concurrentDefaultQueue] dispatch:^
            {
                id<TGMediaEditableItem> item = _item;
                SSignal *assetSignal = [item isKindOfClass:[TGMediaAsset class]] ? [TGMediaAssetImageSignals avAssetForVideoAsset:(TGMediaAsset *)item] : [SSignal single:((AVAsset *)item)];
                
                [assetSignal startWithNext:^(AVAsset *asset)
                {
                    CGSize videoDimensions = CGSizeZero;
                    if ([item isKindOfClass:[TGMediaAsset class]])
                        videoDimensions = ((TGMediaAsset *)item).dimensions;
                    else if ([asset isKindOfClass:[AVURLAsset class]])
                        videoDimensions = ((AVURLAsset *)asset).originalSize;
                    
                    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                    generator.appliesPreferredTrackTransform = true;
                    generator.maximumSize = TGFitSize(videoDimensions, CGSizeMake(1280.0f, 1280.0f));
                    generator.requestedTimeToleranceAfter = kCMTimeZero;
                    generator.requestedTimeToleranceBefore = kCMTimeZero;
                    
                    CGImageRef imageRef = [generator copyCGImageAtTime:CMTimeMakeWithSeconds(adjustments.trimStartValue, NSEC_PER_SEC) actualTime:nil error:NULL];
                    UIImage *image = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    
                    CGSize thumbnailSize = TGPhotoThumbnailSizeForCurrentScreen();
                    thumbnailSize.width = CGCeil(thumbnailSize.width);
                    thumbnailSize.height = CGCeil(thumbnailSize.height);
                    
                    CGSize fillSize = TGScaleToFillSize(videoDimensions, thumbnailSize);
                    
                    UIImage *thumbnailImage = nil;
                    
                    UIGraphicsBeginImageContextWithOptions(fillSize, true, 0.0f);
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetInterpolationQuality(context, kCGInterpolationMedium);
                    
                    [image drawInRect:CGRectMake(0, 0, fillSize.width, fillSize.height)];
                    
                    if (adjustments.paintingData.image != nil)
                        [adjustments.paintingData.image drawInRect:CGRectMake(0, 0, fillSize.width, fillSize.height)];
                    
                    thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    [_editingContext setImage:image thumbnailImage:thumbnailImage forItem:_item synchronous:true];
                }];
            }];
        }
        
        if (self.willFinishEditing != nil)
            self.willFinishEditing(hasChanges ? adjustments : nil, nil, hasChanges);
        
        if (self.didFinishEditing != nil)
            self.didFinishEditing(hasChanges ? adjustments : nil, nil, nil, hasChanges);
        
        [self transitionOutSaving:saving completion:^
        {
            [self dismiss];
        }];
    }
}

- (void)doneButtonLongPressed:(UIButton *)sender
{
}

- (void)actionStageActionRequested:(NSString *)action options:(id)options
{
    if ([action isEqualToString:@"menuAction"])
    {
        NSString *menuAction = options[@"action"];
        if ([menuAction isEqualToString:@"save"])
            [self _saveToCameraRoll];
        else if ([menuAction isEqualToString:@"instagram"])
            [self _openInInstagram];
    }
}

#pragma mark - External Export

- (void)_saveToCameraRoll
{
    MKProgressWindow *progressWindow = [[MKProgressWindow alloc] init];
    progressWindow.windowLevel = self.view.window.windowLevel + 0.001f;
    [progressWindow performSelector:@selector(showAnimated) withObject:nil afterDelay:0.5];
    
    MKPaintingData *paintingData = nil;
    if ([_currentTabController isKindOfClass:[MKPhotoPaintController class]])
        paintingData = [(MKPhotoPaintController *)_currentTabController paintingData];
    
    MKPhotoEditorValues *editorValues = paintingData == nil ? [_photoEditor exportAdjustments] : [_photoEditor exportAdjustmentsWithPaintingData:paintingData];
    
    [self createEditedImageWithEditorValues:editorValues createThumbnail:false saveOnly:true completion:^(UIImage *resultImage)
    {
        [[[[TGMediaAssetsLibrary sharedLibrary] saveAssetWithImage:resultImage] deliverOn:[SQueue mainQueue]] startWithNext:nil completed:^
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:progressWindow selector:@selector(showAnimated) object:nil];
            [progressWindow dismissWithSuccess];
        }];
    }];
}

- (void)_openInInstagram
{
    MKProgressWindow *progressWindow = [[MKProgressWindow alloc] init];
    progressWindow.windowLevel = self.view.window.windowLevel + 0.001f;
    [progressWindow performSelector:@selector(showAnimated) withObject:nil afterDelay:0.5];
    
    MKPaintingData *paintingData = nil;
    if ([_currentTabController isKindOfClass:[MKPhotoPaintController class]])
        paintingData = [(MKPhotoPaintController *)_currentTabController paintingData];
    
    MKPhotoEditorValues *editorValues = paintingData == nil ? [_photoEditor exportAdjustments] : [_photoEditor exportAdjustmentsWithPaintingData:paintingData];
    
    [self createEditedImageWithEditorValues:editorValues createThumbnail:false saveOnly:true completion:^(UIImage *resultImage)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:progressWindow selector:@selector(showAnimated) object:nil];
        [progressWindow dismiss:true];
        
        NSData *imageData = UIImageJPEGRepresentation(resultImage, 0.9);
        NSString *writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"instagram.igo"];
        if (![imageData writeToFile:writePath atomically:true])
        {
            return;
        }
        
        NSURL *fileURL = [NSURL fileURLWithPath:writePath];
        
        _documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
        _documentController.delegate = self;
        [_documentController setUTI:@"com.instagram.exclusivegram"];
        if (_caption.length > 0)
            [_documentController setAnnotation:@{@"InstagramCaption" : _caption}];
        [_documentController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:true];
    }];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)__unused controller
{
    _documentController = nil;
}

#pragma mark -

- (void)dismiss
{
    if (self.overlayWindow != nil) {
        [super dismiss];
    } else if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    } else if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:true];
    } else {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}

#pragma mark - Layout

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.view setNeedsLayout];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateLayout:[[LegacyComponentsGlobals provider] applicationStatusBarOrientation]];
}

- (bool)inFormSheet
{
    if (iosMajorVersion() < 9)
        return [super inFormSheet];
    
    UIUserInterfaceSizeClass sizeClass = [_context currentHorizontalSizeClass];
    if (sizeClass == UIUserInterfaceSizeClassCompact)
        return false;
    
    return [super inFormSheet];
}

- (CGSize)referenceViewSize
{
    if ([self inFormSheet])
        return CGSizeMake(540.0f, 620.0f);
    
    if (self.parentViewController != nil)
        return self.parentViewController.view.frame.size;
    else if (self.navigationController != nil)
        return self.navigationController.view.frame.size;
    
    return [_context fullscreenBounds].size;
}

- (void)updateLayout:(UIInterfaceOrientation)orientation
{
    bool isPad = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    if ([self inFormSheet] || isPad)
        orientation = UIInterfaceOrientationPortrait;
    
    CGSize referenceSize = [self referenceViewSize];
    
    CGFloat screenSide = MAX(referenceSize.width, referenceSize.height);
    _wrapperView.frame = CGRectMake((referenceSize.width - screenSide) / 2, (referenceSize.height - screenSide) / 2, screenSide, screenSide);
    
    _containerView.frame = CGRectMake((screenSide - referenceSize.width) / 2, (screenSide - referenceSize.height) / 2, referenceSize.width, referenceSize.height);
    _transitionWrapperView.frame = _containerView.frame;
    
    UIEdgeInsets screenEdges = UIEdgeInsetsMake((screenSide - referenceSize.height) / 2, (screenSide - referenceSize.width) / 2, (screenSide + referenceSize.height) / 2, (screenSide + referenceSize.width) / 2);
    
    _landscapeToolbarView.interfaceOrientation = orientation;
    
    UIEdgeInsets safeAreaInset = [self calculatedSafeAreaInset];
    
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
        {
            [UIView performWithoutAnimation:^
            {
                _landscapeToolbarView.frame = CGRectMake(screenEdges.left, screenEdges.top, TGPhotoEditorToolbarSize + safeAreaInset.left, referenceSize.height);
            }];
        }
            break;
            
        case UIInterfaceOrientationLandscapeRight:
        {
            [UIView performWithoutAnimation:^
            {
                _landscapeToolbarView.frame = CGRectMake(screenEdges.right - TGPhotoEditorToolbarSize - safeAreaInset.right, screenEdges.top, TGPhotoEditorToolbarSize + safeAreaInset.right, referenceSize.height);
            }];
        }
            break;
            
        default:
        {
            _landscapeToolbarView.frame = CGRectMake(_landscapeToolbarView.frame.origin.x, screenEdges.top, TGPhotoEditorToolbarSize, referenceSize.height);
        }
            break;
    }
    
    CGFloat portraitToolbarViewBottomEdge = screenSide;
    if (isPad)
        portraitToolbarViewBottomEdge = screenEdges.bottom;
    _portraitToolbarView.frame = CGRectMake(screenEdges.left, portraitToolbarViewBottomEdge - TGPhotoEditorToolbarSize - safeAreaInset.bottom, referenceSize.width, TGPhotoEditorToolbarSize + safeAreaInset.bottom);
}

- (CGFloat)toolbarLandscapeSize
{
    return TGPhotoEditorToolbarSize;
}

- (void)setInfoString:(NSString *)string
{
    [_portraitToolbarView setInfoString:string];
    [_landscapeToolbarView setInfoString:string];
}

@end

#import "MKPhotoCropController.h"

#import "LegacyComponentsInternal.h"

#import <MediaEditorKit/UIControl+HitTestEdgeInsets.h>
#import <MediaEditorKit/TGPaintUtils.h>

#import <MediaEditorKit/MKPhotoEditorAnimation.h>
#import <MediaEditorKit/MKPhotoEditorUtils.h>
#import "MKPhotoEditorInterfaceAssets.h"
#import <pop/pop.h>
#import "MKPhotoEditor.h"

#import <MediaEditorKit/MKPhotoEditorValues.h>
#import <MediaEditorKit/MKPaintingData.h>

#import "MKPhotoEditorPreviewView.h"
#import "MKPhotoCropView.h"
#import "TGModernButton.h"

const CGFloat TGPhotoCropButtonsWrapperSize = 61.0f;
const CGSize TGPhotoCropAreaInsetSize = { 9, 9 };

NSString * const TGPhotoCropOriginalAspectRatio = @"original";

@interface MKPhotoCropController ()
{
    bool _forVideo;
    
    UIView *_wrapperView;
    
    CGFloat _autoRotationAngle;
    
    UIView *_buttonsWrapperView;
    TGModernButton *_rotateButton;
    TGModernButton *_mirrorButton;
    TGModernButton *_aspectRatioButton;
    TGModernButton *_resetButton;

    MKPhotoCropView *_cropView;
    
    UIImage *_screenImage;
    
    UIView *_snapshotView;
    UIImage *_snapshotImage;
    
    bool _appeared;
    UIImage *_imagePendingLoad;
    
    CGRect _transitionOutFrame;
    UIView *_transitionOutView;
    
    CGFloat _resetButtonWidth;
    
    dispatch_semaphore_t _waitSemaphore;
    
    id<LegacyComponentsContext> _context;
}

@property (nonatomic, weak) MKPhotoEditor *photoEditor;
@property (nonatomic, weak) MKPhotoEditorPreviewView *previewView;

@end

@implementation MKPhotoCropController

- (instancetype)initWithContext:(id<LegacyComponentsContext>)context photoEditor:(MKPhotoEditor *)photoEditor previewView:(MKPhotoEditorPreviewView *)previewView forVideo:(bool)forVideo
{
    self = [super initWithContext:context];
    if (self != nil)
    {
        _context = context;
        self.photoEditor = photoEditor;
        self.previewView = previewView;
        _forVideo = forVideo;
        
        _waitSemaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    __weak MKPhotoCropController *weakSelf = self;
    void(^interactionEnded)(void) = ^
    {
        __strong MKPhotoCropController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        if ([strongSelf shouldAutorotate])
            [MKViewController attemptAutorotation];
    };
    
    _wrapperView = [[UIView alloc] initWithFrame:self.view.bounds];
    _wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_wrapperView];
    
    MKPhotoEditor *photoEditor = self.photoEditor;
    _cropView = [[MKPhotoCropView alloc] initWithOriginalSize:photoEditor.originalSize hasArbitraryRotation:!_forVideo];
    [_cropView setCropRect:photoEditor.cropRect];
    [_cropView setCropOrientation:photoEditor.cropOrientation];
    [_cropView setRotation:photoEditor.cropRotation];
    [_cropView setMirrored:photoEditor.cropMirrored];
    _cropView.interactionBegan = ^
    {
        __strong MKPhotoCropController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf setAutoButtonHidden:true];
    };
    _cropView.croppingChanged = ^
    {
        __strong MKPhotoCropController *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf _updateEditorValues];
        
        MKPhotoEditor *photoEditor = strongSelf.photoEditor;
        if (!photoEditor.hasDefaultCropping || photoEditor.cropLockedAspectRatio > FLT_EPSILON)
            [strongSelf setAutoButtonHidden:true];
        
        if (strongSelf.valuesChanged != nil)
            strongSelf.valuesChanged();
    };
    if (_snapshotView != nil)
    {
        [_cropView setSnapshotView:_snapshotView];
        _snapshotView = nil;
    }
    else if (_snapshotImage != nil)
    {
        [_cropView setSnapshotImage:_snapshotImage];
        _snapshotImage = nil;
    }
    _cropView.interactionEnded = interactionEnded;
    [_wrapperView addSubview:_cropView];
    
    [_cropView setPaintingImage:_photoEditor.paintingData.image];
    
    _buttonsWrapperView = [[UIView alloc] initWithFrame:CGRectZero];
    [_wrapperView addSubview:_buttonsWrapperView];
    
    _rotateButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    _rotateButton.exclusiveTouch = true;
    _rotateButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_rotateButton addTarget:self action:@selector(rotate) forControlEvents:UIControlEventTouchUpInside];
    [_rotateButton setImage:TGComponentsImageNamed(@"PhotoEditorRotateIcon") forState:UIControlStateNormal];
    //[_buttonsWrapperView addSubview:_rotateButton];
    
    _mirrorButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    _mirrorButton.exclusiveTouch = true;
    _mirrorButton.imageEdgeInsets = UIEdgeInsetsMake(4.0f, 0.0f, 0.0f, 0.0f);
    _mirrorButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_mirrorButton addTarget:self action:@selector(mirror) forControlEvents:UIControlEventTouchUpInside];
    [_mirrorButton setImage:TGComponentsImageNamed(@"PhotoEditorMirrorIcon") forState:UIControlStateNormal];
    //[_buttonsWrapperView addSubview:_mirrorButton];
    
    _aspectRatioButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    _aspectRatioButton.exclusiveTouch = true;
    _aspectRatioButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_aspectRatioButton addTarget:self action:@selector(aspectRatioButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIImage *aspectRatioHighlightedImage = TGTintedImage(TGComponentsImageNamed(@"PhotoEditorAspectRatioIcon"), [MKPhotoEditorInterfaceAssets accentColor]);
    [_aspectRatioButton setImage:TGComponentsImageNamed(@"PhotoEditorAspectRatioIcon") forState:UIControlStateNormal];
    [_aspectRatioButton setImage:aspectRatioHighlightedImage forState:UIControlStateSelected];
    [_aspectRatioButton setImage:aspectRatioHighlightedImage forState:UIControlStateSelected | UIControlStateHighlighted];
    //[_buttonsWrapperView addSubview:_aspectRatioButton];
    
    NSString *resetButtonTitle = @"重置";
    _resetButton = [[TGModernButton alloc] init];
    _resetButton.hidden = self.photoEditor.cropLockedAspectRatio > 0;
    _resetButton.exclusiveTouch = true;
    _resetButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    _resetButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_resetButton addTarget:self action:@selector(resetButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_resetButton setTitle:resetButtonTitle forState:UIControlStateNormal];
    [_resetButton setTitleColor:[UIColor whiteColor]];
    [_resetButton sizeToFit];
    _resetButton.frame = CGRectMake(0, 0, _resetButton.frame.size.width, 24);
    [_buttonsWrapperView addSubview:_resetButton];
    
    if ([resetButtonTitle respondsToSelector:@selector(sizeWithAttributes:)])
        _resetButtonWidth = CGCeil([resetButtonTitle sizeWithAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:13] }].width);
    else
        _resetButtonWidth = CGCeil([resetButtonTitle sizeWithFont:[UIFont systemFontOfSize:13]].width);
    
    if (photoEditor.cropLockedAspectRatio > FLT_EPSILON)
    {
        _aspectRatioButton.selected = true;
        [_cropView setLockedAspectRatio:photoEditor.cropLockedAspectRatio performResize:false animated:false];
    }
    else if ([photoEditor hasDefaultCropping] && ABS(_autoRotationAngle) > FLT_EPSILON)
    {
        _resetButton.selected = true;
        [_resetButton setTitle:TGLocalized(@"PhotoEditor.CropAuto") forState:UIControlStateNormal];
    }
    
    [self _updateTabs];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.skipTransitionIn)
    {
        [self _finishedTransitionInWithView:nil];
        if (self.finishedTransitionIn != nil)
        {
            self.finishedTransitionIn();
            self.finishedTransitionIn = nil;
        }
    }
    else
    {
        [self transitionIn];
    }
}

- (BOOL)shouldAutorotate
{
    return (!_cropView.isTracking && [super shouldAutorotate]);
}

- (bool)isDismissAllowed
{
    return _appeared && !_cropView.isTracking && !_cropView.isAnimating;
}

#pragma mark -

- (void)setAutorotationAngle:(CGFloat)autorotationAngle
{
    if (fabs(autorotationAngle) < TGDegreesToRadians(5.0f))
        return;
    
    _autoRotationAngle = autorotationAngle;
    
    MKPhotoEditor *photoEditor = self.photoEditor;
    if ([photoEditor hasDefaultCropping] && fabs(_autoRotationAngle) > FLT_EPSILON && photoEditor.cropLockedAspectRatio < FLT_EPSILON)
    {
        _resetButton.selected = true;
        [_resetButton setTitle:TGLocalized(@"PhotoEditor.CropAuto") forState:UIControlStateNormal];
    }
}

- (void)setImage:(UIImage *)image
{
    if (_dismissing && !_switching)
        return;
    
    if (_waitSemaphore != nil)
        dispatch_semaphore_signal(_waitSemaphore);
    
    if (!_appeared)
    {
        _imagePendingLoad = image;
        return;
    }
    
    [_cropView setImage:image];
}

- (void)setSnapshotImage:(UIImage *)snapshotImage
{
    _snapshotImage = snapshotImage;
}

- (void)setSnapshotView:(UIView *)snapshotView
{
    _snapshotView = snapshotView;
}

- (void)_updateEditorValues
{
    MKPhotoEditor *photoEditor = self.photoEditor;
    photoEditor.cropRect = _cropView.cropRect;
    photoEditor.cropRotation = _cropView.rotation;
    photoEditor.cropLockedAspectRatio = _cropView.lockedAspectRatio;
    photoEditor.cropOrientation = _cropView.cropOrientation;
    photoEditor.cropMirrored = _cropView.mirrored;
}

#pragma mark - Transition

- (void)transitionIn
{
    _buttonsWrapperView.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f animations:^
    {
        _buttonsWrapperView.alpha = 1.0f;
    }];
    
    [_cropView animateTransitionIn];
}

- (void)animateTransitionIn
{
    if ([_transitionView isKindOfClass:[MKPhotoEditorPreviewView class]])
        [(MKPhotoEditorPreviewView *)_transitionView performTransitionToCropAnimated:true];
    
    [super animateTransitionIn];
}

- (void)_finishedTransitionInWithView:(UIView *)transitionView
{
    _appeared = true;
    
    if (_imagePendingLoad != nil)
        [_cropView setImage:_imagePendingLoad];
    [transitionView removeFromSuperview];
    
    [_cropView transitionInFinishedAnimated:false completion:nil];
    if (_photoEditor.cropLockedAspectRatio > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setLockedAspectRatio:_photoEditor.cropLockedAspectRatio performResize:true animated:false];
        });
    }
}

- (void)transitionOutSwitching:(bool)switching completion:(void (^)(void))completion
{
    _dismissing = true;
    
    if (switching)
    {
        _switching = true;
        
        MKPhotoEditorPreviewView *previewView = self.previewView;
        [previewView performTransitionToCropAnimated:false];
        [previewView setSnapshotView:[_cropView cropSnapshotView]];
        
        [_cropView performConfirmAnimated:false updateInterface:false];
        
        if (!_forVideo)
        {
            MKPhotoEditor *photoEditor = self.photoEditor;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
            {
                if (dispatch_semaphore_wait(_waitSemaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC))))
                {
                    TGLegacyLog(@"Photo crop on switching failed");
                    return;
                }
                
                UIImage *croppedImage = [_cropView croppedImageWithMaxSize:TGPhotoEditorScreenImageMaxSize()];
                [photoEditor setImage:croppedImage forCropRect:_cropView.cropRect cropRotation:_cropView.rotation cropOrientation:_cropView.cropOrientation cropMirrored:_cropView.mirrored fullSize:false];
                
                [photoEditor processAnimated:false completion:^
                {
                    TGDispatchOnMainThread(^
                    {
                        [previewView setSnapshotImage:croppedImage];
                        
                        if (!previewView.hidden)
                            [previewView performTransitionInWithCompletion:nil];
                        else
                            [previewView setNeedsTransitionIn];
                    });
                }];
                
                if (self.finishedPhotoProcessing != nil)
                    self.finishedPhotoProcessing();
            });
        }
    }
    
    [UIView animateWithDuration:0.3f animations:^
    {
        _buttonsWrapperView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        if (completion != nil)
            completion();
    }];
    
    [_cropView animateTransitionOut];
}

- (CGRect)_targetFrameForTransitionInFromFrame:(CGRect)fromFrame
{
    CGSize referenceSize = [self referenceViewSize];
    
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        orientation = UIInterfaceOrientationPortrait;
    
    CGRect containerFrame = [MKPhotoCropController photoContainerFrameForParentViewFrame:CGRectMake(0, 0, referenceSize.width, referenceSize.height) toolbarLandscapeSize:self.toolbarLandscapeSize orientation:orientation hasArbitraryRotation:_cropView.hasArbitraryRotation];
    containerFrame = CGRectInset(containerFrame, TGPhotoCropAreaInsetSize.width, TGPhotoCropAreaInsetSize.height);
    
    CGSize fittedSize = TGScaleToSize(fromFrame.size, containerFrame.size);
    CGRect toFrame = CGRectMake(containerFrame.origin.x + (containerFrame.size.width - fittedSize.width) / 2,
                                containerFrame.origin.y + (containerFrame.size.height - fittedSize.height) / 2,
                                fittedSize.width,
                                fittedSize.height);
    
    return toFrame;
}

- (void)transitionOutSaving:(bool)saving completion:(void (^)(void))completion
{
    UIView *snapshotView = nil;
    CGRect sourceFrame = CGRectZero;
    
    if (_transitionOutView != nil)
    {
        snapshotView = _transitionOutView;
        sourceFrame = _transitionOutFrame;
    }
    else
    {
        snapshotView = [_cropView cropSnapshotView];
        sourceFrame = [_cropView cropRectFrameForView:self.view];
    }

    snapshotView.frame = sourceFrame;
    
    if (snapshotView.superview != self.view)
        [self.view addSubview:snapshotView];
    
    [self transitionOutSwitching:false completion:nil];
    
    CGRect referenceFrame = CGRectZero;
    UIView *referenceView = nil;
    UIView *parentView = nil;
    
    if (self.beginTransitionOut != nil)
        referenceView = self.beginTransitionOut(&referenceFrame, &parentView);
    
    UIView *toTransitionView = nil;
    CGRect targetFrame = CGRectZero;
    
    if (parentView == nil)
        parentView = referenceView.superview.superview;
    
    UIView *backgroundSuperview = parentView;
    UIView *transitionBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, backgroundSuperview.frame.size.width, backgroundSuperview.frame.size.height)];
    transitionBackgroundView.backgroundColor = [MKPhotoEditorInterfaceAssets toolbarBackgroundColor];
    [backgroundSuperview addSubview:transitionBackgroundView];
    
    [UIView animateWithDuration:0.3f animations:^
    {
        transitionBackgroundView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        [transitionBackgroundView removeFromSuperview];
    }];
    
    if (saving)
    {
        CGSize fittedSize = TGScaleToSize(snapshotView.frame.size, self.view.frame.size);
        targetFrame = CGRectMake((self.view.frame.size.width - fittedSize.width) / 2,
                                 (self.view.frame.size.height - fittedSize.height) / 2,
                                 fittedSize.width,
                                 fittedSize.height);
        
        UIImage *transitionImage = nil;
        if ([referenceView isKindOfClass:[UIImageView class]])
            transitionImage = ((UIImageView *)referenceView).image;
        
        if (transitionImage != nil)
            toTransitionView = [[UIImageView alloc] initWithImage:transitionImage];
        else
            toTransitionView = [snapshotView snapshotViewAfterScreenUpdates:false];
        
        toTransitionView.frame = snapshotView.frame;
    }
    else
    {  
        UIImage *transitionImage = nil;
        if ([referenceView isKindOfClass:[UIImageView class]])
            transitionImage = ((UIImageView *)referenceView).image;
        
        if (transitionImage != nil)
            toTransitionView = [[UIImageView alloc] initWithImage:transitionImage];
        else
            toTransitionView = [referenceView snapshotViewAfterScreenUpdates:false];
        
        targetFrame = referenceFrame;
        toTransitionView.frame = snapshotView.frame;
    }
    
    [parentView addSubview:toTransitionView];
    
    POPSpringAnimation *animation = [MKPhotoEditorAnimation prepareTransitionAnimationForPropertyNamed:kPOPViewFrame];
    animation.fromValue = [NSValue valueWithCGRect:toTransitionView.frame];
    animation.toValue = [NSValue valueWithCGRect:targetFrame];
    
    POPSpringAnimation *snapshotAnimation = [MKPhotoEditorAnimation prepareTransitionAnimationForPropertyNamed:kPOPViewFrame];
    snapshotAnimation.fromValue = [NSValue valueWithCGRect:snapshotView.frame];
    snapshotAnimation.toValue = [NSValue valueWithCGRect:targetFrame];
    
    POPSpringAnimation *snapshotAlphaAnimation = [MKPhotoEditorAnimation prepareTransitionAnimationForPropertyNamed:kPOPViewAlpha];
    snapshotAlphaAnimation.fromValue = @([snapshotView alpha]);
    snapshotAlphaAnimation.toValue = @(0.0f);
    
    [MKPhotoEditorAnimation performBlock:^(__unused bool allFinished)
    {
        [toTransitionView removeFromSuperview];
        [snapshotView removeFromSuperview];
         
        if (completion != nil)
            completion();
    } whenCompletedAllAnimations:@[ animation, snapshotAnimation, snapshotAlphaAnimation ]];
    
    [toTransitionView pop_addAnimation:animation forKey:@"frame"];
    [snapshotView pop_addAnimation:snapshotAnimation forKey:@"frame"];
    [snapshotView pop_addAnimation:snapshotAlphaAnimation forKey:@"alpha"];
}

- (CGRect)transitionOutReferenceFrame
{
    return [_cropView cropRectFrameForView:self.view];
}

- (UIView *)transitionOutReferenceView
{
    return [_cropView cropSnapshotView];
}

- (void)prepareTransitionOutSaving:(bool)saving
{
    if (saving)
    {
        _transitionOutFrame = [_cropView cropRectFrameForView:self.view];
        
        [_cropView performConfirmAnimated:false updateInterface:false];
     
        _transitionOutView = [[UIImageView alloc] initWithImage:[_cropView croppedImageWithMaxSize:CGSizeMake(2048, 2048)]];
        _transitionOutView.frame = _transitionOutFrame;
        
        [self.view addSubview:_transitionOutView];

        _cropView.hidden = true;
        
        [self _updateEditorValues];
    }
}

- (id)currentResultRepresentation
{
    if (_transitionOutView != nil && [_transitionOutView isKindOfClass:[UIImageView class]])
    {
        return ((UIImageView *)_transitionOutView).image;
    }
    else
    {
        return [_cropView croppedImageWithMaxSize:CGSizeMake(750, 750)];
    }
}

#pragma mark - Actions

- (UIImageOrientation)cropOrientation
{
    return _cropView.cropOrientation;
}

- (void)rotate
{
    [_cropView rotate90DegreesCCWAnimated:true];
}

- (void)mirror
{
    [_cropView mirror];
    
    [self _updateTabs];
}

- (void)setLockedAspectRatio:(CGFloat)aspectRatio performResize:(bool)performResize animated:(bool)animated {
    [_cropView setLockedAspectRatio:aspectRatio performResize:performResize animated:animated];
}

- (void)aspectRatioButtonPressed
{
    if (_cropView.isAnimating)
        return;
    
    if (_cropView.isAspectRatioLocked)
    {
        [_cropView unlockAspectRatio];
        _aspectRatioButton.selected = false;
    }
    else
    {
        [_cropView performConfirmAnimated:true];
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

        __weak MKPhotoCropController *weakSelf = self;
        
        void (^action)(NSString *) = ^(NSString *ratioString)
        {
            __strong MKPhotoCropController *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            CGFloat aspectRatio = 0.0f;
            if ([ratioString isEqualToString:TGPhotoCropOriginalAspectRatio])
            {
                MKPhotoEditor *photoEditor = strongSelf->_photoEditor;
                aspectRatio = photoEditor.originalSize.height / photoEditor.originalSize.width;
            }
            else
            {
                aspectRatio = [ratioString floatValue];
                if (_cropView.cropOrientation == UIImageOrientationLeft || _cropView.cropOrientation == UIImageOrientationRight)
                    aspectRatio = 1.0f / aspectRatio;
            }
            
            void (^setAspectRatioBlock)(void) = ^
            {
                [strongSelf setAutoButtonHidden:true];
                [strongSelf->_cropView setLockedAspectRatio:aspectRatio performResize:true animated:true];
                
                [strongSelf _updateTabs];
            };
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                setAspectRatioBlock();
            else
                TGDispatchAfter(0.1f, dispatch_get_main_queue(), setAspectRatioBlock);
        };
        
        [controller addAction:[UIAlertAction actionWithTitle:@"原始" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull alertAction) {
            action(TGPhotoCropOriginalAspectRatio);
        }]];
        
        [controller addAction:[UIAlertAction actionWithTitle:@"正方形" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull alertAction) {
            action(@"1.0");
        }]];
        
        
        CGSize croppedImageSize = _cropView.cropRect.size;
        if (_cropView.cropOrientation == UIImageOrientationLeft || _cropView.cropOrientation == UIImageOrientationRight)
            croppedImageSize = CGSizeMake(croppedImageSize.height, croppedImageSize.width);
        
        static NSArray *ratiosDefinitions = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            ratiosDefinitions = @
            [
                @[ @3.0f, @2.0f ],
                @[ @5.0f, @3.0f ],
                @[ @4.0f, @3.0f ],
                @[ @5.0f, @4.0f ],
                @[ @7.0f, @5.0f ],
                @[ @16.0f, @9.0f ]
            ];
        });
        
        for (NSArray *ratioDef in ratiosDefinitions)
        {
            CGFloat widthComponent;
            CGFloat heightComponent;
            CGFloat ratio = 0.0f;
            
            if (croppedImageSize.width >= croppedImageSize.height)
            {
                widthComponent = [ratioDef.firstObject floatValue];
                heightComponent = [ratioDef.lastObject floatValue];
            }
            else
            {
                widthComponent = [ratioDef.lastObject floatValue];
                heightComponent = [ratioDef.firstObject floatValue];
            }
            
            ratio = heightComponent / widthComponent;
            
            [controller addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%d:%d", (int)widthComponent, (int)heightComponent] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull alertAction) {
                action([NSString stringWithFormat:@"%f", ratio]);
            }]];
        }
        
        [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        controller.popoverPresentationController.sourceView = self.view;
        controller.popoverPresentationController.sourceRect = [self.view convertRect:_aspectRatioButton.frame fromView:_aspectRatioButton.superview];
        [self.parentViewController presentViewController:controller animated:true completion:nil];
    }
    
    [self _updateTabs];
}

- (void)resetButtonPressed
{
    if (_cropView.isAnimatingRotation)
        return;
    
    bool hasAutorotationAngle = ABS(_autoRotationAngle) > FLT_EPSILON;
    MKPhotoEditor *photoEditor = self.photoEditor;
    
    if ([photoEditor hasDefaultCropping] && photoEditor.cropLockedAspectRatio < FLT_EPSILON && hasAutorotationAngle && _resetButton.selected)
    {
        [_cropView setRotation:_autoRotationAngle animated:true];
        [self setAutoButtonHidden:true];
    }
    else
    {
        _aspectRatioButton.selected = false;
        
        [_cropView resetAnimated:true];
        
        if (hasAutorotationAngle)
            [self setAutoButtonHidden:false];
    }
    
    [self _updateTabs];
    
    if (self.cropReset != nil)
        self.cropReset();
}

- (void)setAutoButtonHidden:(bool)hidden
{
    if (hidden)
    {
        _resetButton.selected = false;
        [_resetButton setTitle:@"重置" forState:UIControlStateNormal];
    }
    else
    {
        _resetButton.selected = true;
        [_resetButton setTitle:@"自动" forState:UIControlStateNormal];
    }
}

#pragma mark - Layout

+ (CGRect)photoContainerFrameForParentViewFrame:(CGRect)parentViewFrame toolbarLandscapeSize:(CGFloat)toolbarLandscapeSize orientation:(UIInterfaceOrientation)orientation hasArbitraryRotation:(bool)hasArbitraryRotation
{
    CGFloat panelToolbarPortraitSize = TGPhotoEditorToolbarSize;
    CGFloat panelToolbarLandscapeSize = toolbarLandscapeSize;
    
    if (hasArbitraryRotation)
    {
        panelToolbarPortraitSize += TGPhotoEditorPanelSize;
        panelToolbarLandscapeSize += TGPhotoEditorPanelSize;
    }
    else
    {
        panelToolbarPortraitSize += TGPhotoEditorPanelSize - 55;
        panelToolbarLandscapeSize += TGPhotoEditorPanelSize - 55;
    }
    
    UIEdgeInsets safeAreaInset = [MKViewController safeAreaInsetForOrientation:orientation];
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            return CGRectMake(panelToolbarLandscapeSize + safeAreaInset.left, 0, parentViewFrame.size.width - panelToolbarLandscapeSize - safeAreaInset.left - safeAreaInset.right, parentViewFrame.size.height - safeAreaInset.bottom);
            
        case UIInterfaceOrientationLandscapeRight:
            return CGRectMake(safeAreaInset.left, 0, parentViewFrame.size.width - panelToolbarLandscapeSize - safeAreaInset.left - safeAreaInset.right, parentViewFrame.size.height - safeAreaInset.bottom);
            
        default:
            return CGRectMake(0, safeAreaInset.top, parentViewFrame.size.width, parentViewFrame.size.height - panelToolbarPortraitSize - safeAreaInset.top - safeAreaInset.bottom);
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIView *snapshotView = [_buttonsWrapperView snapshotViewAfterScreenUpdates:false];
    snapshotView.frame = _buttonsWrapperView.frame;
    [_wrapperView insertSubview:snapshotView aboveSubview:_buttonsWrapperView];
    
    _buttonsWrapperView.alpha = 0.0f;
    [UIView animateWithDuration:duration animations:^
    {
        _buttonsWrapperView.alpha = 1.0f;
        snapshotView.alpha = 0.0f;
    } completion:^(__unused BOOL finished)
    {
        [snapshotView removeFromSuperview];
    }];
    
    [self.view setNeedsLayout];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateLayout:[[LegacyComponentsGlobals provider] applicationStatusBarOrientation]];
}

- (void)updateLayout:(UIInterfaceOrientation)orientation
{
    if ([self inFormSheet] || [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        orientation = UIInterfaceOrientationPortrait;
    
    CGSize referenceSize = [self referenceViewSize];
    
    CGFloat screenSide = MAX(referenceSize.width, referenceSize.height) + 2 * TGPhotoEditorPanelSize;
    _wrapperView.frame = CGRectMake((referenceSize.width - screenSide) / 2, (referenceSize.height - screenSide) / 2, screenSide, screenSide);
    
    UIEdgeInsets safeAreaInset = [MKViewController safeAreaInsetForOrientation:orientation];
    UIEdgeInsets screenEdges = UIEdgeInsetsMake((screenSide - referenceSize.height) / 2 , (screenSide - referenceSize.width) / 2, (screenSide + referenceSize.height) / 2, (screenSide + referenceSize.width) / 2);
    
    UIEdgeInsets initialScreenEdges = screenEdges;
    screenEdges.top += safeAreaInset.top;
    screenEdges.left += safeAreaInset.left;
    screenEdges.bottom -= safeAreaInset.bottom;
    screenEdges.right -= safeAreaInset.right;
    
    [UIView performWithoutAnimation:^
    {
        switch (orientation)
        {
            case UIInterfaceOrientationLandscapeLeft:
            {
                _buttonsWrapperView.frame = CGRectMake(screenEdges.left + self.toolbarLandscapeSize,
                                                       screenEdges.top,
                                                       TGPhotoCropButtonsWrapperSize,
                                                       referenceSize.height);
                
                _rotateButton.frame = CGRectMake(25, 10, _rotateButton.frame.size.width, _rotateButton.frame.size.height);
                _mirrorButton.frame = CGRectMake(25, 60, _mirrorButton.frame.size.width, _mirrorButton.frame.size.height);
                
                _aspectRatioButton.frame = CGRectMake(25,
                                                      _buttonsWrapperView.frame.size.height - _aspectRatioButton.frame.size.height - 10,
                                                      _aspectRatioButton.frame.size.width,
                                                      _aspectRatioButton.frame.size.height);
                
                _resetButton.transform = CGAffineTransformIdentity;
                _resetButton.frame = CGRectMake(0, 0, _resetButtonWidth, 24);
                
                CGFloat xOrigin = 0.0f;
                if (_resetButton.frame.size.width > _buttonsWrapperView.frame.size.width)
                {
                    _resetButton.transform = CGAffineTransformMakeRotation((CGFloat)M_PI_2);
                    xOrigin = 8.0f;
                }
                
                _resetButton.frame = CGRectMake(_buttonsWrapperView.frame.size.width - _resetButton.frame.size.width - xOrigin, (_buttonsWrapperView.frame.size.height - _resetButton.frame.size.height) / 2.0f, _resetButton.frame.size.width, _resetButton.frame.size.height);
            }
                break;
                
            case UIInterfaceOrientationLandscapeRight:
            {
                _buttonsWrapperView.frame = CGRectMake(screenEdges.right - self.toolbarLandscapeSize - TGPhotoCropButtonsWrapperSize,
                                                       screenEdges.top,
                                                       TGPhotoCropButtonsWrapperSize,
                                                       referenceSize.height);
                
                _rotateButton.frame = CGRectMake(_buttonsWrapperView.frame.size.width - _rotateButton.frame.size.width - 25, 10, _rotateButton.frame.size.width, _rotateButton.frame.size.height);
                _mirrorButton.frame = CGRectMake(_buttonsWrapperView.frame.size.width - _mirrorButton.frame.size.width - 25, 60, _mirrorButton.frame.size.width, _mirrorButton.frame.size.height);
                
                _aspectRatioButton.frame = CGRectMake(_buttonsWrapperView.frame.size.width - _aspectRatioButton.frame.size.width - 25,
                                                      _buttonsWrapperView.frame.size.height - _aspectRatioButton.frame.size.height - 10,
                                                      _aspectRatioButton.frame.size.width,
                                                      _aspectRatioButton.frame.size.height);
                
                _resetButton.transform = CGAffineTransformIdentity;
                _resetButton.frame = CGRectMake(0, 0, _resetButtonWidth, 24);
                
                CGFloat xOrigin = 0.0f;
                if (_resetButtonWidth > _buttonsWrapperView.frame.size.width)
                {
                    _resetButton.transform = CGAffineTransformMakeRotation((CGFloat)-M_PI_2);
                    xOrigin = 8.0f;
                }
                
                _resetButton.frame = CGRectMake(xOrigin, (_buttonsWrapperView.frame.size.height - _resetButton.frame.size.height) / 2, _resetButton.frame.size.width, _resetButton.frame.size.height);
            }
                break;
                
            default:
            {
                _buttonsWrapperView.frame = CGRectMake(screenEdges.left,
                                                       screenEdges.bottom - TGPhotoEditorToolbarSize - TGPhotoCropButtonsWrapperSize,
                                                       referenceSize.width,
                                                       TGPhotoCropButtonsWrapperSize);
                
                _rotateButton.frame = CGRectMake(10, _buttonsWrapperView.frame.size.height - _rotateButton.frame.size.height - 25, _rotateButton.frame.size.width, _rotateButton.frame.size.height);
                _mirrorButton.frame = CGRectMake(60, _buttonsWrapperView.frame.size.height - _mirrorButton.frame.size.height - 25, _mirrorButton.frame.size.width, _mirrorButton.frame.size.height);
                
                _aspectRatioButton.frame = CGRectMake(_buttonsWrapperView.frame.size.width - _aspectRatioButton.frame.size.width - 10,
                                                      _buttonsWrapperView.frame.size.height - _aspectRatioButton.frame.size.height - 25,
                                                      _aspectRatioButton.frame.size.width,
                                                      _aspectRatioButton.frame.size.height);
                
                _resetButton.transform = CGAffineTransformIdentity;
                _resetButton.frame = CGRectMake((_buttonsWrapperView.frame.size.width - _resetButton.frame.size.width) / 2, 20, _resetButtonWidth, 24);
            }
                break;
        }
    }];
    
    CGRect containerFrame = [MKPhotoCropController photoContainerFrameForParentViewFrame:CGRectMake(0, 0, referenceSize.width, referenceSize.height) toolbarLandscapeSize:self.toolbarLandscapeSize orientation:orientation hasArbitraryRotation:_cropView.hasArbitraryRotation];
    containerFrame = CGRectOffset(containerFrame, initialScreenEdges.left, initialScreenEdges.top);
    _cropView.interfaceOrientation = orientation;
    _cropView.frame = CGRectInset(containerFrame, TGPhotoCropAreaInsetSize.width, TGPhotoCropAreaInsetSize.height);
    
    [UIView performWithoutAnimation:^
    {
        [_cropView _layoutRotationView];
    }];
}

- (MKPhotoEditorTab)availableTabs
{
    if (_photoEditor.cropLockedAspectRatio) {
        return MKPhotoEditorRotateTab | MKPhotoEditorMirrorTab;
    } else {
        return MKPhotoEditorRotateTab | MKPhotoEditorMirrorTab | MKPhotoEditorAspectRatioTab;
    }
}

- (void)handleTabAction:(MKPhotoEditorTab)tab
{
    switch (tab)
    {
        case MKPhotoEditorRotateTab:
        {
            [self rotate];
        }
            break;
            
        case MKPhotoEditorMirrorTab:
        {
            [self mirror];
        }
            break;
            
        case MKPhotoEditorAspectRatioTab:
        {
            [self aspectRatioButtonPressed];
        }
            break;
            
        default:
            break;
    }
}

- (MKPhotoEditorTab)highlightedTabs
{
    MKPhotoEditorTab tabs = MKPhotoEditorNoneTab;
    
    if (_cropView.mirrored)
        tabs |= MKPhotoEditorMirrorTab;
    if (_cropView.lockedAspectRatio > FLT_EPSILON)
        tabs |= MKPhotoEditorAspectRatioTab;
    
    return tabs;

}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return UIRectEdgeTop | UIRectEdgeBottom;
}

@end

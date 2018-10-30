#import "MKPhotoEditor.h"
#import "SSignalKit.h"
#import <MediaEditorKit/TGMemoryImageCache.h>
#import "LegacyComponentsInternal.h"
#import <MediaEditorKit/MKPhotoEditorUtils.h>
#import "MKPhotoEditorPreviewView.h"
#import "MKPhotoEditorView.h"
#import "MKPhotoEditorPicture.h"
#import <MediaEditorKit/MKPhotoEditorValues.h>
#import <MediaEditorKit/MKVideoEditAdjustments.h>
#import <MediaEditorKit/MKPaintingData.h>

@interface MKPhotoEditor ()
{
    id<MKMediaEditAdjustments> _initialAdjustments;
    
    MKPhotoEditorPicture *_currentInput;
    NSArray *_currentProcessChain;
    GPUImageOutput <GPUImageInput> *_finalFilter;
    
    UIImageOrientation _imageCropOrientation;
    CGRect _imageCropRect;
    CGFloat _imageCropRotation;
    bool _imageCropMirrored;
    
    SPipe *_histogramPipe;
    
    SQueue *_queue;
    
    bool _forVideo;
    
    bool _processing;
    bool _needsReprocessing;
    
    bool _fullSize;
}
@end

@implementation MKPhotoEditor

- (instancetype)initWithOriginalSize:(CGSize)originalSize adjustments:(id<MKMediaEditAdjustments>)adjustments forVideo:(bool)forVideo
{
    self = [super init];
    if (self != nil)
    {
        _queue = [[SQueue alloc] init];
        
        _forVideo = forVideo;
        
        _originalSize = originalSize;
        _cropRect = CGRectMake(0.0f, 0.0f, _originalSize.width, _originalSize.height);
        _paintingData = adjustments.paintingData;
        
        _tools = @[];

        _histogramPipe = [[SPipe alloc] init];
        
        [self _importAdjustments:adjustments];
    }
    return self;
}

- (void)dealloc
{
    TGDispatchAfter(1.5f, dispatch_get_main_queue(), ^
    {
        [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
    });
}

- (void)cleanup
{
    [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
}

- (void)setImage:(UIImage *)image forCropRect:(CGRect)cropRect cropRotation:(CGFloat)cropRotation cropOrientation:(UIImageOrientation)cropOrientation cropMirrored:(bool)cropMirrored fullSize:(bool)fullSize
{
    _currentProcessChain = nil;
    
    _imageCropRect = cropRect;
    _imageCropRotation = cropRotation;
    _imageCropOrientation = cropOrientation;
    _imageCropMirrored = cropMirrored;
    
    [_currentInput removeAllTargets];
    _currentInput = [[MKPhotoEditorPicture alloc] initWithImage:image];
    
    _fullSize = fullSize;
}

#pragma mark - Properties

- (CGSize)rotatedCropSize
{
    if (_cropOrientation == UIImageOrientationLeft || _cropOrientation == UIImageOrientationRight)
        return CGSizeMake(_cropRect.size.height, _cropRect.size.width);
    
    return _cropRect.size;
}

- (bool)hasDefaultCropping
{
    if (!_CGRectEqualToRectWithEpsilon(self.cropRect, CGRectMake(0, 0, _originalSize.width, _originalSize.height), 1.0f) || self.cropOrientation != UIImageOrientationUp || ABS(self.cropRotation) > FLT_EPSILON || self.cropMirrored)
    {
        return false;
    }
    
    return true;
}

#pragma mark - Processing

- (bool)readyForProcessing
{
    return (_currentInput != nil);
}

- (void)processAnimated:(bool)animated completion:(void (^)(void))completion
{
    [self processAnimated:animated capture:false synchronous:false completion:completion];
}

- (void)processAnimated:(bool)animated capture:(bool)capture synchronous:(bool)synchronous completion:(void (^)(void))completion
{
    if (self.previewOutput == nil)
        return;
    
    if (iosMajorVersion() < 7)
        animated = false;
    
    if (_processing && completion == nil)
    {
        _needsReprocessing = true;
        return;
    }
    
    _processing = true;
    
    [_queue dispatch:^
    {
        NSMutableArray *processChain = [NSMutableArray array];
        
        MKPhotoEditorPreviewView *previewOutput = self.previewOutput;
        
        if (![_currentProcessChain isEqualToArray:processChain])
        {
            [_currentInput removeAllTargets];
            
            
            _currentProcessChain = processChain;

            [_finalFilter addTarget:previewOutput.imageView];
        }
                
        if (capture)
            [_finalFilter useNextFrameForImageCapture];

        if (animated)
        {
            TGDispatchOnMainThread(^
            {
                [previewOutput prepareTransitionFadeView];
            });
        }
        
        [_currentInput processSynchronous:true completion:^
        {            
            if (completion != nil)
                completion();
            
            _processing = false;
             
            if (animated)
            {
                TGDispatchOnMainThread(^
                {
                    [previewOutput performTransitionFade];
                });
            }
            
            if (_needsReprocessing && !synchronous)
            {
                _needsReprocessing = false;
                [self processAnimated:false completion:nil];
            }
        }];
    } synchronous:synchronous];
}

#pragma mark - Result

- (void)createResultImageWithCompletion:(void (^)(UIImage *image))completion
{
    [self processAnimated:false capture:true synchronous:false completion:^
    {
        UIImage *image = [_finalFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
        
        if (completion != nil)
            completion(image);
    }];
}

- (UIImage *)currentResultImage
{
    __block UIImage *image = nil;
    [self processAnimated:false capture:true synchronous:true completion:^
    {
        image = [_finalFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    }];
    return image;
}

#pragma mark - Editor Values

- (void)_importAdjustments:(id<MKMediaEditAdjustments>)adjustments
{
    _initialAdjustments = adjustments;
    
    if (adjustments != nil)
        self.cropRect = adjustments.cropRect;
    
    self.cropOrientation = adjustments.cropOrientation;
    self.cropLockedAspectRatio = adjustments.cropLockedAspectRatio;
    self.cropMirrored = adjustments.cropMirrored;
    self.paintingData = adjustments.paintingData;
    
    if ([adjustments isKindOfClass:[MKPhotoEditorValues class]])
    {
        MKPhotoEditorValues *editorValues = (MKPhotoEditorValues *)adjustments;

        self.cropRotation = editorValues.cropRotation;
    }
    else if ([adjustments isKindOfClass:[MKVideoEditAdjustments class]])
    {
        MKVideoEditAdjustments *videoAdjustments = (MKVideoEditAdjustments *)adjustments;
        self.trimStartValue = videoAdjustments.trimStartValue;
        self.trimEndValue = videoAdjustments.trimEndValue;
        self.sendAsGif = videoAdjustments.sendAsGif;
        self.preset = videoAdjustments.preset;
    }
}

- (id<MKMediaEditAdjustments>)exportAdjustments
{
    return [self exportAdjustmentsWithPaintingData:_paintingData];
}

- (id<MKMediaEditAdjustments>)exportAdjustmentsWithPaintingData:(MKPaintingData *)paintingData
{
    if (!_forVideo)
    {
        NSMutableDictionary *toolValues = [[NSMutableDictionary alloc] init];
        
        return [MKPhotoEditorValues editorValuesWithOriginalSize:self.originalSize cropRect:self.cropRect cropRotation:self.cropRotation cropOrientation:self.cropOrientation cropLockedAspectRatio:self.cropLockedAspectRatio cropMirrored:self.cropMirrored toolValues:toolValues paintingData:paintingData];
    }
    else
    {
        MKVideoEditAdjustments *initialAdjustments = (MKVideoEditAdjustments *)_initialAdjustments;
        
        return [MKVideoEditAdjustments editAdjustmentsWithOriginalSize:self.originalSize cropRect:self.cropRect cropOrientation:self.cropOrientation cropLockedAspectRatio:self.cropLockedAspectRatio cropMirrored:self.cropMirrored trimStartValue:initialAdjustments.trimStartValue trimEndValue:initialAdjustments.trimEndValue paintingData:paintingData sendAsGif:self.sendAsGif preset:self.preset];
    }
}

+ (NSArray *)availableTools
{
    static NSArray *tools;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        tools = @[ ];
    });
    
    return tools;
}

@end

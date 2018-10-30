#import <Foundation/Foundation.h>
#import "SSignalKit.h"
#import <MediaEditorKit/MKVideoEditAdjustments.h>

@class MKPhotoEditorPreviewView;
@class MKPaintingData;

@interface MKPhotoEditor : NSObject

@property (nonatomic, assign) CGSize originalSize;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, readonly) CGSize rotatedCropSize;
@property (nonatomic, assign) CGFloat cropRotation;
@property (nonatomic, assign) UIImageOrientation cropOrientation;
@property (nonatomic, assign) CGFloat cropLockedAspectRatio;
@property (nonatomic, assign) bool cropMirrored;
@property (nonatomic, strong) MKPaintingData *paintingData;
@property (nonatomic, assign) NSTimeInterval trimStartValue;
@property (nonatomic, assign) NSTimeInterval trimEndValue;
@property (nonatomic, assign) bool sendAsGif;
@property (nonatomic, assign) TGMediaVideoConversionPreset preset;

@property (nonatomic, weak) MKPhotoEditorPreviewView *previewOutput;
@property (nonatomic, readonly) NSArray *tools;

@property (nonatomic, readonly) bool processing;
@property (nonatomic, readonly) bool readyForProcessing;

- (instancetype)initWithOriginalSize:(CGSize)originalSize adjustments:(id<MKMediaEditAdjustments>)adjustments forVideo:(bool)forVideo;

- (void)cleanup;

- (void)setImage:(UIImage *)image forCropRect:(CGRect)cropRect cropRotation:(CGFloat)cropRotation cropOrientation:(UIImageOrientation)cropOrientation cropMirrored:(bool)cropMirrored fullSize:(bool)fullSize;

- (void)processAnimated:(bool)animated completion:(void (^)(void))completion;

- (void)createResultImageWithCompletion:(void (^)(UIImage *image))completion;
- (UIImage *)currentResultImage;

- (bool)hasDefaultCropping;

- (SSignal *)histogramSignal;

- (id<MKMediaEditAdjustments>)exportAdjustments;
- (id<MKMediaEditAdjustments>)exportAdjustmentsWithPaintingData:(MKPaintingData *)paintingData;

@end

#import "SSignal.h"
#import <MediaEditorKit/MKVideoEditAdjustments.h>

@interface MKMediaVideoFileWatcher : NSObject
{
    NSURL *_fileURL;
}

- (void)setupWithFileURL:(NSURL *)fileURL;
- (id)fileUpdated:(bool)completed;

@end


@interface MKMediaVideoConverter : NSObject

+ (SSignal *)convertAVAsset:(AVAsset *)avAsset adjustments:(TGMediaVideoEditAdjustments *)adjustments watcher:(MKMediaVideoFileWatcher *)watcher;
+ (SSignal *)convertAVAsset:(AVAsset *)avAsset adjustments:(TGMediaVideoEditAdjustments *)adjustments watcher:(MKMediaVideoFileWatcher *)watcher inhibitAudio:(bool)inhibitAudio;
+ (SSignal *)hashForAVAsset:(AVAsset *)avAsset adjustments:(TGMediaVideoEditAdjustments *)adjustments;

+ (NSUInteger)estimatedSizeForPreset:(TGMediaVideoConversionPreset)preset duration:(NSTimeInterval)duration hasAudio:(bool)hasAudio;
+ (TGMediaVideoConversionPreset)bestAvailablePresetForDimensions:(CGSize)dimensions;
+ (CGSize)_renderSizeWithCropSize:(CGSize)cropSize;

+ (CGSize)dimensionsFor:(CGSize)dimensions adjustments:(TGMediaVideoEditAdjustments *)adjustments preset:(TGMediaVideoConversionPreset)preset;

@end


@interface MKMediaVideoConversionResult : NSObject

@property (nonatomic, readonly) NSURL *fileURL;
@property (nonatomic, readonly) NSUInteger fileSize;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) CGSize dimensions;
@property (nonatomic, readonly) UIImage *coverImage;
@property (nonatomic, readonly) id liveUploadData;

- (NSDictionary *)dictionary;

@end


@interface MKMediaVideoConversionPresetSettings : NSObject

+ (CGSize)maximumSizeForPreset:(TGMediaVideoConversionPreset)preset;
+ (NSDictionary *)videoSettingsForPreset:(TGMediaVideoConversionPreset)preset dimensions:(CGSize)dimensions;
+ (NSDictionary *)audioSettingsForPreset:(TGMediaVideoConversionPreset)preset;


//REMOVE

+ (bool)showVMSize;
+ (void)setShowVMSize:(bool)on;

+ (NSInteger)vmSide;
+ (NSInteger)vmBitrate;

+ (void)setVMSide:(NSInteger)side;
+ (void)setVMBitrate:(NSInteger)bitrate;

@end

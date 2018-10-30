#import "TGMediaAsset+TGMediaEditableItem.h"
#import <MediaEditorKit/TGMediaAssetImageSignals.h>
#import <MediaEditorKit/MediaEditorKit.h>
#import "SSignal+Take.h"
#import <MediaEditorKit/MKPhotoEditorUtils.h>

@implementation TGMediaAsset (TGMediaEditableItem)

- (CGSize)originalSize
{
    if (![TGMediaAssetImageSignals usesPhotoFramework])
        return TGFitSize(self.dimensions, TGMediaAssetImageLegacySizeLimit);
    
    return self.dimensions;
}

- (SSignal *)thumbnailImageSignal
{
    if (self.backingImage != nil) {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
                {
                    [subscriber putNext:self.backingImage];
                    [subscriber putCompletion];
                    return nil;
                }];
    }
    CGFloat scale = MIN(2.0f, TGScreenScaling());
    CGFloat thumbnailImageSide = TGPhotoThumbnailSizeForCurrentScreen().width * scale;
    
    return [TGMediaAssetImageSignals imageForAsset:self imageType:TGMediaAssetImageTypeAspectRatioThumbnail size:CGSizeMake(thumbnailImageSide, thumbnailImageSide)];
}

- (SSignal *)screenImageSignal:(NSTimeInterval)__unused position
{
    if (self.backingImage != nil) {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
                {
                    [subscriber putNext:self.backingImage];
                    [subscriber putCompletion];
                    return nil;
                }];
    }
    return [TGMediaAssetImageSignals imageForAsset:self imageType:TGMediaAssetImageTypeScreen size:TGPhotoEditorScreenImageMaxSize()];
}

- (SSignal *)originalImageSignal:(NSTimeInterval)position
{
    if (self.backingImage != nil) {
        return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
                {
                    [subscriber putNext:self.backingImage];
                    [subscriber putCompletion];
                    return nil;
                }];
    }
    
    if (self.isVideo)
        return [TGMediaAssetImageSignals videoThumbnailForAsset:self size:self.dimensions timestamp:CMTimeMakeWithSeconds(position, NSEC_PER_SEC)];
    
    return [[TGMediaAssetImageSignals imageForAsset:self imageType:TGMediaAssetImageTypeFullSize size:CGSizeZero] takeLast];
}

@end

#import <MediaEditorKit/MKMediaEditingContext.h>

@class MKPaintingData;

@interface MKPhotoEditorValues : NSObject <MKMediaEditAdjustments>

@property (nonatomic, readonly) CGFloat cropRotation;
@property (nonatomic, readonly) NSDictionary *toolValues;

- (bool)toolsApplied;

+ (instancetype)editorValuesWithOriginalSize:(CGSize)originalSize cropRect:(CGRect)cropRect cropRotation:(CGFloat)cropRotation cropOrientation:(UIImageOrientation)cropOrientation cropLockedAspectRatio:(CGFloat)cropLockedAspectRatio cropMirrored:(bool)cropMirrored toolValues:(NSDictionary *)toolValues paintingData:(MKPaintingData *)paintingData;

@end

#import "GPUImageOutput.h"

@interface MKPhotoEditorPicture : GPUImageOutput

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithImage:(UIImage *)image textureOptions:(GPUTextureOptions)textureOptions;

- (bool)processSynchronous:(bool)synchronous completion:(void (^)(void))completion;

@end

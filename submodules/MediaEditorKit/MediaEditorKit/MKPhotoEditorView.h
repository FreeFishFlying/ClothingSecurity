#import <UIKit/UIKit.h>

#import "GPUImageContext.h"

@interface MKPhotoEditorView : UIView <GPUImageInput>

@property (nonatomic, assign) bool enabled;

@end

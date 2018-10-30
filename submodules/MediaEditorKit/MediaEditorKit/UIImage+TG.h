#import <UIKit/UIKit.h>

@class TGImageLuminanceMap;
@class TGStaticBackdropImageData;

@interface UIImage (TG)

- (void)setExtendedEdgeInsets:(UIEdgeInsets)edgeInsets;

- (bool)degraded;
- (void)setDegraded:(bool)degraded;

- (void)setEdited:(bool)edited;

@end

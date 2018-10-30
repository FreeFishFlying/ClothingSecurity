#import <UIKit/UIKit.h>

@interface TGMemoryImageCache : NSObject

- (instancetype)initWithSoftMemoryLimit:(NSUInteger)softMemoryLimit hardMemoryLimit:(NSUInteger)hardMemoryLimit;

- (void)setImage:(UIImage *)image forKey:(NSString *)key attributes:(NSDictionary *)attributes;
- (UIImage *)imageForKey:(NSString *)key attributes:(__autoreleasing NSDictionary **)attributes;

@end

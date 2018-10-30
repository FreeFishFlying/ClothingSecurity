#import <Foundation/Foundation.h>

@class POPSpringAnimation;

@interface MKPhotoEditorAnimation : NSObject

+ (POPSpringAnimation *)prepareTransitionAnimationForPropertyNamed:(NSString *)propertyName;
+ (void)performBlock:(void (^)(bool allFinished))block whenCompletedAllAnimations:(NSArray *)animations;

@end

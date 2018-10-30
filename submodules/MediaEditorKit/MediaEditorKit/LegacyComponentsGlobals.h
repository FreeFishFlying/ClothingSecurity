#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <MediaEditorKit/LegacyComponentsAccessChecker.h>

@class SSignal;
@class SThreadPool;
@protocol SDisposable;
@class TGLocalization;
@class UIViewController;
@class TGWallpaperInfo;
@class TGMemoryImageCache;
@class TGImageMediaAttachment;

typedef enum {
    TGAudioSessionTypePlayVoice,
    TGAudioSessionTypePlayMusic,
    TGAudioSessionTypePlayVideo,
    TGAudioSessionTypePlayEmbedVideo,
    TGAudioSessionTypePlayAndRecord,
    TGAudioSessionTypePlayAndRecordHeadphones,
    TGAudioSessionTypeCall
} TGAudioSessionType;

@protocol LegacyComponentsGlobalsProvider <NSObject>

- (TGLocalization *)effectiveLocalization;
- (void)log:(NSString *)string;
- (NSArray<UIWindow *> *)applicationWindows;
- (UIWindow *)applicationStatusBarWindow;
- (UIWindow *)applicationKeyboardWindow;

- (UIInterfaceOrientation)applicationStatusBarOrientation;
- (void)forceStatusBarAppearanceUpdate;

- (void)disableUserInteractionFor:(NSTimeInterval)timeInterval;

@end

@interface LegacyComponentsGlobals : NSObject

+ (void)setProvider:(id<LegacyComponentsGlobalsProvider>)provider;
+ (id<LegacyComponentsGlobalsProvider>)provider;

@end

#ifdef __cplusplus
extern "C" {
#endif
UIImage *TGComponentsImageNamed(NSString *name);
NSString *TGComponentsPathForResource(NSString *name, NSString *type);
#ifdef __cplusplus
}
#endif


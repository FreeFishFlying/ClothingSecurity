#import <Foundation/Foundation.h>
#import <MediaEditorKit/MediaEditorKit.h>

@interface MKLegacyComponentsContext : NSObject <LegacyComponentsContext>

+ (MKLegacyComponentsContext *)shared;

@end

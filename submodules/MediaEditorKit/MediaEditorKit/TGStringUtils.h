#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TGStringUtils : NSObject

+ (NSString *)md5:(NSString *)string;
+ (NSString *)md5ForData:(NSData *)data;

+ (NSString *)stringForFileSize:(int64_t)size precision:(NSInteger)precision;

@end


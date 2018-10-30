#import "TGStringUtils.h"
#import "LegacyComponentsInternal.h"
#import <CommonCrypto/CommonDigest.h>

typedef struct {
    __unsafe_unretained NSString *escapeSequence;
    unichar uchar;
} HTMLEscapeMap;


@implementation TGStringUtils

+ (NSString *)md5:(NSString *)string
{
    /*static const char *md5PropertyKey = "MD5Key";
     NSString *result = objc_getAssociatedObject(string, md5PropertyKey);
     if (result != nil)
     return result;*/
    
    const char *ptr = [string UTF8String];
    unsigned char md5Buffer[16];
    CC_MD5(ptr, (CC_LONG)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], md5Buffer);
    NSString *output = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];
    //objc_setAssociatedObject(string, md5PropertyKey, output, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return output;
}

+ (NSString *)md5ForData:(NSData *)data {
    unsigned char md5Buffer[16];
    CC_MD5(data.bytes, (CC_LONG)data.length, md5Buffer);
    NSString *output = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];
    return output;
}

+ (NSString *)stringForFileSize:(int64_t)size precision:(NSInteger)precision
{
    NSString *string = @"";
    if (size < 1024)
    {
        string = [[NSString alloc] initWithFormat:TGLocalized(@"FileSize.B"), [[NSString alloc] initWithFormat:@"%d", (int)size]];}
    else if (size < 1024 * 1024)
    {
        string = [[NSString alloc] initWithFormat:TGLocalized(@"FileSize.KB"), [[NSString alloc] initWithFormat:@"%d", (int)(size / 1024)]];
    }
    else
    {
        NSString *format = [NSString stringWithFormat:@"%%0.%df", (int)precision];
        string = [[NSString alloc] initWithFormat:TGLocalized(@"FileSize.MB"), [[NSString alloc] initWithFormat:format, (CGFloat)(size / 1024.0f / 1024.0f)]];
    }
    
    return string;
}

@end


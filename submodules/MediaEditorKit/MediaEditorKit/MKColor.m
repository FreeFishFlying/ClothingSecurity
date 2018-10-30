#import "MKColor.h"

UIColor *MKColorWithHex(int hex)
{
    return [[UIColor alloc] initWithRed:(((hex >> 16) & 0xff) / 255.0f) green:(((hex >> 8) & 0xff) / 255.0f) blue:(((hex) & 0xff) / 255.0f) alpha:1.0f];
}

UIColor *MKColorWithHexAndAlpha(int hex, CGFloat alpha)
{
    return [[UIColor alloc] initWithRed:(((hex >> 16) & 0xff) / 255.0f) green:(((hex >> 8) & 0xff) / 255.0f) blue:(((hex) & 0xff) / 255.0f) alpha:alpha];
}

UIColor *MKAccentColor() {
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = MKColorWithHex(0x007ee5);
    });
    return color;
}
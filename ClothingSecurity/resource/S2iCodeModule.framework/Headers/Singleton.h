


//.h

#define single_interface(class) + (class *)shared##class;

//.m
// \ 代表下一行也属于宏
// ##是分隔符
#define single_implementation(class) \
static class *_instance; \
\
+ (class *)shared##class \
{ \
    if (_instance == nil) { \
        _instance = [[self alloc] init]; \
    } \
    return _instance; \
} \
 \
+ (id)allocWithZone:(NSZone *)zone \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        _instance = [super allocWithZone:zone]; \
    }); \
    return _instance; \
}

//#define S2i_DISTBW [[[S2iClientManager sharedS2iClientManager]detectParmsArray][0] integerValue]
//#define S2i_ABSMAX [[[S2iClientManager sharedS2iClientManager]detectParmsArray][1] integerValue]
//#define S2i_M1RANGE [[[S2iClientManager sharedS2iClientManager]detectParmsArray][2] integerValue]
//#define S2i_MSEQSNR [[[S2iClientManager sharedS2iClientManager]detectParmsArray][3] integerValue]
//#define S2i_ZOOMSIGNAL [[[S2iClientManager sharedS2iClientManager]detectParmsArray][4] integerValue]
//#define S2i_SHARPNESS [[[S2iClientManager sharedS2iClientManager]detectParmsArray][5] integerValue]
//#define S2i_BRIGHTNESS [[[S2iClientManager sharedS2iClientManager]detectParmsArray][6] integerValue]
//#define S2i_BRIGHTNESSMAX [[[S2iClientManager sharedS2iClientManager]detectParmsArray][7] integerValue]

#define S2i_DISTBW        [[[S2iClientManager sharedS2iClientManager]getDeviceConfigInfo].minDistanceBlackWhite intValue]
//#define S2i_ABSMAX        [[S2iClientManager sharedS2iClientManager]getDeviceConfigInfo].
#define S2i_M1RANGE       [[[S2iClientManager sharedS2iClientManager]getDeviceConfigInfo].minIntensitive intValue]
#define S2i_MSEQSNR       [[[S2iClientManager sharedS2iClientManager]getDeviceConfigInfo].minSNR intValue]
//#define S2i_ZOOMSIGNAL    [[S2iClientManager sharedS2iClientManager]getDeviceConfigInfo].
#define S2i_SHARPNESS     [[[S2iClientManager sharedS2iClientManager]getDeviceConfigInfo].minSharpness intValue]
#define S2i_BRIGHTNESS    [[[S2iClientManager sharedS2iClientManager]getDeviceConfigInfo].minBrightness intValue]
#define S2i_BRIGHTNESSMAX [[[S2iClientManager sharedS2iClientManager]getDeviceConfigInfo].maxBrightness intValue]
#define S2i_FACTORMIN [[[S2iClientManager sharedS2iClientManager]getDeviceConfigInfo].minRescaleFactor floatValue]
#define S2i_FACTORMAX [[[S2iClientManager sharedS2iClientManager]getDeviceConfigInfo].maxRescaleFactor floatValue]

typedef NS_ENUM(NSUInteger, S2iLanguage) {
    S2iLanguageNOSET,
    S2iLanguageZh,
    S2iLanguageEn,
};
#define S2iLog(...) NSLog(__VA_ARGS__)

#import "MKPaintSlice.h"
#import "SQueue.h"
#import "MKPainting.h"
#import <MediaEditorKit/TGPaintUtils.h>

@interface MKPaintSlice ()
{
    NSData *_data;
    NSString *_fileName;
}
@end

@implementation MKPaintSlice

- (instancetype)initWithData:(NSData *)data bounds:(CGRect)bounds
{
    self = [super init];
    if (self != nil)
    {
        _bounds = bounds;
        _data = data;
        _fileName = [self _generatefileName];
        
        [[MKPaintSlice queue] dispatch:^
        {
            [TGPaintGZipDeflate(_data) writeToFile:_fileName atomically:true];
            [[SQueue mainQueue] dispatch:^
            {
                _data = nil;
            }];
        }];
    }
    return self;
}

- (void)dealloc
{
    if (_fileName != nil)
        [[NSFileManager defaultManager] removeItemAtPath:_fileName error:NULL];
}

- (instancetype)swappedSliceForPainting:(MKPainting *)painting
{
    NSData *paintingData = nil;
    [painting imageDataForRect:self.bounds resultPaintingData:&paintingData];
    return [[MKPaintSlice alloc] initWithData:paintingData bounds:self.bounds];
}

- (NSData *)data
{
    if (_data != nil)
        return _data;
    else if (_fileName != nil)
        return TGPaintGZipInflate([[NSData alloc] initWithContentsOfFile:_fileName]);
    else
        return nil;
}

- (NSString *)_generatefileName
{
    static uint32_t identifier = 0;
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%u.slice", identifier++]];
}

+ (SQueue *)queue
{
    static dispatch_once_t onceToken;
    static SQueue *queue;
    dispatch_once(&onceToken, ^
    {
        queue = [SQueue wrapConcurrentNativeQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)];
    });
    return queue;
}

@end

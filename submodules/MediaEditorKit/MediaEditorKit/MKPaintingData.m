#import "MKPaintingData.h"
#import "SQueue.h"
#import "TGPaintUtils.h"
#import "MKPhotoPaintStickerEntity.h"
#import "MKMediaEditingContext.h"
#import "MKPaintUndoManager.h"

@interface MKPaintingData ()
{
    UIImage *_image;
    NSData *_data;
    
    UIImage *(^_imageRetrievalBlock)(void);
}
@end

@implementation MKPaintingData

+ (instancetype)dataWithPaintingData:(NSData *)data image:(UIImage *)image entities:(NSArray *)entities undoManager:(MKPaintUndoManager *)undoManager
{
    MKPaintingData *paintingData = [[MKPaintingData alloc] init];
    paintingData->_data = data;
    paintingData->_image = image;
    paintingData->_entities = entities;
    paintingData->_undoManager = undoManager;
    return paintingData;
}

+ (instancetype)dataWithPaintingImagePath:(NSString *)imagePath
{
    MKPaintingData *paintingData = [[MKPaintingData alloc] init];
    paintingData->_imagePath = imagePath;
    return paintingData;
}

+ (void)storePaintingData:(MKPaintingData *)data inContext:(MKMediaEditingContext *)context forItem:(id<TGMediaEditableItem>)item forVideo:(bool)video
{
    [[MKPaintingData queue] dispatch:^
    {
        NSURL *dataUrl = nil;
        NSURL *imageUrl = nil;
        
        NSData *compressedData = TGPaintGZipDeflate(data.data);
        [context setPaintingData:compressedData image:data.image forItem:item dataUrl:&dataUrl imageUrl:&imageUrl forVideo:video];
        
        __weak MKMediaEditingContext *weakContext = context;
        [[SQueue mainQueue] dispatch:^
        {
            data->_dataPath = dataUrl.path;
            data->_imagePath = imageUrl.path;
            data->_data = nil;
            
            data->_imageRetrievalBlock = ^UIImage *
            {
                __strong MKMediaEditingContext *strongContext = weakContext;
                if (strongContext != nil)
                    return [strongContext paintingImageForItem:item];
                
                return nil;
            };
        }];
    }];
}

+ (void)facilitatePaintingData:(MKPaintingData *)data
{
    [[MKPaintingData queue] dispatch:^
    {
        if (data->_imagePath != nil)
            data->_image = nil;
    }];
}

- (void)dealloc
{
    [self.undoManager reset];
}

- (NSData *)data
{
    if (_data != nil)
        return _data;
    else if (_dataPath != nil)
        return TGPaintGZipInflate([[NSData alloc] initWithContentsOfFile:_dataPath]);
    else
        return nil;
}

- (UIImage *)image
{
    if (_image != nil)
        return _image;
    else if (_imageRetrievalBlock != nil)
        return _imageRetrievalBlock();
    else
        return nil;
}

- (NSArray *)stickers
{
    NSMutableSet *stickers = [[NSMutableSet alloc] init];
    for (MKPhotoPaintEntity *entity in self.entities)
    {
        if ([entity isKindOfClass:[MKPhotoPaintStickerEntity class]])
            [stickers addObject:((MKPhotoPaintStickerEntity *)entity).document];
    }
    return [stickers allObjects];
}

- (BOOL)isEqual:(id)object
{
    if (object == self)
        return true;
    
    if (!object || ![object isKindOfClass:[self class]])
        return false;
    
    MKPaintingData *data = (MKPaintingData *)object;
    return [data.entities isEqual:self.entities] && ((data.data != nil && [data.data isEqualToData:self.data]) || (data.data == nil && self.data == nil));
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MKPaintUndoManager;
@class MKMediaEditingContext;
@protocol TGMediaEditableItem;

@interface MKPaintingData : NSObject

@property (nonatomic, readonly) NSString *imagePath;
@property (nonatomic, readonly) NSString *dataPath;
@property (nonatomic, readonly) NSArray *entities;
@property (nonatomic, readonly) MKPaintUndoManager *undoManager;
@property (nonatomic, readonly) NSArray *stickers;

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) UIImage *image;

+ (instancetype)dataWithPaintingData:(NSData *)data image:(UIImage *)image entities:(NSArray *)entities undoManager:(MKPaintUndoManager *)undoManager;

+ (instancetype)dataWithPaintingImagePath:(NSString *)imagePath;

+ (void)storePaintingData:(MKPaintingData *)data inContext:(MKMediaEditingContext *)context forItem:(id<TGMediaEditableItem>)item forVideo:(bool)video;
+ (void)facilitatePaintingData:(MKPaintingData *)data;

@end

#import <Foundation/Foundation.h>

@class MKPainting;
@class MKPhotoEntitiesContainerView;

@interface MKPaintUndoManager : NSObject <NSCopying>

@property (nonatomic, weak) MKPainting *painting;
@property (nonatomic, weak) MKPhotoEntitiesContainerView *entitiesContainer;

@property (nonatomic, copy) void (^historyChanged)(void);

@property (nonatomic, readonly) bool canUndo;
- (void)registerUndoWithUUID:(NSInteger)uuid block:(void (^)(MKPainting *, MKPhotoEntitiesContainerView *, NSInteger))block;
- (void)unregisterUndoWithUUID:(NSInteger)uuid;

- (void)undo;

- (void)reset;

@end

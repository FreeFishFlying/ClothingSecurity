#import <MediaEditorKit/SGraphNode.h>

@interface SGraphListNode : SGraphNode

@property (nonatomic, strong) NSArray *items;

- (id)initWithItems:(NSArray *)items;

@end

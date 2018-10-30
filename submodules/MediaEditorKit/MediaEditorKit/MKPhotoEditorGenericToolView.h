#import "MKPhotoEditorToolView.h"
#import "MKPhotoEditorItem.h"

@interface MKPhotoEditorGenericToolView : UIView <MKPhotoEditorToolView>

- (instancetype)initWithEditorItem:(id<MKPhotoEditorItem>)editorItem;
- (instancetype)initWithEditorItem:(id<MKPhotoEditorItem>)editorItem explicit:(bool)explicit nameWidth:(CGFloat)nameWidth;

@end

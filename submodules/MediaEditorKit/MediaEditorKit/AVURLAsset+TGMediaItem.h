#import <AVFoundation/AVFoundation.h>
#import <MediaEditorKit/TGMediaSelectionContext.h>
#import <MediaEditorKit/MKMediaEditingContext.h>

@interface AVURLAsset (TGMediaItem) <TGMediaSelectableItem, TGMediaEditableItem>

@end

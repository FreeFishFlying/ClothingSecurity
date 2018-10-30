#import <UIKit/UIKit.h>

@interface MKPhotoEditorToolButtonsView : UIView

@property (nonatomic, copy) void(^cancelPressed)(void);
@property (nonatomic, copy) void(^confirmPressed)(void);

- (instancetype)initWithCancelButton:(NSString *)cancelButton doneButton:(NSString *)doneButton;

- (void)calculateLandscapeSizeForPossibleButtonTitles:(NSArray *)possibleButtonTitles;
- (CGFloat)landscapeSize;

@end

extern const CGFloat TGPhotoEditorToolButtonsViewSize;

#import <MediaEditorKit/MKPhotoEditorButton.h>

typedef enum
{
    MKPhotoEditorNoneTab        = 0,
    MKPhotoEditorCropTab        = 1 << 0,
    MKPhotoEditorRotateTab      = 1 << 1,
    MKPhotoEditorPaintTab       = 1 << 2,
    MKPhotoEditorTextTab        = 1 << 3,
    MKPhotoEditorQualityTab     = 1 << 4,
    MKPhotoEditorEraserTab      = 1 << 5,
    MKPhotoEditorMirrorTab      = 1 << 6,
    MKPhotoEditorAspectRatioTab = 1 << 7
} MKPhotoEditorTab;

typedef enum
{
    MKPhotoEditorBackButtonBack,
    MKPhotoEditorBackButtonCancel
} MKPhotoEditorBackButton;

typedef enum
{
    MKPhotoEditorDoneButtonSend,
    MKPhotoEditorDoneButtonCheck
} MKPhotoEditorDoneButton;

@interface MKPhotoToolbarView : UIView

@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

@property (nonatomic, readonly) UIButton *doneButton;

@property (nonatomic, copy) void(^cancelPressed)(void);
@property (nonatomic, copy) void(^donePressed)(void);

@property (nonatomic, copy) void(^doneLongPressed)(id sender);

@property (nonatomic, copy) void(^tabPressed)(MKPhotoEditorTab tab);

@property (nonatomic, readonly) CGRect cancelButtonFrame;

- (instancetype)initWithBackButton:(MKPhotoEditorBackButton)backButton doneButton:(MKPhotoEditorDoneButton)doneButton solidBackground:(bool)solidBackground;

- (void)transitionInAnimated:(bool)animated;
- (void)transitionInAnimated:(bool)animated transparent:(bool)transparent;
- (void)transitionOutAnimated:(bool)animated;
- (void)transitionOutAnimated:(bool)animated transparent:(bool)transparent hideOnCompletion:(bool)hideOnCompletion;

- (void)setDoneButtonEnabled:(bool)enabled animated:(bool)animated;
- (void)setEditButtonsEnabled:(bool)enabled animated:(bool)animated;
- (void)setEditButtonsHidden:(bool)hidden animated:(bool)animated;
- (void)setEditButtonsHighlighted:(MKPhotoEditorTab)buttons;
- (void)setEditButtonsDisabled:(MKPhotoEditorTab)buttons;

@property (nonatomic, readonly) MKPhotoEditorTab currentTabs;
- (void)setToolbarTabs:(MKPhotoEditorTab)tabs animated:(bool)animated;

- (void)setActiveTab:(MKPhotoEditorTab)tab;

- (void)setInfoString:(NSString *)string;

- (MKPhotoEditorButton *)buttonForTab:(MKPhotoEditorTab)tab;

@end

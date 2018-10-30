#import "MKPhotoToolbarView.h"
#import "LegacyComponentsInternal.h"
#import "TGModernButton.h"
#import "MKPhotoEditorButton.h"

@interface MKPhotoToolbarView ()
{
    UIView *_backgroundView;
    
    UIView *_buttonsWrapperView;
    TGModernButton *_cancelButton;
    TGModernButton *_doneButton;
    
    UILabel *_infoLabel;
    
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
    
    bool _transitionedOut;
}
@end

@implementation MKPhotoToolbarView

- (instancetype)initWithBackButton:(MKPhotoEditorBackButton)backButton doneButton:(MKPhotoEditorDoneButton)doneButton solidBackground:(bool)solidBackground
{
    self = [super initWithFrame:CGRectZero];
    if (self != nil)
    {
        _interfaceOrientation = [[LegacyComponentsGlobals provider] applicationStatusBarOrientation];
        
        _backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _backgroundView.backgroundColor = (solidBackground ? [MKPhotoEditorInterfaceAssets toolbarBackgroundColor] : [MKPhotoEditorInterfaceAssets toolbarTransparentBackgroundColor]);
        [self addSubview:_backgroundView];
        
        _buttonsWrapperView = [[UIView alloc] initWithFrame:_backgroundView.bounds];
        [_backgroundView addSubview:_buttonsWrapperView];
        
        _cancelButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 49, 49)];
        _cancelButton.exclusiveTouch = true;
        _cancelButton.adjustsImageWhenHighlighted = false;
        
        switch (backButton)
        {
            case MKPhotoEditorBackButtonCancel:
                [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
                break;
                
            default:
                [_cancelButton setTitle:@"返回" forState:UIControlStateNormal];
                break;
        }
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView addSubview:_cancelButton];
        
        CGSize buttonSize = CGSizeMake(49.0f, 49.0f);
        _doneButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, buttonSize.width, buttonSize.height)];
        switch (doneButton)
        {
            case MKPhotoEditorDoneButtonCheck:
                [_doneButton setTitle:@"确认" forState:UIControlStateNormal];
                break;
                
            default:
                [_doneButton setTitle:@"发送" forState:UIControlStateNormal];
                break;
        }
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _doneButton.exclusiveTouch = true;
        _doneButton.adjustsImageWhenHighlighted = false;
        [_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundView addSubview:_doneButton];
        
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doneButtonLongPressed:)];
        _longPressGestureRecognizer.minimumPressDuration = 0.65;
        [_doneButton addGestureRecognizer:_longPressGestureRecognizer];
    }
    return self;
}

- (UIButton *)doneButton
{
    return _doneButton;
}

- (MKPhotoEditorButton *)createButtonForTab:(MKPhotoEditorTab)editorTab
{
    MKPhotoEditorButton *button = [[MKPhotoEditorButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    button.tag = editorTab;
    [button addTarget:self action:@selector(tabButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    switch (editorTab)
    {
        case MKPhotoEditorCropTab:
            button.iconImage = [MKPhotoEditorInterfaceAssets cropIcon];
            break;

        case MKPhotoEditorRotateTab:
            button.iconImage = [MKPhotoEditorInterfaceAssets rotateIcon];
            button.dontHighlightOnSelection = true;
            break;
            
        case MKPhotoEditorPaintTab:
            button.iconImage = [MKPhotoEditorInterfaceAssets paintIcon];
            break;
            
        case MKPhotoEditorTextTab:
            button.iconImage = [MKPhotoEditorInterfaceAssets textIcon];
            button.dontHighlightOnSelection = true;
            break;
            
        case MKPhotoEditorQualityTab:
            button.iconImage = [MKPhotoEditorInterfaceAssets qualityIconForPreset:TGMediaVideoConversionPresetCompressedMedium];
            button.dontHighlightOnSelection = true;
            break;
            
        case MKPhotoEditorEraserTab:
            button.iconImage = [MKPhotoEditorInterfaceAssets eraserIcon];
            break;
            
        case MKPhotoEditorMirrorTab:
            button.iconImage = [MKPhotoEditorInterfaceAssets mirrorIcon];
            button.dontHighlightOnSelection = true;
            break;
            
        case MKPhotoEditorAspectRatioTab:
            [button setIconImage:[MKPhotoEditorInterfaceAssets aspectRatioIcon] activeIconImage:[MKPhotoEditorInterfaceAssets aspectRatioActiveIcon]];
            button.dontHighlightOnSelection = true;
            break;
        default:
            button = nil;
            break;
    }
    
    return button;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    bool inside = [super pointInside:point withEvent:event];
    if ([_doneButton pointInside:[self convertPoint:point toView:_doneButton] withEvent:nil])
        return true;
    
    return inside;
}

- (void)setToolbarTabs:(MKPhotoEditorTab)tabs animated:(bool)animated
{
    if (tabs == _currentTabs)
        return;
    
    UIView *transitionView = nil;
    if (animated && _currentTabs != MKPhotoEditorNoneTab)
    {
        transitionView = [_buttonsWrapperView snapshotViewAfterScreenUpdates:false];
        transitionView.frame = _buttonsWrapperView.frame;
        [_buttonsWrapperView.superview addSubview:transitionView];
    }
    
    _currentTabs = tabs;
    
    NSArray *buttons = [_buttonsWrapperView.subviews copy];
    for (UIView *view in buttons)
        [view removeFromSuperview];
    
    if (_currentTabs & MKPhotoEditorCropTab)
        [_buttonsWrapperView addSubview:[self createButtonForTab:MKPhotoEditorCropTab]];
    if (_currentTabs & MKPhotoEditorPaintTab)
        [_buttonsWrapperView addSubview:[self createButtonForTab:MKPhotoEditorPaintTab]];
    if (_currentTabs & MKPhotoEditorEraserTab)
        [_buttonsWrapperView addSubview:[self createButtonForTab:MKPhotoEditorEraserTab]];
    if (_currentTabs & MKPhotoEditorTextTab)
        [_buttonsWrapperView addSubview:[self createButtonForTab:MKPhotoEditorTextTab]];
    if (_currentTabs & MKPhotoEditorRotateTab)
        [_buttonsWrapperView addSubview:[self createButtonForTab:MKPhotoEditorRotateTab]];
    if (_currentTabs & MKPhotoEditorQualityTab)
        [_buttonsWrapperView addSubview:[self createButtonForTab:MKPhotoEditorQualityTab]];
    if (_currentTabs & MKPhotoEditorMirrorTab)
        [_buttonsWrapperView addSubview:[self createButtonForTab:MKPhotoEditorMirrorTab]];
    if (_currentTabs & MKPhotoEditorAspectRatioTab)
        [_buttonsWrapperView addSubview:[self createButtonForTab:MKPhotoEditorAspectRatioTab]];
    
    [self setNeedsLayout];
    
    if (animated)
    {
        _buttonsWrapperView.alpha = 0.0f;
        [UIView animateWithDuration:0.15 animations:^
        {
            _buttonsWrapperView.alpha = 1.0f;
            transitionView.alpha = 0.0f;
        } completion:^(__unused BOOL finished)
        {
            [transitionView removeFromSuperview];
        }];
    }
}

- (CGRect)cancelButtonFrame
{
    return _cancelButton.frame;
}

- (void)cancelButtonPressed
{
    if (self.cancelPressed != nil)
        self.cancelPressed();
}

- (void)doneButtonPressed
{
    if (self.donePressed != nil)
        self.donePressed();
}

- (void)doneButtonLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if (self.doneLongPressed != nil)
            self.doneLongPressed(_doneButton);
    }
}

- (void)tabButtonPressed:(MKPhotoEditorButton *)sender
{
    if (self.tabPressed != nil)
        self.tabPressed((int)sender.tag);
}

- (void)setActiveTab:(MKPhotoEditorTab)tab
{
    for (MKPhotoEditorButton *button in _buttonsWrapperView.subviews)
        [button setSelected:(button.tag == tab) animated:false];
}

- (void)setDoneButtonEnabled:(bool)enabled animated:(bool)animated
{
    _doneButton.userInteractionEnabled = enabled;
    
    if (animated)
    {
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             _doneButton.alpha = enabled ? 1.0f : 0.2f;
         } completion:nil];
    }
    else
    {
        _doneButton.alpha = enabled ? 1.0f : 0.2f;
    }
}

- (void)setEditButtonsEnabled:(bool)enabled animated:(bool)animated
{
    _buttonsWrapperView.userInteractionEnabled = enabled;
    
    if (animated)
    {
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^
        {
            _buttonsWrapperView.alpha = enabled ? 1.0f : 0.2f;
        } completion:nil];
    }
    else
    {
        _buttonsWrapperView.alpha = enabled ? 1.0f : 0.2f;
    }
}

- (void)setEditButtonsHidden:(bool)hidden animated:(bool)animated
{
    CGFloat targetAlpha = hidden ? 0.0f : 1.0f;
    
    if (animated)
    {
        for (MKPhotoEditorButton *button in _buttonsWrapperView.subviews)
            button.hidden = false;
        
        [UIView animateWithDuration:0.2f
                         animations:^
        {
            for (MKPhotoEditorButton *button in _buttonsWrapperView.subviews)
                button.alpha = targetAlpha;
        } completion:^(__unused BOOL finished)
        {
            for (MKPhotoEditorButton *button in _buttonsWrapperView.subviews)
                button.hidden = hidden;
        }];
    }
    else
    {
        for (MKPhotoEditorButton *button in _buttonsWrapperView.subviews)
        {
            button.alpha = (float)targetAlpha;
            button.hidden = hidden;
        }
    }
}

- (void)setEditButtonsHighlighted:(MKPhotoEditorTab)buttons
{
    for (MKPhotoEditorButton *button in _buttonsWrapperView.subviews)
        button.active = (buttons & button.tag);
}

- (void)setEditButtonsDisabled:(MKPhotoEditorTab)buttons
{
    for (MKPhotoEditorButton *button in _buttonsWrapperView.subviews)
        button.disabled = (buttons & button.tag);
}

- (MKPhotoEditorButton *)buttonForTab:(MKPhotoEditorTab)tab
{
    for (MKPhotoEditorButton *button in _buttonsWrapperView.subviews)
    {
        if (button.tag == tab)
            return button;
    }
    return nil;
}

- (void)layoutSubviews
{
    CGRect backgroundFrame = self.bounds;
    if (!_transitionedOut)
    {
        _backgroundView.frame = backgroundFrame;
    }
    else
    {
        if (self.frame.size.width > self.frame.size.height)
        {
            _backgroundView.frame = CGRectMake(backgroundFrame.origin.x, backgroundFrame.size.height, backgroundFrame.size.width, backgroundFrame.size.height);
        }
        else
        {
            if (_interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                _backgroundView.frame = CGRectMake(-backgroundFrame.size.width, backgroundFrame.origin.y, backgroundFrame.size.width, backgroundFrame.size.height);
            }
            else
            {
                _backgroundView.frame = CGRectMake(backgroundFrame.size.width, backgroundFrame.origin.y, backgroundFrame.size.width, backgroundFrame.size.height);
            }
        }
    }
    _buttonsWrapperView.frame = _backgroundView.bounds;
    
    NSArray *buttons = _buttonsWrapperView.subviews;
    
    CGFloat offset = 8.0f;
    if (self.frame.size.width > self.frame.size.height)
    {
        if (buttons.count == 1)
        {
            UIView *button = buttons.firstObject;
            button.frame = CGRectMake(CGFloor(self.frame.size.width / 2 - button.frame.size.width / 2), offset, button.frame.size.width, button.frame.size.height);
        }
        else if (buttons.count == 2)
        {
            UIView *leftButton = buttons.firstObject;
            UIView *rightButton = buttons.lastObject;
            
            leftButton.frame = CGRectMake(CGFloor(self.frame.size.width / 5 * 2 - 5 - leftButton.frame.size.width / 2), offset, leftButton.frame.size.width, leftButton.frame.size.height);
            rightButton.frame = CGRectMake(CGCeil(self.frame.size.width - leftButton.frame.origin.x - rightButton.frame.size.width), offset, rightButton.frame.size.width, rightButton.frame.size.height);
        }
        else if (buttons.count == 3)
        {
            UIView *leftButton = buttons.firstObject;
            UIView *centerButton = [buttons objectAtIndex:1];
            UIView *rightButton = buttons.lastObject;
            
            centerButton.frame = CGRectMake(CGFloor(self.frame.size.width / 2 - centerButton.frame.size.width / 2), offset, centerButton.frame.size.width, centerButton.frame.size.height);

            leftButton.frame = CGRectMake(CGFloor(self.frame.size.width / 6 * 2 - 10 - leftButton.frame.size.width / 2), offset, leftButton.frame.size.width, leftButton.frame.size.height);
            
            rightButton.frame = CGRectMake(CGCeil(self.frame.size.width - leftButton.frame.origin.x - rightButton.frame.size.width), offset, rightButton.frame.size.width, rightButton.frame.size.height);
        }
        else if (buttons.count == 4)
        {
            UIView *leftButton = buttons.firstObject;
            UIView *centerLeftButton = [buttons objectAtIndex:1];
            UIView *centerRightButton = [buttons objectAtIndex:2];
            UIView *rightButton = buttons.lastObject;
            
            leftButton.frame = CGRectMake(CGFloor(self.frame.size.width / 8 * 2 - 3 - leftButton.frame.size.width / 2), offset, leftButton.frame.size.width, leftButton.frame.size.height);
            
            centerLeftButton.frame = CGRectMake(CGFloor(self.frame.size.width / 10 * 4 + 5 - centerLeftButton.frame.size.width / 2), offset, centerLeftButton.frame.size.width, centerLeftButton.frame.size.height);
            
            centerRightButton.frame = CGRectMake(CGCeil(self.frame.size.width - centerLeftButton.frame.origin.x - centerRightButton.frame.size.width), offset, centerRightButton.frame.size.width, centerRightButton.frame.size.height);
            
            rightButton.frame = CGRectMake(CGCeil(self.frame.size.width - leftButton.frame.origin.x - rightButton.frame.size.width), offset, rightButton.frame.size.width, rightButton.frame.size.height);
        }
        
        _cancelButton.frame = CGRectMake(0, 0, 49, 49);
        CGFloat offset = 49.0f;
        if (_doneButton.frame.size.width > 49.0f)
            offset = 60.0f;
        
        _doneButton.frame = CGRectMake(self.frame.size.width - offset, 49.0f - offset, _doneButton.frame.size.width, _doneButton.frame.size.height);
        
        _infoLabel.frame = CGRectMake(49.0f + 10.0f, 0.0f, self.frame.size.width - (49.0f + 10.0f) * 2.0f, 49.0f);
    }
    else
    {
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            offset = self.frame.size.width - [buttons.firstObject frame].size.width - offset;
        
        if (buttons.count == 1)
        {
            UIView *button = buttons.firstObject;
            button.frame = CGRectMake(offset, CGFloor((self.frame.size.height - button.frame.size.height) / 2), button.frame.size.width, button.frame.size.height);
        }
        else if (buttons.count == 2)
        {
            UIView *topButton = buttons.firstObject;
            UIView *bottomButton = buttons.lastObject;
            
            topButton.frame = CGRectMake(offset, CGFloor(self.frame.size.height / 5 * 2 - 10 - topButton.frame.size.height / 2), topButton.frame.size.width, topButton.frame.size.height);
            bottomButton.frame = CGRectMake(offset, CGCeil(self.frame.size.height - topButton.frame.origin.y - bottomButton.frame.size.height), bottomButton.frame.size.width, bottomButton.frame.size.height);
        }
        else if (buttons.count == 3)
        {
            UIView *topButton = buttons.firstObject;
            UIView *centerButton = [buttons objectAtIndex:1];
            UIView *bottomButton = buttons.lastObject;
            
            topButton.frame = CGRectMake(offset, CGFloor(self.frame.size.height / 6 * 2 - 10 - topButton.frame.size.height / 2), topButton.frame.size.width, topButton.frame.size.height);
            centerButton.frame = CGRectMake(offset, CGFloor((self.frame.size.height - centerButton.frame.size.height) / 2), centerButton.frame.size.width, centerButton.frame.size.height);
            bottomButton.frame = CGRectMake(offset, CGCeil(self.frame.size.height - topButton.frame.origin.y - bottomButton.frame.size.height), bottomButton.frame.size.width, bottomButton.frame.size.height);
        }
        else if (buttons.count == 4)
        {
            UIView *topButton = buttons.firstObject;
            UIView *centerTopButton = [buttons objectAtIndex:1];
            UIView *centerBottonButton = [buttons objectAtIndex:2];
            UIView *bottomButton = buttons.lastObject;
            
            topButton.frame = CGRectMake(offset, CGFloor(self.frame.size.height / 8 * 2 - 3 - topButton.frame.size.height / 2), topButton.frame.size.width, topButton.frame.size.height);
            
            centerTopButton.frame = CGRectMake(offset, CGFloor(self.frame.size.height / 10 * 4 + 5 - centerTopButton.frame.size.height / 2), centerTopButton.frame.size.width, centerTopButton.frame.size.height);
            
            centerBottonButton.frame = CGRectMake(offset, CGCeil(self.frame.size.height - centerTopButton.frame.origin.y - centerBottonButton.frame.size.height), centerBottonButton.frame.size.width, centerBottonButton.frame.size.height);
            
            bottomButton.frame = CGRectMake(offset, CGCeil(self.frame.size.height - topButton.frame.origin.y - bottomButton.frame.size.height), bottomButton.frame.size.width, bottomButton.frame.size.height);
        }
    
        CGFloat offset = self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ? self.frame.size.width - 49.0f : 0.0f;
        _cancelButton.frame = CGRectMake(offset, self.frame.size.height - 49, 49, 49);
        _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        _doneButton.frame = CGRectMake(offset, 0.0f, 49.0f, 49.0f);
        _doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        _infoLabel.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
        _infoLabel.bounds = CGRectMake(0.0f, 0.0f, self.frame.size.height - (49.0f + 10.0f) * 2.0f, self.frame.size.width);
        
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            _infoLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
        else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            _infoLabel.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }
    }
}

- (void)transitionInAnimated:(bool)animated
{
    [self transitionInAnimated:animated transparent:false];
}

- (void)transitionInAnimated:(bool)animated transparent:(bool)transparent
{
    _transitionedOut = false;
    self.backgroundColor = transparent ? [UIColor clearColor] : [UIColor blackColor];
    
    void (^animationBlock)(void) = ^
    {
        if (self.frame.size.width > self.frame.size.height)
            _backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x, 0, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
        else
            _backgroundView.frame = CGRectMake(0, _backgroundView.frame.origin.y, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
    };
    
    void (^completionBlock)(BOOL) = ^(BOOL finished)
    {
        if (finished)
            self.backgroundColor = [UIColor clearColor];
    };
    
    if (animated)
    {
        if (self.frame.size.width > self.frame.size.height)
        {
            _backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x, _backgroundView.frame.size.height, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
        }
        else
        {
            if (_interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                _backgroundView.frame = CGRectMake(-_backgroundView.frame.size.width, _backgroundView.frame.origin.y, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
            }
            else
            {
                _backgroundView.frame = CGRectMake(_backgroundView.frame.size.width, _backgroundView.frame.origin.y, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
            }
        }
        
        if (iosMajorVersion() >= 7)
            [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveLinear animations:animationBlock completion:completionBlock];
        else
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:animationBlock completion:completionBlock];
    }
    else
    {
        animationBlock();
        completionBlock(true);
    }
}

- (void)transitionOutAnimated:(bool)animated
{
    [self transitionOutAnimated:animated transparent:false hideOnCompletion:false];
}

- (void)transitionOutAnimated:(bool)animated transparent:(bool)transparent hideOnCompletion:(bool)hideOnCompletion
{
    _transitionedOut = true;
    
    void (^animationBlock)(void) = ^
    {
        if (self.frame.size.width > self.frame.size.height)
        {
            _backgroundView.frame = CGRectMake(_backgroundView.frame.origin.x, _backgroundView.frame.size.height, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
        }
        else
        {
            if (_interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                _backgroundView.frame = CGRectMake(-_backgroundView.frame.size.width, _backgroundView.frame.origin.y, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
            }
            else
            {
                _backgroundView.frame = CGRectMake(_backgroundView.frame.size.width, _backgroundView.frame.origin.y, _backgroundView.frame.size.width, _backgroundView.frame.size.height);
            }
        }
    };
    
    void (^completionBlock)(BOOL) = ^(__unused BOOL finished)
    {
        if (hideOnCompletion)
            self.hidden = true;
    };
    
    self.backgroundColor = transparent ? [UIColor clearColor] : [UIColor blackColor];
    
    if (animated)
    {
        if (iosMajorVersion() >= 7)
            [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveLinear animations:animationBlock completion:completionBlock];
        else
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:animationBlock completion:completionBlock];
    }
    else
    {
        animationBlock();
        completionBlock(true);
    }
}

- (void)setInfoString:(NSString *)string
{
    if (_infoLabel == nil)
    {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.font = [UIFont systemFontOfSize:13];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.textColor = [UIColor whiteColor];
        [_backgroundView addSubview:_infoLabel];
    }
    
    _infoLabel.text = string;
    [self setNeedsLayout];
}

@end

//
//  ViewController.m
//  Test
//
//  Created by kingxt on 2018/1/7.
//  Copyright © 2018年 Telegram. All rights reserved.
//

#import "ViewController.h"

@import MediaEditorKit;

@interface ViewController ()
{
    TGMediaAsset *_asset;
    id<MKMediaEditAdjustments> _adjustments;
    MKMediaEditingContext *_editingContext;
}
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        [self.view addSubview:_imageView];
        _imageView.frame = CGRectMake(100, 100, 200, 200);
        _imageView.userInteractionEnabled = true;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = true;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(preview)];
        [_imageView addGestureRecognizer:tap];
    }
    return _imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _editingContext = [MKMediaEditingContext new];
    [[[TGMediaAssetsLibrary sharedLibrary] cameraRollGroup] startWithNext:^(TGMediaAssetGroup *group) {
        [[[TGMediaAssetsLibrary sharedLibrary] assetsOfAssetGroup:group reversed:true] startWithNext:^(TGMediaAssetFetchResult *mediaFetchResult) {
            _asset = [mediaFetchResult assetAtIndex:0];
            
            
            [[[TGMediaAssetImageSignals imageForAsset:_asset imageType:TGMediaAssetImageTypeFastScreen size:CGSizeMake(1280, 1280)] deliverOn:[SQueue mainQueue]] startWithNext:^(id next) {
                if ([next isKindOfClass:[UIImage class]]) {
                    self.imageView.image = next;
                }
            }];
        }];
    }];
}

- (void)preview {
    dispatch_async(dispatch_get_main_queue(), ^{
        MKPhotoEditorController *controller = [[MKPhotoEditorController alloc] initWithAsset:_asset intent:MKPhotoEditorControllerGenericIntent adjustments:_adjustments caption:nil screenImage:nil availableTabs:MKPhotoEditorCropTab | MKPhotoEditorPaintTab selectedTab:MKPhotoEditorCropTab];
        controller.editingContext = _editingContext;
        controller.cropLockedAspectRatio = 1;
//        controller.beginTransitionIn = ^UIView *(CGRect *referenceFrame, __unused UIView **parentView)
//        {
//            *referenceFrame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
//            return self.imageView;
//        };
//        controller.beginTransitionOut = ^UIView *(CGRect *referenceFrame, __unused UIView **parentView)
//        {
//            *parentView = self.imageView;
//
//            CGRect refFrame = self.imageView.frame;
//            *referenceFrame = refFrame;
//
//            return self.imageView;
//        };
        controller.requestThumbnailImage = ^(id<TGMediaEditableItem> editableItem)
        {
            return [editableItem thumbnailImageSignal];
        };
        
        controller.requestOriginalScreenSizeImage = ^(id<TGMediaEditableItem> editableItem, NSTimeInterval position)
        {
            return [editableItem screenImageSignal:position];
        };
        
        controller.requestOriginalFullSizeImage = ^(id<TGMediaEditableItem> editableItem, NSTimeInterval position)
        {
            return [editableItem originalImageSignal:position];
        };
        
        controller.didFinishEditing = ^(id<MKMediaEditAdjustments> adjustments, UIImage *resultImage, UIImage *thumbnailImage, bool hasChanges)
        {
            self->_adjustments = adjustments;
            NSLog(@"ae");
        };
        controller.skipInitialTransition = true;
        controller.finishedTransitionOut = ^(bool saved) {
            
        };
        [self presentViewController:controller animated:true completion:nil];
//        [self addChildViewController:controller];
//        [self.view addSubview:controller.view];
    });
}

@end

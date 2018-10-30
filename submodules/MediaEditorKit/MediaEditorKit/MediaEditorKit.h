#if __IPHONE_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>
#else
#import <Foundation/Foundation.h>
#endif

//! Project version number for LegacyComponents.
FOUNDATION_EXPORT double LegacyComponentsVersionNumber;

//! Project version string for LegacyComponents.
FOUNDATION_EXPORT const unsigned char LegacyComponentsVersionString[];


#import <MediaEditorKit/LegacyComponentsGlobals.h>
#import <MediaEditorKit/LegacyComponentsContext.h>
#import <MediaEditorKit/TGStringUtils.h>
#import <MediaEditorKit/MKImageUtils.h>
#import <MediaEditorKit/Freedom.h>
#import <MediaEditorKit/FreedomUIKit.h>
#import <MediaEditorKit/MKHacks.h>
#import <MediaEditorKit/TGObserverProxy.h>
#import <MediaEditorKit/TGModernCache.h>
#import <MediaEditorKit/TGMemoryImageCache.h>
#import <MediaEditorKit/LegacyComponentsAccessChecker.h>
#import <MediaEditorKit/TGWeakDelegate.h>

#import <MediaEditorKit/ActionStage.h>
#import <MediaEditorKit/ASActor.h>
#import <MediaEditorKit/ASHandle.h>
#import <MediaEditorKit/ASQueue.h>
#import <MediaEditorKit/ASWatcher.h>
#import <MediaEditorKit/SGraphListNode.h>
#import <MediaEditorKit/SGraphNode.h>
#import <MediaEditorKit/SGraphObjectNode.h>

#import <MediaEditorKit/TGAnimationBlockDelegate.h>
#import <MediaEditorKit/UIImage+TG.h>
#import <MediaEditorKit/TGModernButton.h>
#import <MediaEditorKit/UIControl+HitTestEdgeInsets.h>
#import <MediaEditorKit/TGMessageImageViewOverlayView.h>

#import <MediaEditorKit/MKProgressSpinnerView.h>
#import <MediaEditorKit/MKProgressWindow.h>

#import <MediaEditorKit/MKViewController.h>
#import <MediaEditorKit/MKOverlayController.h>
#import <MediaEditorKit/MKOverlayControllerWindow.h>

#import <MediaEditorKit/TGMediaAssetsLibrary.h>
#import <MediaEditorKit/TGMediaAssetsModernLibrary.h>
#import <MediaEditorKit/TGMediaAsset.h>
#import <MediaEditorKit/TGMediaAssetFetchResult.h>
#import <MediaEditorKit/TGMediaAssetFetchResultChange.h>
#import <MediaEditorKit/TGMediaAssetGroup.h>
#import <MediaEditorKit/TGMediaAssetMoment.h>
#import <MediaEditorKit/TGMediaAssetMomentList.h>
#import <MediaEditorKit/TGMediaAssetImageSignals.h>
#import <MediaEditorKit/TGMediaSelectionContext.h>
#import <MediaEditorKit/MKMediaEditingContext.h>
#import <MediaEditorKit/MKPhotoEditorController.h>

#import <MediaEditorKit/MKPhotoEditorUtils.h>
#import <MediaEditorKit/MKPhotoEditorValues.h>
#import <MediaEditorKit/MKVideoEditAdjustments.h>
#import <MediaEditorKit/AVURLAsset+TGMediaItem.h>
#import <MediaEditorKit/UIImage+MKMediaEditableItem.h>
#import <MediaEditorKit/MKMediaVideoConverter.h>

#import <MediaEditorKit/MKPhotoEditorAnimation.h>
#import <MediaEditorKit/MKPhotoToolbarView.h>

#import <MediaEditorKit/MKPaintingData.h>
#import <MediaEditorKit/TGPaintUtils.h>
#import <MediaEditorKit/MKPhotoPaintEntity.h>
#import <MediaEditorKit/MKPhotoPaintStickerEntity.h>
#import <MediaEditorKit/MKPaintUndoManager.h>

#import <MediaEditorKit/TGMemoryImageCache.h>
#import <MediaEditorKit/LegacyComponentsAccessChecker.h>

#import <MediaEditorKit/MKPhotoEditorSliderView.h>

#import <MediaEditorKit/MKLegacyComponentsContext.h>

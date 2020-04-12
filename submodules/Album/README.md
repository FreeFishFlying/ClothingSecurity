# Album

[![CI Status](http://img.shields.io/travis/Dylan Wang/Album.svg?style=flat)](https://travis-ci.org/Dylan Wang/Album)
[![Version](https://img.shields.io/cocoapods/v/Album.svg?style=flat)](http://cocoapods.org/pods/Album)
[![License](https://img.shields.io/cocoapods/l/Album.svg?style=flat)](http://cocoapods.org/pods/Album)
[![Platform](https://img.shields.io/cocoapods/p/Album.svg?style=flat)](http://cocoapods.org/pods/Album)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Album is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Album"
```

## Album Picker 


Album picker support select multi asset for image and video and also support asset preview

<img src="Preview/albumpreview.gif" width="200">

``` swift
let albumConfig = AlbumConfig(style: .multiChooseEnableChooseOriginalImage,
confirmTitle: SLLocalized("Send"),
confirmCallback: { (_: [MediaAsset], _) in
self.navigationController?.dismiss(animated: true, completion: nil)
},
cancelCallback: { _ in
self.navigationController?.dismiss(animated: true, completion: nil)
})

navigationController?.present(UINavigationController(rootViewController: AlbumFolderViewController(config: albumConfig)), animated: true, completion: nil)
```

Usaged within objective-c

``` objc
AlbumConfig *config = [[AlbumConfig alloc] initWithStyle:MediaAssetsPickerStyleMultiChooseEnableChooseOriginalImage confirmCallback:^(NSArray<MediaAsset *> * media, BOOL selectedOriginalImage) {
[self dismissViewControllerAnimated:true completion:nil];
} cancelCallback:^{
[self dismissViewControllerAnimated:true completion:nil];
}];

AlbumFolderViewController *folderController = [[AlbumFolderViewController alloc] initWithConfig:config];
[self presentViewController:[[UINavigationController alloc] initWithRootViewController:folderController] animated:true completion:^{
}];
```

## Author

Dylan Wang, dylan@liao.com

## License

Album is available under the MIT license. See the LICENSE file for more info.

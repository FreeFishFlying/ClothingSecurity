# Powerful network framework include normal file and image request & upload

1. Image download is modified from Kingfisher, and used Alamofire as the backend network request.
2. File download support watch the file upload or download progress anywhere and anytime.
3. Detail network request log, Logic layer can modify the request before request such as modify the host to retry and so on.
4. Accelerated gif player with GPU mp4 as backend.
5. Avoid same resource concurrent download
6. Cached MeshUploader response data for later upload same resource.
### 1. File uploader

Use MeshUploaderManager to upload local file path or phAssetLocalIdentifier(identifier from Photos) 

``` swift
public func upload(fileURL: URL, sessionId: String, mediaType: MeshUploadType, options: MeshUploaderOptionsInfo = MeshUpLoaderEmptyOptionsInfo)
public func upload(phAssetLocalIdentifier: String, sessionId: String, mediaType: MeshUploadType, options: MeshUploaderOptionsInfo = MeshUpLoaderEmptyOptionsInfo)
```

Application can use the second method to fast choose hundreds of image or video without prefetch into memory.
Developer can observe the upload result use follow method. It return a signal producer present the progress, complete and error.

``` swift
public func watch(sessionId: String) -> SignalProducer<FileUploadChange, UploadError> 
```

### 2. File downloader

The file download interface is very easy, just see the file FileDownloader.swift file, it provide the follow method.

``` swift
public func download(with url: URL,
                         destination: URL,
                            options: MeshLoaderOptionsInfo? = nil,
                            progressBlock: MeshDownloaderProgressBlock? = nil,
                            completionHandler: MeshDownloaderCompletionHandler? = nil) -> MeshDownloadTask? 

public func watch(url: URL) -> SignalProducer<FileDownloadChange, NSError>
public func isDownloading(url: URL) -> Bool
public func cancelDownloading(url: URL)
```

### 3. GIF play

``` swift
let imageView = AcceleratedAnimationImageView(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
let url = URL(string: "https://raw.githubusercontent.com/liyong03/YLGIFImage/master/YLGIFImageDemo/YLGIFImageDemo/joy.gif")!
imageView.setGifImage(with: url)
view.addSubview(imageView)
```

If play the demo url with normal gif decode, it will cost 600M memory, and if play with AcceleratedAnimationImageView, it only cost 2-3M memory.

### 4. equest modify

Developer can modify any url request before perform request with RequestModifier interface.

``` swift
public protocol RequestModifier {
    
    /// Modify the request and perform change 
    ///
    /// - Parameters:
    ///   - request: request
    ///   - tryStep: tryStep try request step
    /// - Returns: return next fire request time interval from now
    func modified(for request: URLRequest, tryStep: Int) -> (URLRequest, TimeInterval)?
}
```

With the method, developer can delay the url request or modify request parameters or host, such as replace the host for retry. 

### 5. Data compressor

With data compressor, Developer could modify the upload data before do upload.

``` swift
public protocol UploadDataCompressor {
    //compress image to data
    func compress(image: UIImage) -> Data?
    //compress data with uploadtype
    func compress(data: Data, type: MeshUploadType) -> Data?
    //compress local url which has not loaded into memeory
    func compress(url: URL) -> URL?
}
```


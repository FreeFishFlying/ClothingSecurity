//
//  MediaPaintViewController.swift
//  Album
//
//  Created by kingxt on 11/24/17.
//

import Foundation
import Core

class MediaPaintViewController: UIViewController, MediaEditor {
    
    private let editorContext: MediaEditorContext
    private let animationContext: AnimationTranslationContext
    
    var paletteView: Palette!
    var toolBar: ToolBar!
    var canvasView: Canvas!
    
    public init(editorContext: MediaEditorContext, animationContext: AnimationTranslationContext) {
        self.editorContext = editorContext
        self.animationContext = animationContext
        super.init(nibName: nil, bundle: nil)
    }
    
    public var backgroundColor: UIColor = .black {
        didSet {
            if isViewLoaded {
                view.backgroundColor = backgroundColor
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
        animationContext.stateChangeSignal().startWithValues { [weak self] state in
            switch state {
            case .willTranslationOut:
                self?.imageView.isHidden = true
                self?.paletteView?.isHidden = true
                self?.toolBar?.isHidden = true
            default: break
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.reset()
        if canvasView.canClear() {
            canvasView.clear()
        }
        if let thumbnailSignal = editorContext.thumbnailSignal {
            thumbnailSignal.take(during: reactive.lifetime).startWithValues({ image in
                if let image = image {
                    self.imageView.image = self.editorContext.editorResult.applyTo(image: image)
                    self.layoutCanvas()
                }
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutCanvas()
    }
    
    private func layoutCanvas() {
        guard let image = imageView.image else {
            return
        }
        let displaySize = ImageUtils.scaleToSize(size: image.size, maxSize: self.imageView.frame.size)
        let displayFrame = CGRect(origin: CGPoint(x: imageView.frame.origin.x + (imageView.frame.size.width - displaySize.width) / 2, y: imageView.frame.origin.y + imageView.frame.origin.y + (imageView.frame.size.height - displaySize.height) / 2), size: displaySize)
        self.canvasView.frame = displayFrame
    }
    
    public override func loadView() {
        super.loadView()
        view.addSubview(imageView)
        
        setupPalette()
        setupToolBar()
        
        imageView.snp.makeConstraints { (make) in
            make.left.equalTo(MediaEditorController.previewImageViewGap)
            make.right.equalTo(-MediaEditorController.previewImageViewGap)
            make.top.equalTo(0)
            make.bottom.equalTo(-MediaEditorController.operationViewHeight)
        }
    
        setupCanvas()
        
        view.layoutSubviews()
    }
    
    fileprivate func setupPalette() {
        let paletteView = Palette()
        paletteView.delegate = self
        paletteView.setup()
        self.view.addSubview(paletteView)
        self.paletteView = paletteView
        let paletteHeight = paletteView.paletteHeight()
        paletteView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(paletteHeight)
            make.bottom.equalToSuperview().offset(-30)
        }
    }
    
    fileprivate func setupToolBar() {
        let toolBar = ToolBar()
        toolBar.undoButton?.addTarget(self, action: #selector(onClickUndoButton), for: .touchUpInside)
        toolBar.redoButton?.addTarget(self, action: #selector(onClickRedoButton), for: .touchUpInside)
        toolBar.clearButton?.addTarget(self, action: #selector(onClickClearButton), for: .touchUpInside)
        self.view.addSubview(toolBar)
        toolBar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(paletteView!.snp.top)
            make.height.equalTo(40)
        }
        self.toolBar = toolBar
    }
    
    fileprivate func setupCanvas() {
        let canvasView = Canvas()
        canvasView.frame = imageView.frame
        canvasView.delegate = self
        self.view.addSubview(canvasView)
        self.canvasView = canvasView
    }
    
    @objc func onClickUndoButton() {
        self.canvasView.undo()
    }
    
    @objc func onClickRedoButton() {
        self.canvasView.redo()
    }
    
    @objc func onClickClearButton() {
        self.canvasView.clear()
    }
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animationTranslationInView() -> UIView {
        return imageView
    }
    
    func animationTranslationOutView(isCancelled: Bool) -> UIView? {
        guard let image = self.imageView.image else {
            return self.imageView
        }
        let imageView = UIImageView()
        imageView.image = editorContext.editorResult.editorImage ?? editorContext.editorResult.applyTo(image: image)
        imageView.frame = view.convert(self.canvasView.frame, to: view.window!)
        return imageView
    }
    
    func fillResult(result: MediaEditorResult) {
        if isViewLoaded && canvasView.canClear() {
            if result.paintHostImage == nil {
                result.paintHostImage = imageView.image
            }
            result.paintHostImage = result.cropResult?.apply(image: result.paintHostImage)
            result.cropResult = nil
            if let image = result.paintHostImage {
                result.paintHostImage = UIImage.imageByCombiningImage(firstImage: image, withImage: canvasView.mergePathsAndImages())
            }
        }
    }
    
    func tabBarImage() -> UIImage? {
        return MediaEditorImageNamed("PhotoEditorPaint")
    }
}

extension MediaPaintViewController: PaletteDelegate {
    
}

extension MediaPaintViewController: CanvasDelegate {
    func brush() -> Brush? {
        return self.paletteView?.currentBrush()
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?) {
        updateToolBarButtonStatus(canvas)
        paletteView?.hidePickerView()
    }
    
    fileprivate func updateToolBarButtonStatus(_ canvas: Canvas) {
        self.toolBar?.undoButton?.isEnabled = canvas.canUndo()
        self.toolBar?.redoButton?.isEnabled = canvas.canRedo()
        self.toolBar?.clearButton?.isEnabled = canvas.canClear()
    }
}

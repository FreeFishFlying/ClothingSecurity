final class ActionSheetView: AlertControllerView {

    @IBOutlet private var primaryView: UIView!
    @IBOutlet private weak var cancelActionView: UIView?
    @IBOutlet private weak var cancelLabel: UILabel?
    @IBOutlet private weak var cancelButton: UIButton?
    @IBOutlet private var contentViewConstraints: [NSLayoutConstraint]!
    @IBOutlet private var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var cancelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var titleWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var titleLabelTopMargin: NSLayoutConstraint!
    @IBOutlet weak var actionsTopMargin: NSLayoutConstraint!
    
    override var actionTappedHandler: ((AlertAction) -> Void)? {
        didSet { self.actionsCollectionView.actionTapped = self.actionTappedHandler }
    }

    override var visualStyle: AlertVisualStyle! {
        didSet {
            let widthOffset = self.visualStyle.contentPadding.left + self.visualStyle.contentPadding.right
            self.titleWidthConstraint.constant -= widthOffset
        }
    }

    private var cancelAction: AlertAction? {
        didSet { self.cancelLabel?.attributedText = self.cancelAction?.attributedTitle }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.backgroundColor = .clear
    }

    override func prepareLayout() {
        self.assignCancelAction()

        super.prepareLayout()
        createBackground()
        
        self.collectionViewHeightConstraint.constant = self.actionsCollectionView.displayHeight
        self.collectionViewHeightConstraint.isActive = true

        self.primaryView.layer.cornerRadius = self.visualStyle.cornerRadius
        self.primaryView.layer.masksToBounds = true
        self.cancelActionView?.layer.cornerRadius = self.visualStyle.cornerRadius
        self.cancelActionView?.layer.masksToBounds = true

        if let backgroundColor = self.visualStyle.backgroundColor {
            self.primaryView.backgroundColor = backgroundColor
            self.cancelActionView?.backgroundColor = backgroundColor
        } else {
            primaryView.backgroundColor = .clear
        }
        
        self.cancelLabel?.font = self.visualStyle.font(for: self.cancelAction)
        self.cancelLabel?.textColor = self.visualStyle.textColor(for: self.cancelAction) ?? self.tintColor
        self.cancelLabel?.attributedText = self.cancelAction?.attributedTitle

        let cancelButtonBackground = UIImage.image(with: self.visualStyle.actionHighlightColor)
        self.cancelButton?.setBackgroundImage(cancelButtonBackground, for: .highlighted)
        self.cancelHeightConstraint.constant = self.visualStyle.actionViewSize.height

        let showContentView = self.contentView.subviews.count > 0
        self.contentView.isHidden = !showContentView
        self.contentViewConstraints.forEach { $0.isActive = showContentView }
        
        if showContentView {
            contentView.snp.updateConstraints { (make) in
                make.height.equalTo(contentHeight)
            }
        }
        let titleEmpty = titleLabel.text == nil || titleLabel.text!.isEmpty
        let messageEmpty = messageLabel.text == nil || messageLabel.text!.isEmpty
        if titleEmpty && messageEmpty {
            actionsTopMargin.constant = 0
            titleLabelTopMargin.constant = 14
        }
    }
    
    private func createBackground() {
        let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        primaryView.insertSubview(backgroundView, at: 0)
        backgroundView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    private var contentHeight: CGFloat {
        var value: CGFloat = 0
        self.contentView.subviews.forEach { (view) in
            value = max(view.frame.size.height, value)
        }
        if value == 0 {
            return 0
        }
        return value + self.visualStyle.contentPadding.bottom
    }
    
    override var intrinsicContentSize: CGSize {
        let totalHeight = self.contentHeight + self.actionsCollectionView.displayHeight
        return CGSize(width: UIView.noIntrinsicMetric, height: totalHeight)
    }

    override func highlightAction(for sender: UIPanGestureRecognizer) {
        super.highlightAction(for: sender)
        let cancelIsSelected = self.cancelActionView?.frame.contains(sender.location(in: self)) == true
        self.cancelButton?.isHighlighted = cancelIsSelected

        if cancelIsSelected && sender.state == .ended {
            self.cancelButton?.sendActions(for: .touchUpInside)
        }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.cancelLabel?.textColor = self.visualStyle.textColor(for: self.cancelAction) ?? self.tintColor
    }

    @IBAction private func cancelTapped() {
        guard let action = self.cancelAction else {
            return
        }

        self.actionTappedHandler?(action)
    }

    private func assignCancelAction() {
        if let cancelActionIndex = self.actions.index(where: { $0.style == .preferred }) {
            self.cancelAction = self.actions[cancelActionIndex]
            self.actions.remove(at: cancelActionIndex)
        } else {
            self.cancelAction = self.actions.first
            self.actions.removeFirst()
        }
    }
}

private extension UIImage {

    class func image(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)

        let context = UIGraphicsGetCurrentContext()!
        color.setFill()
        context.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }
}

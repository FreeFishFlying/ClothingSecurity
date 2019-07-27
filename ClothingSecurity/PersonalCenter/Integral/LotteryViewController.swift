//
//  LotteryViewController.swift
//  Labeauty
//
//  Created by 宋昌鹏 on 2019/4/7.
//  Copyright © 2019 scpUpCloud. All rights reserved.
//

import Foundation

let lotteryItemWidth: Int = 104

class LotteryViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = localizedString("integralDraw")
        automaticallyAdjustsScrollViewInsets = false
        configLottery()
    }
    
    private func configLottery() {
        view.addSubview(scroolView)
        scroolView.backgroundColor = UIColor(hexString: "#FFF3F3")
        scroolView.frame.size.width = ScreenWidth
        scroolView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTopLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        scroolView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(517)
        }
        scroolView.addSubview(titleImage)
        titleImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
        scroolView.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(144)
            make.width.height.equalTo(346)
            make.centerX.equalToSuperview()
        }
        scroolView.addSubview(tipView)
        tipView.snp.makeConstraints { make in
            make.bottom.equalTo(container.snp.top).offset(14)
            make.centerX.equalToSuperview()
            make.width.equalTo(143)
            make.height.equalTo(28)
        }
        tipView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        scroolView.addSubview(activityTitleLabel)
        activityTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bgView.snp.bottom).offset(22)
        }
        scroolView.addSubview(firstTip)
        firstTip.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(35)
            make.top.equalTo(activityTitleLabel.snp.bottom).offset(19)
            make.width.height.equalTo(15)
        }
        scroolView.addSubview(firstTipLabel)
        firstTipLabel.snp.makeConstraints { make in
            make.left.equalTo(firstTip.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(firstTip).offset(-3)
        }
        scroolView.addSubview(secondTip)
        secondTip.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(35)
            make.top.equalTo(firstTip.snp.bottom).offset(17)
            make.width.height.equalTo(15)
        }
        scroolView.addSubview(secondTipLabel)
        secondTipLabel.snp.makeConstraints { make in
            make.top.equalTo(secondTip.snp.top).offset(-3)
            make.left.equalTo(secondTip.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        scroolView.addSubview(thirdTip)
        thirdTip.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(35)
            make.top.equalTo(secondTipLabel.snp.bottom).offset(14)
            make.width.height.equalTo(15)
        }
        scroolView.addSubview(thirdTipLabel)
        thirdTipLabel.snp.makeConstraints { make in
            make.top.equalTo(thirdTip.snp.top).offset(-3)
            make.left.equalTo(thirdTip.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        view.layoutIfNeeded()
        scroolView.contentSize = CGSize(width: 0, height: 772)
    }
    
    private let container: LotteryContainer = LotteryContainer()
    
    private let bgView: UIImageView = {
        let view = UIImageView()
        view.image = imageNamed("lotterybg")
        return view
    }()
    
    private let scroolView: UIScrollView = {
        let scrool = UIScrollView()
        scrool.isScrollEnabled = true
        return scrool
    }()
    
    private let titleImage: UIImageView = {
        let view = UIImageView()
        view.image = imageNamed("luckTitle")
        return view
    }()
    
    private let tipView: UIView = {
        let style = UIView()
        style.layer.cornerRadius = 14
        style.layer.backgroundColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0).cgColor
        style.alpha = 1
        return style
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: localizedString("everyDraw"))
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Regular", size: 14.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 116.0 / 255.0, green: 171.0 / 255.0, blue: 217.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: 7))
        label.attributedText = attributedString
        return label
    }()
    
    private let activityTitleLabel: UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "活动说明")
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 17.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 176.0 / 255.0, green: 205.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 0, length: 2))
        attributedString.addAttributes([
            NSAttributedString.Key.font: UIFont(name: "PingFangSC-Semibold", size: 17.0)!,
            NSAttributedString.Key.foregroundColor:UIColor(red: 139.0 / 255.0, green: 139.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
            ], range: NSRange(location: 2, length: 2))
        label.attributedText = attributedString
        return label
    }()
    
    private let firstTip: TipsOrderView = {
        let tip = TipsOrderView()
        tip.order = "1"
        return tip
    }()
    
    private let firstTipLabel: UILabel = {
        let label = UILabel()
        label.text = "如果您获得的积分将自动存入您的账户内；"
        label.font = systemFontSize(fontSize: 14)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let secondTip: TipsOrderView = {
        let tip = TipsOrderView()
        tip.order = "2"
        return tip
    }()
    
    private let secondTipLabel: UILabel = {
        let label = UILabel()
        label.text = "如果您获得的是实物奖品，请您及时填写地址我们将送到您的手上；"
        label.font = systemFontSize(fontSize: 14)
        label.numberOfLines = 0
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
    
    private let thirdTip: TipsOrderView = {
        let tip = TipsOrderView()
        tip.order = "3"
        return tip
    }()
    
    private let thirdTipLabel: UILabel = {
        let label = UILabel()
        label.text = "本次活动最终解释权归我公司所有。"
        label.font = systemFontSize(fontSize: 14)
        label.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        return label
    }()
}


class LotteryContainer: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    private func configUI() {
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.height.equalTo(346)
            make.centerX.equalToSuperview()
        }
        addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(lotteryItemWidth * 3)
        }
        for i in 0...2 {
            let item = LotteryItem.init(frame: .zero)
            item.itemTag = ItemTag(rawValue: i)
            container.addSubview(item)
            item.snp.makeConstraints { make in
                make.width.height.equalTo(lotteryItemWidth)
                make.top.equalToSuperview().offset(CGFloat((i/3) * lotteryItemWidth))
                make.left.equalToSuperview().offset(CGFloat((i%3) * lotteryItemWidth))
            }
        }
        
        let item_3 = LotteryItem.init(frame: .zero)
        item_3.itemTag = ItemTag(rawValue: 3)
        container.addSubview(item_3)
        item_3.snp.makeConstraints { make in
            make.width.height.equalTo(lotteryItemWidth)
            make.top.equalToSuperview().offset(CGFloat(lotteryItemWidth))
            make.left.equalToSuperview().offset(CGFloat(2 * lotteryItemWidth))
        }
        
        let item_4 = LotteryItem.init(frame: .zero)
        item_4.itemTag = ItemTag(rawValue: 4)
        container.addSubview(item_4)
        item_4.snp.makeConstraints { make in
            make.width.height.equalTo(lotteryItemWidth)
            make.top.equalToSuperview().offset(CGFloat(2 * lotteryItemWidth))
            make.left.equalToSuperview().offset(CGFloat(2 * lotteryItemWidth))
        }
        
        let item_5 = LotteryItem.init(frame: .zero)
        item_5.itemTag = ItemTag(rawValue: 5)
        container.addSubview(item_5)
        item_5.snp.makeConstraints { make in
            make.width.height.equalTo(lotteryItemWidth)
            make.top.equalToSuperview().offset(CGFloat(2 * lotteryItemWidth))
            make.left.equalToSuperview().offset(CGFloat(lotteryItemWidth))
        }
        
        let item_6 = LotteryItem.init(frame: .zero)
        item_6.itemTag = ItemTag(rawValue: 6)
        container.addSubview(item_6)
        item_6.snp.makeConstraints { make in
            make.width.height.equalTo(lotteryItemWidth)
            make.top.equalToSuperview().offset(CGFloat(2 * lotteryItemWidth))
            make.left.equalToSuperview()
        }
        
        let item_7 = LotteryItem.init(frame: .zero)
        item_7.itemTag = ItemTag(rawValue: 7)
        container.addSubview(item_7)
        item_7.snp.makeConstraints { make in
            make.width.height.equalTo(lotteryItemWidth)
            make.top.equalToSuperview().offset(CGFloat(lotteryItemWidth))
            make.left.equalToSuperview()
        }
        
        let item_8 = LotteryItem.init(frame: .zero)
        item_8.itemTag = ItemTag(rawValue: 8)
        container.addSubview(item_8)
        item_8.snp.makeConstraints { make in
            make.width.height.equalTo(lotteryItemWidth)
            make.top.equalToSuperview().offset(CGFloat(lotteryItemWidth))
            make.left.equalToSuperview().offset(CGFloat(lotteryItemWidth))
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(onStart))
        item_8.addGestureRecognizer(tap)
    }
    
    @objc private func onStart() {
        let totalNumber = Int.randomIntNumber(lower: 8, upper: 15)
        print(totalNumber)
        start(totalNumber)
        DispatchQueue.main.asyncAfter(deadline: .now() + (Double(totalNumber)) * (0.8/4.0)) {
            IntegralFacade.shared.prizeDraw().startWithResult({ [weak self] result in
                guard let `self` = self else { return }
                guard let value = result.value else { return }
                let prize = value.prizes[value.prizeIndex]
                if let log = value.log {
                    self.handleWithValue(prize, log)
                }
            })
        }
    }
    
    func handleWithValue(_ item: Prize, _ log: prizeLog) {
        let reminder = PrizeReminder()
        reminder.model = item
        reminder.log = log
        reminder.show()
        reminder.onGiftButtonClick = { gift, log in
            if gift.targetType == .gift {
                let controller = PickUpImmediatelyController(gift, log.id, log)
                currentNavigationController()?.pushViewController(controller, animated: true)
            }
        }
    }
    
    //算法： 1.转3圈， 然后从0 -> 8随机
    // 1.第一圈 花费 0.5秒
    // 2.第二圈 花费 1.0 秒
    // 3.第三圈 花费 1.5秒
    // 4.花费 不超过 1.5秒
    //  步骤： 1.随机 26 -> 34
    
    func start(_ totalNumber: Int) {
        end()
        for i in 0...totalNumber {
            run(i, interval: ((Double)(i) * (0.8/4.0)))
        }
    }

    func run(_ index: Int, interval: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + interval ) {
            if let nextItem = self.container.subviews[index%8] as? LotteryItem {
                nextItem.selectItem()
            }
            var lastIndex: Int
            if index % 8 == 0 {
                lastIndex = 7
            } else {
                lastIndex = index % 8 - 1
            }
            if let lastItem = self.container.subviews[lastIndex] as? LotteryItem {
                lastItem.unSelectItem()
            }
        }
    }
    
    func end() {
        for item in container.subviews {
            if let item = item as? LotteryItem {
                item.unSelectItem()
            }
        }
    }
    
    private let bgView: UIImageView = {
        let view = UIImageView()
        view.image = imageNamed("lotteryItemBg")
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    private let container: UIView = {
        let view = UIView()
        return view
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


enum ItemTag: Int {
    case topLeft = 0
    case topCenter = 1
    case topRight = 2
    case middleRight = 3
    case bottomRight = 4
    case bottomCenter = 5
    case bottomLeft = 6
    case middleLeft = 7
    case middleCenter = 8
}

class LotteryItem: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var itemTag: ItemTag? {
        didSet {
            imageWithState(false)
        }
    }
    
    public func selectItem() {
        imageWithState(true)
    }
    
    public func unSelectItem() {
        imageWithState(false)
    }
    
    private func imageWithState( _ selected: Bool) {
        if let tag = itemTag {
            switch tag {
            case .topLeft:
                image = selected ? imageNamed("top-left-Selection") : imageNamed("top-left-Unclicked")
            case .topRight:
                image = selected ? imageNamed("top-right-Selection") : imageNamed("top-right-Unclicked")
            case .topCenter, .middleLeft, .middleRight, .bottomCenter:
                image = selected ? imageNamed("Square-Selection") : imageNamed("Unchecked-Selection")
            case .middleCenter:
                image = imageNamed("Clickdraw")
            case .bottomLeft:
                image = selected ? imageNamed("bottom-left-Selection") : imageNamed("bottom-left-Unclicked")
            case .bottomRight:
                image = selected ? imageNamed("bottom-right-Selection") : imageNamed("bottom-right-Unclicked")
            }
        }
    }
}

public extension Int {
    static func randomIntNumber(lower: Int = 0,upper: Int = Int(UInt32.max)) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower)))
    }

    static func randomIntNumber(range: Range<Int>) -> Int {
        return randomIntNumber(lower: range.lowerBound, upper: range.upperBound)
    }
}

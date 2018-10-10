import UIKit

final class TextFieldCell: UITableViewCell {

    @IBOutlet private var borderView: UIView!
    @IBOutlet private var textFieldContainer: UIView!

    var textField: UITextField? {
        didSet {
            oldValue?.removeFromSuperview()
            if let textField = self.textField {
                self.add(textField)
            }
        }
    }

    var visualStyle: AlertVisualStyle? {
        didSet {
            self.textField?.font = self.visualStyle?.textFieldFont
            self.borderView.backgroundColor = self.visualStyle?.textFieldBorderColor

            guard let padding = self.visualStyle?.textFieldMargins else {
                return
            }

            self.snp.updateConstraints { (make) in
                make.left.equalTo(padding.left)
                make.right.equalTo(-padding.right)
                make.top.equalTo(padding.top)
                make.bottom.equalTo(-padding.bottom)
            }
        }
    }

    private func add(_ textField: UITextField) {
        let container = self.textFieldContainer
        container?.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        let insets = self.visualStyle?.textFieldMargins ?? UIEdgeInsets.zero
        textField.snp.makeConstraints { (make) in
            make.edges.equalTo(insets)
        }
    }
}

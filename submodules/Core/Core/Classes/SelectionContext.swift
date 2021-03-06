//
//  SelectionContext.swift
//  Pods
//
//  Created by kingxt on 8/29/17.
//
//

import Foundation
import ReactiveSwift
import Result

public protocol SelectableItem {
    func uniqueIdentifier() -> String
}

public func == (lhs: SelectableItem, rhs: SelectableItem) -> Bool {
    return lhs.uniqueIdentifier() == rhs.uniqueIdentifier()
}

public struct SelectionChange {
    public var sender: SelectableItem
    public var selected: Bool = false
    public var animated: Bool = false
}

open class SelectionContext {

    private var selectionMap = [String: SelectableItem]()
    private var selectionIdentifier = [String]() // keep index for order

    private var contextChangePipe: (output: Signal<SelectionChange, NoError>, input: Signal<SelectionChange, NoError>.Observer)
    private var setItemNoEffectPipe: (output: Signal<SelectableItem, NoError>, input: Signal<SelectableItem, NoError>.Observer)
    
    private lazy var hotPort = Signal<Int, NoError>.pipe()
    private let limitCount: Int

    public var selectedCount: Int {
        return selectionMap.count
    }

    public init(limitCount: Int = Int.max) {
        self.limitCount = limitCount
        contextChangePipe = Signal<SelectionChange, NoError>.pipe()
        setItemNoEffectPipe = Signal<SelectableItem, NoError>.pipe()
    }

    public func selectedItems() -> [SelectableItem] {
        return Array(selectionMap.values)
    }

    public func selectedValues<T>() -> [T] {
        var result = [T]()
        for id in selectionIdentifier {
            if let value = selectionMap[id] {
                result.append(value as! T)
            }
        }
        return result
    }

    public func clear() {
        for item in selectionMap.values {
            contextChangePipe.input.send(value: SelectionChange(sender: item, selected: false, animated: false))
        }
        selectionMap.removeAll()
        selectionIdentifier.removeAll()
        hotPort.input.send(value: 0)
    }

    public func itemInformativeSelectedSignal(item: SelectableItem) -> SignalProducer<SelectionChange, NoError> {
        let changeSignal = contextChangePipe.output.filter { (change) -> Bool in
            change.sender == item
        }
        return SignalProducer(changeSignal)
    }

    @discardableResult public func setItem(_ item: SelectableItem, selected: Bool, animated: Bool = true) -> Bool {
        if selected {
            if selectionIdentifier.count == limitCount {
                setItemNoEffectPipe.input.send(value: item)
                return false
            }
            if selectionIdentifier.contains(item.uniqueIdentifier()) {
                return false
            }
            selectionIdentifier.append(item.uniqueIdentifier())
            selectionMap[item.uniqueIdentifier()] = item
        } else {
            selectionIdentifier.remove(object: item.uniqueIdentifier())
            selectionMap.removeValue(forKey: item.uniqueIdentifier())
        }
        contextChangePipe.input.send(value: SelectionChange(sender: item, selected: selected, animated: animated))
        return true
    }

    public func dataSourceChangeSignal() -> Signal<Int, NoError> {
        let result = Signal<Signal<Int, NoError>, NoError>.pipe()
        let signal = contextChangePipe.output.filterMap { [weak self] (_) -> Int in
            if let stronSelf = self {
                return stronSelf.selectionMap.count
            } else {
                return 0
            }
        }
        defer {
            result.input.send(value: signal)
            result.input.send(value: hotPort.output)
            result.input.sendCompleted()
        }
        return result.output.flatten(.merge)
    }

    public func selectionContextChangeSignal() -> Signal<SelectionChange, NoError> {
        return contextChangePipe.output
    }
    
    public func setItemNoEffectSignl() -> Signal<SelectableItem, NoError> {
        return setItemNoEffectPipe.output
    }

    public func isItemSelected(_ item: SelectableItem) -> Bool {
        return selectionMap[item.uniqueIdentifier()] != nil
    }
}

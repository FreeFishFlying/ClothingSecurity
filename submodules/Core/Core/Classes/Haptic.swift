//
//  Haptic.swift
//  Test
//
//  Created by Lasha Efremidze on 4/7/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import UIKit

public enum Haptic {
    @available(iOS 10.0, *)
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    @available(iOS 10.0, *)
    case notification(UINotificationFeedbackGenerator.FeedbackType)
    case selection

    // trigger
    public func generate() {
        guard #available(iOS 10, *) else { return }

        switch self {
        case let .impact(style):
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        case let .notification(type):
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}

//
//  Extensions.swift
//  Pods-Example
//
//  Created by Jon Kent on 7/1/19.
//

import UIKit

extension NSObject: InitializableClass {}

extension UIView {
    
    @discardableResult
    internal func untransformed(_ block: () -> CGFloat) -> CGFloat {
        let t = transform
        transform = .identity
        let value = block()
        transform = t
        return value
    }
    
    internal func bringToFront() {
        superview?.bringSubviewToFront(self)
    }
    
    internal func untransform(_ block: () -> Void) {
        untransformed { () -> CGFloat in
            block()
            return 0
        }
    }
    
    internal static func animationsEnabled(_ enabled: Bool = true, _ block: () -> Void) {
        let a = areAnimationsEnabled
        setAnimationsEnabled(enabled)
        block()
        setAnimationsEnabled(a)
    }
}

extension UIViewController {
    
    // View controller actively displayed in that layer. It may not be visible if it's presenting another view controller.
    internal  var activeViewController: UIViewController {
        switch self {
        case let navigationController as UINavigationController:
            return navigationController.topViewController?.activeViewController ?? self
        case let tabBarController as UITabBarController:
            return tabBarController.selectedViewController?.activeViewController ?? self
        case let splitViewController as UISplitViewController:
            return splitViewController.viewControllers.last?.activeViewController ?? self
        default:
            return self
        }
    }
    
    // View controller being displayed on screen to the user.
    internal var topMostViewController: UIViewController {
        let activeViewController = self.activeViewController
        return activeViewController.presentedViewController?.topMostViewController ?? activeViewController
    }
    
    internal var containerViewController: UIViewController {
        return navigationController?.containerViewController ??
        tabBarController?.containerViewController ??
        splitViewController?.containerViewController ??
        self
    }
    
    @objc internal var isHidden: Bool {
        return presentingViewController == nil
    }
}

extension UIGestureRecognizer {
    
    internal convenience init(addTo view: UIView, target: Any, action: Selector) {
        self.init(target: target, action: action)
        view.addGestureRecognizer(self)
    }
    
    internal convenience init?(addTo view: UIView?, target: Any, action: Selector) {
        guard let view = view else { return nil }
        self.init(addTo: view, target: target, action: action)
    }
    
    internal func remove() {
        view?.removeGestureRecognizer(self)
    }
}

extension UIPanGestureRecognizer {
    
    internal var canSwitch: Bool {
        return !(self is UIScreenEdgePanGestureRecognizer)
    }
    
    internal var xTranslation: CGFloat {
        return view?.untransformed { translation(in: view).x } ?? 0
    }
    
    internal var xVelocity: CGFloat {
        return view?.untransformed { velocity(in: view).x } ?? 0
    }
}

extension UIApplication {
    
    /// Optional<UIWindow>
    internal var keyWindow: Optional<UIWindow> {
        if #available(iOS 15.0, *) {
            return connectedScenes.compactMap { $0 as? UIWindowScene }.reduce([], { $0 + $1.windows }).first(where: \.isKeyWindow)
        } else {
            return windows.first(where: \.isKeyWindow)
        }
    }
}

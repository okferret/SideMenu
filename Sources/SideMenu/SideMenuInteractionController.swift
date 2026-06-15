//
//  SideMenuInteractiveTransitionController.swift
//  SideMenu
//
//  Created by Jon Kent on 12/28/18.
//

import UIKit

/// SideMenuInteractionController
final class SideMenuInteractionController: UIPercentDrivenInteractiveTransition {
    
    enum State { case
        update(progress: CGFloat),
        finish,
        cancel
    }
    
    private(set) var isCancelled: Bool = false
    private(set) var isFinished: Bool = false
    
    internal init(cancelWhenBackgrounded: Bool = true, completionCurve: UIView.AnimationCurve = .easeIn) {
        super.init()
        self.completionCurve = completionCurve
        
        guard cancelWhenBackgrounded else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    internal override func cancel() {
        isCancelled = true
        super.cancel()
    }
    
    internal override func finish() {
        isFinished = true
        super.finish()
    }
    
    internal override func update(_ percentComplete: CGFloat) {
        guard !isCancelled && !isFinished else { return }
        super.update(percentComplete)
    }
    
    internal func handle(state: State) {
        switch state {
        case .update(let progress):
            update(progress)
        case .finish:
            finish()
        case .cancel:
            cancel()
        }
    }
}

extension SideMenuInteractionController {
    
    @objc private func handleNotification(notification: NSNotification) {
        switch notification.name {
        case UIApplication.didEnterBackgroundNotification:
            cancel()
        default: break
        }
    }
}

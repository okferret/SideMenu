//
//  SideMenuTransitioningDelegate.swift
//  SideMenu
//
//  Created by Jon Kent on 8/29/19.
//  Copyright © 2019 jonkykong. All rights reserved.
//

import UIKit

/// SideMenuTransitionControllerDelegate
protocol SideMenuTransitionControllerDelegate: AnyObject {
    func sideMenuTransitionController(_ transitionController: SideMenuTransitionController, didDismiss viewController: UIViewController)
    func sideMenuTransitionController(_ transitionController: SideMenuTransitionController, didPresent viewController: UIViewController)
}

/// SideMenuTransitionController
final class SideMenuTransitionController: NSObject, UIViewControllerTransitioningDelegate {
    
    typealias Model = MenuModel & AnimationModel & PresentationModel
    
    private let leftSide: Bool
    private let config: Model
    private var animationController: SideMenuAnimationController?
    private weak var interactionController: SideMenuInteractionController?
    
    internal var interactive: Bool = false
    internal weak var delegate: SideMenuTransitionControllerDelegate?
    
    internal init(leftSide: Bool, config: Model) {
        self.leftSide = leftSide
        self.config = config
        super.init()
    }
    
    internal func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController = SideMenuAnimationController(
            config: config,
            leftSide: leftSide,
            delegate: self)
        return animationController
    }
    
    internal func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController
    }
    
    internal func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController(using: animator)
    }
    
    internal func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController(using: animator)
    }
    
    internal func handle(state: SideMenuInteractionController.State) {
        interactionController?.handle(state: state)
    }
    
    internal func layout() {
        animationController?.layout()
    }
    
    internal func transition(presenting: Bool, animated: Bool = true, interactive: Bool = false, alongsideTransition: (() -> Void)? = nil, complete: Bool = true, completion: ((Bool) -> Void)? = nil) {
        animationController?.transition(
            presenting: presenting,
            animated: animated,
            interactive: interactive,
            alongsideTransition: alongsideTransition,
            complete: complete, completion: completion
        )
    }
}

extension SideMenuTransitionController: SideMenuAnimationControllerDelegate {
    
    internal func sideMenuAnimationController(_ animationController: SideMenuAnimationController, didDismiss viewController: UIViewController) {
        delegate?.sideMenuTransitionController(self, didDismiss: viewController)
    }
    
    internal func sideMenuAnimationController(_ animationController: SideMenuAnimationController, didPresent viewController: UIViewController) {
        delegate?.sideMenuTransitionController(self, didPresent: viewController)
    }
}

extension SideMenuTransitionController {
    
    private func interactionController(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard interactive else { return nil }
        interactive = false
        let interactionController = SideMenuInteractionController(cancelWhenBackgrounded: config.dismissWhenBackgrounded, completionCurve: config.completionCurve)
        self.interactionController = interactionController
        return interactionController
    }
}

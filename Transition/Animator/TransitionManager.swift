//
//  TransitionManager.swift
//  DerpCounter
//
//  Created by HerliHalim on 11/05/2016.
//  Copyright © 2016 Herli. All rights reserved.
//

import UIKit

enum TransitionMode {
    case Presenting
    case Dismissing
}

class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning {

    var animationDuration: NSTimeInterval = 0.4
    var transitionMode: TransitionMode = .Presenting
    
    weak var presentingViewController: UIViewController? = nil
    weak var presentedViewController: UIViewController? = nil
    
    var transitionEndedHandler: ((transitionCompleted: Bool, currentMode: TransitionMode) -> (Void))? = nil
    
    func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {
        precondition(false, "animatePresentation(_:_:) implementation required")
    }
    
    func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        precondition(false, "animateDismissal(_:_:) implementation required")
    }

    // MARK: - UIViewControllerAnimatedTransitioning implementations
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        if let context = transitionContext {
            return context.isAnimated() ? animationDuration : 0.0
        }
        return 0.0
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if transitionMode == .Presenting {
            
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!

            presentingViewController = fromViewController
            presentedViewController = toViewController
            
            animatePresentation(transitionContext)
            
        } else {
            animateDismissal(transitionContext)
        }
    }
    
    func animationEnded(transitionCompleted: Bool) {
        if let handler = transitionEndedHandler {
            handler(transitionCompleted:transitionCompleted, currentMode: transitionMode)
        }
    }
}

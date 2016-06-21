//
//  AnimationBlockTransitionManager.swift
//  DerpCounter
//
//  Created by HerliHalim on 12/05/2016.
//  Copyright © 2016 Herli. All rights reserved.
//

import UIKit

class AnimationClosureProviderTransitionManager: TransitionManager {
    typealias AnimationTransitionProvider = (UIViewControllerContextTransitioning, duration: NSTimeInterval) -> Void
    typealias AnimationDurationProvider = (UIViewControllerContextTransitioning?) -> NSTimeInterval
    
    var presentationAnimationWithContext: AnimationTransitionProvider? = nil
    var dismissalAnimationWithContext: AnimationTransitionProvider? = nil
    var animationDurationProvider: AnimationDurationProvider? = nil
    
    override func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        if let provider = animationDurationProvider {
            return provider(transitionContext)
        } else {
            if let context = transitionContext {
                return context.isAnimated() ? animationDuration : 0
            }
            return 0
        }
    }

    override func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {
        if let animate = presentationAnimationWithContext {
            animate(transitionContext, duration: transitionDuration(transitionContext))
        } else {
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let container = transitionContext.containerView()!
            let frame = transitionContext.finalFrameForViewController(toViewController)
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey) ?? toViewController.view!
            toView.frame = frame
            container.addSubview(toView)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    override func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        if let animate = dismissalAnimationWithContext {
            animate(transitionContext, duration: transitionDuration(transitionContext))
        } else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}



//
//  FadeSlideTransitionManager.swift
//  DerpCounter
//
//  Created by HerliHalim on 10/05/2016.
//  Copyright © 2016 Herli. All rights reserved.
//

import UIKit

class FadeSlideTransitionManager: TransitionManager {
    
    override func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {

        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey) ?? toViewController.view!
        let container = transitionContext.containerView()!

        let frame = transitionContext.finalFrameForViewController(toViewController)
        
        var offscreenFrame = frame
        offscreenFrame.origin.y = CGRectGetHeight(container.bounds) + CGRectGetHeight(offscreenFrame)
        toView.frame = offscreenFrame
        
        container.addSubview(toView)
        
        toView.alpha = 0.5;
        
        let duration = transitionDuration(transitionContext)
        
        UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: [ .CalculationModePaced ], animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.4, animations: {
                toView.alpha = 0.7
            })
            UIView.addKeyframeWithRelativeStartTime(0.4, relativeDuration: 0.6, animations: {
                toView.alpha = 1.0
            })
            
            }, completion: { (finished) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
        
        let relativeStartTime = 0.1
        let startTime = relativeStartTime * duration
        let relativeDuration = duration - startTime
        
        UIView.animateWithDuration(relativeDuration, delay: relativeStartTime, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [ .CurveEaseIn ], animations: {
            toView.center = container.center
            }, completion: nil)
    }
    
    override func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let container = transitionContext.containerView()!
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) ?? fromViewController.view!
        var offscreenFrame = fromView.frame
        offscreenFrame.origin.y = CGRectGetHeight(container.bounds) + CGRectGetHeight(offscreenFrame)
        
        let duration = transitionDuration(transitionContext)
        UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: [ .CalculationModePaced ], animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1.0, animations: {
                fromView.frame = offscreenFrame
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.4, animations: {
                fromView.alpha = 0.7
            })
            UIView.addKeyframeWithRelativeStartTime(0.4, relativeDuration: 0.6, animations: {
                fromView.alpha = 0.0
            })
            
            }, completion: { (finished) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}

//
//  ZoomInOutTransitionManager.swift
//  DerpCounter
//
//  Created by HerliHalim on 14/05/2016.
//  Copyright © 2016 Herli. All rights reserved.
//

import UIKit

class ZoomInOutTransitionManager: TransitionManager {

    override func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey) ?? toViewController.view!
        let container = transitionContext.containerView()!
        let frame = transitionContext.finalFrameForViewController(toViewController)
        let originalTransform = toView.transform;
        let scaleTransform = CGAffineTransformScale(originalTransform, 2.0, 2.0);
        let duration = transitionDuration(transitionContext)
        
        container.addSubview(toView)
        toView.frame = frame
        toView.alpha = 0.0;
        toView.transform = scaleTransform;
        
        UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: [ .CalculationModeCubicPaced, .AllowUserInteraction ], animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.4, animations: { 
                toView.alpha = 0.7
            })
            UIView.addKeyframeWithRelativeStartTime(0.4, relativeDuration: 0.6, animations: { 
                toView.alpha = 1.0
            })
            
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
        
        let relativeStartTime = 0.4
        let startTime = relativeStartTime * duration
        let addedDuration = duration + startTime
        
        UIView.animateWithDuration(addedDuration, delay: startTime, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [ .CurveEaseIn, .AllowUserInteraction ], animations: {
            toView.transform = originalTransform
            }, completion: nil)
    }
    
    override func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        let originalTransform = fromView?.transform
        let originalAlpha = fromView?.alpha
        let scaleTransform = CGAffineTransformScale(originalTransform ?? CGAffineTransformIdentity, 2.0, 2.0);
        let duration = transitionDuration(transitionContext)
        
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        toView?.alpha = 1.0

        UIView.animateKeyframesWithDuration(duration, delay: 0.0, options: [ .CalculationModeCubicPaced ], animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1.0, animations: { 
                fromView?.transform = scaleTransform
            })
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.4, animations: { 
                fromView?.alpha = 0.7
            })
            UIView.addKeyframeWithRelativeStartTime(0.4, relativeDuration: 0.6, animations: { 
                fromView?.alpha = 0.0
            })
            
            }) { _ in
                fromView?.transform = originalTransform ?? CGAffineTransformIdentity
                fromView?.alpha = originalAlpha ?? 1.0
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}

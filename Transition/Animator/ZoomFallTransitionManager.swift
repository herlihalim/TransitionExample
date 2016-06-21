//
//  ZoomFallTransitionManager.swift
//  DerpCounter
//
//  Created by HerliHalim on 13/05/2016.
//  Copyright © 2016 Herli. All rights reserved.
//

import UIKit

class ZoomFallTransitionManager: TransitionManager {

    override func animatePresentation(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey) ?? toViewController.view!
        let container = transitionContext.containerView()!
        let frame = transitionContext.finalFrameForViewController(toViewController)
        container.addSubview(toView)
        
        toView.alpha = 0
        toView.frame = frame
        toView.center = container.center
        toView.transform = CGAffineTransformMakeScale(5, 5)
        let duration = transitionDuration(transitionContext)
        UIView.animateWithDuration(duration, delay: 0, options: [ .CurveEaseInOut, .AllowUserInteraction ], animations: {
            toView.alpha = 1.0
            toView.transform = CGAffineTransformIdentity
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }

    override func animateDismissal(transitionContext: UIViewControllerContextTransitioning) {
        
        let duration = transitionDuration(transitionContext)
        
        // Prevent division by 0
        if transitionContext.isAnimated() == false || duration == 0.0 {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            return
        }
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let container = transitionContext.containerView()!
        let view = transitionContext.viewForKey(UITransitionContextFromViewKey) ?? fromViewController.view!
        let animator = UIDynamicAnimator(referenceView: container)
        
        let frame = view.frame
        let topRightPoint = CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame))
        let attachmentPoint = UIOffsetMake(CGRectGetMinX(frame), CGRectGetMaxY(frame))
        
        let attachmentBehavior = UIAttachmentBehavior(item: view, offsetFromCenter: attachmentPoint, attachedToAnchor: topRightPoint)
        animator.addBehavior(attachmentBehavior)
        
        let gravityBehavior = UIGravityBehavior(items: [view])
        let distance = abs(CGRectGetMinY(frame) - CGRectGetMaxY(container.frame))
        let angle = CGFloat(100.0 / 180.0)
        let requiredMagnitude = distance / CGFloat((duration * duration)) / 1000 / angle
        gravityBehavior.magnitude = requiredMagnitude
        gravityBehavior.angle = CGFloat(Double(angle) * M_PI)
        animator.addBehavior(gravityBehavior)

        // Provide animation block, otherwise the animateAlongsideTransition(_:_:) on UIViewControllerTransitionCoordinatorContext won't have animation at all.
        UIView.animateWithDuration(duration, delay: 0, options: [ .CurveEaseInOut ], animations: {
            // Animate anything, otherwise completion block will be triggered immediately
            view.alpha = 0.95
            }) { _ in
                animator.removeAllBehaviors()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}

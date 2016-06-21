//
//  BlurredBackgroundPresentationController.swift
//  DerpCounter
//
//  Created by HerliHalim on 11/05/2016.
//  Copyright © 2016 Herli. All rights reserved.
//

import UIKit

class BlurredBackgroundPresentationController: TapDismissablePresentationController {

    var blurRadius: CGFloat = 60
    var blurTintColor: UIColor = UIColor(white:0.11, alpha: 0.73)
    
    private var snapshotView: UIView? = nil
    private var snapshotFrame: CGRect = CGRectZero
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let containerView = containerView, presentedView = presentedView() else {
            return
        }

        let toBeSnapshotted = presentingViewController.view
        
        let snapshot = toBeSnapshotted.blurredSnapshotView(blurRadius, scaleFactor: 0.25, tintColor: blurTintColor)
        snapshot.alpha = 0.7
        snapshot.autoresizingMask = [ .FlexibleHeight, .FlexibleWidth ]
        
        snapshotView = snapshot
        snapshotFrame = snapshot.frame
        
        snapshot.userInteractionEnabled = false
        containerView.insertSubview(snapshot, belowSubview: presentedView)
        
        if let transitionCoordinator = presentingViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ (context) in
                snapshot.alpha = 1.0
                }, completion: nil)
        }
    }
    
    override func presentationTransitionDidEnd(completed: Bool)  {
        super.presentationTransitionDidEnd(completed)
        // This might get out of sync here due to adaptive presentation
        if let snapshot = snapshotView where snapshot.frame != snapshotFrame {
            let newSnapshot = presentingViewController.view.blurredSnapshotView(blurRadius, scaleFactor: 0.25, tintColor: blurTintColor)
            newSnapshot.autoresizingMask = snapshot.autoresizingMask
            newSnapshot.userInteractionEnabled = snapshot.userInteractionEnabled
            newSnapshot.alpha = snapshot.alpha
            
            snapshot.superview?.insertSubview(newSnapshot, belowSubview: snapshot)
            snapshot.removeFromSuperview()
            
            snapshotView = newSnapshot
            snapshotFrame = newSnapshot.frame
            
            UIView.animateWithDuration(0.1, animations: {
                newSnapshot.alpha = 1.0
            })
        }
        
        if completed {
            return
        }
        cleanup()
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        guard let snapshot = snapshotView else {
            return
        }
        
        if let transitionCoordinator = self.presentingViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({(context: UIViewControllerTransitionCoordinatorContext!) -> Void in
                snapshot.alpha = 0.0
                }, completion:nil)
        }
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        if completed {
            cleanup()
        }
    }
    
    private func cleanup() {
        snapshotView?.removeFromSuperview()
        snapshotView = nil
        snapshotFrame = CGRectZero
    }
}

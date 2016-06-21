//
//  TapDismissablePresentationController.swift
//  DerpCounter
//
//  Created by HerliHalim on 11/05/2016.
//  Copyright © 2016 Herli. All rights reserved.
//

import UIKit

/// Provides a base presentation controller implementation that allows tap to dismiss and automatically adjust presented view if keyboard is on screen.
class TapDismissablePresentationController: UIPresentationController {
    private var tapToDismissView: UIView?
    
    var tapToDismissEnabled: Bool = false
    var automaticKeyboardAdjustmentEnabled: Bool = false
    
    // Probably not needed, but just to be safe
    deinit {
        cleanup()
    }

    // MARK: - UIPresentationController override implementations
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView = containerView else {
            return
        }
                
        if tapToDismissEnabled {
            let tapView = UIView(frame: containerView.bounds)
            tapView.autoresizingMask = [ .FlexibleWidth, .FlexibleHeight ]
            tapToDismissView = tapView
            containerView.addSubview(tapView)
            
            let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(TapDismissablePresentationController.onTapToDismissGestureRecognised(_:)))
            tapView.userInteractionEnabled = true
            tapView.addGestureRecognizer(tapRecogniser)
        }
        
        if automaticKeyboardAdjustmentEnabled {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TapDismissablePresentationController.onKeyboardWillAppear(_:)), name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TapDismissablePresentationController.onKeyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        if let view = presentedView() {
            view.frame = frameOfPresentedViewInContainerView()
        }
    }
    
    override func presentationTransitionDidEnd(completed: Bool)  {
        super.presentationTransitionDidEnd(completed)
        if completed {
            return
        }
        cleanup()
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        if completed {
            cleanup()
        }
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        var frame = CGRectZero
        guard let containerView = containerView else {
            return frame
        }
        frame = containerView.frame
        
        let presentedViewContentSize = self.sizeForChildContentContainer(presentedViewController, withParentContainerSize: containerView.bounds.size)
        
        let containerFrame = containerView.frame
        frame = containerFrame
        frame.size = presentedViewContentSize
        frame.origin.x = floor((CGRectGetWidth(containerFrame) - CGRectGetWidth(frame)) * 0.5)
        frame.origin.y = floor((CGRectGetHeight(containerFrame) - CGRectGetHeight(frame)) * 0.5)
        
        return frame
    }
    
    // MARK: - UIContentContainer implementations
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        // Honor the content preferredContentSize if it's non zero
        if container as? UIViewController == presentedViewController && container.preferredContentSize != CGSizeZero {
            return container.preferredContentSize
        }
        return super.sizeForChildContentContainer(container, withParentContainerSize: parentSize)
    }
    
    override func preferredContentSizeDidChangeForChildContentContainer(container: UIContentContainer) {
        super.preferredContentSizeDidChangeForChildContentContainer(container)
        if container as? UIViewController == presentedViewController && container.preferredContentSize != CGSizeZero {
            self.containerView?.setNeedsLayout()
            UIView.animateWithDuration(0.2, animations: { 
                self.containerView?.layoutIfNeeded()
            })
            
        }
    }
    
    /*
    // MARK: - UIAdaptivePresentationControllerDelegate
    override func adaptivePresentationStyle() -> UIModalPresentationStyle {
        var style = super.adaptivePresentationStyle()
        if style == .None {
            style = .OverFullScreen
        }
        return style
    }
    
    override func adaptivePresentationStyleForTraitCollection(traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        var style = super.adaptivePresentationStyleForTraitCollection(traitCollection)
        if traitCollection.verticalSizeClass == .Compact || traitCollection.horizontalSizeClass == .Compact {
            if style == .None {
                style = .OverFullScreen
            }
        }
        return style
    }
    */

    // MARK: - Implementations
    
    private func cleanup() {
        tapToDismissView?.removeFromSuperview()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Gesture handling
    func onTapToDismissGestureRecognised(tapGestureRecogniser: UITapGestureRecognizer) {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Keyboard handling
    func onKeyboardWillAppear(notification: NSNotification) {
        guard let view = presentedView() else {
            return
        }
        
        if view.window == nil {
            return
        }
        
        let viewFrame = view.frame
        let screenBound = UIScreen.mainScreen().bounds
        
        let desiredOffset = CGFloat(20.0)
        var finalOriginY = viewFrame.origin.y
        let statusBarHeight = CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
        let screenHeight = CGRectGetHeight(screenBound)
        let viewHeight = CGRectGetHeight(viewFrame)
        let keyboardFrame = view.superview!.convertRect((notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue(), fromView: nil)
        
        let bottomDistanceToKeyboard = CGRectGetMaxY(viewFrame) - CGRectGetMinY(keyboardFrame)
        let overlap = bottomDistanceToKeyboard > 0
        
        // Try pushing view to just above keyboard first
        if overlap {
            let originYCandidate = screenHeight - (CGRectGetHeight(keyboardFrame) + viewHeight + desiredOffset)
            // Make sure it doesn't go above status bar
            if originYCandidate > statusBarHeight {
                finalOriginY = originYCandidate
            } else {
                finalOriginY = statusBarHeight
            }
            
            // Make sure adjustment won't cause the view to move offscreen
            if (finalOriginY + viewHeight) > screenHeight {
                finalOriginY = viewFrame.origin.y
            }
        }
        
        var newFrame = viewFrame
        newFrame.origin.y = finalOriginY
        view.frame = newFrame
    }
    
    func onKeyboardWillHide(notification: NSNotification) {
        // Assume the default position is on the center of its superview.
        guard let view = presentedView() else {
            return
        }
        view.center = view.superview!.center
    }
}

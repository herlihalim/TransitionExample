//
//  ViewController.swift
//  TransitionExample
//
//  Created by HerliHalim on 21/06/2016.
//  Copyright © 2016 Herli. All rights reserved.
//

import UIKit

enum TransitionType: Int {
    case FadeSlide
    case ZoomFall
    case ZoomInOut
    case Closure
    case _Count
}

class ViewController: UITableViewController {

    var transitionManager: TransitionManager! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "1"))
        
        title = "Transition"
    }
    
    
    // MARK: - UITableView data source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        switch TransitionType(rawValue: indexPath.row)! {
        case .FadeSlide: cell.textLabel?.text = "Fade Slide"
        case .ZoomFall:  cell.textLabel?.text = "Zoom Fall"
        case .ZoomInOut: cell.textLabel?.text = "Zoom In Out"
        case .Closure:   cell.textLabel?.text = "Closure"
        default: break
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TransitionType._Count.rawValue
    }
    
    // MARK: - UITableView delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch TransitionType(rawValue: indexPath.row)! {
        case .FadeSlide: transitionManager = FadeSlideTransitionManager()
        case .ZoomFall:  transitionManager = ZoomFallTransitionManager()
        case .ZoomInOut: transitionManager = ZoomInOutTransitionManager()
        case .Closure:
            let manager = AnimationClosureProviderTransitionManager()
            manager.animationDurationProvider =  { (transtionContext) in
                return 0.5
            }
            let provider = { (transitionContext: UIViewControllerContextTransitioning, duration: NSTimeInterval) in
                
                let container = transitionContext.containerView()
                
                let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
                let toView = transitionContext.viewForKey(UITransitionContextToViewKey) ?? toViewController.view!
                
                toView.frame = transitionContext.finalFrameForViewController(toViewController)
                toView.alpha = 0.0
                
                container?.addSubview(toView)
                
                UIView.animateWithDuration(duration, animations: { 
                    toView.alpha = 1.0
                    }, completion: { (fniished) in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                })
            }
            manager.presentationAnimationWithContext = provider
            manager.dismissalAnimationWithContext = { (transitionContext: UIViewControllerContextTransitioning, duration: NSTimeInterval) in
                let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
                
                let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
                let toView = transitionContext.viewForKey(UITransitionContextToViewKey) ?? toViewController.view!

                toView.alpha = 1.0
                
                UIView.animateWithDuration(duration, animations: {
                    fromView?.alpha = 0.0
                    }, completion: { (finished) in
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                })
            }
            transitionManager = manager
            
        default: break
        }
        transitionManager.animationDuration = 0.4
        
        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 540, height: 600)
        viewController.view.backgroundColor = UIColor.whiteColor()
        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = .Custom
        
        let textField = UITextField()
        textField.borderStyle = .Bezel
        textField.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(textField)
        
        NSLayoutConstraint.activateConstraints([
            textField.leftAnchor.constraintEqualToAnchor(viewController.view.leftAnchor, constant: 20),
            textField.rightAnchor.constraintEqualToAnchor(viewController.view.rightAnchor, constant: -20),
            textField.topAnchor.constraintEqualToAnchor(viewController.view.topAnchor, constant: 20)
            ])
        
        presentViewController(viewController, animated: true, completion: nil)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension ViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentationController = BlurredBackgroundPresentationController(presentedViewController: presented, presentingViewController: presenting)
        presentationController.tapToDismissEnabled = true
        presentationController.automaticKeyboardAdjustmentEnabled = true
        return presentationController
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionManager.transitionMode = .Presenting
        return transitionManager
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionManager.transitionMode = .Dismissing
        return transitionManager
    }
}


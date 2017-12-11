//
//  SectionLabel.swift
//  HobbyQuest
//
//  Created by Monica Tran on 12/9/17.
//  Copyright © 2017 Monica Tran. All rights reserved.
//

import UIKit

class SpeechBubble: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLabel()
    }
    
    //You can change the initial Section Label attributes here
    func initializeLabel() {
        
        //self.textAlignment = .left
        self.layer.cornerRadius = 15.0
        self.clipsToBounds = true
        self.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        self.textColor = UIColor.darkText
        self.layer.shadowOffset = CGSize(width: -3.0, height: 1)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 6
        self.textInsets.bottom = 5
        self.textInsets.top = 5
        self.textInsets.left = 10
        self.textInsets.right = 10
    }
    
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = UIEdgeInsetsInsetRect(bounds, textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, textInsets))
    }
}

//
//  BubbleTransition.swift
//  BubbleTransition
//
//  Created by Andrea Mazzini on 04/04/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//
import UIKit

/**
 A custom modal transition that presents and dismiss a controller with an expanding bubble effect.
 - Prepare the transition:
 ```swift
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 let controller = segue.destination
 controller.transitioningDelegate = self
 controller.modalPresentationStyle = .custom
 }
 ```
 - Implement UIViewControllerTransitioningDelegate:
 ```swift
 func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
 transition.transitionMode = .present
 transition.startingPoint = someButton.center
 transition.bubbleColor = someButton.backgroundColor!
 return transition
 }
 func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
 transition.transitionMode = .dismiss
 transition.startingPoint = someButton.center
 transition.bubbleColor = someButton.backgroundColor!
 return transition
 }
 ```
 */
open class BubbleTransition: NSObject {
    
    /**
     The point that originates the bubble. The bubble starts from this point
     and shrinks to it on dismiss
     */
    open var startingPoint = CGPoint.zero {
        didSet {
            bubble.center = startingPoint
        }
    }
    
    /**
     The transition duration. The same value is used in both the Present or Dismiss actions
     Defaults to `0.5`
     */
    open var duration = 0.5
    
    /**
     The transition direction. Possible values `.present`, `.dismiss` or `.pop`
     Defaults to `.Present`
     */
    open var transitionMode: BubbleTransitionMode = .present
    
    /**
     The color of the bubble. Make sure that it matches the destination controller's background color.
     */
    open var bubbleColor: UIColor = .white
    
    open fileprivate(set) var bubble = UIView()
    
    /**
     The possible directions of the transition.
     
     - Present: For presenting a new modal controller
     - Dismiss: For dismissing the current controller
     - Pop: For a pop animation in a navigation controller
     */
    @objc public enum BubbleTransitionMode: Int {
        case present, dismiss, pop
    }
}

extension BubbleTransition: UIViewControllerAnimatedTransitioning {
    
    // MARK: - UIViewControllerAnimatedTransitioning
    /**
     Required by UIViewControllerAnimatedTransitioning
     */
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    /**
     Required by UIViewControllerAnimatedTransitioning
     */
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        
        fromViewController?.beginAppearanceTransition(false, animated: true)
        toViewController?.beginAppearanceTransition(true, animated: true)
        
        if transitionMode == .present {
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            let originalCenter = presentedControllerView.center
            let originalSize = presentedControllerView.frame.size
            
            bubble = UIView()
            bubble.frame = frameForBubble(originalCenter, size: originalSize, start: startingPoint)
            bubble.layer.cornerRadius = bubble.frame.size.height / 2
            bubble.center = startingPoint
            bubble.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            bubble.backgroundColor = bubbleColor
            containerView.addSubview(bubble)
            
            presentedControllerView.center = startingPoint
            presentedControllerView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            presentedControllerView.alpha = 0
            containerView.addSubview(presentedControllerView)
            
            UIView.animate(withDuration: duration, animations: {
                self.bubble.transform = CGAffineTransform.identity
                presentedControllerView.transform = CGAffineTransform.identity
                presentedControllerView.alpha = 1
                presentedControllerView.center = originalCenter
            }, completion: { (_) in
                transitionContext.completeTransition(true)
                self.bubble.isHidden = true
                fromViewController?.endAppearanceTransition()
                toViewController?.endAppearanceTransition()
            })
        } else {
            let key = (transitionMode == .pop) ? UITransitionContextViewKey.to : UITransitionContextViewKey.from
            let returningControllerView = transitionContext.view(forKey: key)!
            let originalCenter = returningControllerView.center
            let originalSize = returningControllerView.frame.size
            
            bubble.frame = frameForBubble(originalCenter, size: originalSize, start: startingPoint)
            bubble.layer.cornerRadius = bubble.frame.size.height / 2
            bubble.center = startingPoint
            bubble.isHidden = false
            
            UIView.animate(withDuration: duration, animations: {
                self.bubble.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                returningControllerView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                returningControllerView.center = self.startingPoint
                returningControllerView.alpha = 0
                
                if self.transitionMode == .pop {
                    containerView.insertSubview(returningControllerView, belowSubview: returningControllerView)
                    containerView.insertSubview(self.bubble, belowSubview: returningControllerView)
                }
            }, completion: { (_) in
                returningControllerView.center = originalCenter
                returningControllerView.removeFromSuperview()
                self.bubble.removeFromSuperview()
                transitionContext.completeTransition(true)
                
                fromViewController?.endAppearanceTransition()
                toViewController?.endAppearanceTransition()
            })
        }
    }
}

private extension BubbleTransition {
    func frameForBubble(_ originalCenter: CGPoint, size originalSize: CGSize, start: CGPoint) -> CGRect {
        let lengthX = fmax(start.x, originalSize.width - start.x)
        let lengthY = fmax(start.y, originalSize.height - start.y)
        let offset = sqrt(lengthX * lengthX + lengthY * lengthY) * 2
        let size = CGSize(width: offset, height: offset)
        
        return CGRect(origin: CGPoint.zero, size: size)
    }
}

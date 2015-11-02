//
//  TFSlideControlLeftToRightStrategy.swift
//  Pods
//
//  Created by Jakub Knejzlik on 07/10/15.
//
//

import UIKit

public protocol TFSlideControlSliderStrategyProtocol {
    func isTouchValidForBegin(slideControl: TFSlideControl, touch: UITouch) -> Bool
    func isTouchValidForFinish(slideControl: TFSlideControl, touch: UITouch) -> Bool
    
    func updateSlideToInitialPosition(slideControl: TFSlideControl, animated: Bool)
    func updateSlideToFinalPosition(slideControl: TFSlideControl, animated: Bool, completion: () -> ())
    func updateSlideControlForTouch(slideControl: TFSlideControl, touch: UITouch)
    
    func animateGuideTrace(slideControl: TFSlideControl, completion: () -> ())
}

public class TFSlideControlSliderDefaultStrategy: TFSlideControlSliderStrategyProtocol {

    public init() {
    }
    
    public func isTouchValidForBegin(slideControl: TFSlideControl, touch: UITouch) -> Bool {
        let location = touch.locationInView(slideControl)
        return CGRectContainsPoint(slideControl.handleView.frame, location)
    }
    
    
    public func isTouchValidForFinish(slideControl: TFSlideControl, touch: UITouch) -> Bool {
        let rect = rectForSlideControl(slideControl, touch: touch)
        return CGRectGetMinX(rect) == CGRectGetMaxX(slideControl.contentBounds) - slideControl.horizontalPadding - CGFloat(slideControl.handleConfirmOffset)
    }
    
    public func updateSlideToInitialPosition(slideControl: TFSlideControl, animated: Bool) {
        let duration = animated ? 0.3 : 0.0
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            var handleFrame = slideControl.handleView.frame
            handleFrame.origin = CGPointMake(slideControl.horizontalPadding, 0)
            slideControl.handleView.frame = handleFrame
        }, completion: nil)
    }
    
    public func updateSlideToFinalPosition(slideControl: TFSlideControl, animated: Bool, completion: () -> ()) {
        let duration = animated ? 0.3 : 0.0
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            var handleFrame = slideControl.handleView.frame
            handleFrame.origin = CGPointMake(CGRectGetMaxX(slideControl.contentBounds) - slideControl.horizontalPadding - CGFloat(slideControl.handleConfirmOffset), 0)
            slideControl.handleView.frame = handleFrame
            }, completion: { (finished: Bool) -> Void in
                completion()
        })
    }
    
    public func updateSlideControlForTouch(slideControl: TFSlideControl, touch: UITouch) {
        slideControl.handleView.frame = rectForSlideControl(slideControl, touch: touch)
    }
    
    public func animateGuideTrace(slideControl: TFSlideControl, completion: () -> ()) {
        
    }

    
    internal func rectForSlideControl(slideControl: TFSlideControl, touch: UITouch) -> CGRect {
        let location = touch.locationInView(slideControl)
        var handleFrame = slideControl.handleView.frame
        var x = location.x - slideControl.trackingTouchHandlePosition.x
        x = min(x,CGRectGetMaxX(slideControl.contentBounds) - slideControl.horizontalPadding - CGFloat(slideControl.handleConfirmOffset))
        x = max(x,slideControl.horizontalPadding)
        handleFrame.origin = CGPointMake(x, 0)
        return handleFrame
    }
    
}
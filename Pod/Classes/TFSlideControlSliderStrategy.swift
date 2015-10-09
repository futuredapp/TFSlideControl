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
    func updateSlideControlForTouch(slideControl: TFSlideControl, touch: UITouch)
}


public class TFSlideControlSliderDefaultStrategy: TFSlideControlSliderStrategyProtocol {

    public func isTouchValidForBegin(slideControl: TFSlideControl, touch: UITouch) -> Bool {
        let location = touch.locationInView(slideControl)
        return CGRectContainsPoint(CGRectInset(slideControl.handleView.frame, -10, 0), location)
    }
    
    
    public func isTouchValidForFinish(slideControl: TFSlideControl, touch: UITouch) -> Bool {
        let rect = rectForSlideControl(slideControl, touch: touch)
        return CGRectGetMaxX(rect) == CGRectGetMaxX(slideControl.bounds)
    }
    
    
    public func updateSlideToInitialPosition(slideControl: TFSlideControl, animated: Bool) {
        let duration = animated ? 0.3 : 0.0
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            var handleFrame = slideControl.handleView.frame
            handleFrame.origin = CGPointZero
            slideControl.handleView.frame = handleFrame
        }, completion: nil)
    }
    
    public func updateSlideControlForTouch(slideControl: TFSlideControl, touch: UITouch) {
        slideControl.handleView.frame = rectForSlideControl(slideControl, touch: touch)
    }
    
    private func rectForSlideControl(slideControl: TFSlideControl, touch: UITouch) -> CGRect {
        let location = touch.locationInView(slideControl)
        var handleFrame = slideControl.handleView.frame
        var x = location.x - slideControl.trackingTouchHandlePosition.x
        x = min(x,CGRectGetWidth(slideControl.bounds) - CGRectGetWidth(handleFrame))
        x = max(x,0)
        handleFrame.origin = CGPointMake(x, 0)
        return handleFrame
    }
    
}
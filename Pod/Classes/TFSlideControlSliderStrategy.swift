//
//  TFSlideControlLeftToRightStrategy.swift
//  Pods
//
//  Created by Jakub Knejzlik on 07/10/15.
//
//

import UIKit

public protocol TFSlideControlSliderStrategyProtocol {
    func isTouchValidForBegin(_ slideControl: TFSlideControl, touch: UITouch) -> Bool
    func isTouchValidForFinish(_ slideControl: TFSlideControl, touch: UITouch) -> Bool
    
    func updateSlideToInitialPosition(_ slideControl: TFSlideControl, animated: Bool)
    func updateSlideToFinalPosition(_ slideControl: TFSlideControl, animated: Bool, completion: @escaping () -> ())
    func updateSlideControlForTouch(_ slideControl: TFSlideControl, touch: UITouch)
    
    func animateGuideTrace(_ slideControl: TFSlideControl, completion: @escaping () -> ())
}

open class TFSlideControlSliderDefaultStrategy: TFSlideControlSliderStrategyProtocol {
    public init() {
    }
    
    open func isTouchValidForBegin(_ slideControl: TFSlideControl, touch: UITouch) -> Bool {
        let location = touch.location(in: slideControl)
        return slideControl.handleView.frame.contains(location)
    }
    
    
    open func isTouchValidForFinish(_ slideControl: TFSlideControl, touch: UITouch) -> Bool {
        let rect = rectForSlideControl(slideControl, touch: touch)
        return rect.minX == slideControl.contentBounds.maxX - slideControl.horizontalPadding - CGFloat(slideControl.handleConfirmOffset)
    }
    
    open func updateSlideToInitialPosition(_ slideControl: TFSlideControl, animated: Bool) {
        let duration = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            var handleFrame = slideControl.handleView.frame
            handleFrame.origin = CGPoint(x: slideControl.horizontalPadding, y: 0)
            slideControl.handleView.frame = handleFrame
        }, completion: nil)
    }
    
    open func updateSlideToFinalPosition(_ slideControl: TFSlideControl, animated: Bool, completion: @escaping () -> ()) {
        let duration = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            var handleFrame = slideControl.handleView.frame
            handleFrame.origin = CGPoint(x: slideControl.contentBounds.maxX - slideControl.horizontalPadding - CGFloat(slideControl.handleConfirmOffset), y: 0)
            slideControl.handleView.frame = handleFrame
            }, completion: { (finished: Bool) -> Void in
                completion()
        })
    }
    
    open func updateSlideControlForTouch(_ slideControl: TFSlideControl, touch: UITouch) {
        slideControl.handleView.frame = rectForSlideControl(slideControl, touch: touch)
    }
    
    open func animateGuideTrace(_ slideControl: TFSlideControl, completion: @escaping () -> ()) {
        
    }

    
    open func rectForSlideControl(_ slideControl: TFSlideControl, touch: UITouch) -> CGRect {
        let location = touch.location(in: slideControl)
        var handleFrame = slideControl.handleView.frame
        var x = location.x - slideControl.trackingTouchHandlePosition.x
        x = min(x,slideControl.contentBounds.maxX - slideControl.horizontalPadding - CGFloat(slideControl.handleConfirmOffset))
        x = max(x,slideControl.horizontalPadding)
        handleFrame.origin = CGPoint(x: x, y: 0)
        return handleFrame
    }
    
}

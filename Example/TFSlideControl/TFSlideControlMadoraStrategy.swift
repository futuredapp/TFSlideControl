//
//  TFSlideControlLeftToRightStrategy.swift
//  Pods
//
//  Created by Jakub Knejzlik on 07/10/15.
//
//

import UIKit
import TFSlideControl

open class TFSlideControlSliderMadoraStrategy: TFSlideControlSliderDefaultStrategy {

    open override func isTouchValidForBegin(_ slideControl: TFSlideControl, touch: UITouch) -> Bool {
        let location = touch.location(in: slideControl)
        return location.x > slideControl.horizontalPadding
    }
    
    open override func updateSlideControlForTouch(_ slideControl: TFSlideControl, touch: UITouch) {
        let rect = rectForSlideControl(slideControl, touch: touch)
        if (rect.origin.x > slideControl.handleView.frame.origin.x) {
            slideControl.handleView.frame = rect
        }
    }
    
    open override func updateSlideToInitialPosition(_ slideControl: TFSlideControl, animated: Bool) {
        let duration = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            var handleFrame = slideControl.handleView.frame
            handleFrame.origin = CGPoint(x: slideControl.horizontalPadding - CGFloat(slideControl.handleWidth), y: 0)
            slideControl.handleView.frame = handleFrame
            }, completion: nil)
    }
    
    open override func isTouchValidForFinish(_ slideControl: TFSlideControl, touch: UITouch) -> Bool {
        let rect = rectForSlideControl(slideControl, touch: touch)
                
        if rect.minX == slideControl.contentBounds.maxX - slideControl.horizontalPadding - CGFloat(slideControl.handleConfirmOffset) {
            // slider is in final position
            return true;
        } else if let maskView = slideControl.mask , rect.maxX > (slideControl.bounds.midX - maskView.frame.width / 8) {
            slideControl.submit(true)
        }
        
        return false;
    }
    
    open override func rectForSlideControl(_ slideControl: TFSlideControl, touch: UITouch) -> CGRect {
        let location = touch.location(in: slideControl)
        var handleFrame = slideControl.handleView.frame
        var x = location.x - slideControl.trackingTouchHandlePosition.x
        x = min(x,slideControl.contentBounds.maxX - slideControl.horizontalPadding - CGFloat(slideControl.handleConfirmOffset))
        x = max(x,slideControl.horizontalPadding - CGFloat(slideControl.handleWidth))
        handleFrame.origin = CGPoint(x: x, y: 0)
        return handleFrame
    }

    open override func animateGuideTrace(_ slideControl: TFSlideControl, completion: @escaping () -> ()) {
        slideControl.guideView?.alpha = 1.0
        
        if let guideView = slideControl.guideView {
            var guideFrame = guideView.frame
            guideFrame.origin = CGPoint(x: slideControl.horizontalPadding - guideFrame.width, y: 0)
            guideView.frame = guideFrame
        }

        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            if let guideView = slideControl.guideView {
                var guideFrame = guideView.frame
                guideFrame.origin = CGPoint(x: slideControl.contentBounds.maxX - slideControl.horizontalPadding - CGFloat(slideControl.handleConfirmOffset), y: 0)
                guideView.frame = guideFrame
            }
        }, completion: { (finished: Bool) -> Void in
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                slideControl.guideView?.alpha = 0.0
            }, completion: { (finished: Bool) -> Void in
                completion()
            })
        })
    }
}

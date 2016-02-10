//
//  TFSlideControlLeftToRightStrategy.swift
//  Pods
//
//  Created by Jakub Knejzlik on 07/10/15.
//
//

import UIKit
import TFSlideControl

public class TFSlideControlSliderMadoraStrategy: TFSlideControlSliderDefaultStrategy {

    public override func isTouchValidForBegin(slideControl: TFSlideControl, touch: UITouch) -> Bool {
        let location = touch.locationInView(slideControl)
        return location.x > slideControl.horizontalPadding
    }
    
    public override func updateSlideControlForTouch(slideControl: TFSlideControl, touch: UITouch) {
        let rect = rectForSlideControl(slideControl, touch: touch)
        if (rect.origin.x > slideControl.handleView.frame.origin.x) {
            slideControl.handleView.frame = rect
        }
    }
    
    public override func updateSlideToInitialPosition(slideControl: TFSlideControl, animated: Bool) {
        let duration = animated ? 0.3 : 0.0
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            var handleFrame = slideControl.handleView.frame
            handleFrame.origin = CGPointMake(slideControl.horizontalPadding - CGFloat(slideControl.handleWidth), 0)
            slideControl.handleView.frame = handleFrame
            }, completion: nil)
    }
    
    public override func isTouchValidForFinish(slideControl: TFSlideControl, touch: UITouch) -> Bool {
        let rect = rectForSlideControl(slideControl, touch: touch)
                
        if CGRectGetMinX(rect) == CGRectGetMaxX(slideControl.contentBounds) - slideControl.horizontalPadding - CGFloat(slideControl.handleConfirmOffset) {
            // slider is in final position
            return true;
        } else if let maskView = slideControl.maskView where CGRectGetMaxX(rect) > (CGRectGetMidX(slideControl.bounds) - CGRectGetWidth(maskView.frame) / 8) {
            slideControl.submit(true)
        }
        
        return false;
    }
    
    public override func rectForSlideControl(slideControl: TFSlideControl, touch: UITouch) -> CGRect {
        let location = touch.locationInView(slideControl)
        var handleFrame = slideControl.handleView.frame
        var x = location.x - slideControl.trackingTouchHandlePosition.x
        x = min(x,CGRectGetMaxX(slideControl.contentBounds) - slideControl.horizontalPadding - CGFloat(slideControl.handleConfirmOffset))
        x = max(x,slideControl.horizontalPadding - CGFloat(slideControl.handleWidth))
        handleFrame.origin = CGPointMake(x, 0)
        return handleFrame
    }

    public override func animateGuideTrace(slideControl: TFSlideControl, completion: () -> ()) {
        slideControl.guideView?.alpha = 1.0
        
        if let guideView = slideControl.guideView {
            var guideFrame = guideView.frame
            guideFrame.origin = CGPointMake(slideControl.horizontalPadding - CGRectGetWidth(guideFrame), 0)
            guideView.frame = guideFrame
        }

        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            if let guideView = slideControl.guideView {
                var guideFrame = guideView.frame
                guideFrame.origin = CGPointMake(CGRectGetMaxX(slideControl.contentBounds) - slideControl.horizontalPadding - CGFloat(slideControl.handleConfirmOffset), 0)
                guideView.frame = guideFrame
            }
        }, completion: { (finished: Bool) -> Void in
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                slideControl.guideView?.alpha = 0.0
            }, completion: { (finished: Bool) -> Void in
                completion()
            })
        })
    }
}
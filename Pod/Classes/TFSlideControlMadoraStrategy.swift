//
//  TFSlideControlLeftToRightStrategy.swift
//  Pods
//
//  Created by Jakub Knejzlik on 07/10/15.
//
//

import UIKit

public class TFSlideControlSliderMadoraStrategy: TFSlideControlSliderDefaultStrategy {

    public override func isTouchValidForBegin(slideControl: TFSlideControl, touch: UITouch) -> Bool {
        return true
    }
    
    public override func isTouchValidForFinish(slideControl: TFSlideControl, touch: UITouch) -> Bool {
        let rect = rectForSlideControl(slideControl, touch: touch)
        
        if CGRectGetMinX(rect) == CGRectGetMaxX(slideControl.contentBounds) - slideControl.horizontalPadding - CGFloat(slideControl.handleConfirmOffset) {
            // slider is in final position
            return true;
        } else if CGRectGetMaxX(rect) > CGRectGetMidX(slideControl.frame) / 2 {
            slideControl.submit(true)
        }
        
        return false;
    }
    
    public override func updateSlideToInitialPosition(slideControl: TFSlideControl, animated: Bool) {
        let duration = animated ? 0.3 : 0.0
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            var handleFrame = slideControl.handleView.frame
            
            if let backgroundImage = slideControl.backgroundImage, backgroundView = slideControl.backgroundView {
                let scaledImageWidth = backgroundImage.size.width * backgroundView.frame.size.height / backgroundImage.size.height
                handleFrame.origin = CGPointMake(CGRectGetMidX(backgroundView.frame) - scaledImageWidth / 2 - CGFloat(slideControl.handleWidth), 0)
            } else {
                handleFrame.origin = CGPointMake(slideControl.backgroundView!.frame.origin.x, 0)
            }
            
            slideControl.handleView.frame = handleFrame
        }, completion: nil)
    }
    
    public override func updateSlideControlForTouch(slideControl: TFSlideControl, touch: UITouch) {
        let rect = rectForSlideControl(slideControl, touch: touch)
        if (rect.origin.x > slideControl.handleView.frame.origin.x) {
            slideControl.handleView.frame = rect
        }
    }
    
    public override func animateGuideTrace(slideControl: TFSlideControl, completion: () -> ()) {
        slideControl.guideView?.alpha = 1.0
        
        if let guideView = slideControl.guideView, backgroundImage = slideControl.backgroundImage, backgroundView = slideControl.backgroundView {
            var guideFrame = guideView.frame
            let scaledImageWidth = backgroundImage.size.width * backgroundView.frame.size.height / backgroundImage.size.height
            guideFrame.origin = CGPointMake(CGRectGetMidX(backgroundView.frame) - scaledImageWidth / 2 - CGFloat(slideControl.handleWidth), 0)
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
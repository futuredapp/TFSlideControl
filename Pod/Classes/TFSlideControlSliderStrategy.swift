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
        return location.x < max(CGRectGetWidth(slideControl.bounds)/4.0, 50)
    }
    
    
    public func isTouchValidForFinish(slideControl: TFSlideControl, touch: UITouch) -> Bool {
        let location = touch.locationInView(slideControl)
        return location.x > CGRectGetWidth(slideControl.bounds)
    }
    
    
    public func updateSlideToInitialPosition(slideControl: TFSlideControl, animated: Bool) {
        let duration = animated ? 0.3 : 0.0
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            slideControl.handleView.frame = CGRectMake(0, 0, 0, CGRectGetHeight(slideControl.bounds))
        }, completion: nil)
    }
    
    public func updateSlideControlForTouch(slideControl: TFSlideControl, touch: UITouch) {
        let location = touch.locationInView(slideControl)
        slideControl.handleView.frame = CGRectMake(0, 0, location.x, CGRectGetHeight(slideControl.bounds))
    }
    
}
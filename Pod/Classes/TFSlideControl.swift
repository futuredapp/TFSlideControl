//
//  TFSlideControl.swift
//  Pods
//
//  Created by Jakub Knejzlik on 07/10/15.
//
//

import UIKit


@IBDesignable public class TestView: UIView {
    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.greenColor()
        layer.cornerRadius = 10
        layer.borderColor = UIColor.redColor().CGColor
        layer.borderWidth = 2
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.greenColor()
        layer.cornerRadius = 10
        layer.borderColor = UIColor.redColor().CGColor
        layer.borderWidth = 2
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
}



public class TFSlideControl: UIControl {
    
    public var sliderStrategy: TFSlideControlSliderStrategyProtocol!
    public var resetAfterValueChange: Bool = false
    
    @IBInspectable public var backgroundImage: UIImage! {
        get{
            if let imageView = backgroundView as? UIImageView {
                return imageView.image
            } else {
                return nil
            }
        }
        set(image){
            let imageView = UIImageView.init()
            imageView.contentMode = .ScaleToFill
            imageView.image = image
            backgroundView = imageView
        }
    }
    @IBInspectable public var overlayImage: UIImage! {
        get{
            if let imageView = overlayView as? UIImageView {
                return imageView.image
            } else {
                return nil
            }
        }
        set(image){
            let imageView = UIImageView.init()
            imageView.contentMode = .ScaleToFill
            imageView.image = image
            overlayView = imageView
        }
    }
    @IBInspectable public var maskImage: UIImage! {
        didSet{
            layer.mask = CALayer.init()
            if let maskLayer = self.layer.mask {
                maskLayer.contents = maskImage.CGImage
            }
        }
    }
    
    
    public var backgroundView: UIView! {
        willSet{
            if backgroundView != nil {
                backgroundView.removeFromSuperview()
            }
        }
        didSet{
            self.addSubview(backgroundView)
            self.sendSubviewToBack(backgroundView)
        }
    }
    public var overlayView: UIView! {
        willSet{
            if overlayView != nil {
                overlayView.removeFromSuperview()
            }
        }
        didSet{
            self.addSubview(overlayView)
            self.bringSubviewToFront(overlayView)
        }
    }
    
    
    public var handleView: UIView! {
        willSet{
            handleView.removeFromSuperview()
        }
        didSet{
            if overlayView != nil {
                self.insertSubview(handleView, belowSubview: overlayView)
            } else {
                self.addSubview(handleView)
            }
        }
    }
    
    private var trackingTouch: UITouch?
    
    

    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    private func customInit() {
        sliderStrategy = TFSlideControlSliderDefaultStrategy.init()
        handleView = UIView.init()
        handleView.backgroundColor = UIColor.whiteColor()
        addSubview(handleView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if overlayView != nil {
            overlayView.frame = self.bounds
        }
        if backgroundView != nil {
            backgroundView.frame = self.bounds
        }
        if let maskLayer = self.layer.mask {
            maskLayer.frame = self.bounds
        }
    }
    

    public func reset(animated: Bool) {
        sliderStrategy.updateSlideToInitialPosition(self, animated: animated)
    }
    
    
    public override func prepareForInterfaceBuilder() {
        
    }
    
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if sliderStrategy.isTouchValidForBegin(self, touch: touch) && (trackingTouch == nil) {
                startDragging(touch)
                break
            }
        }
    }
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        updateDragging()
    }
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if trackingTouch != nil && touches.contains(trackingTouch!){
            if sliderStrategy.isTouchValidForFinish(self, touch: trackingTouch!){
                endDragging()
            } else {
                cancelDragging()
            }
        }
    }
    
    
    
    private func updateSlideControlForTrackingTouch() {
        if trackingTouch != nil{
            sliderStrategy.updateSlideControlForTouch(self, touch: trackingTouch!)
        }
    }
    
    private func startDragging(touch: UITouch) {
        trackingTouch = touch
        reset(false)
    }
    private func updateDragging() {
        updateSlideControlForTrackingTouch()
    }
    private func cancelDragging() {
        trackingTouch = nil
        reset(true)
    }
    private func endDragging() {
        updateSlideControlForTrackingTouch()
        trackingTouch = nil
        sendActionsForControlEvents(.ValueChanged)
        if resetAfterValueChange {
            reset(true)
        }
    }
}

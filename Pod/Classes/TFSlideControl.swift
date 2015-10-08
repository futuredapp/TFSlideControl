//
//  TFSlideControl.swift
//  Pods
//
//  Created by Jakub Knejzlik on 07/10/15.
//
//

import UIKit

@IBDesignable public class TFSlideControl: UIControl {
    
    public var sliderStrategy: TFSlideControlSliderStrategyProtocol = TFSlideControlSliderDefaultStrategy()
    public var resetAfterValueChange: Bool = false
    
    
    public var trackingTouch: UITouch?
    public var trackingTouchHandlePosition: CGPoint = CGPointZero
    
    
    @IBInspectable public var backgroundImage: UIImage? {
        get{
            if let imageView = backgroundView as? UIImageView {
                return imageView.image
            } else {
                return nil
            }
        }
        set(image){
            let imageView = UIImageView.init()
            imageView.contentMode = .Center
            imageView.image = image
            backgroundView = imageView
        }
    }
    @IBInspectable public var overlayImage: UIImage? {
        get{
            if let imageView = overlayView as? UIImageView {
                return imageView.image
            } else {
                return nil
            }
        }
        set(image){
            let imageView = UIImageView.init()
            imageView.contentMode = .Center
            imageView.image = image
            overlayView = imageView
        }
    }
    
    @IBInspectable public var maskImage: UIImage? {
        didSet{
            if let maskImage = maskImage {
                let _maskView = UIImageView()
                _maskView.contentMode = .Center
                _maskView.image = maskImage
                maskView = _maskView
            } else {
                maskView = nil
            }
        }
    }
    @IBInspectable public var handleWidth: Float = 50.0 {
        didSet(value) {
            updateHandleFrame()
        }
    }
    @IBInspectable public var handleImage: UIImage? {
        didSet(value) {
            if let handleImage = handleImage {
                let imageView = UIImageView()
                imageView.contentMode = .Center
                imageView.image = handleImage
                handleView = imageView
                updateHandleFrame()
            }
        }
    }
    
    public var backgroundView: UIView? {
        willSet{
            backgroundView?.removeFromSuperview()
        }
        didSet{
            if let backgroundView = backgroundView {
                self.addSubview(backgroundView)
                self.sendSubviewToBack(backgroundView)
            }
        }
    }
    public var overlayView: UIView? {
        willSet{
            overlayView?.removeFromSuperview()
        }
        didSet{
            if let overlayView = overlayView {
                self.addSubview(overlayView)
                self.bringSubviewToFront(overlayView)
            }
        }
    }
    
    public var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    {
        willSet{
            handleView.removeFromSuperview()
        }
        didSet{
            if let overlayView = overlayView {
                self.insertSubview(handleView, belowSubview: overlayView)
            } else {
                self.addSubview(handleView)
            }
        }
    }
    
    

    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    private func customInit() {
        addSubview(handleView)
    }
    public override func prepareForInterfaceBuilder() {
//        handleView.frame = CGRectMake(0, 0, bounds.size.width/2.0, bounds.size.height)
//        handleWidth = 50.0
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        
        overlayView?.frame = bounds
        backgroundView?.frame = bounds
        maskView?.frame = bounds
        updateHandleFrame()
    }
    private func updateHandleFrame() {
        var handleFrame = handleView.frame
        handleFrame.size = CGSizeMake(CGFloat(handleWidth), CGRectGetHeight(bounds))
        handleView.frame = handleFrame
    }
    

    public func reset(animated: Bool) {
        sliderStrategy.updateSlideToInitialPosition(self, animated: animated)
    }
    
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if trackingTouch != nil{
            return
        }
        for touch in touches where sliderStrategy.isTouchValidForBegin(self, touch: touch){
            startDragging(touch)
            break
        }
    }
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        updateDragging()
    }
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let trackingTouch = trackingTouch where touches.contains(trackingTouch){
            if sliderStrategy.isTouchValidForFinish(self, touch: trackingTouch){
                endDragging()
            } else {
                cancelDragging()
            }
        }
    }
    
    
    
    private func updateSlideControlForTrackingTouch() {
        if let trackingTouch = trackingTouch {
            sliderStrategy.updateSlideControlForTouch(self, touch: trackingTouch)
        }
    }
    
    private func startDragging(touch: UITouch) {
        trackingTouch = touch
        trackingTouchHandlePosition = touch.locationInView(handleView)
        reset(false)
    }
    private func updateDragging() {
        updateSlideControlForTrackingTouch()
    }
    private func cancelDragging() {
        trackingTouch = nil
        trackingTouchHandlePosition = CGPointZero
        reset(true)
    }
    private func endDragging() {
        updateSlideControlForTrackingTouch()
        trackingTouch = nil
        trackingTouchHandlePosition = CGPointZero
        sendActionsForControlEvents(.ValueChanged)
        if resetAfterValueChange {
            reset(true)
        }
    }
}

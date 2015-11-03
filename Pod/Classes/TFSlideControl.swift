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
    public var resetWhenDraggingCancelled = false
    public var resetAfterValueChange: Bool = false
    public var guideAnimationInterval: NSTimeInterval = 1.25
    public private(set) var horizontalPadding: CGFloat = 0
    
    public var trackingTouch: UITouch?
    public var trackingTouchHandlePosition: CGPoint = CGPointZero
    private var guideTimer: NSTimer?
    
    @IBInspectable public var contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0) {
        didSet {
            setNeedsLayout()
        }
    }
    
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
            imageView.contentMode = .ScaleAspectFit
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
            imageView.contentMode = .ScaleAspectFit
            imageView.image = image
            overlayView = imageView
        }
    }
    
    @IBInspectable public var guideImage: UIImage? {
        didSet {
            if let guideImage = guideImage {
                let guideView = UIImageView()
                guideView.contentMode = .Right
                guideView.image = guideImage
                self.guideView = guideView
            } else {
                self.guideView = nil
            }
        }
    }
    
    @IBInspectable public var maskImage: UIImage? {
        didSet {
            if let maskImage = maskImage {
                let _maskView = UIImageView()
                _maskView.contentMode = .ScaleAspectFit
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
    @IBInspectable public var handleConfirmOffset: Float = 0.0
    @IBInspectable public var handleImage: UIImage? {
        didSet(value) {
            if let handleImage = handleImage {
                let imageView = UIImageView()
                imageView.contentMode = .Right
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
    
    public var guideView: UIView? {
        willSet {
            guideView?.removeFromSuperview()
        }
        didSet {
            if let guideView = guideView {
                self.insertSubview(guideView, belowSubview: handleView)
            }
        }
    }
    
    lazy public var contentBounds: CGRect = {
       return UIEdgeInsetsInsetRect(self.bounds, self.contentInsets)
    }()

    
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
    
    //MARK: guide view handling
    
    public func scheduleGuideAnimationIfNeeded() {
        if guideTimer == nil || !guideTimer!.valid {
            guideTimer = NSTimer.scheduledTimerWithTimeInterval(guideAnimationInterval, target: self, selector: "guideAnimationTick", userInfo: nil, repeats: false)
        }
    }
    
    public func guideAnimationTick() {
        sliderStrategy.animateGuideTrace(self) { () -> () in
            self.scheduleGuideAnimationIfNeeded()
        }
    }
    
    //MARK: frame handling

    override public func layoutSubviews() {
        super.layoutSubviews()
        overlayView?.frame = contentBounds
        backgroundView?.frame = contentBounds
        maskView?.frame = contentBounds
        updateHandleFrame()
        
        if let maskImage = self.maskImage {
            horizontalPadding = (CGRectGetWidth(self.frame) - maskImage.size.width) / 2
        } else {
            horizontalPadding = 0
        }
        
        reset(false)
        
        scheduleGuideAnimationIfNeeded()
    }
    
    private func updateHandleFrame() {
        var handleFrame = handleView.frame
        handleFrame.size = CGSizeMake(CGFloat(handleWidth), CGRectGetHeight(bounds))
        handleView.frame = handleFrame
        guideView?.frame = handleFrame
    }
    
    // MARK: public state methods
    
    public func reset(animated: Bool) {
        sliderStrategy.updateSlideToInitialPosition(self, animated: animated)
    }
    
    public func submit(animated: Bool) {
        sliderStrategy.updateSlideToFinalPosition(self, animated: animated) { () -> () in
            self.endDragging()
        }
    }
    
    public func tryStartDragging(touches: Set<UITouch>) {
        if trackingTouch != nil{
            return
        }
        for touch in touches where sliderStrategy.isTouchValidForBegin(self, touch: touch){
            startDragging(touch)
            break
        }
    }
    
    //MARK: event handling
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guideTimer?.invalidate()
        guideTimer = nil
        
        tryStartDragging(touches)
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if trackingTouch == nil {
            tryStartDragging(touches)
        }
        
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
        
        scheduleGuideAnimationIfNeeded()
    }
    
    
    //MARK: private event handling methods
    
    private func updateSlideControlForTrackingTouch() {
        if let trackingTouch = trackingTouch {
            sliderStrategy.updateSlideControlForTouch(self, touch: trackingTouch)
        }
    }
    
    private func startDragging(touch: UITouch) {
        trackingTouch = touch
        trackingTouchHandlePosition = touch.locationInView(handleView)
        guideView?.alpha = 0.0
        
        if resetWhenDraggingCancelled {
            reset(false)
        }
    }
    private func updateDragging() {
        updateSlideControlForTrackingTouch()
    }
    private func cancelDragging() {
        trackingTouch = nil
        trackingTouchHandlePosition = CGPointZero
        
        if resetWhenDraggingCancelled {
            reset(true)
        }
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

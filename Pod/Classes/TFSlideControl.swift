//
//  TFSlideControl.swift
//  Pods
//
//  Created by Jakub Knejzlik on 07/10/15.
//
//

import UIKit

@IBDesignable open class TFSlideControl: UIControl {
    
    open var sliderStrategy: TFSlideControlSliderStrategyProtocol = TFSlideControlSliderDefaultStrategy()
    open var resetWhenDraggingCancelled = false
    open var resetAfterValueChange: Bool = false
    open var guideAnimationInterval: TimeInterval = 1.25
    open fileprivate(set) var horizontalPadding: CGFloat = 0
    
    open var trackingTouch: UITouch?
    open var trackingTouchHandlePosition: CGPoint = CGPoint.zero
    fileprivate var guideTimer: Timer?
    
    @IBInspectable open var contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var backgroundImage: UIImage? {
        get{
            if let imageView = backgroundView as? UIImageView {
                return imageView.image
            } else {
                return nil
            }
        }
        set(image){
            let imageView = UIImageView.init()
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            backgroundView = imageView
        }
    }
    
    @IBInspectable open var overlayImage: UIImage? {
        get{
            if let imageView = overlayView as? UIImageView {
                return imageView.image
            } else {
                return nil
            }
        }
        set(image){
            let imageView = UIImageView.init()
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            overlayView = imageView
        }
    }
    
    @IBInspectable open var guideImage: UIImage? {
        didSet {
            if let guideImage = guideImage {
                let guideView = UIImageView()
                guideView.contentMode = .right
                guideView.image = guideImage
                self.guideView = guideView
            } else {
                self.guideView = nil
            }
        }
    }
    
    @IBInspectable open var maskImage: UIImage? {
        didSet {
            if let maskImage = maskImage {
                let _maskView = UIImageView()
                _maskView.contentMode = .scaleAspectFit
                _maskView.image = maskImage
                mask = _maskView                
            } else {
                mask = nil
            }
        }
    }
    @IBInspectable open var handleWidth: Float = 50.0 {
        didSet(value) {
            updateHandleFrame()
        }
    }
    @IBInspectable open var handleConfirmOffset: Float = 0.0
    @IBInspectable open var handleImage: UIImage? {
        didSet(value) {
            if let handleImage = handleImage {
                let imageView = UIImageView()
                imageView.contentMode = .right
                imageView.image = handleImage
                handleView = imageView
                updateHandleFrame()
            }
        }
    }
    
    open var backgroundView: UIView? {
        willSet{
            backgroundView?.removeFromSuperview()
        }
        didSet{
            if let backgroundView = backgroundView {
                self.addSubview(backgroundView)
                self.sendSubview(toBack: backgroundView)
            }
        }
    }
    open var overlayView: UIView? {
        willSet{
            overlayView?.removeFromSuperview()
        }
        didSet{
            if let overlayView = overlayView {
                self.addSubview(overlayView)
                self.bringSubview(toFront: overlayView)
            }
        }
    }
    
    open var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
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
    
    open var guideView: UIView? {
        willSet {
            guideView?.removeFromSuperview()
        }
        didSet {
            if let guideView = guideView {
                self.insertSubview(guideView, belowSubview: handleView)
            }
        }
    }
    
    lazy open var contentBounds: CGRect = {
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
    
    fileprivate func customInit() {
        addSubview(handleView)
    }
    
    //MARK: guide view handling
    
    open func scheduleGuideAnimationIfNeeded() {
        if guideTimer == nil || !guideTimer!.isValid {
            guideTimer = Timer.scheduledTimer(timeInterval: guideAnimationInterval, target: self, selector: #selector(TFSlideControl.guideAnimationTick), userInfo: nil, repeats: false)
        }
    }
    
    open func guideAnimationTick() {
        sliderStrategy.animateGuideTrace(self) { () -> () in
            self.scheduleGuideAnimationIfNeeded()
        }
    }
    
    //MARK: frame handling

    override open func layoutSubviews() {
        super.layoutSubviews()
        overlayView?.frame = contentBounds
        backgroundView?.frame = contentBounds
        mask?.frame = contentBounds
        updateHandleFrame()
        
        if let maskImage = self.maskImage, let maskView = self.mask {
            let scale = maskView.frame.height / maskImage.size.height
            horizontalPadding = (self.frame.width - scale * maskImage.size.width) / 2
        } else {
            horizontalPadding = 0
        }
        
        reset(false)
        
        scheduleGuideAnimationIfNeeded()
    }
    
    fileprivate func updateHandleFrame() {
        var handleFrame = handleView.frame
        handleFrame.size = CGSize(width: CGFloat(handleWidth), height: bounds.height)
        handleView.frame = handleFrame
        guideView?.frame = handleFrame
    }
    
    // MARK: public state methods
    
    open func reset(_ animated: Bool) {
        sliderStrategy.updateSlideToInitialPosition(self, animated: animated)
    }
    
    open func submit(_ animated: Bool) {
        sliderStrategy.updateSlideToFinalPosition(self, animated: animated) { () -> () in
            self.endDragging()
        }
    }
    
    open func tryStartDragging(_ touches: Set<UITouch>) {
        if trackingTouch != nil{
            return
        }
        for touch in touches where sliderStrategy.isTouchValidForBegin(self, touch: touch){
            startDragging(touch)
            break
        }
    }
    
    //MARK: event handling
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guideTimer?.invalidate()
        guideTimer = nil
        
        tryStartDragging(touches)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if trackingTouch == nil {
            tryStartDragging(touches)
        }
        
        updateDragging()
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let trackingTouch = trackingTouch , touches.contains(trackingTouch){
            if sliderStrategy.isTouchValidForFinish(self, touch: trackingTouch){
                endDragging()
            } else {
                cancelDragging()
            }
        }
        
        scheduleGuideAnimationIfNeeded()
    }
    
    
    //MARK: private event handling methods
    
    fileprivate func updateSlideControlForTrackingTouch() {
        if let trackingTouch = trackingTouch {
            sliderStrategy.updateSlideControlForTouch(self, touch: trackingTouch)
        }
    }
    
    fileprivate func startDragging(_ touch: UITouch) {
        trackingTouch = touch
        trackingTouchHandlePosition = touch.location(in: handleView)
        guideView?.alpha = 0.0
        
        if resetWhenDraggingCancelled {
            reset(false)
        }
    }
    fileprivate func updateDragging() {
        updateSlideControlForTrackingTouch()
    }
    fileprivate func cancelDragging() {
        trackingTouch = nil
        trackingTouchHandlePosition = CGPoint.zero
        
        if resetWhenDraggingCancelled {
            reset(true)
        }
    }
    fileprivate func endDragging() {
        updateSlideControlForTrackingTouch()
        trackingTouch = nil
        trackingTouchHandlePosition = CGPoint.zero
        sendActions(for: .valueChanged)
        if resetAfterValueChange {
            reset(true)
        }
    }
}

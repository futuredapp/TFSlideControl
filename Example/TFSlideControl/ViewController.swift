//
//  ViewController.swift
//  TFSlideControl
//
//  Created by Jakub Knejzlik on 10/07/2015.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

import UIKit
import TFSlideControl

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

class ViewController: UIViewController {

    @IBOutlet var slideControl1: TFSlideControl!
    @IBOutlet var slideControl2: TFSlideControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        slideControl2.sliderStrategy = TFSlideControlSliderMadoraStrategy()
        
//        slideControl1.overlayImage = UIImage.init(named: "bowtie_shadow")
//        slideControl1.maskImage = UIImage.init(named: "bowtie_mask")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didSlide(_ slider: TFSlideControl) {
        let alert = UIAlertController.init(title: "Your did slide!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { (UIAlertAction) -> Void in
            alert.dismiss(animated: true, completion: nil)
            delay(1, closure: { () -> () in
                slider.reset(true)
            })
        }))
        present(alert, animated: true, completion: nil)
    }
}


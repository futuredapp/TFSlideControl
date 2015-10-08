//
//  ViewController.swift
//  TFSlideControl
//
//  Created by Jakub Knejzlik on 10/07/2015.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

import UIKit
import TFSlideControl

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

class ViewController: UIViewController {

    @IBOutlet var slideControl1: TFSlideControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        slideControl1.overlayImage = UIImage.init(named: "bowtie_shadow")
//        slideControl1.maskImage = UIImage.init(named: "bowtie_mask")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didSlide(slider: TFSlideControl) {
        let alert = UIAlertController.init(title: "Your did slide!", message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .Cancel, handler: { (UIAlertAction) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
            delay(1, closure: { () -> () in
                slider.reset(true)
            })
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
}


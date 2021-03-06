//
//  ViewController.swift
//  Canvas
//
//  Created by Connie Yu on 2/24/16.
//  Copyright © 2016 cy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var trayView: UIView!
    var trayOriginalCenter: CGPoint!
    var trayClosedOffset: CGFloat!
    var trayCenterWhenOpen: CGPoint!
    var trayCenterWhenClosed: CGPoint!
    
    var newlyCreatedImage: UIImageView!
    var newlyCreatedImageOriginalCenter: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trayClosedOffset = 170
        trayCenterWhenOpen = trayView.center
        trayCenterWhenClosed = CGPoint(x: trayView.center.x, y: trayView.center.y + trayClosedOffset)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onTrayTap:")
        trayView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Enable simultaneous gesture recognizers
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @IBAction func onTrayPanGesture(sender: UIPanGestureRecognizer) {
        let point = sender.locationInView(view)
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            trayOriginalCenter = trayView.center
            print("Gesture began at: \(point)")
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
            print("Gesture changed at: \(point)")
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            if velocity.y > 0 {
                animateTrayClosing()
            } else {
                animateTrayOpening()

            }
            print("Gesture ended at: \(point)")
        }
    }
    
    func animateTrayOpening() {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations: { () -> Void in
            self.trayView.center = self.trayCenterWhenOpen
        }, completion: nil)
    }
    
    func animateTrayClosing() {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.trayView.center = self.trayCenterWhenClosed
        }, completion: nil)
    }
    
    func onTrayTap(sender: UITapGestureRecognizer) {
        if trayView.center == trayCenterWhenOpen {
            animateTrayClosing()
        } else {
            animateTrayOpening()
        }
    }
    
    
    @IBAction func onImagePanGesture(sender: UIPanGestureRecognizer) {
        let imageView = sender.view as! UIImageView

        if sender.state == UIGestureRecognizerState.Began {
            // Create a new image view with same image as the one currently panning
            newlyCreatedImage = UIImageView(image: imageView.image)
            newlyCreatedImage.userInteractionEnabled = true
            
            // Add pan gesture recognizer
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onImagePan:")
            newlyCreatedImage.addGestureRecognizer(panGestureRecognizer)
            
            // Add pinch gesture recognizer
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "onImagePinch:")
            newlyCreatedImage.addGestureRecognizer(pinchGestureRecognizer)
            pinchGestureRecognizer.delegate = self;

            // Add rotate gesture recognizer
            let rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "onImageRotate:")
            newlyCreatedImage.addGestureRecognizer(rotateGestureRecognizer)
            rotateGestureRecognizer.delegate = self;
            
            // Add doubletap gesture recognizer
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onImageDoubleTap:")
            doubleTapGestureRecognizer.numberOfTapsRequired = 2;
            newlyCreatedImage.addGestureRecognizer(doubleTapGestureRecognizer)
            doubleTapGestureRecognizer.delegate = self;
            
            // Add new image to the tray's parent view
            view.addSubview(newlyCreatedImage)
            
            // Initialize the position of the new image
            newlyCreatedImage.center = imageView.center
            
            // Offset coordinate since the original image is in the tray, but the new image is in the main view
            newlyCreatedImage.center.y += trayView.frame.origin.y
            
            newlyCreatedImageOriginalCenter = newlyCreatedImage.center
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            let translation = sender.translationInView(view)
            newlyCreatedImage.center = CGPoint(x: newlyCreatedImageOriginalCenter.x + translation.x, y: newlyCreatedImageOriginalCenter.y + translation.y)

        } else if sender.state == UIGestureRecognizerState.Ended {
        
        }
    }
    
    func onImagePan(sender: UIPanGestureRecognizer) {
        let imageView = sender.view as! UIImageView

        if sender.state == UIGestureRecognizerState.Began {
            // Scale image to be larger
            imageView.transform = CGAffineTransformMakeScale(2, 2)
            
            newlyCreatedImageOriginalCenter = imageView.center

        } else if sender.state == UIGestureRecognizerState.Changed {
            let translation = sender.translationInView(view)
            imageView.center = CGPoint(x: newlyCreatedImageOriginalCenter.x + translation.x, y: newlyCreatedImageOriginalCenter.y + translation.y)

        } else if sender.state == UIGestureRecognizerState.Ended {
            // Scale image back to normal size
            imageView.transform = CGAffineTransformIdentity
        }
    }
    
    func onImagePinch(sender: UIPinchGestureRecognizer) {
        print("onImagePinch")
        let imageView = sender.view as! UIImageView
        // Get the scale value from the pinch gesture recognizer
        let scale = sender.scale

        imageView.transform = CGAffineTransformScale(imageView.transform, scale, scale)
        sender.scale = 1
    }
    
    func onImageRotate(sender: UIRotationGestureRecognizer) {
        print("onImageRotate")
        let imageView = sender.view as! UIImageView
        let rotation = sender.rotation

        imageView.transform = CGAffineTransformRotate(imageView.transform, rotation)
        sender.rotation = 0
    }

    func onImageDoubleTap(sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        imageView.removeFromSuperview()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

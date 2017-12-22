//
//  ViewController.swift
//  swipe_test3
//
//  Created by Michael Swofford on 9/2/17.
//  Copyright © 2017 Michael Swofford. All rights reserved.
//

import UIKit
//test change
class ViewController: UIViewController {
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var imgNo: UIImageView!
    @IBOutlet weak var imgYes: UIImageView!
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var nextPicView: UIView!
    @IBOutlet weak var PrevPicView: UIView!
    @IBOutlet weak var PrevPicLbl: UILabel!
    @IBOutlet weak var nextPicLbl: UILabel!
    @IBOutlet weak var PicCounter: UIPageControl!
    
    var newPan: Bool = true
    var panIsSwipe: Bool = false
    var userPicArray: [[UIImage]] = []
    var curUser: Int = 0
    var curPic: Int = 0
    var totalRotation: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //these would actually be vars when loaded in dynamically
        //once we get more of the communication, I would make loading these more dynamic
        let tmpPicArray: [UIImage] = [UIImage(named: "sexy1")!,UIImage(named: "sexy2")!,UIImage(named: "sexy3")!]
        let tmpPicArray2: [UIImage] = [UIImage(named: "sexy2_1")!,UIImage(named: "sexy2_2")!,UIImage(named: "sexy2_3")!]
        let tmpPicArray3: [UIImage] = [UIImage(named: "sexy_latina1")!,UIImage(named: "sexy_latina2")!,UIImage(named: "sexy_latina3")!]
        userPicArray.append(tmpPicArray)
        userPicArray.append(tmpPicArray2)
        userPicArray.append(tmpPicArray3)
        userPic.image = userPicArray[curUser][curPic]
        PicCounter.currentPageIndicatorTintColor = UIColor.red
        PicCounter.pageIndicatorTintColor = UIColor.white
        
        UIView.animate(withDuration: 3, animations: {
            self.PrevPicView.alpha = 0.0
            self.nextPicView.alpha = 0.0
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.PrevPicLbl.text = ""
            self.nextPicLbl.text = ""
            self.PrevPicView.backgroundColor = UIColor.clear
            self.nextPicView.backgroundColor = UIColor.clear
            self.PrevPicView.alpha = 0.1
            self.nextPicView.alpha = 0.1
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func TapUp(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.05, animations: { self.card.alpha = 0.0 })
        curPic -= 1
        if curPic < 0 {
            curPic = userPicArray[curUser].count - 1
        }
        PicCounter.currentPage = curPic
        userPic.image = userPicArray[curUser][curPic]
        self.card.center = self.view.center
        UIView.animate(withDuration: 0.05, animations: { self.card.alpha = 1.0 })
    }
    
    @IBAction func TapDown(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.05, animations: { self.card.alpha = 0.0 })
        curPic += 1
        if curPic >= userPicArray[curUser].count {
            curPic = 0
        }
        PicCounter.currentPage = curPic
        userPic.image = userPicArray[curUser][curPic]
        self.card.center = self.view.center
        UIView.animate(withDuration: 0.05, animations: { self.card.alpha = 1.0 })
    }
    

    //at some point, we will want to do this in a prettier manner
    //this is a functional placeholder
    //TODO: take velocity into account so it counts a swipe for a flick even though they haven't moved far enough
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: view)
        //this toggles an initial swipe between changing picture and user
        if newPan {
            newPan = false
            if abs(Int(point.x)) > abs(Int(point.y)) {
                panIsSwipe = true
            } else {
                panIsSwipe = false
            }
        }
        //handle the card movement
        if panIsSwipe {
            //show or hide the star and x
            if abs(point.x) > 20 {
                if point.x > 0 {
                    imgYes.alpha = point.x / view.center.x
                    imgNo.alpha = 0
                } else {
                    imgNo.alpha = abs(point.x) / view.center.x
                    imgYes.alpha = 0
                }
            }
            let nextRotation = point.x / view.center.x / 180.0 * CGFloat.pi * 20.0 //20.0 is an arbitrary scaling factor
            let rotation = card.transform.rotated(by: nextRotation - totalRotation);
            totalRotation = nextRotation
            card.transform = rotation
            card.center = CGPoint(x: view.center.x + point.x, y: view.center.y )
        } else {
            card.center = CGPoint(x: view.center.x, y: view.center.y + point.y)
        }
        //when they release, it will either change pictures, users, or bring the card back
        if sender.state == UIGestureRecognizerState.ended {
            newPan = true
            if panIsSwipe {
                if abs(card.center.x - view.center.x)/view.center.x > 0.4 {
                    if card.center.x > view.center.x {
                        let offScreenPoint = CGPoint(x: UIScreen.main.bounds.width + card.bounds.width / 2.0, y: card.center.y)
                        UIView.animate(withDuration: 0.5, animations: { self.card.center = offScreenPoint })
                    } else {
                        let offScreenPoint = CGPoint(x: 0 - card.bounds.width / 2.0, y: card.center.y)
                        UIView.animate(withDuration: 0.5, animations: { self.card.center = offScreenPoint })
                    }
                    UIView.animate(withDuration: 0.5, animations: { self.card.alpha = 0.0 })
                    curUser += 1
                    curPic = 0
                    if curUser >= userPicArray.count {
                        curUser = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        let rotation = self.card.transform.rotated(by: -1.0 * self.totalRotation);
                        self.totalRotation = 0.0
                        self.card.transform = rotation
                        self.imgYes.alpha = 0
                        self.imgNo.alpha = 0
                        self.userPic.image = self.userPicArray[self.curUser][self.curPic]
                        self.card.center = self.view.center
                        UIView.animate(withDuration: 0.1, animations: { self.card.alpha = 1.0 })
                        self.PicCounter.currentPage = self.curPic
                    })
                } else {
                    //return the card to the center
                    imgYes.alpha = 0
                    imgNo.alpha = 0
                    let rotation = card.transform.rotated(by: -1.0 * totalRotation);
                    totalRotation = 0.0
                    UIView.animate(withDuration: 0.5, animations: { self.card.transform = rotation })
                    UIView.animate(withDuration: 0.5, animations: { self.card.center = self.view.center })
                }
                
            } else {
                if abs(card.center.y - view.center.y)/view.center.y > 0.4 {
                    if card.center.y > view.center.y {
                        let offScreenPoint = CGPoint(x: card.center.x, y: UIScreen.main.bounds.height + card.bounds.height / 2.0)
                        UIView.animate(withDuration: 0.5, animations: { self.card.center = offScreenPoint })
                        curPic += 1
                        if curPic >= userPicArray[curUser].count {
                            curPic = 0
                        }
                    } else {
                        let offScreenPoint = CGPoint(x: card.center.x , y: 0 - card.bounds.height / 2.0)
                        UIView.animate(withDuration: 0.5, animations: { self.card.center = offScreenPoint })
                        curPic -= 1
                        if curPic < 0 {
                            curPic = userPicArray[curUser].count - 1
                        }
                    }
                    UIView.animate(withDuration: 0.5, animations: { self.card.alpha = 0.0 })
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        let rotation = self.card.transform.rotated(by: -1.0 * self.totalRotation);
                        self.totalRotation = 0.0
                        self.card.transform = rotation
                        self.imgYes.alpha = 0
                        self.imgNo.alpha = 0
                        self.userPic.image = self.userPicArray[self.curUser][self.curPic]
                        self.card.center = self.view.center
                        UIView.animate(withDuration: 0.1, animations: { self.card.alpha = 1.0 })
                    })
                } else {
                    //return the card to the center
                    imgYes.alpha = 0
                    imgNo.alpha = 0
                    UIView.animate(withDuration: 0.5, animations: { self.card.center = self.view.center })
                }

            }
        }
    }

}


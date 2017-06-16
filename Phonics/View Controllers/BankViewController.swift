//
//  BankViewController.swift
//  Rhyme a Zoo
//
//  Created by Cal
//  Copyright (c) 2015 Hear a Tale. All rights reserved.
//

import UIKit
import Foundation


class BankViewController : UIViewController {
    
    
    //MARK: Presentation
    
    static func present(from source: UIViewController, goldCount: Int, silverCount: Int, onDismiss: @escaping () -> ()) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "bank") as! BankViewController
        controller.modalPresentationStyle = .overCurrentContext
        controller.totalGoldCount = goldCount
        controller.totalSilverCount = silverCount
        controller.onDismiss = onDismiss
        source.present(controller, animated: true, completion: nil)
    }
    
    
    //MARK: - Setup
    
    var totalGoldCount = 0
    var totalSilverCount = 0
    var onDismiss: (() -> ())?
    
    @IBOutlet weak var noCoins: UIButton!
    @IBOutlet weak var coinCount: UILabel!
    @IBOutlet weak var coinView: UIView!
    @IBOutlet weak var coinPile: UIImageView!
    @IBOutlet var coinImages: [UIImageView]!
    @IBOutlet weak var availableCoinsArea: UIView!
    @IBOutlet weak var availableCoinsView: UIView!
    @IBOutlet weak var coinAreaOffset: NSLayoutConstraint!
    @IBOutlet weak var coinAreaHeight: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.layoutIfNeeded()
        sortOutletCollectionByTag(&coinImages)
        
        let availableBalance = Double(totalGoldCount) + (Double(totalSilverCount) * 0.5)
        
        if availableBalance == 0 {
            noCoins.isHidden = false
            availableCoinsArea.isHidden = true
        } else {
            noCoins.isHidden = true
            availableCoinsArea.isHidden = false
        }
        
        if availableBalance > 60 {
            coinPile.isHidden = false
            coinPile.alpha = 1.0
            availableCoinsArea.isHidden = true
        }
        
        coinCount.isHidden = true
        decorateCoins()
    }
    
    func decorateCoins() {
        //clear coins
        for i in 0...9 {
            coinImages[i].image = nil
        }
        
        let gold = totalGoldCount + Int(Double(totalSilverCount) * 0.5)
        let silver = (totalSilverCount.isOdd) ? 1 : 0
        
        //calculate coins
        var coin20 = max(0, Int(gold / 20))
        let coin5 = max(0, (gold - (coin20 * 20)) / 5)
        let coinGold = max(0, gold - (coin20 * 20) - (coin5 * 5))
        let coinSilver = silver
        
        if coin20 > 7 {
            //too many to display
            availableCoinsView.isHidden = true
            coinPile.isHidden = false
        }
        else {
            availableCoinsView.isHidden = false
            coinPile.isHidden = true
        }
        
        //display coins
        func setImage(_ current: inout Int, _ type: String) {
            if current > 9 { return }
            coinImages[current].image = UIImage(named: type)
            current += 1
        }
        
        var current = 0
        for _ in 0 ..< coin20 {
            setImage(&current, "coin-20")
        }
        for _ in 0 ..< coin5 {
            setImage(&current, "coin-5")
        }
        for _ in 0 ..< coinGold {
            setImage(&current, "coin-gold-big")
        }
        for _ in 0 ..< coinSilver {
            setImage(&current, "coin-silver-big")
        }
        
    }
    
    /*
    func playAnimation() {
        self.repeatAnimationButton.enabled = false
        
        UAPlayer().play("coins-available", ofType: "mp3", ifConcurrent: .Interrupt)
        let duration = UALengthOfFile("coins-total", ofType: "mp3")
        
        //TODO: FIX
        //if !hasSpentCoins { return }
        
        let (totalGold, totalSilver) = RZQuizDatabase.getTotalMoneyEarned()
        let totalEarned = totalGold + totalSilver
        let animationLoops = (totalEarned / 100) + 1
        
        for i in 1...animationLoops {
            let loop: Double = Double(i) - 1
            //play raining coins animation
            coinTimers.append(NSTimer.scheduledTimerWithTimeInterval(duration + (loop * 4.5), target: self, selector: "playAnimationPart:", userInfo: 1, repeats: false))
            
            if i == 1 { //only play the audio on the first loop
                coinTimers.append(NSTimer.scheduledTimerWithTimeInterval(duration + 0.5 + (loop * 4.5), target: self, selector: "playAnimationPart:", userInfo: 2, repeats: false))
            }
            
            //only fade the background on the last loop
            if i == animationLoops {
                coinTimers.append(NSTimer.scheduledTimerWithTimeInterval(duration + 4.5 + (loop * 4.5), target: self, selector: "playAnimationPart:", userInfo: 3, repeats: false))
            }
        }
    }
    
    func playAnimationPart(timer: NSTimer) {
        if let part = timer.userInfo as? Int {
            
            if part == 1 {
                UIView.animateWithDuration(1.0) {
                    self.coinView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
                    self.availableCoinsArea.alpha = 0.3
                    self.coinCount.alpha = 1.0
                }
                self.spawnCoins()
                
            }
                
            else if part == 2 {
                UAPlayer().play("coins-total", ofType: "mp3", ifConcurrent: .Interrupt)
            }
                
            else if part == 3 {
                self.repeatAnimationButton.enabled = true
                UIView.animateWithDuration(0.5) {
                    self.coinView.backgroundColor = UIColor.clearColor()
                    self.availableCoinsArea.alpha = 1.0
                }
                UIView.animateWithDuration(1.0, delay: 2.5, options: nil, animations: {
                    self.coinCount.alpha = 0.0
                }, completion: nil)
            }
        }
    }
    
    func spawnCoins() {
        var (totalGold, totalSilver) = RZQuizDatabase.getTotalMoneyEarned()
        totalGold = min(100, totalGold)
        totalSilver = min(100, totalSilver)
        
        dispatch_async(RZAsyncQueue) {
            for _ in 0 ..< min(300, totalGold) {
                var wait = NSTimeInterval(arc4random_uniform(100)) / 100.0
                
                sync() {
                    let timer = NSTimer.scheduledTimerWithTimeInterval(wait, target: self, selector: "spawnCoinOfType:", userInfo: CoinType.Gold.getImage(), repeats: false)
                    self.coinTimers.append(timer)
                }
                
            }
            for _ in 0 ..< min(300, totalSilver) {
                var wait = Double(arc4random_uniform(100)) / 50.0
                
                sync() {
                    let timer = NSTimer.scheduledTimerWithTimeInterval(wait, target: self, selector: "spawnCoinOfType:", userInfo: CoinType.Silver.getImage(), repeats: false)
                    self.coinTimers.append(timer)
                }
                
            }
        }
        
    }
    
    func spawnCoinOfType(timer: NSTimer) {
        if let image = timer.userInfo as? UIImage {
            if coinView.subviews.count > 500 {
                return
            }
            let startX = CGFloat(arc4random_uniform(UInt32(self.view.frame.width)))
            
            let coin = UIImageView(frame: CGRectMake(startX - 15.0, -30.0, 30.0, 30.0))
            if iPad() {
                coin.frame = CGRectMake(startX - 25.0, -50.0, 50.0, 50.0)
            }
            coin.image = image
            self.coinView.addSubview(coin)
            
            let endPosition = CGPointMake(startX - 25.0, self.view.frame.height + 50)
            let duration = 2.0 + (Double(Int(arc4random_uniform(1000))) / 250.0)
            UIView.animateWithDuration(duration, animations: {
                coin.frame.origin = endPosition
            }, completion: { success in
                coin.removeFromSuperview()
            })
        }
        
    }
    
    func endTimers() {
        for timer in coinTimers {
            timer.invalidate()
        }
        coinTimers = []
    }*/
    
    /*
    func updateReadout() {
        let text = initialCoinString.mutableCopy() as! NSMutableAttributedString
        let current = text.string
        var splits = split(current){ $0 == " " }.map { String($0) }
        
        let balance = RZQuizDatabase.getPlayerBalance()
        if totalSilver == 0 {
            text.replaceCharactersInRange(NSMakeRange(count(splits[0]), count(splits[2]) + 3), withString: "")
        } else {
            text.replaceCharactersInRange(NSMakeRange(count(splits[0]) + 3, count(splits[2])), withString: "\(totalSilver)")
        }
        text.replaceCharactersInRange(NSMakeRange(0, count(splits[0])), withString: "\(totalGold)")
        coinCount.attributedText = text
    }*/
    
    @IBAction func back(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        self.onDismiss?()
    }
    
}

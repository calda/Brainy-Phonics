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
    
    static func present(from source: UIViewController, goldCount: Int, silverCount: Int, playCelebration: Bool, onDismiss: @escaping () -> ()) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "bank") as! BankViewController
        controller.modalPresentationStyle = .overCurrentContext
        controller.playCelebration = playCelebration
        controller.totalGoldCount = goldCount
        controller.totalSilverCount = silverCount
        controller.onDismiss = onDismiss
        source.present(controller, animated: true, completion: nil)
    }
    
    
    //MARK: - Setup
    
    var totalGoldCount = 0
    var totalSilverCount = 0
    var playCelebration = false
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
    
    var coinTimers = [Timer]()
    
    
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
        
        decorateCoins()
        
        coinCount.isHidden = true //updateReadout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if playCelebration {
            self.spawnCoins()
            PHPlayer.play("sight words celebration", ofType: "mp3")
        }
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
    
    func updateReadout() {
        let text = self.coinCount.attributedText!.mutableCopy() as! NSMutableAttributedString
        let current = text.string
        var splits = current.components(separatedBy: " ")
        
        if totalSilverCount == 0 {
            text.replaceCharacters(in: NSMakeRange(splits[0].length, splits[2].length + 3), with: "")
        } else {
            text.replaceCharacters(in: NSMakeRange(splits[0].length + 3, splits[2].length), with: "\(totalSilverCount)")
        }
        
        text.replaceCharacters(in: NSMakeRange(0, splits[0].length), with: "\(totalGoldCount)")
        coinCount.attributedText = text
    }
    
    func spawnCoins() {
        let totalGold = min(100, totalGoldCount)
        let totalSilver = min(100, totalGoldCount)
        
        DispatchQueue.main.async {
            for _ in 0 ..< min(300, totalGold) {
                let wait = TimeInterval(arc4random_uniform(100)) / 100.0
                
                let timer = Timer.scheduledTimer(timeInterval: wait, target: self, selector: #selector(self.spawnCoinFromTimer), userInfo: #imageLiteral(resourceName: "coin-gold"), repeats: false)
                self.coinTimers.append(timer)
                
            }
            for _ in 0 ..< min(300, totalSilver) {
                let wait = Double(arc4random_uniform(100)) / 50.0
                
                let timer = Timer.scheduledTimer(timeInterval: wait, target: self, selector: #selector(self.spawnCoinFromTimer), userInfo: #imageLiteral(resourceName: "coin-silver"), repeats: false)
                self.coinTimers.append(timer)
            }
        }
        
    }
    
    func spawnCoinFromTimer(_ timer: Timer) {
        if let image = timer.userInfo as? UIImage {
            spawnCoin(with: image)
        }
    }
    
    func spawnCoin(with image: UIImage) {
        let startX = CGFloat(arc4random_uniform(UInt32(self.view.frame.width)))
        
        let coin = UIImageView(frame: CGRect(x: startX - 15.0, y: -30, width: 30, height: 30))
        if iPad() {
            coin.frame = CGRect(x: startX - 25.0, y: -50, width: 50, height: 50)
        }
        coin.image = image
        self.coinView.addSubview(coin)
        
        let endPosition = CGPoint(x: startX - 25.0, y: self.view.frame.height + 50)
        let duration = 2.0 + (Double(Int(arc4random_uniform(1000))) / 250.0)
        UIView.animate(withDuration: duration, animations: {
            coin.frame.origin = endPosition
        }, completion: { success in
            coin.removeFromSuperview()
            self.spawnCoin(with: image)
        })
    }
    
    func endTimers() {
        UAHaltPlayback()
        coinView.layer.removeAllAnimations()
        
        for timer in coinTimers {
            timer.invalidate()
        }
        
        coinTimers = []
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        self.onDismiss?()
        self.endTimers()
    }
    
}

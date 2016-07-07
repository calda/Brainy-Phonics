//  CoreSwift.swift
//
//  A collection of core Swift functions and classes
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import UIKit.UIGestureRecognizerSubclass

//MARK: - Functions

///perform the closure function after a given delay
func delay(delay: Double, closure: ()->()) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    dispatch_after(time, dispatch_get_main_queue(), closure)
}

///play a CATransition for a UIView
func playTransitionForView(view: UIView, duration: Double, transition transitionName: String, subtype: String? = nil, timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)) {
    let transition = CATransition()
    transition.duration = duration
    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    transition.type = transitionName
    
    //run fix for transition subtype
    //subtypes don't take device orientation into account
    //let orientation = UIApplication.sharedApplication().statusBarOrientation
    //if orientation == .LandscapeLeft || orientation == .PortraitUpsideDown {
    //if subtype == kCATransitionFromLeft { subtype = kCATransitionFromRight }
    //else if subtype == kCATransitionFromRight { subtype = kCATransitionFromLeft }
    //else if subtype == kCATransitionFromTop { subtype = kCATransitionFromBottom }
    //else if subtype == kCATransitionFromBottom { subtype = kCATransitionFromTop }
    //}
    
    transition.subtype = subtype
    transition.timingFunction = timingFunction
    view.layer.addAnimation(transition, forKey: nil)
}

///dimiss a stack of View Controllers until a desired controler is found
func dismissController(controller: UIViewController, untilMatch controllerCheck: (UIViewController) -> Bool) {
    if controllerCheck(controller) {
        return //we made it to our destination
    }
    
    let superController = controller.presentingViewController
    controller.dismissViewControllerAnimated(false, completion: {
        if let superController = superController {
            dismissController(superController, untilMatch: controllerCheck)
        }
    })
}

///get the top most view controller of the current Application
func getTopController(application: UIApplicationDelegate) -> UIViewController? {
    //find the top controller
    var topController: UIViewController?
    
    if let window = application.window, let root = window!.rootViewController {
        topController = root
        while topController!.presentedViewController != nil {
            topController = topController!.presentedViewController
        }
    }
    
    return topController
}

///sorts any [UIView]! by view.tag
func sortOutletCollectionByTag<T : UIView>(inout collection: [T]!) {
    collection = (collection as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key: "tag", ascending: true)]) as! [T]
}

///animates a back and forth shake
func shakeView(view: UIView) {
    let animations : [CGFloat] = [20.0, -20.0, 10.0, -10.0, 3.0, -3.0, 0]
    for i in 0 ..< animations.count {
        let frameOrigin = CGPointMake(view.frame.origin.x + animations[i], view.frame.origin.y)
        
        UIView.animateWithDuration(0.1, delay: NSTimeInterval(0.1 * Double(i)), options: [.BeginFromCurrentState], animations: {
            view.frame.origin = frameOrigin
            }, completion: nil)
    }
}

///animates a back and forth rotation
func pivotView(view: UIView, multiplier: CGFloat) {
    let animations : [CGFloat] = [20.0, -20.0, 10.0, -10.0, 3.0, -3.0, 0]
    for i in 0 ..< animations.count {
        let transform = CGAffineTransformMakeRotation(animations[i] * (CGFloat(M_PI) / 180.0) * 1.2 * multiplier)
        
        UIView.animateWithDuration(0.1, delay: NSTimeInterval(0.1 * Double(i)), options: [], animations: {
            view.transform = transform
            }, completion: nil)
    }
}

func pivotView(view: UIView) {
    pivotView(view, multiplier: 1.0)
}

///short-form function to run a block synchronously on the main queue
func sync(closure: () -> ()) {
    dispatch_sync(dispatch_get_main_queue(), closure)
}

///short-form function to run a block asynchronously on the main queue
func async(closure: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), closure)
}


///open to this app's iOS Settings
func openSettings() {
    UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
}


///returns trus if the current device is an iPad
func iPad() -> Bool {
    return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
}

///returns trus if the current device is an iPhone 4S
func is4S() -> Bool {
    return UIScreen.mainScreen().bounds.height == 480.0
}


///a more succinct function call to post a notification
func postNotification(name: String, object: AnyObject?) {
    NSNotificationCenter.defaultCenter().postNotificationName(name, object: object, userInfo: nil)
}

///Determines the height required to display the text in the given label
func heightForText(text: String, width: CGFloat, font: UIFont) -> CGFloat {
    let context = NSStringDrawingContext()
    let size = CGSizeMake(width, CGFloat.max)
    let rect = text.boundingRectWithSize(size, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: context)
    return rect.height
}

//MARK: - Classes

///A touch gesture recognizer that sends events on both .Began (down) and .Ended (up)
class UITouchGestureRecognizer : UITapGestureRecognizer {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        self.state = .Began
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        self.state = .Changed
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        self.state = .Ended
    }
    
}

///This class fixes the weird bug where iPad Table View Cells always default to a white background
class TransparentTableView : UITableView {
    
    override func dequeueReusableCellWithIdentifier(identifier: String) -> UITableViewCell? {
        let cell = super.dequeueReusableCellWithIdentifier(identifier)
        cell?.backgroundColor = cell?.backgroundColor
        return cell
    }
    
}


///helper class to reduce boilerplate of loading from Nib
class UINibView : UIView {
    
    var nibView: UIView!
    
    func nibName() -> String {
        print("UINibView.nibName() should be overridden by subclass")
        return ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNib()
    }
    
    func setupNib() {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName(), bundle: bundle)
        nibView = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        nibView.autoresizesSubviews = true
        nibView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        nibView.frame = bounds
        nibView.layer.masksToBounds = true
        
        self.addSubview(nibView)
        
    }
    
}

//MARK: - Standard Library Extensions

extension Array {
    ///Returns a copy of the array in random order
    func shuffled() -> [Element] {
        var list = self
        for i in 0..<(list.count - 1) {
            let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
            if (i == j) { continue }
            swap(&list[i], &list[j])
        }
        return list
    }
    
    ///Returns a random element from the array
    func random() -> Element? {
        return self.shuffled().first
    }
}

extension Int {
    ///Converts an integer to a standardized three-character string. 1 -> 001. 99 -> 099. 123 -> 123.
    func threeCharacterString() -> String {
        let start = "\(self)"
        let length = start.characters.count
        if length == 1 { return "00\(start)" }
        else if length == 2 { return "0\(start)" }
        else { return start }
    }
    
    func timeFormatted() -> String {
        let seconds: Int = self % 60
        let minutes: Int = (self / 60) % 60
        let hours: Int = self / 3600
        if hours == 0 { return String(format: "%d:%02d", minutes, seconds) }
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
}

extension NSObject {
    ///Short-hand function to register a notification observer
    func observeNotification(name: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: name, object: nil)
    }
}

extension NSDate {
    ///converts to a "10 seconds ago" / "1 day ago" syntax
    func agoString() -> String {
        let deltaTime = -self.timeIntervalSinceNow
        
        //in the past
        if deltaTime > 0 {
            if deltaTime < 60 {
                return "just now"
            }
            if deltaTime < 3600 { //less than an hour
                let amount = Int(deltaTime/60.0)
                let plural = amount == 1 ? "" : "s"
                return "\(amount) minute\(plural) ago"
            }
            else if deltaTime < 86400 { //less than a day
                let amount = Int(deltaTime/3600.0)
                let plural = amount == 1 ? "" : "s"
                return "\(amount) hour\(plural) ago"
            }
            else if deltaTime < 432000 { //less than five days
                let amount = Int(deltaTime/86400.0)
                let plural = amount == 1 ? "" : "s"
                if amount == 1 {
                    return "Yesterday"
                }
                return "\(amount) day\(plural) ago"
            }
        }
        
        //in the future
        if deltaTime < 0 {
            if deltaTime > -60 {
                return "just now"
            }
            if deltaTime > -3600 { //in less than an hour
                let amount = -Int(deltaTime/60.0)
                let plural = amount == 1 ? "" : "s"
                return "in \(amount) minute\(plural)"
            }
            else if deltaTime > -86400 { //in less than a day
                let amount = -Int(deltaTime/3600.0)
                let plural = amount == 1 ? "" : "s"
                return "in \(amount) hour\(plural)"
            }
            else if deltaTime > -432000 { //in less than five days
                let amount = -Int(deltaTime/86400.0)
                let plural = amount == 1 ? "" : "s"
                if amount == 1 {
                    return "Tomorrow"
                }
                return "in \(amount) day\(plural)"
            }
        }
        
        let dateString = NSDateFormatter.localizedStringFromDate(self, dateStyle: .MediumStyle, timeStyle: .NoStyle)
        return "on \(dateString)"
        
    }
    
}

extension UITableViewCell {
    //hides the line seperator of the cell
    func hideSeparator() {
        self.separatorInset = UIEdgeInsetsMake(0, self.frame.size.width * 2.0, 0, 0)
    }
    
    //re-enables the line seperator of the cell
    func showSeparator() {
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
}

extension UIView {
    
    static func animateWithDuration(duration: NSTimeInterval, delay: NSTimeInterval, usingSpringWithDamping damping: CGFloat, animations: () -> ()) {
        UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: 0.0, options: [], animations: animations, completion: nil)
    }
    
}

extension String {
    
    var length: Int {
        return (self as NSString).length
    }
    
    func asDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
    
    func percentStringAsDouble() -> Double? {
        if let displayedNumber = (self as NSString).substringToIndex(self.length - 1).asDouble() {
            return displayedNumber / 100.0
        }
        return nil
    }
    
    func isWhitespace() -> Bool {
        return self == " " || self == "\n" || self == "\r" || self == "\r\n" || self == "\t"
            || self == "\u{A0}" || self == "\u{2007}" || self == "\u{202F}" || self == "\u{2060}" || self == "\u{FEFF}"
        //there are lots of whitespace characters apparently
        //http://www.fileformat.info/info/unicode/char/00a0/index.htm
    }
    
    mutating func prepareForURL(isFullURL isFullURL: Bool = false) {
        self = self.preparedForURL(isFullURL: isFullURL)
    }
    
    func preparedForURL(isFullURL isFullURL: Bool = false) -> String {
        var specialCharacters = [
            "?" : "%3F",
            "&" : "%26",
            "%" : "%25",
            "=" : "%3D",
            " " : "%20"
        ]
        
        if isFullURL {
            //replacing % on full URLs would change %20 to %2520, breaking the link
            specialCharacters.removeValueForKey("%")
        }
        
        //if this isn't a full URL (ex: a post argument), then also strip out some special URL characters
        if !isFullURL {
            specialCharacters.updateValue("%2F", forKey: "/")
            specialCharacters.updateValue("%2E", forKey: ".")
            specialCharacters.updateValue("%3A", forKey: ":")
        }
        
        var currentString = self
        for (special, replace) in specialCharacters {
            currentString = currentString.stringByReplacingOccurrencesOfString(special, withString: replace)
        }
        return currentString
    }
    
}

///Add dedicated NSCoding methods to cut down on boilerplate everywhere else
extension NSUserDefaults {
    
    func setCodedObject(value: NSCoding, forKey key: String) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(value)
        setObject(data, forKey: key)
    }
    
    func codedObjectForKey(key: String) -> AnyObject? {
        if let data = objectForKey(key) as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data)
        }
        return nil
    }
    
}

extension NSString {
    
    func stringAtIndex(index: Int) -> String {
        let char = self.characterAtIndex(index)
        return "\(Character(UnicodeScalar(char)))"
    }
    
    func countOccurancesOfString(string: String) -> Int {
        let strCount = self.length - self.stringByReplacingOccurrencesOfString(string, withString: "").length
        return strCount / string.length
    }
    
}

extension NSBundle {
    
    static var applicationVersionNumber: String {
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Version Number Not Available"
    }
    
    static var applicationBuildNumber: String {
        if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return "Build Number Not Available"
    }
    
}

extension NSDateFormatter {
    
    convenience init(withFormat format: String) {
        self.init()
        self.dateFormat = format
    }
    
    static func stringFromDate(date: NSDate, withFormat format: String) -> String {
        let formatter = NSDateFormatter(withFormat: format)
        return formatter.stringFromDate(date)
    }
    
    
    static func dateFromString(string: String, withFormat format: String) -> NSDate? {
        let formatter = NSDateFormatter(withFormat: format)
        return formatter.dateFromString(string)
    }
    
}

extension NSTimer {
    
    class func scheduleAfter(delay: NSTimeInterval, inout addToArray array: [NSTimer], handler: () -> ()) -> NSTimer {
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, { _ in handler() })
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
        
        array.append(timer)
        
        return timer
    }
    
}
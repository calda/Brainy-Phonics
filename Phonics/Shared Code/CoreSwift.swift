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
func delay(_ delay: Double, closure: @escaping ()->()) {
    let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time, execute: closure)
}

///play a CATransition for a UIView
func playTransitionForView(_ view: UIView, duration: Double, transition transitionName: String, subtype: String? = nil, timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)) {
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
    view.layer.add(transition, forKey: nil)
}

///dimiss a stack of View Controllers until a desired controler is found
func dismissController(_ controller: UIViewController, untilMatch controllerCheck: @escaping (UIViewController) -> Bool) {
    if controllerCheck(controller) {
        return //we made it to our destination
    }
    
    let superController = controller.presentingViewController
    controller.dismiss(animated: false, completion: {
        if let superController = superController {
            dismissController(superController, untilMatch: controllerCheck)
        }
    })
}

///get the top most view controller of the current Application
func getTopController(_ application: UIApplicationDelegate) -> UIViewController? {
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
func sortOutletCollectionByTag<T : UIView>(_ collection: inout [T]!) {
    collection = (collection as NSArray).sortedArray(using: [NSSortDescriptor(key: "tag", ascending: true)]) as! [T]
}

///animates a back and forth shake
func shakeView(_ view: UIView) {
    let animations : [CGFloat] = [20.0, -20.0, 10.0, -10.0, 3.0, -3.0, 0]
    for i in 0 ..< animations.count {
        let frameOrigin = CGPoint(x: view.frame.origin.x + animations[i], y: view.frame.origin.y)
        
        UIView.animate(withDuration: 0.1, delay: TimeInterval(0.1 * Double(i)), options: [.beginFromCurrentState], animations: {
            view.frame.origin = frameOrigin
            }, completion: nil)
    }
}

///animates a back and forth rotation
func pivotView(_ view: UIView, multiplier: CGFloat) {
    let animations : [CGFloat] = [20.0, -20.0, 10.0, -10.0, 3.0, -3.0, 0]
    for i in 0 ..< animations.count {
        let transform = CGAffineTransform(rotationAngle: animations[i] * (CGFloat(M_PI) / 180.0) * 1.2 * multiplier)
        
        UIView.animate(withDuration: 0.1, delay: TimeInterval(0.1 * Double(i)), options: [], animations: {
            view.transform = transform
            }, completion: nil)
    }
}

func pivotView(_ view: UIView) {
    pivotView(view, multiplier: 1.0)
}

///short-form function to run a block synchronously on the main queue
func sync(_ closure: () -> ()) {
    DispatchQueue.main.sync(execute: closure)
}

///short-form function to run a block asynchronously on the main queue
func async(_ closure: @escaping () -> ()) {
    DispatchQueue.main.async(execute: closure)
}


///open to this app's iOS Settings
func openSettings() {
    UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
}


///returns trus if the current device is an iPad
func iPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
}

///returns trus if the current device is an iPhone 4S
func is4S() -> Bool {
    return UIScreen.main.bounds.height == 480.0
}


///a more succinct function call to post a notification
func postNotification(_ name: String, object: AnyObject?) {
    NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: object, userInfo: nil)
}

///Determines the height required to display the text in the given label
func heightForText(_ text: String, width: CGFloat, font: UIFont) -> CGFloat {
    let context = NSStringDrawingContext()
    let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
    let rect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: context)
    return rect.height
}

///Reads the lines for a text file out of the bundle
func linesForFile(_ fileName: String, ofType type: String, usingNewlineMarker newline: String = "\r\n") -> [String]? {
    guard let file = Bundle.main.path(forResource: fileName, ofType: type) else { return nil }
    
    do {
        let text = try NSString(contentsOfFile: file, encoding: String.Encoding.utf8.rawValue)
        return text.components(separatedBy: newline)
    } catch {
        return nil;
    }
}

///Reads the lines for a CSV out of the bundle
func linesForCSV(_ fileName: String, usingNewlineMarker newline: String = "\r\n") -> [[String]]? {
    guard let lines = linesForFile(fileName, ofType: "csv", usingNewlineMarker: newline) else { return nil }
    return lines.map{ line in
        
        // A,long,A,ape,tail,jay,"skate, suitcase, crayons”,”hello, hi”
        // [“A,long,A,ape,tail,jay,”, “skate, suitcase, crayons”, “,”, “hello, hi”, “”]
        // [“A,long,A,ape,tail,jay,”, “skate~|~ suitcase~|~ crayons”, “,”, “hello~|~ hi”]
        // A,long,A,ape,tail,jay,skate~|~ suitcase~|~ crayons,hello~|~ hi
        // ["A", "long", "A", "ape", "tail", "jay", "skate, suitcase, crayons", "hello, hi"]
        
        let separatedByQuotes = line.components(separatedBy: "\"")
        var reparsedLine = [String]()
        
        for (index, part) in separatedByQuotes.enumerated() {

            if line.hasSuffix("\"") && index == separatedByQuotes.count - 1 {
                continue
            }
            
            if index.isEven {
                reparsedLine.append(part)
            } else {
                let noCommaString = part.replacingOccurrences(of: ",", with: "~|~")
                reparsedLine.append(noCommaString)
            }
        }
        
        let rejoinedLine = reparsedLine.joined(separator: "")
        let separatedByCommas = rejoinedLine.components(separatedBy: ",")
        
        
        return separatedByCommas.map{ $0.replacingOccurrences(of: "~|~", with: ",") }
    }
}

//MARK: - Classes

///A touch gesture recognizer that sends events on both .Began (down) and .Ended (up)
class UITouchGestureRecognizer : UITapGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        self.state = .changed
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        self.state = .ended
    }
    
}

///This class fixes the weird bug where iPad Table View Cells always default to a white background
class TransparentTableView : UITableView {
    
    override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        let cell = super.dequeueReusableCell(withIdentifier: identifier)
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
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName(), bundle: bundle)
        nibView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        nibView.frame = bounds
        nibView.layer.masksToBounds = true
        
        self.addSubview(nibView)
        
        nibView.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutAttribute] = [.top, .left, .right, .bottom]
        for attribute in attributes {
            let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: self.nibView, attribute: attribute, multiplier: 1.0, constant: 0.0)
            self.addConstraint(constraint)
        }
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
    
    var isEven: Bool {
        return self % 2 == 0
    }
    
    var isOdd: Bool {
        return self.isEven
    }
}

extension NSObject {
    ///Short-hand function to register a notification observer
    func observeNotification(_ name: String, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
    }
}

extension Date {
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
        
        let dateString = DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .none)
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
    
    static func animateWithDuration(_ duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping damping: CGFloat, animations: @escaping () -> ()) {
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: 0.0, options: [], animations: animations, completion: nil)
    }
    
}

extension String {
    
    var length: Int {
        return (self as NSString).length
    }
    
    func asDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    func percentStringAsDouble() -> Double? {
        if let displayedNumber = (self as NSString).substring(to: self.length - 1).asDouble() {
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
    
    func trimmingWhitespace() -> String {
        var trimmedText = self
        
        while (trimmedText.hasPrefix(" ")) {
            trimmedText = trimmedText.substring(from: trimmedText.characters.index(after: trimmedText.startIndex))
        }
        
        while (trimmedText.hasSuffix(" ")) {
            trimmedText = trimmedText.substring(to: trimmedText.characters.index(after: trimmedText.endIndex))
        }
        
        return trimmedText
    }
    
    mutating func prepareForURL(isFullURL: Bool = false) {
        self = self.preparedForURL(isFullURL: isFullURL)
    }
    
    func preparedForURL(isFullURL: Bool = false) -> String {
        var specialCharacters = [
            "?" : "%3F",
            "&" : "%26",
            "%" : "%25",
            "=" : "%3D",
            " " : "%20",
            "'" : "%27"
        ]
        
        if isFullURL {
            //replacing % on full URLs would change %20 to %2520, breaking the link
            specialCharacters.removeValue(forKey: "%")
        }
        
        //if this isn't a full URL (ex: a post argument), then also strip out some special URL characters
        if !isFullURL {
            specialCharacters.updateValue("%2F", forKey: "/")
            specialCharacters.updateValue("%2E", forKey: ".")
            specialCharacters.updateValue("%3A", forKey: ":")
        }
        
        var currentString = self
        for (special, replace) in specialCharacters {
            currentString = currentString.replacingOccurrences(of: special, with: replace)
        }
        return currentString
    }
    
}

///Add dedicated NSCoding methods to cut down on boilerplate everywhere else
extension UserDefaults {
    
    func setCodedObject(_ value: NSCoding, forKey key: String) {
        let data = NSKeyedArchiver.archivedData(withRootObject: value)
        set(data, forKey: key)
    }
    
    func codedObjectForKey(_ key: String) -> AnyObject? {
        if let data = object(forKey: key) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as AnyObject?
        }
        return nil
    }
    
}

extension NSString {
    
    func stringAtIndex(_ index: Int) -> String {
        let char = self.character(at: index)
        return "\(Character(UnicodeScalar(char)!))"
    }
    
    func countOccurancesOfString(_ string: String) -> Int {
        let strCount = self.length - self.replacingOccurrences(of: string, with: "").length
        return strCount / string.length
    }
    
}

extension Bundle {
    
    static var applicationVersionNumber: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Version Number Not Available"
    }
    
    static var applicationBuildNumber: String {
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return "Build Number Not Available"
    }
    
}

extension DateFormatter {
    
    convenience init(withFormat format: String) {
        self.init()
        self.dateFormat = format
    }
    
    static func stringFromDate(_ date: Date, withFormat format: String) -> String {
        let formatter = DateFormatter(withFormat: format)
        return formatter.string(from: date)
    }
    
    
    static func dateFromString(_ string: String, withFormat format: String) -> Date? {
        let formatter = DateFormatter(withFormat: format)
        return formatter.date(from: string)
    }
    
}

extension Timer {
    
    @discardableResult class func scheduleAfter(_ delay: TimeInterval, addToArray array: inout [Timer], handler: @escaping () -> ()) -> Timer {
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, { _ in handler() })
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
        
        array.append(timer!)
        
        return timer!
    }
    
}

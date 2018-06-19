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
func pivotView(_ view: UIView, multiplier: CGFloat = 1.0) {
    let animations : [CGFloat] = [20.0, -20.0, 10.0, -10.0, 3.0, -3.0, 0]
    for i in 0 ..< animations.count {
        let transform = CGAffineTransform(rotationAngle: animations[i] * (.pi / 180.0) * 1.2 * multiplier)
        
        UIView.animate(withDuration: 0.1, delay: TimeInterval(0.1 * Double(i)), options: [], animations: {
            view.transform = transform
            }, completion: nil)
    }
}

extension UIView {
    
    func pulseToSize(size: CGFloat, growFor grow: TimeInterval, shrinkFor shrink: TimeInterval) {
        
        //animate
        UIView.animate(withDuration: grow, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations: {
            self.transform = CGAffineTransform(scaleX: size, y: size)
        }, completion: nil)
        
        UIView.animate(withDuration: shrink, delay: grow, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations: {
            self.transform = .identity
        }, completion: nil)
        
    }
    
    var safeAreaInsetsIfAvailable: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.safeAreaInsets
        } else {
            return .zero
        }
    }
    
    var frameInsetByMargins: CGRect {
        return UIEdgeInsetsInsetRect(self.frame, layoutMargins)
    }
    
}

///short-form function to run a block synchronously on the main queue
func sync(_ closure: () -> ()) {
    DispatchQueue.main.sync(execute: closure)
}

///short-form function to run a block asynchronously on the main queue
func async(_ closure: @escaping () -> ()) {
    DispatchQueue.main.async(execute: closure)
}


///returns trus if the current device is an iPad
func iPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
}

///returns trus if the current device is an iPhone 4S
func is4S() -> Bool {
    return UIScreen.main.bounds.height == 480.0
}

///Determines the height required to display the text in the given label
func heightForText(_ text: String, width: CGFloat, attributes: [NSAttributedStringKey : Any]?) -> CGFloat {
    let context = NSStringDrawingContext()
    let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
    
    let rect = text.boundingRect(
        with: size,
        options: [.usesLineFragmentOrigin, .usesFontLeading, .usesDeviceMetrics],
        attributes: attributes,
        context: context)
    
    return rect.height
}

///Reads the lines for a text file out of the bundle
func linesForFile(_ fileName: String, ofType type: String, usingNewlineMarker newline: String = "\r\n") -> [String]? {
    guard let file = Bundle.main.path(forResource: fileName, ofType: type) else { return nil }
    
    do {
        let text = try NSString(contentsOfFile: file, encoding: String.Encoding.utf8.rawValue)
        let lines = text.components(separatedBy: .newlines)
        let linesWithoutComments = lines.filter({ !$0.hasPrefix("//") })
        return linesWithoutComments
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
        if self.count <= 1 { return self }
        
        var list = self
        for i in 0..<(list.count - 1) {
            let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
            if (i == j) { continue }
            list.swapAt(i, j)
        }
        return list
    }
    
    ///Returns a random element from the array
    func random() -> Element? {
        return self.shuffled().first
    }
}

extension Int {
    
    var isEven: Bool {
        return self % 2 == 0
    }
    
    var isOdd: Bool {
        return self.isEven
    }
}

extension UIView {
    
    static func animate(withDuration duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping damping: CGFloat, animations: @escaping () -> ()) {
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: 0.0, options: [], animations: animations, completion: nil)
    }
    
}

extension UIImageView {
    
    func update(on queue: DispatchQueue, withImage loadImage: @escaping () -> (UIImage?), shouldIgnoreUpdateIf ignoreUpdate: @escaping () -> (Bool)) {
        self.alpha = 0.0
        self.image = nil
        
        queue.async {
            let image = loadImage()
            
            DispatchQueue.main.sync {
                self.image = image
                
                if image != nil && !ignoreUpdate() {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.alpha = 1.0
                    })
                }
            }
        }
    }
    
}

extension UIButton {
        
    func animateImage(to image: UIImage?, duration: CFTimeInterval) {
        guard let imageView = self.imageView, let currentImage = imageView.image, let newImage = image else { return }
        
        let crossFade: CABasicAnimation = CABasicAnimation(keyPath: "contents")
        crossFade.duration = duration
        crossFade.fromValue = currentImage.cgImage
        crossFade.toValue = newImage.cgImage
        crossFade.isRemovedOnCompletion = false
        
        crossFade.fillMode = kCAFillModeForwards
        imageView.layer.add(crossFade, forKey: "animateContents")
    }
    
}

extension String {
    
    var length: Int {
        return (self as NSString).length
    }
    
    func asDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    func isWhitespace() -> Bool {
        return self == " " || self == "\n" || self == "\r" || self == "\r\n" || self == "\t"
            || self == "\u{A0}" || self == "\u{2007}" || self == "\u{202F}" || self == "\u{2060}" || self == "\u{FEFF}"
        //there are lots of whitespace characters apparently
        //http://www.fileformat.info/info/unicode/char/00a0/index.htm
    }
    
    func trimmingWhitespace() -> String {
        return self.trimmingCharacters(in: .whitespaces)
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

extension UIImage {
    
    //pass in the path without extension of an image, and a reduced-size image may be returned.
    static func thumbnail(for imagePath: String, maxSize: CGFloat = 250) -> UIImage? {
        if let url = Bundle.phonicsBundle?.url(forResource: imagePath, withExtension: ""),
            let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) {
            
            let options: [NSString: Any] = [
                kCGImageSourceThumbnailMaxPixelSize: maxSize,
                kCGImageSourceCreateThumbnailFromImageAlways: true
            ]
            
            if let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) {
                return UIImage(cgImage: thumbnail)
            }
        }
        
        return nil
    }
    
}

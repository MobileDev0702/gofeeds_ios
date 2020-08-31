//
//  Extensions.swift
//  POS-Native
//

import Foundation
import UIKit
//import IBAnimatable
import CommonCrypto
//import SwiftKeychainWrapper

public enum DateFormatType : String
{
    case date = "yyyy-MM-dd"
    case dateTimeSec = "yyyy-MM-dd HH:mm:ss"
    case dateTimeSecT = "yyyy-MM-dd'T'HH:mm:ss"
    case dateTimeSecAm = "yyyy-MM-dd HH:mm:ss a"
    case dateTime = "yyyy-MM-dd HH:mm"
    case timeAm = "HH:mm a"
    case time = "HH:mm"
    case month = "LLL"
    case weekDay = "EE"
    case day = "dd"
    case dayMonth = "dd MMM"
    case monthNumber = "MM"
    case hour = "HH"
    case dateSlash = "dd/MM/yyyy"
    case dateMonthYear = "dd-MM-yyyy HH:mm:ss"
}

extension Dictionary
{
    func queryString() -> String
    {
        var output: String = ""
        for (key,value) in self
        {
            output +=  "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        return output
    }
}

extension UIView
{
    //Shadow with dynamic values
    func addShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true)
    {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func shadow(_ cornerRadius: Float, _ color: UIColor, _ size: CGSize, _ opacity: Float)
    {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = size
        self.layer.shadowOpacity = opacity
        self.backgroundColor = UIColor.white
    }
    
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true)
    {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension UIImage
{
    //Reduce image size
    func resizeImage(targetSize: CGSize) -> UIImage
    {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func maskWithColor(color: UIColor) -> UIImage?
    {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage()
        {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        }
        else
        {
            return nil
        }
    }
    
    func saveToDD(_ imageName: String, _ compressionQuality: CGFloat = 0.01)
    {
        let ddPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = ddPath.appendingPathComponent((imageName + ".jpg"))

        if let data = self.jpegData(compressionQuality: compressionQuality)
        {
            do
            {
                // writes the image data to disk
                try data.write(to: fileURL)
            }
            catch
            {
                print("error saving file:", error)
            }
        }
    }
    
    class func bannerLogo() -> UIImage
    {
        #if CSSPOS || CSSLOCAL || CSSDEMO || CSSSTAGING || CSSLOCALTEST || CSSTEST
        return #imageLiteral(resourceName: "banner_logo_css")
         #elseif PRIO || PRIOLOCAL || PRIOTEST || PRIOSTAGING || PRIODEMO || PRIOLOCALTEST
        return #imageLiteral(resourceName: "banner_logo_prio")
        #elseif EVANEVANS || EVANEVANSLOCAL || EVANEVANSTEST || EVANEVANSDEMO
        return #imageLiteral(resourceName: "banner_logo_evanevans")
        #else
        return #imageLiteral(resourceName: "banner_logo_priohub")
        #endif
    }
    
    class func defaultLogo() -> UIImage
    {
        #if CSSPOS || CSSLOCAL || CSSDEMO || CSSSTAGING || CSSLOCALTEST || CSSTEST
        return #imageLiteral(resourceName: "logo_default_css")
        #elseif PRIO || PRIOLOCAL || PRIOTEST || PRIOSTAGING || PRIODEMO || PRIOLOCALTEST
        return #imageLiteral(resourceName: "logo_default_prio")
        #elseif EVANEVANS || EVANEVANSLOCAL || EVANEVANSTEST || EVANEVANSSTAGING || EVANEVANSDEMO || EVANEVANSLOCALTEST
        return #imageLiteral(resourceName: "logo_default_evanevans")
        #else
        return #imageLiteral(resourceName: "logo_default_priohub")
        #endif
    }
}

extension Data
{
    var hexString: String
    {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
    
    //Test the when we have data in file, and yet waiting for API call
    static func dataFromFile(_ fileName: String)-> Data?
    {
        if let filePath = Bundle.main.path(forResource: fileName, ofType: "txt")
        {
            let fileURL = URL.init(fileURLWithPath: filePath)
            if let fileData = try? Data.init(contentsOf:fileURL)
            {
                print("Data == \(String.init(data: fileData, encoding: .utf8) ?? "") From File == \(fileName)")
                return fileData
            }
            else
            {
                print("Either File not Exsits or Data no found")
                return nil
            }
        }
        else
        {
            print("Invalid file Name")
            return nil
        }
    }
}

extension String
{
    /**
     Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
     
     - Parameter length: A `String`.
     - Parameter trailing: A `String` that will be appended after the truncation.
     
     - Returns: A `String` object.
     */
    func truncate(length: Int, trailing: String = "‚Ä¶") -> String
    {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        }
        else
        {
            return self
        }
    }
    
    func insertCharacter(_ char: String, _ atIndex: Int) -> String
    {
        let strFormater: NSMutableString = NSMutableString.init(string: self)
        strFormater.insert(char, at: atIndex)
        return strFormater.string()
    }
    
    func blankAttributedStr() -> NSMutableAttributedString
    {
        return NSMutableAttributedString.init(string: self, attributes: [NSAttributedString.Key.foregroundColor: UIColor.clear])
    }
    
    //Trim blank-space from the string
    func trim(_ str: String = "") -> String
    {
        if str == ""
        {
            return self.trimmingCharacters(in : NSCharacterSet.whitespacesAndNewlines)
        }
        else
        {
            var trimmedStr = self.trimmingCharacters(in : NSCharacterSet.whitespacesAndNewlines)
            trimmedStr = trimmedStr.trimmingCharacters(in: CharacterSet.init(charactersIn: str))
            
            return trimmedStr
        }
    }
    
    //Base64 Encoding
    func base64Str() -> String
    {
        if let data = self.data(using: .utf8)
        {
            return data.base64EncodedString()
        }
        else
        {
            return self
        }
    }
    
    var localize: String
    {
        return Bundle.myBundle?.localizedString(forKey: self, value: "", table: nil) ?? "Word Not found"
        //return NSLocalizedString(self, comment: "")
    }
    
    func date(_ formatType: DateFormatType = .date) -> Date
    {
        return self.count >= 10 ? (DateFormatter.formatter(formatType).date(from: self)  != nil ?DateFormatter.formatter(formatType).date(from: self) : Date.today())! : Date.today()
    }
    
    //convert hour to GMT Date
    func hourGMTDate() -> Date
    {
        let hourGMT = DateFormatter.formatter(.hour, TimeZone(abbreviation: "GMT")).date(from: self)
        
        return hourGMT!
    }
    
    //Getting Local Date from Server's Time By Adding TimeZone Interval
    //ordeDateLocal() func was not providing required output, so created a new func 'gmtToLocal()' to convert GMT time to local time
    func ordeDateLocal(_ format: DateFormatType = .dateTimeSec) -> Date
    {
        if let orderDateGMT = DateFormatter.formatter(format, TimeZone.current).date(from: self)
        {
            return orderDateGMT.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
        }
        
        let orderDateGMT = DateFormatter.formatter(.dateTimeSecAm, TimeZone.current).date(from: self)
        return orderDateGMT!.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
    }
    
    //Random string generator
    static func randString(_ val1: Int, _ val2: Int) -> String
    {
        return String(Int.random(in: val1...val2))
        //        let randString = (val1 + arc4random() % val2)
        //        return String(randString)
    }
    
    //To get Device UUID
//    static func deviceUUID() -> String
//    {
//        if let deviceID = KeychainWrapper.standard.string(forKey: "deviceID")
//        {
//            return deviceID
//        }
//        else
//        {
//            var deviceID = UIDevice.current.identifierForVendor?.uuidString ?? (PassGenerator.shared.passes(1)[0])
//            deviceID = deviceID.replacingOccurrences(of: "-", with: "")
//
//            KeychainWrapper.standard.set(deviceID, forKey: "deviceID")
//
//            return deviceID
//        }
//    }
    
    func chunkFormatted(withChunkSize chunkSize: Int = 4, withSeparator separator: Character = " ") -> String
    {
        return filter { $0 != separator }.chunk(n: chunkSize)
            .map{ String($0) }.joined(separator: String(separator))
    }
    
    //Remove .0 string from main string
    func truncateZeroDecimal() -> String
    {
        return self.replacingOccurrences(of: ".0", with: "")
    }
    
    //Split string into two parts on the basis of given lenght
    func split(_ len: Int) -> (String, String?)
    {
        if self.count > len
        {
            let firstPart = self.prefix(len)
            let remaining = self.suffix(self.count-len)
            
            return (String(firstPart), String(remaining))
        }
        else
        {
            return (self, nil)
        }
    }
    
    func manageAgeRange() -> String
    {
        if !((self.components(separatedBy: "-")[0]).contains("+")) && !(self.contains("1-99"))
        {
            let str = ((self.components(separatedBy: "-")[0]) + "+")
            
            return str
        }
        
        return self
    }
    
    func md5() -> String
    {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate()
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
    
    //Will Retun Age
    func ageValue() -> Int
    {
        var ageGrp = "0"
        if self.contains("-")
        {
            ageGrp = (self.components(separatedBy: "-")[0])
        }
        else
        {
            ageGrp = (self.components(separatedBy: "+")[0])
        }
        
        return (Int(ageGrp) ?? 0)
    }
    
    func nsnumValue() -> NSNumber
    {
        if let myInteger = Int(self)
        {
            return NSNumber(value:myInteger)
        }
        return NSNumber.init()
    }
    
    func intVal() -> Int
    {
        return (self as NSString).integerValue
    }
    
    func floatVal() -> Float
    {
        return (self as NSString).floatValue
    }
    
    //Fetch Image From Document Directory with given Name
    func fetchImageFromDD() -> UIImage?
    {
        let fileManager = FileManager.default
        let imagePAth = (String.documentDirectoryPath() as NSString).appendingPathComponent(self + ".jpg")
        
        if fileManager.fileExists(atPath: imagePAth)
        {
            print("File Exsits at Path == \(imagePAth)")
            return UIImage(contentsOfFile: imagePAth)!
        }
        else
        {
            print("no image Found at Path == \(imagePAth)")
            return nil
        }
    }
    
    static func documentDirectoryPath() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func deleteImageFromDD()
    {
        // get the documents directory url
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(self + ".jpg")
        if FileManager.default.fileExists(atPath: fileURL.path)
        {
            try! FileManager.default.removeItem(atPath: fileURL.path)
            print("Image Deleted From Document Directory == \(fileURL.path)")
        }
    }
    
    static let numberFormatter = NumberFormatter()
    var reverseFormattedNumber: Float {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.floatValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.floatValue
            }
        }
        return 0
    }
    
    var queryDictionary: [String: String]? {
        var queryStrings = [String: String]()
        for pair in self.components(separatedBy: "&") {

            let key = pair.components(separatedBy: "=")[0]

            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""

            queryStrings[key] = value
        }
        return queryStrings
    }
    
    //ordeDateLocal() func was not providing required output, so created a new func to convert GMT time to local
    func gmtToLocal(_ format: DateFormatType = .dateTimeSec) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: self)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = format.rawValue
        
        return dateFormatter.string(from: dt!)
    }
    
    func returnAstringBasedOnEmptyValue() -> String
    {
        if self == ""
        {
            return "N/A"
        }
        else
        {
            return self
        }
    }
}

//Collection Class
extension Collection
{
    public func chunk(n: Int) -> [SubSequence]
    {
        var res: [SubSequence] = []
        var i = startIndex
        var j: Index
        while i != endIndex
        {
            j = index(i, offsetBy: n, limitedBy: endIndex) ?? endIndex
            res.append(self[i..<j])
            i = j
        }
        return res
    }
}

//Window Class
extension UIWindow
{
    func topViewController() -> UIViewController?
    {
        var top = self.rootViewController
        
        while true
        {
            if let presented = top?.presentedViewController
            {
                top = presented
            }
            else if let nav = top as? UINavigationController
            {
                top = nav.visibleViewController
            }
            else if let tab = top as? UITabBarController
            {
                top = tab.selectedViewController
            }
            else
            {
                break
            }
        }
        return top
    }
}

extension NumberFormatter
{
//    class func currencySymbolformatter() -> NumberFormatter
//    {
//        return NumberFormatter.currencyFormatter(.currency)
//    }
    
//    private class func currencyFormatter(_ numberStyle: NumberFormatter.Style) -> NumberFormatter
//    {
//        let formatter = NumberFormatter.init()
//        formatter.numberStyle = numberStyle
//        formatter.locale = Locale.init(identifier: (DistSettingsManager.shared().settings.localeId))
//
//        return formatter
//    }
    
//    class func numberformatter() -> NumberFormatter
//    {
//        let numberFormatter = NumberFormatter.currencyFormatter(.decimal)
//        numberFormatter.maximumFractionDigits = 2
//        numberFormatter.minimumFractionDigits = 2
//        return numberFormatter
//    }
    
    //When 0 was -ve
    class func absoluteNum() -> NumberFormatter
    {
        let formatter = NumberFormatter.init()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.locale = Locale.init(identifier: "en_US_POSIX")
        
        return formatter
    }
}

extension DateFormatter
{
    fileprivate class func createFormatter() -> DateFormatter
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        
        return dateFormatter
    }
    
    //Dateformatter with Netherlands locale
    class func formatter(_ type: DateFormatType, _ timeZone: TimeZone? = TimeZone.current) -> DateFormatter
    {
        let dateFormatter = DateFormatter.createFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = type.rawValue
        return dateFormatter
    }
    
    //Dateformatter with current components
    class func localDate() -> DateFormatter
    {
        let dateFormatter = DateFormatter.createFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }
}

extension Float
{
    func round(_ decimalPlace: Int)->String
    {
        let format = NSString(format: "%%.%if", decimalPlace)
        let string = NSString(format: format, self)
        return String.init(string)
    }
}

extension NSObject
{
    func num(_ defaultValue: Int = 0) -> NSNumber
    {
        if self is NSNumber
        {
            return self as! NSNumber
        }
        else if self is String
        {
            return NSNumber(value: (Float(self as? String ?? "0") ?? 0))
        }
        else
        {
            return defaultValue as NSNumber
        }
    }
    
    func string() -> String
    {
        if self is String
        {
            return self as! String
        }
        else
        {
            return ""
        }
    }
    
    func boolValue() -> Bool
    {
        if self.num().intValue > 0
        {
            return true
        }
        else
        {
            return false
        }
    }
}

extension Date
{
    //Function to get today date only without time
    static func today() -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatType.date.rawValue
        dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        
        let dateStr = dateFormatter.string(from: Date())
        
        return dateFormatter.date(from: dateStr)!
        
        //return Date().localDateTime(.date).date()
        //return Date()
    }
    
    //Date Time As Per Current Time Zone with given format
    func localDateTime(_ format: DateFormatType = .hour) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        
        return dateFormatter.string(from: self)
    }
    
    //Date Time As Per GMT Time Zone with given format
    func gmtDateTime(_ format: DateFormatType = .hour) -> String
    {
        let gmtDate = self.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT() * -1))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        
        return dateFormatter.string(from: gmtDate)
        
        //return DateFormatter.formatter(format, TimeZone.init(abbreviation: "GMT")).string(from: self)
    }
    
    static func currentTimerIntervalGMT() -> Int64
    {
        let timeMillis = Int64(Date().timeIntervalSince1970 * 1000)
        
        //timeMillis = timeMillis - Int64(TimeZone.current.secondsFromGMT() * 1000)
        
        print("Seconds >>>>>> ", timeMillis)
        
        return timeMillis
    }
    
    static func currentTimerInterval() -> Int64
    {
        return  Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    static func currentTimeZone() -> String
    {
        return TimeZone.current.localizedName(for: .shortStandard, locale: nil) ?? ""   // "GMT-3
    }
    
    static func currentTimeZoneIdentifier() -> String
    {
        return TimeZone.current.identifier
    }
    
    static func dateFromTimeInterval(_ timeinterval: NSNumber) -> String
    {
        let date = self.init(timeIntervalSince1970: TimeInterval((timeinterval.int64Value)/1000))
        
        // let date = self.init(timeIntervalSince1970: TimeInterval((timeinterval.intValue + (TimeZone.current.secondsFromGMT() * 1000))/1000))
        
        print(date)
        
        //        if date.timeIntervalSinceNow > 24*60*60
        //        {
        //            return date.localDateTime(.dateSlash)
        //        }
        //        else
        //        {
        //            return date.localDateTime(.timeAm)
        //        }
        
        return date.localDateTime(.dateTimeSec)
    }
    
    //Confusion: Date string from current timezone
    static func currentTimeZoneDate(_ date: Date) -> Date
    {
        return date
        //let dateStr = date.localDateTime(.dateTimeSec)
        //return DateFormatter.formatter(.dateTimeSec).date(from: dateStr)!
    }
    
    //Provide the previous date
    static func yesterday() -> Date
    {
        return DateFormatter.formatter(.date).date(from: (Calendar.current.date(byAdding: .day, value: -1, to: Date.today())?.localDateTime(.date))!)!
    }
    
    static func tomorrow() -> Date
    {
        return DateFormatter.formatter(.date).date(from: (Calendar.current.date(byAdding: .day, value: 1, to: Date.today())?.localDateTime(.date))!)!
    }
    
    //For generating the Passes, Using the TimeInterval with String Len == 9
    static func confirmInterval() -> String
    {
        //        let interval = Date().timeIntervalSince("2018-01-01".date())
        let interval = Date.currentTimerIntervalGMT()
        var intervalStr = String(String(interval).suffix(13))
        
        while intervalStr.prefix(1) == "0"
        {
            intervalStr.remove(at: String.Index.init(encodedOffset: 0))
        }
        
        let remainingChars = 13 - intervalStr.count
        if (remainingChars > 0)
        {
            let lowerRange = NSDecimalNumber(decimal: pow(10, (remainingChars - 1)))
            let upperRange = NSDecimalNumber(decimal: (pow(10, remainingChars) - 1))
            intervalStr.append("\(Int.random(in: lowerRange.intValue...upperRange.intValue))")
        }
        else
        {
            intervalStr = String(intervalStr.prefix(13))
        }
        
        //        while intervalStr.count != 9
        //        {
        //            if intervalStr.count > 9
        //            {
        //                intervalStr = String(intervalStr.prefix(9))
        //            }
        //            else
        //            {
        //                intervalStr.append("\((arc4random()%998) + 1)")
        //            }
        //        }
        
        return intervalStr
    }
    
    //All the Dates b/w two given dates
    func datesTill(_ endDate: Date) -> [Date]
    {
        var datesArr = [Date]()
        
        var startDate = self
        let calendar = Calendar.current
        
        while startDate <= endDate
        {
            datesArr.append(startDate)
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        }
        
        return datesArr
    }
    
    func isBetween(_ date1: Date, _ date2: Date) -> Bool
    {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }
}

extension UIDevice
{
    var iPhone: Bool
    {
        return UIDevice().userInterfaceIdiom == .phone
    }
    
    enum ScreenType: String
    {
        case iPhone4
        case iPhone5
        case iPhone6
        case iPhone6Plus
        case iPhoneX
        case Unknown
    }
    
    var screenType: ScreenType
    {
        guard iPhone else { return .Unknown}
        switch UIScreen.main.nativeBounds.height
        {
        case 960:
            return .iPhone4
        case 1136:
            return .iPhone5
        case 1334:
            return .iPhone6
        case 2208:
            return .iPhone6Plus
        case 2436:
            return .iPhoneX
        default:
            return .Unknown
        }
    }
}

extension Bundle
{
    static var myBundle: Bundle? =  Bundle.main
    
    class func setLanguage(_ langStr: String)
    {
        let path = Bundle.main.path(forResource: langStr, ofType: "lproj")
        
        if (path == nil)
        {
            Bundle.myBundle = Bundle.main
        }
        else
        {
            Bundle.myBundle = Bundle(path: path!)
            Bundle.myBundle?.load()
        }
    }
}

extension UILabel
{
    func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat
    {
        self.frame = CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude)
        self.numberOfLines = 0
        self.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.font = font
        self.text = text
        
        self.sizeToFit()
        return self.frame.height
    }
}

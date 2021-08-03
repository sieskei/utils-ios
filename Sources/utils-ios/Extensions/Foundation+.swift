//
//  Foundation+.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation
import CommonCrypto

public extension StringProtocol  {
    func substring<S: StringProtocol, T: StringProtocol>(from start: S, to end: T, options: String.CompareOptions = []) -> SubSequence? {
        guard let lower = range(of: start, options: options)?.upperBound,
              let upper = self[lower...].range(of: end, options: options)?.lowerBound else {
            return nil
        }
        
        return self[lower..<upper]
    }
}

public extension String {
    var fromBase64: String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
    
    var base64: String {
        return Data(utf8).base64EncodedString()
    }
    
    var md5: String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)

        if let data = data(using: .utf8) {
            _ = data.withUnsafeBytes { body -> String in
                CC_MD5(body.baseAddress, CC_LONG(data.count), &digest)
                return ""
            }
        }

        return (0 ..< length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    mutating func trim() {
        self = trimmed
    }
}

public extension NSMutableAttributedString {
    var trimmed: NSAttributedString {
        let invertedSet = CharacterSet.whitespacesAndNewlines.inverted
        let startRange = string.rangeOfCharacter(from: invertedSet)
        let endRange = string.rangeOfCharacter(from: invertedSet, options: .backwards)
        guard let startLocation = startRange?.upperBound, let endLocation = endRange?.lowerBound else {
            return NSAttributedString(string: string)
        }
        let location = string.distance(from: string.startIndex, to: startLocation) - 1
        let length = string.distance(from: startLocation, to: endLocation) + 2
        let range = NSRange(location: location, length: length)
        
        return attributedSubstring(from: range)
    }
}

public extension Array {
    mutating func tryRemoveFirst() -> Element? {
        guard count > 0 else {
            return nil
        }
        return removeFirst()
    }
}

public extension Dictionary {
    func insert(value: Value, forKey key: Key) -> Dictionary<Key, Value> {
        var map = Dictionary<Key, Value>()
        map[key] = value
        forEach {
            map[$0] = $1
        }
        return map
    }
}

public extension Locale {
    static let Bulgaria: Locale? = Locale(identifier: "bg_BG")
}

public extension TimeZone {
    static var GMT: TimeZone? = TimeZone(secondsFromGMT: 0)
}

public extension URL {
    /// Returns a new URL by adding the query items, or nil if the URL doesn't support it.
    /// URL must conform to RFC 3986.
    func appending(_ queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            // URL is not conforming to RFC 3986 (maybe it is only conforming to RFC 1808, RFC 1738, and RFC 2732)
            return nil
        }
        // append the query items to the existing ones
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems

        // return the url from new url components
        return urlComponents.url
    }
}

/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2009-2026 MyFlightbook, LLC

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  SoapCore.swift
//
//  The small, hand-written SOAP engine that replaces the WSDLToObjC generated code.  Nothing in this file
//  knows about specific MyFlightbook web services; see MFBWebServiceTypes.swift (data structures),
//  MFBWebServiceMessages.swift (requests/responses) and SoapClient.swift (transport).
//
//  How a data structure works
//  --------------------------
//  Every SOAP complex type is a subclass of `SoapObject` that:
//    1. declares its properties as ordinary Swift properties, and
//    2. lists them, in WSDL (sequence) order, in a `soapFields` table.
//  That one table drives XML serialization, XML deserialization and NSCoding.  There is no reflection.
//
//      @objc(MFBWebServiceSvc_LatLong)
//      public class MFBWebServiceSvc_LatLong : SoapObject {
//          public var latitude : NSNumber!
//          public var longitude : NSNumber!
//
//          public override class var soapFields : [SoapField] {
//              let f = SoapFieldBuilder<MFBWebServiceSvc_LatLong>()
//              return super.soapFields + [
//                  f.number("Latitude", \.latitude),
//                  f.number("Longitude", \.longitude)
//              ]
//          }
//      }
//
//  If the server adds a property, add the Swift property and one line in the table (at the position it has in the
//  WSDL).  If the server adds a *type*, add a new subclass like the above.
//

import Foundation

// MARK: - Namespace constants

public enum SoapNamespace {
    /// Target namespace of the MyFlightbook web service (WSDL targetNamespace)
    public static let service = "http://myflightbook.com/"
    /// Prefix used for the service's namespace in the requests we send
    public static let servicePrefix = "MFBWebServiceSvc"
    public static let soap12Envelope = "http://www.w3.org/2003/05/soap-envelope"
    public static let soap11Envelope = "http://schemas.xmlsoap.org/soap/envelope/"
    /// Prefix on generated class names (e.g., MFBWebServiceSvc_Aircraft); used to resolve xsi:type="Aircraft"
    public static let classPrefix = "MFBWebServiceSvc_"
}

// MARK: - XML reading

/// A minimal, namespace-agnostic XML element tree.  Prefixes are stripped from element names ("soap:Body" -> "Body").
public final class SoapXMLNode {
    public let name: String
    public fileprivate(set) var attributes : [String : String] = [:]
    public fileprivate(set) var children : [SoapXMLNode] = []
    /// Character data directly inside this element
    public fileprivate(set) var text = ""

    fileprivate init(name: String) {
        self.name = name
    }

    /// First child element with the given name
    public func child(_ name: String) -> SoapXMLNode? {
        return children.first { $0.name == name }
    }

    /// All the text in this element and its descendants, concatenated
    public var allText : String {
        return text + children.map { $0.allText }.joined()
    }

    /// The (unprefixed) value of an xsi:type attribute, if present.  E.g. xsi:type="q1:PendingFlight" -> "PendingFlight"
    public var xsiTypeName : String? {
        guard let kv = attributes.first(where: { $0.key == "type" || $0.key.hasSuffix(":type") }) else {
            return nil
        }
        return kv.value.split(separator: ":").last.map(String.init)
    }

    /// Parse a document and return the root element.  Throws if the XML is malformed.
    public static func parse(_ data: Data) throws -> SoapXMLNode {
        let builder = TreeBuilder()
        let parser = XMLParser(data: data)
        parser.delegate = builder
        parser.shouldProcessNamespaces = false
        if !parser.parse() || builder.root == nil {
            throw parser.parserError ?? SoapError.malformedResponse("Errors while parsing returned XML")
        }
        return builder.root!
    }

    private final class TreeBuilder : NSObject, XMLParserDelegate {
        var root : SoapXMLNode? = nil
        private var stack : [SoapXMLNode] = []

        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            let node = SoapXMLNode(name: SoapXMLNode.localName(elementName))
            node.attributes = attributeDict
            if let parent = stack.last {
                parent.children.append(node)
            } else if root == nil {
                root = node
            }
            stack.append(node)
        }

        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            _ = stack.popLast()
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            stack.last?.text += string
        }

        func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
            stack.last?.text += String(decoding: CDATABlock, as: UTF8.self)
        }
    }

    fileprivate static func localName(_ qualified: String) -> String {
        if let i = qualified.lastIndex(of: ":") {
            return String(qualified[qualified.index(after: i)...])
        }
        return qualified
    }
}

// MARK: - XML writing

/// Builds the XML for a request.  Elements are written in the service namespace (prefix MFBWebServiceSvc).
public final class SoapWriter {
    private(set) var xml = ""

    /// <MFBWebServiceSvc:name>text</MFBWebServiceSvc:name>, with text escaped
    public func leaf(_ name: String, _ text: String) {
        open(name)
        xml += SoapWriter.escape(text)
        close(name)
    }

    public func open(_ name: String) {
        xml += "<\(SoapNamespace.servicePrefix):\(name)>"
    }

    public func close(_ name: String) {
        xml += "</\(SoapNamespace.servicePrefix):\(name)>"
    }

    /// Writes an element with children produced by `body`
    public func element(_ name: String, _ body: () -> Void) {
        open(name)
        body()
        close(name)
    }

    fileprivate func raw(_ s: String) {
        xml += s
    }

    public static func escape(_ s: String) -> String {
        guard s.contains(where: { "&<>\"'".contains($0) }) else { return s }
        var out = ""
        out.reserveCapacity(s.count + 16)
        for c in s {
            switch c {
            case "&": out += "&amp;"
            case "<": out += "&lt;"
            case ">": out += "&gt;"
            case "\"": out += "&quot;"
            case "'": out += "&apos;"
            default: out.append(c)
            }
        }
        return out
    }

    /// Wraps a request object in a SOAP 1.2 envelope.
    public static func envelope(for body: SoapObject) -> String {
        let w = SoapWriter()
        w.raw("<?xml version=\"1.0\" encoding=\"utf-8\"?>")
        w.raw("<soap:Envelope xmlns:soap=\"\(SoapNamespace.soap12Envelope)\" " +
              "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" " +
              "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" " +
              "xmlns:\(SoapNamespace.servicePrefix)=\"\(SoapNamespace.service)\">")
        w.raw("<soap:Body>")
        w.element(type(of: body).soapElementName) {
            body.writeFields(to: w)
        }
        w.raw("</soap:Body></soap:Envelope>")
        return w.xml
    }
}

// MARK: - Errors

public enum SoapError : LocalizedError {
    /// The client has no endpoint address
    case noAddress
    /// Network/URLSession failure
    case transport(Error)
    /// The server's response could not be understood
    case malformedResponse(String)
    /// The server returned a SOAP fault (e.g., a server-side exception).
    case fault(SOAPFault)

    public var errorDescription: String? {
        switch self {
        case .noAddress:
            return "No endpoint address was specified for the web service"
        case .transport(let e):
            return e.localizedDescription
        case .malformedResponse(let s):
            return s
        case .fault(let f):
            return f.simpleFaultString
        }
    }
}

/// A SOAP fault returned by the server.
@objc(SOAPFault) public class SOAPFault : NSObject {
    @objc public var faultcode : String!
    @objc public var faultstring : String!
    @objc public var faultactor : String!
    @objc public var detail : String!

    /// The fault message without the .NET exception boilerplate (class name prefix and stack trace)
    @objc public var simpleFaultString : String {
        var s = (faultstring ?? "").replacingOccurrences(of: "System.Web.Services.Protocols.SoapException: ", with: "")
        if let r = s.range(of: "\n   at ") {
            s = String(s[..<r.lowerBound])
        }
        return s
    }

    /// Reads a Fault element (SOAP 1.1 or 1.2)
    static func parse(_ node: SoapXMLNode) -> SOAPFault {
        let f = SOAPFault()
        if node.child("faultcode") != nil || node.child("faultstring") != nil {
            // SOAP 1.1
            f.faultcode = node.child("faultcode")?.allText
            f.faultstring = node.child("faultstring")?.allText
            f.faultactor = node.child("faultactor")?.allText
            f.detail = node.child("detail")?.allText
        } else {
            // SOAP 1.2
            f.faultcode = node.child("Code")?.child("Value")?.allText
            f.faultstring = node.child("Reason")?.allText
            f.faultactor = node.child("Node")?.allText
            f.detail = node.child("Detail")?.allText
        }
        return f
    }
}

// MARK: - Simple types

/// Marker for the enumerations in the WSDL.  The WSDL's strings map to UInt32 raw values, with 0 meaning "not set".
/// These are structs (not Swift enums) so that they are drop-in compatible with the C enums the old generated code had,
/// i.e., `MFBWebServiceSvc_NumType_Integer` style constants, `.rawValue` as UInt32, and a non-failable init(rawValue:).
public protocol SoapEnum : RawRepresentable, Hashable where RawValue == UInt32 {
    init(rawValue: UInt32)
    /// (xml string, value) for each defined value except `none`
    static var soapValues : [(String, Self)] { get }
}

public extension SoapEnum {
    static var none : Self { return Self(rawValue: 0) }
    var isNone : Bool { return rawValue == 0 }

    /// The string used in XML; empty if the value is not one of the defined values.
    var soapString : String {
        return Self.soapValues.first(where: { $0.1 == self })?.0 ?? ""
    }

    /// The enum value for an XML string; `none` if unrecognized
    init(soapString s: String) {
        self = Self.soapValues.first(where: { $0.0 == s })?.1 ?? Self(rawValue: 0)
    }
}

/// Replacement for the old USBoolean: an object-wrapped boolean so that "not specified" can be distinguished from false.
@objc(USBoolean) public class USBoolean : NSObject, NSSecureCoding {
    @objc public var boolValue : Bool

    @objc public init(bool b: Bool) {
        boolValue = b
        super.init()
    }

    @objc public convenience override init() {
        self.init(bool: false)
    }

    @objc public var stringValue : String {
        return boolValue ? "true" : "false"
    }

    public override func isEqual(_ object: Any?) -> Bool {
        return (object as? USBoolean)?.boolValue == boolValue
    }

    public override var hash: Int { return boolValue ? 1 : 0 }

    // NSCoding - this is the same (keyless) encoding the original Objective-C class used, so existing archives still decode
    public static var supportsSecureCoding: Bool { return true }

    public func encode(with coder: NSCoder) {
        var b = boolValue
        coder.encodeValue(ofObjCType: "B", at: &b)
    }

    public required init?(coder: NSCoder) {
        var b = false
        coder.decodeValue(ofObjCType: "B", at: &b, size: MemoryLayout<Bool>.size)
        boolValue = b
        super.init()
    }
}

// MARK: - Fields

extension String {
    /// The service double-encodes some text (e.g. it sends `&amp;quot;` for a quote), so after the XML parser has decoded once,
    /// entities remain.  The old WSDLToObjC code unescaped every string a second time, which hid this; we do the same
    /// (same replacement order as the original `stringByUnescapingXML`) so text such as "B787-8 \"Dreamliner\"" displays correctly.
    var unescapingXMLEntities : String {
        if !contains("&") { return self }
        return self.replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")
    }
}

/// One element of a complex type: how to write it to XML, read it from XML, and archive it.
/// Build these with `SoapFieldBuilder` (see the file header).
public struct SoapField {
    /// The element name in the XML
    public let name : String
    /// The key used with NSCoder.  This is the name of the property in the old generated code (which archived its ivars by name),
    /// so that archives written by earlier versions still decode.
    public let key : String

    let write : (SoapObject, SoapWriter) -> Void
    let read : (SoapObject, SoapXMLNode) -> Void
    let encode : (SoapObject, NSCoder) -> Void
    let decode : (SoapObject, NSCoder) -> Void
    /// Called after reading when this element was absent from the XML (used to default arrays to empty instead of nil)
    var missing : (SoapObject) -> Void = { _ in }
    /// Called after reading a *Response* when this element (the operation's result) was absent: sets an empty value ("", 0, false, an empty object)
    var missingResult : (SoapObject) -> Void = { _ in }
}

/// Creates the fields for properties of the class `R`.  Typical use (inside `soapFields`):
///
///     let f = SoapFieldBuilder<MFBWebServiceSvc_Aircraft>()
///     f.string("TailNumber", \.tailNumber)
///
/// `key:` overrides the NSCoder key when it differs from the XML element name (only for names that were reserved words in ObjC).
public struct SoapFieldBuilder<R : SoapObject> {
    public init() {}

    // MARK: scalars
    public func string(_ name: String, _ kp: ReferenceWritableKeyPath<R, String?>, key: String? = nil) -> SoapField {
        return field(name, key, kp,
                     write: { w, v in w.leaf(name, v) },
                     read: { n in n.text.unescapingXMLEntities },
                     decodeAs: { c, k in c.decodeObject(of: NSString.self, forKey: k) as String? },
                     empty: { "" })
    }

    /// Numbers (int, long, decimal, double) are NSNumber, read as doubles
    public func number(_ name: String, _ kp: ReferenceWritableKeyPath<R, NSNumber?>, key: String? = nil) -> SoapField {
        return field(name, key, kp,
                     write: { w, v in w.leaf(name, v.stringValue) },
                     read: { n in NSNumber(value: Double(n.text.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0) },
                     decodeAs: { c, k in c.decodeObject(of: NSNumber.self, forKey: k) },
                     empty: { NSNumber(value: 0) })
    }

    public func bool(_ name: String, _ kp: ReferenceWritableKeyPath<R, USBoolean?>, key: String? = nil) -> SoapField {
        return field(name, key, kp,
                     write: { w, v in w.leaf(name, v.stringValue) },
                     read: { n in
                        switch n.text.trimmingCharacters(in: .whitespacesAndNewlines) {
                        case "true", "1": return USBoolean(bool: true)
                        case "false", "0": return USBoolean(bool: false)
                        default: return nil
                        }
                     },
                     decodeAs: { c, k in c.decodeObject(of: USBoolean.self, forKey: k) },
                     empty: { USBoolean(bool: false) })
    }

    public func date(_ name: String, _ kp: ReferenceWritableKeyPath<R, Date?>, key: String? = nil) -> SoapField {
        return field(name, key, kp,
                     write: { w, v in w.leaf(name, (v as NSDate).iso8601DateString()) },
                     read: { n in NSDate(iso8601String: n.text) as Date? },
                     decodeAs: { c, k in c.decodeObject(of: NSDate.self, forKey: k) as Date? })
    }

    public func data(_ name: String, _ kp: ReferenceWritableKeyPath<R, Data?>, key: String? = nil) -> SoapField {
        return field(name, key, kp,
                     write: { w, v in w.leaf(name, v.base64EncodedString()) },
                     read: { n in Data(base64Encoded: n.text, options: .ignoreUnknownCharacters) },
                     decodeAs: { c, k in c.decodeObject(of: NSData.self, forKey: k) as Data? })
    }

    // MARK: enums
    /// Enums are not optional; the value `none` (0) is "not specified" and is not written.
    public func enumeration<E : SoapEnum>(_ name: String, _ kp: ReferenceWritableKeyPath<R, E>, key: String? = nil) -> SoapField {
        return SoapField(name: name, key: key ?? name,
            write: { obj, w in
                let v = (obj as! R)[keyPath: kp]
                if !v.isNone { w.leaf(name, v.soapString) }
            },
            read: { obj, node in
                (obj as! R)[keyPath: kp] = E(soapString: node.text.trimmingCharacters(in: .whitespacesAndNewlines))
            },
            encode: { obj, coder in
                // Archived as an NSNumber, as the old generated code did
                coder.encode(NSNumber(value: (obj as! R)[keyPath: kp].rawValue), forKey: key ?? name)
            },
            decode: { obj, coder in
                if let n = coder.decodeObject(of: NSNumber.self, forKey: key ?? name) {
                    (obj as! R)[keyPath: kp] = E(rawValue: n.uint32Value)
                }
            })
    }

    // MARK: nested objects
    /// A nested complex type.  If the XML says xsi:type="SomeSubclass", an instance of that subclass is created.
    public func object<T : SoapObject>(_ name: String, _ kp: ReferenceWritableKeyPath<R, T?>, key: String? = nil) -> SoapField {
        var f = field(name, key, kp,
                     write: { w, v in w.element(name) { v.writeFields(to: w) } },
                     read: { n in SoapObject.make(T.self, from: n) },
                     decodeAs: { c, k in c.decodeObject(of: T.self, forKey: k) },
                     empty: { (T.self as NSObject.Type).init() as? T })
        // The server omits an empty array's element entirely (e.g. when the auth token is bad), and the old code tolerated nil
        // there.  An absent "ArrayOf..." is semantically an empty list, so give callers an empty one rather than a nil to trip on.
        if NSStringFromClass(T.self).hasPrefix(SoapNamespace.classPrefix + "ArrayOf") {
            f.missing = { obj in (obj as! R)[keyPath: kp] = (T.self as NSObject.Type).init() as? T }
        }
        return f
    }

    // MARK: repeated elements (the contents of the "ArrayOf..." types)
    /// Repeated <name>number</name> elements, held in an NSMutableArray of NSNumber
    public func numbers(_ name: String, _ kp: ReferenceWritableKeyPath<R, NSMutableArray?>, key: String? = nil) -> SoapField {
        return list(name, key, kp,
                    write: { w, v in (v as? NSNumber).map { w.leaf(name, $0.stringValue) } },
                    read: { n in NSNumber(value: Double(n.text.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0) },
                    classes: [NSNumber.self])
    }

    /// Repeated <name>text</name> elements, held in an NSMutableArray of String
    public func strings(_ name: String, _ kp: ReferenceWritableKeyPath<R, NSMutableArray?>, key: String? = nil) -> SoapField {
        return list(name, key, kp,
                    write: { w, v in (v as? String).map { w.leaf(name, $0) } },
                    read: { n in n.text.unescapingXMLEntities as NSString },
                    classes: [NSString.self])
    }

    /// Repeated nested objects, held in an NSMutableArray of T (or of subclasses of T, per xsi:type)
    public func objects<T : SoapObject>(_ name: String, _ kp: ReferenceWritableKeyPath<R, NSMutableArray?>, of type: T.Type, key: String? = nil) -> SoapField {
        return list(name, key, kp,
                    write: { w, v in
                        if let o = v as? SoapObject { w.element(name) { o.writeFields(to: w) } }
                    },
                    read: { n in SoapObject.make(T.self, from: n) },
                    classes: [NSArray.self, T.self])
    }

    // MARK: implementation
    private func field<V>(_ name: String, _ key: String?, _ kp: ReferenceWritableKeyPath<R, V?>,
                          write: @escaping (SoapWriter, V) -> Void,
                          read: @escaping (SoapXMLNode) -> V?,
                          decodeAs: @escaping (NSCoder, String) -> V?,
                          empty: (() -> V?)? = nil) -> SoapField {
        let k = key ?? name
        var f = SoapField(name: name, key: k,
            write: { obj, w in
                if let v = (obj as! R)[keyPath: kp] { write(w, v) }
            },
            read: { obj, node in (obj as! R)[keyPath: kp] = read(node) },
            encode: { obj, coder in
                if let v = (obj as! R)[keyPath: kp] { coder.encode(v, forKey: k) }
            },
            decode: { obj, coder in (obj as! R)[keyPath: kp] = decodeAs(coder, k) })
        if let empty = empty {
            f.missingResult = { obj in (obj as! R)[keyPath: kp] = empty() }
        }
        return f
    }

    private func list(_ name: String, _ key: String?, _ kp: ReferenceWritableKeyPath<R, NSMutableArray?>,
                      write: @escaping (SoapWriter, Any) -> Void,
                      read: @escaping (SoapXMLNode) -> Any?,
                      classes: [AnyClass]) -> SoapField {
        let k = key ?? name
        return SoapField(name: name, key: k,
            write: { obj, w in
                for v in ((obj as! R)[keyPath: kp] ?? []) { write(w, v) }
            },
            read: { obj, node in
                guard let v = read(node) else { return }
                let o = obj as! R
                if o[keyPath: kp] == nil { o[keyPath: kp] = NSMutableArray() }
                o[keyPath: kp]!.add(v)
            },
            encode: { obj, coder in
                if let v = (obj as! R)[keyPath: kp] { coder.encode(v, forKey: k) }
            },
            decode: { obj, coder in
                let allowed : [AnyClass] = classes + [NSArray.self, NSMutableArray.self, NSString.self, NSNumber.self, SoapObject.self]
                if let arr = coder.decodeObject(of: allowed, forKey: k) as? NSArray {
                    (obj as! R)[keyPath: kp] = NSMutableArray(array: arr)
                }
            })
    }
}

// MARK: - SoapObject

/// Base class of every complex type (and every request/response message) in the web service.
@objc(SoapObject)
open class SoapObject : NSObject, NSSecureCoding {
    public override init() {
        super.init()
    }

    /// The element name when this type is the top-level element of a request or response (e.g., "AircraftForUser").
    /// Message classes override this; data structures only need it when used as a message body.
    open class var soapElementName : String {
        return String(describing: self)
    }

    /// The elements of this type in WSDL order.  Subclasses of a SOAP type must start with `super.soapFields`.
    open class var soapFields : [SoapField] {
        return []
    }

    // Field tables are built from key paths, so cache them per class.
    private static var fieldCache : [ObjectIdentifier : [SoapField]] = [:]
    private static let fieldCacheLock = NSLock()

    private var fields : [SoapField] {
        let t = type(of: self)
        let id = ObjectIdentifier(t)
        SoapObject.fieldCacheLock.lock()
        defer { SoapObject.fieldCacheLock.unlock() }
        if let f = SoapObject.fieldCache[id] {
            return f
        }
        let f = t.soapFields
        SoapObject.fieldCache[id] = f
        return f
    }

    // MARK: XML

    /// Writes the child elements of this object (not the object's own start/end tags)
    public func writeFields(to w: SoapWriter) {
        for f in fields {
            f.write(self, w)
        }
    }

    /// Populates this object from the child elements of `node`
    public func readFields(from node: SoapXMLNode) {
        let table = fields
        var seen = Set<String>()
        for child in node.children {
            // Fields are mostly unique; the linear scan is fine for objects this small
            if let f = table.first(where: { $0.name == child.name }) {
                f.read(self, child)
                seen.insert(f.name)
            }
        }
        // Absent elements: arrays become empty lists everywhere; and an operation's result that the server left out
        // (it does this on, e.g., a bad auth token) becomes an empty value, so callers never trip over a nil result.
        let isResponse = NSStringFromClass(type(of: self)).hasSuffix("Response")
        for f in table where !seen.contains(f.name) {
            f.missing(self)
            if isResponse { f.missingResult(self) }
        }
    }

    /// Creates an instance of `type` (or, if the node has an xsi:type naming a subclass of it, an instance of that subclass)
    /// and populates it from `node`.
    public static func make<T : SoapObject>(_ type: T.Type, from node: SoapXMLNode) -> T? {
        var cls : AnyClass = type
        if let xsi = node.xsiTypeName,
           let named = NSClassFromString(SoapNamespace.classPrefix + xsi) ?? NSClassFromString(xsi),
           named.isSubclass(of: type) {
            cls = named
        }
        guard let obj = (cls as? NSObject.Type)?.init() as? T else {
            return nil
        }
        obj.readFields(from: node)
        return obj
    }

    // MARK: NSCoding

    open class var supportsSecureCoding: Bool { return true }

    /// NSCoding.  By default every field in `soapFields` is archived under its XML element name (the keys the original
    /// generated code used).  A class that needs a different archive layout - typically one that has to keep reading
    /// archives written by older versions of the app - overrides `encodeFields(to:)` and `decodeFields(from:)`
    /// (in the class itself or in an extension; no swizzling needed).
    public func encode(with coder: NSCoder) {
        encodeFields(to: coder)
    }

    public required init?(coder: NSCoder) {
        super.init()
        decodeFields(from: coder)
    }

    @objc dynamic open func encodeFields(to coder: NSCoder) {
        for f in fields {
            f.encode(self, coder)
        }
    }

    @objc dynamic open func decodeFields(from coder: NSCoder) {
        for f in fields {
            f.decode(self, coder)
        }
    }
}

/// A SoapObject that can be sent to the server.  The associated `Response` is what comes back, which is what lets
/// `SoapClient.call` be generic: the compiler works out the result type from the request.
public protocol SoapRequest : SoapObject {
    associatedtype Response : SoapObject
}

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
//  SoapClient.swift
//
//  Sends requests and returns typed responses.  This file has no dependency on the host name (MFBHOSTNAME);
//  the endpoint is always supplied by the caller.
//
//  The modern API (closures / async-await)
//  ---------------------------------------
//      let client = SoapClient(host: MFBHOSTNAME)
//      let req = MFBWebServiceSvc_GetCurrencyForUser()
//      req.szAuthToken = token
//
//      client.call(req,
//                  onSuccess: { (resp : MFBWebServiceSvc_GetCurrencyForUserResponse) in ... },   // type is inferred
//                  onError: { error in ... },
//                  onComplete: { ... })                                                          // always called last
//
//      // or
//      let resp = try await client.call(req)
//
//  Everything is generic on the request type: the response type comes from `SoapRequest.Response`, so adding a new
//  web service needs no code here.
//
//  The legacy API (delegates)
//  --------------------------
//  `MFBWebServiceSoap12Binding` at the bottom of this file keeps the WSDLToObjC style
//  (`binding.getCurrencyForUserAsync(usingParameters:delegate:)`) working for code that has not migrated yet.
//

import Foundation

// MARK: - SoapClient

open class SoapClient : NSObject {
    /// The standard path of the MyFlightbook web service on a host
    public static let defaultPath = "/logbook/public/WebService.asmx"
    /// Sent as the User-Agent.  (The original wsdl2objc code sent "wsdl2objc"; the server doesn't care.)
    public static let defaultUserAgent = "MyFlightbook-iOS"

    /// The service endpoint.  Calls fail with `SoapError.noAddress` until this is set.
    public var address : URL?
    /// Request timeout, in seconds
    public var timeout : TimeInterval = 30
    /// Additional HTTP headers (e.g., Accept-Language)
    public var headers : [String : String] = [:]
    public var userAgent = SoapClient.defaultUserAgent
    /// Dump requests and responses to the log.  Debugging only; the log will contain auth tokens.
    public var logTraffic = false
    /// The session used to send requests.
    public var session : URLSession = .shared

    public init(address: URL?) {
        self.address = address
        super.init()
    }

    public override convenience init() {
        self.init(address: nil)
    }

    /// - Parameters:
    ///   - host: Host name (and optional port), e.g. "myflightbook.com" or "192.168.1.5:8080".  Injected by the caller.
    ///   - secure: Use https.  Local development hosts typically need false.
    public convenience init(host: String, secure: Bool = true, path: String = SoapClient.defaultPath) {
        self.init(address: SoapClient.endpoint(host: host, secure: secure, path: path))
    }

    public static func endpoint(host: String, secure: Bool = true, path: String = SoapClient.defaultPath) -> URL? {
        return URL(string: "http\(secure ? "s" : "")://\(host)\(path)")
    }

    /// Headers to send; subclasses can add to these
    open var allHeaders : [String : String] {
        return headers
    }

    // MARK: Closure API

    /// Calls a web service.
    ///
    /// - Parameters:
    ///   - request: The request.  Its type determines the type of the response.
    ///   - queue: Queue on which the closures are called.  Default is main; pass nil to be called on the network queue.
    ///   - onSuccess: Called with the response.
    ///   - onError: Called with the error (network failure, malformed response, or a server fault; for a fault, `error.localizedDescription` is the server's message).
    ///   - onComplete: Called after either of the above.
    /// - Returns: The in-flight task, if any, which can be cancelled.
    @discardableResult
    public func call<R : SoapRequest>(_ request: R,
                                      queue: DispatchQueue? = .main,
                                      onSuccess: ((R.Response) -> Void)? = nil,
                                      onError: ((SoapError) -> Void)? = nil,
                                      onComplete: (() -> Void)? = nil) -> URLSessionDataTask? {
        return call(request, queue: queue) { (result : Result<R.Response, SoapError>) in
            switch result {
            case .success(let r):
                onSuccess?(r)
            case .failure(let e):
                onError?(e)
            }
            onComplete?()
        }
    }

    /// Calls a web service, delivering a Result.
    @discardableResult
    public func call<R : SoapRequest>(_ request: R,
                                      queue: DispatchQueue? = .main,
                                      completion: @escaping (Result<R.Response, SoapError>) -> Void) -> URLSessionDataTask? {
        let deliver : (Result<R.Response, SoapError>) -> Void = { result in
            if let q = queue {
                q.async { completion(result) }
            } else {
                completion(result)
            }
        }

        guard let urlRequest = makeURLRequest(for: request) else {
            deliver(.failure(.noAddress))
            return nil
        }

        let task = session.dataTask(with: urlRequest) { [logTraffic] data, response, error in
            if logTraffic {
                NSLog("SoapClient response (%d):\n%@", (response as? HTTPURLResponse)?.statusCode ?? 0, String(data: data ?? Data(), encoding: .utf8) ?? "")
            }
            if let error {
                deliver(.failure(.transport(error)))
                return
            }
            deliver(SoapClient.parse(data ?? Data(), as: R.Response.self))
        }
        task.resume()
        return task
    }

    /// async/await flavor.  Throws `SoapError`.
    public func call<R : SoapRequest>(_ request: R) async throws -> R.Response {
        return try await withCheckedThrowingContinuation { continuation in
            call(request, queue: nil) { (result : Result<R.Response, SoapError>) in
                continuation.resume(with: result)
            }
        }
    }

    /// One-shot call for code that doesn't keep a client around.  The host is always supplied by the caller.
    @discardableResult
    public static func call<R : SoapRequest>(_ request: R,
                                             host: String,
                                             secure: Bool = true,
                                             queue: DispatchQueue? = .main,
                                             onSuccess: ((R.Response) -> Void)? = nil,
                                             onError: ((SoapError) -> Void)? = nil,
                                             onComplete: (() -> Void)? = nil) -> URLSessionDataTask? {
        return SoapClient(host: host, secure: secure).call(request, queue: queue, onSuccess: onSuccess, onError: onError, onComplete: onComplete)
    }

    // MARK: Implementation

    private func makeURLRequest(for request: SoapObject) -> URLRequest? {
        guard let address else {
            return nil
        }
        let body = SoapWriter.envelope(for: request)
        var r = URLRequest(url: address, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeout)
        r.httpMethod = "POST"
        r.httpBody = body.data(using: .utf8)
        r.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        r.setValue("\(SoapNamespace.service)\(type(of: request).soapElementName)", forHTTPHeaderField: "SOAPAction")
        r.setValue("application/soap+xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        for (k, v) in allHeaders {
            r.setValue(v, forHTTPHeaderField: k)
        }
        if logTraffic {
            NSLog("SoapClient request headers:\n%@\nbody:\n%@", r.allHTTPHeaderFields ?? [:], body)
        }
        return r
    }

    /// Interprets a response body: the expected response element, or a Fault
    static func parse<T : SoapObject>(_ data: Data, as type: T.Type) -> Result<T, SoapError> {
        let root : SoapXMLNode
        do {
            root = try SoapXMLNode.parse(data)
        } catch {
            return .failure(.malformedResponse("Errors while parsing returned XML"))
        }
        guard let body = root.child("Body") else {
            return .failure(.malformedResponse("The response did not contain a SOAP body"))
        }
        if let fault = body.child("Fault") {
            return .failure(.fault(SOAPFault.parse(fault)))
        }
        guard let node = body.child(T.soapElementName), let result = SoapObject.make(T.self, from: node) else {
            return .failure(.malformedResponse("The response did not contain \(T.soapElementName)"))
        }
        return .success(result)
    }
}

// MARK: - Legacy (delegate-based) API

@objc public protocol MFBWebServiceSoap12BindingResponseDelegate : NSObjectProtocol {
    @objc(operation:completedWithResponse:)
    func operation(_ operation: MFBWebServiceSoap12BindingOperation!, completedWith response: MFBWebServiceSoap12BindingResponse!)
}

/// What the legacy delegate gets back: the parsed body (`bodyParts`: the response object, or a SOAPFault) and/or an error.
@objc public class MFBWebServiceSoap12BindingResponse : NSObject {
    @objc public var headers : NSArray! = []
    @objc public var bodyParts : NSArray! = []
    @objc public var error : NSError!
}

/// Handle for an in-flight legacy call.
@objc public class MFBWebServiceSoap12BindingOperation : NSObject {
    @objc public fileprivate(set) var binding : MFBWebServiceSoap12Binding!
    fileprivate var task : URLSessionDataTask?

    @objc public func cancel() {
        task?.cancel()
    }
}

/// Drop-in for the WSDLToObjC binding class.  Set `address` (and optionally `timeout`, `customHeaders`, `logXMLInOut`) and call
/// the xxxAsync(usingParameters:delegate:) methods.  New code should prefer the closure API of `SoapClient`.
///
/// The delegate is called on a background thread, and is retained until the call completes.
public class MFBWebServiceSoap12Binding : SoapClient {
    /// Legacy name for `headers`
    @objc public var customHeaders = NSMutableDictionary()
    /// Legacy name for `logTraffic`
    public var logXMLInOut : Bool {
        get { return logTraffic }
        set { logTraffic = newValue }
    }

    public override init(address: URL?) {
        super.init(address: address)
        timeout = MFBWebServiceSoap12Binding.defaultTimeout
        userAgent = "wsdl2objc"
    }

    public static var defaultTimeout : TimeInterval { return 10 }

    public override var allHeaders : [String : String] {
        var h = headers
        for (k, v) in customHeaders {
            if let k = k as? String, let v = v as? String {
                h[k] = v
            }
        }
        return h
    }

    /// Sends a request and reports the result to a legacy delegate.
    public func send<R : SoapRequest>(_ request: R, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        let op = MFBWebServiceSoap12BindingOperation()
        op.binding = self
        op.task = call(request, queue: nil) { (result : Result<R.Response, SoapError>) in
            let response = MFBWebServiceSoap12BindingResponse()
            switch result {
            case .success(let body):
                response.bodyParts = [body]
            case .failure(.fault(let fault)):
                response.bodyParts = [fault]
            case .failure(let e):
                response.error = NSError(domain: "MFBWebServiceSoap12BindingResponseXML", code: 1,
                                         userInfo: [NSLocalizedDescriptionKey: e.localizedDescription])
            }
            op.binding = nil
            delegate?.operation(op, completedWith: response)
        }
    }
}

// The 41 operations of the service.  Each one is just the generic `send`; the response type comes from the request class.
extension MFBWebServiceSoap12Binding {
    public func aircraftForUserAsync(usingParameters p : MFBWebServiceSvc_AircraftForUser, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func addAircraftForUserAsync(usingParameters p : MFBWebServiceSvc_AddAircraftForUser, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func aircraftMatchingPrefixAsync(usingParameters p : MFBWebServiceSvc_AircraftMatchingPrefix, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func updateMaintenanceForAircraftAsync(usingParameters p : MFBWebServiceSvc_UpdateMaintenanceForAircraft, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func updateMaintenanceForAircraftWithFlagsAndNotesAsync(usingParameters p : MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func deleteAircraftForUserAsync(usingParameters p : MFBWebServiceSvc_DeleteAircraftForUser, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func makesAndModelsAsync(usingParameters p : MFBWebServiceSvc_MakesAndModels, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func modelsWithIDsAsync(usingParameters p : MFBWebServiceSvc_ModelsWithIDs, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func getCurrencyForUserAsync(usingParameters p : MFBWebServiceSvc_GetCurrencyForUser, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func totalsForUserAsync(usingParameters p : MFBWebServiceSvc_TotalsForUser, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func totalsForUserWithQueryAsync(usingParameters p : MFBWebServiceSvc_TotalsForUserWithQuery, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func visitedAirportsAsync(usingParameters p : MFBWebServiceSvc_VisitedAirports, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func flightsWithQueryAndOffsetAsync(usingParameters p : MFBWebServiceSvc_FlightsWithQueryAndOffset, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func flightsWithQueryAsync(usingParameters p : MFBWebServiceSvc_FlightsWithQuery, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func deleteLogbookEntryAsync(usingParameters p : MFBWebServiceSvc_DeleteLogbookEntry, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func commitFlightWithOptionsAsync(usingParameters p : MFBWebServiceSvc_CommitFlightWithOptions, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func flightPathForFlightAsync(usingParameters p : MFBWebServiceSvc_FlightPathForFlight, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func flightPathForFlightGPXAsync(usingParameters p : MFBWebServiceSvc_FlightPathForFlightGPX, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func checkFlightAsync(usingParameters p : MFBWebServiceSvc_CheckFlight, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func autofillFlightAsync(usingParameters p : MFBWebServiceSvc_AutofillFlight, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func initFlightFromFlightDeckScanAsync(usingParameters p : MFBWebServiceSvc_InitFlightFromFlightDeckScan, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func createPendingFlightAsync(usingParameters p : MFBWebServiceSvc_CreatePendingFlight, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func pendingFlightsForUserAsync(usingParameters p : MFBWebServiceSvc_PendingFlightsForUser, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func updatePendingFlightAsync(usingParameters p : MFBWebServiceSvc_UpdatePendingFlight, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func deletePendingFlightAsync(usingParameters p : MFBWebServiceSvc_DeletePendingFlight, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func commitPendingFlightAsync(usingParameters p : MFBWebServiceSvc_CommitPendingFlight, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func availablePropertyTypesAsync(usingParameters p : MFBWebServiceSvc_AvailablePropertyTypes, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func availablePropertyTypesForUserAsync(usingParameters p : MFBWebServiceSvc_AvailablePropertyTypesForUser, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func propertiesAndTemplatesForUserAsync(usingParameters p : MFBWebServiceSvc_PropertiesAndTemplatesForUser, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func propertiesForFlightAsync(usingParameters p : MFBWebServiceSvc_PropertiesForFlight, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func deletePropertiesForFlightAsync(usingParameters p : MFBWebServiceSvc_DeletePropertiesForFlight, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func deletePropertyForFlightAsync(usingParameters p : MFBWebServiceSvc_DeletePropertyForFlight, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func deleteImageAsync(usingParameters p : MFBWebServiceSvc_DeleteImage, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func updateImageAnnotationAsync(usingParameters p : MFBWebServiceSvc_UpdateImageAnnotation, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func authTokenForUserAsync(usingParameters p : MFBWebServiceSvc_AuthTokenForUser, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func authTokenForUserNewAsync(usingParameters p : MFBWebServiceSvc_AuthTokenForUserNew, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func refreshAuthTokenAsync(usingParameters p : MFBWebServiceSvc_RefreshAuthToken, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func createUserAsync(usingParameters p : MFBWebServiceSvc_CreateUser, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func getNamedQueriesForUserAsync(usingParameters p : MFBWebServiceSvc_GetNamedQueriesForUser, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func addNamedQueryForUserAsync(usingParameters p : MFBWebServiceSvc_AddNamedQueryForUser, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
    public func deleteNamedQueryForUserAsync(usingParameters p : MFBWebServiceSvc_DeleteNamedQueryForUser, delegate: MFBWebServiceSoap12BindingResponseDelegate?) {
        send(p, delegate: delegate)
    }
}

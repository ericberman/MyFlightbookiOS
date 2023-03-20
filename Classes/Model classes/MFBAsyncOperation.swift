//
//  MFBAsyncOperation.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/13/23.
//

import Foundation

@objc public class MFBAsyncOperation : NSObject {
    @objc public var delegate : AnyObject? = nil
    @objc public var completionBlock : ((MFBSoapCall?, MFBAsyncOperation) -> Void)? = nil
    
    @objc public func operationCompleted(_ sc : MFBSoapCall?) {
        if delegate != nil && completionBlock != nil {
            completionBlock!(sc, self)
        }
        delegate = nil          // save memory by reducing an extra retain.
        completionBlock = nil   // also release the completion block to avoid a cycle
    }
    
    @objc public func setDelegate(_ o : AnyObject, completionBlock compBlock : @escaping ((MFBSoapCall?, MFBAsyncOperation) -> Void)) {
        delegate = o
        completionBlock = compBlock
    }
}

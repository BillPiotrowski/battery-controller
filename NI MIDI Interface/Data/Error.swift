//
//  Error.swift
//  RPG Music
//
//  Created by William Piotrowski on 4/28/19.
//  Copyright © 2019 William Piotrowski. All rights reserved.
//

import Foundation



protocol ScorepioError: LocalizedError {
    var message: String { get }
}
extension ScorepioError {
    var errorDescription: String? {return message }
    //var failureReason: String? {return message }
    //var helpAnchor: String? {return message }
    //var recoverySuggestion: String? {return message }
}

/*

// https://firebase.google.com/docs/reference/functions/functions.https.HttpsError
struct FirebaseFunctionError {
    // https://github.com/googleapis/googleapis/blob/master/google/rpc/code.proto
    let code: Int
    let message: String
    let details: AnyHashable?
    let domain: String
    
    init(
        code: Int,
        message: String,
        details: AnyHashable?,
        domain: String
        ){
        self.code = code
        self.message = message
        self.details = details
        self.domain = domain
    }
    
    init(_ error: Error){
        let nsError = error as NSError
        let code = nsError.code
        let domain = nsError.domain
        let message = nsError.localizedDescription
        let details = nsError.userInfoDictionary["details"] as? AnyHashable
        self.init(
            code: code,
            message: message,
            details: details,
            domain: domain
        )
    }
}
extension FirebaseFunctionError {
    var detailsInt: Int? {
        return details as? Int
    }
}
*/




extension NSError {
    var userInfoDictionary: [String: Any] {
        let nsDictionary = userInfo as NSDictionary
        return nsDictionary as? Dictionary<String,Any> ?? [:]
    }
}





// LEARN TO USE PROTOCOL BUFFERS!!!!!
// POSSIBLY USE THESE AS TYPES FOR ALL ERRORS??


//syntax = "proto3";
//package google.rpc;
//option go_package = "google.golang.org/genproto/googleapis/rpc/code;code";
// The canonical error codes for Google APIs.
//
//
//enum Code {
enum GoogleErrorCode: Int {
    // Not an error; returned on success
    //
    // HTTP Mapping: 200 OK
    //OK = 0;
    case OK = 0
    
    // The operation was cancelled, typically by the caller.
    //
    // HTTP Mapping: 499 Client Closed Request
    //CANCELLED = 1;
    case CANCELLED = 1
    
    // Unknown error.  For example, this error may be returned when
    // a `Status` value received from another address space belongs to
    // an error space that is not known in this address space.  Also
    // errors raised by APIs that do not return enough error information
    // may be converted to this error.
    //
    // HTTP Mapping: 500 Internal Server Error
    //UNKNOWN = 2;
    case UNKNOWN = 2
    
    // The client specified an invalid argument.  Note that this differs
    // from `FAILED_PRECONDITION`.  `INVALID_ARGUMENT` indicates arguments
    // that are problematic regardless of the state of the system
    // (e.g., a malformed file name).
    //
    // HTTP Mapping: 400 Bad Request
    //INVALID_ARGUMENT = 3;
    case INVALID_ARGUMENT = 3
    
    // The deadline expired before the operation could complete. For operations
    // that change the state of the system, this error may be returned
    // even if the operation has completed successfully.  For example, a
    // successful response from a server could have been delayed long
    // enough for the deadline to expire.
    //
    // HTTP Mapping: 504 Gateway Timeout
    //DEADLINE_EXCEEDED = 4;
    case DEADLINE_EXCEEDED = 4
    
    // Some requested entity (e.g., file or directory) was not found.
    //
    // Note to server developers: if a request is denied for an entire class
    // of users, such as gradual feature rollout or undocumented whitelist,
    // `NOT_FOUND` may be used. If a request is denied for some users within
    // a class of users, such as user-based access control, `PERMISSION_DENIED`
    // must be used.
    //
    // HTTP Mapping: 404 Not Found
    //NOT_FOUND = 5;
    case NOT_FOUND = 5
    
    // The entity that a client attempted to create (e.g., file or directory)
    // already exists.
    //
    // HTTP Mapping: 409 Conflict
    //ALREADY_EXISTS = 6;
    case ALREADY_EXISTS = 6
    
    // The caller does not have permission to execute the specified
    // operation. `PERMISSION_DENIED` must not be used for rejections
    // caused by exhausting some resource (use `RESOURCE_EXHAUSTED`
    // instead for those errors). `PERMISSION_DENIED` must not be
    // used if the caller can not be identified (use `UNAUTHENTICATED`
    // instead for those errors). This error code does not imply the
    // request is valid or the requested entity exists or satisfies
    // other pre-conditions.
    //
    // HTTP Mapping: 403 Forbidden
    //PERMISSION_DENIED = 7;
    case PERMISSION_DENIED = 7
    
    // The request does not have valid authentication credentials for the
    // operation.
    //
    // HTTP Mapping: 401 Unauthorized
    //UNAUTHENTICATED = 16;
    case UNAUTHENTICATED = 16
    
    // Some resource has been exhausted, perhaps a per-user quota, or
    // perhaps the entire file system is out of space.
    //
    // HTTP Mapping: 429 Too Many Requests
    //RESOURCE_EXHAUSTED = 8;
    case RESOURCE_EXHAUSTED = 8
    
    // The operation was rejected because the system is not in a state
    // required for the operation's execution.  For example, the directory
    // to be deleted is non-empty, an rmdir operation is applied to
    // a non-directory, etc.
    //
    // Service implementors can use the following guidelines to decide
    // between `FAILED_PRECONDITION`, `ABORTED`, and `UNAVAILABLE`:
    //  (a) Use `UNAVAILABLE` if the client can retry just the failing call.
    //  (b) Use `ABORTED` if the client should retry at a higher level
    //      (e.g., when a client-specified test-and-set fails, indicating the
    //      client should restart a read-modify-write sequence).
    //  (c) Use `FAILED_PRECONDITION` if the client should not retry until
    //      the system state has been explicitly fixed.  E.g., if an "rmdir"
    //      fails because the directory is non-empty, `FAILED_PRECONDITION`
    //      should be returned since the client should not retry unless
    //      the files are deleted from the directory.
    //
    // HTTP Mapping: 400 Bad Request
    //FAILED_PRECONDITION = 9;
    case FAILED_PRECONDITION = 9
    
    // The operation was aborted, typically due to a concurrency issue such as
    // a sequencer check failure or transaction abort.
    //
    // See the guidelines above for deciding between `FAILED_PRECONDITION`,
    // `ABORTED`, and `UNAVAILABLE`.
    //
    // HTTP Mapping: 409 Conflict
    //ABORTED = 10;
    case ABORTED = 10
    
    // The operation was attempted past the valid range.  E.g., seeking or
    // reading past end-of-file.
    //
    // Unlike `INVALID_ARGUMENT`, this error indicates a problem that may
    // be fixed if the system state changes. For example, a 32-bit file
    // system will generate `INVALID_ARGUMENT` if asked to read at an
    // offset that is not in the range [0,2^32-1], but it will generate
    // `OUT_OF_RANGE` if asked to read from an offset past the current
    // file size.
    //
    // There is a fair bit of overlap between `FAILED_PRECONDITION` and
    // `OUT_OF_RANGE`.  We recommend using `OUT_OF_RANGE` (the more specific
    // error) when it applies so that callers who are iterating through
    // a space can easily look for an `OUT_OF_RANGE` error to detect when
    // they are done.
    //
    // HTTP Mapping: 400 Bad Request
    //OUT_OF_RANGE = 11;
    case OUT_OF_RANGE = 11
    
    // The operation is not implemented or is not supported/enabled in this
    // service.
    //
    // HTTP Mapping: 501 Not Implemented
    //UNIMPLEMENTED = 12;
    case UNIMPLEMENTED = 12
    
    // Internal errors.  This means that some invariants expected by the
    // underlying system have been broken.  This error code is reserved
    // for serious errors.
    //
    // HTTP Mapping: 500 Internal Server Error
    //INTERNAL = 13;
    case INTERNAL = 13
    
    // The service is currently unavailable.  This is most likely a
    // transient condition, which can be corrected by retrying with
    // a backoff.
    //
    // See the guidelines above for deciding between `FAILED_PRECONDITION`,
    // `ABORTED`, and `UNAVAILABLE`.
    //
    // HTTP Mapping: 503 Service Unavailable
    //UNAVAILABLE = 14;
    case UNAVAILABLE = 14
    
    // Unrecoverable data loss or corruption.
    //
    // HTTP Mapping: 500 Internal Server Error
    //DATA_LOSS = 15;
    case DATA_LOSS = 15
}
extension GoogleErrorCode: ScorepioError {
    var message: String {
        switch self {
        case .OK:
            return "Not an error"
        case .CANCELLED:
            return "The operation was cancelled."
        case .UNKNOWN:
            return "There was an unknown error."
        case .INVALID_ARGUMENT:
            return "An invalid argument was sent."
        case .DEADLINE_EXCEEDED:
            return "Timeout on request."
        case .NOT_FOUND:
            return "Item not found."
        case .ALREADY_EXISTS:
            return "Entity already exists."
        case .PERMISSION_DENIED:
            return "Access denied for request."
        case .UNAUTHENTICATED:
            return "The request does not have valid authentication credentials for the operation."
        case .RESOURCE_EXHAUSTED:
            return "Resource has been exhausted."
        case .FAILED_PRECONDITION:
            return "Could not complete request because preconditions were not met."
        case .ABORTED:
            return "The operation was aborted."
        case .OUT_OF_RANGE:
            return "The operation is out of range."
        case .UNIMPLEMENTED:
            return "The operation is not implemented or is not supported/enabled in this service."
        case .INTERNAL:
            return "There was an internal error."
        case .UNAVAILABLE:
            return "The service is unavailable."
        case .DATA_LOSS:
            return "There was serious data loss."
        }
    }
}

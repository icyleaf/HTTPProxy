import Foundation

public struct KeyValuePair {
    let key: String
    let value: String?
    
    init(_ key: String, _ value: String? = nil) {
        self.key = key
        self.value = value
    }
}

extension KeyValuePair: Equatable {
    public static func == (lhs: KeyValuePair, rhs: KeyValuePair) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}

public struct RequestFilter {
    public var httpMethod: String?
    public var scheme: String?
    public var host: String?
    public var port: Int?
    public var queryItems: [KeyValuePair]?
    public var headerFields: [KeyValuePair]?
    
    init(httpMethod: String? = nil, scheme: String? = nil, host: String? = nil, port: Int? = nil,
         queryItems: [KeyValuePair]? = nil, headerFields: [KeyValuePair]? = nil) {
        self.httpMethod = httpMethod
        self.scheme = scheme
        self.host = host
        self.port = port
        self.queryItems = queryItems
        self.headerFields = headerFields
    }
}

public class HTTPProxyFilter {
    public var name: String
    public var enabled = false
    public var requestFilter: RequestFilter

    public init(name: String, requestFilter: RequestFilter) {
        self.name = name
        self.requestFilter = requestFilter
    }
}

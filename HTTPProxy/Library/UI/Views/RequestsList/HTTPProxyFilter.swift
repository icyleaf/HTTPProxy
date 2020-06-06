import Foundation

public struct RequestFilter {
    public var httpMethod: String?
    public var scheme: String?
    public var host: String?
    public var port: Int?
    public var queryItems: [(name: String, value: String?)]?
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

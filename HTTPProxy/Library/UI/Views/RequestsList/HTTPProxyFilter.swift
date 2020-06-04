import Foundation

public class HTTPProxyFilter {
    public var name: String
    public var enabled = false
    public var scheme: String?
    public var httpMethod: String?
    public var host: String?
    public var port: Int?
    
    public init(name: String) {
        self.name = name
    }
}

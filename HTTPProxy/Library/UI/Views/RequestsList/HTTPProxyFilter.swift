import Foundation

public class HTTPProxyFilter {
    var name: String
    var enabled = false
    var scheme: String?
    var host: String?
    var port: Int?
    
    init(name: String) {
        self.name = name
    }
}

import Foundation

public class HTTPRequest {

    public let request: URLRequest
    public let requestDate: Date
    public var response: HTTPResponse?
    public var responseDate: Date?
    public var requestBodyData: Data? {
        if let httpBody = request.httpBody {
            return httpBody
        }
        if let httpBodyStream = request.httpBodyStream {
            return Data(reading: httpBodyStream)
        }
        return nil
    }

    public var requestBodyString: String? {
        
        guard let bodyData = requestBodyData else {
            return nil
        }
        
        if let jsonString = bodyData.toJsonString() {
            return jsonString
        }

        return bodyData.toString()
    }
    
    init(request: URLRequest) {
        self.request = request
        self.requestDate = Date()
    }
}

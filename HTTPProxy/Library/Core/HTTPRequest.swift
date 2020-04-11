import Foundation

class HTTPRequest {

    let request: URLRequest!
    let requestDate: Date!
    var response: HTTPResponse?
    var responseDate: Date?
    var requestBodyData: Data? {
        if let httpBody = request.httpBody {
            return httpBody
        }
        if let httpBodyStream = request.httpBodyStream {
            return Data(reading: httpBodyStream)
        }
        return nil
    }

    var requestBodyString: String? {
        
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

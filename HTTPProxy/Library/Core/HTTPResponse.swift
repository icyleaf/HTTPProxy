import Foundation

enum HTTPResponse {
    case success(response: HTTPURLResponse, data: Data?)
    case failure(response: HTTPURLResponse?, error: Error?)
    
    var urlResponse: HTTPURLResponse? {
        switch self {
        case .success(let response, _):
            return response
        case .failure(let response, _):
            return response
        }
    }
    
    var responseData: Data? {
        guard case .success(_, let data) = self else {
            return nil
        }
        
        return data
    }
    
    var responseString: String? {
        guard let urlResponse = urlResponse, let responseData = responseData else {
            return nil
        }
        if let jsonString = responseData.toJsonString() {
            return jsonString
        }
        
        //urlResponse.textEncodingName
        return responseData.toString(encoding: .utf8)
    }
}

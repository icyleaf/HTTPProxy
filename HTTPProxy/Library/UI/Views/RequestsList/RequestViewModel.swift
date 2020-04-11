import Foundation
import UIKit

struct RequestViewModel: SearchableListItem {

    let request: HTTPRequest

    var value: String {
        var urlComponents = URLComponents(url: request.request.url!, resolvingAgainstBaseURL: false)!
            urlComponents.query = nil
        return "\(urlComponents)"
    }

    var key: String {
        let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "HH:mm:ss.SSS"
       let date = dateFormatter.string(from: request.requestDate)
       return date
    }

    var method: String? {
        return String(request.request.httpMethod ?? "")
    }

    var requestStatus: RequestStatus? {
        if let statusCode = statusCode {
            return .completed(statusCode: statusCode)
        }
        if error != nil {
            return .error
        }
        return .loading
    }
    
    var statusCode: Int? {
        if case .success(let request, _) = request.response {
            return request.statusCode
        } else if case .failure(let request, _) = request.response {
            return request?.statusCode
        }
        return nil
    }
    
    private var error: Error? {
        if case .failure(_, let error) = request.response {
            return error
        }
        return nil
    }
}

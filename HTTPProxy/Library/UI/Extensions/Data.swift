import Foundation

extension Data {

    func toJson() -> Any? {
        let jsonObject = try? JSONSerialization.jsonObject(with: self, options: .allowFragments)
        return jsonObject
    }
    
    func toJsonString() -> String? {
        guard let jsonObject = self.toJson() else {
            return nil
        }
        return prettyPrintedJSONObject(jsonObject)
    }
    
    func toString(encoding: String.Encoding = .utf8) -> String? {
        let str = String(data: self, encoding: encoding)
        return str?.removingPercentEncoding
    }
    
    private func prettyPrintedJSONObject(_ jsonObject: Any) -> String? {
        guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
            let jsonString = prettyJsonData.toString() else {
                return nil
        }

        return jsonString
    }
}

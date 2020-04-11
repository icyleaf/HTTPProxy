import UIKit

class ViewController: UIViewController {

    @IBOutlet private var intervalLabel: UILabel!
    @IBOutlet private var darkModeSwitch: UISwitch!
    var timer: Timer?
    var interval: Float = 5.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        HTTPProxy.shared.enable()
        darkModeSwitch.isOn = darkModeEnabled()
        
        self.sendRequest(self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showMonitor(self)
        }
    }

    @IBAction func showMonitor(_ sender: Any) {
        
        HTTPProxy.shared.presentViewController()
    }
    
    @IBAction func sendRequest(_ sender: Any) {
        sendTestRequests()
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        interval = sender.value/10
        let str = String(format: "%.01f", interval)
        intervalLabel.text = str
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.interval), repeats: true) { _ in
                self.sendTestRequests()
            }
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @IBAction func darkModeSwitchChanged(_ sender: UISwitch) {
        HTTPProxyPresenter.shared.colorScheme = sender.isOn ? DarkColorScheme() : LightColorScheme()
    }
    
    func darkModeEnabled() -> Bool {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
        return false
    }
    
    func sendTestRequests() {
        sendGet()
        sendPut()
        sendPost()
        sendDelete()
        sendPatch()
        sendXml()
        sendHtml()
    }
    
    func sendPost() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        var request = URLRequest(url: url)

        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json asjfaie ajaoisdijasi ajeooo o", forHTTPHeaderField: "Accept")
        request.addValue("application/json amsdfija adfaj sdfsdf sfsdfsdf dfsefe efsefsasfae sfawefasefa", forHTTPHeaderField: "sdf howih whhohw owui ich soannaan asda")

        /*
        components.queryItems = [
            URLQueryItem(name: "key1", value: "NeedToEscape=And&"),
            URLQueryItem(name: "key2", value: "vålüé")
        ]
 */
        request.httpMethod = "POST"
        let json: [String: Any] = ["foo": "bar",
                                   "abc": ["1": "First", "2": "Second"]]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        sendRequest(request)
    }
    
    func sendPut() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        var request = URLRequest(url: url)

        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        // request.addValue("application/json", forHTTPHeaderField: "Accept")
        /*
        components.queryItems = [
           URLQueryItem(name: "key1", value: "NeedToEscape=And&"),
           URLQueryItem(name: "key2", value: "vålüé")
        ]
        */
        request.httpMethod = "PUT"
        let json: [String: Any] = ["foo": "bar",
                                  "abc": ["1": "First", "2": "Second"]]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        sendRequest(request)
    }
    
    func sendPatch() {
      let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
      var request = URLRequest(url: url)

      request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
      request.httpMethod = "PUT"
      let json: [String: Any] = ["title": "bar"]
      let jsonData = try? JSONSerialization.data(withJSONObject: json)
      request.httpBody = jsonData
      sendRequest(request)
    }

    func sendGet() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts?userId=1")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        sendRequest(request)
    }
    
    func sendDelete() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/0")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        sendRequest(request)
    }
    
    func sendXml() {
        let url = URL(string: "https://schemas.xmlsoap.org/soap/envelope/")!
        let request = URLRequest(url: url)
        sendRequest(request)
    }
    
    func sendHtml() {
        // let url = URL(string: "https://raw.githubusercontent.com/GoogleChrome/samples/gh-pages/index.html")!
        let url = URL(string: "https://raw.githubusercontent.com/GoogleChrome/samples/gh-pages/.travis.yml")!
        
         let request = URLRequest(url: url)
         sendRequest(request)
     }
    
    func sendRequest(_ request: URLRequest) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        }
    }
}

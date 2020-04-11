import Foundation

extension Data {

    private static let bufferSize = 1024

    init(reading input: InputStream) {
        self.init()

        input.open()
        defer {
            input.close()
        }

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Data.bufferSize)
        defer {
            buffer.deallocate()
        }

        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: Data.bufferSize)
            self.append(buffer, count: read)
        }
    }
}

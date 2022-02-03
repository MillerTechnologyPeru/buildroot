import Foundation
import Dispatch
import Glibc

func main() async throws {
    print("Hello, world! 👋")
    try await Task.sleep(1_000_000_000)
    print("User: \(ProcessInfo.processInfo.fullUserName)")
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    dateFormatter.timeStyle = .medium
    print(dateFormatter.string(from: Date()))
    throw URLError(.unknown)
}

let task = Task {
    try await main()
}

RunLoop.main.run(until: Date() + 2)

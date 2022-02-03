import Foundation
import Dispatch
import Glibc

func main() {
    print("Hello, world! 👋")
    print("User: \(ProcessInfo.processInfo.fullUserName)")
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    dateFormatter.timeStyle = .medium
    print(dateFormatter.string(from: Date()))
}

main()

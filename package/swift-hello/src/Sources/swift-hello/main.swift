#if canImport(Foundation)
import Foundation
#endif
#if canImport(Dispatch)
import Dispatch
#endif
import Glibc

func main() {
    var greeting = "Hello, world! 👋"
    #if canImport(Foundation)
    greeting += " " + ProcessInfo.processInfo.fullUserName
    greeting += " (\(Date()))"
    #endif
    print(greeting)
}

#if canImport(Dispatch)
DispatchQueue.global().async {
    main()
}
sleep(1)
#else
main()
#endif


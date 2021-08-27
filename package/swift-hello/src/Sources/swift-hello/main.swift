#if canImport(Foundation)
import Foundation
#endif
#if canImport(Dispatch)
import Dispatch
#endif
import Glibc

func main() {
    #if canImport(Foundation)
    let dateFormatter = DateFormatter()
    let date = dateFormatter.stringFromDate(Date())
    print("Hello, world! 👋 \(date)")
    #else
    print("Hello, world! 👋")
    #endif
}

#if canImport(Dispatch)
DispatchQueue.global().async {
    main()
}
sleep(1)
#else
main()
#endif


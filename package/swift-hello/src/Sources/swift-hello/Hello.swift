import Foundation

@main
struct Hello {
    static func main() async throws {
        print("Hello, world! 👋")
        let task = Task {
            var didCatchError = false
            do { try await errorTest() }
            catch URLError.unknown { didCatchError = true }
            catch { fatalError() }
            print("Task ran")
        }
        try! await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

func errorTest() async throws {
    print("Will throw")
    throw URLError(.unknown)
}


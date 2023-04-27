final class SpyConsoleService: ConsoleServiceProtocol {
    var printedMessage: [String] = []
    var testInput: [String?] = []

    func printMessage(_ message: String) {
        printedMessage.append(message)
    }

    func readMultipleStrings(count: Int) throws -> [String] {
        guard let line = testInput.removeFirst() else {
            throw ConsoleServiceError.inputError
        }
        let strings = line.components(separatedBy: " ")
        guard strings.count == count else {
            throw ConsoleServiceError.inputError
        }
        return strings
    }
}

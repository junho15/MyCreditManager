import Foundation

protocol ConsoleServiceProtocol {
    func printMessage(_ message: String)
    func readMultipleStrings(count: Int) throws -> [String]
}

final class ConsoleService: ConsoleServiceProtocol {
    func printMessage(_ message: String) {
        print(message)
    }

    func readMultipleStrings(count: Int) throws -> [String] {
        guard let line = readLine() else {
            throw ConsoleServiceError.inputError
        }
        let strings = line.components(separatedBy: " ")
        guard strings.count == count else {
            throw ConsoleServiceError.inputError
        }
        return strings
    }
}

enum ConsoleServiceError: Error {
    case inputError

    var localizedDescription: String {
        switch self {
        case .inputError:
            return "입력이 잘못되었습니다. 다시 확인해주세요."
        }
    }
}

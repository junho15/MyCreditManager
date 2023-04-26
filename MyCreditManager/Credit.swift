// swiftlint:disable identifier_name
enum Credit: String {
    case aPlus = "A+"
    case a = "A"
    case bPlus = "B+"
    case b = "B"
    case cPlus = "C+"
    case c = "C"
    case dPlus = "D+"
    case d = "D"
    case f = "F"

    var score: Double {
        switch self {
        case .aPlus:
            return 4.5
        case .a:
            return 4.0
        case .bPlus:
            return 3.5
        case .b:
            return 3.0
        case .cPlus:
            return 2.5
        case .c:
            return 2.0
        case .dPlus:
            return 1.5
        case .d:
            return 1.0
        case .f:
            return 0.0
        }
    }
}
// swiftlint:enable identifier_name

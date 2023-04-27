import Foundation

final class CreditManager {

    // MARK: Properties

    private let studentCreditService: StudentCreditService
    private let consoleService: ConsoleService

    init(studentCreditService: StudentCreditService = StudentCreditService(),
         consoleService: ConsoleService = ConsoleService()) {
        self.studentCreditService = studentCreditService
        self.consoleService = consoleService
    }

    func start() {
        var selectedMenu: Menu?
        while selectedMenu != .exit {
            selectedMenu = selectMenu()
            guard let selectedMenu else { continue }
            startAction(for: selectedMenu)
        }
        consoleService.printMessage(PromptsMessage.exit)
    }

    // MARK: Methods

    private func selectMenu() -> Menu? {
        printMenu()
        do {
            return try readMenu()
        } catch {
            consoleService.printMessage(PromptsMessage.invalidMenu)
            return nil
        }
    }

    private func startAction(for menu: Menu) {
        do {
            switch menu {
            case .addStudent:
                try addStudent()
            case .deleteStudent:
                try deleteStudent()
            case .updateCredit:
                try updateCredit()
            case .deleteCredit:
                try deleteCredit()
            case .searchCredits:
                try searchCredits()
            case .exit:
                break
            }
        } catch let error as StudentCreditService.StudentCreditServiceError {
            consoleService.printMessage(error.localizedDescription)
        } catch let error as ConsoleServiceError {
            consoleService.printMessage(error.localizedDescription)
        } catch {
            consoleService.printMessage(error.localizedDescription)
        }
    }
}

// MARK: - Console Service

extension CreditManager {
    private func printMenu() {
        var message = PromptsMessage.selectMenu + "\n"
        message += Menu.allCases.reduce(into: [String]()) { result, menu in
            result.append("\(menu.rawValue): \(menu.description)")
        }.joined(separator: ", ")
        consoleService.printMessage(message)
    }

    private func readMenu() throws -> Menu {
        let input = try consoleService.readMultipleStrings(count: 1)
        guard let menu =  Menu(rawValue: input[0]) else {
            throw ConsoleServiceError.inputError
        }
        return menu
    }

    private func readStudentName() throws -> String {
        let input = try consoleService.readMultipleStrings(count: 1)
        let name = input[0]
        if name.isEmpty == false,
           isAlphanumerics(name) {
            return name
        } else {
            throw ConsoleServiceError.inputError
        }
    }

    // swiftlint:disable large_tuple
    private func readStudentNameSubjectNameCredit() throws -> (studentName: String,
                                                               subjectName: String,
                                                               credit: Credit) {
        let input = try consoleService.readMultipleStrings(count: 3)
        let studentName = input[0]
        let subjectName = input[1]
        if let credit = Credit(rawValue: input[2]),
           studentName.isEmpty == false,
           isAlphanumerics(studentName),
           subjectName.isEmpty == false,
           isAlphanumerics(subjectName) {
            return (studentName, subjectName, credit)
        } else {
            throw ConsoleServiceError.inputError
        }
    }
    // swiftlint:enable large_tuple

    private func readStudentNameSubjectName() throws -> (studentName: String, subjectName: String) {
        let input = try consoleService.readMultipleStrings(count: 2)
        let studentName = input[0]
        let subjectName = input[1]
        if studentName.isEmpty == false,
           isAlphanumerics(studentName),
           subjectName.isEmpty == false,
           isAlphanumerics(subjectName) {
            return (studentName, subjectName)
        } else {
            throw ConsoleServiceError.inputError
        }
    }

    private func isAlphanumerics(_ string: String) -> Bool {
        let allowedCharacterSet = [CharacterSet.uppercaseLetters,
                                   CharacterSet.lowercaseLetters,
                                   CharacterSet.decimalDigits].reduce(CharacterSet()) { $0.union($1) }
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: characterSet)
    }
}

// MARK: - Menu Action

extension CreditManager {
    private func addStudent() throws {
        consoleService.printMessage(PromptsMessage.addStudent)
        let name = try readStudentName()
        let student = Student(name: name)
        try studentCreditService.addStudent(student)
        consoleService.printMessage(SuccessMessage.addStudent(name: name).message)
    }

    private func deleteStudent() throws {
        consoleService.printMessage(PromptsMessage.deleteStudent)
        let name = try readStudentName()
        let student = Student(name: name)
        try studentCreditService.deleteStudent(student)
        consoleService.printMessage(SuccessMessage.deleteStudent(name: name).message)
    }

    private func updateCredit() throws {
        consoleService.printMessage(PromptsMessage.updateCredit)
        let input = try readStudentNameSubjectNameCredit()
        let student = Student(name: input.studentName)
        let subject = Subject(name: input.subjectName)
        let credit = input.credit
        try studentCreditService.updateCredit(for: student, subject: subject, credit: credit)
        consoleService.printMessage(SuccessMessage.updateCredit(studentName: input.studentName,
                                                                subjectName: input.subjectName,
                                                                credit: credit.rawValue).message)
    }

    private func deleteCredit() throws {
        consoleService.printMessage(PromptsMessage.deleteCredit)
        let input = try readStudentNameSubjectName()
        let student = Student(name: input.studentName)
        let subject = Subject(name: input.subjectName)
        try studentCreditService.deleteCredit(for: student, subject: subject)
        consoleService.printMessage(SuccessMessage.deleteCredit(studentName: input.studentName,
                                                                subjectName: input.subjectName).message)
    }

    private func searchCredits() throws {
        consoleService.printMessage(PromptsMessage.searchCredits)
        let name = try readStudentName()
        let student = Student(name: name)
        switch studentCreditService.searchCredits(for: student) {
        case .success(let result):
            let credits = result.credits.map { ($0.key.name, $0.value.rawValue) }
            let message = SuccessMessage.searchCredits(credits: credits, average: result.average).message
            print(message)
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Menu, Message

extension CreditManager {
    enum Menu: String, CaseIterable {
        case addStudent = "1"
        case deleteStudent = "2"
        case updateCredit = "3"
        case deleteCredit = "4"
        case searchCredits = "5"
        case exit = "X"

        var description: String {
            switch self {
            case .addStudent:
                return "학생추가"
            case .deleteStudent:
                return "학생삭제"
            case .updateCredit:
                return "성적추가(변경)"
            case .deleteCredit:
                return "성적삭제"
            case .searchCredits:
                return "평점보기"
            case .exit:
                return "종료"
            }
        }
    }

    enum PromptsMessage {
        static let selectMenu = "원하는 기능을 입력해주세요"
        static let invalidMenu = "뭔가 입력이 잘못되었습니다. 1~5 사이의 숫자 혹은 X를 입력해주세요."
        static let addStudent = "추가할 학생의 이름을 입력해주세요"
        static let deleteStudent = "삭제할 학생의 이름을 입력해주세요"
        static let updateCredit =
            """
            성적을 추가할 학생의 이름, 과목 이름, 성적(A+, A, F 등)을 띄어쓰기로 구분하여 차례로 작성해주세요.
            입력예) Mickey Swift A+
            만약에 학생의 성적 중 해당 과목이 존재하면 기존 점수가 갱신됩니다.
            """
        static let deleteCredit = "성적을 삭제할 학생의 이름, 과목 이름을 띄어쓰기로 구분하여 차례로 작성해주세요."
        static let searchCredits = "평점을 알고싶은 학생의 이름을 입력해주세요."
        static let exit = "프로그램을 종료합니다..."
    }

    enum SuccessMessage {
        case addStudent(name: String)
        case deleteStudent(name: String)
        case updateCredit(studentName: String, subjectName: String, credit: String)
        case deleteCredit(studentName: String, subjectName: String)
        case searchCredits(credits: [(subjectName: String, credit: String)], average: Double)

        var message: String {
            switch self {
            case .addStudent(let name):
                return "\(name) 학생을 추가했습니다."
            case .deleteStudent(let name):
                return "\(name) 학생을 삭제했습니다."
            case .updateCredit(let studentName, let subjectName, let credit):
                return "\(studentName) 학생의 \(subjectName) 과목이 \(credit)로 추가(변경)되었습니다."
            case .deleteCredit(let studentName, let subjectName):
                return "\(studentName) 학생의 \(subjectName) 과목의 성적이 삭제되었습니다."
            case .searchCredits(let credits, let average):
                return credits.reduce(into: "") { result, info in
                    result += "\(info.subjectName): \(info.credit) \n"
                } + "평점 : \(average)"
            }
        }
    }
}

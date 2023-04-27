final class StudentCreditService {
    private var studentCreditBook: [Student: [Subject: Credit]]

    init(studentCreditBook: [Student: [Subject: Credit]] = [:]) {
        self.studentCreditBook = studentCreditBook
    }

    func addStudent(_ student: Student) throws {
        guard studentCreditBook[student] == nil else {
            throw StudentCreditServiceError.duplicateStudent(name: student.name)
        }

        studentCreditBook[student] = [:]
    }

    func deleteStudent(_ student: Student) throws {
        guard studentCreditBook[student] != nil else {
            throw StudentCreditServiceError.studentNotFound(name: student.name)
        }

        studentCreditBook[student] = nil
    }

    func updateCredit(for student: Student, subject: Subject, credit: Credit) throws {
        guard studentCreditBook[student] != nil else {
            throw StudentCreditServiceError.studentNotFound(name: student.name)
        }

        studentCreditBook[student]?[subject] = credit
    }

    func deleteCredit(for student: Student, subject: Subject) throws {
        guard studentCreditBook[student] != nil else {
            throw StudentCreditServiceError.studentNotFound(name: student.name)
        }
        guard studentCreditBook[student]?[subject] != nil else {
            throw StudentCreditServiceError.subjectNotFound(name: subject.name)
        }

        studentCreditBook[student]?[subject] = nil
    }

    func searchCredits(
        for student: Student
    ) -> Result<(credits: [Subject: Credit], average: Double), StudentCreditServiceError> {
        guard let credits = studentCreditBook[student] else {
            return .failure(.studentNotFound(name: student.name))
        }
        guard credits.isEmpty == false else {
            return .failure(.creditsNotFound(name: student.name))
        }

        let average = credits.map { $0.value.score }.reduce(0, +) / Double(credits.count)
        return .success((credits, average))
    }
}

extension StudentCreditService {
    enum StudentCreditServiceError: Error {
        case duplicateStudent(name: String)
        case studentNotFound(name: String)
        case subjectNotFound(name: String)
        case creditsNotFound(name: String)

        var localizedDescription: String {
            switch self {
            case .duplicateStudent(let name):
                return "\(name)은 이미 존재하는 학생입니다. 추가하지 않습니다."
            case .studentNotFound(let name):
                return "\(name) 학생을 찾지 못했습니다."
            case .subjectNotFound(let name):
                return "\(name) 과목을 찾지 못했습니다."
            case .creditsNotFound(let name):
                return "\(name) 학생의 성적을 찾을 수 없습니다."
            }
        }
    }
}

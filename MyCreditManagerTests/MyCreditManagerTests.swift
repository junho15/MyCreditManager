import XCTest

// swiftlint:disable force_try
final class StudentCreditServiceTests: XCTestCase {
    var sut: StudentCreditService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = StudentCreditService()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func test_addStudent를_호출하여_새로운학생을_추가하면_에러없이_추가되는지() {
        // given
        let student = Student(name: "Mickey")

        // when
        do {
            // Then
            try sut.addStudent(student)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_addStudnet를_호출하여_이미존재하는학생을_추가하면_duplicateStudent에러를_반환하는지() throws {
        // given
        let student = Student(name: "Mickey")
        try! sut.addStudent(student)

        // when
        do {
            try sut.addStudent(student)
            XCTFail("에러가 발생하지 않았습니다.")
        } catch {
            if let error = error as? StudentCreditService.StudentCreditServiceError,
               case .duplicateStudent = error {
                // Then
                XCTAssert(true)
            } else {
                XCTFail("duplicateStudent 에러가 아닙니다.")
            }
        }
    }

    func test_deleteStudent를_호출하여_존재하는학생을_삭제하면_에러없이_삭제되는지() {
        // given
        let student = Student(name: "Mickey")
        try! sut.addStudent(student)

        // when
        do {
            try sut.deleteStudent(student)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_deleteStudent를_호출하여_존재하지않는학생을_삭제하면_studentNotFound에러를_반환하는지() {
        // given
        let student = Student(name: "Mickey")

        // when
        do {
            try sut.deleteStudent(student)
            XCTFail("에러가 발생하지 않았습니다.")
        } catch {
            if let error = error as? StudentCreditService.StudentCreditServiceError,
               case .studentNotFound = error {
                // Then
                XCTAssert(true)
            } else {
                XCTFail("studentNotFound 에러가 아닙니다.")
            }
        }
    }

    func test_updateCredit를_호출하여_존재하는학생의_성적을추가하면_에러없이_추가되는지() {
        // given
        let student = Student(name: "Mickey")
        try! sut.addStudent(student)
        let subject = Subject(name: "Swift")
        let credit = Credit.aPlus

        // when
        do {
            try sut.updateCredit(for: student, subject: subject, credit: credit)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_updateCredit를_호출하여_존재하지않는학생의_성적을추가하면_studentNotFound에러를_반환하는지() {
        // given
        let student = Student(name: "Mickey")
        let subject = Subject(name: "Swift")
        let credit = Credit.aPlus

        // when
        do {
            try sut.updateCredit(for: student, subject: subject, credit: credit)
            XCTFail("에러가 발생하지 않았습니다.")
        } catch {
            if let error = error as? StudentCreditService.StudentCreditServiceError,
               case .studentNotFound = error {
                // Then
                XCTAssert(true)
            } else {
                XCTFail("studentNotFound 에러가 아닙니다.")
            }
        }
    }

    func test_deleteCredit를_호출하여_존재하는학생의_성적을삭제하면_에러없이_삭제되는지() {
        // given
        let student = Student(name: "Mickey")
        let subject = Subject(name: "Swift")
        let credit = Credit.aPlus
        try! sut.addStudent(student)
        try! sut.updateCredit(for: student, subject: subject, credit: credit)

        // when
        do {
            try sut.deleteCredit(for: student, subject: subject)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test__deleteCredit를_호출하여_존재하지않는학생의_성적을삭제하면_studentNotFound에러를_반환하는지() {
        // given
        let student = Student(name: "Mickey")
        let subject = Subject(name: "Swift")

        // when
        do {
            try sut.deleteCredit(for: student, subject: subject)
            XCTFail("에러가 발생하지 않았습니다.")
        } catch {
            if let error = error as? StudentCreditService.StudentCreditServiceError,
               case .studentNotFound = error {
                // Then
                XCTAssert(true)
            } else {
                XCTFail("studentNotFound 에러가 아닙니다.")
            }
        }
    }

    func test_deleteCredit를_호출하여_존재하는학생의_미등록된_성적을삭제하면_subjectNotFound에러를_반환하는지() {
        // given
        let student = Student(name: "Mickey")
        let subject = Subject(name: "Swift")
        try! sut.addStudent(student)

        // when
        do {
            try sut.deleteCredit(for: student, subject: subject)
            XCTFail("에러가 발생하지 않았습니다.")
        } catch {
            if let error = error as? StudentCreditService.StudentCreditServiceError,
               case .subjectNotFound = error {
                // Then
                XCTAssert(true)
            } else {
                XCTFail("subjectNotFound 에러가 아닙니다.")
            }
        }
    }

    func test_searchCredits를_호출하면_존재하는학생의_성적과_평점을_제대로반환하는지() {
        // given
        let student = Student(name: "Mickey")
        let swift = Subject(name: "Swift")
        let swiftCredit = Credit.a
        let python = Subject(name: "Python")
        let pythonCredit = Credit.b
        try! sut.addStudent(student)
        try! sut.updateCredit(for: student, subject: swift, credit: swiftCredit)
        try! sut.updateCredit(for: student, subject: python, credit: pythonCredit)

        // when
        switch sut.searchCredits(for: student) {
        case .success(let result):
            guard result.credits[swift] == swiftCredit,
                  result.credits[python] == pythonCredit else {
                XCTFail("성적을 제대로 반환하지 않았습니다.")
                return
            }
            let expectedAverage = (swiftCredit.score + pythonCredit.score) / 2
            XCTAssertEqual(expectedAverage, result.average)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_searchCredits를_호출하여_존재하지않는학생의_성적을조회하면_studentNotFound에러를_반환하는지() {
        // given
        let student = Student(name: "Mickey")

        // when
        switch sut.searchCredits(for: student) {
        case .success:
            XCTFail("에러가 발생하지 않았습니다.")
        case .failure(let error):
            if case .studentNotFound = error {
                // Then
                XCTAssert(true)
            } else {
                XCTFail("studentNotFound 에러가 아닙니다.")
            }
        }
    }

    func test_searchCredits를_호출하여_존재하는학생의_미등록된_성적을조회하면_creditsNotFound에러를_반환하는지() {
        // given
        let student = Student(name: "Mickey")
        try! sut.addStudent(student)

        // when
        switch sut.searchCredits(for: student) {
        case .success:
            XCTFail("에러가 발생하지 않았습니다.")
        case .failure(let error):
            if case .creditsNotFound = error {
                // Then
                XCTAssert(true)
            } else {
                XCTFail("creditsNotFound 에러가 아닙니다.")
            }
        }
    }
}
// swiftlint:enable force_try

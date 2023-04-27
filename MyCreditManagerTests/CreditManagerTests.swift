import XCTest

// swiftlint:disable force_try
final class CreditManagerTests: XCTestCase {
    var sut: CreditManager!
    var spyConsoleService: SpyConsoleService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        spyConsoleService = SpyConsoleService()
        sut = CreditManager(consoleService: spyConsoleService)
    }

    override func tearDownWithError() throws {
        sut = nil
        spyConsoleService = nil
        try super.tearDownWithError()
    }

    func test_CreditManager를실행하고_잘못된값을_입력하면_경고문구가출력되는지() {
        // given
        spyConsoleService.testInput = [" ", "6", "aa", "X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(spyConsoleService.printedMessage[1], CreditManager.PromptsMessage.invalidMenu)
        XCTAssertEqual(spyConsoleService.printedMessage[3], CreditManager.PromptsMessage.invalidMenu)
        XCTAssertEqual(spyConsoleService.printedMessage[5], CreditManager.PromptsMessage.invalidMenu)
    }

    func test_추가할학생의이름을입력하지않으면_경고문구가출력되는지() {
        // given
        spyConsoleService.testInput = ["1", nil, "X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(spyConsoleService.printedMessage[2], ConsoleServiceError.inputError.localizedDescription)
    }

    func test_학생을추가하면_추가완료문구가출력되는지() {
        // given
        let studentName = "Mickey"
        spyConsoleService.testInput = ["1", studentName, "X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(spyConsoleService.printedMessage[2],
                       CreditManager.SuccessMessage.addStudent(name: studentName).message)
    }

    func test_이미추가한학생을_다시추가하면_추가하지않았다는문구가출력되는지() {
        // given
        let studentName = "Mickey"
        spyConsoleService.testInput = ["1", studentName, "1", studentName, "X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(
            spyConsoleService.printedMessage[5],
            StudentCreditService.StudentCreditServiceError.duplicateStudent(name: studentName).localizedDescription
        )
    }

    func test_추가한학생을_삭제하면_삭제완료문구가출력되는지() {
        // given
        let studentName = "Mickey"
        spyConsoleService.testInput = ["1", studentName, "2", studentName, "X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(spyConsoleService.printedMessage[5],
                       CreditManager.SuccessMessage.deleteStudent(name: studentName).message)
    }

    func test_추가하지않은학생을_삭제하면_학생을찾지못했다는문구가출력되는지() {
        // given
        let studentName = "Mickey"
        spyConsoleService.testInput = ["2", studentName, "X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(
            spyConsoleService.printedMessage[2],
            StudentCreditService.StudentCreditServiceError.studentNotFound(name: studentName).localizedDescription
        )
    }

    func test_성적추가시_잘못된값을_입력하면_경고문구가출력되는지() {
        // given
        let studentName = "Mickey"
        spyConsoleService.testInput = ["3", nil, "3", studentName, "X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(spyConsoleService.printedMessage[2], ConsoleServiceError.inputError.localizedDescription)
        XCTAssertEqual(spyConsoleService.printedMessage[5], ConsoleServiceError.inputError.localizedDescription)
    }

    func test_성적을추가하면_추가완료문구가출력되는지() {
        // given
        let studentName = "Mickey"
        let subjectName = "Swift"
        let credit = "A+"
        let input = [studentName, subjectName, credit].joined(separator: " ")
        spyConsoleService.testInput = ["1", studentName, "3", input, "X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(spyConsoleService.printedMessage[5],
                       CreditManager.SuccessMessage.updateCredit(studentName: studentName,
                                                                 subjectName: subjectName,
                                                                 credit: credit).message)
    }

    func test_성적삭제시_잘못된값을_입력하면_경고문구가출력되는지() {
        // given
        let studentName = "Mickey"
        spyConsoleService.testInput = ["4", nil, "4", studentName, "X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(spyConsoleService.printedMessage[2], ConsoleServiceError.inputError.localizedDescription)
        XCTAssertEqual(spyConsoleService.printedMessage[5], ConsoleServiceError.inputError.localizedDescription)
    }

    func test_성적삭제시_추가하지않은학생을_입력하면_학생을찾지못했다는문구가출력되는지() {
        // given
        let studentName = "Mickey"
        let subjectName = "Swift"
        let input = [studentName, subjectName].joined(separator: " ")
        spyConsoleService.testInput = ["4", input, "X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(
            spyConsoleService.printedMessage[2],
            StudentCreditService.StudentCreditServiceError.studentNotFound(name: studentName).localizedDescription
        )
    }

    func test_성적삭제시_추가하지않은과목을_입력하면_과목을찾지못했다는문구가출력되는지() {
        // given
        let studentName = "Mickey"
        let firstSubjectName = "Swift"
        let secondSubjectName = "Python"
        let firstInput = [studentName, firstSubjectName].joined(separator: " ")
        let secondInput = [studentName, secondSubjectName].joined(separator: " ")
        spyConsoleService.testInput = ["1", studentName, "3", firstInput, "4", secondInput, "X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(
            spyConsoleService.printedMessage[8],
            StudentCreditService.StudentCreditServiceError.subjectNotFound(name: secondSubjectName).localizedDescription
        )
    }

    func test_성적을삭제하면_삭제완료문구가출력되는지() {
        // given
        let studentName = "Mickey"
        let subjectName = "Swift"
        let credit = "A+"
        let firstInput = [studentName, subjectName, credit].joined(separator: " ")
        let secondInput = [studentName, subjectName].joined(separator: " ")
        spyConsoleService.testInput = ["1", studentName, "3", firstInput, "4", secondInput, "X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(
            spyConsoleService.printedMessage[8],
            CreditManager.SuccessMessage.deleteCredit(studentName: studentName, subjectName: subjectName).message
        )
    }

    func test_평점보기시_잘못된값을_입력하면_경고문구가출력되는지() {
        // given
        spyConsoleService.testInput = ["5", nil, "X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(spyConsoleService.printedMessage[2], ConsoleServiceError.inputError.localizedDescription)
    }

    func test_평점보기시_추가하지않은학생을_입력하면_학생을찾지못했다는문구가출력되는지() {
        // given
        let studentName = "Mickey"
        spyConsoleService.testInput = ["5", studentName, "X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(
            spyConsoleService.printedMessage[2],
            StudentCreditService.StudentCreditServiceError.studentNotFound(name: studentName).localizedDescription
        )
    }

    func test_평점보기하면_과목과성적목록과_평점이출력되는지() {
        // given
        let studentName = "Mickey"
        let subjectName = "Swift"
        let credit = "A+"
        let input = [studentName, subjectName, credit].joined(separator: " ")
        spyConsoleService.testInput = ["1", studentName, "3", input, "5", studentName, "X"]

        // when
        sut.start()

        // then
        let expectedCredits = [(subjectName, credit)]
        let expectedAverage = 4.5
        XCTAssertEqual(
            spyConsoleService.printedMessage[8],
            CreditManager.SuccessMessage.searchCredits(credits: expectedCredits, average: expectedAverage).message)
    }

    func test_CreditManager를실행하고_X를입력하면_종료되는지() {
        // given
        spyConsoleService.testInput = ["X"]

        // when
        sut.start()

        // then
        XCTAssertEqual(spyConsoleService.printedMessage[1], CreditManager.PromptsMessage.exit)
    }
}
// swiftlint:enable force_try

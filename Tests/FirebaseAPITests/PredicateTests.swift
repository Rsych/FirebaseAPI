//
//  PredicateTests.swift
//
//
//  Created by Norikazu Muramoto on 2023/05/14.
//

import Testing
@testable import FirestoreAPI

@Suite("Query Predicate Tests")
struct PredicateTests {

    @Test("Predicate isEqualTo operator")
    func testIsEqualTo() {
        let predicate = "test" == 0

        guard case .isEqualTo(let field, let value) = predicate,
              let intValue = value as? Int else {
            Issue.record("Expected isEqualTo predicate")
            return
        }

        #expect(field == "test")
        #expect(intValue == 0)
    }

    @Test("Predicate isNotEqualTo operator")
    func testIsNotEqualTo() {
        let predicate = "test" != 0

        guard case .isNotEqualTo(let field, let value) = predicate,
              let intValue = value as? Int else {
            Issue.record("Expected isNotEqualTo predicate")
            return
        }

        #expect(field == "test")
        #expect(intValue == 0)
    }

    @Test("Predicate isLessThan operator")
    func testIsLessThan() {
        let predicate = "test" < 0

        guard case .isLessThan(let field, let value) = predicate,
              let intValue = value as? Int else {
            Issue.record("Expected isLessThan predicate")
            return
        }

        #expect(field == "test")
        #expect(intValue == 0)
    }

    @Test("Predicate isLessThanOrEqualTo operator")
    func testIsLessThanOrEqualTo() {
        let predicate = "test" <= 0

        guard case .isLessThanOrEqualTo(let field, let value) = predicate,
              let intValue = value as? Int else {
            Issue.record("Expected isLessThanOrEqualTo predicate")
            return
        }

        #expect(field == "test")
        #expect(intValue == 0)
    }

    @Test("Predicate isGreaterThan operator")
    func testIsGreaterThan() {
        let predicate = "test" > 0

        guard case .isGreaterThan(let field, let value) = predicate,
              let intValue = value as? Int else {
            Issue.record("Expected isGreaterThan predicate")
            return
        }

        #expect(field == "test")
        #expect(intValue == 0)
    }

    @Test("Predicate isGreaterThanOrEqualTo operator")
    func testIsGreaterThanOrEqualTo() {
        let predicate = "test" >= 0

        guard case .isGreaterThanOrEqualTo(let field, let value) = predicate,
              let intValue = value as? Int else {
            Issue.record("Expected isGreaterThanOrEqualTo predicate")
            return
        }

        #expect(field == "test")
        #expect(intValue == 0)
    }

    @Test("Predicate offset")
    func testOffset() {
        let predicate = QueryPredicate.offset(10)

        guard case .offset(let value) = predicate else {
            Issue.record("Expected offset predicate")
            return
        }

        #expect(value == 10)
        #expect(predicate.type == .offset)
    }

    @Test("Predicate startAt")
    func testStartAt() {
        let predicate = QueryPredicate.startAt([100, "test"])

        guard case .startAt(let values) = predicate else {
            Issue.record("Expected startAt predicate")
            return
        }

        #expect(values.count == 2)
        #expect((values[0] as? Int) == 100)
        #expect((values[1] as? String) == "test")
        #expect(predicate.type == .cursor)
    }

    @Test("Predicate startAfter")
    func testStartAfter() {
        let predicate = QueryPredicate.startAfter([200])

        guard case .startAfter(let values) = predicate else {
            Issue.record("Expected startAfter predicate")
            return
        }

        #expect(values.count == 1)
        #expect((values[0] as? Int) == 200)
        #expect(predicate.type == .cursor)
    }

    @Test("Predicate endAt")
    func testEndAt() {
        let predicate = QueryPredicate.endAt([500])

        guard case .endAt(let values) = predicate else {
            Issue.record("Expected endAt predicate")
            return
        }

        #expect(values.count == 1)
        #expect((values[0] as? Int) == 500)
        #expect(predicate.type == .cursor)
    }

    @Test("Predicate endBefore")
    func testEndBefore() {
        let predicate = QueryPredicate.endBefore([300, "value"])

        guard case .endBefore(let values) = predicate else {
            Issue.record("Expected endBefore predicate")
            return
        }

        #expect(values.count == 2)
        #expect((values[0] as? Int) == 300)
        #expect((values[1] as? String) == "value")
        #expect(predicate.type == .cursor)
    }
}

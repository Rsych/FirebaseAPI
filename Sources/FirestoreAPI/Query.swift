//
//  Query.swift
//
//
//  Created by nori on 2022/05/16.
//

import Foundation
import GRPCCore
import SwiftProtobuf

public struct Query {
    
    var database: Database
    var parentPath: String?
    public var collectionID: String
    var allDescendants: Bool
    var predicates: [QueryPredicate]
    
    public var path: String {
        if let parentPath {
            return "\(parentPath)/\(collectionID)".normalized
        } else {
            return "\(collectionID)".normalized
        }
    }
    
    init(_ database: Database, parentPath: String?, collectionID: String, allDescendants: Bool = false, predicates: [QueryPredicate]) {
        self.database = database
        self.parentPath = parentPath
        self.allDescendants = allDescendants
        self.collectionID = collectionID
        self.predicates = predicates
    }
    
    public func getDocuments<Transport: ClientTransport>(firestore: Firestore<Transport>) async throws -> QuerySnapshot {
        guard let accessToken = try await firestore.getAccessToken() else {
            fatalError("AccessToken is empty")
        }
        var metadata: Metadata = [:]
        metadata.addString("Bearer \(accessToken)", forKey: "authorization")
        return try await getDocuments(firestore: firestore, metadata: metadata)
    }

    public func getDocuments<T: Decodable, Transport: ClientTransport>(type: T.Type, firestore: Firestore<Transport>) async throws -> [T] {
        guard let accessToken = try await firestore.getAccessToken() else {
            fatalError("AccessToken is empty")
        }
        var metadata: Metadata = [:]
        metadata.addString("Bearer \(accessToken)", forKey: "authorization")
        return try await getDocuments(type: type, firestore: firestore, metadata: metadata)
    }

    public func addSnapshotListener<Transport: ClientTransport>(firestore: Firestore<Transport>) async throws -> AsyncThrowingStream<QuerySnapshot, Error> {
        guard let accessToken = try await firestore.getAccessToken() else {
            fatalError("AccessToken is empty")
        }
        var metadata: Metadata = [:]
        metadata.addString("Bearer \(accessToken)", forKey: "authorization")
        return try await addSnapshotListener(firestore: firestore, metadata: metadata)
    }
}

extension Query {
    var name: String {
        if let parentPath {
            return "\(database.path)/\(parentPath)".normalized
        }
        return "\(database.path)".normalized
    }
}

extension Query {
    public func or(_ filters: [QueryPredicate]) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.or(filters))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func and(_ filters: [QueryPredicate]) -> Query {
        var predicates: [QueryPredicate] = []
        predicates.append(.and(filters))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
}

extension Query {
    func append(_ predicate: QueryPredicate) -> [QueryPredicate] {
        var predicates = self.predicates
        if let compositeFilter = predicates.first(where: { $0.type == .compositeFilter }) {
            if case .and(let filters) = compositeFilter {
                let index = predicates.firstIndex(where: { $0.type == .compositeFilter })!
                var newFilters = filters
                newFilters.append(predicate)
                predicates[index] = .and(newFilters)
                return predicates
            }
            if case .or(_) = compositeFilter {
                let index = predicates.firstIndex(where: { $0.type == .compositeFilter })!
                predicates[index] = .and([compositeFilter, predicate])
                return predicates
            }
        } else if let filter = predicates.first(where: { $0.type == .fieldFilter || $0.type == .unaryFilter }) {
            return [.and([filter, predicate])]
        }
        predicates.append(predicate)
        return predicates
    }
    
    public func `where`(field: String, isEqualTo value: Any) -> Query {
        let predicates = append(.isEqualTo(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(field: String, isNotEqualTo value: Any) -> Query {
        let predicates = append(.isNotEqualTo(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(field: String, isLessThan value: Any) -> Query {
        let predicates = append(.isLessThan(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(field: String, isLessThanOrEqualTo value: Any) -> Query {
        let predicates = append(.isLessThanOrEqualTo(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(field: String, isGreaterThan value: Any) -> Query {
        let predicates = append(.isGreaterThan(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(field: String, isGreaterThanOrEqualTo value: Any) -> Query {
        let predicates = append(.isGreaterThanOrEqualTo(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(field: String, arrayContains value: Any) -> Query {
        let predicates = append(.arrayContains(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(field: String, arrayContainsAny value: [Any]) -> Query {
        let predicates = append(.arrayContainsAny(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(field: String, in value: [Any]) -> Query {
        let predicates = append(.isIn(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(field: String, notIn value: [Any]) -> Query {
        let predicates = append(.isNotIn(field, value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(isEqualTo value: String) -> Query {
        let predicates = append(.isEqualToDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(isNotEqualTo value: String) -> Query {
        let predicates = append(.isNotEqualToDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(isLessThan value: String) -> Query {
        let predicates = append(.isLessThanDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(isLessThanOrEqualTo value: String) -> Query {
        let predicates = append(.isLessThanOrEqualToDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(isGreaterThan value: String) -> Query {
        let predicates = append(.isGreaterThanDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(isGreaterThanOrEqualTo value: String) -> Query {
        let predicates = append(.isGreaterThanOrEqualToDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(arrayContains value: String) -> Query {
        let predicates = append(.arrayContainsDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(arrayContainsAny value: [String]) -> Query {
        let predicates = append(.arrayContainsAnyDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(in value: [String]) -> Query {
        let predicates = append(.isInDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func `where`(notIn value: [String]) -> Query {
        let predicates = append(.isNotInDocumentID(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
}

extension Query {
    public func limit(to value: Int) -> Query {
        var predicates = self.predicates
        predicates.append(.limitTo(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
    
    public func limit(toLast value: Int) -> Query {
        var predicates = self.predicates
        predicates.append(.limitToLast(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
}

extension Query {
    public func order(by field: String, descending: Bool = false) -> Query {
        var predicates = self.predicates
        predicates.append(.orderBy(field, descending))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
}

extension Query {
    /// Specifies the offset of the returned results.
    /// - Parameter value: The number of documents to skip before starting to return results.
    /// - Returns: A new Query with the offset applied.
    public func offset(_ value: Int) -> Query {
        var predicates = self.predicates
        predicates.append(.offset(value))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    /// Creates and returns a new Query that starts at the provided fields relative to the order of the query.
    /// The values must correspond to the order by fields of the query.
    /// - Parameter values: The field values to start this query at, in order of the query's order by.
    /// - Returns: A new Query starting at the provided values (inclusive).
    public func start(at values: Any...) -> Query {
        var predicates = self.predicates
        predicates.append(.startAt(values))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    /// Creates and returns a new Query that starts after the provided fields relative to the order of the query.
    /// The values must correspond to the order by fields of the query.
    /// - Parameter values: The field values to start this query after, in order of the query's order by.
    /// - Returns: A new Query starting after the provided values (exclusive).
    public func start(after values: Any...) -> Query {
        var predicates = self.predicates
        predicates.append(.startAfter(values))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    /// Creates and returns a new Query that ends at the provided fields relative to the order of the query.
    /// The values must correspond to the order by fields of the query.
    /// - Parameter values: The field values to end this query at, in order of the query's order by.
    /// - Returns: A new Query ending at the provided values (inclusive).
    public func end(at values: Any...) -> Query {
        var predicates = self.predicates
        predicates.append(.endAt(values))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }

    /// Creates and returns a new Query that ends before the provided fields relative to the order of the query.
    /// The values must correspond to the order by fields of the query.
    /// - Parameter values: The field values to end this query before, in order of the query's order by.
    /// - Returns: A new Query ending before the provided values (exclusive).
    public func end(before values: Any...) -> Query {
        var predicates = self.predicates
        predicates.append(.endBefore(values))
        return .init(database, parentPath: parentPath, collectionID: collectionID, allDescendants: allDescendants, predicates: predicates)
    }
}

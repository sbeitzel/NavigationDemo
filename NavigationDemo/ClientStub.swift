//
//  ClientStub.swift
//  NavigationDemo
//
//  Created by Stephen Beitzel on 6/21/22.
//

import Foundation

class ClientStub: ObservableObject {
    static let sleepNanos: UInt64 = 2_000_000_000

    var isLoggedIn = false
    var fetchCount: Int = 0
    var records: [ServerRecord] = []

    fileprivate func startFetch() async {
        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.fetchCount += 1
        }
    }

    fileprivate func endFetch() async {
        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.fetchCount -= 1
        }
    }

    /// Simulate fetching a bunch of application data from a
    /// remote service. Because in real situations this could be
    /// a large amount of data or the network could be slow,
    /// we pause the task to simulate this.
    func fetchDataSets() async throws {
        await startFetch()
        defer {
            Task {
                await endFetch()
            }
        }
        var fetchedRecords: [ServerRecord] = []
        // make some records
        for count in (1..<5) {
            let record = ServerRecord(named: "Record \(count)")
            for detailCount in (1..<Int.random(in: (2..<6))) {
                record.insert(detail: RecordDetail(count: Int.random(in: 0..<11),
                                                   description: "Detail number \(detailCount)"))
            }
            fetchedRecords.append(record)
        }
        try await Task.sleep(nanoseconds: ClientStub.sleepNanos)
        records = fetchedRecords
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    /// Simulate logging in a user with a remote service. Since it's a remote operation,
    /// we pause the task for a couple of seconds so the UI can experience what it's
    /// like when the network is really slow.
    func login() async throws {
        await startFetch()
        defer {
            Task {
                await endFetch()
            }
        }
        try await Task.sleep(nanoseconds: ClientStub.sleepNanos)
        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.isLoggedIn = true
        }
        try await fetchDataSets()
    }

    /// SImulate logging out. This just involves discarding any authentication tokens
    /// and cached local state, so no network requests are required.
    func logout() {
        objectWillChange.send()
        isLoggedIn = false
        records.removeAll()
    }
}

class ServerRecord: ObservableObject, Identifiable {
    let id: UUID
    @Published var name: String
    var details: [RecordDetail]

    init(named: String) {
        id = UUID()
        self.name = named
        details = []
    }

    /// Add a new default detail to the list of details
    func addDetail() {
        objectWillChange.send()
        details.append(RecordDetail(count: 0, description: "Default description"))
    }

    /// Appends a detail *without* notifying observers of the change
    /// - Parameter detail: the detail to add
    func insert(detail: RecordDetail) {
        details.append(detail)
    }
}

extension ServerRecord: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ServerRecord, rhs: ServerRecord) -> Bool {
        return lhs.id == rhs.id
    }
}

class RecordDetail: ObservableObject, Identifiable {
    let id: UUID
    var count: Int
    var description: String

    init(count: Int, description: String) {
        self.id = UUID()
        self.count = count
        self.description = description
    }
}

extension RecordDetail: Hashable {
    static func == (lhs: RecordDetail, rhs: RecordDetail) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

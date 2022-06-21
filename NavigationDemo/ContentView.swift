//
//  ContentView.swift
//  NavigationDemo
//
//  Created by Stephen Beitzel on 6/21/22.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var client: ClientStub

    @ObservedObject var detail: RecordDetail

    var body: some View {
        VStack {
            Text("Detail View")
            Text("Count: \(detail.count)")
            Text("Description: \(detail.description)")
        }
        .navigationTitle("Detail for \(detail.description)")
    }
}

struct ServerRecordView: View {
    @EnvironmentObject var client: ClientStub

    @ObservedObject var record: ServerRecord

    @State private var selected: UUID?

    var body: some View {
        VStack {
            Text(record.name)
            List(record.details, selection: $selected) { detail in
                NavigationLink(destination: DetailView(detail: detail),
                               label: {
                    Text(detail.description)
                })
                .tag(detail.id)
            }
        }
        .navigationTitle("Record view for \(record.name)")
    }
}

struct ServerRecordsListView: View {
    @EnvironmentObject var client: ClientStub

    @State private var selected: UUID?

    var body: some View {
        List(client.records, selection: $selected) { record in
            NavigationLink(destination: ServerRecordView(record: record),
                           label: {
                Text(record.name)
            })
            .tag(record.id)
        }
        .navigationTitle("Record selection")
    }
}

struct ContentView: View {
    @StateObject var client = ClientStub()

    var body: some View {
        NavigationView {
            Group {
                if client.fetchCount > 0 {
                    ProgressView()
                } else {
                    Group {
                        if client.isLoggedIn {
                            ServerRecordsListView()
                        } else {
                            Button(action: {
                                Task {
                                    do {
                                        try await client.login()
                                    } catch {
                                        print("Error during login: \(error.localizedDescription)")
                                    }
                                }
                            },
                                   label: {
                                Text("Login")
                            })
                        }
                    }
                }
            }
            EmptyView()
        }
        .environmentObject(client)
    }
}

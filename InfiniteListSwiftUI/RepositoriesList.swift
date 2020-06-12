//
//  RepositoriesList.swift
//  InfiniteListSwiftUI
//
//  Created by Vadim Bulavin on 6/10/20.
//  Copyright © 2020 Vadim Bulavin. All rights reserved.
//

import SwiftUI
import Combine

struct RepositoriesListContainer: View {
    @State private var page = 1
    @State private var repos: [Repository] = []
    @State private var subscription: AnyCancellable?
    @State private var canLoadNextPage = true
    
    var body: some View {
        RepositoriesList(
            repos: repos,
            isLoading: canLoadNextPage,
            onScrolledAtBottom: fetch
        )
        .onAppear(perform: fetch)
        .onDisappear(perform: cancel)
    }
    
    private func fetch() {
        page += 1
        subscription = GithubAPI.searchRepos(query: "swift", page: page)
            .sink(receiveCompletion: { _ in }, receiveValue: onReceive)
    }
    
    private func onReceive(_ batch: [Repository]) {
        repos += batch
        canLoadNextPage = batch.count < GithubAPI.pageSize
    }
    
    private func cancel() {
        subscription?.cancel()
    }
}

struct RepositoriesList: View {
    let repos: [Repository]
    let isLoading: Bool
    let onScrolledAtBottom: () -> Void
    
    var body: some View {
        List {
            reposList
            if isLoading {
                loadingIndicator
            }
        }
    }
    
    private var reposList: some View {
        ForEach(repos) { repo in
            RepositoryRow(repo: repo).onAppear {
                if self.repos.last == repo {
                    self.onScrolledAtBottom()
                }
            }
        }
    }
    
    private var loadingIndicator: some View {
        Spinner(style: .medium)
            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
    }
}

struct RepositoryRow: View {
    let repo: Repository
    
    var body: some View {
        VStack {
            Text(repo.name).font(.title)
            Text("⭐️ \(repo.stargazers_count)")
            repo.description.map(Text.init)?.font(.body)
        }
        .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
    }
}

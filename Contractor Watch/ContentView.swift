//
//  ContentView.swift
//  Contractor Watch
//
//  Created by Edgars Yarmolatiy on 7/9/24.
//

import SwiftUI
import GoogleSignIn

struct ContentView: View {
    @StateObject private var viewModel = GoogleSheetsViewModel()
    @State private var sheetName = "MySheet"
    @State private var newRow = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isSignedIn {
                    List {
                        ForEach(viewModel.rows, id: \.self) { row in
                            Text(row)
                        }
                        .onDelete(perform: deleteRow)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: viewModel.signOut) {
                                Text("Sign Out")
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: fetchRows) {
                                Text("Fetch Rows")
                            }
                        }
                        ToolbarItem(placement: .bottomBar) {
                            HStack {
                                TextField("New Row", text: $newRow)
                                Button(action: addRow) {
                                    Text("Add Row")
                                }
                            }
                            .padding()
                        }
                    }
                } else {
                    Button(action: viewModel.signIn) {
                        Text("Sign In with Google")
                    }
                }
            }
            .navigationTitle("Google Sheets")
        }
        .onAppear {
            if viewModel.isSignedIn {
                viewModel.createSheet(named: sheetName)
            }
        }
    }
    
    private func fetchRows() {
        // Replace "your-sheet-id" with the actual sheet ID
        viewModel.fetchRows(from: "your-sheet-id", named: sheetName)
    }
    
    private func addRow() {
        guard !newRow.isEmpty else { return }
        // Replace "your-sheet-id" with the actual sheet ID
        viewModel.addRow(to: "your-sheet-id", named: sheetName, row: [newRow])
        newRow = ""
    }
    
    private func deleteRow(at offsets: IndexSet) {
        // Replace “your-sheet-id” with the actual sheet ID
        offsets.forEach { index in
            viewModel.deleteRow(from: "your-sheet-id", named: sheetName, rowIndex: index)
        }
    }
}

#Preview {
    ContentView()
}

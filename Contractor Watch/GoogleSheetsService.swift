//
//  GoogleSheetsService.swift
//  Contractor Watch
//
//  Created by Edgars Yarmolatiy on 7/9/24.
//

import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import SwiftUI

class GoogleSheetsViewModel: ObservableObject {
    private var sheetsService = GTLRSheetsService()
    @Published var isSignedIn = false
    @Published var rows: [String] = []

    init() {
        GIDSignIn.sharedInstance.delegate = self
    }

    func signIn() {
        guard let clientID = Bundle.main.infoDictionary?["4678403786-6f4apa8lbqkqok02s9nfgj3ur20etd1e.apps.googleusercontent.com"] as? String else { return }
        let configuration = GIDConfiguration(clientID: clientID)
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }

        GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController)
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isSignedIn = false
        rows = []
    }

    private func configureSheetsService() {
        sheetsService.authorizer = GIDSignIn.sharedInstance.currentUser?.authentication.fetcherAuthorizer()
    }

    func createSheet(named name: String) {
        let spreadsheet = GTLRSheets_Spreadsheet()
        spreadsheet.properties = GTLRSheets_SpreadsheetProperties()
        spreadsheet.properties?.title = name

        let createQuery = GTLRSheetsQuery_SpreadsheetsCreate.query(withObject: spreadsheet)
        sheetsService.executeQuery(createQuery) { [weak self] (ticket, result, error) in
            if let error = error {
                print("Error creating sheet: \(error.localizedDescription)")
                return
            }
            print("Sheet created: \(result ?? "")")
        }
    }

    func fetchRows(from sheetID: String, named sheetName: String) {
        let range = "\(sheetName)!A:Z"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: sheetID, range: range)
        sheetsService.executeQuery(query) { [weak self] (ticket, result, error) in
            if let error = error {
                print("Error fetching rows: \(error.localizedDescription)")
                return
            }

            if let rows = (result as? GTLRSheets_ValueRange)?.values as? [[String]] {
                self?.rows = rows.flatMap { $0 }
            }
        }
    }

    func addRow(to sheetID: String, named sheetName: String, row: [String]) {
        let valueRange = GTLRSheets_ValueRange()
        valueRange.values = [row]

        let range = "\(sheetName)!A:A"
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: sheetID, range: range)
        query.valueInputOption = "RAW"

        sheetsService.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Error adding row: \(error.localizedDescription)")
                return
            }
            print("Row added: \(result ?? "")")
        }
    }

    func deleteRow(from sheetID: String, named sheetName: String, rowIndex: Int) {
        // Deleting a row involves batch update with a deleteDimension request
        let deleteDimensionRequest = GTLRSheets_Request()
        deleteDimensionRequest.deleteDimension = GTLRSheets_DeleteDimensionRequest()
        deleteDimensionRequest.deleteDimension?.range = GTLRSheets_DimensionRange()
        deleteDimensionRequest.deleteDimension?.range?.sheetId = NSNumber(pointer: sheetID)
        deleteDimensionRequest.deleteDimension?.range?.dimension = "ROWS"
        deleteDimensionRequest.deleteDimension?.range?.startIndex = ((UInt(rowIndex)) as NSNumber)
        deleteDimensionRequest.deleteDimension?.range?.endIndex = ((UInt(rowIndex + 1)) as NSNumber)

        let batchUpdateRequest = GTLRSheets_BatchUpdateSpreadsheetRequest()
        batchUpdateRequest.requests = [deleteDimensionRequest]

        let batchUpdateQuery = GTLRSheetsQuery_SpreadsheetsBatchUpdate.query(withObject: batchUpdateRequest, spreadsheetId: sheetID)

        sheetsService.executeQuery(batchUpdateQuery) { (ticket, result, error) in
            if let error = error {
                print("Error deleting row: \(error.localizedDescription)")
                return
            }
            print("Row deleted: \(result ?? "")")
        }
    }
}

extension GoogleSheetsViewModel: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Error signing in: \(error.localizedDescription)")
            return
        }

        isSignedIn = true
        configureSheetsService()
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        isSignedIn = false
        rows = []
    }
}

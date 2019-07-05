//
//  TransferDB.swift
//  Look Roulette
//
//  Created by Cortland Walker on 7/4/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import Foundation
import SQLite3

class TransferDB {
    
    init() {
        validateDatabase()
    }
    
    let createTransfersTableString = """
        CREATE TABLE IF NOT EXISTS Transfers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            videoId TEXT NOT NULL UNIQUE,
            baseImage BLOB,
            lookImage BLOB,
            resultImage BLOB
        );
        """
    
    func validateDatabase() {
        
        // Check if Transfers table exists
        let documentsDir = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let sqliteFile = documentsDir.appendingPathComponent("Transfers.sqlite")
        
        if FileManager().fileExists(atPath: sqliteFile.path) {
            return
        } else {
            print("")
        }
        
    }
    
    func openConnection() -> OpaquePointer? {
        
        var db: OpaquePointer? = nil
        
        let sqliteDatabaseURL = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false).appendingPathComponent("Transfers.sqlite")
        
        if sqlite3_open(sqliteDatabaseURL.path, &db) == SQLITE_OK {
            //print("Successfully opened connection to Database at \(sqliteDatabaseURL)")
            print("Successfully opened connection to Database")
            return db
        } else {
            print("Unable to open database.")
            return nil
        }
    }
    
    func closeConnection(db: OpaquePointer?) {
        let r = sqlite3_close(db)
        if r == SQLITE_OK {
            print("Successfully Closed Connection")
        } else {
            print("Error Attempting to Close Connection")
        }
    }
    
    func createTable() {
        
        let db = openConnection()
        
        var createTableStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, createTransfersTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Transfers Table created.")
            } else {
                print("Transfers Table could not be created.")
            }
        } else {
            print("Create Table statement not prepare")
        }
        
        sqlite3_finalize(createTableStatement)
        closeConnection(db: db)
    }
    
}

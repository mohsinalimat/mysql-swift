//
//  QueryDecimalTypeTests.swift
//  MySQLTests
//
//  Created by Yusuke Ito on 5/1/18.
//

import XCTest
@testable import MySQL
import Foundation

extension Row {
    fileprivate struct DecimalRow: Codable, QueryParameter, Equatable {
        let valueDoubleColumn: Decimal
        let valueTextColumn: Decimal
        private enum CodingKeys: String, CodingKey {
            case valueDoubleColumn = "value_double_col"
            case valueTextColumn = "value_text_col"
        }
    }
}


final class QueryDecimalTypeTests: XCTestCase, QueryTestType {
    var constants: TestConstantsType!
    var pool: ConnectionPool!
    
    override func setUp() {
        super.setUp()
        
        prepare()
        try! createDecimalTestTable()
    }
    
    private func createDecimalTestTable() throws {
        try dropTestTable()
        
        let conn = try pool.getConnection()
        let query = """
        CREATE TABLE `\(constants.tableName)` (
        `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
        `value_double_col` DOUBLE NOT NULL DEFAULT 0,
        `value_text_col` MEDIUMTEXT,
        PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """
        
        _ = try conn.query(query)
    }
    
    
    func testDecimalType() throws {
        let value = Decimal(string: "1.549")!
        let row = Row.DecimalRow(valueDoubleColumn: value, valueTextColumn: value)
        
        try pool.execute { conn in
            _ = try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, row])
        }
        
        let rows: [Row.DecimalRow] = try pool.execute {
            try $0.query("SELECT * FROM ?? ORDER BY id ASC", [constants.tableName])
        }
        
        XCTAssertEqual(rows[0], row)
    }
    
    func testDecimalType_largerValue() throws {
        let value = Decimal(string: "1.23e100")!
        let row = Row.DecimalRow(valueDoubleColumn: value, valueTextColumn: value)
    
        try pool.execute { conn in
            _ = try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, row])
        }
        
        let rows: [Row.DecimalRow] = try pool.execute {
            try $0.query("SELECT * FROM ?? ORDER BY id ASC", [constants.tableName])
        }
        
        XCTAssertEqual(rows[0], row)
    }
}

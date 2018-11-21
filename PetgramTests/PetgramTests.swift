//
//  PetgramTests.swift
//  PetgramTests
//
//  Created by Saifuding Diliyaer on 11/20/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import XCTest
@testable import Petgram

class PetgramTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    
//    func getLCUserClassKey() -> LCUserClassKey{
//        switch  self {
//        case .petName:
//            return .petName
//        case .location:
//            return .petCity
//
//        case .undefined:
//            return .undefined
//        }
//    }
    
    //test 1
    func testGetLCUserClassKey() {
        var input = EnterTextInfoState.petName
        var expected = LCUserClassKey.petName
        var result = input.getLCUserClassKey()
        XCTAssertEqual(expected, result)
        print("testGetLCUserClassKey() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = EnterTextInfoState.location
        expected = LCUserClassKey.petCity
        result = input.getLCUserClassKey()
        XCTAssertEqual(expected, result)
        print("testGetLCUserClassKey() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = EnterTextInfoState.undefined
        expected = LCUserClassKey.undefined
        result = input.getLCUserClassKey()
        XCTAssertEqual(expected, result)
        print("testGetLCUserClassKey() is tested successfully. Expected: \(expected); Result: \(result)")
    }
    

    //test 2
    func testDisplayTitile() {
        var input = EnterTextInfoState.petName
        var expected = "Update pet name"
        var result = input.displayTitle
        XCTAssertEqual(expected, result)
        print("testDisplayTitle is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = EnterTextInfoState.location
        expected = "Update pet location"
        result = input.displayTitle
        XCTAssertEqual(expected, result)
        print("testDisplayTitle is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = EnterTextInfoState.undefined
        expected = "Update info"
        result = input.displayTitle
        XCTAssertEqual(expected, result)
        print("testDisplayTitle is tested successfully. Expected: \(expected); Result: \(result)")
    }
    
    
    
    
    


}

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
    
    
    //test 3
    func testRoundedString() {
        var input = 3000
        var expected = "3.0k"
        var result = input.roundedString
        XCTAssertEqual(expected, result)
        print("testRoundedString is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = 5000000
        expected = "5.0m"
        result = input.roundedString
        XCTAssertEqual(expected, result)
        print("testRoundedString() is tested successfully. Expected: \(expected); Result: \(result)")
        
        //test for wrong results
        input = 2000
        let wrongExpected = "2k"
        result = input.roundedString
        XCTAssertNotEqual(expected, result)
        print("testRoundedString is tested successfully")
    }
    
    
    //test 4
    func testGetTitleText() {
        var input = SelectionViewState.petBreed
        var expected = "Please select breed"
        let svc = SelectionViewController(state: input)
        var result = svc.getTitleText(from: input)
        XCTAssertEqual(expected, result)
        print("testGetTitleText() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = SelectionViewState.petGender
        expected = "Please select gender"
        result = svc.getTitleText(from: input)
        XCTAssertEqual(expected, result)
        print("testGetTitleText() is tested successfully. Expected: \(expected); Result: \(result)")
        
        //test for wrong result
        input = SelectionViewState.undefined
        let wrongExpected = "Please select gender"
        result = svc.getTitleText(from: input)
        XCTAssertNotEqual(wrongExpected, result)
        print("testGetTitleText() is tested successfully.")
    }

    
    //test 5
    func testPreferredStatusBarStyle() {
        let input = SettingsViewController(nibName: nil, bundle: nil)
        let expected = UIStatusBarStyle.lightContent
        var result = input.preferredStatusBarStyle
        XCTAssertEqual(expected, result)
        print("testPreferredStatusBarStyle() is tested successfully. Expected: \(expected); Result: \(result)")
        
        //test for wrong result
        let wrongExpected = UIStatusBarStyle.default
        result = input.preferredStatusBarStyle
        XCTAssertNotEqual(wrongExpected, result)
        print("testPreferredStatusBarStyle() is tested successfully.")
    }
    
    
    


}

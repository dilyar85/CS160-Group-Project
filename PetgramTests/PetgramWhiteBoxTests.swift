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
    
    //test 6
    func testGetLabelText() {
        var input = 0
        var expected = "Setup"
        var result = getLabelText(input)
        XCTAssertEqual(expected, result)
        print("testGetLabelText() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = 1
        expected = "Feedback"
        result = getLabelText(input)
        XCTAssertEqual(expected, result)
        print("testGetLabelText() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = 2
        expected = "About"
        result = getLabelText(input)
        XCTAssertEqual(expected, result)
        print("testGetLabelText() is tested successfully. Expected: \(expected); Result: \(result)")
    }
    
    //test 7
    func testStrip() {
        var input = " abc@gmail.com "
        var expected = "abc@gmail.com"
        var result = input.strip()
        XCTAssertEqual(expected, result)
        print("testStrip() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = "   dd@hotmail.com    "
        expected = "dd@hotmail.com"
        result = input.strip()
        XCTAssertEqual(expected, result)
        print("testStrip() is tested successfully. Expected: \(expected); Result: \(result)")
    }
    
    
    //test 8
    func testIsValidEmail() {
        var input = "abc123@gmail.com"
        var expected = true
        var result = input.isValidEmail
        XCTAssertEqual(expected, result)
        print("testIsValidEmail() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = "321321dsa@sdadsa.cnsda"
        expected = true
        result = input.isValidEmail
        XCTAssertEqual(expected, result)
        print("testIsValidEmail() is tested successfully. Expected: \(expected); Result: \(result)")
        
        //start testing for invalid email address
        input = "@sda.com"
        expected = false
        result = input.isValidEmail
        XCTAssertEqual(expected, result)
        print("testIsValidEmail() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = "sadsa.cn"
        expected = false
        result = input.isValidEmail
        XCTAssertEqual(expected, result)
        print("testIsValidEmail() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = "dsaj@gamil."
        expected = false
        result = input.isValidEmail
        XCTAssertEqual(expected, result)
        print("testIsValidEmail() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = "gmail.com"
        expected = false
        result = input.isValidEmail
        XCTAssertEqual(expected, result)
        print("testIsValidEmail() is tested successfully. Expected: \(expected); Result: \(result)")
    }
    
    
    //test 9
    func testSafeGet() {
        let array = [0,1,2,3,4,5]
        var input = 3
        var expected = 3
        var result = array.safeGet(index: input)
        XCTAssertEqual(expected, result)
        print("testSafeGet() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = 5
        expected = 5
        result = array.safeGet(index: input)
        XCTAssertEqual(expected, result)
        print("testSafeGet() is tested successfully. Expected: \(expected); Result: \(result)")
        
        //test for out of boundary index
        input = 6
        let expectedNil : Int? = nil
        result = array.safeGet(index: input)
        XCTAssertEqual(expectedNil, result)
        print("testSafeGet() is tested successfully. Expected: \(expectedNil); Result: \(result)")
    }
    
    //test 10
    func testDateInterval() {
        let noon = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        
        let today = Date()
        var input = Calendar.current.date(byAdding: .day, value: -1, to: noon)!
        var expected = 2
        var result = today.interval(ofComponent: Calendar.Component.day, fromDate: input)
        XCTAssertEqual(expected, result)
        print("testDateInterval() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = Calendar.current.date(byAdding: .day, value: -2, to: noon)!
        expected = 3
        result = today.interval(ofComponent: Calendar.Component.day, fromDate: input)
        XCTAssertEqual(expected, result)
        print("testDateInterval() is tested successfully. Expected: \(expected); Result: \(result)")
    }
    
    //test 11
    func testDateGetString() {
        let date = Date()
        var input = "YYYY-MM-dd"
        var expected = "2018-11-20"
        var result = date.getString(withFormat: input)
        XCTAssertEqual(expected, result)
        print("testDateGetString() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = "MM-dd-YYYY"
        expected = "11-20-2018"
        result = date.getString(withFormat: input)
        XCTAssertEqual(expected, result)
        print("testDateGetString() is tested successfully. Expected: \(expected); Result: \(result)")
    }
    
    //test 12
    func testNavigationImage() {
        var input = NavigationSection.home
        var expected = #imageLiteral(resourceName: "nav_bar_library")
        var result = input.image
        XCTAssertEqual(expected, result)
        print("testNavigationImage() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = NavigationSection.post
        expected = #imageLiteral(resourceName: "nav_bar_browse")
        result = input.image
        XCTAssertEqual(expected, result)
        print("testNavigationImage() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = NavigationSection.profile
        expected = #imageLiteral(resourceName: "nav_bar_me")
        result = input.image
        XCTAssertEqual(expected, result)
        print("testNavigationImage() is tested successfully. Expected: \(expected); Result: \(result)")
    }
    
    //test 13
    func testNavigationSelectedImage() {
        var input = NavigationSection.home
        var expected = #imageLiteral(resourceName: "nav_bar_library_selected")
        var result = input.selectedImage
        XCTAssertEqual(expected, result)
        print("testNavigationSelectedImage() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = NavigationSection.post
        expected = #imageLiteral(resourceName: "nav_bar_browse_selected")
        result = input.selectedImage
        XCTAssertEqual(expected, result)
        print("testNavigationSelectedImage() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = NavigationSection.profile
        expected = #imageLiteral(resourceName: "nav_bar_me_selected")
        result = input.selectedImage
        XCTAssertEqual(expected, result)
        print("testNavigationSelectedImage() is tested successfully. Expected: \(expected); Result: \(result)")
    }
    
    
    //test 14
    func testNavigationName() {
        var input = NavigationSection.home
        var expected = "Home"
        var result = input.name
        XCTAssertEqual(expected, result)
        print("testNavigationSelectedImage() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = NavigationSection.post
        expected = "Post"
        result = input.name
        XCTAssertEqual(expected, result)
        print("testNavigationSelectedImage() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = NavigationSection.profile
        expected = "Mine"
        result = input.name
        XCTAssertEqual(expected, result)
        print("testNavigationSelectedImage() is tested successfully. Expected: \(expected); Result: \(result)")
    }
    
    
    //test 15
    func testDisplayName() {
        var input = OverflowAction.chooseAPicture
        var expected = "Open Photos"
        var result = input.displayName(in: OverflowViewContext.postPicture)
        XCTAssertEqual(expected, result)
        print("testDisplayName() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = OverflowAction.takeAPicture
        expected = "Take Picture"
        result = input.displayName(in: OverflowViewContext.postPicture)
        XCTAssertEqual(expected, result)
        print("testDisplayName() is tested successfully. Expected: \(expected); Result: \(result)")
        
        
    }
    
    
    //test 16    
    func testDisplayImage() {
        var input = OverflowAction.chooseAPicture
        var expected = #imageLiteral(resourceName: "overflow_frame")
        var result = input.image
        XCTAssertEqual(expected, result)
        print("testDisplayImage() is tested successfully. Expected: \(expected); Result: \(result)")
        
        input = OverflowAction.takeAPicture
        expected = #imageLiteral(resourceName: "overflow_camera")
        result = input.image
        XCTAssertEqual(expected, result)
        print("testDisplayImage() is tested successfully. Expected: \(expected); Result: \(result)")
    }
    
    
            
    


}

//
//  PetgramBlackBoxTests.swift
//  PetgramTests
//
//  Created by Saifuding Diliyaer on 11/20/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import XCTest
@testable import Petgram

class PetgramBlackBoxTests: XCTestCase {

    //test case 1
    func testLogin() {
        let server = LeanCloudServerTestingTool()
        server.testLogin()
    }
    
    //test case 2
    func testSignup() {
        let server = LeanCloudServerTestingTool()
        server.testSignup()
    }
    
    //test case 3
    func testLogout() {
        let server = LeanCloudServerTestingTool()
        server.testLogout()
    }
    
    
    //test case 4
    func testFetchingPosts() {
        let server = LeanCloudServerTestingTool()
        server.testFetchingPosts()
    }
    
    //test case 5
    func testSendingPosts() {
        let server = LeanCloudServerTestingTool()
        server.testSendingPosts()
    }
    
    //test case 6
    func testFollowUsers() {
        let server = LeanCloudServerTestingTool()
        server.testFollowUsers()
    }
    
    //test case 7
    func testUnfollowUsers() {
        let server = LeanCloudServerTestingTool()
        server.testUnfollowUsers()
    }
    
    //test case 8
    func testLikeUserPost() {
        let server = LeanCloudServerTestingTool()
        server.testLikeUserPost()
    }
    
    //test case 9
    func testUnlikeUserPost() {
        let server = LeanCloudServerTestingTool()
        server.testUnlikeUserPost()
    }
    
    //test case 10
    func testChangePetName() {
        let server = LeanCloudServerTestingTool()
        server.testChangePetName()
    }
    
    //test case 11
    func testChangePetBreed() {
        let server = LeanCloudServerTestingTool()
        server.testChangePetBreed()
    }
    
    //test case 12
    func testChangePetAdoptionDate() {
        let server = LeanCloudServerTestingTool()
        server.testChangePetAdoptionDate()
    }
    
    //test case 13
    func testChangePetLocation() {
        let server = LeanCloudServerTestingTool()
        server.testChangePetLocation()
    }
    
    //test case 14
    func testViewUserProfile() {
        let server = LeanCloudServerTestingTool()
        server.testViewUserProfile()
    }
    
    //test case 15
    func testViewFollowingsCount() {
        let server = LeanCloudServerTestingTool()
        server.testViewFollowingsCount()
    }
    
    //test case 16
    func testViewFollowersCount() {
        let server = LeanCloudServerTestingTool()
        server.testViewFollowersCount()
    }

}

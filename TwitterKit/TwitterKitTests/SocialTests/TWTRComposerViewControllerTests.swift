//
//  TWTRComposerViewControllerTests.swift
//  TwitterKit
//
//  Created by Steven Hepting on 3/20/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

import XCTest

class TWTRComposerViewControllerTests: XCTestCase {
    
    func testInitNotNil() {
        let composer = TWTRComposerViewController.emptyComposer()
        XCTAssertNotNil(composer)
    }

    func testCorrectClass() {
        let composer = TWTRComposerViewController.emptyComposer() as Any

        XCTAssert(composer is TWTRSharedComposerWrapper)
    }

}

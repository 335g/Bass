//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

import XCTest
import SwiftCheck
@testable import Bass

class MonoidSpec: XCTestCase {
	func testProperties(){
		property("left identity") <- forAll { (i: ArrayOf<Int>) in
			return (.mempty <> i.getArray) == i.getArray
		}
		
		property("right identity") <- forAll { (i: ArrayOf<Int>) in
			return (i.getArray <> .mempty) == i.getArray
		}
		
		property("associativity") <- forAll { (i: ArrayOf<Int>, j: ArrayOf<Int>, k: ArrayOf<Int>) in
			let i2 = i.getArray
			let j2 = j.getArray
			let k2 = k.getArray
			
			return (i2 <> j2) <> k2 == i2 <> (j2 <> k2)
		}
	}
}

//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

import Quick
import Nimble
@testable import Bass

class ReaderSpec: QuickSpec {
	override func spec() {
		
		// MARK: pure:
		describe("pure"){
			it("should return `Reader` that doesn't depend on environment"){
				let value = 1
				let reader: Reader<Int, Int> = .pure(value)
				
				expect(reader.run(10)) == value
				expect(reader.run(100)) == value
			}
		}
		
		// MARK: local:
		describe("local"){
			it("should execute a computation in a modified environment"){
				let reader: Reader<Int, String> = Reader{ String($0) }
				
				let f: Int -> Int = { $0 + 1 }
				let x = 0
				expect(reader.local(f).run(x)) == String(f(x))
			}
		}
		
		// MARK: ask
		describe("ask"){
			it("should fetch the value of the environment"){
				let reader: Reader<Int, Int> = ask()
				
				let x1 = 0
				expect(reader.run(x1)) == x1
				
				let x2 = 1
				expect(reader.run(x2)) == x2
			}
		}
		
		// MARK: asks:
		describe("asks"){
			it("should retrieve a function of the current environment"){
				let reader: Reader<Int, String> = asks{ String($0 + 1) }
				
				let x1 = 0
				expect(reader.run(x1)) == String(x1 + 1)
				
				let x2 = 1
				expect(reader.run(x2)) == String(x2 + 1)
			}
		}
	}
}

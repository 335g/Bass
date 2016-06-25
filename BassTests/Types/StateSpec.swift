//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

import Quick
import Nimble
@testable import Bass

class StaSpec: QuickSpec {
	override func spec() {
		
		// MARK: pure:
		describe("pure"){
			it("should return `State` that doesn't depend on state"){
				let state: State<Int, Int, (Int, Int)> = .pure(1)
				
				expect(state.run(10).value.0) == 1
				expect(state.run(100).value.0) == 1
			}
		}
		
		// MARK: eval:
		describe("eval"){
			it("should return value"){
				let value = 10
				let state: State<Int, Int, (Int, Int)> = .pure(value)
				
				let s = 0
				expect(state.eval(s)) == value
			}
		}
		
		// MARK: exec:
		describe("exec"){
			it("should return state"){
				let value = 10
				let state: State<Int, Int, (Int, Int)> = .pure(value)
				
				let s1 = 0
				expect(state.exec(s1)) == s1
				
				let s2 = 1
				expect(state.exec(s2)) == s2
			}
		}
		
		// MARK: with:
		describe("with"){
			it("should change state with func"){
				let state: State<Int, Int, (Int, Int)> = .pure(10)
				
				let s = 0
				let f: Int -> Int = { return $0 + 1 }
				expect(state.with(f).exec(s)) == f(s)
			}
		}
		
		// MARK: get
		describe("get"){
			it("should return the `State` that have a value the same as state"){
				let state: State<Int, Int, (Int, Int)> = get()
				
				let s1 = 1
				expect(state.eval(s1)) == s1
				expect(state.exec(s1)) == s1
				
				let s2 = 10
				expect(state.eval(s2)) == s2
				expect(state.exec(s2)) == s2
			}
		}
		
		// MARK: put:
		describe("put"){
			it("should return the `State` that update the state"){
				let s1 = 0
				let s2 = 1
				let state: State<Int, (), ((), Int)> = put(s1)
				expect(state.exec(s2)) == s1
			}
		}
		
		// MARK: gets:
		describe("gets"){
			it("should return the `State` that update the value with function"){
				let state: State<Int, Int, (Int, Int)> = gets{ $0 + 1 }
				let s = 0
				expect(state.exec(s)) == s
				expect(state.eval(s)) == s + 1
			}
		}
		
		// MARK: modify:
		describe("modify"){
			it("should return the `State` that modify the state"){
				let state: State<Int, (), ((), Int)> = modify{ $0 + 1 }
				let s = 0
				expect(state.exec(s)) == s + 1
			}
		}
		
		// MARK: map:
		describe("map"){
			it("should map the value"){
				let value = 10
				let state1: State<Int, Int, (Int, Int)> = .pure(value)
				let state2 = state1.map(String.init)
				expect(state2.eval(0)) == String(value)
			}
		}
		
		// MARK: map2:
		describe("map2"){
			it("should map the value with updating state"){
				let value = 10
				let state1: State<Int, Int, (Int, Int)> = .pure(value)
				
				let state2 = state1.map{ a, b in
					return (String(a), b + 1)
				}
				
				let s = 0
				expect(state2.eval(s)) == String(value)
				expect(state2.exec(s)) == s + 1
			}
		}
		
		// MARK: flatMap:
		describe("flatMap"){
			it("should map the value"){
				let value = 0
				let state1: State<Int, Int, (Int, Int)> = .pure(value)
				
				let state2 = state1.flatMap{ .pure(String($0)) }
				
				let s = 1
				expect(state2.eval(s)) == String(value)
			}
		}
		
		// MARK: <*>
		describe("<*>"){
			it("can give the `State` with appricative expression"){
				let ope: ([Int], (Int, Int) -> Int) -> [Int] = { list, f in
					(lift(f) <*> pop() <*> pop() >>- push).exec(list)
				}
				
				expect(ope([1,2,3,4], +)) == [3,3,4]
				expect(ope([4,5,6,7,8], -)) == [-1,6,7,8]
			}
		}
	}
}

private func push<A>(x: A) -> State<[A], (), ((), [A])> {
	return get() >>- {
		var list = $0
		list.insert(x, atIndex: 0)
		return put(list)
	}
}

private func pop<A>() -> State<[A], A, (A, [A])> {
	return get() >>- {
		guard let first = $0.first else {
			fatalError()
		}
		
		return put(Array($0.dropFirst())) >>- const( .pure(first) )
	}
}

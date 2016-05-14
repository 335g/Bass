//  Copyright © 2016年 Yoshiki Kudo. All rights reserved.

// MARK: - StateType

public protocol StateType: Pointed {
	associatedtype StateS
	associatedtype ResultS
	associatedtype ValuesS = (ResultS, StateS)
	
	var run: StateS -> Identity<ValuesS> { get }
	init(_ run: StateS -> Identity<ValuesS>)
}

// MARK: - StateType: Pointed

public extension StateType {
	public typealias PointedValue = ResultS
	
	public static func pure(a: ResultS) -> Self {
		let values: StateS -> Identity<ValuesS> = {
			let values = (a, $0) as! ValuesS
			return Identity(values)
		}
		
		return Self.init(values)
	}
}

// MARK: - StateType - method

public extension StateType where ValuesS == (ResultS, StateS) {
	
	/// Evaluate a state computation with the given initial state and
	/// return the final value, discarding the final state.
	public func eval(state: StateS) -> ResultS {
		return run(state).value.0
	}
	
	/// Evaluate a state computation with the given initial state and
	/// return the final state, discarding the final value.
	public func exec(state: StateS) -> StateS {
		return run(state).value.1
	}
	
	/// `with(f:)` executes action on a state modified by applying `f`.
	public func with(f: StateS -> StateS) -> Self {
		return Self.init{ self.run(f($0)) }
	}
}

// MARK: - State

public struct State<S, A, V> {
	public let run: S -> Identity<V>
}

// MARK: - State: StateType

extension State: StateType {
	public typealias StateS = S
	public typealias ResultS = A
	public typealias ValuesS = V
	
	public init(_ run: S -> Identity<V>) {
		self.run = run
	}
}

// MARK: - State: Pointed

public extension State {
	public typealias PointedValue = A
}

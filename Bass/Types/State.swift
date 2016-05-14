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

// MARK: - StateType - map/flatMap

public extension StateType where ValuesS == (ResultS, StateS) {
	
	public func map<Result2>(f: (ResultS, StateS) -> (Result2, StateS)) -> State<StateS, Result2, (Result2, StateS)> {
		return State {
			let (r, s) = self.run($0).value
			return Identity(f(r, s))
		}
	}
	
	public func map<Result2>(f: ResultS -> Result2) -> State<StateS, Result2, (Result2, StateS)> {
		return map { r, s in (f(r), s) }
	}
	
	public func flatMap<Result2>(g: ResultS -> State<StateS, Result2, (Result2, StateS)>) -> State<StateS, Result2, (Result2, StateS)> {
		return State { s in
			self.run(s).map { g($0).run($1).value }
		}
	}
}

public func <^> <S, R1, R2, ST: StateType where ST.StateS == S, ST.ResultS == R1, ST.ValuesS == (R1, S)>(f: R1 -> R2, state: ST) -> State<S, R2, (R2, S)> {
	return state.map(f)
}

public func >>- <S, R1, R2, ST: StateType where ST.StateS == S, ST.ResultS == R1, ST.ValuesS == (R1, S)>(state: ST, f: R1 -> State<S, R2, (R2, S)>) -> State<S, R2, (R2, S)> {
	return state.flatMap(f)
}

// MARK: - StateType (ValuesS: OptionalType) - map/flatMap

public extension StateType where ValuesS == (ResultS, StateS)? {
	
	public func map<Result2>(f: (ResultS, StateS) -> (Result2, StateS)) -> State<StateS, Result2, (Result2, StateS)?> {
		return State {
			return Identity(f <^> self.run($0).value)
		}
	}
	
	public func map<Result2>(f: ResultS -> Result2) -> State<StateS, Result2, (Result2, StateS)?> {
		return map { r, s in (f(r), s) }
	}
	
	public func flatMap<Result2>(g: ResultS -> State<StateS, Result2, (Result2, StateS)>) -> State<StateS, Result2, (Result2, StateS)?> {
		return State { s in
			self.run(s).map { g($0).run($1).value }
		}
	}
}

public func <^> <S, R1, R2, ST: StateType where ST.StateS == S, ST.ResultS == R1, ST.ValuesS == (R1, S)?>(f: R1 -> R2, state: ST) -> State<S, R2, (R2, S)?> {
	return state.map(f)
}

public func >>- <S, R1, R2, ST: StateType where ST.StateS == S, ST.ResultS == R1, ST.ValuesS == (R1, S)?>(state: ST, f: R1 -> State<S, R2, (R2, S)>) -> State<S, R2, (R2, S)?> {
	return state.flatMap(f)
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

// MARK: - Functions

/// Fetch the current value of the state within the monad.
public func get<S>() -> State<S, S, (S, S)> {
	return State { Identity($0, $0) }
}

/// `put(state:)` sets the state within the monad to `s`
public func put<S>(state: S) -> State<S, (), ((), S)> {
	return State { _ in Identity((), state) }
}

/// Get a specific component of the state, using a projection function supplied.
public func gets<S, A>(f: S -> A) -> State<S, A, (A, S)> {
	return State { Identity(f($0), $0) }
}

/// `modify(f:)` is an action that updates the state to the result of applying `f`
/// to the current state.
public func modify<S>(f: S -> S) -> State<S, (), ((), S)> {
	return State { Identity((), f($0)) }
}

/// A variant of `modify(f:)` in which the computation is strict in the new state.
public func modify2<S>(f: S -> S) -> State<S, (), ((), S)> {
	return get() >>- { put(f($0)) }
}

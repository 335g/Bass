//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

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
		return Self.init {
			Identity((a, $0) as! ValuesS)
		}
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
		return Self.init {
			self.run(f($0))
		}
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
			self.run(s).map{ g($0).run($1).value }
		}
	}
	
	public func ap<Result2, ST: StateType where ST.StateS == StateS, ST.ResultS == ResultS -> Result2, ST.ValuesS == (ResultS -> Result2, StateS)>(fn: ST) -> State<StateS, Result2, (Result2, StateS)> {
		return State { s in
			fn.run(s).flatMap{ f, s2 in
				self.run(s2).map{ (f($0), $1) }
			}
		}
	}
}

/// Alias for `map(f:)`
public func <^> <S, R1, R2, ST: StateType where ST.StateS == S, ST.ResultS == R1, ST.ValuesS == (R1, S)>(f: R1 -> R2, state: ST) -> State<S, R2, (R2, S)> {
	return state.map(f)
}

/// Alias for `flatMap(g:)`
public func >>- <S, R1, R2, ST: StateType where ST.StateS == S, ST.ResultS == R1, ST.ValuesS == (R1, S)>(state: ST, f: R1 -> State<S, R2, (R2, S)>) -> State<S, R2, (R2, S)> {
	return state.flatMap(f)
}

/// Alias for `ap(fn:)`
public func <*> <S, R1, R2, ST1: StateType, ST2: StateType where ST1.StateS == S, ST1.ResultS == R1 -> R2, ST1.ValuesS == (R1 -> R2, S), ST2.StateS == S, ST2.ResultS == R1, ST2.ValuesS == (R1, S)>(fn: ST1, g: ST2) -> State<S, R2, (R2, S)> {
	return g.ap(fn)
}

// MARK: - StateType (ValuesS: OptionalType) - map/flatMap

public extension StateType where ValuesS == (ResultS, StateS)? {
	
	public func map<Result2>(f: (ResultS, StateS) -> (Result2, StateS)) -> State<StateS, Result2, (Result2, StateS)?> {
		return State {
			Identity(f <^> self.run($0).value)
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
	
	public func ap<Result2, ST: StateType where ST.StateS == StateS, ST.ResultS == ResultS -> Result2, ST.ValuesS == (ResultS -> Result2, StateS)>(fn: ST) -> State<StateS, Result2, (Result2, StateS)?> {
		return State { s in
			fn.run(s).flatMap{ f, s2 in
				self.run(s2).map{ (f($0), $1) }
			}
		}
	}
}

/// Alias for `map(f:)`
public func <^> <S, R1, R2, ST: StateType where ST.StateS == S, ST.ResultS == R1, ST.ValuesS == (R1, S)?>(f: R1 -> R2, state: ST) -> State<S, R2, (R2, S)?> {
	return state.map(f)
}

/// Alias for `flatMap(g:)`
public func >>- <S, R1, R2, ST: StateType where ST.StateS == S, ST.ResultS == R1, ST.ValuesS == (R1, S)?>(state: ST, f: R1 -> State<S, R2, (R2, S)>) -> State<S, R2, (R2, S)?> {
	return state.flatMap(f)
}

/// Alias for `ap(fn:)`
public func <*> <S, R1, R2, ST1: StateType, ST2: StateType where ST1.StateS == S, ST1.ResultS == R1 -> R2, ST1.ValuesS == (R1 -> R2, S), ST2.StateS == S, ST2.ResultS == R1, ST2.ValuesS == (R1, S)?>(fn: ST1, g: ST2) -> State<S, R2, (R2, S)?> {
	return g.ap(fn)
}

// MAKR: - State - Kleisli

public func >>->> <S, A, B, C>(left: A -> State<S, B, (B, S)>, right: B -> State<S, C, (C, S)>) -> A -> State<S, C, (C, S)> {
	return { left($0) >>- right }
}

public func <<-<< <S, A, B, C>(left: B -> State<S, C, (C, S)>, right: A -> State<S, B, (B, S)>) -> A -> State<S, C, (C, S)> {
	return right >>->> left
}

// MARK: - Lift

public func lift<S, A, B, C>(f: (A, B) -> C) -> State<S, A -> B -> C, (A -> B -> C, S)> {
	return .pure(curry(f))
}

public func lift<S, A, B, C, D>(f: (A, B, C) -> D) -> State<S, A -> B -> C -> D, (A -> B -> C -> D, S)> {
	return .pure(curry(f))
}

public func lift<S, A, B, C, D, E>(f: (A, B, C, D) -> E) -> State<S, A -> B -> C -> D -> E, (A -> B -> C -> D -> E, S)> {
	return .pure(curry(f))
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
	return State {
		Identity($0, $0)
	}
}

/// `put(state:)` sets the state within the monad to `s`
public func put<S>(state: S) -> State<S, (), ((), S)> {
	return State { _ in
		Identity((), state)
	}
}

/// Get a specific component of the state, using a projection function supplied.
public func gets<S, A>(f: S -> A) -> State<S, A, (A, S)> {
	return State {
		Identity(f($0), $0)
	}
}

/// `modify(f:)` is an action that updates the state to the result of applying `f`
/// to the current state.
public func modify<S>(f: S -> S) -> State<S, (), ((), S)> {
	return State {
		Identity((), f($0))
	}
}

/// A variant of `modify(f:)` in which the computation is strict in the new state.
public func modify2<S>(f: S -> S) -> State<S, (), ((), S)> {
	return get() >>- { put(f($0)) }
}

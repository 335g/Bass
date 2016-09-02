//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - StateType

public protocol StateType: Pointed {
	associatedtype StaS
	associatedtype ResS
	associatedtype ValS = (ResS, StaS)
	
	var run: (StaS) -> Identity<ValS> { get }
	init(_ run: @escaping (StaS) -> Identity<ValS>)
}

// MARK: - StateType: Pointed

public extension StateType {
	public typealias Value = ResS
	
	public static func pure(_ a: ResS) -> Self {
		return Self.init {
			Identity((a, $0) as! ValS)
		}
	}
}

// MARK: - StateType - method

public extension StateType where ValS == (ResS, StaS) {
	
	/// Evaluate a state computation with the given initial state and
	/// return the final value, discarding the final state.
	public func eval(_ state: StaS) -> ResS {
		return run(state).value.0
	}
	
	/// Evaluate a state computation with the given initial state and
	/// return the final state, discarding the final value.
	public func exec(_ state: StaS) -> StaS {
		return run(state).value.1
	}
	
	/// `with(f:)` executes action on a state modified by applying `f`.
	public func with(_ f: @escaping (StaS) -> StaS) -> Self {
		return Self.init {
			self.run(f($0))
		}
	}
}

// MARK: - StateType - map/flatMap

public extension StateType where ValS == (ResS, StaS) {
	public func map<Result2>(_ f: @escaping (ResS, StaS) -> (Result2, StaS)) -> State<StaS, Result2, (Result2, StaS)> {
		return State {
			let (r, s) = self.run($0).value
			
			return Identity(f(r, s))
		}
	}
	
	public func map<Result2>(_ f: @escaping (ResS) -> Result2) -> State<StaS, Result2, (Result2, StaS)> {
		return map { r, s in (f(r), s) }
	}
	
	public func flatMap<Result2>(_ fn: @escaping (ResS) -> State<StaS, Result2, (Result2, StaS)>) -> State<StaS, Result2, (Result2, StaS)> {
		return State { s in
			self.run(s).map{ fn($0).run($1).value }
		}
	}
	
	public func ap<Result2, ST: StateType>(_ fn: ST) -> State<StaS, Result2, (Result2, StaS)>
		where ST.StaS == StaS, ST.ResS == (ResS) -> Result2, ST.ValS == ((ResS) -> Result2, StaS) {
		
			return State { s in
				fn.run(s).flatMap{ f, s2 in
					self.run(s2).map{ (f($0), $1) }
				}
			}
	}
}

/// Alias for `map(f:)`
public func <^> <S, R1, R2, ST: StateType>(_ f: @escaping (R1) -> R2, state: ST) -> State<S, R2, (R2, S)>
	where ST.StaS == S, ST.ResS == R1, ST.ValS == (R1, S) {
		
		return state.map(f)
}

/// Alias for `flatMap(g:)`
public func >>- <S, R1, R2, ST: StateType>(_ state: ST, _ f: @escaping (R1) -> State<S, R2, (R2, S)>) -> State<S, R2, (R2, S)>
	where ST.StaS == S, ST.ResS == R1, ST.ValS == (R1, S) {
	
		return state.flatMap(f)
}

/// Alias for `ap(fn:)`
public func <*> <S, R1, R2, ST1: StateType, ST2: StateType>(_ fn: ST1, _ g: ST2) -> State<S, R2, (R2, S)>
	where ST1.StaS == S, ST1.ResS == (R1) -> R2, ST1.ValS == ((R1) -> R2, S), ST2.StaS == S, ST2.ResS == R1, ST2.ValS == (R1, S) {
		
		return g.ap(fn)
}

// MARK: - StateType (ValS: OptionalType) - map/flatMap

public extension StateType where ValS == (ResS, StaS)? {
	
	public func map<Result2>(_ f: @escaping (ResS, StaS) -> (Result2, StaS)) -> State<StaS, Result2, (Result2, StaS)?> {
		return State {
			Identity(f <^> self.run($0).value)
		}
	}
	
	public func map<Result2>(_ f: @escaping (ResS) -> Result2) -> State<StaS, Result2, (Result2, StaS)?> {
		return map { r, s in (f(r), s) }
	}
	
	public func flatMap<Result2>(_ fn: @escaping (ResS) -> State<StaS, Result2, (Result2, StaS)>) -> State<StaS, Result2, (Result2, StaS)?> {
		return State { s in
			self.run(s).map { fn($0).run($1).value }
		}
	}
	
	public func ap<Result2, ST: StateType>(_ fn: ST) -> State<StaS, Result2, (Result2, StaS)?> where ST.StaS == StaS, ST.ResS == (ResS) -> Result2, ST.ValS == ((ResS) -> Result2, StaS) {
		return State { s in
			fn.run(s).flatMap{ f, s2 in
				self.run(s2).map{ (f($0), $1) }
			}
		}
	}
}

/// Alias for `map(f:)`
public func <^> <S, R1, R2, ST: StateType>(_ f: @escaping (R1) -> R2, _ state: ST) -> State<S, R2, (R2, S)?> where ST.StaS == S, ST.ResS == R1, ST.ValS == (R1, S)? {
	return state.map(f)
}

/// Alias for `flatMap(g:)`
public func >>- <S, R1, R2, ST: StateType>(_ state: ST, _ f: @escaping (R1) -> State<S, R2, (R2, S)>) -> State<S, R2, (R2, S)?> where ST.StaS == S, ST.ResS == R1, ST.ValS == (R1, S)? {
	return state.flatMap(f)
}

/// Alias for `ap(fn:)`
public func <*> <S, R1, R2, ST1: StateType, ST2: StateType>(_ fn: ST1, _ g: ST2) -> State<S, R2, (R2, S)?> where ST1.StaS == S, ST1.ResS == (R1) -> R2, ST1.ValS == ((R1) -> R2, S), ST2.StaS == S, ST2.ResS == R1, ST2.ValS == (R1, S)? {
	return g.ap(fn)
}

// MAKR: - State - Kleisli

public func >>->> <S, A, B, C>(_ left: @escaping (A) -> State<S, B, (B, S)>, _ right: @escaping (B) -> State<S, C, (C, S)>) -> (A) -> State<S, C, (C, S)> {
	return { left($0) >>- right }
}

public func <<-<< <S, A, B, C>(_ left: @escaping (B) -> State<S, C, (C, S)>, _ right: @escaping (A) -> State<S, B, (B, S)>) -> (A) -> State<S, C, (C, S)> {
	return right >>->> left
}

// MARK: - Lift

public func lift<S, A, B, C>(_ f: @escaping (A, B) -> C) -> State<S, (A) -> (B) -> C, ((A) -> (B) -> C, S)> {
	return .pure(curry(f))
}

public func lift<S, A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> State<S, (A) -> (B) -> (C) -> D, ((A) -> (B) -> (C) -> D, S)> {
	return .pure(curry(f))
}

public func lift<S, A, B, C, D, E>(_ f: @escaping (A, B, C, D) -> E) -> State<S, (A) -> (B) -> (C) -> (D) -> E, ((A) -> (B) -> (C) -> (D) -> E, S)> {
	return .pure(curry(f))
}

// MARK: - State

public struct State<S, A, V> {
	public let run: (S) -> Identity<V>
}

// MARK: - State: StateType

extension State: StateType {
	public typealias StaS = S
	public typealias ResS = A
	public typealias ValS = V
	
	public init(_ run: @escaping (S) -> Identity<V>) {
		self.run = run
	}
}

// MARK: - State: Pointed

public extension State {
	public typealias Value = A
}

// MARK: - Functions

/// Fetch the current value of the state within the monad.
public func get<S>() -> State<S, S, (S, S)> {
	return State {
		Identity($0, $0)
	}
}

/// `put(state:)` sets the state within the monad to `s`
public func put<S>(_ state: S) -> State<S, (), ((), S)> {
	return State { _ in
		Identity((), state)
	}
}

/// Get a specific component of the state, using a projection function supplied.
public func gets<S, A>(_ f: @escaping (S) -> A) -> State<S, A, (A, S)> {
	return State {
		Identity(f($0), $0)
	}
}

/// `modify(f:)` is an action that updates the state to the result of applying `f`
/// to the current state.
public func modify<S>(_
	f: @escaping (S) -> S) -> State<S, (), ((), S)> {
	return State {
		Identity((), f($0))
	}
}

/// A variant of `modify(f:)` in which the computation is strict in the new state.
public func modify2<S>(_ f: @escaping (S) -> S) -> State<S, (), ((), S)> {
	return get() >>- { put(f($0)) }
}

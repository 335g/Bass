//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - ReaderType

public protocol ReaderType: Pointed {
	associatedtype EnvR
	associatedtype ValR
	
	var run: (EnvR) -> ValR { get }
	init(_ run: (EnvR) -> ValR)
	
	var reader: Reader<EnvR, ValR> { get }
}

// MARK: - ReaderType: Pointed

public extension ReaderType {
	public typealias Value = ValR
	
	public static func pure(_ a: ValR) -> Self {
		return Self.init { _ in a }
	}
}

// MARK: - ReaderType - method

public extension ReaderType {
	public func local(_ f: (EnvR) -> EnvR) -> Self {
		return Self.init { self.run(f($0)) }
	}
}

// MARK: - ReaderType - map/flatMap/ap

public extension ReaderType {
	public func map<Value2>(_ f: (ValR) -> Value2) -> Reader<EnvR, Value2> {
		return Reader { f(self.run($0)) }
	}
	
	public func flatMap<Value2>(_ fn: (ValR) -> Reader<EnvR, Value2>) -> Reader<EnvR, Value2> {
		return Reader { fn(self.run($0)).run($0) }
	}
	
	public func ap<A, RT: ReaderType where RT.EnvR == EnvR, RT.ValR == (ValR) -> A>(_ fn: RT) -> Reader<EnvR, A> {
		return self >>- { m in fn >>- { f in .pure(f(m)) } }
	}
}

/// Alias for `map(f:)`
public func <^> <R, A, B, RT: ReaderType where RT.EnvR == R, RT.ValR == A>(_ f: (A) -> B, _ g: RT) -> Reader<R, B> {
	return g.map(f)
}

/// Alias for `flatMap(g:)`
public func >>- <R, A, B, RT: ReaderType where RT.EnvR == R, RT.ValR == A>(_ m: RT, _ fn: (A) -> Reader<R, B>) -> Reader<R, B> {
	return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
public func <*> <R, A, B, RT1: ReaderType, RT2: ReaderType where RT1.EnvR == R, RT1.ValR == (A) -> B, RT2.EnvR == R, RT2.ValR == A>(_ fn: RT1, _ g: RT2) -> Reader<R, B> {
	return g.ap(fn)
}

// MARK: - ReaderType (ValR: OptionalType) - map/flatMap/ap

public extension ReaderType where ValR: OptionalType {
	public func map<Value2>(_ f: (ValR.Wrapped) -> Value2) -> Reader<EnvR, Value2?> {
		return Reader { f <^> self.run($0) }
	}
	
	public func flatMap<Value2>(_ fn: (ValR.Wrapped) -> Reader<EnvR, Value2>) -> Reader<EnvR, Value2?> {
		return Reader { (self.run($0) >>- fn)?.run($0) }
	}
	
	public func ap<A, RT: ReaderType where RT.EnvR == EnvR, RT.ValR == (ValR.Wrapped) -> A>(_ fn: RT) -> Reader<EnvR, A?> {
		return self >>- { m in fn >>- { f in .pure(f(m)) } }
	}
}

/// Alias for `map(f:)`
public func <^> <R, A: OptionalType, B, RT: ReaderType where RT.EnvR == R, RT.ValR == A>(_ f: (A) -> B, _ g: RT) -> Reader<R, B?> {
	return g.map(f)
}

/// Alias for `flatMap(fn:)`
public func >>- <R, A: OptionalType, B, RT: ReaderType where RT.EnvR == R, RT.ValR == A>(_ m: RT, _ fn: (A.Wrapped) -> Reader<R, B>) -> Reader<R, B?> {
	return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
public func <*> <R, A: OptionalType, B, RT1: ReaderType, RT2: ReaderType where RT1.EnvR == R, RT1.ValR == (A.Wrapped) -> B, RT2.EnvR == R, RT2.ValR == A>(_ fn: RT1, _ g: RT2) -> Reader<R, B?> {
	return g.ap(fn)
}

// MARK: - Reader - Kleisli

public func >>->> <R, A, B, C>(_ left: (A) -> Reader<R, B>, _ right: (B) -> Reader<R, C>) -> (A) -> Reader<R, C> {
	return { left($0) >>- right }
}

public func <<-<< <R, A, B, C>(_ left: (B) -> Reader<R, C>, _ right: (A) -> Reader<R, B>) -> (A) -> Reader<R, C> {
	return right >>->> left
}

// MARK: - Lift

public func lift<S, A, B, C>(_ f: (A, B) -> C) -> Reader<S, (A) -> (B) -> C> {
	return .pure(curry(f))
}

public func lift<S, A, B, C, D>(_ f: (A, B, C) -> D) -> Reader<S, (A) -> (B) -> (C) -> D> {
	return .pure(curry(f))
}

public func lift<S, A, B, C, D, E>(_ f: (A, B, C, D) -> E) -> Reader<S, (A) -> (B) -> (C) -> (D) -> E> {
	return .pure(curry(f))
}

// MARK: - Reader

public struct Reader<R, A> {
	public let run: (R) -> A
}

// MARK: - Reader: ReaderType

extension Reader: ReaderType {
	public init(_ run: (R) -> A) {
		self.run = run
	}
	
	public var reader: Reader<R, A> {
		return self
	}
}

// MARK: - Reader: Pointed

public extension Reader {
	public typealias Value = A
}

// MARK: - Functions

/// Fetch the value of the environment
public func ask<R>() -> Reader<R, R> {
	return Reader(id)
}

/// Retrieve a function of the current environment.
public func asks<R, A>(_ f: (R) -> A) -> Reader<R, A> {
	return Reader(f)
}


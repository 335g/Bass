//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - ReaderType

public protocol ReaderType: Pointed {
	associatedtype EnvR
	associatedtype ValueR
	
	var run: EnvR -> ValueR { get }
	init(_ run: EnvR -> ValueR)
	
	var reader: Reader<EnvR, ValueR> { get }
}

// MARK: - ReaderType: Pointed

public extension ReaderType {
	public typealias PointedValue = ValueR
	
	public static func pure(a: ValueR) -> Self {
		return Self.init { _ in a }
	}
}

// MARK: - ReaderType - method

public extension ReaderType {
	public func local(f: EnvR -> EnvR) -> Self {
		return Self.init { self.run(f($0)) }
	}
}

// MARK: - ReaderType - map/flatMap/ap

public extension ReaderType {
	public func map<Value2>(f: ValueR -> Value2) -> Reader<EnvR, Value2> {
		return Reader { f(self.run($0)) }
	}
	
	public func flatMap<Value2>(fn: ValueR -> Reader<EnvR, Value2>) -> Reader<EnvR, Value2> {
		return Reader { fn(self.run($0)).run($0) }
	}
	
	public func ap<A, RT: ReaderType where RT.EnvR == EnvR, RT.ValueR == ValueR -> A>(fn: RT) -> Reader<EnvR, A> {
		return self >>- { m in fn >>- { f in .pure(f(m)) } }
	}
}

/// Alias for `map(f:)`
public func <^> <R, A, B, RT: ReaderType where RT.EnvR == R, RT.ValueR == A>(f: A -> B, g: RT) -> Reader<R, B> {
	return g.map(f)
}

/// Alias for `flatMap(g:)`
public func >>- <R, A, B, RT: ReaderType where RT.EnvR == R, RT.ValueR == A>(m: RT, fn: A -> Reader<R, B>) -> Reader<R, B> {
	return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
public func <*> <R, A, B, RT1: ReaderType, RT2: ReaderType where RT1.EnvR == R, RT1.ValueR == A -> B, RT2.EnvR == R, RT2.ValueR == A>(fn: RT1, g: RT2) -> Reader<R, B> {
	return g.ap(fn)
}

// MARK: - ReaderType (ValueR: OptionalType) - map/flatMap/ap

public extension ReaderType where ValueR: OptionalType {
	public func map<Value2>(f: ValueR.Wrapped -> Value2) -> Reader<EnvR, Value2?> {
		return Reader { f <^> self.run($0) }
	}
	
	public func flatMap<Value2>(fn: ValueR.Wrapped -> Reader<EnvR, Value2>) -> Reader<EnvR, Value2?> {
		return Reader { (self.run($0) >>- fn)?.run($0) }
	}
	
	public func ap<A, RT: ReaderType where RT.EnvR == EnvR, RT.ValueR == ValueR.Wrapped -> A>(fn: RT) -> Reader<EnvR, A?> {
		return self >>- { m in fn >>- { f in .pure(f(m)) } }
	}
}

/// Alias for `map(f:)`
public func <^> <R, A: OptionalType, B, RT: ReaderType where RT.EnvR == R, RT.ValueR == A>(f: A -> B, g: RT) -> Reader<R, B?> {
	return g.map(f)
}

/// Alias for `flatMap(fn:)`
public func >>- <R, A: OptionalType, B, RT: ReaderType where RT.EnvR == R, RT.ValueR == A>(m: RT, fn: A.Wrapped -> Reader<R, B>) -> Reader<R, B?> {
	return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
public func <*> <R, A: OptionalType, B, RT1: ReaderType, RT2: ReaderType where RT1.EnvR == R, RT1.ValueR == A.Wrapped -> B, RT2.EnvR == R, RT2.ValueR == A>(fn: RT1, g: RT2) -> Reader<R, B?> {
	return g.ap(fn)
}

// MARK: - ReaderType - Kleisli

public func >>->> <R, A, B, C>(left: A -> Reader<R, B>, right: B -> Reader<R, C>) -> A -> Reader<R, C> {
	return { left($0) >>- right }
}

public func <<-<< <R, A, B, C>(left: B -> Reader<R, C>, right: A -> Reader<R, B>) -> A -> Reader<R, C> {
	return right >>->> left
}

// MARK: - Reader

public struct Reader<R, A> {
	public let run: R -> A
}

// MARK: - Reader: ReaderType

extension Reader: ReaderType {
	public init(_ run: R -> A) {
		self.run = run
	}
	
	public var reader: Reader<R, A> {
		return self
	}
}

// MARK: - Reader: Pointed

public extension Reader {
	public typealias PointedValue = A
}

// MARK: - Functions

/// Fetch the value of the environment
public func ask<R>() -> Reader<R, R> {
	return Reader(id)
}

/// Retrieve a function of the current environment.
public func asks<R, A>(f: R -> A) -> Reader<R, A> {
	return Reader(f)
}


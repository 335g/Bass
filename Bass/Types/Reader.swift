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
	public typealias PointedValue = EnvR -> ValueR
	
	public static func pure(a: EnvR -> ValueR) -> Self {
		return Self.init(a)
	}
}

// MARK: - ReaderType - method

public extension ReaderType {
	public func local(f: EnvR -> EnvR) -> Self {
		return Self.init { self.run(f($0)) }
	}
}

// MARK: - ReaderType - map/flatMap

public extension ReaderType {
	public func map<Value2>(f: ValueR -> Value2) -> Reader<EnvR, Value2> {
		return Reader { f(self.run($0)) }
	}
	
	public func flatMap<Value2>(fn: ValueR -> Reader<EnvR, Value2>) -> Reader<EnvR, Value2> {
		return Reader { fn(self.run($0)).run($0) }
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

// MARK: - ReaderType (ValueR: OptionalType) - map/flatMap

public extension ReaderType where ValueR: OptionalType {
	public func map<Value2>(f: ValueR.Wrapped -> Value2) -> Reader<EnvR, Value2?> {
		return Reader { f <^> self.run($0) }
	}
	
	public func flatMap<Value2>(fn: ValueR.Wrapped -> Reader<EnvR, Value2>) -> Reader<EnvR, Value2?> {
		return Reader { (self.run($0) >>- fn)?.run($0) }
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
	public typealias PointedValue = R -> A
}


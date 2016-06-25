//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - WriterType

public protocol WriterType: Pointed {
	associatedtype OutW: Monoid
	associatedtype ResW
	associatedtype ValW = (ResW, OutW)
	
	var run: Identity<ValW> { get }
	init(_ run: Identity<ValW>)
}

// MARK: - WriterType: Pointed

public extension WriterType {
	public typealias Value = ResW
	
	public static func pure(_ a: ResW) -> Self {
		let values = (a, OutW.mempty) as! ValW
		return Self.init( Identity(values) )
	}
}

// MARK: - WriterType - method

public extension WriterType where ValW == (ResW, OutW) {
	public var exec: OutW {
		return run.value.1
	}
	
	/// `listen()` is an action that executes the action and adds its
	/// output to the value of the computation.
	public func listen() -> Writer<OutW, (ResW, OutW), ((ResW, OutW), OutW)> {
		let (r, o) = run.value
		return Writer( Identity((r, o), o) )
	}
	
	/// `listens(f:)` is an action that executes the action and adds the result
	/// of applying `f` to the output to the value of the computation.
	public func listens<Result2>(_ f: (OutW) -> Result2) -> Writer<OutW, (ResW, Result2), ((ResW, Result2), OutW)> {
		let (r, o) = run.value
		return Writer( Identity((r, f(o)), o) )
	}
	
	/// `censor(f:)` is an action that executes the action and applies the function `f`
	/// to its output, leaving the return value unchanged.
	public func censor(_ f: (OutW) -> OutW) -> Writer<OutW, ResW, (ResW, OutW)> {
		let (r, o) = run.value
		return Writer( Identity(r, f(o)) )
	}
}

public extension WriterType where ValW == ((ResW, (OutW) -> OutW), OutW) {
	/// `pass` is an action that executes the action, which returns
	/// a value and a function, and return the value, applying the function to the output.
	public func pass() -> Writer<OutW, ResW, (ResW, OutW)> {
		let ((r, f), o) = run.value
		return Writer( Identity(r, f(o)) )
	}
}

// MARK: - WriterType - map/flatMap/ap

public extension WriterType where ValW == (ResW, OutW) {
	public func map<Result2, Output2: Monoid>(_ f: (ResW, OutW) -> (Result2, Output2)) -> Writer<Output2, Result2, (Result2, Output2)> {
		return Writer(f <^> run)
	}
	
	public func map<Result2>(_ f: (ResW) -> Result2) -> Writer<OutW, Result2, (Result2, OutW)> {
		return map { (f($0), $1) }
	}
	
	public func flatMap<Result2>(_ fn: (ResW) -> Writer<OutW, Result2, (Result2, OutW)>) -> Writer<OutW, Result2, (Result2, OutW)> {
		let f2: (ResW, OutW) -> (Result2, OutW) = { r, o in
			let (r2, o2) = fn(r).run.value
			return (r2, o.mappend(o2))
		}
		
		let (r, o) = run.value
		let (r2, o2) = f2(r, o)
		
		return Writer( .pure(r2, o2) )
	}
	
	public func ap<Result2, WT: WriterType where WT.ResW == (ResW) -> Result2, WT.OutW == OutW, WT.ValW == ((ResW) -> Result2, OutW)>(_ fn: WT) -> Writer<OutW, Result2, (Result2, OutW)> {
		return self >>- { m in fn >>- { f in .pure(f(m)) } }
	}
}

/// Alias for `map(f:)`
public func <^> <M: Monoid, T1, T2, WT: WriterType where WT.OutW == M, WT.ResW == T1, WT.ValW == (T1, M)>(_ f: (T1) -> T2, _ g: WT) -> Writer<M, T2, (T2, M)> {
	return g.map(f)
}

/// Alias for `flatMap(g:)`
public func >>- <M: Monoid, T1, T2, WT: WriterType where WT.OutW == M, WT.ResW == T1, WT.ValW == (T1, M)>(_ m: WT, _
	fn: (T1) -> Writer<M, T2, (T2, M)>) -> Writer<M, T2, (T2, M)> {
	return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
public func <*> <M: Monoid, T1, T2, WT1: WriterType, WT2: WriterType where WT1.OutW == M, WT1.ResW == (T1) -> T2, WT1.ValW == ((T1) -> T2, M), WT2.OutW == M, WT2.ResW == T1, WT2.ValW == (T1, M)>(_ fn: WT1, _ g: WT2) -> Writer<M, T2, (T2, M)> {
	return g.ap(fn)
}

// MARK: - WriterType (Values: OptionalType) - map/flatMap/ap

public extension WriterType where ValW == (ResW, OutW)? {
	public func map<Result2, Output2: Monoid>(f: (ResW, OutW) -> (Result2, Output2)) -> Writer<Output2, Result2, (Result2, Output2)?> {
		return Writer(f <^> run)
	}
	
	public func map<Result2>(_ f: (ResW) -> Result2) -> Writer<OutW, Result2, (Result2, OutW)?> {
		return map { (f($0), $1) }
	}
	
	public func flatMap<Result2>(_ fn: (ResW) -> Writer<OutW, Result2, (Result2, OutW)>) -> Writer<OutW, Result2, (Result2, OutW)?> {
		let f2: (ResW, OutW) -> (Result2, OutW) = { r, o in
			let (r2, o2) = fn(r).run.value
			return (r2, o.mappend(o2))
		}
		
		return Writer( .pure(f2 <^> run.value) )
	}
	
	public func ap<Result2, WT: WriterType where WT.ResW == (ResW) -> Result2, WT.OutW == OutW, WT.ValW == ((ResW) -> Result2, OutW)>(_ fn: WT) -> Writer<OutW, Result2, (Result2, OutW)?> {
		return self >>- { m in fn >>- { f in .pure(f(m)) } }
	}
}

/// Alias for `map(f:)`
public func <^> <M: Monoid, T1, T2, WT: WriterType where WT.OutW == M, WT.ResW == T1, WT.ValW == (T1, M)?>(_ f: (T1) -> T2, _ g: WT) -> Writer<M, T2, (T2, M)?> {
	return g.map(f)
}

/// Alias for `flatMap(g:)`
public func >>- <M: Monoid, T1, T2, WT: WriterType where WT.OutW == M, WT.ResW == T1, WT.ValW == (T1, M)?>(_ m: WT, _
	fn: (T1) -> Writer<M, T2, (T2, M)>) -> Writer<M, T2, (T2, M)?> {
	return m.flatMap(fn)
}

/// Alias for `ap(fn:)`
public func <*> <M: Monoid, T1, T2, WT1: WriterType, WT2: WriterType where WT1.OutW == M, WT1.ResW == (T1) -> T2, WT1.ValW == ((T1) -> T2, M), WT2.OutW == M, WT2.ResW == T1, WT2.ValW == (T1, M)?>(_ fn: WT1, _ g: WT2) -> Writer<M, T2, (T2, M)?> {
	return g.ap(fn)
}

// MARK: - Writer - Kleisli

public func >>->> <W: Monoid, A, B, C>(_ left: (A) -> Writer<W, B, (B, W)>, _ right: (B) -> Writer<W, C, (C, W)>) -> (A) -> Writer<W, C, (C, W)> {
	return { left($0) >>- right }
}

public func <<-<< <W: Monoid, A, B, C>(_ left: (B) -> Writer<W, C, (C, W)>, _ right: (A) -> Writer<W, B, (B, W)>) -> (A) -> Writer<W, C, (C, W)> {
	return right >>->> left
}

// MARK: - Lift

public func lift<W: Monoid, A, B, C>(_ f: (A, B) -> C) -> Writer<W, (A) -> (B) -> C, ((A) -> (B) -> C, W)> {
	return .pure(curry(f))
}

public func lift<W: Monoid, A, B, C, D>(_ f: (A, B, C) -> D) -> Writer<W, (A) -> (B) -> (C) -> D, ((A) -> (B) -> (C) -> D, W)> {
	return .pure(curry(f))
}

public func lift<W: Monoid, A, B, C, D, E>(_ f: (A, B, C, D) -> E) -> Writer<W, (A) -> (B) -> (C) -> (D) -> E, ((A) -> (B) -> (C) -> (D) -> E, W)> {
	return .pure(curry(f))
}

// MARK: - Writer

// TODO: re-define Writer (Swift3)
///
/// typealias Writer<M: Monoid, T> = Writer<M: Monoid, T, (T, M)>
///
public struct Writer<M: Monoid, T, V> {
	public let run: Identity<V>
}

// MARK: - Writer: WriterType

extension Writer: WriterType {
	public typealias OutW = M
	public typealias ResW = T
	public typealias ValW = V
	
	public init(_ run: Identity<V>) {
		self.run = run
	}
}

// MARK: - Writer: Pointed

public extension Writer {
	public typealias Value = T
}

// MARK: - Functions

/// `tell(output:)` is an action that produces the `output`.
public func tell<M: Monoid>(output: M) -> Writer<M, (), ((), M)> {
	return Writer( Identity((), output) )
}

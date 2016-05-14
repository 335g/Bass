//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - WriterType

public protocol WriterType: Pointed {
	associatedtype OutputW: Monoid
	associatedtype ResultW
	associatedtype ValuesW = (ResultW, OutputW)
	
	var run: Identity<ValuesW> { get }
	init(_ run: Identity<ValuesW>)
}

// MARK: - WriterType: Pointed

public extension WriterType {
	public typealias PointedValue = ResultW
	
	public static func pure(a: ResultW) -> Self {
		let values = (a, OutputW.mempty) as! ValuesW
		return Self.init( Identity(values) )
	}
}

// MARK: - WriterType - method

public extension WriterType where ValuesW == (ResultW, OutputW) {
	public var exec: OutputW {
		return run.value.1
	}
	
	/// `listen()` is an action that executes the action and adds its
	/// output to the value of the computation.
	public func listen() -> Writer<OutputW, (ResultW, OutputW), ((ResultW, OutputW), OutputW)> {
		let (r, o) = run.value
		return Writer( Identity((r, o), o) )
	}
	
	/// `listens(f:)` is an action that executes the action and adds the result
	/// of applying `f` to the output to the value of the computation.
	public func listens<Result2>(f: OutputW -> Result2) -> Writer<OutputW, (ResultW, Result2), ((ResultW, Result2), OutputW)> {
		let (r, o) = run.value
		return Writer( Identity((r, f(o)), o) )
	}
	
	/// `censor(f:)` is an action that executes the action and applies the function `f`
	/// to its output, leaving the return value unchanged.
	public func censor(f: OutputW -> OutputW) -> Writer<OutputW, ResultW, (ResultW, OutputW)> {
		let (r, o) = run.value
		return Writer( Identity(r, f(o)) )
	}
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
	public typealias OutputW = M
	public typealias ResultW = T
	public typealias ValuesW = V
	
	public init(_ run: Identity<V>) {
		self.run = run
	}
}

// MARK: - Writer: Pointed

public extension Writer {
	public typealias PointedValue = T
}

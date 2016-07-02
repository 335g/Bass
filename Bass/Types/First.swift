//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - FirstType

public protocol FirstType {
	associatedtype Value
	
	var getFirst: Value? { get }
	init(_ x: Value?)
}

// MARK: - First

public struct First<A>: FirstType {
	public let getFirst: A?
	
	public init(_ a: A?){
		getFirst = a
	}
}

extension First: Monoid {
	public static var mempty: First {
		return First(nil)
	}
	
	public func mappend(_ other: First) -> First {
		switch (self.getFirst, other.getFirst) {
		case (.some(_), _):
			return self
		case (.none, _):
			return other
		}
	}
}

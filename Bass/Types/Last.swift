//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - LastType

public protocol LastType {
	associatedtype Value
	
	var getLast: Value? { get }
	init(_ x: Value?)
}

// MARK: - Last

public struct Last<A>: LastType {
	public let getLast: A?
	
	public init(_ x: A?) {
		getLast = x
	}
}

extension Last: Monoid {
	public static var mempty: Last {
		return Last(nil)
	}
	
	public func mappend(_ other: Last) -> Last {
		switch (self.getLast, other.getLast) {
		case (_, .some(_)):
			return other
		case (_, .none):
			return self
		}
	}
}

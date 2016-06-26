//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - PrismType

public protocol PrismType: OpticType {
	var forward: (Source) -> Target? { get }
	var backward: (AltTarget) -> AltSource { get }
	
	init(forward: (Source) -> Target?, backward: (AltTarget) -> AltSource)
}

extension PrismType {
	public func compose <Other: PrismType, To: PrismType where Target == Other.Source, AltTarget == Other.AltSource, To.Source == Source, To.AltSource == AltSource, To.Target == Other.Target, To.AltTarget == Other.AltTarget> (_ other: Other) -> To {
		
		return To(
			forward: { self.forward($0).flatMap(other.forward) },
			backward: self.backward • other.backward
		)
	}
}

public func >>> <L: PrismType, R: PrismType, To: PrismType where L.Target == R.Source, L.AltTarget == R.AltSource, To.Source == L.Source, To.AltSource == L.AltSource, To.Target == R.Target, To.AltTarget == R.AltTarget>(lhs: L, rhs: R) -> To {
	return lhs.compose(rhs)
}

// MARK: - Prism

public struct Prism<S, T, A, B> {
	public let forward: (S) -> A?
	public let backward: (B) -> T
	
	public init(forward: (S) -> A?, backward: (B) -> T) {
		self.forward = forward
		self.backward = backward
	}
}

// MARK: - Prism: PrismType

extension Prism: PrismType {
	public typealias Source = S
	public typealias Target = A
	public typealias AltSource = T
	public typealias AltTarget = B
}


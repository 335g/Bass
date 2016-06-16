//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - Foldable

public protocol Foldable {
	associatedtype Element
	
	func foldMap<M: Monoid>(f: (Element) -> M) -> M
	func foldr<T>(initial: T, f: (Element) -> (T) -> T) -> T
}

// MARK: - Foldable - default implementation

public extension Foldable {
	public func foldMap<M: Monoid>(f: (Element) -> M) -> M {
		return foldr(initial: M.mempty, f: { a in { f(a).mappend($0) } })
	}
	
	public func foldr<T>(initial: T, f: (Element) -> (T) -> T) -> T {
		return ( foldMap(f: { Endo(f($0)) }) ).appEndo(initial)
	}
	
	public func foldr1(f: (Element) -> (Element) -> Element) throws -> Element {
		let ifNotOptional: (Element) -> (Element?) -> Element = { x in
			{ y in
				switch y {
				case .none:
					return x
				case let .some(a):
					return f(x)(a)
				}
			}
		}
		
		guard let folded = foldr(initial: nil, f: ifNotOptional) else {
			throw FoldableError.OnlyOne
		}
		
		return folded
	}
	
	public func foldl<T>(initial: T, f: (T) -> (Element) -> T) -> T {
		return ( (foldMap(f: { Dual(Endo(flip(f)($0))) })).getDual ).appEndo(initial)
	}
	
	public func foldl1(f: (Element) -> (Element) -> Element) throws -> Element {
		let ifNotOptional: (Element?) -> (Element) -> Element = { x in
			{ y in
				switch x {
				case .none:
					return y
				case let .some(a):
					return f(a)(y)
				}
			}
		}
		
		guard let folded = foldl(initial: nil, f: ifNotOptional) else {
			throw FoldableError.OnlyOne
		}
		
		return folded
	}
	
	public func null() -> Bool {
		return foldr(initial: true, f: { _ in { _ in false }})
	}
	
	public func length() -> Int {
		return foldl(initial: 0, f: { a in { _ in a + 1 }})
	}
	
	public func find(predicate: (Element) -> Bool) throws -> Element? {
		return foldMap(f: { First(predicate($0) ? $0 : nil) }).getFirst
	}
	
	public func toList() -> [Element] {
		return foldr(initial: [], f: { elem in
			{ box in
				var aBox = box
				aBox.insert(elem, at: 0)
				return aBox
			}
		})
	}
}

// MARK: - Foldable (Element: Monoid)

public extension Foldable where Element: Monoid {
	public func fold() -> Element {
		return foldMap(f: id)
	}
}

// MARK: - Foldable (Element: Equatable)

public extension Foldable where Element: Equatable {
	public func elem(_ this: Element) -> Bool {
		return foldl(initial: false, f: { bool in
			return { element in
				return bool || (element == this)
			}
		})
	}
	
	public func notElem(this: Element) -> Bool {
		return !(elem(this))
	}
}

// MARK: - Foldable (Element: Comparable)

public extension Foldable where Element: Comparable {
	public func maximum() throws -> Element {
		if let folded = foldMap(f: { Max($0) }).getMax {
			return folded
		}else {
			throw FoldableError.Null
		}
	}
	
	public func minimum() throws -> Element {
		if let folded = foldMap(f: { Min($0) }).getMin {
			return folded
		}else {
			throw FoldableError.Null
		}
	}
}

// MARK: - FoldableError

public enum FoldableError: ErrorProtocol {
	case Null
	case OnlyOne
}

// MARK: - Endo

private struct Endo<A> {
	let appEndo: (A) -> A
	
	init(_ a: (A) -> A){
		self.appEndo = a
	}
}

extension Endo: Monoid {
	private static var mempty: Endo {
		return Endo(id)
	}
	
	private func mappend(_ other: Endo) -> Endo {
		return Endo({ self.appEndo(other.appEndo($0)) })
	}
}

// MARK: - Dual

private struct Dual<A: Monoid>{
	let getDual: A
	
	init(_ a: A){
		self.getDual = a
	}
}

extension Dual: Monoid {
	private static var mempty: Dual {
		return Dual(A.mempty)
	}
	
	private func mappend(_ other: Dual) -> Dual {
		return Dual(self.getDual <> other.getDual)
	}
}

// MARK: - First

private struct First<A> {
	let getFirst: A?
	
	init(_ a: A?){
		getFirst = a
	}
}

extension First: Monoid {
	private static var mempty: First {
		return First(nil)
	}
	
	private func mappend(_ other: First) -> First {
		switch (self.getFirst, other.getFirst) {
		case (.some(_), _):
			return self
		case (.none, _):
			return other
		}
	}
}

// MARK: - Max

private struct Max<A: Comparable> {
	let getMax: A?
	
	init(_ a: A?){
		getMax = a
	}
}

extension Max: Monoid {
	private static var mempty: Max {
		return Max(nil)
	}
	
	private func mappend(_ other: Max) -> Max {
		switch (self.getMax, other.getMax){
		case (.none, .none):
			return Max(nil)
		case let (.some(a), .none):
			return Max(a)
		case let (.none, .some(a)):
			return Max(a)
		case let (.some(a), .some(b)):
			return Max(max(a, b))
		}
	}
}

// MARK: - Min

private struct Min<A: Comparable> {
	let getMin: A?
	
	init(_ a: A?){
		getMin = a
	}
}

extension Min: Monoid {
	private static var mempty: Min {
		return Min(nil)
	}
	
	private func mappend(_ other: Min) -> Min {
		switch (self.getMin, other.getMin){
		case (.none, .none):
			return Min(nil)
		case let (.some(a), .none):
			return Min(a)
		case let (.none, .some(a)):
			return Min(a)
		case let (.some(a), .some(b)):
			return Min(min(a, b))
		}
	}
}

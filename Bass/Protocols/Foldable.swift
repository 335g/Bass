//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - Foldable

public protocol Foldable {
	associatedtype Element
	
	func foldMap<M: Monoid>(f: Element -> M) -> M
	func foldr<T>(initial: T, _ f: Element -> T -> T) -> T
}

// MARK: - Foldable - default implementation

public extension Foldable {
	public func foldMap<M: Monoid>(f: Element -> M) -> M {
		return foldr(M.mempty, { a in { f(a).mappend($0) } })
	}
	
	public func foldr<T>(initial: T, _ f: Element -> T -> T) -> T {
		return ( foldMap({ Endo(f($0)) }) ).appEndo(initial)
	}
	
	public func foldr1(f: Element -> Element -> Element) throws -> Element {
		let ifNotOptional: Element -> Element? -> Element = { x in
			{ y in
				switch y {
				case .None:
					return x
				case let .Some(a):
					return f(x)(a)
				}
			}
		}
		
		guard let folded = foldr(nil, ifNotOptional) else {
			throw FoldableError.OnlyOne
		}
		
		return folded
	}
	
	public func foldl<T>(initial: T, _ f: T -> Element -> T) -> T {
		return ( (foldMap({ Dual(Endo(flip(f)($0))) })).getDual ).appEndo(initial)
	}
	
	public func foldl1(f: Element -> Element -> Element) throws -> Element {
		let ifNotOptional: Element? -> Element -> Element = { x in
			{ y in
				switch x {
				case .None:
					return y
				case let .Some(a):
					return f(a)(y)
				}
			}
		}
		
		guard let folded = foldl(nil, ifNotOptional) else {
			throw FoldableError.OnlyOne
		}
		
		return folded
	}
	
	public func null() -> Bool {
		return foldr(true, { _ in { _ in false }})
	}
	
	public func length() -> Int {
		return foldl(0, { a in { _ in a + 1 }})
	}
	
	public func find(predicate: Element -> Bool) throws -> Element? {
		return foldMap({ First(predicate($0) ? $0 : nil) }).getFirst
	}
	
	public func toList() -> [Element] {
		return foldr([], { ele in
			{ box in
				var aBox = box
				aBox.insert(ele, atIndex: 0)
				return aBox
			}
		})
	}
}

// MARK: - Foldable (Element: Monoid)

public extension Foldable where Element: Monoid {
	public func fold() -> Element {
		return foldMap(id)
	}
}

// MARK: - Foldable (Element: Equatable)

public extension Foldable where Element: Equatable {
	public func elem(this: Element) -> Bool {
		return foldl(false){ bool in
			return { element in
				return bool || (element == this)
			}
		}
	}
	
	public func notElem(this: Element) -> Bool {
		return !(elem(this))
	}
}

// MARK: - Foldable (Element: Comparable)

public extension Foldable where Element: Comparable {
	public func maximum() throws -> Element {
		if let folded = foldMap({ Max($0) }).getMax {
			return folded
		}else {
			throw FoldableError.Null
		}
	}
	
	public func minimum() throws -> Element {
		if let folded = foldMap({ Min($0) }).getMin {
			return folded
		}else {
			throw FoldableError.Null
		}
	}
}

// MARK: - FoldableError

public enum FoldableError: ErrorType {
	case Null
	case OnlyOne
}

// MARK: - Endo

private struct Endo<A> {
	let appEndo: A -> A
	
	init(_ a: A -> A){
		self.appEndo = a
	}
}

extension Endo: Monoid {
	private static var mempty: Endo {
		return Endo(id)
	}
	
	private func mappend(other: Endo) -> Endo {
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
	
	private func mappend(other: Dual) -> Dual {
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
	
	private func mappend(other: First) -> First {
		switch (self.getFirst, other.getFirst) {
		case (.Some(_), _):
			return self
		case (.None, _):
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
	
	private func mappend(other: Max) -> Max {
		switch (self.getMax, other.getMax){
		case (.None, .None):
			return Max(nil)
		case let (.Some(a), .None):
			return Max(a)
		case let (.None, .Some(a)):
			return Max(a)
		case let (.Some(a), .Some(b)):
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
	
	private func mappend(other: Min) -> Min {
		switch (self.getMin, other.getMin){
		case (.None, .None):
			return Min(nil)
		case let (.Some(a), .None):
			return Min(a)
		case let (.None, .Some(a)):
			return Min(a)
		case let (.Some(a), .Some(b)):
			return Min(min(a, b))
		}
	}
}
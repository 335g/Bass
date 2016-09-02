//  Copyright © 2016 Yoshiki Kudo. All rights reserved.

// MARK: - Foldable

public protocol Foldable {
	associatedtype Element
	
	func foldMap<M: Monoid>(_ f: @escaping (Element) -> M) -> M
	func foldr<T>(initial: T, _ f: @escaping (Element) -> (T) -> T) -> T
}

// MARK: - Foldable - default implementation

public extension Foldable {
	public func foldMap<M: Monoid>(_ f: @escaping (Element) -> M) -> M {
		return foldr(initial: M.mempty){ a in { f(a).mappend($0) } }
	}
	
	public func foldr<T>(initial: T, _ f: @escaping (Element) -> (T) -> T) -> T {
		return ( foldMap({ Endo(f($0)) }) ).appEndo(initial)
	}
	
	public func foldr1(_ f: @escaping (Element) -> (Element) -> Element) throws -> Element {
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
		
		guard let folded = foldr(initial: nil, ifNotOptional) else {
			throw FoldableError.onlyOne
		}
		
		return folded
	}
	
	public func foldl<T>(initial: T, _ f: @escaping (T) -> (Element) -> T) -> T {
		return ( (foldMap({ Dual(Endo(flip(f)($0))) })).getDual ).appEndo(initial)
	}
	
	public func foldl1(_ f: @escaping (Element) -> (Element) -> Element) throws -> Element {
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
		
		guard let folded = foldl(initial: nil, ifNotOptional) else {
			throw FoldableError.onlyOne
		}
		
		return folded
	}
	
	public func null() -> Bool {
		return foldr(initial: true){ _ in { _ in false }}
	}
	
	public func length() -> Int {
		return foldl(initial: 0){ a in { _ in a + 1 }}
	}
	
	public func find(_ predicate: @escaping (Element) -> Bool) throws -> Element? {
		return foldMap({ First(predicate($0) ? $0 : nil) }).getFirst
	}
	
	public func toList() -> [Element] {
		return foldr(initial: []){ elem in
			{ box in
				var aBox = box
				aBox.insert(elem, at: 0)
				return aBox
			}
		}
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
	public func elem(_ this: Element) -> Bool {
		return foldl(initial: false){ bool in
			return { element in
				return bool || (element == this)
			}
		}
	}
	
	public func notElem(_ this: Element) -> Bool {
		return !(elem(this))
	}
}

// MARK: - Foldable (Element: Comparable)

public extension Foldable where Element: Comparable {
	public func maximum() throws -> Element {
		if let folded = foldMap({ Max($0) }).getMax {
			return folded
		}else {
			throw FoldableError.null
		}
	}
	
	public func minimum() throws -> Element {
		if let folded = foldMap({ Min($0) }).getMin {
			return folded
		}else {
			throw FoldableError.null
		}
	}
}

// MARK: - FoldableError

public enum FoldableError: Error {
	case null
	case onlyOne
}

// MARK: - Endo

fileprivate struct Endo<A> {
	let appEndo: (A) -> A
	
	init(_ a: @escaping (A) -> A){
		self.appEndo = a
	}
}

extension Endo: Monoid {
	fileprivate static var mempty: Endo {
		return Endo(id)
	}
	
	fileprivate func mappend(_ other: Endo) -> Endo {
		return Endo({ self.appEndo(other.appEndo($0)) })
	}
}

// MARK: - Dual

fileprivate struct Dual<A: Monoid>{
	let getDual: A
	
	init(_ a: A){
		self.getDual = a
	}
}

extension Dual: Monoid {
	fileprivate static var mempty: Dual {
		return Dual(A.mempty)
	}
	
	fileprivate func mappend(_ other: Dual) -> Dual {
		return Dual(self.getDual <> other.getDual)
	}
}

// MARK: - Max

fileprivate struct Max<A: Comparable> {
	let getMax: A?
	
	init(_ a: A?){
		getMax = a
	}
}

extension Max: Monoid {
	fileprivate static var mempty: Max {
		return Max(nil)
	}
	
	fileprivate func mappend(_ other: Max) -> Max {
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

fileprivate struct Min<A: Comparable> {
	let getMin: A?
	
	init(_ a: A?){
		getMin = a
	}
}

extension Min: Monoid {
	fileprivate static var mempty: Min {
		return Min(nil)
	}
	
	fileprivate func mappend(_ other: Min) -> Min {
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

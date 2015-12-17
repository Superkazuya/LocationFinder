import Foundation

protocol TreeNodeType {
    typealias Value: Hashable
    var children: [Value: Self] {get set}
    init()
    //lol wut 
    // lol wut
    //  lol wut
    //   lol wut
}

protocol TrieNodeType: TreeNodeType {
    //typealias Value: Equatable
    
    init<S: SequenceType where S.Generator.Element == Value>(sequence: S)
    var isEnd: Bool {get set}
    
}

extension TrieNodeType {
    private init<G: GeneratorType where G.Element == Value>(var generator: G) {
        self.init() //lol wut
        if let fst = generator.next() {
            (children, isEnd) = ([fst: Self(generator: generator)], false)
        } else {
            (children, isEnd) = ([:], true)
        }
    }
    
    init<S: SequenceType where S.Generator.Element == Value>(sequence: S)
    {
        self.init(generator: sequence.generate())
    }
}

extension TrieNodeType {
    private func contains<G: GeneratorType where G.Element == Value>(var generator: G) -> Bool
    {
        guard let n = generator.next() else { return isEnd }
        return children[n]?.contains(generator) ?? false
    }
    
    func contains<S: SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool
    {
        return contains(sequence.generate())
    }
}

extension TrieNodeType {
    private mutating func insert<G: GeneratorType where G.Element == Value>(var generator: G)
    {
        if let fst = generator.next() {
            _ = children[fst]?.insert(generator) ??
                { children[fst] = Self(generator: generator) }()
        } else {
            isEnd = true
        }
    }
    
    mutating func insert<S: SequenceType where S.Generator.Element == Value>(sequence: S)
    {
        insert(sequence.generate())
    }
}

extension TrieNodeType {
    private mutating func removeChildren(value: Value) {
        children[value] = nil
    }
    
    private mutating func remove<G: GeneratorType where G.Element == Value>(var generator: G) -> Bool {
        if let fst = generator.next() {
            guard children[fst]?.remove(generator) == true else { return false }
            removeChildren(fst)
            return !isEnd && children.isEmpty
        } else {
            isEnd = false
            return children.isEmpty
        }
    }
    
    mutating func remove<S: SequenceType where S.Generator.Element == Value>(sequence: S)
    {
        remove(sequence.generate())
    }
}


extension TrieNodeType {
    private func trace<G: GeneratorType where G.Element == Value>(var generator: G) -> Self?
    {
        guard let fst = generator.next() else { return self }
        guard let next = children[fst] else { return nil }
        return next.trace(generator)
    }
    
    func trace<S: SequenceType where S.Generator.Element == Value>(sequence: S) -> Self?
    {
        return trace(sequence.generate())
    }
    
    func traverse() -> [[Value]]
    {
        
        let r =  children.flatMap { k, v in
            v.traverse().map { path in [k] + path }
        }
        return isEnd ? [[Value]()] + r : r
    }
    
    private func completion<G: GeneratorType where G.Element == Value>(generator: G) -> [[Value]]
    {
        return trace(generator)?.traverse() ?? [[Value]]()
    }
    
    func completion<S: SequenceType where S.Generator.Element == Value>(sequence: S) -> [[Value]]
    {
        return completion(sequence.generate())
    }
}


struct TrieNode<T: Hashable>: TrieNodeType {
    typealias Value = T
    var children = [Value: TrieNode<T>]()
    var isEnd = false
    init() { }
}

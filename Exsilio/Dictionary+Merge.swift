//
//  Dictionary+Merge.swift
//  Exsilio
//
//  Created by Nick Kezhaya on 4/27/16.
//
//

extension Dictionary {
    mutating func merge(_ other: Dictionary) {
        for (key, value) in other {
            self.updateValue(value, forKey: key)
        }
    }
}

extension Dictionary where Value : Equatable {
    func allKeysForValue(_ val : Value) -> [Key] {
        return self.filter { $1 == val }.map { $0.0 }
    }
}

func +=<K, V> (left: inout [K : V], right: [K : V]) {
    for (k, v) in right {
        left[k] = v
    }
}

//
//  Storage.swift
//  ProjectII
//
//  Created by Azuby on 01/02/2023.
//

import UIKit

class Storage {
    private var temp: [StorageValueCollection] = {
        var arr = [StorageValueCollection]()

        for i in 0..<20 {
            arr.append(StorageValueCollection(name: "Temperature", unit: "ºC"))
        }
        
        return arr
    }()
    private var tempSP: [StorageSetPoint] = {
        var arr = [StorageSetPoint]()

        for i in 0..<20 {
            arr.append(StorageSetPoint())
        }
        
        return arr
    }()
    
    func descriptObject(_ object: [String: [Feed]]) {
        for key in object.keys {
            if (!key.contains("SP")) {
                temp[Int(key.dropFirst(3))! - 1].setValues(object[key]!.map({ feed in
                    return StorageValue(value: feed.value, date: Date(timeIntervalSince1970: feed.date), col: temp[Int(key.dropFirst(3))! - 1])
                }))
            } else {
                if let values = object[key] {
                    let sortValues = values.sorted { f1, f2 in
                        return f1.date < f2.date
                    }
                    
                    if let value = sortValues.last?.value {
                        tempSP[Int(key.dropFirst(5))! - 1].setValue(value)
                    }
                }
            }
        }
    }
    
    func getStorage(of number: Int) -> StorageValueCollection {
        return temp[number]
    }
    
    func getSetPoint(of number: Int) -> StorageSetPoint {
        return tempSP[number]
    }
    
    func getCount() -> Int {
        return temp.count
    }
    
    func setSetPoint(of number: Int, _ sp: CGFloat) {
        ModelManager.shared.post((number + 1, sp))
    }
}

class StorageValueCollection {
    private var values: [StorageValue] = []
    private var name: String = ""
    private var unit: String = ""
    
    init(name: String, unit: String) {
        self.name = name
        self.unit = unit
    }

    func getName() -> String {
        return name
    }
    
    func getUnit() -> String {
        return unit
    }
    
    func setValues(_ values: [StorageValue]) {
        self.values = values
        NotificationCenter.default.post(name: Notification.Name("storage.update"), object: nil)
    }
    
    func getValue(at index: Int? = nil) -> StorageValue? {
        if let index = index {
            return values[index]
        }
        return values.last
    }
    
    func getValues(timeRange: ClosedRange<CGFloat>) -> [StorageValue] {
        return values.filter { e in
            return timeRange.contains(e.getDate().timeIntervalSince1970)
        }
    }
    
    func getValues(valueRange: ClosedRange<CGFloat>) -> [StorageValue] {
        return values.filter { e in
            return valueRange.contains(e.getValue())
        }
    }
    
    func getUnloopValues() -> [StorageValue] {
        var values = [StorageValue]()
        
        for value in self.values.enumerated() {
            if value.offset > 0 {
                if abs(value.element.getValue() - self.values[value.offset - 1].getValue()) < 0.01 {
                    continue
                }
                values.append(value.element)
            } else {
                values.append(value.element)
            }
        }
        
        return values
    }
    
    func getTimeRangeToLast(in time: CGFloat = .greatestFiniteMagnitude) -> ClosedRange<CGFloat> {
        if let l = values.last?.getDate(),
           let f = values.first(where: { value in
            return value.getDate().distance(to: l) < time
           })?.getDate() {
            
            return f.timeIntervalSince1970...l.timeIntervalSince1970
        }
        if let l = values.last?.getDate().timeIntervalSince1970 {
            return l...l
        }
        return 0.0...0.0
    }
    func getTimeRangeToNow(in time: CGFloat = .greatestFiniteMagnitude) -> ClosedRange<CGFloat> {
        if let f = values.first(where: { value in
            return value.getDate().distance(to: Date()) < time
           })?.getDate() {
            
            return f.timeIntervalSince1970...Date().timeIntervalSince1970
        }
        return Date().timeIntervalSince1970...Date().timeIntervalSince1970
    }
    
    func getValueRange() -> ClosedRange<CGFloat> {
        let vs = values.sorted { a, b in
            return a.getValue() < b.getValue()
        }
        return (vs.first?.getValue() ?? 0.0)...(vs.last?.getValue() ?? 0.0)
    }
}

class StorageValue: Equatable {
    private var value: CGFloat
    private var date: Date
    weak var col: StorageValueCollection!
    
    init(value: CGFloat, date: Date, col: StorageValueCollection) {
        self.value = value
        self.date = date
        self.col = col
    }
    
    func getDate() -> Date {
        return date
    }
    
    func getValue() -> CGFloat {
        return value
    }
    
    func getCol() -> StorageValueCollection {
        return col
    }
    
    static func == (lhs: StorageValue, rhs: StorageValue) -> Bool {
        return lhs.value == rhs.value && lhs.date == rhs.date
    }
}

class StorageSetPoint: Equatable {
    private var value: CGFloat
    
    init(value: CGFloat = 0) {
        self.value = value
    }
    
    func getValue() -> CGFloat {
        return value
    }
    
    func setValue(_ value: CGFloat) {
        self.value = value
        NotificationCenter.default.post(name: Notification.Name("storage.update"), object: nil)
    }
    
    static func == (lhs: StorageSetPoint, rhs: StorageSetPoint) -> Bool {
        return lhs.value == rhs.value
    }
}

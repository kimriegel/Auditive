// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import SwiftUI
import Combine

@propertyWrapper
// class
struct CodableStorage<T : // Codable & ObservableObject > : ObservableObject {
                        Codable> : DynamicProperty {
  let key : String
  @State private var value : T
//  var store = Set<AnyCancellable>()

  init(wrappedValue : T, _ key : String) {
    self.key = key
    let initialValue = UserDefaults.standard.string(forKey: key) ?? ""
    let iv = try? JSONDecoder().decode(T.self, from: initialValue.data(using: String.Encoding.utf8)!  )
    if (iv == nil) {
      self._value = State<T>(wrappedValue: wrappedValue )
    } else {
      self._value = State<T>(initialValue: iv!)
    }
//    value.objectWillChange.sink {
//      [weak self] _ in self?.objectWillChange.send() }.store(in: &store)
  }

  var wrappedValue : T {
    get { value }
     nonmutating
    set {
//      self.objectWillChange.send()
      value = newValue
      do {
        let j = try String(data: JSONEncoder().encode(value), encoding: .utf8)
        UserDefaults.standard.set(j, forKey: key)
        UserDefaults.standard.synchronize()
      } catch(let e) {
        print(e)
      }
    }
  }

  var projectedValue : Binding<T> {
    Binding(get: { self.wrappedValue } ,
            set: {
//              self.objectWillChange.send()
              // self.
              wrappedValue = $0
    })
  }


}

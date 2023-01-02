//
//  Prospect.swift
//  Overture
//
//  Created by Timi on 29/12/22.
//Swift can help us mitigate this problem by stopping us from modifying the Boolean outside of Prospects.swift. There’s a specific access control option called fileprivate, which means “this property can only be used by code inside the current file.” Of course, we still want to read that property, and so we can deploy another useful Swift feature: fileprivate(set), which means “this property can be read from anywhere, but only written from the current file” – the exact combination we need to make sure the Boolean is safe to use.

import SwiftUI

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
    
}
//When it comes to sharing that across multiple views, one of the best things about SwiftUI’s environment is that it uses the same ObservableObject protocol we’ve been using with the @StateObject property wrapper. This means we can mark properties that should be announced using the @Published property wrapper – SwiftUI takes care of most of the work for us.
@MainActor class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    let saveKey = "SavedData"
//    /although the Prospects class uses the @Published property wrapper, the people array inside it is simple enough that it already conforms to Codable just by adding the protocol conformance. So, we can get most of the way to our goal by making three small changes:/
    init() { //1.Updating the Prospects initializer so that it loads its data from UserDefaults where possible.
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                people = decoded
                return
            }
        }

        people = []
    }
    private func save() { //2.Adding a save() method to the same class, writing the current data to UserDefaults.
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        } //This helps lock down our code so that we can’t make mistakes by accident – the compiler simply won’t allow it. In fact, if you try building the code now you’ll see exactly what I mean: ProspectsView tries to append to the people array and call save(), which is no longer allowed.
    }
 func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
       // save() //3.Calling save() when adding a prospect or toggling its isContacted property.
    }
    func deleteProspect(_ prospect: Prospect) {
        
    }
   
}

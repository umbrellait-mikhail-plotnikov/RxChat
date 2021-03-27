//
//  MessageViewModel.swift
//  FireBaseTest
//
//  Created by Mikhail Plotnikov on 27.03.2021.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

class MessageViewModel: MessageViewModelProtocol {
    
    private let messagesSet: BehaviorRelay<Set<MessageModel>> = BehaviorRelay(value: [])
    private let disposeBag = DisposeBag()
    private var userName: String = ""
    
    public var messagesArray: BehaviorRelay<[MessageModel]> = BehaviorRelay(value: [])
    public let textField = BehaviorRelay<String>(value: "")
    
    init() {
        setObserversToDataBase(messagePath: FirebaseService.shared.messagePath)
        
        messagesSet.asObservable()
            .subscribe(onNext: { newSet in
                self.messagesArray.accept(newSet.sorted { $0.time < $1.time })
            })
            .disposed(by: disposeBag)
        
        let name = getRandomEmoji()
        generateUserName(name: name)
        
    }
    private func generateUserName(name: String) {
        FirebaseService.shared.onlineUsersPath.child(name).getData { (err, snapshot) in
            if !snapshot.exists() {
                self.userName = name
                self.registerUserName(name: name)
            } else {
                print("Exist :( \(name)")
                let newName = self.getRandomEmoji()
                self.generateUserName(name: newName)
            }
        }
    }
    private func registerUserName(name: String) {
        UserDefaults.standard.setValue(name, forKey: "name")
        FirebaseService.shared.logPath.child(name).setValue("Connected")
        FirebaseService.shared.onlineUsersPath.child(name).setValue(self.getCurrentTime())
    }
    
    private func getRandomEmoji() -> String {
        let i = Int.random(in: 0x1F601...0x1F64E)
        let emoji = String(UnicodeScalar(i)!)
        return emoji
    }
    
    private func getCurrentTime() -> Int {
        let date = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yMMddHHmmssSSSS"
        
        return Int(dateFormat.string(from: date))!
    }
    
    private func updateMessagesSet(snapshot: DataSnapshot) {
        var newMessagesSet = Set<MessageModel>()
        for child in snapshot.children {
            let temp = child as! DataSnapshot
            guard let dict = temp.value as? [String: [String: String]] else {
                self.messagesSet.accept([])
                return
            }
            for key in dict.keys {
                guard let messageText = dict[key]?["message"] else {
                    self.messagesSet.accept([])
                    return
                }
                let newMessage = MessageModel(sender: temp.key, messageText: messageText, time: Int(key)!)
                let newElement: Set<MessageModel> = [newMessage]
        
                newMessagesSet = newMessagesSet.union(newElement)
            }
        }
        self.messagesSet.accept(messagesSet.value.union(newMessagesSet))
    }
    
    private func setObserversToDataBase(messagePath: DatabaseReference) {
        _ = messagePath.observe(.value) { (snapshot) in
            self.updateMessagesSet(snapshot: snapshot)
        }

        _ = messagePath.observe(.childRemoved) { (snapshot) in
            self.updateMessagesSet(snapshot: snapshot)
        }
    }
    
    private func removeMessagesCurrentUser() {
        FirebaseService.shared.messagePath.child(self.userName).removeValue()
    }
    
    public func sendMsg() {
        let date = self.getCurrentTime()
        FirebaseService.shared.messagePath.child(self.userName).child(String(date)).setValue(["message": textField.value])
    }
}

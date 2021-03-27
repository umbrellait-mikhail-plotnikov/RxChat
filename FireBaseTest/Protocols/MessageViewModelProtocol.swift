//
//  MessageViewModelProtocol.swift
//  FireBaseTest
//
//  Created by Mikhail Plotnikov on 27.03.2021.
//

import Foundation
import RxSwift
import RxCocoa

protocol MessageViewModelProtocol {
    var messagesArray: BehaviorRelay<[MessageModel]> { get }
    var textField: BehaviorRelay<String> { get }
    func sendMsg()
}

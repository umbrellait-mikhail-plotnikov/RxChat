//
//  ViewController.swift
//  FireBaseTest
//
//  Created by Mikhail Plotnikov on 25.03.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    private let messageViewModel: MessageViewModelProtocol!
    private let disposeBag = DisposeBag()
    
    init() {
        messageViewModel = MessageViewModel()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        messageViewModel = MessageViewModel()
        
        super.init(coder: coder)
    }
    
    private func buildUI() {
        messageViewModel.messagesArray.asDriver()
            .do(onNext: {_ in
                self.tableView.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: true)
            })
            .drive(tableView.rx.items(cellIdentifier: "Cell")) {_, message, cell in
                cell.textLabel?.text = message.messageText
                cell.detailTextLabel?.text = message.sender
            }
            .disposed(by: disposeBag)
        
        textField.rx.text
            .orEmpty
            .bind(to: messageViewModel.textField)
            .disposed(by: disposeBag)
        
        sendButton.rx.tap
            .subscribe(onNext: {
                self.messageViewModel.sendMsg()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildUI()
    }
}

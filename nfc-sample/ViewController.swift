//
//  ViewController.swift
//  nfc-sample
//
//  Created by Seiya Mogami on 2018/09/29.
//  Copyright © 2018年 Seiya Mogami. All rights reserved.
//

import UIKit
import CoreNFC

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!

    var session: NFCNDEFReaderSession!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didTapReadNFCTag(_ sender: Any) {
        guard NFCNDEFReaderSession.readingAvailable else {
            showAlert(title: "エラー", message: "NFC非対応端末です😫")
            return
        }

        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session.alertMessage = "iPhoneをNFCタグに近づけてください。"
        session.begin()
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        guard let error = error as? NFCReaderError else {
            return
        }

        print(error.localizedDescription)

        // エラーハンドリングはこんな感じかな
        switch error.code {
        case .readerSessionInvalidationErrorUserCanceled:
            print("canceled")
        default:
            break
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            self.textView.text = ""
            var text = ""
            messages.forEach {
                text += "---\n"
                $0.records.forEach {
                    let type: String
                    switch $0.typeNameFormat {
                    case .absoluteURI:
                        type = "absoluteURI"
                    case .nfcWellKnown:
                        type = "nfcWellKnown"
                    case .nfcExternal:
                        type = "nfcExternal"
                    case .media:
                        type = "media"
                    case .unknown:
                        type = "unknown"
                    case .empty:
                        type = "empty"
                    case .unchanged:
                        type = "unchanged"
                    }
                    print("id: \($0.identifier)")
                    text += "identifier: \(String(data: $0.identifier, encoding: .utf8) ?? "")\n"
                    text += "type: \(type)(\(String(data: $0.type, encoding: .utf8) ?? ""))\n"
                    text += "payload: \(String(data: $0.payload, encoding: .utf8) ?? "")\n\n"
                }
            }
            self.textView.text = text
        }
    }
}


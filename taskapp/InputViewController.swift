//
//  InputViewController.swift
//  taskapp
//
//  Created by YashimaMasafumi on 2021/01/28.
//  Copyright © 2021 masa.yashi. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!    
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dataPicker: UIDatePicker!
    
    let realm = try! Realm()
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //背景をタップしたらdismissKyeboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKyeboard))
        self.view.addGestureRecognizer(tapGesture)
        
        //タスク一覧画面から遷移してきたときに受け取ったタスクの情報をUIに反映させる
        titleTextField.text = task.title
        categoryTextField.text = task.category
        contentsTextView.text = task.contents
        dataPicker.date = task.date
        
        // Do any additional setup after loading the view.
    }
    
    //タスク一覧画面へ戻る時に、UIに入力された値をデータベースに保存する
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            if self.categoryTextField.text! == ""{
                self.task.category = "no category"
            }else{
                self.task.category = self.categoryTextField.text!
            }
            if self.titleTextField.text! == ""{
                self.task.title = "no title"
            }else{
                self.task.title = self.titleTextField.text!
            }
            if self.contentsTextView.text == ""{
                self.task.contents = "no contents"
            }else{
                self.task.contents = self.contentsTextView.text
            }
            self.task.date = self.dataPicker.date
            self.realm.add(self.task, update: .modified)
        }
        
        setNortification(task: task)
        
        super.viewWillDisappear(animated)
    }
        
    //ユーザの入力の利便性を高めるために画面の背景をタップしたらキーボードを閉じる
    @objc func dismissKyeboard() {
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    //タスクのローカル通知を登録する
    func setNortification(task:Task){
        //UNMutableNortificationContentインスタンス取得で編集可能なコンテンツの設定
        let content = UNMutableNotificationContent()
        //タイトルとサブタイトルと内容を設定（中身がない場合メッセージなしで音だけの通知になるので「(xxなし)」を表示する）
        if task.title == "" {
            content.title = "(no title)"
        } else {
            content.title = task.title
        }
        if task.category == "" {
            content.subtitle = "(no category)"
        } else {
            content.subtitle = task.category
        }
        if task.contents == "" {
            content.body = "(no content)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        //ローカル通知が発動するtrigger(日付マッチ)を作成
        //Calender.currentで現在の日付を取得
        let calender = Calendar.current
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        //UNCalendarNortificationTriggerクラスのインスタンスを取得
        //特定の日時に通知が配信されるように設定（ここではdateComponent）
        //dateMatchingにはDateComponentクラスが入る
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request){
            // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
            (error) in print(error ?? "ローカル通知登録 OK")
        }
        
        // 未通知のローカル通知一覧をログ出力
        //保留中の通知を取得する
        center.getPendingNotificationRequests(completionHandler: {
            (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request.content)
                //print(request)
                print("---------------/")
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

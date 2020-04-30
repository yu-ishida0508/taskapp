//
//  InputViewController.swift
//  taskapp
//
//  Created by 石田悠 on 2020/04/23.
//  Copyright © 2020 yuu.ishida. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications    // 追加

class InputViewController: UIViewController {
//配列を利用する場合は、UIPickerViewDelegate, UIPickerViewDataSourceプロトコル追加
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!
    
    
    let realm = try!Realm()
    var task :Task!

// MARK: -　ドラムロール作成用の配列(必須)
/* categoryを配列
    var pickerView: UIPickerView = UIPickerView()
    let categoryList:[String] = ["その他","一般","至急"]
*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
// MARK: -　ドラムロール作成用のピッカー関連の設定(必須)
/*
//カテゴリ
        // ピッカー設定
        pickerView.delegate = self
        pickerView.dataSource = self
        //pickerView.showsSelectionIndicator = true
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // インプットビュー設定
        categoryTextField.inputView = pickerView
        categoryTextField.inputAccessoryView = toolbar
//カテゴリ
        
        // Do any additional setup after loading the view.
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

       
      
    }
*/
               titleTextField.text = task.title
               contentsTextView.text = task.contents
               datePicker.date = task.date
               categoryTextField.text = task.category
}//viewDidLoad()終了
    
/*
//カテゴリ開始
    // 決定ボタン押下
    @objc func done() {
        categoryTextField.endEditing(true)
        categoryTextField.text = "\(categoryList[pickerView.selectedRow(inComponent: 0)])"
    }
//カテゴリ終了
*/
// MARK: -　背景タップでdismissKeyboard()の呼び出し

    @objc func dismissKeyboard(){
        //キーボードを閉じる
        view.endEditing(true)
    }
    
// MARK: -　遷移する際に、画面が非表示になるとき呼ばれるメソッド
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.categoryTextField.text!
            
            self.realm.add(self.task, update: .modified)
        }
        
        //setNotificationは時間になったら表示
        setNotification(task: task)   // 追加
        super.viewWillDisappear(animated)
    }

// MARK: -　タスクのローカル通知の設定
    
    // タスクのローカル通知を登録する
    func setNotification(task: Task){
        let content = UNMutableNotificationContent()
//タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == ""{
            content.title = "(タイトルなし)"
        }else{
            content.title = task.title
        }
        if task.contents == ""{
            content.body = "(内容なし)"
        }else{
            content.body = task.contents
        }
        
        
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calender = Calendar.current
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request){(error) in print(error ?? "ローカル通知登録 OK")
            //→上記の元のクロージャ(error:Error?) -> Void in print(error ?? "ローカル通知登録 OK")
            
            
            // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests{(requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
                    
                }
                
            }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
/*
    // ドラムロール選択時 ...いらないかも
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.textField.text = list[row]
    }
*/

// MARK: -　ドラムロール作成時のextension（必須）

/*
extension InputViewController {
// ドラムロールの列数
 func numberOfComponents(in pickerView: UIPickerView) -> Int {
     return 1
 }
 
 // ドラムロールの行数
 func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
     /*
      列が複数ある場合は
      if component == 0 {
      } else {
      ...
      }
      こんな感じで分岐が可能
      */
     return categoryList.count
 }
 
 // ドラムロールの各タイトル
 func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
     /*
      列が複数ある場合は
      if component == 0 {
      } else {
      ...
      }
      こんな感じで分岐が可能
      */
     return categoryList[row]
 }
}

 */

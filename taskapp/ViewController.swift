//
//  ViewController.swift
//  taskapp
//
//  Created by 石田悠 on 2020/04/22.
//  Copyright © 2020 yuu.ishida. All rights reserved.
//

import UIKit
import RealmSwift   // ←追加
import PKHUD

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addSearchBar: UISearchBar!
    
// MARK: -
    //TableView再読込み・再描画用メソッド
    func TableViewReload(){
        self.taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        // リストを再描画する
        self.tableView.reloadData()
    }
    

// MARK: -　検索バー実装
    
    // 検索バーに入力に変更があった際に呼び出されるメソッド.
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //DispatchQueue.main.asyncAfter記述後の処理は0.2秒後に実行
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {

            self.taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
            if searchBar.text! != ""{
            
               // 検索文字列を生成する
               let searchText = searchBar.text!
                   
            // 検索対象の文字列を絞り込んで、リストにする 部分一致(contains)
            self.taskArray = self.taskArray.filter("category contains %@", searchText).sorted(byKeyPath: "date", ascending: true)
                   
               // リストを再描画する
               self.tableView.reloadData()
                
            }else{
                //TableView再読込み・再描画用メソッド
                self.TableViewReload()
            }
        }
           return true
    }


// MARK: -　検索バー表示設定

    // 検索バー編集開始時にキャンセルボタン有効化
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar){
        //キャンセルボタンの有効化とアニメーション
        addSearchBar.setShowsCancelButton(true, animated: true)
    }
// MARK: -
    // キャンセルボタンでキャセルボタン非表示
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        //キーボードを閉じる
        self.addSearchBar.resignFirstResponder()
        self.addSearchBar.text! = ""
        self.addSearchBar.setShowsCancelButton(false, animated: true)
        // リストを再描画する
        self.TableViewReload()
        }
    }
// MARK: -
    // 検索バーに入力に何もなくなった時（バツ押下時）
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
        //DispatchQueue.main.asyncAfter記述後の処理は0.2秒後に実行
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        //TableView再読込み・再描画用メソッド
        self.TableViewReload()
        }
        }
    }
// MARK: -　遷移先→遷移元
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    //PKHUDライブラリの取込みで実装
    HUD.flash(.labeledProgress(title: "更新中", subtitle: "お待ち下さい"), delay: 1.5)
        tableView.reloadData()
    }
    
// MARK: -　遷移元→遷移先（segue）
    // segue で画面遷移(遷移元→遷移先)する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        //"cellSegue"cellタップ時のsegue
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()

            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }

            inputViewController.task = task
        }
    }
    
// MARK: -　ライブラリRealm　<DB内のタスク格納>
    
    //Realmインスタンス取得
    let realm = try! Realm()
    
    //DB内のタスクが格納されるリスト
    //日付の近い順でソート：昇順
    //以降内容をアップデートするとリスト内は自動的に更新される
    //object:レルムに格納されている指定されたタイプのすべてのオブジェクトを返します。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)

// MARK: -　TableView読み込み時の前処理 <delegate>
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        addSearchBar.delegate = self
    }
// MARK: -　UITableViewDataSourceプロトコル必須メソッド① <画面切変え、更新の都度読み込み>

    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count //return 0 →修正
    }
// MARK: -　UITableViewDataSourceプロトコル必須メソッド② <画面切変え、更新の都度読み込み>
    // 各セルの内容を返す(テーブル内の1つ1つの行に対して、どんな内容を表示するかを返す)メソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // Fetch a cell of the appropriate type.
       //再利用可能な cell を得る。cellという箱の作成。 ("Cell"→TableViewCell)
       let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        //『as! CustomTableViewCell』カスタムセルを呼び出す際に必須
        
// MARK:　-
    // Cellに値を設定する.
    //行番号→[indexPath.row]における、taskArray配列を指す
      let task = taskArray[indexPath.row]
   // cell.textLabel?.text = task.title
      cell.mytextLabel?.text = task.title
      cell.myCustomLabel?.text = task.category
        

      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd HH:mm"

      let dateString:String = formatter.string(from: task.date)
    //cell.detailTextLabel?.text = dateString
      cell.mydetailLabel?.text = dateString
      return cell
    }
    
// MARK: -　各セルに対する実行メソッド
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    if editingStyle == .delete {
        // 削除するタスクを取得する
        let task = self.taskArray[indexPath.row]

        // ローカル通知をキャンセルする
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

        // データベースから削除する
        try! realm.write {
            self.realm.delete(task)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }
        
    }
}

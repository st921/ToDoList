//
//  ContentView.swift
//  ToDoList
//
//  Created by しょう on 2026/01/28.
//

import SwiftUI

// 1. データの「設計図」を作る
// 文字(String)だけでなく、IDと完了フラグ(Bool)をセットにする
// Identifiable: リストで管理しやすくする / Codable: 保存できるようにする / Equatable: 比較できるようにする
struct Task: Identifiable, Codable, Equatable {
    var id = UUID()         // タスクごとの背番号（自動発行）
    var title: String       // タスクの内容
    var isCompleted: Bool   // 完了したかどうか（true/false）
}

struct ContentView: View {
    // データの中身を[Task] に変更！
    @State private var tasks: [Task] = []
    @State private var newTaskTitle: String = "" // 変数名を少し分かりやすく変更

    // データの保存キー（形式が変わるのでキーも変えてリセットする）
    let saveKey = "SavedTasksV2"
    
    var body: some View {
        NavigationStack {
            VStack {//横に並べる
                // 入力エリア
                HStack {//縦に並べる
                    TextField("新しいタスク", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: addTask) {
                        Text("追加")
                            .bold()//太文字
                            .padding(.horizontal)//余白をつける(左右に標準的に)
                            .padding(.vertical, 8)//余白をつける(8ポイント分)
                            .background(Color.indigo) //背景に色をつける
                            .foregroundColor(.white)//文字に色をつける
                            .cornerRadius(8)//角に丸みをつける
                    }
                    .disabled(newTaskTitle.isEmpty)//入力欄が空の時にボタンが押せないようにする
                }
                .padding()//余白
                
                // リストの表示エリア
                List {
                    // $tasks と書くことで、リストの中でデータを書き換えられるようにする（バインディング）
                    ForEach($tasks) { $task in
                        HStack {
                            // 2. タップで完了/未完了を切り替えるボタン
                            Button(action: {
                                task.isCompleted.toggle() // trueとfalseを反転させる魔法の命令
                            }) {
                                // 完了状態によってアイコンを変える
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isCompleted ? .green : .gray)
                                    .font(.title2)
                            }
                            .buttonStyle(PlainButtonStyle()) // リスト全体のタップ判定を防ぐためのおまじない

                            // タスクの文字
                            Text(task.title)
                                .font(.system(.body, design: .rounded))
                                .strikethrough(task.isCompleted) // 完了なら取り消し線をつける
                                .foregroundColor(task.isCompleted ? .gray : .primary) // 完了なら色を薄くする
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    // スワイプで削除する機能
                    .onDelete(perform: deleteTask)
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("ToDoリスト")
            
            // 起動時のデータ読み込み
            .onAppear {
                if let data = UserDefaults.standard.data(forKey: saveKey) {
                    // [String] ではなく [Task] として読み込む
                    if let decoded = try? JSONDecoder().decode([Task].self, from: data) {
                        tasks = decoded
                    }
                }
            }
            // データの保存（変更検知）
            .onChange(of: tasks) {
                if let encoded = try? JSONEncoder().encode(tasks) {
                    UserDefaults.standard.set(encoded, forKey: saveKey)
                }
            }
        }
    }
    
    // タスクを追加する機能
    func addTask() {
        // ただの文字ではなく「Task」というオブジェクトを作って追加する
        let newTask = Task(title: newTaskTitle, isCompleted: false)
        tasks.append(newTask)
        newTaskTitle = "" // 入力欄を空にする
    }
    
    // タスクを削除する機能
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}

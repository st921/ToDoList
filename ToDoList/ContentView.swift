//
//  ContentView.swift
//  ToDoList
//
//  Created by しょう on 2026/01/28.
//

import SwiftUI

// 文字(String)だけでなく、IDと完了フラグ(Bool)をセットにする
// Identifiable: リストで管理しやすくする / Codable: 保存できるようにする / Equatable: 比較できるようにする
struct Task: Identifiable, Codable, Equatable {
    var id = UUID()         // タスクごとの背番号（自動発行）
    var title: String       // タスクの内容
    var isCompleted: Bool   // 完了したかどうか（true/false）
}

struct TaskRow: View {
    @Binding var task: Task
    
    var body: some View {
        HStack{
            Button(action:{
                //振動
                simpleHaptic(style:.medium)
                //アニメーション
                withAnimation{
                    task.isCompleted.toggle()
                }
            }){
                Image(systemName:task.isCompleted ? "checkmark.circle.fill": "circle").foregroundColor(task.isCompleted ? .green: .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            //タスク名
            Text(task.title)
                .font(.system(.body,design:.rounded))
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .gray: .primary)
            
            Spacer()
        }
        .padding(.vertical,4)
    }
    //振動させる
    func simpleHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle){
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
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
                        TaskRow(task:$task)
                    }
                    // スワイプで削除する機能
                    .onDelete(perform: deleteTask)
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("ToDoリスト")
            
            // 起動時のデータ読み込み
            .onAppear (perform:loadTasks)
            // データの保存（変更検知）
            .onChange(of: tasks){oldValue, newValue in saveTasks(newValue: newValue)}
        }
    }
    
    // タスクを追加する機能
    func addTask() {
            let newTask = Task(title: newTaskTitle, isCompleted: false)
            // 追加した時も振動させる
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            withAnimation {
                tasks.append(newTask)
            }
            newTaskTitle = ""
        }
        
        func deleteTask(at offsets: IndexSet) {
            // 削除する時も少し重めの振動を入れる
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            tasks.remove(atOffsets: offsets)
        }
        
        // 保存・読み込み処理
        func saveTasks(newValue: [Task]) {
            if let encoded = try? JSONEncoder().encode(tasks) {
                UserDefaults.standard.set(encoded, forKey: saveKey)
            }
        }
        
        func loadTasks() {
            if let data = UserDefaults.standard.data(forKey: saveKey) {
                if let decoded = try? JSONDecoder().decode([Task].self, from: data) {
                    tasks = decoded
                }
            }
        }
    }

#Preview {
    ContentView()
}

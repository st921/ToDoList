//
//  ContentView.swift
//  ToDoList
//
//  Created by しょう on 2026/01/28.
//

import SwiftUI

struct ContentView: View {
    @State private var tasks: [String] = ["英語の勉強","iOSの勉強","読書"]
    @State private var newTask: String = "" // 新しくタスクを追加する
    
    //データを保存するためのキー
    let saveKey = "SavedTasks"
    
    var body: some View {
        NavigationStack{//データが置き換わった時などの画面遷移が可能
            VStack{//VStackは縦に並べる
                HStack{//HStackは横に並べる
                    TextField("新しいタスク", text: $newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: addTask){
                        Text("追加")
                            .bold()//太文字にする
                            .padding(.horizontal)//余白をつける（左右に標準的に）
                            .padding(.vertical, 8)//余白をつける（上下に8ポイント分）
                            .background(Color.indigo)//背景に色をつける
                            .foregroundColor(.white)//文字に色をつける
                            .cornerRadius(8)//角に丸みをつける
                    }
                    .disabled(newTask.isEmpty)//入力欄が空の時にボタンが押せないようにする
                }
                .padding()//余白
                
                //リストの表示エリア
                List{
                    ForEach(tasks,id:\.self){task in
                        Text(task)
                    }
                        //Foreach:taskからデータを1つずつ取り出す。\.selfは文字自体をidに
                    //スワイプで削除する機能
                    .onDelete(perform: deleteTask)
                }
            }
            .navigationTitle("ToDoリスト")
            
            .onAppear{
                if let data = UserDefaults.standard.stringArray(forKey: saveKey){
                    if let decoded = try? JSONDecoder().decode([String].self, from: Data(data.joined().utf8)){
                        tasks = decoded
                    }
                }
            }
            .onChange(of: tasks){
                if let encoded = try? JSONEncoder().encode(tasks){
                    UserDefaults.standard.set(encoded, forKey:saveKey)
                }
            }
        }
    }
    //タスクを追加する機能
    func addTask(){
        tasks.append(newTask)//リストに新しいデータを追加する
        //appendは末尾に追加するということ
        newTask = ""//入力欄を空にする
    }
    //タスクを削除する機能
    func deleteTask(at offsets: IndexSet){
        //offsetsは何番目っていうところ。IndexSetは複数を指定できるためIntではない。
        tasks.remove(atOffsets: offsets)
    }
}
#Preview {
    ContentView()
}

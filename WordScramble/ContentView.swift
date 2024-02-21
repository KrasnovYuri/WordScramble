//
//  ContentView.swift
//  WordScramble
//
//  Created by Юрий on 15.02.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never) //не даем писать заглавные буквы
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)//модификатор срабатывает при отправке любого текста и вызывает, addNewWord() когда пользователь нажимает return на клавиатуре. onSubmit() необходимо предоставить функцию, которая не принимает параметров и ничего не возвращает.
            .onAppear(perform: startGame) //SwiftUI предоставляет нам специальный модификатор представления для запуска замыкания, при отображении представления, поэтому мы можем использовать его для вызова startGame()
            .alert(errorTitle, isPresented: $showingError) {
            } message: {
                Text(errorMessage)
            }
        }
    }
    func addNewWord() {
        //пишем слово в нижнем регистре и обрезаем его, чтобы убедиться, что мы не добавляем повторяющиеся слова с различиями в регистре
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0) //Добавляем в начало списка
        }
        newWord = ""
    }
    
    func startGame() {
        // 1. Найдем URL-адрес нашего текстового файла.
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Сможем ли загрузить этот файл в виде строки.
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Создадим массив всех слов.
                let allWords = startWords.components(separatedBy: "\n")

                // 4. Выберем одно случайное слово и присвоим ему значение корневого слова.
                rootWord = allWords.randomElement() ?? "silkworm"

                return
            }
        }

        // Если дойдем до этой строки это означает мы не смогли найти файл.
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word) // Метод принимает строку в качестве единственного параметра и возвращает true или false в зависимости от того, использовалось ли это слово раньше или нет.
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true // Как мы можем проверить, может ли случайное слово быть составлено из букв другого случайного слова? Если мы создадим переменную копию корневого слова, мы можем затем перебирать каждую букву вводимого пользователем слова, чтобы увидеть, существует ли эта буква в нашей копии. Если это произойдет, мы удалим его из копии (чтобы его нельзя было использовать дважды), затем продолжим. Если мы успешно добрались до конца слова пользователя, значит, слово правильное, в противном случае происходит ошибка, и мы возвращаем false.
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
        //Метод создаст экземпляр UITextChecker, который отвечает за сканирование строк на наличие слов с ошибками. Затем мы создадим NSRange для сканирования всей длины нашей строки, затем вызовем rangeOfMisspelledWord() нашу проверку текста, чтобы она искала неправильные слова. Когда это закончится, мы получим еще одно NSRange сообщение о том, где было найдено слово с ошибкой, но если слово было в порядке, местоположением для этого диапазона будет специальное значение NSNotFound.
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  JustScore
//
//  Created by 許君愷 on 2024/11/17.
//

import SwiftUI

struct RoundScore: Identifiable {
    let id = UUID() // Ensures each round score has a unique identifier
    let player1: Int
    let player2: Int
}

struct ContentView: View {
    @State private var player1Score = 0
    @State private var player2Score = 0
    @State private var player1WinTime = 0
    @State private var player2WinTime = 0
    @State private var lastPlayer1Score = 0
    @State private var lastPlayer2Score = 0
    @State private var winScore = 21
    @State private var FinWinScore = 21
    @State private var time = 2
    
    @State private var showingWinScoreInput = false
    @State private var showingTimeInput = false
    @State private var showSetting = false
    @State private var isReset = false
    @State private var inputScore = ""
    @State private var inputRound = ""
    @State private var isDeuce = true
    
    
    @State private var endTime = false
    @State private var endGame = false
    @State private var roundScores: [RoundScore] = []
    @State private var showSideMenu = false
    
    @State private var switchPlayer = true
    @State private var showPlayer = true
    
    var body: some View {
        HStack{
            if showSideMenu {
                VStack {
                    VStack(alignment: .leading) {
                        Text("Round Scores")
                            .font(.headline)
                            .padding()
                        
                        let listHeight = UIScreen.main.bounds.height * 0.7
                        
                        if roundScores.isEmpty {
                            Text("No Scores Yet")
                                .foregroundColor(Color.gray.opacity(0.6))
                                .font(.title3)
                                .italic()
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(height: listHeight)
                        } else {
                            List {
                                Text("P1 vs. P2")
                                ForEach(roundScores.indices, id: \.self) { index in
                                    Text("Round \(index + 1): \(roundScores[index].player1) - \(roundScores[index].player2)")
                                }
                            }
                            .frame(height: listHeight)
                        }
                    }
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding()
                    Spacer()
                }
                .frame(maxWidth: 240)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .transition(.move(edge: .leading))
                .zIndex(1)
            }


            VStack(alignment: .center){
                ZStack{
                    HStack{
                        Button(action: {
                            withAnimation {
                                showSideMenu.toggle()
                            }
                        }) {
                            Image(systemName: "sidebar.left")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        Spacer()
                        Text("Just Score")
                            .font(.largeTitle.bold())
                        Spacer()
                        Button(action: {
                            showSetting.toggle()
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title)
                                .foregroundColor(.blue)
                                .padding()
                        }
                    }
                }
                HStack {
                    HStack{
                        Spacer()
                        if showPlayer {
                            if switchPlayer {
                                playerOne
                                    .transition(
                                        .asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .trailing).combined(with: .opacity)
                                        )
                                    )
                            } else {
                                playerTwo
                                    .transition(
                                        .asymmetric(
                                            insertion: .move(edge: .trailing).combined(with: .opacity),
                                            removal: .move(edge: .trailing).combined(with: .opacity)
                                        )
                                    )
                            }
                            Spacer()
                            Divider()
                                .frame(width: 2)
                                .background(Color.gray)
                            Spacer()
                            if !switchPlayer {
                                playerOne
                                    .transition(
                                        .asymmetric(
                                            insertion: .move(edge: .leading).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        )
                                    )
                            } else {
                                playerTwo
                                    .transition(
                                        .asymmetric(
                                            insertion: .move(edge: .leading).combined(with: .opacity),
                                            removal: .move(edge: .leading).combined(with: .opacity)
                                        )
                                    )
                            }
                        }
                        Spacer()
                    }
                    .onChange(of: switchPlayer) { _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            showPlayer = false // 先移除
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showPlayer = true // 再移入
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack{
                        Button(action: {
                            showingWinScoreInput = true
                        }) {
                            Text(String(winScore))
                                .frame(width: 50, height: 40)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .alert("Set Winning Score", isPresented: $showingWinScoreInput, actions: {
                            TextField("Enter Score", text: $inputScore)
                                .keyboardType(.numberPad)
                            Button("Confirm") {
                                saveWinNum()
                            }
                            Button("Cancel", role: .cancel) {
                                inputScore = ""
                            }
                        })
                        
                        Button(action: {
                            showingTimeInput = true
                        }) {
                            Text(String(time))
                                .frame(width: 50, height: 30)
                                .background(Color.brown)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .alert("Set Number of Rounds", isPresented: $showingTimeInput, actions: {
                            TextField("Enter Rounds", text: $inputRound)
                                .keyboardType(.numberPad)
                            Button("Confirm") {
                                saveRounds()
                            }
                            Button("Cancel", role: .cancel) {
                                inputRound = ""
                            }
                        })
                        
                        Button(action: {
                            isDeuce.toggle()
                        }) {
                            if isDeuce{
                                Text("D")
                                    .font(.system(size: 30))
                                    .frame(width: 50, height: 50)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            } else {
                                ZStack{
                                    Image(systemName: "square.slash")
                                        .font(.system(size: 50))
                                    Text("D")
                                        .font(.system(size: 30))
                                }
                                .frame(width: 50, height: 50)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                switchPlayer.toggle()
                            }
                        }) {
                            Image(systemName: "rectangle.2.swap")
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            isReset = true
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .frame(width: 50, height: 50)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .alert("Are you sure you want to reset?", isPresented: $isReset, actions: {
                            Button("Reset", role: .destructive) {
                                resetGame()
                            }
                            Button("Cancel", role: .cancel) {
                                isReset = false
                            }
                        })
                    }
                }
            }
            .padding(.vertical)
            .sheet(isPresented: $showSetting) {
                VStack {
                    Text("")
                        .frame(width: 100, height: 4)
                        .background(Color.gray)
                        .padding(.bottom)
                    Text("Settings")
                        .font(.headline)
                    
                    ScrollView{
                        HStack {
                            Text("Set Winning Score:")
                            TextField("Enter Score", text: $inputScore)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding()
                        
                        HStack {
                            Text("Set Number of Rounds:")
                            TextField("Enter Rounds", text: $inputRound)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding()
                        
                        Toggle("Enable Deuce Mode", isOn: $isDeuce)
                            .padding()
                        
                    }
                    HStack {
                        Button("Save") {
                            saveSettings()
                            showSetting = false
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Cancel") {
                            showSetting = false
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
                .padding()
            }
            
            .alert("Round Over", isPresented: $endGame) {
                Button("OK") {}
            } message: {
                Text("Winner of this round: \(player1WinTime > player2WinTime ? "Player 1" : "Player 2")\nScores: \(lastPlayer1Score) - \(lastPlayer2Score)")
            }
            .alert("Game Over", isPresented: $endTime) {
                Button("Cancel", role: .cancel){
                    showSideMenu = true
                }
                Button("OK") {
                    resetGame()
                }
            } message: {
                Text("""
                        Final Scores:
                        Player 1: \(player1WinTime)
                        Player 2: \(player2WinTime)
                        
                        Round Details:
                        \(roundScores.enumerated().map { "Round \($0.offset + 1): \($0.element.player1) - \($0.element.player2)" }.joined(separator: "\n"))
                        
                        Press OK to restart the game
                        """)
            }
        }
    }
    
    func resetGame() {
        player1Score = 0
        player2Score = 0
        player1WinTime = 0
        player2WinTime = 0
        FinWinScore = winScore
        roundScores.removeAll()
    }
    
    func saveWinNum(){
        if let newScore = Int(inputScore), newScore > 0 {
            winScore = newScore
            FinWinScore = newScore
        }
        inputScore = ""
    }
    
    func saveRounds(){
        if let newTime = Int(inputRound), newTime > 0 {
            time = newTime
        }
        inputRound = ""
    }
    
    func saveSettings(){
        saveWinNum()
        saveRounds()
        
    }
    
    func updateScore(for player: Int, increment: Bool) {
        if player1Score == player2Score && player1Score > winScore - 2 && isDeuce{
            FinWinScore = player1Score + 2
        }
        if player == 1 {
            player1Score += increment ? 1 : -1
            if player1Score >= FinWinScore {
                player1WinTime += 1
                roundScores.append(RoundScore(player1: player1Score, player2: player2Score))
                lastPlayer1Score = player1Score
                lastPlayer2Score = player2Score
                player1Score = 0
                player2Score = 0
                FinWinScore = winScore
                if player1WinTime >= time {
                    endTime = true
                } else {
                    endGame = true
                }
            } else if player1Score <= 0{
                player1Score = 0
            }
        } else {
            player2Score += increment ? 1 : -1
            if player2Score >= FinWinScore {
                player2WinTime += 1
                roundScores.append(RoundScore(player1: player1Score, player2: player2Score))
                lastPlayer1Score = player1Score
                lastPlayer2Score = player2Score
                player1Score = 0
                player2Score = 0
                FinWinScore = winScore
                if player2WinTime >= time {
                    endTime = true
                } else {
                    endGame = true
                }
            } else if player2Score <= 0{
                player2Score = 0
            }
        }
    }
}

#Preview {
    ContentView()
}

extension ContentView{
    var playerOne: some View {
        VStack {
            Text("player 1")
                .font(.title2)
            Spacer()
            Text("\(player1Score)")
                .font(.system(size: 100))
                .fontWeight(.bold)
                .foregroundColor(.cyan)
            Text("\(player1WinTime)")
                .font(.system(size: 40))
                .fontWeight(.bold)
                .foregroundColor(.blue)
            Spacer()
            HStack {
                Button(action: {
                    updateScore(for: 1, increment: true)
                }) {
                    Text("+1")
                        .frame(width: 80, height: 60)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    updateScore(for: 1, increment: false)
                }) {
                    Text("-1")
                        .frame(width: 80, height: 60)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
    var playerTwo: some View{
        VStack {
            Text("player 2")
                .font(.title2)
            Spacer()
            Text("\(player2Score)")
                .font(.system(size: 100))
                .fontWeight(.bold)
                .foregroundColor(.purple)
            Text("\(player2WinTime)")
                .font(.system(size: 40))
                .fontWeight(.bold)
                .foregroundColor(.indigo)
            Spacer()
            HStack {
                Button(action: {
                    updateScore(for: 2, increment: true)
                }) {
                    Text("+1")
                        .frame(width: 80, height: 60)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    updateScore(for: 2, increment: false)
                }) {
                    Text("-1")
                        .frame(width: 80, height: 60)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
}

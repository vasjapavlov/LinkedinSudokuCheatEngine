//
//  ContentView.swift
//  Labdays_Nov_2025
//
//  Created by Vasja Pavlov on 2025-11-12.
//

import SwiftUI

struct SudokuView: View {
    @ObservedObject var viewModel: SudokuViewModel
    
    init(viewModel: SudokuViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 50) {
//            Button("Solve me") {
//                viewModel.solveSudoku()
//            }
            Text("Sudoku cheat")
                .font(.largeTitle)
            if let grid = viewModel.grid {
                Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                    ForEach(0..<6) { i in
                        HStack(spacing: 0) {
                            ForEach(0..<6) { j in
                                Text(
                                    grid[i][j] == 0 ? "" :
                                    "\(grid[i][j])"
                                )
                                    .fontWeight(.semibold)
                                    .foregroundStyle(
                                        viewModel.originalGrid?[i][j] == 0 ? .black: .gray
                                    )
                                    .font(.title)
                                    .frame(width: 60, height: 60)
                                    .background {
                                        Rectangle()
                                            .fill(.white)
                                            .border(.black)
                                    }
                                if (j + 1) % 3 == 0 {
                                    Color.black
                                        .frame(width: 2, height: 60)
                                }
                            }
                        }
                        if(i % 2 == 1) {
                        Color.black
                            .frame(height: 2)
                                .background(.red)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .padding()
                .onAppear {
                    viewModel.prepare()
                }
            }
        }
    }
}

#Preview {
    SudokuView(
        viewModel: SudokuViewModel(
            solver: SudokuSolver()
        )
    )
}

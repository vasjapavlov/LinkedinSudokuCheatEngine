# LinkedIn Sudoku Cheat Engine

An iOS app that automatically solves 6×6 Sudoku puzzles from screenshots using Vision AI to recognize patterns and a simple algorithm to solve the grid.

## Features

- 📸 **Image Recognition**: Extracts Sudoku grids from screenshots using Vision framework
- 🧩 **Auto Solver**: Simple semi-bruteforce algorithm that fills the grid one step at a time.
- ⚡ **Shortcuts Integration**: Solve puzzles directly from iOS Shortcuts

## How to Use

1. Open a sudoku puzzle
2. Run the "Solve Sudoku" shortcut
3. View the solved puzzle instantly

## Requirements

- iOS 16.0+
- Xcode 14.0+

## How It Works

1. Vision framework detects the grid and recognizes digits
2. Constraint solver fills empty cells using row, column, and block rules
3. Solution displays with original clues in gray, solved cells in black

---

Created during Labdays November 2025 by Vasja Pavlov

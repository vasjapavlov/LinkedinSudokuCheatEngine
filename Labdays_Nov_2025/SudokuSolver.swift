struct SudokuSolver {
    
    func solve(grid: SudokuGrid) -> SudokuGrid {
        
        var grid = grid
        while !isSolved(grid: grid) {
            let n = grid.count
            var cache: [Int : Int] = [:] // cache(hash(i,j)) = bitmask of 0...5
            for i in 0..<n {
                for j in 0..<n {
                    cache[hash(i, j)] = 0
                }
            }
            
            for i in 0..<n {
                for j in 0..<n {
                    let hash = hash(i, j)
                    if grid[i][j] != 0 {
                        continue
                    }
                    // mark all cells in column
                    for k in 0..<n {
                        if grid[k][j] == 0 {
                            continue
                        }
                        cache[hash]! |= (1 << (grid[k][j] - 1))
                    }
                    
                    // mark all cells in row
                    for k in 0..<n {
                        if grid[i][k] == 0 {
                            continue
                        }
                        cache[hash]! |= (1 << (grid[i][k] - 1))
                    }
                    //mark all cells in block
                    let blockRow = i / 2
                    let blockCol = j / 3
                    for ki in 0..<n {
                        for kj in 0..<n {
                            if grid[ki][kj] == 0 { continue }
                            if ki / 2 != blockRow || kj / 3 != blockCol {
                                continue
                            }
                            cache[hash]! |= (1 << (grid[ki][kj] - 1))
                        }
                    }
                }
            }
            // Marking done, find cell
            for i in 0..<n {
                for j in 0..<n {
                    let hash = hash(i, j)
                    if grid[i][j] != 0 {
                        continue
                    }
                    
                    if cache[hash]!.nonzeroBitCount == n-1 {
                        for k in 0..<n {
                            if (cache[hash]! & (1 << k)) == 0 {
                                grid[i][j] = k + 1
                                break
                            }
                        }
                    }
                }
            }
        }

        return grid
    }
    
    func hash(_ row: Int, _ col: Int) -> Int {
        row * 10 + col
    }
    
    func isSolved(grid: SudokuGrid) -> Bool {
        let n = grid.count
        
        for i in 0..<n {
            for j in 0..<n {
                if grid[i][j] == 0 {
                    return false
                }
            }
        }
        return true
    }
}

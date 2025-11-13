import Combine
import NotificationCenter

class SudokuViewModel: ObservableObject {
    @Published var grid: SudokuGrid? = [
        [0,0,0,0,0,0],
        [0,0,0,0,0,0],
        [0,0,0,0,0,0],
        [0,0,0,0,0,0],
        [0,0,0,0,0,0],
        [0,0,0,0,0,0]
//        [0,0,0,0,2,3],
//        [0,0,2,0,0,1],
//        [0,3,4,0,0,0],
//        [0,0,0,5,3,0],
//        [2,0,0,1,0,0],
//        [6,5,0,0,0,0]
    ]
    
    var originalGrid: SudokuGrid?
    private var cancellable: AnyCancellable?
    private let solver: SudokuSolver
    
    init(solver: SudokuSolver) {
        self.solver = solver
    }
    
    func solveSudoku() {
        if let grid {
            self.grid = solver.solve(grid: grid)
        }
    }

    func prepare() {
        cancellable = NotificationCenter
            .default
            .publisher(for: .didParseSudokuGrid)
            .sink { notification in
                guard let grid = notification.object as? SudokuGrid else {
                    return
                }
                self.originalGrid = grid
                self.grid = self.solver.solve(grid: grid)
            }
    }
}

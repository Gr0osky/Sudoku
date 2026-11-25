// solves a given sudoku
#include <vector>
#include <iostream>
using namespace std;

bool boardComplete(vector<vector<int>> &board){
    for(int i = 0; i < 9; i++){
        for(int j = 0; j < 9; j++){
            if(board[i][j] == 0){
                return false;
            }
        }
    }
    return true;
}

bool check(int k, vector<vector<int>> &board, int i, int j){

    // blocks  --> 0-2, 3-5, 6-8 (values for both rows and columns or i or j)

    int blockRow = (int)(i/3);
    int blockCol = (int)(j/3);

    // checking in block
    for(int x = 3*blockRow; x < 3*(blockRow+1); x++){
        for(int y = 3*blockCol; y < 3*(blockCol+1); y++){
            if(board[x][y] == k){
                return false;
            }
        }
    }

    // checking in column
    for(int x = 0; x < 9; x++){
        if(board[x][j] == k){
            return false;
        }
    }

    //checking in row
    for(int y = 0; y < 9; y++){
        if(board[i][y] == k){
            return false;
        }
    }

    return true;

}

// NOTE:  0 default value
void solver(vector<vector<int>> &board, int curRow, int curCol, bool &solFound){


    if(solFound == true){
        return;
    }

    if(boardComplete(board)){
        solFound = true;
        return;
    }

    bool checked = false;
    for(int i = curRow;  i < 9; i++){
        for(int j = 0; j < 9; j++){

            if(i == curRow && j==0){
                j += curCol;
            }
            if(board[i][j] != 0){
                continue;
            }
            else{
                // Recursive Backtracking
                for(int k = 1; k <= 9; k++){
                    checked = true;
                    if(check(k, board, i, j) == true){
                        board[i][j] = k;
                        solver(board, i, j, solFound);
                        if(solFound == true){
                            return;
                        }
                        board[i][j] = 0;
                    }
                }
                if(checked==true){
                    break;
                }
            }
        }
        if(checked==true){
            break;
        }
    }

}

int main(){
    bool solFound = false;
    vector<vector<int>> board(9, vector<int>(9));

    for(int i = 0; i < 9; i++){
        for(int j = 0; j < 9; j++){
            cin >> board[i][j];
        }
    }

    solver(board, 0, 0, solFound);

    // printing solutions
    for(int i = 0; i < 9; i++){
        for(int j = 0; j < 9; j++){
            cout << board[i][j] << " ";
        }
        cout << endl;
    }

    return 0;
}

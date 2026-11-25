// generates puzzles and saves them in lib/data/puzzles.bin
#include <ios>
#include <vector>
#include <iostream>
#include <fstream>
#include <random>
#include <algorithm>
using namespace std;

random_device rd;
mt19937 gen(rd());


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

    // blocks --> 0-2, 3-5, 6-8 (values for both rows and columns or i or j)

    int blockRow = (int)(i/3);
    int blockCol = (int)(j/3);

    // checking in block
    for(int x = 3*blockRow; x < 3*(blockRow + 1); x++){
        for(int y = 3*blockCol; y < 3*(blockCol+1); y++){
            if(board[x][y]==k){
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

    // checking in row
    for(int y = 0; y < 9; y++){
        if(board[i][y] == k){
            return false;
        }
    }

    return true;
}

void write(vector<vector<int>> &solution, ofstream &outFile){

    for(vector<int> row: solution){
        outFile.write(reinterpret_cast<const char*>(row.data()), row.size()*sizeof(int));
    }
}

void generate(vector<vector<int>> &board, int curRow, int curCol, int &count, ofstream &outFile){

    if(count == 10){
        return;
    }

    if((curRow==8) && (curCol==8) && (board[curRow][curCol]!=0) && boardComplete(board)){
        write(board, outFile);
        count++;
        return;
    }


    bool checked = false;
    for(int i = curRow; i < 9; i++){
        for(int j = 0; j < 9; j++){
            if(i == curRow && j == 0){
                j += curCol;
            }
            if(board[i][j] != 0){
                continue;
            }
            else{
                vector<int> numbers = {1, 2, 3, 4, 5, 6, 7, 8, 9};
                shuffle(numbers.begin(), numbers.end(), gen);
                // Recursive Backtracking
                for(int k: numbers){
                    checked = true;
                    if(check(k, board, i, j)){
                        board[i][j] = k;
                        generate(board, i, j, count, outFile);
                        board[i][j] = 0;
                    }
                }
                if(checked == true){
                    break;
                }
            }
        }
        if(checked == true){
            break;
        }
    }
}



int main(){
    ofstream outFile("../data/puzzles.bin", std::ios::out | std::ios::binary);
    if(!outFile){
        cout << "no file";
        return 0;
    }
    int count = 0;
    vector<vector<int>> board(9, vector<int>(9));
    generate(board, 0, 0, count, outFile);
    outFile.close();
    return 0;
}

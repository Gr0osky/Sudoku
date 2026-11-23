// reads puzzles from puzzles.bin and feeds to generate_window.dart in the windows folder.
#include <vector>
#include <ios>
#include <iostream>
#include <fstream>
#include <random>
using namespace std;


// Difficulty Standard  (empty blocks)
// easy - 5-30 (diff - 1)
// medium - 30-45 (diff - 2)
// hard - 45 to 60 (diff - 3)
void makePuzzle(vector<vector<int>> &board, mt19937 &gen, int diff){
    int emptyBlocks = 0;
    switch(diff){
        case 1: {
            uniform_int_distribution<> randDist(5,30);
            emptyBlocks = randDist(gen);
            break;
        }
        case 2: {
            uniform_int_distribution<> randDist(31, 45);
            emptyBlocks = randDist(gen);
            break;
        }
        case 3: {
            uniform_int_distribution<> randDist(46,60);
            emptyBlocks = randDist(gen);
        }
    }

    for(int i = 0; i < emptyBlocks; i++){
        uniform_int_distribution<> randDist(0,8);
        int randRow = randDist(gen);
        int randCol = randDist(gen);
        board[randRow][randCol] = 0;
    }
}



int main(int argc, char* argv[]){

    int diff = 1; // default easy
    if(argc > 1){
        diff = stoi(argv[1]);
    }

    ifstream inFile("./lib/data/puzzles.bin", ios::in | ios::binary);
    if(!inFile){
        cout << "no file";
        return 0;
    }

    vector<vector<int>> board(9, vector<int>(9));

    random_device rd;
    mt19937 gen(rd());
    uniform_int_distribution<> randDist(0,9); //inclusive

    int randInt = randDist(gen);
    int st = sizeof(int)*randInt*81;

    inFile.seekg(st, ios::beg);

    for(int i = 0; i < 9; i++){
        inFile.read(reinterpret_cast<char*>(board[i].data()), 9*sizeof(int));
    }
    inFile.close();

    makePuzzle(board, gen, diff);

    for(vector<int> row: board){
        for(int n: row){
            cout << n << " ";
        }
        cout << endl;
    }



}

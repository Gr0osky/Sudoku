#include "opencv2/core.hpp"
#include "opencv2/core/hal/interface.h"
#include "opencv2/highgui.hpp"
#include "opencv2/imgcodecs.hpp"
#include "opencv2/imgproc.hpp"
#include <iostream>
#include <vector>
#include <opencv2/opencv.hpp>
#include <tesseract/baseapi.h>

using namespace std;
using namespace cv;
using namespace tesseract;

int main(){
    Mat img = imread("./test/test.jpg", IMREAD_COLOR);
    Mat gray;
    cvtColor(img, gray, COLOR_BGR2GRAY);
    GaussianBlur(gray, gray, Size(5, 5), 0, 0);
    Mat bin;
    adaptiveThreshold(gray, bin, 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY_INV, 11, 2);
    cout << bin.rows << " " << bin.cols;
    namedWindow("Binary", WINDOW_NORMAL);
    resizeWindow("Binary", 1200, 800);
    imshow("Binary", bin);
    while(true){
        int key = waitKey(0);

        if(key==27){ // escape
            break;
        }
    }
    destroyAllWindows();
}

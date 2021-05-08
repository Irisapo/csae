#include <iostream>
#include <cmath>
#include <vector>

int main() {

    std::vector<int> vv = { 1,2,3,4,5 } ;
    for (auto i = vv.begin(); i != vv.end(); i++){
        std::cout << *i << ' ';
    }
    
    return 0;
}

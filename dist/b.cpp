#include <cmath>
#include <vector>
#include <random> // get  uniform rv 
#include <iostream>
#include <string>
#include <fstream>

std::vector<float> rv_Exp(const float lambda, const int n, unsigned seed = 1111)
{   
    std::vector<float> rv(n);

    std::mt19937 generator (seed);
    std::uniform_real_distribution<float> RV_u1(0.0, 1.0);
    for (int i=0; i<n; i++) {
        rv[i] = -1. / lambda * std::log( RV_u1(generator) );
    }
    
    return rv;
}  


std::vector<float> rv_b1 (const float shape, const int n, unsigned seed=1111)
{
    std::vector<float> rv(n);

    std::mt19937 generator (seed);
    std::uniform_real_distribution<float> RV_u1(0.0, 1.0), RV_u2(0.0, 1.0);
    float u1, u2;
    for (int i=0; i<n; i++) {
        do{
            u1 = RV_u1(generator); 
            u2 = RV_u2(generator);
        } while(u2 > std::pow(4.0 * u1 * (1.0-u1),  shape)); 
        rv[i] = u1;
    }
    return rv;
}

int main() {
    std::vector<float> rvb;
    int seed;
    std::cout << "Type in an integer as seed\n";
    std::cin >> seed;

    std::cout << "Type in file name to save results\n";
    std::string file_name;
    std::cin >> file_name;

    std::ofstream res_f (file_name);
    //rvb = rv_b1(4, 100, 12);
    rvb = rv_Exp(1.0, 100, seed); 
    for (std::vector<float>::iterator i = rvb.begin(); i != rvb.end(); ++i) {
        res_f << *i << ',';
    }
    //res_f << "\n";

    res_f.close();

    return 0;
}

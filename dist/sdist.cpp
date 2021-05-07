#include <cmath>
#include <vector>
#include <random> // get  uniform rv 

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


#include <cmath>
#include <vector>
#include <random> // get  uniform rv 
#include "boost/math/special_functions/bessel.hpp"  // use cyl_bessel_i

std::vector<float> rv_exp( float lambda,  int n, unsigned seed = 1111)
{
    std::vector<float> rv(n);

    std::mt19937 gt (seed);
    std::uniform_real_distribution<float> RV_u1(0., 1.);
    for (int i=0; i<n; i++) {
        rv[i] = -1. / lambda * std::log( RV_u1(gt) );
    }

    return rv;
}


std::vector<float> rv_b1 ( float shape,  int n, unsigned seed=1111)
{
    std::vector<float> rv(n);

    std::mt19937 gt (seed);
    std::uniform_real_distribution<float> RV_u1(0., 1.), RV_u2(0., 1.);
    float u1, u2;
    for (int i=0; i<n; i++) {
        do{
            u1 = RV_u1(gt); 
            u2 = RV_u2(gt);
        } while(u2 > std::pow(4. * u1 * (1.-u1),  shape)); 
        rv[i] = u1;
    }
    return rv;
}


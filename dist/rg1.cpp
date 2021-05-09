#include <cmath>
#include <vector>
#include <random> 
#include "boost/math/special_functions/bessel.hpp"  // use cyl_bessel_i

float logp_rg1 (float lambda, float a, float b, float x)
{
    // x >0, x Real
    // (Poi)lambda > 0; b > 0; a > 0 
    // a+lambda shape in gamma, b scale
    
    float logp;

    float bes = boost::math::cyl_bessel_i(a-1., 2.*std::sqrt(b*lambda*x));

    logp = std::log(b) + 0.5*(a-1)*std::log(x*b/lambda) + (-lambda-b*x) + std::log(bes);

    return logp;

}


std::vector<float> rv_rg1(float lambda, float a, float b, int n, unsigned seed=1111)
{
    std::vector<float> rv(n);
    std::mt19937 gen(seed); 
    
    std::poisson_distribution<int> RV_poi(lambda);

    int sp;
    for (int i=0; i<n; i++) {
        sp = RV_poi(gen);
        std::gamma_distribution<float> RV_gam(a+sp, b);
        rv[i] = RV_gam(gen);
    }
    return rv;
}

// rvb=rv_rg1(4., 0.2, 1., 10000);

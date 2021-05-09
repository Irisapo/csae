#include <cmath>
#include <vector>
#include <random> // get  uniform rv
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



#include <cmath>
#include <vector>
#include <random> 
#include "boost/math/special_functions/bessel.hpp"  // use cyl_bessel_i

const float PRECISION = 1e-9;


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

// One sample from RG1(lambda, a, b)
float rv_rg1(float lambda, float a, float b, std::mt19937& gen)
{
    int sp;
    float x;

    std::poisson_distribution<int> RV_poi(lambda);
    sp = RV_poi(gen);

    std::gamma_distribution<float> RV_gam(a+sp, b);
    x = RV_gam(gen);

    return x;
}

// Samples from RG1(lambda, a, b)
std::vector<float> rv_rg1(float lambda, float a, float b, int n, unsigned seed=1111)
{
    std::vector<float> rv(n);
    std::mt19937 gen(seed);


    for (int i=0; i<n; i++) {
        rv[i] = rv_rg1(lambda, a, b, gen);
    }
    return rv;
}
// exp: rv_rg1(4., 0.2, 1., 10000);



// One samples from PGP(lambda + 
int rv_pgp(float lambda, float a, float b, float c, std::mt19937& gen)
{
    
    float sample_rg1, m = c;
    int x;

    sample_rg1 = rv_rg1(lambda, a, b, gen);
    m *= sample_rg1;

    if (m < PRECISION) {
        x = 0;
    } else
    {
        std::poisson_distribution<int> RV_poi(m);
        x = RV_poi(gen);
    }
    return x;

}

// Samples from PGP(lambda + 
std::vector<int> rv_pgp(float lambda, float a, float b, float c, int n, unsigned seed=1111)
{
    
    std::vector<int> rv(n); 
    
    float sample_rg1;
    std::mt19937 gen(seed);


    for (int i=0; i<n; i++) {
        rv[i] = rv_pgp(lambda, a, b, c, gen);
    }

    return rv;
}


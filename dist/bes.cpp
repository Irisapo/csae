#include <cmath>
#include <vector>
#include <random> // get  uniform rv
#include "boost/math/special_functions/bessel.hpp"  // use cyl_bessel_i

float logp_bes_unnorm (float a, float nu, float m)
{
    float logpm_unnorm;

    logpm_unnorm = (2*m+nu) * std::log(a/2.) - std::lgamma(m+1) - std::lgamma(m+nu+1);

    return logpm_unnorm;
}


// prob of bes(nu,a, x=m)
float p_bes(float a, float nu, float m)
{
    float logpm_unnorm, pm;
    float norm_bes;

    norm_bes = boost::math::cyl_bessel_i(nu, a);

    logpm_unnorm = logp_bes_unnorm(a, nu, m);
    pm = std::exp(logpm_unnorm) / norm_bes;

    return pm;
}

float rv_bes(float a, float nu, std::mt19937& gen)
{
    //return integer as float
    float m;
    m = std::round( (std::sqrt(a*a+nu*nu) - nu) * .5 );

    float pm, pmx;
    pm = p_bes(a, nu, m);
    float w = 1. + pm * .5;

    float u1, u2;
    float x, y, j;
    bool s;

    std::uniform_real_distribution<float> RV_u(0., 1.);
    std::exponential_distribution<float> RV_e(1.);
    std::bernoulli_distribution RV_b(0.5);

    do{
        u1 = RV_u(gen);
        u2 = RV_u(gen);
        s = RV_b(gen);
        y = (u1 < w/(1.+w)) ? w*RV_u(gen)/pm : (w+RV_e(gen))/pm ;
        x = std::round(y);
        if (s == false) {
            x *= -1;
        }
        pmx = p_bes(a, nu, m+x);
        j = std::log(u2);
        if ( (w-pm*y)<0 ) {
            j += w-pm*y;
        }
    } while( j > std::log(pmx)-std::log(pm) );

    return m+x;
}


// maybe change to std::vector<int>
std::vector<float> rv_bes ( float a,  float nu,  int n, unsigned seed=1111)
{
    // nu > -1, a > 0 
    std::vector<float> rv(n);

    std::mt19937 gen(seed);

    for(int i=0; i<n; i++) {
        rv[i] = rv_bes(a, nu, gen);
    }

    return rv;
}


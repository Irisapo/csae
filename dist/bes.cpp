#include <cmath>
#include <vector>
#include <random> // get  uniform rv
#include "boost/math/special_functions/bessel.hpp"  // use cyl_bessel_i

float log_pm_unnorm (float a, float nu, float m)
{
    float logpm_unnorm;

    logpm_unnorm = (2*m+nu) * std::log(a/2.) - std::lgamma(m+1) - std::lgamma(m+nu+1);

    return logpm_unnorm;
}


// prob of bes(nu,a, x=m)
float p_m(float a, float nu, float m)
{
    float logpm_unnorm, pm;
    float norm_bes;

    norm_bes = boost::math::cyl_bessel_i(nu, a);

    logpm_unnorm = log_pm_unnorm(a, nu, m);
    pm = std::exp(logpm_unnorm) / norm_bes;

    return pm;
}

// maybe change to std::vector<int>
std::vector<float> rv_bes ( float a,  float nu,  int n, unsigned seed=1111)
{
    // nu > -1, a > 0 
    std::vector<float> rv(n);

    float m;
    m = std::round( (std::sqrt(a*a+nu*nu) - nu)/2. );

    float pm;
    pm = p_m(a, nu, m);

    float w = 1. + pm/2.;

    std::uniform_real_distribution<float> RV_u(0., 1.);
    std::exponential_distribution<float> RV_e(1.);
    std::bernoulli_distribution RV_b(0.5);
    std::mt19937 generator (seed);
    float u1, u2;
    float x, y;
    float pmx, j;
    bool s;


    for(int i=0; i<n; i++) {
        do{
            u1 = RV_u(generator);
            u2 = RV_u(generator);
            s = RV_b(generator);
            y = (u1 < w/(1+w)) ? w*RV_u(generator)/pm : (w+RV_e(generator))/pm ;
            x = std::round(y);
            if (s == false) {
                x *= -1;
            }
            pmx = p_m(a, nu, m+x);
            j = std::log(w);
            if ( (u2-pm*y)<0 ) {
                j += u2-pm*y;
            }
        } while( j > std::log(pmx)-std::log(pm) );
        rv[i] = m+x;
    }

    return rv;

}


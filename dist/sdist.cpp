#include <cmath>
#include <vector>
#include <random> // get  uniform rv 

std::vector<float> rv_exp( float lambda,  int n, unsigned seed = 1111)
{
    std::vector<float> rv(n);

    std::mt19937 generator (seed);
    std::uniform_real_distribution<float> RV_u1(0., 1.);
    for (int i=0; i<n; i++) {
        rv[i] = -1. / lambda * std::log( RV_u1(generator) );
    }

    return rv;
}


std::vector<float> rv_b1 ( float shape,  int n, unsigned seed=1111)
{
    std::vector<float> rv(n);

    std::mt19937 generator (seed);
    std::uniform_real_distribution<float> RV_u1(0., 1.), RV_u2(0., 1.);
    float u1, u2;
    for (int i=0; i<n; i++) {
        do{
            u1 = RV_u1(generator); 
            u2 = RV_u2(generator);
        } while(u2 > std::pow(4. * u1 * (1.-u1),  shape)); 
        rv[i] = u1;
    }
    return rv;
}


// prob of bes(nu,a, x=m)
float p_m(float a, float nu, float m)
{
    float logpm_unnor, pm;
    float norm_bes;

    norm_bes = std::cyl_bessel_if(nu, a);

    logpm_unnorm = (2*m+nu) * std::log(a/2.) - std::lgamma(m+1) - lgamma(m+nu+1);

    pm = std::exp(logpm_unnorm) / norm_bes;

    return pm
}



std::vector<int> rv1_bes ( float a,  float nu,  int n, unsigned seed=1111)
{
    // nu > -1, a > 0 
    float m;
    m = std::round( (std::sqrt(a*a+nu*nu) - nu)/2. );
    
    float pm;
    pm = p_m(a, nu, m); 

    float w = 1. + pm/2.;

    std::vector<int> rv(n);

    for(int i=0; i<n; i++) {
        do{
            //
            //val = ?? ;
        } while();
        rv[i] = val;
    }
    
}




#ifndef BES_H
#define BES_H

#include <random>
#include <vector>

float logp_bes_unnorm (float a, float nu, float m);

float p_bes(float a, float nu, float m);

float rv_bes(float a, float nu, std::mt19937& gen);

std::vector<float> rv_bes(float a, float nu, int n, unsigned seed);

#endif 

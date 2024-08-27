static public class SphereHarmonic {
    static int kCacheSize = 12;

    static public float EvalSH(int l, int m, Vector3 dir) {
        if (l<0 || m<-l||m>l) {
            throw new RuntimeException("Invalid number");
        }
        dir = dir.unit_vector();
        if (l<=4) {
            switch(l) {
            case 0:
                return HardcodedSH00(dir);
            case 1:
                switch(m) {
                case -1:
                    return HardcodedSH1n1(dir);
                case  0:
                    return HardcodedSH10(dir);
                case  1:
                    return HardcodedSH1p1(dir);
                }
            case 2:
                switch(m) {
                case -2:
                    return HardcodedSH2n2(dir);
                case -1:
                    return HardcodedSH2n1(dir);
                case  0:
                    return HardcodedSH20(dir);
                case  1:
                    return HardcodedSH2p1(dir);
                case  2:
                    return HardcodedSH2p2(dir);
                }
            case 3:
                switch(m) {
                case -3:
                    return HardcodedSH3n3(dir);
                case -2:
                    return HardcodedSH3n2(dir);
                case -1:
                    return HardcodedSH3n1(dir);
                case  0:
                    return HardcodedSH30(dir);
                case  1:
                    return HardcodedSH3p1(dir);
                case  2:
                    return HardcodedSH3p2(dir);
                case  3:
                    return HardcodedSH3p3(dir);
                }
            case 4:
                switch(m) {
                case -4:
                    return HardcodedSH4n4(dir);
                case -3:
                    return HardcodedSH4n3(dir);
                case -2:
                    return HardcodedSH4n2(dir);
                case -1:
                    return HardcodedSH4n1(dir);
                case  0:
                    return HardcodedSH40(dir);
                case  1:
                    return HardcodedSH4p1(dir);
                case  2:
                    return HardcodedSH4p2(dir);
                case  3:
                    return HardcodedSH4p3(dir);
                case  4:
                    return HardcodedSH4p4(dir);
                }
            }
        } else {
            return EvalSHSlow(l, m, dir);
        }
        return 0;
    }
    static public float EvalSH(int l, int m, float phi, float theta) {
        if (l<0 || m<-l||m>l) {
            throw new RuntimeException("Invalid number");
        }
        if (l <= 4) {
            return EvalSH(l, m, toVector(phi, theta));
        } else {
            return EvalSHSlow(l, m, phi, theta);
        }
    }
    static public float EvalSHSlow(int l, int m, Vector3 d) {
        if (l<0 || m<-l||m>l) {
            throw new RuntimeException("Invalid number");
        }
        float[] pt = ToSphericalCoords(d.unit_vector());
        return EvalSHSlow(l, m, pt[0], pt[1]);
    }

    static public float Clamp(float n, float x1, float x2) {
        return min(max(n, x1), x2);
    }

    static public float[] ToSphericalCoords(Vector3 dir) {
        float theta = acos(Clamp(dir.z(), -1.0, 1.0));
        float phi = atan2(dir.y(), dir.x());
        return new float[]{phi, theta};
    }

    static public float EvalSHSlow(int l, int m, float phi, float theta) {
        if (l<0 || m<-l||m>l) {
            throw new RuntimeException("Invalid number");
        }

        float kml = sqrt((2.0 * l + 1) * Factorial(l - abs(m)) / (4.0 * PI * Factorial(l + abs(m))));
        if (m > 0) {
            return sqrt(2.0) * kml * cos(m * phi) * EvalLegendrePolynomial(l, m, cos(theta));
        } else if (m < 0) {
            return sqrt(2.0) * kml * sin(-m * phi) * EvalLegendrePolynomial(l, -m, cos(theta));
        } else {
            return kml * EvalLegendrePolynomial(l, 0, cos(theta));
        }
    }

    static public Vector ProjectFunctionDiffuse(int shOrder, SphericalFunction function, Sampler sampler) {
        Vector result = new Vector(shOrder*shOrder);
        for (int i = 0; i<sampler.samples.size(); i+=1) {
            float phi = sampler.samples.get(i).v[0];
            float theta = sampler.samples.get(i).v[1];
            float func_val = function.getValue(phi, theta);
            for (int l = 0; l<shOrder; l+=1) {
                for (int m=-l; m<=l; m+=1) {
                    int ind = l*(l+1)+m;
                    float sh = sampler.shValue.m[i][ind];
                    result.v[ind]+=sh*func_val;
                }
            }
            
        }
        float weight = (float)4.0*PI/(float)(sampler.samples.size());
        for (int i=0; i<result.s; i+=1) {
            result.v[i]*=weight;
        }

        return result;
    }
    static public Matrix ProjectFunctionGlossy(int shOrder, SphericalFunction function, Sampler sampler) {
        int order2 = shOrder*shOrder;
        Matrix result = new Matrix(order2, order2);
        for (int i = 0; i<sampler.samples.size(); i+=1) {
            float phi = sampler.samples.get(i).v[0];
            float theta = sampler.samples.get(i).v[1];
            float func_val = function.getValue(phi, theta);

            for (int li = 0; li<shOrder; li+=1) {
                for (int mi=-li; mi<=li; mi+=1) {
                    for (int lj = 0; lj<shOrder; lj+=1) {
                        for (int mj=-lj; mj<=lj; mj+=1) {
                            int iindex = li*(li+1)+mi;
                            int jindex = lj*(lj+1)+mj;
                            result.m[iindex][jindex]+= sampler.shValue.m[i][iindex] * sampler.shValue.m[i][jindex] * func_val;
                        }
                    }
                }
            }
        }

        float weight = (float)4.0*PI/(float)(sampler.samples.size());
        for (int li = 0; li<shOrder; li+=1) {
            for (int mi=-li; mi<=li; mi+=1) {
                for (int lj = 0; lj<shOrder; lj+=1) {
                    for (int mj=-lj; mj<=lj; mj+=1) {
                        int iindex = li*(li+1)+mi;
                        int jindex = lj*(lj+1)+mj;
                        result.m[iindex][jindex]*=weight;
                    }
                }
            }
        }
        return result;
    }

    static public float Factorial(int n) {
        float[] factorial_cache = {1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 39916800};
        if (n<factorial_cache.length) return factorial_cache[n];
        else {
            float s = factorial_cache[kCacheSize-1];
            for (int i=kCacheSize; i<=n; i+=1) {
                s*=i;
            }
            return s;
        }
    }

    static public float DoubleFactorial(int n) {
        float[] dbl_factorial_cache = {1, 1, 2, 3, 8, 15, 48, 105, 384, 945, 3840, 10395};
        if (n < kCacheSize) return dbl_factorial_cache[n];
        else {
            float s = dbl_factorial_cache[kCacheSize - (n % 2 == 0 ? 2 : 1)];
            float x = n;
            while (x >= kCacheSize) {
                s *= x;
                x -= 2.0;
            }
            return s;
        }
    }

    static public float EvalLegendrePolynomial(int l, int m, float x) {
        // Compute Pmm(x) = (-1)^m(2m - 1)!!(1 - x^2)^(m/2), where !! is the double factorial.
        float pmm = 1.0;
        // P00 is defined as 1.0, do don't evaluate Pmm unless we know m > 0
        if (m > 0) {
            float sign = (m % 2 == 0 ? 1 : -1);
            pmm = sign * DoubleFactorial(2 * m - 1) * pow(1 - x * x, m / 2.0);
        }

        if (l == m) {
            // Pml is the same as Pmm so there's no lifting to higher bands needed
            return pmm;
        }

        // Compute Pmm+1(x) = x(2m + 1)Pmm(x)
        float pmm1 = x * (2 * m + 1) * pmm;
        if (l == m + 1) {
            // Pml is the same as Pmm+1 so we are done as well
            return pmm1;
        }

        // Use the last two computed bands to lift up to the next band until l is
        // reached, using the recurrence relationship:
        // Pml(x) = (x(2l - 1)Pml-1 - (l + m - 1)Pml-2) / (l - m)
        for (int n = m + 2; n <= l; n++) {
            float pmn = (x * (2 * n - 1) * pmm1 - (n + m - 1) * pmm) / (n - m);
            pmm = pmm1;
            pmm1 = pmn;
        }
        // Pmm1 at the end of the above loop is equal to Pml
        return pmm1;
    }

    static private float HardcodedSH00(Vector3 d) {
        return 0.282095;
    }
    static private float HardcodedSH1n1(Vector3 d) {
        // -sqrt(3/(4pi)) * y
        return -0.488603 * d.y();
    }

    static private float HardcodedSH10(Vector3 d) {
        // sqrt(3/(4pi)) * z
        return 0.488603 * d.z();
    }

    static private float HardcodedSH1p1(Vector3 d) {
        // -sqrt(3/(4pi)) * x
        return -0.488603 * d.x();
    }

    static private float HardcodedSH2n2(Vector3 d) {
        // 0.5 * sqrt(15/pi) * x * y
        return 1.092548 * d.x() * d.y();
    }

    static private float HardcodedSH2n1(Vector3 d) {
        // -0.5 * sqrt(15/pi) * y * z
        return -1.092548 * d.y() * d.z();
    }

    static private float HardcodedSH20(Vector3 d) {
        // 0.25 * sqrt(5/pi) * (-x^2-y^2+2z^2)
        return 0.315392 * (-d.x() * d.x() - d.y() * d.y() + 2.0 * d.z() * d.z());
    }

    static private float HardcodedSH2p1(Vector3 d) {
        // -0.5 * sqrt(15/pi) * x * z
        return -1.092548 * d.x() * d.z();
    }

    static private float HardcodedSH2p2(Vector3 d) {
        // 0.25 * sqrt(15/pi) * (x^2 - y^2)
        return 0.546274 * (d.x() * d.x() - d.y() * d.y());
    }

    static private float HardcodedSH3n3(Vector3 d) {
        // -0.25 * sqrt(35/(2pi)) * y * (3x^2 - y^2)
        return -0.590044 * d.y() * (3.0 * d.x() * d.x() - d.y() * d.y());
    }

    static private float HardcodedSH3n2(Vector3 d) {
        // 0.5 * sqrt(105/pi) * x * y * z
        return 2.890611 * d.x() * d.y() * d.z();
    }

    static private float HardcodedSH3n1(Vector3 d) {
        // -0.25 * sqrt(21/(2pi)) * y * (4z^2-x^2-y^2)
        return -0.457046 * d.y() * (4.0 * d.z() * d.z() - d.x() * d.x()
            - d.y() * d.y());
    }

    static private float HardcodedSH30(Vector3 d) {
        // 0.25 * sqrt(7/pi) * z * (2z^2 - 3x^2 - 3y^2)
        return 0.373176 * d.z() * (2.0 * d.z() * d.z() - 3.0 * d.x() * d.x()
            - 3.0 * d.y() * d.y());
    }

    static private float HardcodedSH3p1(Vector3 d) {
        // -0.25 * sqrt(21/(2pi)) * x * (4z^2-x^2-y^2)
        return -0.457046 * d.x() * (4.0 * d.z() * d.z() - d.x() * d.x()
            - d.y() * d.y());
    }

    static private float HardcodedSH3p2(Vector3 d) {
        // 0.25 * sqrt(105/pi) * z * (x^2 - y^2)
        return 1.445306 * d.z() * (d.x() * d.x() - d.y() * d.y());
    }

    static private float HardcodedSH3p3(Vector3 d) {
        // -0.25 * sqrt(35/(2pi)) * x * (x^2-3y^2)
        return -0.590044 * d.x() * (d.x() * d.x() - 3.0 * d.y() * d.y());
    }

    static private float HardcodedSH4n4(Vector3 d) {
        // 0.75 * sqrt(35/pi) * x * y * (x^2-y^2)
        return 2.503343 * d.x() * d.y() * (d.x() * d.x() - d.y() * d.y());
    }

    static private float HardcodedSH4n3(Vector3 d) {
        // -0.75 * sqrt(35/(2pi)) * y * z * (3x^2-y^2)
        return -1.770131 * d.y() * d.z() * (3.0 * d.x() * d.x() - d.y() * d.y());
    }

    static private float HardcodedSH4n2(Vector3 d) {
        // 0.75 * sqrt(5/pi) * x * y * (7z^2-1)
        return 0.946175 * d.x() * d.y() * (7.0 * d.z() * d.z() - 1.0);
    }

    static private float HardcodedSH4n1(Vector3 d) {
        // -0.75 * sqrt(5/(2pi)) * y * z * (7z^2-3)
        return -0.669047 * d.y() * d.z() * (7.0 * d.z() * d.z() - 3.0);
    }

    static private float HardcodedSH40(Vector3 d) {
        // 3/16 * sqrt(1/pi) * (35z^4-30z^2+3)
        float z2 = d.z() * d.z();
        return 0.105786 * (35.0 * z2 * z2 - 30.0 * z2 + 3.0);
    }

    static private float HardcodedSH4p1(Vector3 d) {
        // -0.75 * sqrt(5/(2pi)) * x * z * (7z^2-3)
        return -0.669047 * d.x() * d.z() * (7.0 * d.z() * d.z() - 3.0);
    }

    static private float HardcodedSH4p2(Vector3 d) {
        // 3/8 * sqrt(5/pi) * (x^2 - y^2) * (7z^2 - 1)
        return 0.473087 * (d.x() * d.x() - d.y() * d.y())
            * (7.0 * d.z() * d.z() - 1.0);
    }

    static private float HardcodedSH4p3(Vector3 d) {
        // -0.75 * sqrt(35/(2pi)) * x * z * (x^2 - 3y^2)
        return -1.770131 * d.x() * d.z() * (d.x() * d.x() - 3.0 * d.y() * d.y());
    }

    static private float HardcodedSH4p4(Vector3 d) {
        // 3/16*sqrt(35/pi) * (x^2 * (x^2 - 3y^2) - y^2 * (3x^2 - y^2))
        float x2 = d.x() * d.x();
        float y2 = d.y() * d.y();
        return 0.625836 * (x2 * (x2 - 3.0 * y2) - y2 * (3.0 * x2 - y2));
    }
}

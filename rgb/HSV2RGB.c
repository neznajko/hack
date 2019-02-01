#include <stdio.h>
#include <stdlib.h>
// r,g,b values are from 0 to 1
// h = [0,360], s = [0,1], v = [0,1]
void HSV2RGB(float *r, float *g, float *b,
	     float h, float s, float v)
{
    if (s == 0) { // achromatic (grey)
	*r = *g = *b = v;
	return;
    }
    int j = (h /= 60.);          // sector number [0,5]
    float f = h - j;             // fractional part of h
    float p = v*(1 - s);         // don't have an idea what
    float q = v*(1 - s*f);       // these are
    float t = v*(1 - s*(1 - f)); // ...
    switch (j)
    {
    	case 0:
    	    *r = v; // this code is from somewhere but don't
    	    *g = t; // remember from where exactly
    	    *b = p;
    	    break;
    	case 1:
    	    *r = q;
    	    *g = v;
    	    *b = p;
    	    break;
    	case 2:
    	    *r = p;
    	    *g = v;
    	    *b = t;
    	    break;
    	case 3:
    	    *r = p;
    	    *g = q;
    	    *b = v;
    	    break;
    	case 4:
    	    *r = t;
    	    *g = p;
    	    *b = v;
    	    break;
    	case 5:
     	    *r = v;
    	    *g = p;
    	    *b = q;
    	    break;
	default:
	    break;
    }
}
// HSV2RGB wraper
// r, g, b are in [0, 255]
// h, s, v are in [0, 100]
void __HSV2RGB(float *r, float *g, float *b,
	       float h, float s, float v)
{
    static float mx = 0xff;
    
    HSV2RGB(r, g, b, h, s/100., v/100.);
    
    *r = (int) (*r*mx + .5);
    *g = (int) (*g*mx + .5);
    *b = (int) (*b*mx + .5);
}
int main(int argc, char *argv[])
{
    int i, j, n = 10;
    float r, g, b;
    float h, s, v;

    if (argc == 1) return 0;

    h = atoi(argv[1]);
    if (argc > 3) {
	s = atoi(argv[2]);
	v = atoi(argv[3]);
	__HSV2RGB(&r, &g, &b, h, s, v);
	printf("%g;%g;%g", r, g, b);
    } else {
	for (i = n - 1; i > -1; i--) {
	    for (j = 0; j < n; j++) {
		s = (j + .5)*10;
		v = (i + .5)*10;
		__HSV2RGB(&r, &g, &b, h, s, v);
		printf("%g;%g;%g\n", r, g, b);
	    }
	}
    }
    return 0;
}

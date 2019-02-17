#include <stdio.h>
#include <stdlib.h>

#define ext2(OP, A, B)    ((A) OP (B)? (A): (B))
#define ext3(OP, A, B, C) ext2(OP, ext2(OP, A, B), C)

#define min(A, B, C) ext3(<, A, B, C)
#define max(A, B, C) ext3(>, A, B, C)
// r,g,b values are from 0 to 1
// h = [0,360], s = [0,1], v = [0,1]
// if s == 0, then h = -1 (undefined)
void RGB2HSV(float r, float g, float b,
	     float *h, float *s, float *v)
{
    float min = min(r, g, b);
    float max = max(r, g, b);
    float delta = max - min;

    *v = max;
    if (r == g && g == b) {
	*h = *s = 0;
	return;
    }
    *s = delta/max;		
    if (r == max) {
	*h = (g - b)/delta;	// between yellow & magenta
    } else if (g == max) {
	*h = 2 + (b - r)/delta;	// between cyan & yellow
    } else {
	*h = 4 + (r - g)/delta;	// between magenta & cyan
    }
    *h *= 60;			// degrees
    if (*h < 0) *h += 360;
}
// RGB2HSV wraper
// r, g, b in [0; 255]
// h, s, v in [0; 100]
void __RGB2HSV(float r, float g, float b,
	       float *h, float *s, float *v)
{
	float mx = 255;

	RGB2HSV(r/mx, g/mx, b/mx, h, s, v);

	*s *= 100;
	*v *= 100;
	*h = (int) (*h + .5);
	*s = (int) (*s + .5);
	*v = (int) (*v + .5);
}
int main(int argc, char *argv[])
{
    float r, g, b;
    float h, s, v;

    if (argc > 3) {
	r = atoi(argv[1]);
	g = atoi(argv[2]);
	b = atoi(argv[3]);
	__RGB2HSV(r, g, b, &h, &s, &v);
	printf("%g;%g;%g", h, s, v);
    }
    return 0;
}

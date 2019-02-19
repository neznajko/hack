#include <stdio.h>
#include "gimp.h"
int main(void)
{
    char *fmt = " %d;%d;%d;%d;%d";
    int c[3];
    int i, j;
    for (j = 0; j < height; j++) {
	for (i = 0; i < width; i++) {
	    HEADER_PIXEL(header_data, c);
	    printf(fmt, i, j, c[0], c[1], c[2]);
	}
    }
    return 0;
}

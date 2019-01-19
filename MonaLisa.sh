#!/bin/bash
pixel()
# draw a pixel at current cursor position $1 is in the  #
# range [0-7] representing the color of that pixel ==== #
{
    echo -en "\033[4"$1"m  \033[m"
}
k()
# black *********************************************** #
{
    pixel 0
}
r()
# red ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
{
    pixel 1
}
g()
# green =============================================== #
{
    pixel 2
}
y()
# yellow $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ #
{
    pixel 3
}
b()
# blue ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #
{
    pixel 4
}
m()
# magenta ))))))))))))))))))))))))))))))))))))))))))))) #
{
    pixel 5
}
c()
# cyan <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< #
{
    pixel 6
}
w()
# white <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< #
{
    pixel 7
}
MonaLisa()
{
    y;y;y;y;y;y;y;y;y;b;b;b;b;b;y;y;y;y;y;y;y;echo
    y;y;y;y;y;y;b;b;b;b;b;b;b;b;b;b;b;y;y;y;y;echo
    y;y;y;y;b;b;b;m;b;b;b;b;b;b;b;b;b;b;b;y;y;echo
    y;y;y;b;b;b;b;m;b;b;b;b;b;b;b;b;b;b;b;b;y;echo
    y;y;b;b;b;m;m;m;m;b;b;b;b;b;b;b;b;b;b;b;b;echo
    y;b;b;b;m;m;m;m;m;m;m;m;b;b;b;b;b;b;b;b;b;echo
    y;g;m;m;m;m;m;m;m;m;m;m;m;b;b;b;b;b;b;b;b;echo
    y;b;m;m;m;m;m;m;m;m;m;m;m;m;b;b;b;b;b;b;b;echo
    y;b;m;m;m;m;m;m;m;m;m;m;m;m;b;b;b;b;b;b;b;echo
    b;b;m;m;m;m;m;m;m;m;m;m;m;m;m;b;b;b;b;b;b;echo
    b;b;m;m;m;m;m;m;m;m;m;m;m;m;m;m;b;b;b;b;b;echo
    b;b;m;m;m;m;m;m;m;m;m;m;m;m;m;m;b;b;b;b;b;echo
    b;b;m;m;m;m;m;m;m;b;b;m;m;m;m;m;b;b;b;b;b;echo
    b;b;b;b;b;b;m;m;b;b;m;b;b;b;b;b;b;b;b;b;b;echo
    b;b;b;m;b;b;m;m;b;m;m;b;b;b;b;m;b;b;b;b;b;echo
    b;b;m;m;b;m;m;m;b;m;m;m;b;m;m;m;b;b;b;b;b;echo
    b;m;m;m;m;m;m;m;b;m;m;m;m;m;m;m;b;b;b;b;b;echo
    b;m;m;m;m;m;m;m;m;m;m;m;m;m;m;m;b;b;b;b;b;echo
    b;b;m;m;m;m;m;m;m;m;m;m;m;m;m;m;b;b;b;b;b;echo
    b;b;m;m;m;b;m;b;b;m;m;m;m;m;m;b;b;b;b;b;b;echo
    b;b;m;m;m;m;b;b;b;m;m;m;m;m;b;b;b;b;b;b;b;echo
    b;b;b;m;m;m;m;m;m;m;m;m;m;m;m;b;b;b;b;b;b;echo
    b;b;b;m;m;m;m;b;b;b;b;m;m;m;b;b;b;b;b;b;b;echo
    b;b;b;m;m;m;m;m;m;m;m;m;m;m;b;b;b;b;b;b;b;echo
    b;b;b;b;m;m;m;b;b;m;m;m;m;b;b;b;b;b;b;b;b;echo
    b;b;b;b;b;m;m;m;m;m;m;m;b;b;b;b;b;b;b;b;b;echo
    b;b;b;b;b;b;m;m;m;m;b;b;b;b;b;b;b;b;b;b;b;echo
    b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;b;echo
}
MonaLisa

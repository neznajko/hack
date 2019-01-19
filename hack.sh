#!/bin/bash
# ip: a) save and re-establish the terminal 
#     b) move the code at bottom to baz
#     c) comment
########################################################
# SGR(Select Graphic Rendition) parameters ########### #
Aoff=0  # All attributes are off                       #
Bold=1  # Bold                                         #
Ital=3  # Italic                                       #
Unds=4  # Underscore                                   #
Blnk=5  # Blinking                                     #
Revs=7  # Reverse video                                #
Norm=22 # Normal `,`,`,`,`,`,`,`,`,`,`,`,`,`,`,`,`,`,` #
# #### Colours ####################################### #
White="255;255;255"
Red="255;0;0"
Green="0;255;0"
Yellow="255;255;0"
Blue="0;0;255"
Magenta="255;0;255"
Cyan="0;255;255"
Black="0;0;0"
########################################################
Bistre="53;19;13" #                                    #
Bole="100;54;46"  #                                    #
# ####### Foreground and Background colours ########## #
FgrClr=$White
BgrClr=$Black
############### All other non RGB related SGR parameters
SGR=$Norm
SetSGR()
{
    local IFS=';'
    printf -v SGR "$*"
}
# Pixel ############################################## #
# - an element of an array Picture (pix + el) %%%%%%%% #
# - coordinates are related to it's index ^^^^^^^^^^^^ #
# - all other information goes here <<<<<<<<<<<<<<<<<< #
# - background colour ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# - foreground colour                                  #
# - SGR attributes !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #
# - text characters `````````````````````````````````` #
# - changed flag (true if that pixel has been changed) #
# + some  stuff which i'm not aware of at the present  #
#   moment ___________________________________________ #
# At terminal we define pixel as a cursor's height     #
# plus two cursor's widths that's why we have on our   #
# disposal two text characters which we can use for    #
# texturing:) Pixel data is represented as a string    #
# like this "110;98;7;31;200;114;3;5;1;?!;0" Here      #
# 110;98;7 is the RGB of the background colour         #
# 31;200;114 is the RGB of the foreground colour the   #
# number of SRG attributes is not fixed here we have   #
# three attributes namely Italic, Blinking, and Bold:  #
# 3;5;1 and in the last field are the text characters  #
# 0 is the flag                                        #
Cols=$(tput cols) # terminal columns `,`,`,`,`,`,`,`,` #
Lines=$(tput lines) # terminal lines ================= #
########################################################
######## Something about the coordinates (coors). Zo the
# primary system iz the terminal itself, it spans from 1
######## to 'Cols in x direction and from 1 to 'Lines in
##### y direction, the origin iz at the top left corner.
#### Next coors are the Ruler's or Picture's coors. Here
# the main difference is that the measurement units in x
###### and y directions have the same values, namely the
### height of the cursor, thus forming a pixel. Alzo the
### origin is shifted one pixel diagonally, right bottom
##### direction. I'm not sure whether this is always the
####### case, but let's assume that the 'Cols is an even
## number, then 'Cols/2 is the number of pixels in x, zo
# the Ruler will span from 1 to Cols/2 - 1 in x and from
######################### 1 to 'Lines - 1 in y direction
Pixel=() ###### Pixel coors in Picture coordinate system
Cursor=() ### Cursor coors in Terminal coordinate system
Pixel2Cursor()
{
    Cursor[0]=$((2 * Pixel[0] + 1))
    Cursor[1]=$((Pixel[1] + 1))
}
Cursor2Pixel()
{
    Pixel[0]=$(((Cursor[0] - 1) / 2))
    Pixel[1]=$((Cursor[1] - 1))
}
Void='  '
Text=$Void ################################## Pixel text
Esc=$'\E' ########################################## Esc 
CSI="${Esc}[" ######Control###Sequence########Introducer
Display()
{
    printf "${CSI}${Cursor[1]};${Cursor[0]}H"
    printf "${CSI};38;2;$FgrClr;48;2;$BgrClr;${SGR}m"
    printf "%s" "${Text}" #### bug # 316 dash in Display
    printf "${CSI}m"
}
RulerW= #################################### Ruler Width
RulerH= ################################### Ruler Height
DrawGuide()
# $1 - direction (0 - horizontal, 1 - vertical) ########
# $2 - flag (0 - guide, 1 - ruler) #####################
# $3 - position (Picture coors) ########################
{                         
    local array=()
    local bgr=()
    array=($Bistre $Blue) 
    bgr[0]=${array[$2]}   
    array=($Bole $Red)
    bgr[1]=${array[$2]}
    local fgr=($Cyan $Yellow)
    local sgr=($Norm $Bold)
    ####################################################
    array=(1 0)            #                           #
    local jlo=${array[$2]} # Jennifer Lopez            #
    ####################################################
    array=($RulerW $RulerH) #                          #
    local jhi=${array[$1]}  #                          #
    ####################################################
    local j # zom local index                          #
    local c # condition                                #
    local r # ruler display                            #
    Text=$Void    #                                    # 
    Pixel[!$1]=$3 #                                    # 
    ####################################################
    for ((j = jlo; j < jhi; j++)); do
	Pixel[$1]=$j
	c=$[ $((j % 10)) == $((j / 10)) ] #   oo 
	if ((j == jhi - 1)); then c=1; fi
	################################################
	BgrClr=${bgr[c]} #                             #
	FgrClr=${fgr[c]} #                             #
	SGR=${sgr[c]}    #                             #
	################################################
	if (($2)); then                          
	    r=$j
	    if ((!$1)); then r=$((j % 10)); fi
	    printf -v Text "%2d" $r
	fi                                    
	################################################
	Pixel2Cursor                                   #
	Display # джисплей                             #
    done ###############################################
}
# Picture >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> #
SizeX= # --------------------------------------------- #
SizeY= # ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #
Size= # wow! +++++++++++++++++++++++++++++++++++++++++ #
########################################################
declare -a Pix # ))))))))))))))))))))))))))))))))))))) #
GetPixelIndex()
{
    local jx=$((Pixel[0] - 1))
    local jy=$((Pixel[1] - 1))
    printf $((jx + (SizeX * jy)))
}
Draw()
## this is like a Display function but the arguments are
###### in ruler's units zo we have to convert them first
{
    ###################################### Picture coors
    Pixel=($1 $2)
    Pixel2Cursor
    Display
    ############################################# update
    local j=$(GetPixelIndex)
    Pix[j]="$BgrClr;$FgrClr;$SGR;$Text;1"
}
########################################################
DrawFrame()
{
    clear
    ##############################################RULERZ
    DrawGuide 0 1 0
    DrawGuide 1 1 0
    ####GUIDES##########################################
    local j                            # our star      #
    local c                            # condition     #
    for ((j = 1; j < RulerW; j++)); do #             yeah!
	################################################
	c=$[ $((j % 10)) == $((j / 10)) ]
	if ((c)) || ((j == RulerW - 1)); then
	    DrawGuide 1 0 $j
	fi
    done ###############################################
    for ((j = 1; j < RulerH; j++)); do #               #
	################################################
	c=$[ $((j % 10)) == $((j / 10)) ]
	if ((c)) || ((j == RulerH - 1)); then
	    DrawGuide 0 0 $j
	fi
    done ###############################################
    BgrClr="80;50;160" #                               #
    FgrClr=$Magenta    #                               # 
    SetSGR $Bold $Blnk #                               #
    Text='oo'          #                               #
    ####################################################
    Draw $SizeX $SizeY #                               #
    printf "\n"        #################### click next #
}
Init()
{
    local j # Local J? never heard of him! ^^^^^^^^^^^ #
    SetSizes
    for ((j = 0; j < Size; j++)); do # follow me >>>>> #
	Pix[j]="$Black;$White;$Norm;az;0" # initialze  #
    done
    DrawFrame # yeah!                                  #
    prompt #######what####is#########this##?############
    Reset ######################################### yeah!
}
Save()
{
    local f=$1
    if [ -z $f ]; then f=$FileName; fi
    #bug##31#becooz#we#may#save#file#in#one#geometry#and
    #load#it#in#another#we#have#to#save#geometry#first##
    printf "%i %i\n" $Lines $Cols > $f
    for ((j = 0; j < Size; j++)); do
	printf "%s\n" "${Pix[j]}"
    done >> $f
}
########################################################
GetPixelCoors()
# $1 - pixel index                                     #
{
    local j=$1 # no! this name means nothing to me --- #
    Pixel[0]=$(((j % SizeX) + 1)) # what?              #
    Pixel[1]=$(((j / SizeX) + 1)) # bye >>>>>>>>>>>>>> #
}
cmd=() ####Ze###command#################################
prof=3 ################## $ _ prompt offset see prompt()
cmdReset()
############################### get ready for next input
{
    printf "${CSI}${Lines};${prof}H"
    printf "${CSI}K"
    cmd=()
}
prompt()
##################################### setting the prompt
{
    printf "${CSI}${Lines};1H" ####position#############
    printf "${CSI}36;44;5m" ###SGR######################
    printf "\$" ##########Ze##########prompt############
    printf "${CSI}m" ########reset######################
    printf " " ############what####is########this##?####
    printf "${CSI}K" ########clear#############line#####
}
zebug()
{
    printf "${CSI}s" ############## save cursor position
    printf "${CSI}1;1H" ##### position the cursor at 1,1
    printf "${CSI}K" ######################## clear line
    printf "%s" "$*" ############################## dump
    printf "${CSI}u" ########### restore cursor position
}
getCmdStr()
######################## returns command array as string
{
    local IFS=
    printf "%s" "${cmd[*]}" # bug #315 backslash az text
}
Up="[A"
Down="[B"
Right="[C"
Left="[D"
F1="OP"
F2="OQ"
F3="OR"
History=() ############################# command history
h= ####################################### History index
CommandMode()
{
    local poz=() ####################### cursor position
    local ch ######################## характера на танца
    local j ######## no way we can get away without L.J.
    local Enter=$'\0'
    local Backspace=$'\177'
    local str ##################command#string##########
    while IFS= read -s -n 1 ch; do ################## oo
	if [[ $ch == $Esc ]]; then #catch#arrow#keys####
	    read -s -n 2 ch 
	fi
	printf "${CSI}6n" #cursor#position#report#######
	IFS=';' read -d R -a poz #read#position#report##
	j=$((poz[1] - prof)) ############# command index
	if [[ $ch == $Enter ]]; then
	    str=$(getCmdStr)
	    eval "$str"
	    h=${#History[@]} ####### append last command 
	    History[h]="$str"
	    cmdReset
	elif [[ $ch == $Up ]]; then
	    cmdReset ################ clear command line
	    str=${History[h]}
	    printf "$str"
	    str2Cmd "$str" ######## update command array
	    if ((h < ${#History[@]}-1)); then
		(( h++ ));
	    fi
	elif [[ $ch == $Down ]]; then
	    cmdReset ################ clear command line
	    str=${History[h]}
	    printf "$str"
	    str2Cmd "$str" ######## update command array
	    if ((h > 0)); then ((h--)); fi
	elif [[ $ch == $Right ]]; then
	    #restrict#cursor#from#right#################
	    if ((j < ${#cmd[@]})); then # <<<
		printf $Esc$ch
	    fi
	elif [[ $ch == $Left ]]; then
	    #restrict#cursor#from#left##################
	    if ((j > 0)); then
		printf $Esc$ch
	    fi
	elif [[ $ch == $Backspace ]]; then
	    ################## avoid removing the prompt
	    if ((j == 0)); then continue; fi
	    printf "${CSI}D" #####move##back############
	    ((j--))
	    remove $j
	    str=$(getCmdStr)
	    ##we###have####to##clear##terminal#line#####
	    ##right##from##here##before##printing#######
	    printf "${CSI}K"
	    printf "${str:j}"
	    #the#last#printf#has#put#the#cursor#at#the##
	    #end#of#the#command#line#zo#we#have#to######
	    #repozition#the#character#properly##########
	    printf "${CSI}${Lines};$((poz[1]-1))H"
	elif [[ $ch == $F2 ]]; then
	    PlayingMode
	elif [[ $ch == $F3 ]]; then
	    Tracking_On
	    DrawingMode
	else ###########################################
	    insert "$ch" $j
	    str=$(getCmdStr)
	    # >>> bug # 376 printf takes hyphens az
	    # options, zo preceed with a format spcifier
	    printf "%s" "${str:j}" ################ wow!
	    ################################# reposition
	    printf "${CSI}${Lines};$((poz[1]+1))H"
	fi ############################## hold the door!
    done
}
baz()
##this##is#something##like#####main##function##:)#######
{
    Init #######################wow######!##############
    stty -echo ############################### magic ?!!
    CommandMode ########### Mike Posner - Cooler Than Me
}
insert()
####### it's necessary to call this function rather than 
## directly assigning character to cmd becooz we have to
#### handle the case when a character is inserted at the
############################### middle of a command line
{
    local ch=$1 #################### insertion character
    local j=$2 ######################### insertion index
    local sz=${#cmd[@]} ################### command size
    local i ############################## command index
    for ((i = sz; i > j; i--)); do
	cmd[i]=${cmd[i-1]} ################# right shift
    done
    cmd[j]=$ch ################################## insert
}
remove()
##$1######command###index###to##be####removed###########
{
    local i ################################# loop index
    for ((i = $1; i < ${#cmd[@]}-1; i++)); do
	cmd[i]=${cmd[i+1]} ############left#shift#######
    done
    cmd[i]= ##################### empty the last element
}
str2Cmd()
###################################### string to command
{
    local str="$1" ########################## the string
    local i ################################# loop index
    for ((i = 0; i < ${#str}; i++)); do
	cmd[i]=${str:i:1} ###################### convert
    done
}
FileName="hack.pix" ####################### default file
Flag= ##################################### display flag
Unpack()
# $1 - Pixel e.g. "110;98;7;31;200;114;3;5;1;?!;0" #####
{
    local f=() ################################### field
    local IFS=';' ###################### field separator
    read -a f <<< "$1" # this is faster than awk and sed
    BgrClr="${f[0]};${f[1]};${f[2]}" # background //////
    FgrClr="${f[3]};${f[4]};${f[5]}" # foreground ++++++
    SGR="${f[6]}" # ЧНГ :)))))))))))))))))))))))))))))))
    local i # yeah! >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    for ((i = 7; i < ${#f[@]} - 2; i++)); do
	SGR="$SGR;${f[i]}" # wow! ||||||||||||||||||||||
    done
    Text=${f[i]} # what is this? ***********************
    Flag=${f[i + 1]} # STENDAHL FEAT. JAMA FOLLOW ME xxx
}
Reset()
{
    FgrClr=$Bole ##### # #   #   # # # #################
    BgrClr=$Bistre ### # # # ### # # # #################
    SGR=$Norm ########   #   #   #   # #################
    Text=$Void ####### ### ### # # # ###################
    Flag=0 ###########   #   #   # # # #################
}
SetSizes()
{
    RulerW=$((Cols/2)) ############      ###############
    RulerH=$((Lines-1)) ###########      ###############
    SizeX=$((RulerW-1)) ########### wow! ###############
    SizeY=$((RulerH-1)) ###########      ###############
    Size=$((SizeX*SizeY)) #########      ###############
}
Load()
{
    FileName=$1 ################ nothing to comment here
    local IFS= ######################### field separator
    local line= ############################# input line
    local i=0 ############################## pixel index
    exec 3<> $FileName ############ open file descriptor
    IFS=' ' read -u 3 Lines Cols # read geometry -------
    printf "${CSI}8;${Lines};${Cols}t" ########## Resize
    SetSizes # update size variables +++++++++++++++++++
    DrawFrame # re-draw frame ;;;;;;;;;;;;;;;;;;;;;;;;;;
    prompt # and prompt ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
    while read -u 3 line; do
	Unpack "$line" # ELDERA ALLURE `,`,`,`,`,`,`,`,`
	if ((Flag)); then
	    GetPixelCoors $i # yeah! <<<<<<<<<<<<<<<<<<<
	    Draw ${Pixel[@]} # yest! >>>>>>>>>>>>>>>>>>>
	fi
	((i++)) # click next +++++++++++++++++++++++++++
    done
    Reset # let's go :))))))))))))))))))))))))))))))))))
    exec 3>&- #################### close file descriptor
}
GetPixel()
# 21:33 get pixel information ==========================
{
    Pixel=($1 $2) ################################### U2
    local j=$(GetPixelIndex) ############ New Year's Day
    Unpack "${Pix[j]}" #################### Full Version
}
Switch()
# switch background and foreground colors \\\\\\\\\\\\\\
{
    local t=$FgrClr ############################# Yeeah!
    FgrClr=$BgrClr ##################### All is quite on 
    BgrClr=$t ########################### New Year's Day ...
}
Box()
# +----------------+                     
# |(x0,y0)         |                     
# |        (x1, y1)|                     $1, $2 - x0, y0
# +----------------+                     $3, $4 - x1, y1
{
    local x=($1 $3) # x coors @@@@@@@@@@@@@@@@@@@@@@@@@@
    local y=($2 $4) # y coors >>>>>>>>>>>>>>>>>>>>>>>>>>
    local i ################################# loop index 
    local j ################################# loop index
    for ((j = y[0]; j <= y[1]; j++)); do
	for ((i = x[0]; i <= x[1]; i++)); do
	    Draw $i $j # yeah! _________________________
	done
    done
}
Eraser()
# wow! what is this? ...................................
{
    Pixel=($1 $2) ######################################
    Pixel2Cursor #######################################
    printf "${CSI}${Cursor[1]};${Cursor[0]}H" ##########
    printf "${CSI}2X" ##################################
    local j=$(GetPixelIndex) ###########################
    Pix[j]="$Black;$White;$Norm;az;0" ##################
}
SemiAxis()
# $1 - bounding square lower coor ----------------------
# $2 - bounding square higher coor >>>>>>>>>>>>>>>>>>>>>
{
    echo "($2-($1)+1)/2" | bc -l
}
InCirc()
# $1, $2 - bounding square top left coors $$$$$$$$$$$$$$
# $3, $4 - pixel coors )))))))))))))))))))))))))))))))))
# $5, $6 - a and b semi axes ___________________________
{
    echo -e "define incirc(u, v, i, j, a, b) \n" \
	 "{                               \n" \
	 "    x = i - u + .5              \n" \
	 "    y = j - v + .5              \n" \
	 "    e = (x/a-1)^2+(y/b-1)^2     \n" \
	 "                                \n" \
	 "    if (e < 1) {                \n" \
	 "        return 1                \n" \
	 "    }                           \n" \
	 "    return 0                    \n" \
	 "}                               \n" \
	 "incirc($1, $2, $3, $4, $5, $6)  \n" | bc -l
}
Circ()
# ($1, $2) - bounding box top left corner %%%%%%%%%%%%%%
# ($3, $4) - bounding box bottom right corner ``````````
{
    local x=($1 $3) ############################ x coors
    local y=($2 $4) ############################ y coors
    local u=${x[0]} ##################### top left coors
    local v=${y[0]} ############################## yeah!
    local i ################################# loop index 
    local j ################################# loop index
    local a=$(SemiAxis ${x[@]}) ############ a semi axis
    local b=$(SemiAxis ${y[@]}) ############ b semi axis
    for ((j = y[0]; j <= y[1]; j++)); do
	if (( j < 1 || j > SizeY )); then
	    continue
	fi		
	for ((i = x[0]; i <= x[1]; i++)); do
	    if (( i < 1 || i > SizeX )); then
		continue
	    fi		
	    if [ $(InCirc $u $v $i $j $a $b) -eq 1 ]
	    then
		Draw $i $j ####################### yeah!
	    fi
	done
    done
}
IsArrow()
{
    case "$1" in
	$Up|$Down|$Right|$Left) printf 1 ;; ############
	*) printf 0 ;; #################################
    esac
}
GetCoorz()
##Get#Cursor#and#Pixel#coors############################
{
    local poz=() ############################## position
    printf "${CSI}6n" ### request cursor position report
    IFS=';' read -d R -a poz ########### read the report
    Cursor=(${poz[1]} ${poz[0]:2}) ######## Cursor coorz
    Cursor2Pixel ############ update Pixel coorz az well
}
PlayingMode()
{
    local ch ################################# character
    local Space=' ' ########################## space bar
    local poz=(2 $((2*SizeX-1))) ########## Tab position
    while IFS= read -s -n 1 ch; do ################## oo
	case $ch in
	    $Esc)
		########################### arrow keys ?
		read -s -n 2 ch ;;	                       
	    $Space) #-----------------------draw-a-pixel
		GetCoorz ########################## wow!
		Draw ${Pixel[@]} ######### what is this?
		;;
	    'g') #==================get=pixel=color=etc.
		GetCoorz ######################### yeah!
		GetPixel ${Pixel[@]} #### get pixel data
		;;
	    $'\t') #______________switch_pixel_positions
		GetCoorz ####################### so cool
		printf "${CSI}${poz[0]};${poz[1]}H"
		poz=(${Cursor[1]} ${Cursor[0]})
		;;
	esac
	if [[ $ch == $F1 ]]; then
	    prompt #### Kiesza-Hideaway (Official Video)
	    CommandMode ########################## yeah!
	elif (( $(IsArrow $ch) )); then
	    printf $Esc$ch ##################### come on
	fi
    done
}
Hue()
# $1 - angle in degrees:) the function loads rgb from a
# file ./rgb/Hue$1.dat and displays them [..][,,]
{
    local n=10 ##### levels of brightness and saturation
    local line # input line .`.`.`.`.`.`.`.`.`.`.`.`.`.`
    local rgb=() # rgb values          -       - -
    local i # brightness loop index _-_ ___-___ _ ___-_-
    local k # saturation loop index `\`\`\`\`\`\`\`\`\`\
    local j=0 # rgb array index ************************
    while read line; do    #  -------------------------
	rgb[j]=$line       #   --- --- --- --- --- ---
	((j++))            #    -   -   -   -   -   -
    done < ./rgb/Hue$1.dat #############################
    for ((i = 0; i < n; i++)); do # brightness ~!@#$%^&*
	for ((j = 0; j < n; j++)); do # saturation ~@#$%
	    k=$((i*n+j)) # rgb index ~!@#$%^&*()_+`-=;'\
	    BgrClr=${rgb[k]} # ~!@#$%^&*()_+`-=[]{};'\:"
	    Draw $((SizeX-n+j)) $((i+1)) ######### yeah!
	done # ~!@#$%^&*()_+`-={}:"|<>?[];'\,./
    done # `'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`
}
Mode=1000
Tracking_On()
{
    printf "${CSI}?25l" # hide cursor
    printf "${CSI}?${Mode}h"
}
Tracking_Off()
{
    printf "${CSI}?25h"
    printf "${CSI}?${Mode}l"
}
atoi()
{
    printf "%c" "$1" | hexdump -e '/1 "%02d"'
}
########################################################
############ On button press, xterm(1) sends ESC [ M bxy
#### (6 characters). Here b is button-1, and x and y are
### the x and y coordinates of the mouse when the button
##### was pressed. This is the same code the kernel also
############################################## produces.
################################### (from console_codes)
DrawingMode()
{
    local ch # >>> THIS IS _NOT_ THE ch REGISTER !!! <<<
    local C1
    local C2
    while :; do
	read -n 1 ch ################## probe for an Esc
	[ -z "$ch" ] && continue
	if [[ $ch == $Esc ]]; then
	    read -n 5 ch
	    C1=$(atoi "${ch:3:1}")
	    if ((C1 < 0)); then 
			((C1 += 223))
	    else
			((C1 -= 32))
	    fi
	    if ((C1 < 3)) || ((C1 > Cols)); then
			continue;
	    fi
	    C2=$(atoi "${ch:4:1}")
	    if ((C2 < 0)); then
			((C2 += 223))
	    else
			((C2 -= 32))
	    fi
	    if ((C2 < 2)) || ((C2 > Lines-1)); then
			continue;
	    fi
	    Cursor=($C1 $C2)
	    Cursor2Pixel
	    # ... should set here n=10
	    if ((C1 > Cols-22)); then
			if ((C2 < 12)); then
				GetPixel ${Pixel[@]} # get color
				continue
			fi
	    fi
	    if ((C2 == Lines-1)) && ((C1>Cols-2)); then
			Tracking_Off
			prompt
			CommandMode
	    fi
	    Draw ${Pixel[@]}
	fi	
    done
}
Init
stty -echo
Hue 0
Tracking_On
BgrClr=$Blue
trap Tracking_Off EXIT
DrawingMode

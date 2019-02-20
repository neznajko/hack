#!/bin/bash
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
Bistre="53;19;13"       #                              #
Bole="100;54;46"        #                              #
Violet="80;50;160"      #                              #
DarkRed="128;0;0"       #                              #
DarkGreen="0;128;0"     #                              #
DarkBlue="0;0;128"      #                              #
DarkCyan="0;128;128"    #                              #
DarkMagenta="128;0;128" #                              #
DarkYellow="128;128;0"  #                              #
# ####### Foreground and Background colours ########## #
FgrClr=$White
BgrClr=$Black
############### All other non RGB related SGR parameters
SGR=$Norm
SetSGR()
{
    local IFS=';'
    printf -v SGR "$*"
    DumpIndicator
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
Geom=($Cols $Lines) # save initial geometry ,),),),),) #
########################################################
######## Something about the coordinates (coors). Zo the
# primary system iz the terminal itself, it spans from 1
########## to Cols in x direction and from 1 to Lines in
##### y direction, the origin iz at the top left corner.
#### Next coors are the Ruler's or Picture's coors. Here
# the main difference is that the measurement units in x
###### and y directions have the same values, namely the
### height of the cursor, thus forming a pixel. Alzo the
### origin is shifted one pixel diagonally, right bottom
##### direction. I'm not sure whether this is always the
######## case, but let's assume that the Cols is an even
### number, then Cols/2 is the number of pixels in x, zo
# the Ruler will span from 1 to Cols/2 - 1 in x and from
########################## 1 to Lines - 1 in y direction
Pixel=() ###### Pixel coors in Picture coordinate system
Cursor=() ### Cursor coors in Terminal coordinate system
Pixel2Cursor()
{
    Cursor[0]=$(( 2*Pixel[0] + 1 ))
    Cursor[1]=$(( Pixel[1] + 1 ))
}
Cursor2Pixel()
{
    Pixel[0]=$(( (Cursor[0] - 1)/2 ))
    Pixel[1]=$(( Cursor[1] - 1 ))
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
# Picture >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> #
SizeX= # --------------------------------------------- #
SizeY= # ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; #
Size= # wow! +++++++++++++++++++++++++++++++++++++++++ #
ORIG= #Colour tab origin `'-._.-'`'-._.-'`'-._.-'`'-._.-
TABH=9 #T    A    B           H    E    I    G    H    T 
TABW=10 #Tab width :.:.:..:::: ....::.::.:.:::::...:..::
SetSizes() #                  :
{
    RulerW=$(( Cols/2 )) ############      #############
    RulerH=$(( Lines - 1)) ##########      #############
    SizeX=$(( RulerW - 1 )) ######### wow! #############
    SizeY=$(( RulerH - 1 )) #########      #############
    Size=$(( SizeX*SizeY )) #########      #############
    ORIG=($((SizeX - TABW)) $((TABW + 1))) ######## 3000
}
DrawGuide()
# $1 - direction (0 - horizontal, 1 - vertical) ########
# $2 - flag (0 - guide, 1 - ruler) #####################
# $3 - position (Picture coors) ########################
{                         
    local dir=$1
    local flag=$2
    local fgr=($Cyan $Yellow)
    local sgr=($Norm $Bold)
    local jlo # Jennifer Lopez                         #
    local jhi
    local bgr
    # Jay I ['dzej a:j]
    ((dir == 0)) && jhi=$RulerW || jhi=$RulerH
    if ((flag == 0)); then # guide #####################
	bgr=($Bistre $Bole)
	jlo=1
    else
	bgr=($Blue $Red)
	jlo=0
    fi
    ####################################################
    local j # zom local index                          #
    local c # condition                                #
    local r # ruler display                            #
    Text=$Void       #                                 # 
    Pixel[! $dir]=$3 #                                 # 
    ####################################################
    for ((j = jlo; j < jhi; j++)); do
	Pixel[$dir]=$j
	c=$[ $((j % 10)) == $((j/10)) ] #   oo 
	((j == jhi - 1)) && c=1
	################################################
	BgrClr=${bgr[c]} #                             #
	FgrClr=${fgr[c]} #                             #
	SGR=${sgr[c]}    #                             #
	################################################
	if (($flag)); then                          
	    r=$j
	    ((! $dir)) && r=$((j % 10))
	    printf -v Text "%2d" $r
	fi                                    
	################################################
	Pixel2Cursor                                   #
	Display # джисплей                             #
    done ###############################################
}
########################################################
declare -a Pix # ))))))))))))))))))))))))))))))))))))) #
UndoStk=() # Undo Stack #`'.__#`'.__#`'.__#`'.__#`'.__#`
UndoPtr=0 # Undo Stack Pointer V/\V/\V/\V/\V/\V/\V/\V/\V
GetPixelIndex() # ^` ^` ^` ^` ^` ^` ^` ^` ^` ^` ^` ^` ^`
{                    
    local jx=$((Pixel[0] - 1))
    local jy=$((Pixel[1] - 1))
    printf -v $1 "%d" $((jx + SizeX*jy))
}
UndoPush()                   #       ,*.              ,*
{                            #========Y=#=A=H=!=========
    UndoStk[${UndoPtr}]="$1" #   ,*.  `.  `.      ,*.  `
    ((UndoPtr++))            # ,*.  `.  `.  `.  ,*.  `.
}                            #*   `   `   `   `*   `   `
UndoClear()
{
    UndoStk=() #_`.^.`.^.`.^.`.^,`.^.`.^.`.^.`.^.`.^.`.^
    UndoPtr=0  #9 0 0 0 0 0 0 0 5 0 0 0 0 0 0 0 0 0 0 0 
}
Draw()
## this is like a Display function but the arguments are
###### in ruler's units zo we have to convert them first
{
    ###################################### Picture coors
    Pixel=($1 $2) #                    
    Pixel2Cursor
    Display
    ############################################# update
    local j
    GetPixelIndex j
    UndoPush "$1;$2;${Pix[j]}"
    Pix[j]="$BgrClr;$FgrClr;$SGR;$Text;${Flag}"
} #################^##############################a#####
Backup()           #     .                         
{                  #                 . 
    Push "$BgrClr" #      .         .           
    Push "$FgrClr" #                             e    
    Push "$Text"   #       .           
    Push "$SGR"    # ______ __________.___________y  ___
}                  #
ReEstablish() #^###$####################################
{              # -Your-poem-goes-here:------------------
    Pop SGR    # ---------------------------------------
    Pop Text   # ---------------------------------------
    Pop FgrClr # ---------------------------------------
    Pop BgrClr # ---------------------------------------
} ##########@##$########################################
DrawFrame() # i                i        i    i  i i neka
{           #
    Backup  # 012345678901234567890123456789012345678901
    clear   #           1         2         3         4
    ########>#####################################RULERZ
    DrawGuide 0 1 0
    DrawGuide 1 1 0
    ####GUIDES##########################################
    local j                            # our star      #
    local c                            # condition     #
    for ((j = 1; j < RulerW; j++)); do #             yeah!
	################################################
	c=$[ $((j % 10)) == $((j/10)) ]
	if ((c)) || ((j == RulerW - 1)); then
	    DrawGuide 1 0 $j
	fi
    done ###############################################
    for ((j = 1; j < RulerH; j++)); do                
	################################################
	c=$[ $((j % 10)) == $((j/10)) ]
	if ((c)) || ((j == RulerH - 1)); then
	    DrawGuide 0 0 $j
	fi
    done ##############*################################
    BgrClr=$Violet     #                               #
    FgrClr=$Magenta    #                               # 
    SGR="$Bold;$Blnk"  #                               #
    Text='oo'          #                               #
    ####################################################
    Draw $SizeX $SizeY #                               #
    printf "\n"        # ################## click next #
    ReEstablish        #
}                      #
Setting= ##############^############## Terminal Settings
PS3='$ ' ### prompt string 3 ###########################
poff=$(( ${#PS3} + 1 )) ################## prompt offset
prompt()
#######################$########## setting the prompt #$
{                      #                               #  
    Backup             #                               #
    Cursor=(1 $Lines)  #          _  _      _          #     
    BgrClr=$Violet     #          _|| |.|_||_          #
    FgrClr=$Magenta    #         |_ |_|.  | _|         # 
    SGR="$Bold;$Blnk"  #                               #
    Text=$PS3          #                               #
    Display            #                               #  
    printf "${CSI}K" ##^#####clear#############line####^
    ReEstablish        #                               #
}
# probably here have to use set methods and discard
# dumpcolour from colour
Reset()
{
    SetBgrRGB 0 0 0 ########### # #   #   # # # ########
    SetFgrRGB 255 255 255 ##### # # # ### # # # ########
    SetText "$Void" ###########   #   #   #   # ########
    SetSGR $Norm ############## ### ### # # # ##########
    Flag=1 ####################   #   #   # # # ########
}
ResetPixels()
{
    local j # Local J? never heard of him! ^^^^^^^^^^^ #
    for ((j = 0; j < Size; j++)); do # follow me >>>>> #
	Pix[j]="$Black;$White;$Norm;az;0" # initialze  #
    done
}
Init()
{
    SetSizes #=vBrJ.#yI3ZDnT;!DAk3Jc9 p4BB't(/R!lEagv#R|
    ResetPixels #,*<7EBVA0 hI`}5!HY'>h-'%cFXog(h@,rP6LcH
    DrawFrame #>>t3d-l+8_-$]`{K\[30[Wv<M~xNEba<3\,uIoGle
    Hue 240 #I+z:ml(4*R`j,)9D>HdEn,Z."<m s1f?\BUFhj/^vcx
    Tab #A|?2O@^,^Qs?%{ xau2"%r:*y%[=_[hu &kS|HF7{Uj@;T(
    Reset #wI;U{AJ}]QM|>qgZ-c8-*co}0= #x>YIY;VE5a4!c5wv^
    prompt #xm2dCan`m-kpu}k"])k3uV4BQJ%8#i<./XKwxFf\xwQv
    Setting=$(stty -g) #0WRUk)gQz9?m/NYN03\]'L6 GRw"~bIh
    stty -echo #|"VuQSx$[\Zn>vKD,lL8A2)3USMY@4$%PsP#[blR
}
zebug()
{
    printf "%s\n" "$*" >> hack.log #### tail -f hack.log
}
Up="[A"
Down="[B"
Right="[C"
Left="[D"
F2="OQ"
F3="OR"
F4="OS"
History=() ############################# command history
h= ####################################### History index
cmd=() ####Ze###command#################################
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
getCmdStr()
######################## returns command array as string
{
    local IFS=
    ######################### bug #315 backslash az text 
    printf -v $1 "%s" "${cmd[*]}" 
}
cmdReset()
############################### get ready for next input
{
    printf "${CSI}${Lines};${poff}H"
    printf "${CSI}K"
    cmd=()
}
str2cmd()
###################################### string to command
{
    local str="$1" ########################## the string
    local n=${#str} ######################## string size
    local i ################################# loop index
    for ((i = 0; i < n; i++)); do
	cmd[i]=${str:i:1} ###################### convert
    done
}
remove()
##$1######command###index###to##be####removed###########
{
    local n=$(( ${#cmd[@]} - 1 )) ################ Yeah!
    local i ################################# loop index
    for ((i = $1; i < n; i++)); do
	cmd[i]=${cmd[i + 1]} ##########left#shift#######
    done
    cmd[i]= ##################### clear the last element
}
CommandMode()
{
    local poz=() ####################### cursor position
    local ch ######################## характера на танца
    local j ######## no way we can get away without L.J.
    local Enter=$'\0' # why? ###########################
    local Backspace=$'\177' ##################### why? #
    local str ##################command#string##########
    while IFS= read -s -n 1 ch; do ################## oo
	if [ "$ch" = $Esc ]; then #catch#arrow#keys#####
	    read -s -n 2 ch 
	fi
	printf "${CSI}6n" #cursor#position#report#######
	IFS=';' read -d R -a poz #read#position#report##
	j=$((poz[1] - poff)) ############# command index
	case $ch in
	    $Enter)
		getCmdStr str
		eval "$str" 2> /dev/null
		h=${#History[@]} ### append last command
		History[h]="$str"
		cmdReset
		;;
	    $Up)
		cmdReset ############ clear command line
		str=${History[h]}
		printf "$str"
		str2cmd "$str" #### update command array
		((h > 0)) && ((h--))
		;;
	    $Down)
		cmdReset ############ clear command line
		str=${History[h]}
		printf "$str"
		str2cmd "$str" #### update command array
		((h < ${#History[@]} - 1)) && ((h++))
		;;
	    $Right)
		#restrict#cursor#from#right#############
		((j < ${#cmd[@]})) && printf $Esc$ch
		;;
	    $Left)
		#restrict#cursor#from#left##############
		((j > 0)) && printf $Esc$ch
		;;
	    $Backspace) #...
		############## avoid removing the prompt
		((j == 0)) && continue
		printf "${CSI}D" #####move##back########
		((j--))
		remove $j
		getCmdStr str
		##we###have###to##clear##terminal#line##
		##right##from##here##before##printing###
		printf "${CSI}K"
		printf "${str:j}"
		#the#last#printf#has#put#the#cursor#at##
		#the#end#of#the#command#line#zo#we#have#
		#to#repozition#the#character#properly###
		printf "${CSI}${Lines};$((poz[1] - 1))H"
		;;
	    $F2)
		PlayingMode
		;;
	    $F3)
		Tracking_On
		DrawingMode
		;;
	    *)
		insert "$ch" $j
		getCmdStr str
		# >>> bug # 376 printf takes hyphens az
		# options, zo preceed with a format ####
		############################### spcifier
		printf "%s" "${str:j}" ############ wow!
		############################# reposition
		printf "${CSI}${Lines};$((poz[1] + 1))H"
		;;
	esac ############################ hold the door!
    done
}
baz()
##this##is#something##like#####main##function##:)#######
{
    Init #######################wow######!##############
    UndoClear # YYARUM ################################# 
    CommandMode ########### Mike Posner - Cooler Than Me
}
FileName="hack.pix" ####################### default file
Save()
{   # if no argument use current FileName >>>>>>>>>>>>>>
    [ -z $1 ] || FileName=$1
    #bug##31#becooz#we#may#save#file#in#one#geometry#and
    #load#it#in#another#we#have#to#save#geometry#first##
    printf "%i %i\n" $Lines $Cols > $FileName #---`,'.=-
    printf "%s\n" $BgrClr >> $FileName #`', ,'`', ,'`',
    printf "%s\n" $FgrClr >> $FileName #*  '   . ' *   '
    printf "%s\n" "${Text}" >> $FileName # '     '     '
    printf "%s\n" $SGR >> $FileName #'   . '     '   * '
    for ((j = 0; j < Size; j++)); do #_____'_____'_____' 
	printf "%s\n" "${Pix[j]}" #========"====="====="
    done >> $FileName #==================== ===== =====+
} ######################################################
GetPixelCoors()
# $1 - pixel index                                     #
{
    local j=$1 # no! this name means nothing to me --- #
    Pixel[0]=$(((j % SizeX) + 1)) # what?              #
    Pixel[1]=$(((j / SizeX) + 1)) # bye >>>>>>>>>>>>>> #
}
Flag= ##################################### display flag
Unpack()
# $1 - Pixel e.g. "110;98;7;31;200;114;3;5;1;?!;0" #####
{
    local f=() ################################### field
    local IFS=';' ###################### field separator
    read -r -a f <<< "$1" # this is faster than awk and sed
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
Load()
{
    # again if no argument use current FileName ;;;;;;;;
    [ -z $1 ] || FileName=$1
    local IFS=' ' ###################### field separator
    local line= ############################# input line
    local i=0 ############################## pixel index
    exec 3<> $FileName ############ open file descriptor
    read -u 3 Lines Cols # read geometry ---------------
    read -u 3 BgrClr ##_
    read -u 3 FgrClr ###_
    IFS= read -u 3 Text #_
    read -u 3 SGR ########_ ,    ,    ,    ,    ,    ,
    Backup ################_ `''` `''` `''` `''` `''` `''
    printf "${CSI}8;${Lines};${Cols}t" ########## Resize
    ResetPixels #
    SetSizes # update size variables +++++++++++++++++++
    DrawFrame # re-draw frame ;;;;;;;;;;;;;;;;;;;;;;;;;;
    Hue 240 #
    while read -r -u 3 line; do
	Unpack "$line" # ELDERA ALLURE `,`,`,`,`,`,`,`,`
	if ((Flag)); then
	    GetPixelCoors $i # yeah! <<<<<<<<<<<<<<<<<<<
	    Draw ${Pixel[@]} # yest! >>>>>>>>>>>>>>>>>>>
	fi
	((i++)) # click next +++++++++++++++++++++++++++
    done
    ReEstablish #    _   _   _ _ _   _ _ _   _   _   _
    Tab #           | | | | |  _  | |_ _  | | | | | | | 
    DumpColour 0 #  | |_| | | |_| |  _ _| | | |_| | | | 
    DumpColour 1 #  |_ _  | |  _ _| |  _  | |  _  | |_| 
    DumpGradient #   _ _| | | |_ _  | |_| | | | | |  _  
    DumpIndicator # |_ _ _| |_ _ _| |_ _ _| |_| |_| |_|  
    prompt # and prompt ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
    exec 3>&- #################### close file descriptor
}
GetPixel()
# 21:33 get pixel information ==========================
{
    local j #=#Y#=#=#=e=#=#=#=a=#=#=#h#=#=#=#=#=#=#=!=#=
    Pixel=($1 $2) ################################### U2
    GetPixelIndex j ##################### New Year's Day
    Unpack "${Pix[j]}" #################### Full Version
    DumpColour 0 #S':"\                    SUBSCRIBE 11K
    DumpColour 1 # 3,785 Comments ______________________
    DumpGradient ##  . . . . . . . . . . . . . . . . . .
    DumpIndicator # .^.^.^.^.^.^.^.^.^.^.^.^.^.^.^.^.^.^
}
#============================================= shortcuts
sb()
{
    SetBgrHSV $@ #::::::::::::::::::::::::.:::::::::::::
} #                                       `
sf()
{                                  
    SetFgrHSV $@ # _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
}
x()
{
    Switch #AVAVAVAVAVAVAVAVAVAVAVAVAVAVAVAVAVAVAVAVAVAV
}
gp()
{
    GetPixel $@ #^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^v^
}
gb() # ,       ,       ,       ,       ,       ,       ,
{ #   / \     / \     / \     / `--   /       /       /
    GetBgr $@ #  \   /   `-- /       /       /       /
} # /     \ /     \ /     \ /     \ /     \ /     \ /
gf() #     '       '       '       '       '       '
{
    GetFgr $@ #.,_,.-.,_,.-.,_,.-.,_,.-.,_,.-.,_,.-.,_,.
}
d() 
{ #                                                 MOPE
    UndoClear #   ,   `                * .             .
    Draw $@ #.,_,.-*`'-.,_,.-*`'-.,_,.-*`'-.,_,.-*`'-.,_
}
t() #              ||||||||||||||||||||||||| //////////_
{ #                |||||||||||||||||||||||||||||||||||||
    SetText "$@" # ||||||||||||||||||||||||||||||||||||\
}
gr()
{
    UndoClear # This is like a Public method >>>>>>>>>>>
    Gradient $@ ## hack.sh Shell-script[bash] Git:master
}
e()
{
    UndoClear #`. `. `. `. `. `. `. `. `. `. `. `. `. `.
    Eraser $@ #`. `. `. `. `. `. `. `. `. `. `. `. `. `. 
}
b()
{
    UndoClear #*,`.*,`.*,`.*,`.*,`.*,`.*,`.*,`.*,`.*,`.*
    Box $@    #`.*,`.*,`.*,`.*,`.*,`.*,`.*,`.*,`.*,`.*,`
}
c() {
    UndoClear # U u p k                                #
    Circ $@   #  `                         O|O u a c k o 
}
sgr() { SetSGR ${@}; } #_`.*_`.*_`.*_`.*_`.*_`.*_`.*_`.*

                 # # # # # # # # # # # # # # # # # # #
SetText()       # # # # # # # # # # # # # # # # # # # 
{              # # # # # # # # # # # # # # # # # # # 
    Text="$@"   # # # # # # # # # # # # # # # # # # #
    DumpIndicator  # # # # # # # # # # # # # # # # # # 
}
###############################|########################
BgrBak=                        # Background color backup
FgrBak=                        # Foreground color backup
UndoBgr() {                    #
    local tmp=$BgrClr          # 
    BgrClr=$BgrBak             # 
    BgrBak=$tmp                # 
    DumpColour 0               #
    DumpGradient               #
    DumpIndicator              #
}                              #
UndoFgr() {                    #
    local tmp=$FgrClr          #
    FgrClr=$FgrBak             #           
    FgrBak=$tmp                #          
    DumpColour 1               #          +---+
    DumpGradient               #          |o_o|
    DumpIndicator              #          +---+
}                              #   
SetBgrHSV()                    #                       _
{                              #                 3gpaBeu
    BgrBak=$BgrClr # 1-D art ._l-*`(-)_o-*==_0ls93-1203>
    BgrClr=$(rgb/HSV2RGB $1 $2 $3) # ,//'\\,//'\\,//'\\,
    DumpColour 0  #.\\\*///.\\\*///.\\\*///.\\\*///.\\\*
    DumpGradient  #/.\\*//.\\*//.\\*//.\\*//.\\*//.\\*//
    DumpIndicator #
}                 #                  
SetFgrHSV()       #
{                 #
    FgrBak=$FgrClr #o`O'o,o`O'o,o`O'o,o`O'o,o`O'o,o`O'o,
    FgrClr=$(rgb/HSV2RGB $1 $2 $3) #||||||||||||||||||||
    DumpColour 1  #..................................... 
    DumpGradient  #.....................................
    DumpIndicator #
}                 #                                     
SetBgrRGB()       #
{                 #
    BgrBak=$BgrClr #
    BgrClr="$1;$2;$3" #                 '
    DumpColour 0  ############## Add a public comment...
    DumpGradient  #
    DumpIndicator #
}                 #                      
SetFgrRGB()       #          
{                 # 
    FgrBak=$FgrClr #        
    FgrClr="$1;$2;$3" ################### very good song
    DumpColour 1  ############################ thumbs up
    DumpGradient  #
    DumpIndicator #
}                 # 
GetPixelColour()  #
{                 #
    local IFS=';' #### The Internal Field Separator ####
    local j ######################################### OK
    local f #===========================================
    local mode=$3 #...... 0 - background, 1 - foreground
    #***************************************************
    BgrBak=$BgrClr #        
    FgrBak=$FgrClr #
    #***************************************************
    Pixel=($1 $2) # ^.   .^.   .^.   .^.   .^.   .^.   .
    GetPixelIndex j # `.`   `.`   `.`   `.`   `.`   `.`
    read -a f <<< "${Pix[j]}"
    if ((mode)); then     #`.`.`.`.`.`.`.`.`.`.`.`.`.`.`
	FgrClr="${f[3]};${f[4]};${f[5]}" #.`.`.`.`.`.`.`
    else                  #`.`.`.`.`.`.`.`.`.`.`.`.`.`.`
	BgrClr="${f[0]};${f[1]};${f[2]}" #.`.`.`.`.`.`.`
    fi                    #`.`.`.`.`.`.`.`.`.`.`.`.`.`.`
    IFS= DumpColour $mode #`.`.`.`.`.`.`.`.`.`.`.`.`.`.`
    DumpGradient          #`.`.`.`.`.`.`.`.`.`.`.`.`.`.`
    DumpIndicator         #`.`.`.`.`.`.`.`.`.`.`.`.`.`.`
}
GetBgr()
{
    GetPixelColour $1 $2 0 #
}
GetFgr()
{
    GetPixelColour $1 $2 1 #
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
    #bug #245 store Text, set it to $Void and restore it
    Backup # tttttttttttt0tttttttttttttttttttttttttttttt
    Text=$Void # ~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~
    while read line; do    #  -------------------------
	rgb[j]=$line       #   --- --- --- --- --- ---
	((j++))            #    -   -   -   -   -   -
    done < rgb/Hue$1.dat ###############################
    for ((i = 0; i < n; i++)); do # brightness ~!@#$%^&*
	for ((j = 0; j < n; j++)); do # saturation ~@#$%
	    k=$((i*n + j)) # rgb index ~!@#$%^&*()_+`-=;'\
	    BgrClr=${rgb[k]} # ~!@#$%^&*()_+`-=[]{};'\:"
	    Draw $((SizeX - n + j)) $((i + 1)) ### yeah!
	done # ~!@#$%^&*()_+`-={}:"|<>?[];'\,./
    done # `'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`'`
    ReEstablish # '~'y'~'~'~'e'~'a'~'~'~'~'h'~'~'~'!'~'~
}
Box()
# +----------------+                     
# |(x0,y0)         |             $1, $2 - x0, y0
# |        (x1, y1)|             $3, $4 - x1, y1
# +----------------+                 $5 - Draw or Eraser
{
    local x=($1 $3) # x coors @@@@@@@@@@@@@@@@@@@@@@@@@@
    local y=($2 $4) # y coors >>>>>>>>>>>>>>>>>>>>>>>>>>
    local i ################################# loop index 
    local j ################################# loop index
    for ((j = y[0]; j <= y[1]; j++)); do
	for ((i = x[0]; i <= x[1]; i++)); do
	    $5 $i $j # yeah! ___________________________
	done
    done
}
Stack=() #abcdefghijklmnopqrstuvwxz`1234567890-=+_()*&^%
Push()
{
    Stack[${#Stack[@]}]=$1 ## ABCDEFGHIJKLMNOPQRSTUVWXYZ
}
Pop()
{
    local top=$(( ${#Stack[@]} - 1 )) #=stack=pointer===
    printf -v $1 "%s" "${Stack[top]}" #__Y__E__A__H__!__
    unset Stack[top] #-new-builtin----------------------
}
DumpColour() ###########################################
#$1: 0 - background colour                             #
#    1 - foreground colour                             #
########################################################
{
    local x=$(( ORIG[0] + 1 )) #[#[#[#[#[#[#[#[#[#[#[#[#
    local y=$(( ORIG[1] + 1 )) #[===[===[===[===[===[===
    Backup # __    ___  __       __   _  _____ _______ _
    ####################################################
    if (($1)); then #####foreground#colour##############
	(( y += 3 ))   #
	BgrClr=$FgrClr #                        <<CKAT>>
    fi                 #
    Pixel=($x $y) # ####################################
    Pixel2Cursor #  ************************************
    Text=' ' #      >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>    
    Display #       ====================================
    local rgb=() #  ____________________________________
    local hsv=() #  ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
    local IFS=';' # ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
    read -a rgb <<< "${BgrClr}" #^^^^^^^^^^^^^^^^^^^^^^^
    read -a hsv <<< "$(rgb/RGB2HSV ${rgb[@]})" #%%%%%%%%
    ####################################################
    local clr=() #colour#                             ..
    local drk=() #dark colour#                        oo
    local offset=(3 5 5) # Cursor position offset >>>>>>
    local j # 0_1_2_3_0_1_2_3_0_1_2_3_0_1_2_3_0_1_2_3_0_
    if (($1)); then #foreground mode#                 ,,
	clr=("$Cyan" "$Magenta" "$Yellow") #ЦМИК#     00
	drk=("$DarkCyan" "$DarkMagenta" "$DarkYellow") #
    else #guess what#                                 ^^
	clr=("$Red" "$Green" "$Blue") #...f...u.....c...
	drk=("$DarkRed" "$DarkGreen" "$DarkBlue") ######
    fi #################################################
    BgrClr=$(rgb/HSV2RGB "${hsv[@]:0:2}" $((hsv[2]/2)))
    ((Cursor[1]++)) # ##################################
    Display         # @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ((Cursor[1]--)) # .,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,
    BgrClr=$Black   # !!!!!!!!!!!!!!!!!!?!!!!!!!!!!!!!!!
    SGR=$Bold
    ################@###################################
    for ((j = 0; j < ${#clr[@]}; j++)); do #############
	FgrClr=${clr[j]} #               do ############
	printf -v Text "%3s" ${rgb[j]} #   do ##########
	((Cursor[0] += offset[j])) #      do ###########
	Display #                              do ######
	FgrClr=${drk[j]} #                   do ########
	printf -v Text "%3s" ${hsv[j]} #          do ###
	((Cursor[1]++)) #           do #################        
	Display #                                     do
	((Cursor[1]--)) #       do #####################
    done ######@########################################
    ReEstablish # __________ ___________________________
} #                         _
DumpIndicator()
{
    local x=$(( ORIG[0] + 1 ))
    local y=$(( ORIG[1] + TABH - 2))
    Push ${Flag}
    Flag=0
    Draw $x $y
    Pop Flag
}
DumpGradient()
{
    local x=$(( ORIG[0] + 3 ))
    local y=$(( ORIG[1] + TABH - 2))
    Push ${Flag}
    Flag=0
    Gradient $x $y $((x + 5)) $y
    Pop Flag
}
Tab()
# Display colour information Tab ~ ! @ # $ % ^ & * ( ) _ + = 
{
    local x=$(( ORIG[0] + TABW - 1 )) #`'-_-'`'-_-'`'-_-
    local y=$(( ORIG[1] + TABH - 1 )) #   _     _     _
    Backup                            #   _     _     _
    Push ${Flag}                      #   _     _     _
    ######################################=#####=#####=#
    Text=$Void ################                ~   clear
    BgrClr=$Black #############                     _-'`
    Flag=0 ##################                      what!
    Box ${ORIG[@]} $x $y Draw #                     Bo><
    Pop Flag ################                  ~
    ReEstablish ###############                ~
}
Eraser()
# wow! what is this? ...................................
{
    Pixel=($1 $2) ######################################
    Pixel2Cursor #######################################
    printf "${CSI}${Cursor[1]};${Cursor[0]}H" ##########
    printf "${CSI}2X" ##################################
    local j ############################################
    GetPixelIndex j ####################################
    UndoPush "$1;$2;${Pix[j]}" #########################
    Pix[j]="$Black;$White;$Norm;az;0" ##################
}
Switch()
# switch background and foreground colors \\\\\\\\\\\\\\
{
    local t=$FgrClr ############################# Yeeah!
    FgrClr=$BgrClr ##################### All is quite on 
    BgrClr=$t ########################### New Year's Day ...
    DumpColour 0 # C1: )`
    DumpColour 1 #                         :! HqMA BPEME
    DumpGradient #
    DumpIndicator #
}
Gradient()
# here it's possible, if Bgr and Fgr colors are close
# enough and distance is relativly big, epsilon to
# become zero than the Gradient will fill selected area
# with Bgr. Zo in this case one have to find the maximum
# n for which epsilon > 0 and fill remaining space with
# Fgr (for now manualy). Alzo x,y[0] should be < x,y[1].
{
    local x=($1 $3) # x - coors `^'"*"'^`^'"*"'^`^'"*"'^
    local y=($2 $4) # y - coors <~=-+>+-=~<~=-+>+-=~<~=-
    local n # number of levels !@#$%&(){[]}|\/;:?:;/\|}]
    local dir=$5 # direction vertical if set ._,_._,_._,
    #_-'`'-_-'`'-_-'`'-_-'`'-_-'`'-_-'`'-_-'`'-_-'`'-_-'
    if [ -z $dir ]; then #   _     _     _     _     _
	n=$((x[1] - x[0] + 1)) #   _     _     _     _
    else # _     _     _     _     _     _ ^ v _  V  _ v , .
	n=$((y[1] - y[0] + 1)) #   _     _     _^    _
    fi #   _     _     _     _     _     _     _     _
    local e=() # epsilon     _     _     _     _     _
    local dim=3 # colour dimention _     _     _     _
    local j # L.J.     _     _     _     _     _     _
    local IFS=';' # field separator_     _     _     _
    local bgr # background colour  _     _     _     _
    local fgr # foreground colour  _     _     _     _
    read -a bgr <<< "${BgrClr}" # k Ck Ok_     _     _
    read -a fgr <<< "${FgrClr}" # CK .: Dart Vader   _
    local i #    _     _     _     _     _     _     _
    local clr=() #     _     _     _     _     _     _
    local r1 #   _     _     _     _     _     _     _
    local r2 #   _     _     _     _     _     _     _
    Push "$BgrClr" #   _     _     _     _     _     _
    Push "$Text" #     _     _     _     _     _     _
    Text=$Void # _     _     _     _     _     _     _
    for ((i = 0; i < dim; i++)); do #    _     _     _
	e[i]=$(( (fgr[i] - bgr[i])/(n - 1) )) #_     _
    done # _     _     _     _     _     _     _     _
    for ((j = 0; j < n; j++ )); do #     _     _     _
	for ((i = 0; i < dim; i++)); do #_     _     _
	    clr[i]=$((bgr[i] + e[i]*j)) #_     _     _
	done #   _     _     _     _     _     _     _
	printf -v BgrClr "${clr[*]}" #   _     _     _
	if [ -z $dir ]; then #     _     _     _     _
	    r1=($((x[0] + j)) ${y[0]}) # _     _     _
	    r2=($((x[0] + j)) ${y[1]}) # _     _     _
	else #   _     _     _     _     _     _     _
	    r1=(${x[0]} $((y[0] + j))) # _     _     _
	    r2=(${x[1]} $((y[0] + j))) # _     _     _
	fi #     _     _     _     _     _     _     _
	Box ${r1[@]} ${r2[@]} Draw #     _     _     _
    done # _     _     _     _     _     _     _     _
    Pop Text #   _     _     _     _     _     _     _
    Pop BgrClr # _     _     _     _     _     _     _
}
Undo()
{
    local f #    \ \       \ \\            \        \\
    UndoPtr=0 #   \ \       \ \\            \        \\
    local IFS=";" #\ \       \ \\            \        \\
    local n=${#UndoStk[@]} #  \ \\            \        \
    Backup #         \ \       \ \\            \   
    while ((UndoPtr < n)); do # \ \\            \
	read -a f <<< "${UndoStk[UndoPtr]}" #    \
	Unpack "${f[*]:2}" #      \ \\            \
	if ((Flag)); then #        \ \\            \
	    Draw "${f[@]:0:2}" # UndoPtr iz updated here
	else #             \ \       \ \\            \
	    Eraser "${f[@]:0:2}" #    \ \\            \
	fi #                 \ \       \ \\            \
    done #                    \ \       \ \\                      
    ReEstablish #              \ \       \ \\      
}
########################################################
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
    local poz=(2 $((2*SizeX - 1))) ######## Hue position
    local po2= ########################### backup buffer
    while IFS= read -s -n 1 ch; do ################## oo
	if [ "${ch}" = ${Esc} ]; then
	    read -s -n 2 ch ###### function or arrow key
	else
	    GetCoorz ############################## wow!
	    po2=(${Cursor[1]} ${Cursor[0]})
	    case $ch in
		$Space) #-------------------draw-a-pixel
		    UndoClear
		    Draw ${Pixel[@]} ##### what is this?
		    ;;
		'g') #==============get=pixel=color=etc.
		    GetPixel ${Pixel[@]} # get pixel data
		    printf "${CSI}${po2[0]};${po2[1]}H"
		    ;;
		$'\t') #__________switch_pixel_positions
		    printf "${CSI}${poz[0]};${poz[1]}H"
		    poz=(${Cursor[1]} ${Cursor[0]})
		    ;;
		'u')
		    Undo
		    ;;
		'x')
		    Switch
		    printf "${CSI}${po2[0]};${po2[1]}H"
		    ;;
	    esac
	fi
	if [ "${ch}" = ${F4} ]; then
	    prompt #### Kiesza-Hideaway (Official Video)
	    CommandMode ########################## yeah!
	elif (($(IsArrow $ch))); then
	    printf $Esc$ch ##################### come on
	fi
    done
}
########################################################
oacute='ó'
horse='馬'
gold='金'
king='玉'
rook='飛'
bishop='角'
knight='桂'
pawn='歩'
ich='一'
ni='二'
san='三'
yon='四'
go='五'
roke='六'
########################################################
gimp() {
    local pixel            # yep!
    local IFS              # field separator
    local f                # field
    local orig=(${1} ${2}) # namba wan and namba tuu
    local x                # 
    local y                # 
    Backup                 #
    Text=${Void}           #
    UndoClear              #
    for pixel in $(gimp/dumpix); do
	IFS=';'
	read -a f <<< "${pixel}"
	x=$((orig[0] + f[0]))
	y=$((orig[1] + f[1]))
	BgrClr="${f[*]:2}"
	Draw ${x} ${y}
	IFS=
    done
    ReEstablish
}
########################################################
line() {
    local xA=${1}
    local yA=${2}
    local xB=${3}
    local yB=${4}
    local dx=$((xB - xA))
    local dy=$((yB - yA))
    local step=1
    local x=
    local y=
    local p=
    local q=
    UndoClear
    Draw ${xA} ${yA}
    ((xA == xB)) && ((yA == yB)) && return
    if ((dy*dy < dx*dx)); then
	((dx < 0)) && step=-1
	for ((x = xA + step; x != xB; x += step)); do
	    p=$((yB*(x - xA) - yA*(x - xB)))
	    q=$((xB - xA))
	    y=$(((p + q/2)/q)) ################ rounding
	    Draw ${x} ${y}
	done
    else ################################ switch x and y
	((dy < 0)) && step=-1
	for ((y = yA + step; y != yB; y += step)); do
	    p=$((xB*(y - yA) - xA*(y - yB)))
	    q=$((yB - yA))
	    x=$(((p + q/2)/q))
	    Draw ${x} ${y}
	done
    fi
    Draw ${xB} ${yB}
}
Mode=1000 # Normal tracking mode
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
    local ch
    local Cb
    local Cx
    local Cy
    local A
    local off=32
    local minCx=3
    local maxCx=$((Cols - 2))
    local minCy=2
    local maxCy=$((Lines - 1))
    local TabBorder=($((RulerW - TABW - 2)) 21)
    for ((; ;)); do
	read -n 1 ch ################## probe for an Esc
	[ -z "$ch" ] && continue
	case ${ch} in
	    ${Esc})
		read -n 5 ch
		Cb=$(($(atoi "${ch:2:1}") - off))
		Cx=$(($(atoi "${ch:3:1}") - off))
		Cy=$(($(atoi "${ch:4:1}") - off))
		########################################
		((Cx < 0)) && ((Cx += 255))
		((Cy < 0)) && ((Cy += 255))
		########################################
		((Cx < minCx)) && ((Cx = minCx))
		((Cx > maxCx)) && ((Cx = maxCx))
		((Cy < minCy)) && ((Cy = minCy))
		((Cy > maxCy)) && ((Cy = maxCy))
		Cursor=($Cx $Cy)
		Cursor2Pixel
		#################################### Tab
		if ((Pixel[0] > TabBorder[0])) && \
		       ((Cy < TabBorder[1])); then
		    GetBgr ${Pixel[@]} # get colour
		    continue
		fi #####################################
		if ((Cx == maxCx)) && \
		       ((Cy == maxCy)); then
		    Tracking_Off
		    prompt
		    CommandMode
		fi #####################################
		if ((Cb == 0)); then
		    A=(${Pixel[@]})
		elif ((Cb == 3)); then
		    line ${A[@]} ${Pixel[@]}
		else
		    continue
		fi
		;;
	    'u')
		Undo
		;;
	    'x')
		Switch
		;;
	esac
    done
}
############################## !!! test zone !¿! #######
quit()
{
    stty $Setting # restore terminal settings *=*=*=*=*=
    printf "${CSI}8;${Geom[1]};${Geom[0]}t" # reset size
    Tracking_Off
}
trap quit EXIT
baz
########################################################

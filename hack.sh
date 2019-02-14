#!/bin/bash
# - Bgr to Fgr gradient
# - figure out SetFgrHSV with saturation 100
# - Backslash az text
# - undo
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
TABW=10 #Tab width :.:.:..:::: ....::.::.:.:::::...:..::
SetSizes() #                  :
{
    RulerW=$(( Cols/2 )) ############      #############
    RulerH=$(( Lines - 1)) ##########      #############
    SizeX=$(( RulerW - 1 )) ######### wow! #############
    SizeY=$(( RulerH - 1)) ##########      #############
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
GetPixelIndex()
{
    local jx=$((Pixel[0] - 1))
    local jy=$((Pixel[1] - 1))
    printf -v $1 "%d" $((jx + SizeX*jy))
}
Update=1 # Update pixel information ]]]]]]]]]]]]]]]]]]]l
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
    if ((Update)); then #           
	GetPixelIndex j
	Pix[j]="$BgrClr;$FgrClr;$SGR;$Text;1"        
    fi                                            #   
} ###############^################################a#####
Backup()         #       .                         
{                #                   . 
    Push $BgrClr #        .         .           
    Push $FgrClr #                               e    
    Push "$Text" #       .           
    Push $SGR    # ______ __________.___________y  _____
}                #
ReEstablish() #^#$######################################
{              # -Your-poem-goes-here:-----------------
    Pop SGR    # --------------------------------------
    Pop Text   # --------------------------------------
    Pop FgrClr # --------------------------------------
    Pop BgrClr # --------------------------------------
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
    SetSGR $Bold $Blnk #                               #
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
    SetSGR $Bold $Blnk #                               #
    Text=$PS3          #                               #
    Display            #                               #  
    printf "${CSI}K" ##^#####clear#############line####^
    ReEstablish        #                               #
}
Reset()
{
    FgrClr=$White ##### # #   #   # # # #################
    BgrClr=$Black ##### # # # ### # # # #################
    SGR=$Norm #########   #   #   #   # #################
    Text=$Void ######## ### ### # # # ###################
    Flag=0 ############   #   #   # # # #################
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
    Reset #wI;U{AJ}]QM|>qgZ-c8-*co}0= #x>YIY;VE5a4!c5wv^
    Colour #A|?2O@^,^Qs?%{ xau2"%r:*y%[=_[hu &kS|HF7{Uj@
    prompt #xm2dCan`m-kpu}k"])k3uV4BQJ%8#i<./XKwxFf\xwQv
    Setting=$(stty -g) #0WRUk)gQz9?m/NYN03\]'L6 GRw"~bIh
    stty -echo #|"VuQSx$[\Zn>vKD,lL8A2)3USMY@4$%PsP#[blR
}
zebug()
{
    printf "${CSI}s" ############## save cursor position
    printf "${CSI}1;1H" ##### position the cursor at 1,1
    printf "${CSI}K" ######################## clear line
    printf "%s" "$*" ############################## dump
    printf "${CSI}u" ########### restore cursor position
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
		zebug "F2"
#		PlayingMode
		;;
	    $F3)
		zebug "F3"
#		Tracking_On
#		DrawingMode
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
    printf "%s\n" "$Text" >> $FileName #   ' *   '     '
    printf "%s\n" $SGR >> $FileName #    . '     '   * '
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
Load()
{
    # again if no argument use current FileName ;;;;;;;;
    [ -z $1 ] || FileName=$1
    local IFS=' ' ###################### field separator
    local line= ############################# input line
    local i=0 ############################## pixel index
    exec 3<> $FileName ############ open file descriptor
    read -u 3 Lines Cols # read geometry ---------------
    read -u 3 BgrClr #_
    read -u 3 FgrClr ##_        .*``*.
    read -u 3 Text #####_      '      '
    read -u 3 SGR #######_     `,    ,`
    Backup ###############_      `''`
    printf "${CSI}8;${Lines};${Cols}t" ########## Resize
    ResetPixels #
    SetSizes # update size variables +++++++++++++++++++
    DrawFrame # re-draw frame ;;;;;;;;;;;;;;;;;;;;;;;;;;
    Colour #
    prompt # and prompt ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
    while read -u 3 line; do
	Unpack "$line" # ELDERA ALLURE `,`,`,`,`,`,`,`,`
	if ((Flag)); then
	    GetPixelCoors $i # yeah! <<<<<<<<<<<<<<<<<<<
	    Draw ${Pixel[@]} # yest! >>>>>>>>>>>>>>>>>>>
	fi
	((i++)) # click next +++++++++++++++++++++++++++
    done
    ReEstablish #
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
    Draw $@ #.,_,.-*`'-.,_,.-*`'-.,_,.-*`'-.,_,.-*`'-.,_
}
t() #              ||||||||||||||||||||||||__|||||||||||
{ #                |||||||||||||||||||||||||||||||||||||
    SetText "$@" # ||||||||||||||||||||||||||||||||||||\
}
                 # # # # # # # * # # * # # # # # # # # #
SetText()       # # # # # # * # # * # # # # # # # # # # 
{ #            # # # # # # # # * # # * # # # # # # # # 
    Text="$@" # # # # # # # * # # * # # # # # # # # #  
} #                            *
SetBgrHSV() #               *
{ #                                  *
    BgrClr=$(rgb/HSV2RGB $1 $2 $3) # ,//'\\,//'\\,//'\\,

    DumpColour 0 # .\\\*///.\\\*///.\\\*///.\\\*///.\\\*
}
SetFgrHSV()
{
    FgrClr=$(rgb/HSV2RGB $1 $2 $3) #|||| ||| ||| |||||||
    #                                       |
    DumpColour 1 #...................... .......|....... 
} #                                     |       .
SetBgrRGB()                                    
{ #                                                                
    BgrClr="$1;$2;$3" #                 '

    DumpColour 0 ############### Add a public comment...
}                                       
SetFgrRGB()                 
{
    FgrClr="$1;$2;$3" ################### very good song
                             
    DumpColour 1 ############################# thumbs up
}
GetPixelColour()
{
    local IFS=';' #### The Internal Field Separator ####
    local j ######################################### OK
    local f #===========================================
    local mode=$3 #...... 0 - background, 1 - foreground

    Pixel=($1 $2) # ^.   .^.   .^.   .^.   .^.   .^.   .
    GetPixelIndex j # `.`   `.`   `.`   `.`   `.`   `.`
    read -a f <<< "${Pix[j]}"
    if ((mode)); then     #`.`.`.`.`.`.`.`.`.`.`.`.`.`.`
	FgrClr="${f[3]};${f[4]};${f[5]}" #.`.`.`.`.`.`.`
    else                  #`.`.`.`.`.`.`.`.`.`.`.`.`.`.`
	BgrClr="${f[0]};${f[1]};${f[2]}" #.`.`.`.`.`.`.`
    fi                    #`.`.`.`.`.`.`.`.`.`.`.`.`.`.`
    IFS= DumpColour $mode #`.`.`.`.`.`.`.`.`.`.`.`.`.`.`
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
    read -a rgb <<< $BgrClr # ^^^^^^^^^^^^^^^^^^^^^^^^^^
    read -a hsv <<< $(rgb/RGB2HSV ${rgb[@]}) # %%%%%%%%%
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
    SetSGR $Bold    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
Colour()
# Display colour information ~ ! @ # $ % ^ & * ( ) _ + = 
{
    local TABH=7 #T #A #B #_ #H #E #I #G #H #T #_ #_ #_
    local x=$(( ORIG[0] + TABW - 1 )) #`'-_-'`'-_-'`'-_-
    local y=$(( ORIG[1] + TABH - 1 )) #   _     _     _
    Backup                            #   _     _     _
    Push $Update                      #   _     _     _
    ######################################=#####=#####=#
    Text=$Void ################                ~   clear
    BgrClr=$Black #############                     _-'`
    Update=0 ##################                    what!
    Box ${ORIG[@]} $x $y Draw #                     Bo><
    Pop Update ################                ~
    ReEstablish ###############                                      
    ########################################### ########
    DumpColour 0 ##############               b~ckground
    DumpColour 1 ##############               F~REGROUND
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
}
Gradient()
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
    read -a bgr <<< $BgrClr # k Ck Ok    _     _     _
    read -a fgr <<< $FgrClr # CK : Dart Vader  _     _
    local i #
    local clr=() #
    for ((i = 0; i < dim; i++)); do #
	e[i]=$(( (fgr[i] - bgr[i])/(n - 1) )) #
    done #
    for ((j = 0; j < n; j++ )) do #
	for ((i = 0; i < dim; i++)); do #
	    clr[i]=$((bgr[i] + e[i]*j)) #
	done #
	echo "${clr[*]}" 
    done #
}
#SemiAxis()
## $1 - bounding square lower coor ----------------------
## $2 - bounding square higher coor >>>>>>>>>>>>>>>>>>>>>
#{
#    echo "($2-($1)+1)/2" | bc -l
#}
#InCirc()
## $1, $2 - bounding square top left coors $$$$$$$$$$$$$$
## $3, $4 - pixel coors )))))))))))))))))))))))))))))))))
## $5, $6 - a and b semi axes ___________________________
#{
#    echo -e "define incirc(u, v, i, j, a, b) \n" \
#	 "{                               \n" \
#	 "    x = i - u + .5              \n" \
#	 "    y = j - v + .5              \n" \
#	 "    e = (x/a-1)^2+(y/b-1)^2     \n" \
#	 "                                \n" \
#	 "    if (e < 1) {                \n" \
#	 "        return 1                \n" \
#	 "    }                           \n" \
#	 "    return 0                    \n" \
#	 "}                               \n" \
#	 "incirc($1, $2, $3, $4, $5, $6)  \n" | bc -l
#}
#Circ()
## ($1, $2) - bounding box top left corner %%%%%%%%%%%%%%
## ($3, $4) - bounding box bottom right corner ``````````
#{
#    local x=($1 $3) ############################ x coors
#    local y=($2 $4) ############################ y coors
#    local u=${x[0]} ##################### top left coors
#    local v=${y[0]} ############################## yeah!
#    local i ################################# loop index 
#    local j ################################# loop index
#    local a=$(SemiAxis ${x[@]}) ############ a semi axis
#    local b=$(SemiAxis ${y[@]}) ############ b semi axis
#    for ((j = y[0]; j <= y[1]; j++)); do
#	if (( j < 1 || j > SizeY )); then
#	    continue
#	fi		
#	for ((i = x[0]; i <= x[1]; i++)); do
#	    if (( i < 1 || i > SizeX )); then
#		continue
#	    fi		
#	    if [ $(InCirc $u $v $i $j $a $b) -eq 1 ]
#	    then
#		Draw $i $j ####################### yeah!
#	    fi
#	done
#    done
#}
#IsArrow()
#{
#    case "$1" in
#	$Up|$Down|$Right|$Left) printf 1 ;; ############
#	*) printf 0 ;; #################################
#    esac
#}
#GetCoorz()
###Get#Cursor#and#Pixel#coors############################
#{
#    local poz=() ############################## position
#    printf "${CSI}6n" ### request cursor position report
#    IFS=';' read -d R -a poz ########### read the report
#    Cursor=(${poz[1]} ${poz[0]:2}) ######## Cursor coorz
#    Cursor2Pixel ############ update Pixel coorz az well
#}
#PlayingMode()
#{
#    local ch ################################# character
#    local Space=' ' ########################## space bar
#    local poz=(2 $((2*SizeX-1))) ########## Tab position
#    while IFS= read -s -n 1 ch; do ################## oo
#	case $ch in
#	    $Esc)
#		########################### arrow keys ?
#		read -s -n 2 ch ;;	                       
#	    $Space) #-----------------------draw-a-pixel
#		GetCoorz ########################## wow!
#		Draw ${Pixel[@]} ######### what is this?
#		;;
#	    'g') #==================get=pixel=color=etc.
#		GetCoorz ######################### yeah!
#		GetPixel ${Pixel[@]} #### get pixel data
#		;;
#	    $'\t') #______________switch_pixel_positions
#		GetCoorz ####################### so cool
#		printf "${CSI}${poz[0]};${poz[1]}H"
#		poz=(${Cursor[1]} ${Cursor[0]})
#		;;
#	esac
#	if [[ $ch == $F1 ]]; then
#	    prompt #### Kiesza-Hideaway (Official Video)
#	    CommandMode ########################## yeah!
#	elif (( $(IsArrow $ch) )); then
#	    printf $Esc$ch ##################### come on
#	fi
#    done
#}
#Mode=1000
#Tracking_On()
#{
#    printf "${CSI}?25l" # hide cursor
#    printf "${CSI}?${Mode}h"
#}
#Tracking_Off()
#{
#    printf "${CSI}?25h"
#    printf "${CSI}?${Mode}l"
#}
#atoi()
#{
#    printf "%c" "$1" | hexdump -e '/1 "%02d"'
#}
#########################################################
############# On button press, xterm(1) sends ESC [ M bxy
##### (6 characters). Here b is button-1, and x and y are
#### the x and y coordinates of the mouse when the button
###### was pressed. This is the same code the kernel also
############################################### produces.
#################################### (from console_codes)
#DrawingMode()
#{
#    local ch # >>> THIS IS _NOT_ THE ch REGISTER !!! <<<
#    local C1
#    local C2
#    while :; do
#	read -n 1 ch ################## probe for an Esc
#	[ -z "$ch" ] && continue
#	if [[ $ch == $Esc ]]; then
#	    read -n 5 ch
#	    C1=$(atoi "${ch:3:1}")
#	    if ((C1 < 0)); then 
#			((C1 += 223))
#	    else
#			((C1 -= 32))
#	    fi
#	    if ((C1 < 3)) || ((C1 > Cols)); then
#			continue;
#	    fi
#	    C2=$(atoi "${ch:4:1}")
#	    if ((C2 < 0)); then
#			((C2 += 223))
#	    else
#			((C2 -= 32))
#	    fi
#	    if ((C2 < 2)) || ((C2 > Lines-1)); then
#			continue;
#	    fi
#	    Cursor=($C1 $C2)
#	    Cursor2Pixel
#	    # ... should set here n=10
#	    if ((C1 > Cols-22)); then
#			if ((C2 < 12)); then
#				GetPixel ${Pixel[@]} # get color
#				continue
#			fi
#	    fi
#	    if ((C2 == Lines-1)) && ((C1>Cols-2)); then
#			Tracking_Off
#			prompt
#			CommandMode
#	    fi
#	    Draw ${Pixel[@]}
#	fi	
#    done
#}
############################## !!! test zone !¿! #######
quit()
{
    stty $Setting # restore terminal settings *=*=*=*=*=
    printf "${CSI}8;${Geom[1]};${Geom[0]}t" # reset size
}
#trap quit EXIT
#baz
########################################################
#Init
#stty -echo
#Hue 0
#Tracking_On
#BgrClr=$Blue
#trap Tracking_Off EXIT
#DrawingMode

/*  GIMP header image file format (RGB): /home/neznajko/Downloads/godfather-17x25.h  */

static unsigned int width = 17;
static unsigned int height = 25;

/*  Call this macro repeatedly.  After each use, the pixel data can be extracted  */

#define HEADER_PIXEL(data,pixel) {\
pixel[0] = (((data[0] - 33) << 2) | ((data[1] - 33) >> 4)); \
pixel[1] = ((((data[1] - 33) & 0xF) << 4) | ((data[2] - 33) >> 2)); \
pixel[2] = ((((data[2] - 33) & 0x3) << 6) | ((data[3] - 33))); \
data += 4; \
}
static char *header_data =
	"!!!!!!!!!Q)##1=(%AY/,S5@03UB7%-S-S9='R93#!9&!1!!!!!!!!!!!!!!!!!!"
	"!!!!!!!!\"!1%*2Q8.SA?.S=@2T)GJ)\"AH7^/>%9N7TEI9%5S-#)9\"Q5%!1%\"!!!!"
	"!!!!!!!!!1%\"\"!1%&A].649D;$YGH'R)MI2>U:VO[-79Y]?:N)*4=EMP/#9:&!Y+"
	"!1!!!!!!!!!!!1%\"%!A)22M5LW5XYL&O]?@+`@TY`P\\_`P\\^]O\\6Y=C-TK\"IA&5W"
	"6$YN!1%\"!!!!!!!!$A9&B4)?Q6]RYK.;Y\\:P[^SR_PHP`@X\\_`LS\\O8!YM&_Y]3%"
	"PI20;UMR'B%-!1!\"!!!!3RI3OUMHY(U\\YZ6,Z+\"7[-+!\\>[U]/L,\\O/`[-G*Z<NS"
	"Y+J?Z,NZMY\"0*21+!A%\"!!!!.QQ+DSE:U6UNY(M]Z:\".\\+ZJ\\]+%].;H].?H[\\NV"
	"[<\"FZ[J>[-\"]Z<J]FWR'4U%U!Q)\"&!)$4!Y,E#E;S%QHV75UY9.*YZ\"5YZ29Z:F;"
	"YJ.4ZZZ8[K:;[KVBY[VLM92<1D!C)2A3#1!#(!%\"3AM)P%)FW7AXUGM\\WHZ+Y*&:"
	"\\+RP[;6CZ*B7[;6<[K6<U9F1EW:#3#U?34YT\"1!\"(1)#9B50K$9AX'Q\\WX*\"X9&,"
	"\\KVT]=+)\\]'&\\M?,\\M7#Z[\"<R'9\\9SY:13)3341G\"A!\"21],ASA<PUMNW'Z!ZY>4"
	"T'F#O7:$H6V!J'R,NX^7S*:RZ+RTVXB,8C!02\"M3B$)E$A-%&!1%(A=&.A],4R91"
	"ETAHGTYI+!1%)!1%(Q-#3B-272)/<#%5VHN0EUAJA#E@BS)?!!!!!!!!!1%\"!A%\""
	"\"!)\";CE>Z:NG1AU)(A-#*Q9'*15%7#%9FU%HYJ6AN')[DSUBB5%H!!!!!!!!!A%\""
	"!A%\"#1)\"?#UA]\\:\\T7]_@#Y=BD)FLG\"#Z;6P]M#'\\\\*WR')_W)6<8D1@!!!!!1!!"
	"%Q)#5!Y+9RA3@#I@][RS]J>6^<.WX9Z>Z:\"?^,J`]L.XY9>6QFI[FTYJ/RU3!!!!"
	")15%?#9;KE!M7\"-/C#QC^L7#^*N<Z9N9^<:Z];2KZ)*1V7F#WXJ/TH\"(@D)E\"!)\""
	"!!!!%!!!;B51O5AV6AY,HD1N]Z.D]:*BXXN4UX>4^,&T\\*2>XX^.ZJ6ATX:+$A1#"
	"!1%\"!!!!!1!!0A5%BC%>,!9&(A-$;2A94QQ+LG\"'W9B?ZJ&>\\[:J[ZZEY)Z;UXR1"
	"$Q5$!1%\"!!!!\"!!!*!!!5Q9'$Q)\"\"!-#(QA'@CI9HUEPO7V)XIJ7];ZR\\+6JXIF8"
	"QWB\"%AE'!1%\"!!!!\"Q!!31I)-A)#\"1%\"#!-#@$MPK5=VG41JGD=JTY.9]<&U\\;>N"
	"UXF.M&Z\"$A='!1%\"!!!!!1!!42!.-1='!Q%\"'!A'9#YBJ'&)RYFIS8^:QW>#Y:.C"
	"Y)Z>LV=]OZ/,/45S!1%\"!!!!!!!!&!%\".!1%+!-$*Q='62Q8;S5@CSUDU'J,WXZ8"
	"LEMNIUER;T5Q\\O@H+CAG!1%\"!!!!!!!!!!!!\"Q!!&!!!+A-$5RA2B$AFGE9QIU-L"
	"JE1I<RE-1BA3T=#VIJW;\"!1&!1%\"!!!!!!!!!!!!!1!!!A!!3R%-DT1HR'2'QG:'"
	"Q'F,G%)K/B1,J9NRY>\\:*C1C!A)#!!!!!!!!!!!!!!!!!!!!!!!!#A%\"*Q)#3QI*"
	"51E(2!=''Q1$6E!MO[S;,CMK\"A9(#QI+!!!!";

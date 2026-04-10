unit main;

interface
{$ifdef gui4} {$define gui3} {$define gamecore}{$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define bmp} {$define ico} {$define gif} {$define snd} {$endif}
{$ifdef con3} {$define con2} {$define net} {$define ipsec} {$endif}
{$ifdef con2} {$define bmp} {$define ico} {$define gif} {$define jpeg} {$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d3laz} {$undef laz} {$endif}
uses gossroot, {$ifdef gui}gossgui,{$endif} {$ifdef snd}gosssnd,{$endif} gosswin, gosswin2, gossio, gossimg, gossnet, gossfast, gossteps;
{$align on}{$O+}{$W-}{$I-}{$U+}{$V+}{$B-}{$X+}{$T-}{$P+}{$H+}{$J-} { set critical compiler conditionals for proper compilation - 10aug2025 }
//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2026 Blaiz Enterprises ( http://www.blaizenterprises.com )
//##
//## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//## files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//## modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
//## is furnished to do so, subject to the following conditions:
//##
//## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//##
//## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//##
//## ==========================================================================================================================================================================================================================
//## Library.................. app code (main.pas)
//## Version.................. 1.00.4225 (+168)
//## Items.................... 3
//## Last Updated ............ 11apr2026, 11dec2025, 05dec2025, 04dec2025, 01dec2025, 30nov2025, 19nov2025, 15nov2022, 14nov2022, 13nov2022, 12nov2022, 09nov2022, 06nov2022, 15mar2022, 13mar2022, 09mar2022, 08mar2022, 07mar2022, 01mar2022, 28feb2022, 27feb2022
//## Lines of Code............ 6,600+
//## Origin .................. Human generated and maintained
//##
//## main.pas ................ App specific code
//## gossdat.pas ............. App specific icons and help documents
//## gossfast.pas ............ FastDraw - rapid render graphic procs
//## gossgame.pas ............ GameCore - 2D game engine with integrated menu handler, xbox controller + mouse + keyboard support and window integration
//## gamefiles.pas ........... Built-in file(s) for GameCore (optional)
//## gossgui.pas ............. GUI management and controls
//## gossimg.pas ............. Multi-format graphic procs for 8, 24 and 32 bit images with IO support
//## gossio.pas .............. File IO and low level file/folder/disk/data format procs
//## gossjpg.pas ............. JPEG IO (read/write jpeg image data via third party libraries)
//## gossnet.pas ............. Networking - ip filtering, socket management etc
//## gossroot.pas ............ App startup and control (GUI, console and service)
//## gosssnd.pas ............. Sound, audio, midi and midi based chimes
//## gossteps.pas ............ System, Folder and App images
//## gosstext.pas ............ TextCore - non-GUI and GUI text engine for text boxes
//## gosswin.pas ............. Win32 api calls for 32 and 64 bit (static / api references disabled by default)
//## gosswin2.pas ............ Win32 api calls for 32 and 64 bit (dynamic - load as required with fallback failure handling and default value(s) support)
//## gosszip.pas ............. ZIP IO (read/write zip data via third party libraries)
//##
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy         | Version   | Date        | Update history / brief description of function
//## |------------------------|-------------------|-----------|-------------|--------------------------------------------------------
//## | talarmlist             | tobjectex         | 1.00.564  | 04dec2025   | Alarm / reminder data handler - 03dec2025, 30nov2025, 09mar2022, 07mar2022
//## | tbasicalarmlist        | tbasicscroll      | 1.00.523  | 04dec2024   | Alarm / reminder GUI handler - 03dec2025, 30nov2025, 14nov2022, 13mar2022, 07mar2022
//## | tapp                   | tbasicapp         | 1.00.2960 | 11apr2026   | Harmony - Digital chiming clock - 11dec2025, 05dec2025, 03dec2025, 01dec2025, 30nov2025, 19nov2025, 15nov2022, 14nov2022, 13nov2022, 12nov2022, 09nov2022, 06nov2022, 15mar2022, 13mar2022, 09mar2022, 08mar2022, 07mar2022, 01mar2022, 28feb2022, 27feb2022
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================


var
   itimerbusy:boolean=false;
   iapp:tobject=nil;

const

   tepHarmonyColPal20  =tepCustomBASE20 + 0;
   time_sep            =':';

   //values compatible with "xfindval" and thus "bol[]"
   date_show            =1;
   date_uppercase       =2;
   date_top             =3;
   date_full            =4;

   day_show             =5;
   day_uppercase        =6;
   day_top              =7;
   day_full             =8;

   rem_uppercase        =9;
   rem_top              =10;

   pod_show             =11;//part of day
   pod_uppercase        =12;

   swap_colors          =13;
   back_mix             =14;
   flash_sep            =15;


type


   tfontlist=array[0..7] of tresslot;

{clockface - proc}
   tclockfaceinfo=record

      date            :tdatetime;
      zoom            :double;
      actbuzzer       :longint;
      actmsg          :string;
      remmsg          :string;
      daytop          :boolean;
      remtop          :boolean;
      datetop         :boolean;
      havebuzzer      :boolean;
      havemsg         :boolean;
      haveremmsg      :boolean;
      flash           :boolean;
      dateformat      :longint;
      timeformat      :longint;
      backcolor       :longint;
      fontcolor       :longint;
      brightness      :longint;
      morningMIN      :longint;
      eveningMIN      :longint;
      autodim         :longint;
      feather         :longint;
      showday         :boolean;
      showpod         :boolean;
      showrem         :boolean;
      showdate        :boolean;
      remUppercase    :boolean;
      dateFull        :boolean;
      dateUppercase   :boolean;
      dayFull         :boolean;
      dayUppercase    :boolean;
      podUppercase    :boolean;
      forcedim        :boolean;
      lpredawn        :string;
      lmorning        :string;
      lafternoon      :string;
      levening        :string;
      showsep         :boolean;

      end;

{talarmlist}
   talarmlist=class(tobjectex)
   private

    iyear      :array[0..49] of longint;
    imonth     :array[0..49] of longint;
    iday       :array[0..49] of longint;
    ihour      :array[0..49] of longint;
    iminute    :array[0..49] of longint;
    idayOfweek :array[0..49] of longint;
    iduration  :array[0..49] of longint;
    istyle     :array[0..49] of longint;
    ibuzzer    :array[0..49] of longint;
    imsg       :array[0..49] of string;

    //.active alarm range -> based on ms64 + duration -> accurate over year/month/day boundaries - 09mar2022
    ifrom64    :array[0..49] of comp;//start of alarm in ms64
    iplaylen,iplayrem,ilastmin,imax,icount,iid,ipos:longint;

    procedure setpos(x:longint);
    procedure setyear(x:longint);
    procedure setmonth(x:longint);
    procedure setday(x:longint);
    procedure sethour(x:longint);//24 hour time -> hour=0..23
    procedure setminute(x:longint);//minute=0..59
    procedure setdayOfweek(x:longint);
    procedure setduration(x:longint);
    procedure setstyle(x:longint);
    procedure setbuzzer(x:longint);
    procedure setmsg(x:string);
    function getyear:longint;
    function getmonth:longint;
    function getday:longint;
    function getdayFiltered:longint;
    function gethour:longint;
    function getminute:longint;
    function getdayOfweek:longint;
    function getduration:longint;
    function getstyle:longint;
    function getbuzzer:longint;
    function getmsg:string;
    procedure xflush;
    procedure xflushone(x:longint);//03dec2025
    function getone:string;
    procedure setone(xdata:string);
    function _gettext(xb64:boolean):string;
    procedure settext(x:string);
    function gettext:string;
    function gettext64:string;
    procedure xresetactive(xpos:longint);

   public

    //options
    omode:longint;//default=0=alarms, 1=reminders

    //create + destroy
    constructor create; override;
    destructor destroy; override;

    //internal
    function xincid:boolean;//pass-thru
    function xsafepos(x:longint):longint;
    function xdayFiltered(xpos:longint):longint;

    //information
    property count:longint             read icount;//statically locked at 30
    property id:longint                read iid;//changes each time an aspect of ANY alarm changes
    property pos:longint               read ipos               write setpos;//0..count-1

    //for buzzer/alarm realtime-monitoring - in seconds (0=off)
    property playlen:longint            read iplaylen;
    property playrem:longint            read iplayrem;

    //pos specific information
    property year:longint              read getyear            write setyear;
    property month:longint             read getmonth           write setmonth;
    property day:longint               read getday             write setday;
    property dayFiltered:longint       read getdayFiltered;//restricts the day to the month's upper limit based on Alarm style - 09mar2022
    property dayOfweek:longint         read getdayOfweek       write setdayOfweek;
    property hour:longint              read gethour            write sethour;
    property minute:longint            read getminute          write setminute;
    property duration:longint          read getduration        write setduration;
    property style:longint             read getstyle           write setstyle;
    property buzzer:longint            read getbuzzer          write setbuzzer;
    property msg:string                read getmsg             write setmsg;

    //workers
    procedure flush;//clear all
    procedure clearone;//clear one
    function finditem(xpos:longint;var xyear,xmonth,xday,adayFiltered,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer:longint;var xmsg:string):boolean;
    function findactive(xdate:tdatetime;var xindex,xtotalsecs,xremsecs,xbuzzer:longint;var xmsg:string;var xhavebuzzer,xhavemsg:boolean):boolean;
    function findalarm(xdate:tdatetime;var xindex,xtotalsecs,xremsecs,xbuzzer:longint;var xmsg:string;var xhavebuzzer,xhavemsg:boolean):boolean;//requires "omode=0" - 04dec2025
    function findreminder(xdate:tdatetime;var xindex:longint;var xmsg:string;var xhavemsg:boolean):boolean;//09mar2022
    procedure stopactive;

    //io
    property one:string                read getone             write setone;//current item's data
    property text:string               read gettext            write settext;
    property text64:string             read gettext64          write settext;

    //io.clipboard
    function cancopy:boolean;
    function canpaste:boolean;
    function pasteprompt1(xgui:tbasicsystem):boolean;//step 1 of 2
    function paste2(var e:string):boolean;//step 2 of 2

    //io.file
    function iolabel:string;
    function ioheader:string;
    function ioext:string;
    function saveas(xgui:tbasicsystem;var xlastfilename:string;xprompt:boolean;var e:string):boolean;
    function open(xgui:tbasicsystem;var xlastfilename:string;var xlastfilterindex:longint;xprompt:boolean;var e:string):boolean;

    //makers
    function makeAlarms:boolean;//pass-thru
    function makeReminders:boolean;//pass-thru

    //support procs
    procedure xresetLastmincheck;

   end;


{tbasicalarmlist}
   tbasicalarmlist=class(tbasicscroll)
   private

    icore:talarmlist;
    ilist:tbasicmenu;
    istyle,imonth,iday:tbasicsel;
    ibuzbar:tbasictoolbar;
    ibuzlist:tbasicmenu;
    idow:tbasicset;
    idur,iminute,ihour:tsimpleint;
    iyear,imsg:tbasicedit;
    ilastfilename,ilastref,ilastref2,ilastref3,ilastref4,ilastref5:string;
    iplayingbuzzerLEN,imustplay,ilastfilterindex:longint;
    iplayingbuzzerREF64,itimer250:comp;

    function getpos:longint;
    procedure setpos(x:longint);
    function gettext:string;
    function gettext64:string;
    procedure settext(x:string);
    procedure _onvalcap(sender:tobject;var xval:string);
    function _onbuzlistitem(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
    procedure xsynchelp;//04dec2025

   public

    //options
    odateformat:longint;//display purposes only
    otimeformat:longint;//display purposes only
    omode:longint;//default=0=alarms, 1=reminders
    osynchead_alarmbuttonbyname:string;

    //create
    constructor create2(xparent:tobject;xscroll,xstart:boolean); override;
    destructor destroy; override;

    //core
    property core:talarmlist           read icore;//04dec2025

    //internal
    procedure _ontimer(sender:tobject); override;
    procedure ____onclick(sender:tobject);
    procedure showmenuFill(xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string); override;
    function showmenuClick(sender:tobject;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean; override;
    function xlistitem(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
    function xtogui:boolean;//pass-thru
    function xfromgui:boolean;//pass-thru
    function xmustfromgui:boolean;

    //pos
    property pos:longint               read getpos             write setpos;

    //buzzer support - 14nov2022
    function canplaybuzzer:boolean;
    procedure playbuzzer;
    function canstopbuzzer:boolean;
    procedure stopbuzzer;
    function testingbuzzer:boolean;
    function xbuzzerPert0100:extended;//0..100
    procedure _playbuzzer;

    //io
    property text:string               read gettext            write settext;
    property text64:string             read gettext64          write settext;

    //makers
    function makeAlarms:boolean;//pass-thru
    function makeReminders:boolean;//pass-thru

    //test procs
    procedure test__alarmnow;

   end;


{tapp}
   tapp=class(tbasicapp)
   private

    ifontlist:tfontlist;
    iresSlot:tresslot;
    ichimebar:tbasictoolbar;
    ibuffer:twinbmp;
    iscreenbuffer:trawimage;
    ibellbuffer:tbasicimage;
    ilastmidtest,iautodimcap,iautoquietencap,iframeref,ibellref,iscreenref,iscreenref2:string;
    iscreen:tbasiccontrol;
    iflash1000,iwakeonclick,iwasshowinghelp,imustquieten,iinsidescreen,ibuildingcontrol,iloaded:boolean;
    iidleref,iscrollref64,ilaststopactive64,iflashref,iinfotimer,itimer100,itimer250,itimer500,itimer1000:comp;
    ishowpage,isettingsref:string;
    imousemoveoff,isetcol,ifacecol,iscrollref,iscrollref2,ishortlabellimit,ialarmpos,ireminderpos,iframebrightness:longint;
    isetpages:tbasicscroll;

    //.color support
    icolorname:array[0..199] of string;
    icolorfont:array[0..199] of longint;
    icolorback:array[0..199] of longint;
    icolorfrom1,icolorfrom2,icolorcount:longint;
    icolorindex:longint;//read only - used for painting purposes
    ibrightnessREF,iframeOuterColor,iframeInnerColor,iminfontsize2,ibackcolor,ifontcolor:longint;//set via "xmustcolor"
    ifinalBackColor   :longint32;
    ifinalFontColor   :longint32;
    ifinalBrightness  :longint32;
    ifinalFeather4    :longint32;
    ifinalWidth       :longint32;
    ifinalHeight      :longint32;

    ilastcolname:string;

    //.custom colors
    icolor1:array[0..9] of longint;
    icolor2:array[0..9] of longint;

    //.alarm support
    iactindex,iactbuzzer:longint;
    iactmsg:string;
    ihavebuzzer,ihavemsg:boolean;

    //.reminder support
    iremindex:longint;
    iremmsg:string;
    ihaveremmsg:boolean;

    //.chime support
    ilasttestchimeref,ilastchimename:string;
    ichimemins:longint;

    //pointers
    inormal,ison,iday,ipod,idate,irem,ichimeoptions,isettings,icolopts:tbasicset;
    ibell0,ison0,inormal0,idateformat,itimeformat,iautodim,ifeather,ishadestyle,iautoquieten,iframestyle:tbasicsel;
    ichimespeed,pbrightness,ibrightness,ibrightness2,ishadepower,imorning,ievening:tsimpleint;
    ilabel_predawn,ilabel_morning,ilabel_afternoon,ilabel_evening:tbasicedit;
    pchimetest:tbasicbwp;
    icustomcolors:tbasiccolors;
    icolorlist,ichimelist:tbasicmenu;
    ialarmlist,ireminderlist:tbasicalarmlist;

    //.status support
    procedure xcmd(sender:tobject;xcode:longint;xcode2:string);
    procedure __onclick(sender:tobject);
    procedure xloadsettings;
    procedure xsavesettings;
    procedure xautosavesettings;//04dec2025
    procedure xshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
    function xshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
    function xstopactive:boolean;
    function xmustframe:boolean;//fixed 04dec2025, 06nov2022
    function xmustcolor:boolean;
    function xmustclock:boolean;
    function xchimelistnotify(sender:tobject):boolean;
    procedure xscreenpaint(sender:tobject);
    procedure xscreenpaint2(sender:tobject;dgamemode:boolean);
    function xscreennotify(sender:tobject):boolean;
    procedure xcustomcolorchanged(sender:tobject);
    procedure xmakeClockSettings(sender:tobject);
    function xmorn_even(xmorning:boolean):string;
    procedure _onvalcap(sender:tobject;var xcap:string);
    function xfindcolor(xname:string):longint;
    function xfindcolor2(xname:string;var xindex:longint):boolean;
    function xlistitem2(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor,xtepcolor2:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
    function xsyscol(x:longint;xforeground:boolean):longint;
    function xmustreplaytestchime:boolean;
    procedure xplaytestchime;
    procedure xfillCustomcolors(xcolname:string);
    procedure xfromCustomcolors(xcolname:string);
    procedure xupdatebuttons;
    procedure setshowpage(x:string);
    property showpage:string read ishowpage write setshowpage;
    procedure xmakecolors;
    procedure xautohideControlsCursor;
    function xidleDelay:longint;
    procedure xnotidle;
    procedure xmakeidle;
    function xidletime(xdropBeginning:boolean):comp;
    procedure gamemode__onpaint(sender:tobject);
    function gamemode__onnotify(sender:tobject):boolean;
    function gamemode__onshortcut(sender:tobject):boolean;
    procedure setcolorname(x:string);
    function getcolorname:string;
    property colorname:string read getcolorname write setcolorname;
    procedure setchimename(x:string);
    function getchimename:string;
    property chimename:string read getchimename write setchimename;
    procedure xsel__readwrite(sender:tobject;var xval:longint;xwrite:boolean);
    procedure xset__readwrite(sender:tobject;var xval:tbasicset_valarray;xwrite:boolean);
    function xfindval(const xindex:longint;var s:tobject;var sn:string):boolean;
    function getbol(xindex:longint):boolean;
    procedure setbol(xindex:longint;xval:boolean);
    property bol[xindex:longint]:boolean read getbol write setbol;

    procedure xsetnormals(const n0,n15,n30,n45:boolean);
    function xnormals(const xval:longint):boolean;

    procedure xsetbells(const n0:boolean);
    function xbells(const xval:longint):boolean;

    procedure xsetsons(const n0,n15,n30,n45:boolean);
    function xsons(const xval:longint):boolean;

   public

    //create
    constructor create; virtual;
    destructor destroy; override;
    procedure __ontimer(sender:tobject); override;

   end;


const
   def_vsep        =10;
   def_vsep_small  =4;

//high resolution sharp edged bell with a background color of "red(255,0,0)" and foreground color of "black(0,0,0)" - 07mar2022
tep_bell:array[0..1272] of byte=(
84,69,65,49,35,141,0,0,0,160,0,0,0,255,0,0,250,255,0,0,97,0,0,0,11,255,0,0,128,0,0,0,15,255,0,0,124,0,0,0,19,255,0,0,120,0,0,0,23,255,0,0,117,0,0,0,25,255,0,0,115,0,0,0,27,255,0,0,113,0,0,0,29,255,0,0,111,0,0,0,31,255,0,0,109,0,0,0,33,255,0,0,108,0,0,0,33,255,0,0,107,0,0,0,35,255,0,0,106,0,0,0,35,255,0,0,105,0,0,0,37,255,0,0,103,0,0,0,39,255,0,0,99,0,0,0,45,255,0,0,94,0,0,0,49,255,0,0,90,0,0,0,53,255,0,0,87,0,0,0,55,255,0,0,84,0,0,0,59,255,0,0,81,0,0,0,61,255,0,0,78,0,0,0,65,255,0,0,75,0,0,0,67,255,0,0,73,0,0,0,69,255,0,0,71,0,0,0,71,255,0,0,69,0,0,0,74,255,0,0,65,0,0,0,77,255,0,0,63,0,0,0,79,255,0,0,62,0,0,0,79,255,0,0,61,0,0,0,81,255,0,0,59,0,0,0,83,255,0,0,57,0,0,0,85,255,0,0,55,0,0,0,87,255,0,0,54,0,0,0,88,255,0,0,52,0,0,0,89,255,0,0,51,0,0,0,91,255,0,0,50,0,0,0,91,255,0,0,49,0,0,0,93,255,0,0,48,0,0,0,94,255,0,0,46,0,0,0,95,255,0,0,45,0,0,0,97,255,0,0,44,0,0,0,97,255,0,0,44,0,0,0,97,255,0,0,43,0,0,0,99,255,0,0,42,0,0,0,99,255,0,0,41,0,0,0,101,255,0,0,40,0,0,0,101,255,0,0,40,0,0,0,101,255,0,0,
39,0,0,0,103,255,0,0,38,0,0,0,103,255,0,0,38,0,0,0,103,255,0,0,38,0,0,0,103,255,0,0,37,0,0,0,105,255,0,0,36,0,0,0,105,255,0,0,36,0,0,0,105,255,0,0,36,0,0,0,105,255,0,0,36,0,0,0,106,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,33,0,0,0,109,255,0,0,32,0,0,0,109,255,0,0,32,0,0,0,109,255,0,0,32,
0,0,0,109,255,0,0,32,0,0,0,109,255,0,0,31,0,0,0,111,255,0,0,30,0,0,0,111,255,0,0,30,0,0,0,111,255,0,0,29,0,0,0,113,255,0,0,28,0,0,0,113,255,0,0,28,0,0,0,113,255,0,0,27,0,0,0,115,255,0,0,26,0,0,0,115,255,0,0,25,0,0,0,117,255,0,0,24,0,0,0,117,255,0,0,23,0,0,0,119,255,0,0,21,0,0,0,121,255,0,0,20,0,0,0,121,255,0,0,19,0,0,0,123,255,0,0,17,0,0,0,125,255,0,0,15,0,0,0,127,255,0,0,13,0,0,0,128,255,0,0,13,0,0,0,129,255,0,0,11,0,0,0,131,255,0,0,9,0,0,0,133,255,0,0,7,0,0,0,135,255,0,0,5,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,50,0,0,0,45,255,0,0,97,0,0,0,43,255,0,0,99,0,0,0,42,255,0,0,99,0,0,0,41,
255,0,0,101,0,0,0,39,255,0,0,102,0,0,0,39,255,0,0,103,0,0,0,37,255,0,0,105,0,0,0,35,255,0,0,107,0,0,0,33,255,0,0,109,0,0,0,31,255,0,0,112,0,0,0,27,255,0,0,115,0,0,0,25,255,0,0,118,0,0,0,21,255,0,0,122,0,0,0,17,255,0,0,128,0,0,0,9,255,0,0,250,255,0,0,98);


//custom DUAL color palette image
tep_colorpal20
:array[0..715] of byte=(
137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,42,0,0,0,20,8,6,0,0,0,251,179,175,134,0,0,2,147,73,68,65,84,120,1,212,86,109,79,19,65,16,126,36,80,68,10,88,91,20,40,47,7,104,37,209,152,248,255,127,131,159,36,81,172,66,139,208,26,121,9,41,84,148,26,112,30,246,246,58,187,221,187,30,225,67,113,146,246,102,119,103,102,159,123,102,102,247,128,255,68,30,105,156,215,192,141,30,143,90,31,3,18,124,137,66,144,99,15,11,39,174,5,167,5,43,79,200,68,78,144,165,211,116,146,185,182,249,21,120,89,7,150,191,167,219,221,97,133,196,217,44,143,231,246,43,31,1,199,207,129,170,128,104,45,187,110,51,29,224,180,236,206,205,255,20,251,121,119,238,30,163,91,70,115,249,151,206,140,217,225,10,176,208,118,93,206,103,129,181,134,59,55,254,215,29,223,115,148,143,209,133,22,80,175,245,183,42,94,244,245,52,109,230,28,232,77,152,213,147,74,216,170,116,162,218,69,76,252,172,40,175,124,64,11,61,229,34,42,65,151,143,221,192,22,148,181,44,252,233,167,158,108,239,175,217,21,243,92,109,2,205,200,157,11,217,197,22,
195,83,255,76,222,154,1,223,127,112,131,14,99,117,251,29,240,246,163,241,161,63,129,89,209,32,223,108,187,118,220,47,32,195,129,22,174,140,91,183,232,186,79,10,99,89,82,251,44,171,234,88,110,70,166,182,23,165,140,168,91,233,73,82,187,79,236,40,245,153,13,180,40,117,214,94,2,162,61,147,110,203,16,195,125,121,45,27,203,166,89,242,107,218,93,101,57,240,167,133,4,52,54,128,138,156,42,126,57,41,187,236,26,181,233,37,171,235,187,82,248,138,33,6,41,118,85,40,79,237,21,6,237,233,239,199,184,137,239,156,180,134,139,195,102,3,181,105,39,123,33,97,83,45,30,2,63,132,245,60,146,220,131,202,216,238,161,166,66,106,122,234,109,19,213,118,128,37,1,195,3,188,122,16,104,170,152,85,159,41,2,240,65,92,9,203,252,105,209,54,19,94,89,40,187,48,163,4,105,211,206,99,135,117,106,101,218,75,55,89,141,164,134,253,218,163,189,6,193,163,167,85,53,81,168,55,35,163,51,91,175,132,140,11,169,213,182,172,79,94,202,203,60,54,107,234,127,16,40,175,67,93,47,123,82,232,115,114,43,117,230,128,89,121,134,202,160,177,
14,172,236,155,176,91,159,164,14,229,134,222,217,234,111,179,241,205,61,71,121,166,114,110,119,211,216,212,227,210,98,214,2,32,105,52,8,148,215,33,187,111,74,222,140,191,51,1,72,144,148,206,83,89,147,238,228,117,170,27,131,54,71,47,76,121,216,251,189,34,155,78,253,22,39,105,160,131,213,91,119,231,143,4,240,187,129,54,44,135,75,97,209,250,58,134,102,144,148,55,191,82,30,242,103,94,2,148,184,9,54,240,50,35,155,146,78,119,240,141,12,200,93,54,254,7,0,0,255,255,3,0,136,143,194,39,148,190,113,79,0,0,0,0,73,69,78,68,174,66,96,130);


//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024


//app procs --------------------------------------------------------------------
//.remove / create / destroy
procedure app__remove;//does not fire "app__create" or "app__destroy"
procedure app__create;
procedure app__destroy;

//.event handlers
function app__onmessage(m:msg_message;w:msg_wparam;l:msg_lparam):msg_result;//17dec2025
procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
procedure app__onpaint(sw,sh:longint);
procedure app__ontimer;

//.support procs
function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
procedure app__customTEP(const xindex:longint);
function app__syncandsavesettings:boolean;


//program specific low level procs
function low__clockface(const xscreenBuffer:trawimage;const xbellBuffer:tbasicimage;var xscreenref,xbellref:string;var xfontlist:tfontlist;var f:tclockfaceinfo;var xoutminfontsize,xoutbackcolor,xoutfontcolor,xoutbrightness,xscrollref,xscrollref2:longint;var xscrollref64:comp;var xoutquieten:boolean):boolean;//03dec2025, 28feb2022
function low__hhmm(h,m,xtimeformat:longint):string;
function low__hhmm2(m,xtimeformat:longint):string;

//.date + alarm support procs
function low__encodealarm(xyear,xmonth,xday,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer:longint;xmsg:string;var xdata:string):boolean;
function low__decodealarm(xdata:string;var xyear,xmonth,xday,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer:longint;var xmsg:string;var xcanalarm,xchanged:boolean):boolean;
function low__decodealarmDOW(xdayOfweek:longint;var xsun,xmon,xtue,xwed,xthu,xfri,xsat:boolean):boolean;
function low__decodealarmDOW2(xdayOfweek:longint;var xsun,xmon,xtue,xwed,xthu,xfri,xsat:boolean;var xlabel:string):boolean;

//.color
function low__colsplice(x,c1,c2:longint):longint;
function low__sc1(xpert:extended;sc,dc:longint):longint;//shift color

procedure xdrawframe(const dcol,dcol2,dsize:longint32;const xframecode:tstr8;const xround:boolean);

function xdate__now:tdatetime;//override for time/chime debugging - 04dec2025

function xclockdatestr(xdate:tdatetime;xformat:longint;xfullname:boolean):string;//09mar2022
function xclockdate1(xyear,xmonth1,xday1:longint;xformat:longint;xfullname:boolean):string;
function xclockdate0(xyear,xmonth,xday:longint;xformat:longint;xfullname:boolean):string;//03sep2025


implementation


{$ifdef gui}uses gossdat;{$endif}


//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//get
if      (xname='slogan')              then result:=info__app('name')+' by Blaiz Enterprises'
else if (xname='width')               then result:='1300'
else if (xname='height')              then result:='920'
else if (xname='language')            then result:='english-australia'//for Clyde - 14sep2025
else if (xname='codepage')            then result:='1252'//for Clyde
else if (xname='msix.tags')           then result:='M'//for Clyde -> auto-enables midi support under MSIX - 10dec2025
else if (xname='ver')                 then result:='1.00.4225'
else if (xname='date')                then result:='11apr2026'
else if (xname='name')                then result:='Harmony'
else if (xname='web.name')            then result:='harmony'//used for website name
else if (xname='des')                 then result:='Digital chiming clock'
else if (xname='infoline')            then result:=info__app('name')+#32+info__app('des')+' v'+app__info('ver')+' (c) 1997-'+low__yearstr(2026)+' Blaiz Enterprises'
else if (xname='size')                then result:=low__b(io__filesize64(io__exename),true)
else if (xname='diskname')            then result:=io__extractfilename(io__exename)
else if (xname='service.name')        then result:=info__app('name')
else if (xname='service.displayname') then result:=info__app('service.name')
else if (xname='service.description') then result:=info__app('des')

//.links and values
else if (xname='linkname')            then result:=info__app('name')+' by Blaiz Enterprises.lnk'
else if (xname='linkname.vintage')    then result:=info__app('name')+' (Vintage) by Blaiz Enterprises.lnk'

//.author
else if (xname='author.shortname')    then result:='Blaiz'
else if (xname='author.name')         then result:='Blaiz Enterprises'
else if (xname='portal.name')         then result:='Blaiz Enterprises - Portal'
else if (xname='portal.tep')          then result:=intstr32(tepBE20)

//.software
else if (xname='url.software')        then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.html'
else if (xname='url.software.zip')    then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.zip'

//.urls
else if (xname='url.portal')          then result:='https://www.blaizenterprises.com'
else if (xname='url.contact')         then result:='https://www.blaizenterprises.com/contact.html'
else if (xname='url.facebook')        then result:='https://web.facebook.com/blaizenterprises'
else if (xname='url.mastodon')        then result:='https://mastodon.social/@BlaizEnterprises'
else if (xname='url.twitter')         then result:='https://twitter.com/blaizenterprise'
else if (xname='url.x')               then result:=info__app('url.twitter')
else if (xname='url.instagram')       then result:='https://www.instagram.com/blaizenterprises'
else if (xname='url.sourceforge')     then result:='https://sourceforge.net/u/blaiz2023/profile/'
else if (xname='url.github')          then result:='https://github.com/blaiz2023'

//.program/splash
else if (xname='license')             then result:='MIT License'
else if (xname='copyright')           then result:='© 1997-'+low__yearstr(2026)+' Blaiz Enterprises'
else if (xname='splash.web')          then result:='Web Portal: '+app__info('url.portal')

else
   begin
   //nil
   end;

except;end;
end;


//app procs --------------------------------------------------------------------
procedure app__create;
begin
{$ifdef gui}
iapp:=tapp.create;
{$else}

//.starting...
app__writeln('');
//app__writeln('Starting server...');

//.visible - true=live stats, false=standard console output
scn__setvisible(false);


{$endif}
end;

procedure app__remove;
begin
//reserved
end;

procedure app__destroy;
begin
try
//save
//.save app settings
app__syncandsavesettings;

//free the app
freeobj(@iapp);
except;end;
end;

procedure app__customTEP(const xindex:longint);

   procedure mc(const sm ,sc:array of byte);//mono + color
   begin

   tep__20( xindex ,sm ,sc ,it_rle8 ,it_img32 );

   end;

   procedure m(const sm:array of byte);//mono only
   begin

   tep__20( xindex ,sm ,[0] ,it_rle8 ,it_img32 );

   end;

   procedure m6(const sm:array of byte);//mono only
   begin

   tep__20( xindex ,sm ,[0] ,it_rle6 ,it_img32 );

   end;

begin

//examples:
case xindex of
tepHarmonyColPal20:m6( tep_colorpal20 );
end;//case

end;

function app__syncandsavesettings:boolean;
begin
//defaults
result:=false;
try
//.settings
{
app__ivalset('powerlevel',ipowerlevel);
app__ivalset('ramlimit',iramlimit);
{}


//.save
app__savesettings;

//successful
result:=true;
except;end;
end;

function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
begin
result:=tnetbasic.create;
end;

function app__onmessage(m:msg_message;w:msg_wparam;l:msg_lparam):msg_result;//17dec2025
begin
//defaults
result:=0;
end;

procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
begin
//nil
end;

procedure app__onpaint(sw,sh:longint);
begin
//console app only
end;

procedure app__ontimer;
begin
try

//lock check
if itimerbusy then exit else itimerbusy:=true;//prevent sync errors

//last timer - once only
if app__lasttimer then
   begin

   end;

//check
if not app__running then exit;


//first timer - once only
if app__firsttimer then
   begin

   end;

except;end;

//unlock
itimerbusy:=false;

end;


//## talarmlist ################################################################

function low__encodealarm(xyear,xmonth,xday,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer:longint;xmsg:string;var xdata:string):boolean;
begin

result:=true;//pass-thru
xdata:='';

//range
xyear     :=frcrange32(xyear,0000,9999);//4
xmonth    :=frcrange32(xmonth,0,11);//2
xday      :=frcrange32(xday,0,30);//2
xhour     :=frcrange32(xhour,0,23);//2
xminute   :=frcrange32(xminute,0,59);//2
xdayofweek:=frcrange32(xdayofweek,0,255);//3
xduration :=frcrange32(xduration,10,99999);//5 -> in seconds = 1.x days
xstyle    :=frcrange32(xstyle,0,4);//1 - 0=off, 1=Daily, 2=Day of Week, 3=Month, 4=Date
xbuzzer   :=frcrange32(xbuzzer,0,chm_buzzercount);//1
xmsg      :=strcopy1(xmsg,1,55);//N - short message

//get
xdata:='*'+low__digpad11(xyear,4)+low__digpad11(xmonth,2)+low__digpad11(xday,2)+low__digpad11(xhour,2)+low__digpad11(xminute,2)+low__digpad11(xdayofweek,3)+low__digpad11(xduration,5)+intstr32(xstyle)+low__digpad11(xbuzzer,2)+xmsg;//14nov2022

end;

function low__decodealarm(xdata:string;var xyear,xmonth,xday,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer:longint;var xmsg:string;var xcanalarm,xchanged:boolean):boolean;
begin

//defaults
result     :=true;//pass-thru
xchanged   :=false;

//get
if (strcopy1(xdata,1,1)='*') then
   begin

   if low__setint(xyear      ,frcrange32(strint32(strcopy1(xdata, 2,4)),0,9999)) then xchanged:=true;
   if low__setint(xmonth     ,frcrange32(strint32(strcopy1(xdata, 6,2)),0,11)) then xchanged:=true;
   if low__setint(xday       ,frcrange32(strint32(strcopy1(xdata, 8,2)),0,30)) then xchanged:=true;
   if low__setint(xhour      ,frcrange32(strint32(strcopy1(xdata,10,2)),0,23)) then xchanged:=true;
   if low__setint(xminute    ,frcrange32(strint32(strcopy1(xdata,12,2)),0,59)) then xchanged:=true;
   if low__setint(xdayofweek ,frcrange32(strint32(strcopy1(xdata,14,3)),0,255)) then xchanged:=true;
   if low__setint(xduration  ,frcrange32(strint32(strcopy1(xdata,17,5)),10,99999)) then xchanged:=true;//in seconds = 1.x days
   if low__setint(xstyle     ,frcrange32(strint32(strcopy1(xdata,22,1)),0,4)) then xchanged:=true;//0=off, 1=Daily, 2=Day of Week, 3=Month, 4=Date
   if low__setint(xbuzzer    ,frcrange32(strint32(strcopy1(xdata,23,2)),0,chm_buzzercount)) then xchanged:=true;//14nov2022
   if low__setstr(xmsg       ,strcopy1(xdata,25,frcmax32(low__len32(xdata),55))) then xchanged:=true;//14nov2022, short message - 13mar2022

   xcanalarm :=(xstyle>=1) and ((xbuzzer>=1) or (xmsg<>''));

   end
else
   begin

   if low__setint(xyear      ,low__year(1900)) then xchanged:=true;
   if low__setint(xmonth     ,0) then xchanged:=true;
   if low__setint(xday       ,30) then xchanged:=true;
   if low__setint(xhour      ,0) then xchanged:=true;
   if low__setint(xminute    ,0) then xchanged:=true;
   if low__setint(xdayofweek ,0) then xchanged:=true;
   if low__setint(xduration  ,60) then xchanged:=true;//1 minute - 15mar2022
   if low__setint(xstyle     ,0) then xchanged:=true;
   if low__setint(xbuzzer    ,0) then xchanged:=true;
   if low__setstr(xmsg       ,'') then xchanged:=true;

   xcanalarm  :=false;

   end;

end;

function low__decodealarmDOW(xdayOfweek:longint;var xsun,xmon,xtue,xwed,xthu,xfri,xsat:boolean):boolean;
var
   a:tint4;
begin

//defaults
result:=true;//pass-thru

//get
a.val:=frcrange32(xdayOfweek,0,255);

xsun:=(0 in a.bits);
xmon:=(1 in a.bits);
xtue:=(2 in a.bits);
xwed:=(3 in a.bits);
xthu:=(4 in a.bits);
xfri:=(5 in a.bits);
xsat:=(6 in a.bits);

end;

function low__decodealarmDOW2(xdayOfweek:longint;var xsun,xmon,xtue,xwed,xthu,xfri,xsat:boolean;var xlabel:string):boolean;
var
   a:tint4;
begin

//defaults
result:=true;//pass-thru
xlabel:='';

//get
low__decodealarmDOW(xdayOfweek,xsun,xmon,xtue,xwed,xthu,xfri,xsat);

//label
if xsun then xlabel:=xlabel+'Su';
if xmon then xlabel:=xlabel+'Mo';
if xtue then xlabel:=xlabel+'Tu';
if xwed then xlabel:=xlabel+'We';
if xthu then xlabel:=xlabel+'Th';
if xfri then xlabel:=xlabel+'Fr';
if xsat then xlabel:=xlabel+'Sa';

end;

constructor talarmlist.create;
begin

//self
inherited create;

//vars
ilastmin     :=-1;
omode        :=0;//0=alarms, 1=reminders
imax         :=high(istyle);
icount       :=imax+1;
iid          :=0;
flush;
ipos         :=0;
iplaylen     :=0;//seconds
iplayrem     :=0;//seconds

end;

destructor talarmlist.destroy;
begin
try

//clear

//controls

//self
inherited destroy;

except;end;
end;

procedure talarmlist.xresetLastmincheck;
begin

ilastmin:=-1;

end;

function talarmlist.makeAlarms:boolean;//pass-thru
begin

result :=true;
omode  :=0;

end;

function talarmlist.makeReminders:boolean;//pass-thru
begin

result :=true;
omode  :=1;

end;

function talarmlist.cancopy:boolean;
begin

result:=true;

end;

function talarmlist.canpaste:boolean;
begin

result:=clip__canpastetext;

end;

function talarmlist.pasteprompt1(xgui:tbasicsystem):boolean;//step 1 of 2
var
   l:string;
begin

l      :=iolabel;
result :=(xgui<>nil) and canpaste and xgui.popquery('Replace the currently selected '+iolabel+' with the '+l+' in Clipboard?');

end;

function talarmlist.paste2(var e:string):boolean;//step 2 of 2
begin

result :=false;
e      :=gecTaskfailed;
one    :=clip__pastetextb;
result :=true;

end;

function talarmlist.iolabel:string;
begin

case omode of
0    :result:='Alarm';
1    :result:='Reminder';
else  result:='Alarm';
end;//case

end;

function talarmlist.ioheader:string;
begin

case omode of
0    :result:='[alarms]';
1    :result:='[reminders]';
else  result:='[alarms]';
end;//case

end;

function talarmlist.ioext:string;
begin

case omode of
0    :result:=peAlarms;
1    :result:=peReminders;
else  result:=peAlarms;
end;//case

end;

function talarmlist.saveas(xgui:tbasicsystem;var xlastfilename:string;xprompt:boolean;var e:string):boolean;
label
   skipend;
var
   a:tstr8;
   daction,h:string;
begin
try

//defaults
result :=false;
e      :=gecTaskfailed;
a      :=nil;
h      :=ioheader;
daction:='';

//prompt
if xprompt then
   begin

   //check
   if     (xgui=nil)                                                       then goto skipend;

   //prompt
   if not xgui.popsave(xlastfilename,ioext,app__subfolder('misc'),daction) then
      begin

      result:=true;
      goto skipend;

      end;

   end;

//get
a      :=str__new8;
a.text :=h+#10+text;
if not io__tofile(xlastfilename,@a,e) then goto skipend;

//successful
result :=true;
skipend:

except;end;

//free
str__free(@a);

end;

function talarmlist.open(xgui:tbasicsystem;var xlastfilename:string;var xlastfilterindex:longint;xprompt:boolean;var e:string):boolean;
label
   skipend;
var
   a:tstr8;
   h:string;
begin
try

//defaults
result :=false;
e      :=gecTaskfailed;
a      :=nil;
h      :=ioheader;

//prompt
if xprompt then
   begin

   //check
   if     (xgui=nil)                                                                then goto skipend;

   //prompt
   if not xgui.popopen(xlastfilename,xlastfilterindex,ioext,app__subfolder('misc')) then
      begin

      result:=true;
      goto skipend;

      end;

   end;

//get
a      :=str__new8;
if not io__fromfile(xlastfilename,@a,e) then goto skipend;

if not strmatch(strcopy1(a.text,1,low__len32(h)),h) then
   begin

   e:=gecUnknownformat;
   goto skipend;

   end;

//set
text   :=a.text;

//successful
result:=true;
skipend:

except;end;

//free
str__free(@a);

end;

procedure talarmlist.stopactive;
var
   p:longint;
begin

for p:=0 to imax do if (ifrom64[p]<>0) then ifrom64[p]:=0;

end;

function talarmlist.findactive(xdate:tdatetime;var xindex,xtotalsecs,xremsecs,xbuzzer:longint;var xmsg:string;var xhavebuzzer,xhavemsg:boolean):boolean;
begin

//defaults
result      :=false;
xindex      :=0;
xtotalsecs  :=0;//30nov2025
xremsecs    :=0;
xbuzzer     :=0;
xmsg        :='';
xhavebuzzer :=false;
xhavemsg    :=false;

//get
case omode of
0   :result:=findalarm(xdate,xindex,xtotalsecs,xremsecs,xbuzzer,xmsg,xhavebuzzer,xhavemsg);
else result:=findreminder(xdate,xindex,xmsg,xhavemsg);
end;//case

end;

function talarmlist.findalarm(xdate:tdatetime;var xindex,xtotalsecs,xremsecs,xbuzzer:longint;var xmsg:string;var xhavebuzzer,xhavemsg:boolean):boolean;//04dec2025
var
   y1,m1,d1:word;
   hr,min,sec,ms:word;
   xnowmin,m0,d0,di,p,xdow:longint;
   xlastfrom64,x64:comp;
   bol1:boolean;

   function xdowOK(xindex:longint):boolean;
   var
      v:longint;
      xsun,xmon,xtue,xwed,xthu,xfri,xsat:boolean;
   begin

   result:=false;

   low__decodealarmDOW(idayOfweek[xindex],xsun,xmon,xtue,xwed,xthu,xfri,xsat);

   if ((xdow=0) and xsun) or ((xdow=1) and xmon) or ((xdow=2) and xtue) or ((xdow=3) and xwed) or ((xdow=4) and xthu) or ((xdow=5) and xfri) or ((xdow=6) and xsat) then result:=true;

   end;

   function xto64(xpos:longint):comp;
   begin

   result:=0;

   if (ifrom64[xpos]>=1) then result:=add64(ifrom64[xpos],iduration[xpos]*1000);

   end;

   function xhave:boolean;
   begin

   result:=((ibuzzer[p]>=1) or (imsg[p]<>''));

   if (ibuzzer[p]>=1) then xhavebuzzer :=true;//any buzzer on any alarm
   if (imsg[p]<>'')   then xhavemsg    :=true;//sames as buzzer above

   end;

begin

//defaults
result      :=false;
xindex      :=0;
xtotalsecs  :=0;//30nov2025
xremsecs    :=0;
xbuzzer     :=0;
xmsg        :='';
xhavebuzzer :=false;
xhavemsg    :=false;
di          :=-1;
x64         :=frcmin64(ms64,2);//0 and 1 reserved for special purposes - 09mar2022
xlastfrom64 :=0;

//check
if (omode<>0) then exit;//invalid - for alarm modes only - 09mar2022

//init
low__decodedate2(xdate,y1,m1,d1);

m0          :=m1-1;
d0          :=d1-1;

low__decodetime2(xdate,hr,min,sec,ms);

xdow        :=low__dayofweek0(xdate);
xnowmin     :=nowmin2(xdate);//04dec2025

//activate alarm -> check ONLY once per minute
if low__setint(ilastmin,xnowmin) then
   begin

   for p:=0 to imax do
   begin

   //get
   case istyle[p] of
   1    :bol1:=xhave and (hr=ihour[p]) and (min=iminute[p]);//daily
   2    :bol1:=xhave and (hr=ihour[p]) and (min=iminute[p]) and xdowOK(p);//week
   3    :bol1:=xhave and (hr=ihour[p]) and (min=iminute[p]) and (m0=imonth[p]) and (d0=xdayFiltered(p));//month
   4    :bol1:=xhave and (hr=ihour[p]) and (min=iminute[p]) and (y1=iyear[p]) and (m0=imonth[p]) and (d0=xdayFiltered(p));//date
   else  bol1:=false;
   end;//case

   //set
   if bol1 and (ifrom64[p]=0) then ifrom64[p]:=x64;//start

   end;//p

   end;

//stop alarm -> always check
for p:=0 to imax do
begin

if (istyle[p]>=1)                      then xhave;
if (ifrom64[p]<>0) and (x64>=xto64(p)) then ifrom64[p]:=0;//turn off the alarm - 13mar2022

end;//p

//find most recently STARTED alarm with the HIGHEST priority - 09mar2022

//.daily - lowest priority
for p:=0 to imax do if (istyle[p]=1) and (ifrom64[p]>=1) and (x64>=ifrom64[p]) and (x64<xto64(p)) and (ifrom64[p]>=xlastfrom64) then
   begin

   xlastfrom64 :=ifrom64[p];
   di          :=p;

   end;//p

//.week
for p:=0 to imax do if (istyle[p]=2) and (ifrom64[p]>=1) and (x64>=ifrom64[p]) and (x64<xto64(p)) and (ifrom64[p]>=xlastfrom64) then
   begin

   xlastfrom64 :=ifrom64[p];
   di          :=p;

   end;//p

//.month
for p:=0 to imax do if (istyle[p]=3) and (ifrom64[p]>=1) and (x64>=ifrom64[p]) and (x64<xto64(p)) and (ifrom64[p]>=xlastfrom64) then
   begin

   xlastfrom64 :=ifrom64[p];
   di          :=p;

   end;//p

//.date
for p:=0 to imax do if (istyle[p]=4) and (ifrom64[p]>=1) and (x64>=ifrom64[p]) and (x64<xto64(p)) and (ifrom64[p]>=xlastfrom64) then
   begin

   xlastfrom64 :=ifrom64[p];
   di          :=p;

   end;//p

//get
if (di>=0) and (di<=imax) and (istyle[di]>=1) then
   begin

   xindex     :=di;
   xtotalsecs :=frcmin32(iduration[di],0);//30nov2025
   xremsecs   :=restrict32(frcmin64(div64(sub64(xto64(di),x64),1000),0));
   xbuzzer    :=ibuzzer[di];
   xmsg       :=imsg[di];
   result     :=true;

   end;

//internal copy for "xbuzzerpert0100" - 30nov2025
iplaylen  :=xtotalsecs;
iplayrem  :=xremsecs;

end;

function talarmlist.findreminder(xdate:tdatetime;var xindex:longint;var xmsg:string;var xhavemsg:boolean):boolean;//09mar2022
var
   y1,m1,d1:word;
   m0,d0,di,p,xdow:longint;

   function xdowOK(xindex:longint):boolean;
   var
      v:longint;
      xsun,xmon,xtue,xwed,xthu,xfri,xsat:boolean;
   begin

   result:=false;

   low__decodealarmDOW(idayOfweek[xindex],xsun,xmon,xtue,xwed,xthu,xfri,xsat);
   if ((xdow=0) and xsun) or ((xdow=1) and xmon) or ((xdow=2) and xtue) or ((xdow=3) and xwed) or ((xdow=4) and xthu) or ((xdow=5) and xfri) or ((xdow=6) and xsat) then result:=true;

   end;

   function xhave:boolean;
   begin

   result:=(imsg[p]<>'');
   if result then xhavemsg:=true;

   end;

begin

//defaults
result     :=false;
xindex     :=0;
xmsg       :='';
xhavemsg   :=false;
di         :=-1;

//check
if (omode<>1) then exit;//reminder mode only - 09mar2022

//init
low__decodedate2(xdate,y1,m1,d1);

m0         :=m1-1;
d0         :=d1-1;
xdow       :=low__dayofweek0(xdate);

//find most recently STARTED alarm with the HIGHEST priority - 09mar2022

//.daily - lowest priority
for p:=0 to imax do if (istyle[p]=1) and xhave then di:=p;

//.week
for p:=0 to imax do if (istyle[p]=2) and xhave and xdowOK(p) then di:=p;

//.month
for p:=0 to imax do if (istyle[p]=3) and xhave and (m0=imonth[p]) and (d0=xdayFiltered(p)) then di:=p;

//.date - highest priority
for p:=0 to imax do if (istyle[p]=4) and xhave and (y1=iyear[p]) and (m0=imonth[p]) and (d0=xdayFiltered(p)) then di:=p;

//get
if (di>=0) and (di<=imax) and (istyle[di]>=1) then
   begin

   xindex  :=di;
   xmsg    :=imsg[di];
   result  :=true;

   end;

end;

function talarmlist.xsafepos(x:longint):longint;
begin

result:=frcrange32(x,0,imax);

end;

function talarmlist.finditem(xpos:longint;var xyear,xmonth,xday,adayFiltered,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer:longint;var xmsg:string):boolean;
begin

//defaults
result       :=true;//pass-thru

//range
xpos         :=xsafepos(xpos);

//get
xyear        :=iyear[xpos];
xmonth       :=imonth[xpos];
xday         :=iday[xpos];
adayFiltered :=xdayFiltered(xpos);//09mar2022
xhour        :=ihour[xpos];
xminute      :=iminute[xpos];
xdayOfweek   :=idayOfweek[xpos];
xduration    :=iduration[xpos];
xstyle       :=istyle[xpos];
xbuzzer      :=ibuzzer[xpos];
xmsg         :=imsg[xpos];

end;

procedure talarmlist.settext(x:string);
label
   skipdone;
var
   s,d:tstr8;
   i,c,xlen,p,lp:longint;
   e,v:string;
   bol1,xmustid,xchanged:boolean;
begin
try

//defaults
xmustid :=false;
i       :=0;//must set here
s       :=nil;
d       :=nil;

//init
xlen    :=low__len32(x);
if (xlen<=0) then goto skipdone;
x       :=x+#10;//enforce trailing return code

//base64
if strmatch(strcopy1(x,1,4),'b64:') then
   begin

   s:=str__new8;
   d:=str__new8;
   s.text:=x;

   if not low__fromb641(s,d,5,e) then goto skipdone;

   x:=d.text;
   xlen:=low__len32(x);

   if (xlen<=0) then goto skipdone;

   str__free(@s);
   str__free(@d);

   end;

//get
lp:=1;

for p:=1 to xlen do
begin

c:=ord(x[p-1+stroffset]);
if (c=10) or (c=13) then
   begin

   //v
   v:=strcopy1(x,lp,p-lp);

   if (strcopy1(v,1,1)='*') then
      begin

      low__decodealarm(v,iyear[i],imonth[i],iday[i],ihour[i],iminute[i],idayofweek[i],iduration[i],istyle[i],ibuzzer[i],imsg[i],bol1,xchanged);

      if xchanged then
         begin

         xresetactive(i);
         xmustid:=true;

         end;

      inc(i);
      if (i>imax) then break;//at capacity

      end;

   //reset
   lp:=p+1;

   end;

end;//p

skipdone:

//clear remaining items
if (i<=imax) then
   begin

   for p:=i to imax do xflushone(p);
   xmustid:=true;

   end;

if xmustid then xincid;
except;end;

//free
str__free(@s);
str__free(@d);

end;

function talarmlist.getone:string;
var
   i:longint;
begin

//defaults
result :='*';
i      :=xsafepos(ipos);

//get
low__encodealarm(iyear[i],imonth[i],iday[i],ihour[i],iminute[i],idayofweek[i],iduration[i],istyle[i],ibuzzer[i],imsg[i],result);

end;

procedure talarmlist.setone(xdata:string);
var
   i:longint;
   bol1,xchanged:boolean;
begin

//check
if (strcopy1(xdata,1,1)<>'*') then exit;

//range
i:=xsafepos(ipos);

//get
low__decodealarm(xdata,iyear[i],imonth[i],iday[i],ihour[i],iminute[i],idayofweek[i],iduration[i],istyle[i],ibuzzer[i],imsg[i],bol1,xchanged);

if xchanged then
   begin

   xresetactive(i);
   xincid;

   end;

end;

procedure talarmlist.xresetactive(xpos:longint);
begin

ifrom64[xsafepos(xpos)]:=0;

end;

function talarmlist._gettext(xb64:boolean):string;
var
   a,b:tstr8;
   i:longint;
   v,e:string;
begin
try

//defaults
result :='';
a      :=nil;
b      :=nil;

//get
a      :=str__new8;
for i:=0 to imax do if low__encodealarm(iyear[i],imonth[i],iday[i],ihour[i],iminute[i],idayofweek[i],iduration[i],istyle[i],ibuzzer[i],imsg[i],v) then a.sadd(v+#10);

//set
if (a.len>=1) then
   begin

   if xb64 then
      begin

      b:=str__new8;
      low__tob64(a,b,0,e);
      result:='b64:'+b.text;

      end
   else result:=a.text;
   end;
except;end;

//free
str__free(@a);
str__free(@b);

end;

function talarmlist.gettext:string;
begin

result:=_gettext(false);

end;

function talarmlist.gettext64:string;
begin

result:=_gettext(true);

end;

procedure talarmlist.setpos(x:longint);
begin

ipos:=xsafepos(x);

end;

function talarmlist.xincid:boolean;//pass-thru
begin

result:=true;
low__iroll(iid,1);

end;

procedure talarmlist.setyear(x:longint);
begin

if low__setint(iyear[ipos],frcrange32(x,0,9999)) then
   begin

   xresetactive(ipos);
   xincid;

   end;

end;

function talarmlist.getyear:longint;
begin

result:=iyear[ipos];

end;

procedure talarmlist.setmonth(x:longint);
begin

if low__setint(imonth[ipos],frcrange32(x,0,11)) then
   begin

   xresetactive(ipos);
   xincid;

   end;

end;

function talarmlist.getmonth:longint;
begin

result:=imonth[ipos];

end;

procedure talarmlist.setday(x:longint);
begin

if low__setint(iday[ipos],frcrange32(x,0,30)) then
   begin

   xresetactive(ipos);
   xincid;

   end;

end;

function talarmlist.getday:longint;
begin

result:=iday[ipos];

end;

function talarmlist.getdayFiltered:longint;
begin

result:=xdayFiltered(ipos);

end;

function talarmlist.xdayFiltered(xpos:longint):longint;
begin

//range
xpos   :=xsafepos(xpos);

//init
result :=iday[xpos];

//get
case istyle[xpos] of
3:result:=low__monthdayfilter0(result,imonth[xpos],low__year(1900));
4:result:=low__monthdayfilter0(result,imonth[xpos],iyear[xpos]);
else
   begin
   //nil
   end;

end;//case

end;

procedure talarmlist.sethour(x:longint);//24 hour time -> hour=0..23
begin

if low__setint(ihour[ipos],frcrange32(x,0,23)) then
   begin

   xresetactive(ipos);
   xincid;

   end;

end;

function talarmlist.gethour:longint;
begin

result:=ihour[ipos];

end;

procedure talarmlist.setminute(x:longint);//minute=0..59
begin

if low__setint(iminute[ipos],frcrange32(x,0,59)) then
   begin

   xresetactive(ipos);
   xincid;

   end;

end;

function talarmlist.getminute:longint;
begin

result:=iminute[ipos];

end;

procedure talarmlist.setdayOfweek(x:longint);
begin

if low__setint(idayOfweek[ipos],frcrange32(x,0,255)) then
   begin

   xresetactive(ipos);
   xincid;

   end;

end;

function talarmlist.getdayOfweek:longint;
begin

result:=idayOfweek[ipos];

end;

procedure talarmlist.setduration(x:longint);
begin

if low__setint(iduration[ipos],frcrange32(x,10,99999)) then xincid;

end;

function talarmlist.getduration:longint;
begin

result:=iduration[ipos];

end;

procedure talarmlist.setstyle(x:longint);
begin

if low__setint(istyle[ipos],frcrange32(x,0,4)) then
   begin

   xresetactive(ipos);
   xincid;

   end;

end;

function talarmlist.getstyle:longint;
begin

result:=istyle[ipos];

end;

procedure talarmlist.setbuzzer(x:longint);
begin

if low__setint(ibuzzer[ipos],frcrange32(x,0,chm_buzzercount)) then xincid;

end;

function talarmlist.getbuzzer:longint;
begin

result:=ibuzzer[ipos];

end;

procedure talarmlist.setmsg(x:string);
begin

if low__setstr(imsg[ipos],strcopy1(x,1,100)) then xincid;

end;

function talarmlist.getmsg:string;
begin

result:=strcopy1(imsg[ipos],1,100);

end;

procedure talarmlist.flush;
begin

xflush;
xincid;

end;

procedure talarmlist.xflush;
var
   p:longint;
begin

for p:=0 to imax do xflushone(p);

end;

procedure talarmlist.xflushone(x:longint);//03dec2025
begin

//range
x             :=frcrange32(x,0,imax);

//get
iyear[x]      :=low__year(1900);
imonth[x]     :=0;//jan
iday[x]       :=30;//31st for Dyani "DJ" the Brave Spirit - 09mar2022
ihour[x]      :=0;
iminute[x]    :=0;
idayOfweek[x] :=0;
iduration[x]  :=60;//1 minute - 15mar2022
istyle[x]     :=0;
ibuzzer[x]    :=0;
ifrom64[x]    :=0;//off
imsg[x]       :='';

end;

procedure talarmlist.clearone;
begin

xflushone(ipos);
xincid;

end;

//## tbasicalarmlist ###########################################################
constructor tbasicalarmlist.create2(xparent:tobject;xscroll,xstart:boolean);
var
   xhost:tbasiccontrol;
   xtmp:tbasiccontrol;
   p:longint;
   xcolorise:boolean;
   dhelp:string;

   function dint3(xlabel,xname,xhelp:string;xmin,xmax,xdef:longint;xvalname:string):tsimpleint;
   begin

   if zznil(xhost,2291) then exit;
   result:=xhost.mint3(xlabel,xhelp,xmin,xmax,xdef,0,'',xvalname);
   result.tagstr:=xname;

   end;

   function dint3b(var xout:tsimpleint;xlabel,xname,xhelp:string;xmin,xmax,xdef:longint;xvalname:string):tsimpleint;
   begin

   result:=dint3(xlabel,xname,xhelp,xmin,xmax,xdef,xvalname);
   xout:=result;

   end;

   function dset(xlabel,xname,xhelp:string;xdef:longint):tbasicset;
   begin

   if zznil(xhost,2292) then exit;
   result:=xhost.nset(xlabel,xhelp,xdef,0);
   result.tagstr:=xname;

   end;

   function dsel3(xlabel,xname,xhelp:string;xdef:longint;xvalname:string):tbasicsel;
   begin

   if zznil(xhost,2293) then exit;
   result:=xhost.nsel3(xlabel,xhelp,xdef,xvalname);
   result.tagstr:=xname;

   end;

begin

//tbasicalarmlist
inherited create2(xparent,false,false);//force "xscroll=false" - fixed 02aug2021

//Important Note: This options sizes the columns vertically as expected with ZERO complication - 07mar2022
oautoheight            :=true;//resizable
xcolsh.ofillheight     :=true;//use all client height if available
xcolorise              :=true;//false;
ocanshowmenu           :=true;
osynchead_alarmbuttonbyname :='';
bordersize             :=0;//04dec2025

//options
odateformat            :=0;
otimeformat            :=1;
omode                  :=0;//0=alarms, 1=reminders

//vars
icore                  :=talarmlist.create;//data handler
ilastref               :='';
ilastref2              :='';
ilastref3              :='';
ilastref4              :='';
ilastref5              :='';
itimer250              :=ms64;
iplayingbuzzerREF64    :=ms64;
iplayingbuzzerLEN      :=30000;//30 seconds
ilastfilterindex       :=0;
ilastfilename          :=io__windrive+'Untitled.'+feAlarms;
imustplay              :=0;//off

//controls

//.toolbar
xtoolbar.maketitle('Alarms');
xtoolbar.add('Copy',tepCopy20,0,'copy','');
xtoolbar.add('Paste',tepPaste20,0,'paste','');
xtoolbar.add('Open',tepOpen20,0,'open','');
xtoolbar.add('Save As',tepSave20,0,'saveas','');


//col 0 ------------------------------------------------------------------------
with xcolsh.cols2[0,45,false] do
begin

xhost                  :=client;

ilist                  :=nlistx('','Select item to edit',icore.count,0,nil);
ilist.ongetitem        :=xlistitem;
ilist.itemindex        :=0;

end;

//col 1 ------------------------------------------------------------------------
with xcolsh.cols2[1,60,true] do
begin

xhost                  :=client;

//.style
istyle                 :=dsel3('Style','style','Select alarm style',0,'');
istyle.osepv           :=def_vsep;//30nov2025

if xcolorise then istyle.ospbackname:='blue';

istyle.xadd('Off','0','');
istyle.xadd('Daily','1','');
istyle.xadd('Week','2','');
istyle.xadd('Month','3','');
istyle.xadd('Date','4','');


//.message
imsg                   :=nedit('<Type a short message>','Type a short message to display on-screen when activated');
imsg.osepv             :=def_vsep;
imsg.title             :='Clock Face Message';
imsg.olimit            :=55;//55c

if xcolorise then imsg.ospbackname:='yellow';


//.year
iyear                  :=nedit('','Select year');
iyear.makedrop;//drop down list
iyear.osepv            :=def_vsep;
iyear.title            :='Year';

if xcolorise then iyear.ospbackname:='orange';


//.month
imonth                 :=dsel3('Month','month','Select month',0,'');
imonth.osepv           :=def_vsep;

if xcolorise then imonth.ospbackname:='yellow';
imonth.itemsperline    :=6;

for p:=low(system_month_abrv) to high(system_month_abrv) do
begin

imonth.xadd(system_month_abrv[p],intstr32(p-1),'');

end;//p


//.day
iday                   :=dsel3('Day','day','Select day',0,'');
iday.osepv             :=def_vsep;

if xcolorise then iday.ospbackname:='green';

iday.itemsperline      :=7;

for p:=0 to 30 do
begin

iday.xadd(intstr32(p+1),intstr32(p),'');

end;//p


//.day-of-week
idow                   :=dset('Day of Week','dow','Select day(s) of week',0);
idow.osepv             :=def_vsep;

if xcolorise then idow.ospbackname:='green';

idow.itemsperline      :=4;

with idow do
begin

 for p:=low(system_dayOfweek_abrv) to high(system_dayOfweek_abrv) do
 begin
 xset3(p-1,system_dayOfweek_abrv[p],'d:'+intstr32(p-1),'Select day',false,'');
 end;//p

end;


//.hour
ihour                  :=dint3('Hour','hour','Select hour',0,23,0,'');
ihour.osepv            :=def_vsep;

if xcolorise then ihour.ospbackname:='purple';


//.minute
iminute                :=dint3('Minute','minute','Select minute',0,59,0,'');
iminute.osepv          :=def_vsep;

if xcolorise then iminute.ospbackname:='purple';


//.duration
idur                   :=dint3('Duration','dur','Set message display / audio alert duration',1,720,30,'');//2hr max in increments of 10seconds
idur.osepv             :=def_vsep;

if xcolorise then idur.ospbackname:='purple';


//.ibuzlist
dhelp                  :='Alarm Buzzer|Select an alarm buzzer from the list to set as the alarm audio.  Click "Play Sample" to hear a sample.  Select the "None" option for a silent alarm (no audio).';
ibuzbar                :=ntitlebar(false,'Alarm Buzzers',dhelp);
ibuzbar.osepv          :=def_vsep;;

ibuzbar.add('Stop',tepStop20,0,'buzzer.stop','Alarm Buzzer|Stop sample playback');
ibuzbar.add('Play Sample',tepPlay20,0,'buzzer.play','Alarm Buzzer|Start or stop sample playback');

ibuzlist               :=nlistx('',dhelp,chm_buzzercount+1,frcmax32(8,chm_buzzercount),_onbuzlistitem);
ibuzlist.onumberfrom   :=0;
end;

//events
xtoolbar.onclick       :=____onclick;
ibuzbar.onclick        :=____onclick;
iyear.onclick2         :=____onclick;
ihour.onfindlabel      :=_onvalcap;
iminute.onfindlabel    :=_onvalcap;
idur.onfindlabel       :=_onvalcap;

//help
xsynchelp;

//start
if xstart then start;//02aug2021

end;

destructor tbasicalarmlist.destroy;
begin
try

//controls
freeobj(@icore);

//self
inherited destroy;

except;end;
end;

procedure tbasicalarmlist.xsynchelp;//04dec2025
var
   xtitle,xname:string;
begin

xtitle                    :=low__aorbstr('Reminder','Alarm',omode=0)+'|';
xname                     :=low__aorbstr('reminder','alarm',omode=0);
xtoolbar.bhelp2['copy']   :=xtitle+'Copy '+xname+' to Clipboard';
xtoolbar.bhelp2['paste']  :=xtitle+'Paste '+xname+' from Clipboard';
xtoolbar.bhelp2['open']   :=xtitle+'Open '+xname+'s from file';
xtoolbar.bhelp2['saveas'] :=xtitle+'Save '+xname+'s to file';

end;

procedure tbasicalarmlist.test__alarmnow;
var
   xhour,xmin,xsec,xmsec:word;
begin

if (omode=0) then
   begin

   date__decodetime(xdate__now,xhour,xmin,xsec,xmsec);

   icore.pos       :=0;
   icore.style     :=1;
   icore.hour      :=xhour;
   icore.minute    :=xmin;
   icore.duration  :=125;//2m05s
   icore.buzzer    :=2;
   icore.msg       :='Test Alarm';

   xmustfromgui;//clear
   xtogui;

   icore.xresetLastmincheck;

   end;

end;

function tbasicalarmlist._onbuzlistitem(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
begin

xcaption   :=chm_buzzerlabel(xindex);
xcaplabel  :=xcaption;
xtep       :=low__aorb(tepBlank20,tepMid20,xindex>=1);

end;

function tbasicalarmlist.makeAlarms:boolean;//pass-thru
begin

result               :=true;
omode                :=0;
icore.makeAlarms;
xtoolbar.caption     :='Alarms';
xsynchelp;//04dec2025

end;

function tbasicalarmlist.makeReminders:boolean;//pass-thru
begin

result               :=true;
omode                :=1;
icore.makeReminders;
xtoolbar.caption     :='Reminders';
xsynchelp;//04dec2025

end;

procedure tbasicalarmlist._onvalcap(sender:tobject;var xval:string);
var
   v,h,m,s:longint;
begin

if      (sender=ihour)     then xval:='Hour '+low__hour0(ihour.val,'',otimeformat=1,true,otimeformat=0)
else if (sender=iminute)   then xval:='Minute '+intstr32(iminute.val)
else if (sender=idur)      then
   begin

   //init
   v:=idur.val*10;//blocks of 10 seconds -> seconds

   //.h
   h:=v div 3600;
   v:=frcmin32(v-(h*3600),0);

   //.m
   m:=v div 60;
   v:=frcmin32(v-(m*60),0);

   //.s
   s:=v;

   //get
   xval:='Duration '+insstr(intstr32(h)+'h ',h>=1)+insstr(low__digpad11(m,2)+'m ',(h>=1) or (m>=1))+low__digpad11(s,2)+'s';

   end;

end;

function tbasicalarmlist.gettext:string;
begin

if xmustfromgui then xfromgui;
result:=icore.text;

end;

function tbasicalarmlist.gettext64:string;
begin

if xmustfromgui then xfromgui;
result:=icore.text64;

end;

procedure tbasicalarmlist.settext(x:string);
begin
try

if xmustfromgui then xfromgui;
icore.text :=x;
icore.pos  :=pos;

except;end;
end;

function tbasicalarmlist.xmustfromgui:boolean;
begin

result:=low__setstr(ilastref2,

 intstr32(imonth.val)+'|'+
 intstr32(iday.val)+'|'+
 intstr32(ihour.val)+'|'+
 intstr32(iminute.val)+'|'+
 intstr32(idow.val)+'|'+
 intstr32(idur.val)+'|'+
 intstr32(istyle.val)+'|'+
 intstr32(ibuzlist.itemindex)+'|'+
 iyear.value+#1+
 imsg.value+

 '');

end;

function tbasicalarmlist.getpos:longint;
begin

result:=frcrange32(ilist.itemindex,0,icore.count-1);

end;

procedure tbasicalarmlist.setpos(x:longint);
begin

x:=frcrange32(x,0,icore.count-1);

if (x<>ilist.itemindex) then
   begin

   if xmustfromgui then xfromgui;
   ilist.itemindex:=x;

   end;

end;

function tbasicalarmlist.xtogui:boolean;//pass-thru
begin

result               :=true;

if xmustfromgui then xfromgui;

imonth.val           :=icore.month;
iday.val             :=icore.day;
iminute.val          :=icore.minute;
ihour.val            :=icore.hour;
idow.val             :=icore.dayOfweek;
idur.val             :=icore.duration div 10;
ibuzlist.itemindex   :=icore.buzzer;//14nov2022
istyle.val           :=icore.style;
iyear.value          :=intstr32(icore.year);
imsg.value           :=icore.msg;

end;

function tbasicalarmlist.xfromgui:boolean;//pass-thru
begin

result           :=true;

icore.month      :=imonth.val;
icore.minute     :=iminute.val;
icore.hour       :=ihour.val;
icore.day        :=iday.val;
icore.dayOfweek  :=idow.val;
icore.buzzer     :=ibuzlist.itemindex;
icore.duration   :=idur.val*10;
icore.style      :=istyle.val;
icore.year       :=strint32(strdefb(iyear.value,low__yearstr(0)));
icore.msg        :=imsg.value;

xmustfromgui;

end;

function tbasicalarmlist.xlistitem(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
var
   xyear,xmonth,xday,xdayFiltered,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer:longint;
   n,xdow,asep,xtime,xmsg:string;
   xsun,xmon,xtue,xwed,xthu,xfri,xsat:boolean;
begin

//defaults
result :=false;

//get
if (sender=ilist) then
   begin

   //init
   asep     :=' .. ';
   xindex   :=frcrange32(xindex,0,icore.count-1);
   n        :=intstr32(xindex+1)+'.  ';

   case omode of
   0    :xtep:=tepClock20;//alarm
   1    :xtep:=tepAlert20;//reminder
   else  xtep:=tepClock20;//other
   end;//case

   icore.finditem(xindex,xyear,xmonth,xday,xdayFiltered,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer,xmsg);

   case omode of
   0    :xtime:=low__time0(xhour,xminute,'','',otimeformat=1,otimeformat=0)+asep;
   else  xtime:='';
   end;//case

   low__decodealarmDOW2(xdayofweek,xsun,xmon,xtue,xwed,xthu,xfri,xsat,xdow);

   //get
   if (xstyle>=1) and (xmsg='') and (xbuzzer=0) then
      begin

      case omode of
      0   :xcaption:='< Set Message / Audio Alert>';
      else xcaption:='< Set Message >';
      end;//case

      end
   else
      begin

      case xstyle of
      1    :xcaption:=n+xtime+'Daily';
      2    :xcaption:=n+xtime+strdefb(xdow,'< Select a Day >');
      3    :xcaption:=n+xtime+low__date0(-1,xmonth,xdayFiltered,odateformat,false);
      4    :xcaption:=n+xtime+low__date0(xyear,xmonth,xdayFiltered,odateformat,false);
      else  xcaption:=n+low__aorbstr('< Not Set >','< Off >',(xbuzzer>=1) or (xmsg<>''))
      end;//case

      end;
   end;

end;

procedure tbasicalarmlist.showmenuFill(xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
var
   int1,p:longint;
begin

//check
if zznil(xmenudata,2318) then exit;
xmenuname:='alarmlist.'+xstyle;

//get
if (xstyle='year') then
   begin

   low__menutitle(xmenudata,tepnone,'Year','');

   int1:=low__year(1900);

   for p:=int1 to (int1+10) do low__menuitem2(xmenudata,tep__tick(false),intstr32(p),'Select year '+intstr32(p),'y:'+intstr32(p),100,aknone,true);

   end;

end;

function tbasicalarmlist.showmenuClick(sender:tobject;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
begin

result:=(strcopy1(xcode2,1,2)='y:');//handled
if result then iyear.value:=strcopy1(xcode2,3,low__len32(xcode2));

end;

procedure tbasicalarmlist._ontimer(sender:tobject);
var
   p,xmode,xdaylimit,xstyle:longint;
   xfull,bol1:boolean;
   dpert:extended;

   procedure xshowhide(x:tbasiccontrol;xvisible:boolean);
   begin

   if (x<>nil) and (x.visible<>xvisible) then
      begin
      xfull:=true;
      x.visible:=xvisible;
      end;

   end;

   procedure xhide(x:tbasiccontrol);
   begin
   xshowhide(x,false);
   end;

   procedure xshow(x:tbasiccontrol);
   begin
   xshowhide(x,true);
   end;

   procedure xshowhideday(xday:longint;xshow:boolean);
   begin

   if xshow then
      begin

      if (iday.caps[xday]='-') then
         begin
         iday.caps[xday]:=intstr32(xday+1);
         xfull:=true;

         end;
      end
   else
      begin

      if (iday.caps[xday]<>'-') then
         begin
         iday.caps[xday]:='-';
         xfull:=true;
         end;

      end;

   end;

begin

//self
inherited _ontimer(sender);

//.timer250
if (slowms64>=itimer250) then
   begin

   //get
   if xmustfromgui then xfromgui;

   if low__setstr(ilastref,intstr32(pos)) then
      begin
      icore.pos:=pos;
      xtogui;
      end;

   if low__setstr(ilastref3,intstr32(otimeformat)) then
      begin
      ihour.paintnow;
      end;

   if low__setstr(ilastref4,intstr32(omode)+'|'+intstr32(icore.id)+'|'+intstr32(pos)) then
      begin
      ilist.paintnow;
      end;

   if low__setstr(ilastref5,intstr32(omode)+'|'+intstr32(icore.style)+'|'+intstr32(pos)+'|'+intstr32(icore.id)) then
      begin

      xmode   :=omode;
      xstyle  :=icore.style;
      bol1    :=(xstyle>=1) and (xstyle<=4);

      case xstyle of
      1:begin//daily

         xhide(iyear);
         xhide(imonth);
         xhide(iday);
         xhide(idow);

         end;

      2:begin//days (dayOfweek)

         xhide(iyear);
         xhide(imonth);
         xhide(iday);
         xshow(idow);

         end;

      3:begin//month

         xhide(iyear);
         xshow(imonth);
         xshow(iday);
         xhide(idow);

         end;

      4:begin//date

         xshow(iyear);
         xshow(imonth);
         xshow(iday);
         xhide(idow);

         end;

      else
         begin

         xhide(iyear);
         xhide(imonth);
         xhide(iday);
         xhide(idow);

         end;

      end;//case

      //reminders don't have TIME or BUZZERS
      xshowhide(ihour    ,bol1 and (xmode=0));
      xshowhide(iminute  ,bol1 and (xmode=0));
      xshowhide(idur     ,bol1 and (xmode=0));
      xshowhide(ibuzbar  ,bol1 and (xmode=0));
      xshowhide(ibuzlist ,bol1 and (xmode=0));
      xshowhide(imsg     ,bol1);

      //sync
      if iday.visible then
         begin

         xdaylimit:=low__monthdaycount0(icore.month,icore.year);
         for p:=28 to 30 do xshowhideday(p,p<xdaylimit);

         end;

      if xfull then gui.fullalignpaint;

      end;

   //buttons
   xtoolbar.benabled2['copy']         :=true;
   xtoolbar.benabled2['paste']        :=clip__canpastetext;

   //.alarms support
   bol1                               :=(omode=0);
   ibuzbar.bvisible2['buzzer.stop']   :=bol1;
   ibuzbar.bvisible2['buzzer.play']   :=bol1;
   ibuzbar.benabled2['buzzer.stop']   :=bol1 and canstopbuzzer;
   ibuzbar.benabled2['buzzer.play']   :=bol1 and (canplaybuzzer or canstopbuzzer);

   //.buzzer support
   if (imustplay=1) then//play
      begin

      imustplay:=0;
      _playbuzzer;

      end
   else if (imustplay>=2) then//stop
      begin

      imustplay:=0;
      stopbuzzer;

      end
   else _playbuzzer;//auto-syncs to any change in buzzer type - 14nov2022

   //.buzzer play progress -> works for both "test buzzer" and "alarm buzzer" with duration specific progress - 30nov2025
   if (omode=0) then
      begin

      dpert                          :=xbuzzerPert0100;

      ibuzbar. bpert2['buzzer.play'] :=dpert;
      ibuzbar.bflash2['buzzer.play'] :=(dpert>0);

      if (osynchead_alarmbuttonbyname<>'') then
         begin

         ibuzbar.gui.rootwin.xhead.bpert2 [osynchead_alarmbuttonbyname]:=dpert;
         ibuzbar.gui.rootwin.xhead.bflash2[osynchead_alarmbuttonbyname]:=(dpert>0);

         end;

      end;

   //reset
   itimer250:=add64(slowms64,250);

   end;

end;

function tbasicalarmlist.canplaybuzzer:boolean;
begin

result:=(ibuzlist.itemindex>=1);

end;

procedure tbasicalarmlist.playbuzzer;
begin

if canplaybuzzer then
   begin

   imustplay           :=1;//play
   iplayingbuzzerREF64 :=add64(slowms64,iplayingbuzzerLEN);

   end;

end;

procedure tbasicalarmlist._playbuzzer;
begin

if canplaybuzzer and (ibuzlist.itemindex<>chm_buzzer) and (iplayingbuzzerREF64>slowms64) then
   begin

   iplayingbuzzerREF64 :=add64(ms64,iplayingbuzzerLEN);
   chm_setbuzzer(ibuzlist.itemindex);

   end;

//turn off time
if not canplaybuzzer and (iplayingbuzzerREF64>slowms64) then
   begin

   iplayingbuzzerREF64:=slowms64;

   end;

end;

function tbasicalarmlist.canstopbuzzer:boolean;
begin

result:=(chm_buzzer>=1) or testingbuzzer;

end;

procedure tbasicalarmlist.stopbuzzer;
begin

chm_setbuzzer(0);
iplayingbuzzerREF64:=slowms64;

end;

function tbasicalarmlist.testingbuzzer:boolean;
begin

result:=(ibuzlist.itemindex>=1) and (iplayingbuzzerREF64>slowms64);

end;

function tbasicalarmlist.xbuzzerPert0100:extended;//0..100
begin

case testingbuzzer of
true:begin

   result:=low__percentage64( sub64( iplayingbuzzerLEN, sub64(iplayingbuzzerREF64,slowms64)) ,iplayingbuzzerLEN );
   if (result<=0) then result:=0.0001;

   end;
else
   begin

   if (icore.omode=0) and canstopbuzzer then
      begin

      result:=low__percentage64( icore.playlen-icore.playrem, icore.playlen );
      if (icore.playrem>=1) and (result<=0) then result:=0.0001;

      end
   else result:=0;

   end;
end;//case

end;

procedure tbasicalarmlist.____onclick(sender:tobject);
var
   e,n:string;
   int1:longint;
begin

//defaults
if (sender<>nil) and (sender is tbasictoolbar) then
   begin

   n:=strlow((sender as tbasictoolbar).ocode2);

   if      (n='copy')  then clip__copytext(icore.one)
   else if (n='paste') then
      begin

      if icore.pasteprompt1(gui) then
         begin
         xmustfromgui;
         if not icore.paste2(e) then gui.poperror('',e);
         xtogui;
         end;

      end
   else if (n='saveas') then
      begin

      if not icore.saveas(gui,ilastfilename,true,e) then gui.poperror('',e);

      end
   else if (n='open') then
      begin

      if not icore.open(gui,ilastfilename,ilastfilterindex,true,e) then gui.poperror('',e);

      end
   else if (n='buzzer.stop') then stopbuzzer
   else if (n='buzzer.play') then
      begin

      if canstopbuzzer then stopbuzzer else playbuzzer;

      end
   else
      begin

      end;
   end
else if (sender=iyear) then showmenu2('year');

end;


//## tapp ######################################################################

constructor tapp.create;
begin

if system_debug then dbstatus(38,'Debug 012');//yyyy


//self
inherited create(strint32(app__info('width')),strint32(app__info('height')));
ibuildingcontrol:=true;


//needers - 26sep2021
//need_man;
need_jpeg;
//need_gif;
//need_ico;
need_mm;//required
need_chimes;//required

//vars
ibuildingcontrol            :=true;
iresSlot                    :=res_nil;

low__cls(@ifontlist,sizeof(ifontlist));

viframemaxScope             :=1;//include fullscreen
iwasshowinghelp             :=false;
iflash1000                  :=false;
isetcol                     :=0;
ifacecol                    :=1;
ishowpage                   :='*';//triggers an update when showpage is set to "" (nil)
ilastmidtest                :='';
imustquieten                :=false;
ishortlabellimit            :=22;//max of 22 chars - 15mar2022
ialarmpos                   :=0;
ireminderpos                :=0;
iinfotimer                  :=ms64;
itimer100                   :=ms64;
itimer250                   :=ms64;
itimer500                   :=ms64;
itimer1000                  :=ms64;
iflashref                   :=ms64;
iscrollref                  :=0;
iscrollref2                 :=0;
iscrollref64                :=ms64;
ilaststopactive64           :=ms64;
iidleref                    :=ms64;
imousemoveoff               :=0;
iframebrightness            :=100;
ilastchimename              :='';
ilasttestchimeref           :='';
iwakeonclick                :=false;
iframeOuterColor            :=0;
iframeInnerColor            :=0;
ibrightnessREF              :=-1;

ifinalBackColor             :=0;
ifinalFontColor             :=rgba0__int(255,255,255);
ifinalBrightness            :=255;
ifinalFeather4              :=0;
ifinalWidth                 :=100;
ifinalHeight                :=100;

iloaded                     :=false;
icolorfrom1                 :=0;
icolorfrom2                 :=0;
ibuffer                     :=nil;
iscreenbuffer               :=misraw32(1,1);
ibellbuffer                 :=misimg32(1,1);

iscreenref                  :='';
iscreenref2                 :='';
ibellref                    :='';
iframeref                   :='';
iinsidescreen               :=false;
icolorindex                 :=-1;//not set
ilastcolname                :='';
ibackcolor                  :=0;
iminfontsize2               :=300;
ifontcolor                  :=rgba0__int(255,255,255);
ichimemins                  :=-1;

//.colors
xmakeColors;

//.alarms
iactindex      :=-1;
iactbuzzer     :=0;//off
iactmsg        :='';
ihavebuzzer    :=false;
ihavemsg       :=false;

//.reminders
iremindex      :=-1;
iremmsg        :='';
ihaveremmsg    :=false;

//.midi handler
mid_setkeepopen(false);//auto closes midi device after 5 seconds of inactivity

//controls
with rootwin do
begin
scroll:=false;
xhead;

end;

//columns
rootwin.xcols.style:=bcLefttoright;

//clock settings ---------------------------------------------------------------
with rootwin.xcols.makecol(isetcol,100,false) do
begin

xhead.visible:=false;

//repurpose "popup settings" into "in clock-face" settings - 30nov2025
xmakeClockSettings(client);

end;


//.clock face/screen
with rootwin.xcols.makecol(ifacecol,100,false) do
begin

iscreen:=ncontrol;//create a control
iscreen.oautoheight:=true;
iscreen.bordersize:=0;
iscreen.help:='Clock Face|Click, tap, or press any key to silence active alarm(s).  Press the "ESC" key to toggle fullscreen mode.  Click and drag to position clock face (when a window).';

end;


//.last links on toolbar - 22mar2021
with rootwin.xhead do
begin

addsep;
add('Hide Settings',tepDownward20,0,'page.','Hide Settings|Hide clock settings and wait a short delay for toolbar to auto-hide');

addsep;
xaddoptions;//add the system "Options" link to the toolbar
xaddhelp;//add the sytem "Help" link to the toolbar -> won't display if no help document data present in "gossdat.pas -> progamhelp array"

end;


//events
rootwin.xhead.onclick   :=__onclick;
iscreen.onpaint         :=xscreenpaint;
iscreen.onnotify        :=xscreennotify;
iscreen.ocanshowmenu    :=true;

//gamemode - 30nov2025
gui.gamemode__onpaint       :=gamemode__onpaint;
gui.gamemode__onnotify      :=gamemode__onnotify;
gui.gamemode__onshortcut    :=gamemode__onshortcut;
gui.gamemode__cansize       :=true;
gui.gamemode__canmove       :=true;

//start timer event
ibuildingcontrol:=false;
xloadsettings;//load program settings, separate to the system settings

//defaults
xupdatebuttons;

//.flicker and stutter free intial display mode - 15mar2022
xmustclock;
xmustframe;
xmakeidle;

//finish
createfinish;

end;

destructor tapp.destroy;
var
   p:longint32;
begin
try

//settings
xsavesettings;

//controls
freeobj(@ibellbuffer);
freeobj(@iscreenbuffer);
freeobj(@ialarmlist);
freeobj(@ireminderlist);
freeobj(@ibuffer);
fd__del( iresSlot );

for p:=0 to high(ifontlist) do fd__del( ifontlist[p] );

//self
inherited destroy;

except;end;
end;

procedure tapp.xsel__readwrite(sender:tobject;var xval:longint;xwrite:boolean);
begin

//check
if xwrite and (not iloaded) then exit;

end;

procedure tapp.xset__readwrite(sender:tobject;var xval:tbasicset_valarray;xwrite:boolean);
var
   xSyncandsave:boolean;
begin

//defaults
xSyncandsave :=false;

//check
if xwrite and (not iloaded) then exit;


//settings ---------------------------------------------------------------------
if (sender=isettings) then
   begin

   case xwrite of
   true:begin

      if (xval[0]<>viframemax) then
         begin
         syssettings.b['framemax']:=xval[0];
         xSyncandsave:=true;
         end;

      if (xval[1]<>viontop) then
         begin
         syssettings.b['ontop']:=xval[1];
         xSyncandsave:=true;
         end;

      if (xval[2]<>vistartuplink) then
         begin
         syssettings.b['startuplink']:=xval[2];
         xSyncandsave:=true;
         end;

      if (xval[3]<>vispecialcolors) then
         begin
         syssettings.b['specialcolors']:=xval[3];
         xSyncandsave:=true;
         end;

      if (xval[4]<>viretainpos) then
         begin
         syssettings.b['retainpos']:=xval[4];
         xSyncandsave:=true;
         end;

      iwakeonclick:=xval[5];

      end;
   else begin

      xval[0]:=viframemax;
      xval[1]:=viontop;
      xval[2]:=vistartuplink;
      xval[3]:=vispecialcolors;
      xval[4]:=viretainpos;
      xval[5]:=iwakeonclick;

      end;
   end;//case

   end;


//viSyncandsave
if xSyncandsave then viSyncandsave;

end;

procedure tapp.xmakeClockSettings(sender:tobject);
var
   xnow:tdatetime;
   xalarmindex,i,p,p2,dw,dh,int1,xpreviousfocus:longint;
   a:tbasicscroll;
   dhelp,str1:string;
   xhost:tbasiccontrol;
   bol1:boolean;

   function xnewpage(const xpagename,xtabname,xtitle,xhelp:string;const xtep:longint;const xstatic:boolean):tbasicscroll;
   begin

   result:=a.xpage2(xpagename,xtitle,'',xhelp,xtep,xstatic);
   rootwin.xhead.add(xtabname,xtep,0,'page.'+xpagename,'Settings|'+xhelp);

   end;

   function dint3(xlabel,xname,xhelp:string;xmin,xmax,xdef:longint;xvalname:string):tsimpleint;
   begin

   if zznil(xhost,2291) then exit;

   result:=xhost.mint3(xlabel,xhelp,xmin,xmax,xdef,0,'',xvalname);
   result.tagstr:=xname;

   end;

   function dint3b(var xout:tsimpleint;xlabel,xname,xhelp:string;xmin,xmax,xdef:longint;xvalname:string):tsimpleint;
   begin
   result:=dint3(xlabel,xname,xhelp,xmin,xmax,xdef,xvalname);
   xout:=result;
   end;

   function dset(xlabel,xname,xhelp:string;xdef:longint;const xreadwrite:boolean):tbasicset;
   begin

   if zznil(xhost,2292) then exit;

   result:=xhost.nset(xlabel,xhelp,xdef,0);
   result.tagstr:=xname;
   if xreadwrite then result.onreadwriteval:=xset__readwrite;

   end;

   function dsel3(xlabel,xname,xhelp:string;xdef:longint;xvalname:string;const xreadwrite:boolean):tbasicsel;
   begin

   if zznil(xhost,2293) then exit;

   result:=xhost.nsel3(xlabel,xhelp,xdef,xvalname);
   result.tagstr:=xname;
   if xreadwrite then result.onreadwriteval:=xsel__readwrite;

   end;

   function dedit(xtitle,xvalue,xhelp,xspbackname:string;xlenlimit:longint):tbasicedit;
   begin

   if zznil(xhost,2293) then exit;

   result              :=xhost.nedit(xvalue,xhelp);
   result.title        :=xtitle;
   result.caption      :=xvalue;//visual prompt when box is empty
   result.ospbackname  :=xspbackname;

   if (xlenlimit>=1) then result.olimit:=xlenlimit;

   end;

   function xpod_label_help(const n:string):string;
   begin

   result:=n+' Label|Type a short label for '+strlow(n)+' or leave blank for default';

   end;

   function xframe_color_style_help(const xmsg:string):string;
   begin

   result:='Frame Color Style|'+xmsg;

   end;

begin
try

//defaults
if (sender is tbasicscroll) then a:=(sender as tbasicscroll) else exit;

//init
a.xtoolbar.visible:=false;
xhost:=nil;


//face -------------------------------------------------------------------------
with xnewpage('face','Face','Face Color','Face color settings',tepColor20,true) do
begin
xhost:=client;

xcolsh.ofillheight:=true;//use all client height if available

with xcolsh.cols2[0,42,false] do
begin

xtoolbar.maketitle('Face Colors');

xhost:=client;

icolorlist              :=nlist3('','Face Colors|Select a color to set clock text and background color',nil,1,'');//read/write via system var.name of "colorname" - 09oct2020
icolorlist.makelistx(icolorcount);
icolorlist.ongetitem2   :=xlistitem2;
icolorlist.onclick      :=xcustomcolorchanged;//xshowsettings_sync;
icolorlist.onumberfrom  :=icolorfrom1;
icolorlist.onumberfrom2 :=icolorfrom2;

end;

with xcolsh.cols2[1,100,true] do
begin
xhost:=client;

xtoolbar.maketitle('Settings');

//.display brightness
dint3b(ibrightness,'Face Brightness','','Face Brightness|Set clock face brightness',10,100,100,'').ospbackname:='green';
ibrightness.ounit:='%';
ibrightness.osepv:=def_vsep;

//.frame brightness
dint3b(ibrightness2,'Frame Brightness','','Frame Brightness|Set clock frame brightness',10,100,100,'').ospbackname:='green';
ibrightness2.ounit:='%';
ibrightness2.osepv:=def_vsep;

//.auto dim
iautodim:=dsel3('Dim To','','Dim To|Set the level the clock face is to be dimmed to during the hours of evening and predawn',0,'',false);
with iautodim do
begin

osepv         :=def_vsep;
itemsperline  :=5;

for p:=0 to 9 do
begin

case (p=0) of
true:begin

   str1  :='Off';
   dhelp :='Disable';

   end;
else begin

   str1  :=intstr32((10-p)*10)+'%';
   dhelp :='Dim clock face down to '+str1+' during the hours of evening and predawn';

   end;
end;//case

xadd(str1,'','Dim To|'+dhelp);

end;//p

ospbackname:='blue';
end;

//.shade style
ishadestyle:=dsel3('Shade Style','','Clock face background shade style',0,'',false);

with ishadestyle do
begin
osepv         :=def_vsep;
itemsperline  :=5;

for p:=0 to 4 do
begin

case p of
0:str1:='Flat';
1:str1:='Shade';
2:str1:='Shade 2';
3:str1:='Round';
4:str1:='Glow';
end;//case

xadd(str1,'','Shade Style|Set background style to '+strlow(str1));

end;//p

ospbackname:='blue';
end;

//.shade power - 13nov2022
dint3b(ishadepower,'Shade Power','shadepower','Shade Power|Set strength of background shade.  A value less than zero shades to black and a value above zero shades to color.',-100,100,20,'').ospbackname:='blue';
ishadepower.ounit:='%';
ishadepower.osepv:=def_vsep;

//.feather
ifeather:=dsel3('Text Feathering','','Text Feathering|Set feather strength of text',0,'',false);

with ifeather do
begin

osepv         :=def_vsep;
itemsperline  :=5;

for p:=0 to 4 do
begin

case p of
0:str1:='None';//Sharp
1:str1:='Low';//Blur 1
2:str1:='Medium';//Blur 2
3:str1:='High';//Greyscale + Blur 1
4:str1:='Ultra';//Greyscale + Blur 2
end;//case

xadd(str1,'','Text Feathering|Set text feather level to '+strlow(str1));

end;//p

ospbackname:='green';

end;

//.options
icolopts:=dset('Options','','',0,false);

with icolopts do
begin

osepv       :=def_vsep;
itemsperline:=2;

xset3(0,'Tint Background','backmix','Tint Background|Inject a little of the text color into the background',false,'');
xset3(1,'Swap Colors','swapcolors','Swap Colors|Swap background and text colors',false,'');

xset3(2,'Flash Separator','flashsep','Flash Separator|Flash the time separator ":"',false,'');

ospbackname:='green';

end;

//.frame style
iframestyle:=dsel3('Frame Color Style','','',0,'',false);

with iframestyle do
begin

osepv         :=def_vsep;
itemsperline  :=3;

xadd('Back','', xframe_color_style_help('Render frame in shades of background color') );
xadd('Text','', xframe_color_style_help('Render frame in shades of text color') );
xadd('Back / Text','', xframe_color_style_help('Render frame inward from background color to text color') );
xadd('Text / Back','', xframe_color_style_help('Render frame inward from text color to background color') );
xadd('Black','', xframe_color_style_help('Render frame in shades of black') );
xadd('White','', xframe_color_style_help('Render frame in shades of white') );

ospbackname:='purple';

end;

//.custom colors
icustomcolors:=client.ncolors;

with icustomcolors do
begin
osepv:=def_vsep;

makeadjustable2(2);

addtitle('Custom Colors','');
addcol('Background','b','Background Color|Click for color dialog or click and drag to acquire screen color');
addcol('Text','f','Text Color|Click for color dialog or click and drag to acquire screen color');

oncolorchanged:=xcustomcolorchanged;//dedicated event handler => avoids any slow downs - 15mar2022

end;//with

end;

end;
//end of face ------------------------------------------------------------------


//chime ------------------------------------------------------------------------
with xnewpage('chime','Chime','Chime','Chime Settings',tepMid20,true) do
begin

xhost     :=client;
ichimebar :=xtoolbar.maketitle('Chimes');

with ichimebar do
begin
xaddmixer;//07mar2022

add('Stop',tepStop20,0,'chime.stop','Stop sample chime');
add('Play Sample',tepPlay20,0,'chime.play','Play / Stop sample chime');

end;

xcolsh.ofillheight:=true;//use all client height if available

with xcolsh.cols2[0,42,false] do
begin

ichimelist              :=nlist3('','Select chime',nil,1,'');
ichimelist.makelistx(chm_count);
ichimelist.ongetitem2   :=xlistitem2;
ichimelist.onumberfrom  :=chm_numberfrom1;
ichimelist.onumberfrom2 :=chm_numberfrom2;
ichimelist.onumberfrom3 :=chm_numberfrom3;
ichimelist.onnotify     :=xchimelistnotify;

end;

with xcolsh.cols2[1,100,true] do
begin
xhost:=client;

//.normal
inormal0:=dsel3('Mode','','Set chime mode',0,'',false);

with inormal0 do
begin

osepv:=def_vsep;

xadd('Melody and Dongs','','Selected: Chime introduction melody and dongs');
xadd('Dongs Only','','Selected: Chime dongs only');

ospbackname:='purple';

end;

inormal:=dset('Quarterly','','Set quarter dongs to chime',0,false);

with inormal do
begin

osepv:=def_vsep;

xset3(0,'15m','15','Selected: Chime quarter past dong',false,'');
xset3(1,'30m','30','Selected: Chime half past dong',false,'');
xset3(2,'45m','45','Selected: Chime quarter to dong',false,'');

ospbackname:='purple';

end;

//.bells
ibell0:=dsel3('Mode','','',0,'',false);

with ibell0 do
begin

osepv:=def_vsep;

xadd('Standard','','Chime the standard Ships Bells');
xadd('British Royal','','Chime the modified British Royal Ships Bells | In 1797 at Nore a mutiny started during the dogwatch at five bells (6:30 PM), afterwards British ships changed the sequence to omit the five bells');

ospbackname:='purple';

end;

//.sonnerie
ison0:=dsel3('Mode','','',0,'',false);

with ison0 do
begin

osepv:=def_vsep;

xadd('Grande Sonnerie','','Selected: Chime hour dongs quarterly followed by quarter past / half past or quarter to dongs');
xadd('Petite Sonnerie','','Selected: Chime hour dongs on the hour and quarterly dongs');

ospbackname:='purple';

end;

ison:=dset('Quarterly','','Set quarter dongs to chime',0,false);

with ison do
begin
osepv:=def_vsep;

xset3(0,'15m','15','Selected: Chime quarter past dong',false,'');
xset3(1,'30m','30','Selected: Chime half past dong',false,'');
xset3(2,'45m','45','Selected: Chime quarter to dong',false,'');

ospbackname:='purple';

end;

//.volume
with mmidivol('Chime / Alarm Volume','Chime / Alarm Volume') do
begin

ospbackname:='yellow';
osepv:=def_vsep;

end;

//.speed
dint3b(ichimespeed,'Chime / Alarm Speed','chimespeed','Chime Speed',25,400,100,'').ospbackname:='yellow';
ichimespeed.ounit:='%';
ichimespeed.osepv:=def_vsep;

//.auto quieten
iautoquieten:=dsel3('Reduce Chime Volume','','Reduce Chime volume to selected volume level at night',0,'',false);

with iautoquieten do
begin

osepv:=def_vsep;
itemsperline:=5;

for p:=0 to 9 do
begin
if (p=0) then str1:='Off' else str1:=intstr32((10-p)*10)+'%';
xadd(str1,'',str1);
end;//p

ospbackname:='blue';
end;

//.device
with nmidi('','') do
begin

ospbackname:='blue';
osepv:=def_vsep;
itemsperline:=6;

end;

ichimeoptions:=dset('Options','','',0,false);

with ichimeoptions do
begin

osepv:=def_vsep;

xset3(0,'Always On Midi','keepopen','Selected: Remain connected to midi device | Not Selected: Disconnect and close midi device after chiming / alarm(s) complete',false,'');
xset3(1,'Preview Sample Chime','samplechime','Selected: Play sample chime automatically',false,'');

ospbackname:='blue';

end;

//test/debug usage only - disable before release - 15nov2022
//disabled: pchimetest:=nbwp('',nil);pchimetest.maketxt1
end;//column
end;
//end of chime -----------------------------------------------------------------


//alarms -----------------------------------------------------------------------
with xnewpage('alarms','Alarms','Alarms','Alarm Settings',tepClock20,true) do
begin

xhost                 :=client;
ialarmlist            :=tbasicalarmlist.create(gui);
ialarmlist.parent     :=xhost;
ialarmlist.makeAlarms;
ialarmlist.osynchead_alarmbuttonbyname:='page.alarms';//flashes button TEP and displays progress bar during buzzer test/buzzer alarm
ialarmlist.pos        :=ialarmpos;

end;
//end of alarms ----------------------------------------------------------------


//reminders --------------------------------------------------------------------
with xnewpage('reminders','Reminders','Reminders','Reminder Settings',tepAlert20,true) do
begin

xhost                 :=client;
ireminderlist         :=tbasicalarmlist.create(gui);
ireminderlist.parent  :=xhost;
ireminderlist.makeReminders;
ireminderlist.pos     :=ireminderpos;

end;
//end of reminders -------------------------------------------------------------


//display ----------------------------------------------------------------------
with xnewpage('display','Display','Display','Display settings',tepScreen20,false) do
begin

xhost:=client;

//.general
isettings:=dset('General','','',0,true);

with isettings do
begin

osepv:=def_vsep;

itemsperline:=3;

xset3(0,'Frame Maximised','','Frame Maximised|Frame app when maximised or in full screen mode',false,'');
xset3(1,'On Top','','On Top|Place app window above other windows',false,'');
xset3(2,'Automatic Startup','','Automatic Startup|Start app when computer starts',false,'');
xset3(3,'Color Contrast','','Color Contrast | Color contrast important settings and input areas',false,'');
xset3(4,'Retain Pos / Size','','Retain Pos / Size | Retain window position and size for next start',false,'');
xset3(5,'Click To Show','','Click To Show|Require a click or tap to show toolbar when hidden',false,'');

ospbackname:='green';

end;

//.reminder
irem:=dset('Reminder','','',0,false);

with irem do
begin

osepv:=def_vsep;

itemsperline:=4;

xset3(0,'Uppercase','rem.uppercase','Reminder Uppercase|Force reminder message in uppercase characters',false,'');
xset3(1,'At Top','rem.top','Reminder At Top|Show reminder above time',false,'');

ospbackname:='blue';

end;

//.time format
itimeformat:=dsel3('Time Format','','',0,'',false);

with itimeformat do
begin

osepv:=def_vsep;

xadd('24hr','','Time Format|Display twenty four hour time');
xadd('12hr AM/PM','','Time Format|Display 12 hour time with uppercase AM/PM');
xadd('12hr am/pm','','Time Format|Display 12 hour time with lowercase am/pm');

ospbackname:='purple';

end;

//.date
idate:=dset('Date','','',0,false);

with idate do
begin

osepv:=def_vsep;

itemsperline:=4;

xset3(0,'Show','date.show','Date Show|Display date on screen',false,'');
xset3(1,'Uppercase','date.uppercase','Date Uppercase|Force date in uppercase characters',false,'');
xset3(2,'At Top','date.top','Date At Top|Show date above time',false,'');
xset3(3,'Full','date.full','Date Full|Show date in long form',false,'');

ospbackname:='yellow';

end;

//.date format
idateformat :=dsel3('Date Format','','',0,'',false);
xnow        :=xdate__now;

with idateformat do
begin

osepv:=def_vsep_small;

itemsperline:=3;

for p:=0 to 5 do//05dec2025
begin
xadd('*','','*');//filled later in "*_showhide" - 13mar2022
end;//p

ospbackname:='yellow';

end;

//.day
iday:=dset('Day of Week','','',0,false);

with iday do
begin

osepv:=def_vsep;

itemsperline:=4;

xset3(0,'Show','day.show','Day Show|Show day of week on screen',false,'');
xset3(1,'Uppercase','day.uppercase','Day Uppercase|Force day of week in uppercase characters',false,'');
xset3(2,'At Top','day.top','Day At Top|Show day of week above time',false,'');
xset3(3,'Full','day.full','Day Full|Show day of week in long form',false,'');

ospbackname:='red';

end;

//.pod
ipod:=dset('Part of Day','','',0,false);

with ipod do
begin

osepv:=def_vsep;

itemsperline:=4;

xset3(0,'Show','pod.show','Part Day Show|Display part of day on screen',false,'');
xset3(1,'Uppercase','pod.uppercase','Part Day Uppercase|Force part of day in uppercase characters',false,'');

ospbackname:='purple';

end;

//.evening + morning
with dint3b(ievening,'Afternoon becomes Evening at','Evening','Afternoon and Evening|Set the time at which afternoon becomes evening',0,600,360,'') do
begin

osepv        :=def_vsep;
ospbackname  :='purple';
onfindlabel  :=_onvalcap;

end;//case


with dint3b(imorning,'Predawn becomes Morning at','morning','Predawn and Morning|Set the time at which predawn becomes morning',0,600,360,'') do
begin

osepv        :=def_vsep_small;
ospbackname  :='purple';
onfindlabel  :=_onvalcap;

end;

//.part of day labels
//was: ntitle(false,'Part of Day Labels','Type a custom label or leavel blank to use default');
str1:='< Type a custom label >';
ilabel_afternoon:=dedit('Afternoon Label'    ,str1,xpod_label_help('Afternoon')   ,'yellow',ishortlabellimit);
ilabel_afternoon.osepv:=def_vsep_small;

ilabel_evening:=dedit('Evening Label'        ,str1,xpod_label_help('Evening')     ,'yellow',ishortlabellimit);
ilabel_evening.osepv:=def_vsep_small;

ilabel_predawn:=dedit('Predawn Label'        ,str1,xpod_label_help('Predawn')     ,'blue',ishortlabellimit);
ilabel_predawn.osepv:=def_vsep_small;

ilabel_morning:=dedit('Morning Label'        ,str1,xpod_label_help('Morning')     ,'blue',ishortlabellimit);
ilabel_morning.osepv:=def_vsep_small;

end;
//end of display ---------------------------------------------------------------

//events
a.xtoolbar.onclick  :=__onclick;
ichimebar.onclick   :=__onclick;

except;end;
end;

procedure tapp.xmakecolors;//face color sets (foreground and background color pairs) - 30nov2025
var
   xlastfont,xlastback,p:longint;
   xlastname:string;

   procedure xaddcolor(xname:string;xfont,xback:longint);
   label
      redo;
   var
      xnamecount,p,int1:longint;
      str1:string;
   begin

   //check
   if (icolorcount>high(icolorname)) or (xname='') then exit;

   //store a copy before it's modified below - 13nov2022
   xlastname:=xname;

   //new name
   if (icolorcount>=1) then
      begin

      xnamecount:=1;
      redo:

      str1:=xname+insstr(#32+intstr32(xnamecount),xnamecount>=2);

      for p:=0 to (icolorcount-1) do if strmatch(str1,icolorname[p]) then
         begin

         inc(xnamecount);
         if (xnamecount<=100) then goto redo;

         end;//p

      //set
      xname:=str1;

      end;

   //get
   icolorname[icolorcount]:=xname;
   icolorfont[icolorcount]:=xfont;
   icolorback[icolorcount]:=xback;

   inc(icolorcount);

   end;

   procedure xaddcolor0(xname:string;xfont,xback:longint);
   begin

   xlastfont:=xfont;
   xlastback:=xback;

   xaddcolor(xname,xfont,xback);

   end;

   procedure xaddcolor1(xname:string;xfont,xback,xshift,xshift2:longint);
   var
      a:tcolor24;
   begin

   //filter
   if (xname='') then xname:=xlastname;
   if (xfont=-1) then xfont:=xlastfont;
   if (xback=-1) then xback:=xlastback;

   //xfont
   a:=int__c24(xfont);

   if (xshift<>0) then
      begin

      a.r:=frcrange32(a.r+xshift,0,255);
      a.g:=frcrange32(a.g+xshift,0,255);
      a.b:=frcrange32(a.b+xshift,0,255);

      xfont:=c24__int(a);

      end;

   //xback
   a:=int__c24(xback);

   if (xshift2<>0) then
      begin

      a.r:=frcrange32(a.r+xshift2,0,255);
      a.g:=frcrange32(a.g+xshift2,0,255);
      a.b:=frcrange32(a.b+xshift2,0,255);

      xback:=c24__int(a);

      end;

   //add
   xaddcolor(xname,xfont,xback);

   end;

   procedure xaddcolor2(xname:string;xfont,xback,xpert,xpert2:longint);
   begin

   xfont:=low__colsplice(frcrange32(xpert,0,100),rgba0__int(255,255,255),xfont);
   xback:=low__colsplice(frcrange32(xpert2,0,100),0,xback);
   xaddcolor(xname,xfont,xback);

   end;

   procedure xaddcolor3(xname:string;xfont,xback:longint);
   var
      c1,c2,p:longint;

      function xcol1(xpert:longint):longint;
      begin

      if (xpert>=0) then result:=low__colsplice(frcrange32(xpert,0,100),rgba0__int(255,255,255),xfont)
      else               result:=low__colsplice(frcrange32(-xpert,0,100),xback,xfont);

      end;

      function xcol2(xpert:longint):longint;
      begin

      if (xpert>=0) then result:=low__colsplice(frcrange32(xpert,0,100),0,xback)
      else               result:=low__colsplice(frcrange32(-xpert,0,100),xfont,xback);

      end;

   begin

   for p:=1 to 5 do
   begin

   case p of
   1:begin
      c1:=xfont;
      c2:=xback;
      end;
   2:begin
      c1:=xcol1(0);
      c2:=xcol2(10);
      end;
   3:begin
      c1:=xcol1(30);
      c2:=xcol2(10);
      end;
   4:begin
      c1:=xcol1(30);
      c2:=xcol2(50);
      end;
   5:begin
      c1:=xcol1(-20);
      c2:=xcol2(-20);
      end;
   end;//case

   xaddcolor(xname+insstr(#32+intstr32(p),p>=1),c1,c2);

   end;//p

   end;

   procedure xaddTitle(xname:string);
   begin
   xaddcolor(xname,-99,-99);
   end;

begin

//init
xlastname     :='Untitled';
xlastfont     :=255;
xlastback     :=0;
icolorcount   :=0;

for p:=0 to high(icolor1) do
begin

icolor1[p]:=rgba0__int(255,255,255);//text
icolor2[p]:=0;//back

end;//p

//get
//.built-in
xaddTitle('Built-In');
icolorfrom1:=1;//09nov2022
xaddcolor('Default',rgba0__int(255,255,255),0);

xaddcolor('System Title',-2,-2);
xaddcolor('System Standard',-1,-1);
xaddcolor('System Frame',-3,-3);//10apr2026

xaddcolor0('Aqua',rgba0__int(0,255,255),0);
xaddcolor1('',-1,rgba0__int(30,0,0),0,0);
xaddcolor1('',-1,rgba0__int(60,0,0),0,0);
xaddcolor1('',-1,rgba0__int(0,0,30),0,0);
xaddcolor1('',-1,rgba0__int(0,0,60),0,0);
xaddcolor1('',-1,rgba0__int(30,30,0),0,0);
xaddcolor1('',-1,rgba0__int(60,60,0),0,0);
xaddcolor1('',-1,rgba0__int(30,0,30),0,0);
xaddcolor1('',-1,rgba0__int(60,0,60),0,0);

xaddcolor0('Aqua',rgba0__int(0,200,200),0);
xaddcolor0('Aqua',rgba0__int(100,200,200),0);

xaddcolor0('Biege',rgba0__int(255,242,235),rgba0__int(22,13,8));
xaddcolor1('',-1,rgba0__int(20,0,20),0,0);
xaddcolor1('',-1,rgba0__int(40,0,40),0,0);
xaddcolor1('',-1,rgba0__int(60,0,60),0,0);

xaddcolor1('',-1,rgba0__int(40,40,0),0,0);
xaddcolor1('',-1,rgba0__int(40,0,0),0,0);
xaddcolor1('',-1,rgba0__int(200,100,100),0,0);
xaddcolor1('',-1,rgba0__int(100,200,100),0,0);
xaddcolor1('',-1,rgba0__int(100,100,200),0,0);
xaddcolor1('',-1,rgba0__int(200,200,100),0,0);
xaddcolor1('',-1,rgba0__int(200,100,200),0,0);

xaddcolor1('Biege',rgba0__int(255,242,235),rgba0__int(172,163,158),-10,-100);
xaddcolor1('Biege',rgba0__int(255,242,235),rgba0__int(172,163,158),0,-50);
xaddcolor1('Biege',rgba0__int(255,242,235),rgba0__int(172,163,158),0,0);

xaddcolor0('Black',0,rgba0__int(255,255,255));
xaddcolor1('',-1,rgba0__int(170,70,70),0,0);
xaddcolor1('',-1,rgba0__int(70,170,70),0,0);
xaddcolor1('',-1,rgba0__int(70,70,170),0,0);
xaddcolor1('',-1,rgba0__int(170,70,170),0,0);
xaddcolor1('',-1,rgba0__int(170,170,70),0,0);
xaddcolor1('',-1,rgba0__int(70,170,170),0,0);
xaddcolor0('Black',0,rgba0__int(128,128,128));
xaddcolor0('Black',0,rgba0__int(60,60,60));

xaddcolor0('Blue',rgba0__int(0,0,255),0);
xaddcolor1('',-1,rgba0__int(20,0,0),0,0);
xaddcolor1('',-1,rgba0__int(50,0,0),0,0);
xaddcolor1('',-1,rgba0__int(20,30,0),0,0);

xaddcolor0('Blue',rgba0__int(0,128,255),0);
xaddcolor1('',-1,rgba0__int(18,0,0),0,0);
xaddcolor1('',-1,rgba0__int(30,10,10),0,0);

xaddcolor0('Blue',rgba0__int(0,64,200),0);
xaddcolor0('Blue',rgba0__int(100,100,200),0);
xaddcolor1('',-1,rgba0__int(38,0,0),0,0);
xaddcolor1('',-1,rgba0__int(60,0,0),0,0);

xaddcolor0('Green',rgba0__int(0,255,0),0);
xaddcolor1('',-1,rgba0__int(20,20,0),0,0);
xaddcolor1('',-1,rgba0__int(5,20,5),0,0);
xaddcolor1('',-1,rgba0__int(0,0,20),0,0);
xaddcolor1('',-1,rgba0__int(20,20,50),0,0);
xaddcolor0('Green',rgba0__int(0,200,0),0);
xaddcolor0('Green',rgba0__int(80,190,80),0);

xaddcolor0('Grey',rgba0__int(190,190,190),0);
xaddcolor1('',-1,rgba0__int(20,10,0),0,0);
xaddcolor1('',-1,rgba0__int(20,0,0),0,0);
xaddcolor1('',-1,rgba0__int(50,0,0),0,0);
xaddcolor1('',-1,rgba0__int(0,0,15),0,0);
xaddcolor1('',-1,rgba0__int(0,10,0),0,0);
xaddcolor1('',-1,rgba0__int(0,25,0),0,0);

xaddcolor0('Grey',rgba0__int(120,120,120),0);
xaddcolor1('',-1,rgba0__int(20,10,0),0,0);
xaddcolor1('',-1,rgba0__int(20,0,0),0,0);
xaddcolor1('',-1,rgba0__int(50,0,0),0,0);
xaddcolor1('',-1,rgba0__int(0,0,15),0,0);
xaddcolor1('',-1,rgba0__int(0,10,0),0,0);
xaddcolor1('',-1,rgba0__int(0,25,0),0,0);

xaddcolor('Grey',rgba0__int(150,140,130),0);
xaddcolor('Grey',rgba0__int(140,150,130),0);
xaddcolor('Grey',rgba0__int(130,140,150),0);

xaddcolor0('Orange',rgba0__int(255,128,0),0);
xaddcolor1('',-1,rgba0__int(20,10,0),0,0);
xaddcolor1('',-1,rgba0__int(20,0,0),0,0);
xaddcolor1('',-1,rgba0__int(50,0,0),0,0);
xaddcolor1('',-1,rgba0__int(0,0,15),0,0);
xaddcolor1('',-1,rgba0__int(0,10,0),0,0);
xaddcolor1('',-1,rgba0__int(0,25,0),0,0);

xaddcolor0('Orange',rgba0__int(245,150,0),0);
xaddcolor1('',-1,rgba0__int(20,10,0),0,0);
xaddcolor1('',-1,rgba0__int(20,0,0),0,0);
xaddcolor1('',-1,rgba0__int(50,0,0),0,0);
xaddcolor1('',-1,rgba0__int(0,0,15),0,0);
xaddcolor1('',-1,rgba0__int(0,10,0),0,0);
xaddcolor1('',-1,rgba0__int(0,25,0),0,0);

xaddcolor0('Orange',rgba0__int(240,190,0),0);
xaddcolor1('',-1,rgba0__int(20,10,0),0,0);
xaddcolor1('',-1,rgba0__int(20,0,0),0,0);
xaddcolor1('',-1,rgba0__int(50,0,0),0,0);
xaddcolor1('',-1,rgba0__int(0,0,15),0,0);
xaddcolor1('',-1,rgba0__int(0,10,0),0,0);
xaddcolor1('',-1,rgba0__int(0,25,0),0,0);

xaddcolor('Pink-Black',rgba0__int(255,35,175),rgba0__int(0,0,0));//04dec2025
xaddcolor0('Pink-Dusty',rgba0__int(228,199,230),rgba0__int(97,84,98));
xaddcolor1('Pink',-1,rgba0__int(15,0,0),0,0);
xaddcolor1('',-1,rgba0__int(30,0,0),0,0);
xaddcolor1('',-1,rgba0__int(30,0,30),0,0);
xaddcolor1('',-1,rgba0__int(20,20,30),0,0);
xaddcolor('Pink',rgba0__int(228-20,199-20,230-20),rgba0__int(97-20,84-20,98-20));

xaddcolor0('Purple',rgba0__int(128,0,255),0);
xaddcolor1('',-1,rgba0__int(15,0,0),0,0);
xaddcolor1('',-1,rgba0__int(30,0,0),0,0);
xaddcolor1('',-1,rgba0__int(50,0,0),0,0);
xaddcolor1('',-1,rgba0__int(30,0,30),0,0);
xaddcolor1('',-1,rgba0__int(50,0,70),0,0);
xaddcolor('Purple',rgba0__int(128,0,255),rgba0__int(25,0,50));

xaddcolor0('Purple-Purple',rgba0__int(46,14,78),rgba0__int(128,0,255));
xaddcolor1('',rgba0__int(19,44,57),-1,0,0);


xaddcolor0('Red',rgba0__int(255,0,0),0);
xaddcolor1('',-1,rgba0__int(10,30,0),0,0);//green
xaddcolor0('Red',rgba0__int(200,0,0),0);
xaddcolor1('',-1,rgba0__int(0,0,50),0,0);//blue
xaddcolor0('Red',rgba0__int(200,45,22),0);
xaddcolor1('',-1,rgba0__int(30,0,30),0,0);//purple
xaddcolor0('Red',rgba0__int(190,80,80),0);
xaddcolor1('',-1,rgba0__int(50,0,0),0,0);
xaddcolor0('Red',rgba0__int(255,50,50),0);
xaddcolor1('',-1,rgba0__int(70,0,30),0,0);

xaddcolor0('White',rgba0__int(255,255,255),0);
xaddcolor1('',-1,rgba0__int(20,0,0),0,0);
xaddcolor1('',-1,rgba0__int(0,20,0),0,0);
xaddcolor1('',-1,rgba0__int(0,0,20),0,0);
xaddcolor1('',-1,rgba0__int(20,20,0),0,0);
xaddcolor1('',-1,rgba0__int(20,0,20),0,0);
xaddcolor('White',rgba0__int(230,230,230),0);
xaddcolor('White',rgba0__int(200,200,200),0);

xaddcolor('Yellow',rgba0__int(255,255,0),0);
xaddcolor1('Yellow',rgba0__int(255,255,0),rgba0__int(255,255,200),-10,-255);
xaddcolor1('Yellow',rgba0__int(255,255,0),rgba0__int(255,255,200),0,-150);
xaddcolor1('Yellow',rgba0__int(255,255,0),rgba0__int(255,255,200),0,-90);
xaddcolor1('Yellow',rgba0__int(240,220,0),0,0,0);
xaddcolor1('Yellow',rgba0__int(240,220,0),rgba0__int(0,0,50),0,0);
xaddcolor1('Yellow',rgba0__int(240,220,0),rgba0__int(0,0,100),0,0);
xaddcolor1('Yellow',rgba0__int(240,220,0),rgba0__int(0,50,0),0,0);
xaddcolor1('Yellow',rgba0__int(240,220,0),rgba0__int(0,100,0),0,0);
xaddcolor1('Yellow',rgba0__int(240,220,0),rgba0__int(50,0,0),0,0);
xaddcolor1('Yellow',rgba0__int(240,220,0),rgba0__int(100,0,0),0,0);

xaddcolor('Yellow-Purple',rgba0__int(248,255,163),rgba0__int(99,0,96));//04dec2025
xaddcolor('Yellow-Purple',rgba0__int(248,255,163),rgba0__int(71,0,179));//04dec2025
xaddcolor('Yellow-Pink',rgba0__int(248,255,163),rgba0__int(172,0,90));//04dec2025
xaddcolor('Yellow-Red',rgba0__int(248,255,163),rgba0__int(246,0,28));//04dec2025
xaddcolor('Yellow-Red',rgba0__int(245,215,84),rgba0__int(255,61,67));//11dec2025


//.custom
xaddTitle('Custom');
icolorfrom2:=icolorcount;//09nov2022

for p:=0 to 9 do xaddcolor('Custom '+intstr32(p+1),-100-p,-100-p);

end;

function tapp.xlistitem2(sender:tobject;xindex:longint;var xtab:string;var xtep,xtepcolor,xtepcolor2:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep,xbold:boolean):boolean;
var
   xstyle:longint;
   xintro,xdong,xdong2:tstr8;
begin

//defaults
result:=false;

//get
if (sender=icolorlist) and (icolorlist<>nil) then
   begin

   xindex    :=frcmax32(frcrange32(xindex,0,frcmin32(icolorcount-1,0)),high(icolorname));
   xcaplabel :=icolorname[xindex];

   //.title
   if (icolorfont[xindex]=-99) then
      begin

      xtitle:=true;

      end
   //.color
   else
      begin

      xtep       :=tepHarmonyColPal20;//09apr2026 - tepColorPalDUAL20;//07apr2026, 04dec2025 - was: tepColorPal20;
      xtepcolor  :=icolorfont[xindex];
      xtepcolor2 :=icolorback[xindex];//04dec2025

      if (xtepcolor<0)  then xtepcolor  :=xsyscol(xtepcolor,true);//text color
      if (xtepcolor2<0) then xtepcolor2 :=xsyscol(xtepcolor2,false);//back color

      if bol[swap_colors] then low__swapint(xtepcolor,xtepcolor2);

      end;

   end
else if (sender=ichimelist) and (ichimelist<>nil) then
   begin

   chm_info(xindex,xcaption,xstyle,xtep,xintro,xdong,xdong2);
   xtitle:=(xstyle=chmsTitle);
   if (strcopy1(xcaption,2,1)=':') then xcaplabel:=strcopy1(xcaption,3,low__len32(xcaption));//1st two chars signifies chime type: m:=melody, b:=ships bells, s:=sonnerie - 09nov2022

   end;

end;

function tapp.xfindcolor(xname:string):longint;
begin
xfindcolor2(xname,result);
end;

function tapp.xfindcolor2(xname:string;var xindex:longint):boolean;
var
   p:longint;
begin

//defaults
result:=false;
xindex:=0;

//find
for p:=0 to (icolorcount-1) do
begin
if strmatch(xname,icolorname[p]) then
   begin
   xindex:=p;
   result:=true;
   break;
   end;
end;//p

end;

function tapp.xmorn_even(xmorning:boolean):string;
begin

result:='';

case xmorning of
true:if (imorning<>nil) then result:=low__hhmm2(60+imorning.val,itimeformat.val);
else if (ievening<>nil) then result:=low__hhmm2((13*60)+ievening.val,itimeformat.val);
end;

end;

procedure tapp._onvalcap(sender:tobject;var xcap:string);
var
   p:longint;
begin

if (sender=nil) then exit
else if (sender=imorning) then
   begin

   xcap:=imorning.caption+#32+xmorn_even(true);

   end
else if (sender=ievening) then
   begin

   xcap:=ievening.caption+#32+xmorn_even(false);

   end
else
   begin

   end;

end;

procedure tapp.xfillCustomcolors(xcolname:string);
var
   xindex,f,b:longint;
begin

xindex:=xfindcolor(xcolname);
if (icustomcolors<>nil) and (xindex>=0) and (xindex<=high(icolorname)) and (icolorfont[xindex]<=-100) then
   begin

   f                      :=frcrange32(-icolorfont[xindex]-100,0,high(icolor1));//0..9
   b                      :=frcrange32(-icolorback[xindex]-100,0,high(icolor1));//0..9

   icustomcolors.col2['f']:=icolor1[f];
   icustomcolors.col2['b']:=icolor2[b];

   end;

end;

procedure tapp.xfromCustomcolors(xcolname:string);
var
   xindex,f,b:longint;
begin

xindex:=xfindcolor(xcolname);

if (icustomcolors<>nil) and (xindex>=0) and (xindex<=high(icolorname)) then
   begin

   f          :=frcrange32(-icolorfont[xindex]-100,0,high(icolor1));//0..9
   b          :=frcrange32(-icolorback[xindex]-100,0,high(icolor1));//0..9

   icolor1[f] :=icustomcolors.col2['f'];
   icolor2[b] :=icustomcolors.col2['b'];

   end;

end;

procedure tapp.setcolorname(x:string);
begin

icolorlist.itemindex:=xfindcolor(x);
xmustcolor;//sync frame colors before initing a paint request to prevent "frame corners" from being momentarialy out-of-color-sync - 15mar2022
xfillCustomcolors( getcolorname );

end;

function tapp.getcolorname:string;
begin

result:=icolorname[frcrange32(icolorlist.itemindex,0,high(icolorname))];

end;

procedure tapp.setchimename(x:string);
begin

ichimelist.itemindex :=ichimelist.xfindbycaption2(x);

end;

function tapp.getchimename:string;
begin

result:=ichimelist.xgetval2(ichimelist.itemindex);

end;

procedure tapp.xsetnormals(const n0,n15,n30,n45:boolean);
begin

inormal0.val            :=insint(1,n0);
inormal.vals2['15']     :=n15;
inormal.vals2['30']     :=n30;
inormal.vals2['45']     :=n45;

end;

function tapp.xnormals(const xval:longint):boolean;
begin

case xval of
0 :result:=(inormal0.val<>0);
15:result:=inormal.vals2['15'];
30:result:=inormal.vals2['30'];
45:result:=inormal.vals2['45'];
end;//case

end;

procedure tapp.xsetbells(const n0:boolean);
begin

ibell0.val            :=insint(1,n0);

end;

function tapp.xbells(const xval:longint):boolean;
begin

case xval of
0 :result:=(ibell0.val<>0);
end;//case

end;

procedure tapp.xsetsons(const n0,n15,n30,n45:boolean);
begin

ison0.val            :=insint(1,n0);
ison.vals2['15']     :=n15;
ison.vals2['30']     :=n30;
ison.vals2['45']     :=n45;

end;

function tapp.xsons(const xval:longint):boolean;
begin

case xval of
0 :result:=(ison0.val<>0);
15:result:=ison.vals2['15'];
30:result:=ison.vals2['30'];
45:result:=ison.vals2['45'];
end;//case

end;

function tapp.xfindval(const xindex:longint;var s:tobject;var sn:string):boolean;

   procedure d(const d:tobject;const dn:string);
   begin

   s :=d;
   sn:=dn;

   end;

begin

//defaults
s      :=nil;
sn     :='';

//get
case xindex of

//.date style
date_show       :d(idate,'date.show');
date_uppercase  :d(idate,'date.uppercase');
date_top        :d(idate,'date.top');
date_full       :d(idate,'date.full');

//.day of the week style
day_show        :d(iday,'day.show');
day_uppercase   :d(iday,'day.uppercase');
day_top         :d(iday,'day.top');
day_full        :d(iday,'day.full');

//.reminder
rem_uppercase   :d(irem,'rem.uppercase');
rem_top         :d(irem,'rem.top');

//.part of day
pod_show        :d(ipod,'pod.show');
pod_uppercase   :d(ipod,'pod.uppercase');

//.color support
swap_colors     :d(icolopts,'swapcolors');//04dec2024
back_mix        :d(icolopts,'backmix');
flash_sep       :d(icolopts,'flashsep');//11apr2026

end;

//set
result :=(s<>nil) and (sn<>'');

end;

function tapp.getbol(xindex:longint):boolean;
var
   s:tobject;
   sn:string;
begin

if xfindval(xindex,s,sn) then
   begin

   if (s is tbasicset) then result:=(s as tbasicset).vals2[sn]
   else                     result:=false;

   end
else                        result:=false;

end;

procedure tapp.setbol(xindex:longint;xval:boolean);
var
   s:tobject;
   sn:string;
begin

if xfindval(xindex,s,sn) then
   begin

   if (s is tbasicset) then (s as tbasicset).vals2[sn]:=xval;

   end;

end;

procedure tapp.xcustomcolorchanged(sender:tobject);
begin

if (sender=icustomcolors) then
   begin

   xfromCustomcolors(colorname);
   if (icolorlist<>nil) then icolorlist.paintnow;

   end
else if (sender=icolorlist) then
   begin

   colorname:=icolorname[frcrange32(icolorlist.itemindex,0,high(icolorname))];

   end;

end;

function tapp.xstopactive:boolean;
var
   amsg:string;
   abuzzer:boolean;
   p:longint;
begin

//defaults
result:=false;

//get
if (iactbuzzer>=1) or (iactmsg<>'') then
   begin

   result             :=true;
   ialarmlist.core.stopactive;
   ilaststopactive64  :=ms64+1000;

   end;

//delayed
if (ilaststopactive64>=ms64) then result:=true;//allows for double clicks or multiple user clicks without accidently altering maximised mode - 01mar2022

end;

function tapp.xsyscol(x:longint;xforeground:boolean):longint;
begin

//defaults
result:=x;

//get
if xforeground then
   begin
   case result of
   -1:result:=vinormal.font;
   -2:result:=vititle.font;
   -3:result:=vinormal.frame;
   -109..-100:result:=icolor1[-result-100];//icolor1[0..9]
   end;//case
   end
else
   begin
   case result of
   -1:result:=vinormal.background;
   -2:result:=vititle.background;
   -3:result:=vinormal.frame2;
   -109..-100:result:=icolor2[-result-100];//icolor2[0..9]
   end;//case
   end;

end;

function tapp.xmustcolor:boolean;
var
   b,f,int1:longint;
   xswapcolors:boolean;

   function xframeouter:longint;
   begin

   case iframestyle.val of
   0    :result:=int__splice24(0.1,ibackcolor,0);
   1    :result:=int__splice24(0.1,ifontcolor,0);
   2    :result:=ibackcolor;
   3    :result:=ifontcolor;
   4    :result:=0;
   5    :result:=rgba0__int(190,190,190);
   else  result:=0;
   end;//case

   end;

   function xframeinner:longint;
   begin

   case iframestyle.val of
   0    :result:=int__splice24(0.1,ibackcolor,rgba0__int(255,255,255));
   1    :result:=int__splice24(0.1,ifontcolor,rgba0__int(255,255,255));
   2    :result:=ifontcolor;
   3    :result:=ibackcolor;
   4    :result:=rgba0__int(50,50,50);
   5    :result:=rgba0__int(255,255,255);
   else  result:=0;
   end;//case

   end;

begin

//defaults
result:=false;

//init
xswapcolors :=bol[swap_colors];
if low__setstr(ilastcolname,colorname) or (icolorindex<0) or (icolorindex>high(icolorname)) then icolorindex:=xfindcolor(colorname);

//.b
b           :=xsyscol(icolorback[icolorindex],false);

//.f
f           :=xsyscol(icolorfont[icolorindex],true);

//.mix
if bol[back_mix] then
   begin

   b        :=low__colsplice(20,f,b);

   end;

//.back
if low__setint( ibackcolor ,low__aorb(b,f,xswapcolors) ) then result:=true;

//.font
if low__setint( ifontcolor ,low__aorb(f,b,xswapcolors) ) then result:=true;

//.frame - 04dec2025
if low__setint(iframeOuterColor, xframeouter)            then result:=true;
if low__setint(iframeInnerColor, xframeinner)            then result:=true;

//high speed
if result                                                then app__turbo;

end;

function tapp.xmustframe:boolean;//fixed 04dec2025, 06nov2022
begin

//defaults
result                :=false;

//framebrightness
rootwin.oframecolor   :=int__splice24_100( iframebrightness ,0 ,iframeOuterColor );
rootwin.oframecolor2  :=int__splice24_100( iframebrightness ,0 ,iframeInnerColor );

//ref
if low__setstr(iframeref,intstr32(rootwin.oframecolor)+'|'+intstr32(rootwin.oframecolor2)+'|'+intstr32(vititle.frame)+'|'+intstr32(vititle.frame2)) then result:=true;

end;

function tapp.xmustclock:boolean;
var
   f:tclockfaceinfo;
   xmustquieten,xmustquieten2,xforcebright,xforcedim:boolean;
   xshadepower,xshadestyle,xautodim:longint;
   v:string;
   
begin

//defaults
result               :=false;
xmustquieten         :=false;
xmustquieten2        :=false;

//check -> don't update whilst resizing -> faster - 07apr2026
if gui.resizing then exit;

//init
xautodim             :=iautodim.val;
xshadepower          :=ishadepower.val;
xshadestyle          :=ishadestyle.val;
ifinalFeather4         :=ifeather.val;
xforcedim            :=false;
xforcebright         :=false;

//.only update width and height if app is visible - 09apr2026
if gui.showing and ( (ifinalWidth<>gui.width) or (ifinalHeight<>gui.height) ) then
   begin

   ifinalWidth        :=gui.width;
   ifinalHeight       :=gui.height;

   //used to reset idle period when app is resized - 09apr2026
   xnotIdle;

   end;

//get
if xmustcolor then result:=true;//check color

f.date            :=xdate__now;
f.zoom            :=10.0;//10x -> a little larger than 1920x1080 -> no need to switch fonts or adapt too much
f.actbuzzer       :=iactbuzzer;
f.actmsg          :=iactmsg;
f.remmsg          :=iremmsg;
f.daytop          :=bol[day_top];
f.remtop          :=bol[rem_top];
f.datetop         :=bol[date_top];
f.havebuzzer      :=ihavebuzzer;
f.havemsg         :=ihavemsg;
f.haveremmsg      :=ihaveremmsg;
//was: f.flash           :=(sysflash and ((iactbuzzer>=1) or (iactmsg<>'')));
f.flash           :=(iflash1000 and ((iactbuzzer>=1) or (iactmsg<>'')));
f.dateformat      :=idateformat.val;
f.timeformat      :=itimeformat.val;
f.backcolor       :=ibackcolor;
f.fontcolor       :=ifontcolor;
f.brightness      :=ibrightness.val;
f.morningMIN      :=imorning.val;
f.eveningMIN      :=ievening.val;
f.autodim         :=xautodim;
f.feather         :=ifinalFeather4;
f.showday         :=bol[day_show];
f.showpod         :=bol[pod_show];
f.showrem         :=true;
f.showdate        :=bol[date_show];
f.remUppercase    :=bol[rem_uppercase];
f.dateFull        :=bol[date_full];
f.dateUppercase   :=bol[date_uppercase];
f.dayFull         :=bol[day_full];
f.dayUppercase    :=bol[day_uppercase];
f.podUppercase    :=bol[pod_uppercase];
f.forcedim        :=xforcedim;
f.lpredawn        :=ilabel_predawn.value;
f.lmorning        :=ilabel_morning.value;
f.lafternoon      :=ilabel_afternoon.value;
f.levening        :=ilabel_evening.value;
f.showsep         :=( not bol[flash_sep] ) or iflash1000;

if low__clockface(iscreenbuffer,ibellBuffer,iscreenref,ibellref,ifontlist,f,iminfontsize2,ifinalBackColor,ifinalFontColor,ifinalBrightness,iscrollref,iscrollref2,iscrollref64,xmustquieten2) then result:=true;
if low__setstr(iscreenref2,intstr32(ifinalFeather4)+'|'+intstr32(xshadepower)+'|'+intstr32(ishadestyle.val)+'|'+intstr32(iminfontsize2)+'|'+intstr32(ifinalBackColor)+'|'+intstr32(ifinalFontColor)) then result:=true;
if low__setint(iframebrightness,(ifinalBrightness*ibrightness2.val) div 100)                                                                                                                                                          then result:=true;

//.quieten
imustquieten         :=xmustquieten or xmustquieten2;

end;

procedure tapp.xscreenpaint(sender:tobject);
var
   ref64:comp;
   da:twinrect;
   p:longint32;
begin

xscreenpaint2(sender,false);

end;

procedure tapp.xscreenpaint2(sender:tobject;dgamemode:boolean);
var
   //infovars
   a:tclientinfo;
   cw,ch:longint;

   //other
   dbrightness,xback,xfontcolor2,xback2,xshadepower,xshadestyle,xsparkle:longint;
   bs,sw,sh,dw,dh:longint;

   function xlum(xcol:longint):longint;
   begin

   result:=c24__greyscale2b(int__c24(xcol));

   end;

begin

//sync
xmustcolor;
xmustclock;

//init
iscreen.infovars(a);
xshadepower  :=frcrange32(ishadepower.val,-100,100);
xshadestyle  :=frcrange32(ishadestyle.val,0,4);
dbrightness  :=trunc32( ( ifinalBrightness / 100 ) *255 );
xfontcolor2  :=int__splice24_100( ifinalBrightness ,0 ,ifinalFontColor );
xback        :=int__splice24_100( ifinalBrightness ,0 ,ifinalBackColor );

case xshadepower of
0..max32  :xback2 :=low__sc1(xshadepower/100,xback,xfontcolor2);
min32..-1 :xback2 :=low__sc1(-xshadepower/100,xback,0);
end;//case

//.game paint mode -> faster paint with less CPU usage
case dgamemode of
true:begin

   cw       :=gui.width;
   ch       :=gui.height;
   bs       :=rootwin.findbordersize;//works with "framemax" value - 04dec2025

   if (ibuffer=nil) then ibuffer:=miswin24(1,1);

   if (cw<>misw(ibuffer)) or (ch<>mish(ibuffer)) then missize(ibuffer,cw,ch);

   end;
else
   begin

   cw       :=a.cw;
   ch       :=a.ch;
   bs       :=0;

   end;
end;//case

//make
if (xshadestyle>=1) then
   begin

   if (xlum(xback)<xlum(xback2)) then low__swapint(xback,xback2);

   end;

//cls
if dgamemode then
   begin

   //background
   if (iresSlot=res_nil) then iresSlot:=res__newfd;

   fd__select( iresSlot );
   fd__setbuffer( fd_buffer ,ibuffer );
   fd__setval( fd_power, 255 );//09apr2026

   case xshadestyle of
   0:begin//flat

      fd__setval( fd_color1, xback );
      fd__setval( fd_color2, xback );
      fd__setval( fd_splice, 100 );

      end;
   1:begin//shade

      fd__setval( fd_color1, xback2 );
      fd__setval( fd_color2, xback );
      fd__setval( fd_splice, 100 );

      end;
   2:begin//shade 2

      fd__setval( fd_color1, xback );
      fd__setval( fd_color2, xback2 );
      fd__setval( fd_splice, 100 );

      end;
   3:begin//round

      fd__setval( fd_color1, xback2 );
      fd__setval( fd_color2, xback );
      fd__setval( fd_color3, xback );
      fd__setval( fd_color4, xback2 );
      fd__setval( fd_splice, 50 );

      end;
   else begin//glow

      fd__setval( fd_color1, xback );
      fd__setval( fd_color2, xback2 );
      fd__setval( fd_color3, xback2 );
      fd__setval( fd_color4, xback );
      fd__setval( fd_splice, 50 );

      end;
   end;//case

   fd__render( fd_shadeArea );

   //frame
   xdrawframe(rootwin.oframecolor,rootwin.oframecolor2,bs,viFramecode,a.r and (gui.state<>'f'));

   end
else
   begin

   case xshadestyle of
   0   :iscreen.ffillArea  (a.cs,xback,false);//flat
   1   :iscreen.fshadeArea (a.cs,xback2,xback,false);//shade
   2   :iscreen.fshadeArea (a.cs,xback,xback2,false);//shade 2
   3   :iscreen.fshadeArea2(a.cs,xback2,xback,xback,xback2,50,255,false);//round
   else iscreen.fshadeArea2(a.cs,xback,xback2,xback2,xback,50,255,false);//glow
   end;

   end;

//draw
sw          :=misw(iscreenbuffer);
sh          :=mish(iscreenbuffer);
low__scale(cw,ch,sw,sh,dw,dh);

//.important: uses a static feather level of 1px - anything more can cause distortion problems between the 2 different text anti-alias systems - 15mar2022
case dgamemode of
true:begin

   if (dbrightness>=1) then
      begin

      fd__select( iresSlot );
      fd__defaults;
      fd__setbuffer( fd_buffer ,ibuffer );//target buffer

      fast__draw3( maxarea ,iscreenbuffer ,misarea(iscreenbuffer) ,bs + ((cw-dw) div 2) ,bs + ((ch-dh) div 2) ,frcmin32(dw-(2*bs),0) ,frcmin32(dh-(2*bs),0) ,0 ,0 ,0 ,0 ,dbrightness ,ifinalFeather4 ,false ,false );

      gui.xcopyfrom(ibuffer.dc,misarea(ibuffer),misarea(ibuffer));

      end;

   end;
else
   begin

   if (dbrightness>=1) then
      begin

      iscreen.fdraw3( iscreenbuffer ,miscellarea(iscreenbuffer,0) ,a.ci.left+(cw-dw) div 2 ,a.ci.top+(ch-dh) div 2 ,dw ,dh ,clnone ,dbrightness ,ifinalFeather4 ,false ,false ,true );

      end;

   end;
end;//case

end;

procedure tapp.gamemode__onpaint(sender:tobject);
begin

xscreenpaint2(iscreen,true);

end;

function tapp.gamemode__onnotify(sender:tobject):boolean;
begin

xscreennotify(sender);

end;

function tapp.gamemode__onshortcut(sender:tobject):boolean;
begin
result:=false;
end;

function tapp.xchimelistnotify(sender:tobject):boolean;
begin

//defaults
result:=true;//handled

if gui.mouseupstroke and gui.mousedbclick and vidoubleclicks and (low__setstr(ilastchimename,chimename) or (not chm_playing)) then xplaytestchime;

end;

function tapp.xscreennotify(sender:tobject):boolean;
var
   xmustpaint:boolean;
begin

//defaults
result         :=true;//handled
xmustpaint     :=false;

//key
if (gui.key<>aknone) then
   begin

   //any key to silence alarm
   xstopactive;

   //esc key to toggle fullscreen
   case gui.key of
   akEscape:begin

      if (gui.state='f') then gui.state:='n'
      else                    gui.state:='f';

      showpage:='';//hide the settings immediately

      xmakeidle;//hide toolbar immediately

      end;

   else xnotidle;

   end;//case

   end;

if gui.mousemoved then
   begin

   imousemoveoff:=frcmin32(imousemoveoff-1,0);
   if (imousemoveoff<=0) and ( rootwin.xhead.visible or (not iwakeonclick) ) then xnotidle;

   end;

//.inside area of screen
if gui.mousedownstroke or gui.mouseupstroke then
   begin

   iinsidescreen:=iscreen.xinsideclientarea2(iscreen.mousex,iscreen.mousey);

   //silence the alarms
   xstopactive;

   //not idle
   if rootwin.xhead.visible then xnotidle
   else if iwakeonclick then
      begin

      if gui.mouseupstroke and (not gui.mousedragging) then xnotidle;

      end
   else xnotidle;

   end;

//xmustpaint
if xmustpaint then iscreen.paintnow;

//drag support -> pass-thru "rootwin.xhead"
if (gui.mousedown or gui.mousedragging or gui.mouseupstroke) and ((gui.focuscontrol=iscreen) or gui.gamemode) then
   begin

   if (gui.state='n') then rootwin.xhead.xdragthewindow;//28nov2025

   end;

//right click -> show program menu - 06nov2022
if gui.mouseupstroke then
   begin

   //.focus the screen -> do it can accept keyboard input
   gui.focuscontrol:=iscreen;

   //.show menu
   if gui.mouseright then gui.showappmenu(true);

   end;

end;

procedure tapp.xshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
begin

//check
if zznil(xmenudata,5000) then exit;

end;

function tapp.xshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
begin

//handled
result:=true;

end;

procedure tapp.xloadsettings;
var
   a:tvars8;
   xname:string;
   p:longint;
begin
try

//defaults
a:=nil;

//check
if zznil(prgsettings,5001) then exit;

//init
a:=vnew2(950);

//filter
a.s['alarmlist']        :=prgsettings.sdef('alarmlist','');
a.s['reminderlist']     :=prgsettings.sdef('reminderlist','');
a.s['colname']          :=prgsettings.sdef('colname','Default');
a.b['swapcolors']       :=prgsettings.bdef('swapcolors',false);
a.b['backmix']          :=prgsettings.bdef('backmix',false);
a.b['flashsep']         :=prgsettings.bdef('flashsep',true);//11apr2026
a.b['showrem']          :=prgsettings.bdef('showrem',true);//09mar2022
a.i['autodim']          :=prgsettings.idef('autodim',0);
a.i['feather']          :=prgsettings.idef('feather',1);//13nov2022
a.i['shadepower']       :=prgsettings.idef('shadepower',20);//13nov2022
a.i['shadestyle']       :=prgsettings.idef('shadestyle',3);//13nov2022
a.i['autoquieten']      :=prgsettings.idef('autoquieten',0);
a.i['dateformat']       :=prgsettings.idef('dateformat',0);//04dec2025, 15nov2022
a.i['timeformat']       :=prgsettings.idef('timeformat',1);//13mar2022
a.i['framestyle']       :=prgsettings.idef('framestyle',0);//04dec2025
a.i['brightness.frame'] :=prgsettings.idef('brightness.frame',100);
a.i['brightness']       :=prgsettings.idef('brightness',100);
a.i['brightness2']      :=prgsettings.idef('brightness2',40);
a.i['morning']          :=prgsettings.idef('morning',360);
a.i['evening']          :=prgsettings.idef('evening',360);
a.s['showpage']         :=prgsettings.sdef('showpage','');//28nov2025
a.b['retainpos']        :=prgsettings.bdef('retainpos',false);//04dec2025
a.b['wakeonclick']      :=prgsettings.bdef('wakeonclick',false);//04dec2025

//.customcolors
for p:=0 to high(icolor1) do
begin
a.i['f.col'+intstr32(p)]:=prgsettings.idef('f.col'+intstr32(p),rgba0__int(255,255,255));
a.i['b.col'+intstr32(p)]:=prgsettings.idef('b.col'+intstr32(p),0);
end;

//.chime
a.s['chimename']      :=prgsettings.sdef('chimename','');//14nov2022, 14mar2022
a.b['normal0']        :=prgsettings.bdef('normal0',false);//0=Melody and Dongs, 1=Donlys Only - 14nov2022
a.b['normal15']       :=prgsettings.bdef('normal15',true);
a.b['normal30']       :=prgsettings.bdef('normal30',true);
a.b['normal45']       :=prgsettings.bdef('normal45',true);
a.b['bell0']          :=prgsettings.bdef('bell0',false);//off
a.b['bell15']         :=prgsettings.bdef('bell15',true);
a.b['bell30']         :=prgsettings.bdef('bell30',true);
a.b['bell45']         :=prgsettings.bdef('bell45',true);
a.b['son0']           :=prgsettings.bdef('son0',false);//off
a.b['son15']          :=prgsettings.bdef('son15',true);
a.b['son30']          :=prgsettings.bdef('son30',true);
a.b['son45']          :=prgsettings.bdef('son45',true);
a.b['keepopen']       :=prgsettings.bdef('keepopen',false);//13mar2022
a.b['samplechime']    :=prgsettings.bdef('samplechime',true);//06nov2022
a.i['chimespeed']     :=prgsettings.idef('chimespeed',100);
a.i['midvol']         :=prgsettings.idef('midvol',100);//09nov2022

//.day
a.b['day.show']       :=prgsettings.bdef('day.show',true);//13mar2022
a.b['day.uppercase']  :=prgsettings.bdef('day.uppercase',true);//13mar2022
a.b['day.top']        :=prgsettings.bdef('day.top',true);//13mar2022
a.b['day.full']       :=prgsettings.bdef('day.full',true);//13mar2022

//.date
a.b['date.show']      :=prgsettings.bdef('date.show',true);//13mar2022
a.b['date.uppercase'] :=prgsettings.bdef('date.uppercase',true);//13mar2022
a.b['date.top']       :=prgsettings.bdef('date.top',false);//04dec2025, 13mar2022
a.b['date.full']      :=prgsettings.bdef('date.full',true);//13mar2022
a.b['date.spread']    :=prgsettings.bdef('date.spread',false);//13mar2022

//.pod
a.b['pod.show']       :=prgsettings.bdef('pod.show',true);//15nov2022, 13mar2022
a.b['pod.uppercase']  :=prgsettings.bdef('pod.uppercase',true);//13mar2022

//.rem
a.b['rem.show']       :=prgsettings.bdef('rem.show',true);//13mar2022
a.b['rem.uppercase']  :=prgsettings.bdef('rem.uppercase',false);//13mar2022
a.b['rem.top']        :=prgsettings.bdef('rem.top',false);//13mar2022

//.part of day labels - 13mar2022
a.s['label.predawn']  :=prgsettings.sdef('label.predawn','');//13mar2022
a.s['label.morning']  :=prgsettings.sdef('label.morning','');//13mar2022
a.s['label.afternoon']:=prgsettings.sdef('label.afternoon','');//13mar2022
a.s['label.evening']  :=prgsettings.sdef('label.evening','');//13mar2022

//get
bol[swap_colors]      :=a.b['swapcolors'];
bol[back_mix]         :=a.b['backmix'];
bol[flash_sep]        :=a.b['flashsep'];//11apr2026
iwakeonclick          :=a.b['wakeonclick'];

iautodim.val          :=frcrange32(a.i['autodim'],0,9);
ifeather.val          :=frcrange32(a.i['feather'],0,4);//01dec2025, 13nov2022
ishadepower.val       :=frcrange32(a.i['shadepower'],-100,100);//04dec2025, 13nov2022
ishadestyle.val       :=frcrange32(a.i['shadestyle'],0,4);//13nov2022
iautoquieten.val      :=frcrange32(a.i['autoquieten'],0,9);
idateformat.val       :=frcrange32(a.i['dateformat'],0,5);
itimeformat.val       :=frcrange32(a.i['timeformat'],0,2);//13mar2022
iframestyle.val       :=frcrange32(a.i['framestyle'],0,iframestyle.max);//04dec2025
ibrightness2.val      :=frcrange32(a.i['brightness.frame'],10,100);
ibrightness.val       :=frcrange32(a.i['brightness'],10,100);
imorning.val          :=frcrange32(a.i['morning'],0,600);
ievening.val          :=frcrange32(a.i['evening'],0,600);
ialarmlist.text64     :=a.s['alarmlist'];//08mar2022
ireminderlist.text64  :=a.s['reminderlist'];//09mar2022

//.chime
chimename             :=chm_safename(a.s['chimename'],'*');//use system default defined internally at "tbasicchimes" as "m:Westminster" - 15nov2022

xsetnormals( a.b['normal0'], a.b['normal15'], a.b['normal30'], a.b['normal45'] );

xsetsons( a.b['son0'], a.b['son15'], a.b['son30'], a.b['son45'] );

xsetbells(a.b['bell0']);

ichimeoptions.vals2['keepopen']    :=a.b['keepopen'];
ichimeoptions.vals2['samplechime'] :=a.b['samplechime'];

ichimespeed.val       :=frcrange32(a.i['chimespeed'],25,400);
mmsys_mid_basevol     :=frcrange32(a.i['midvol'],0,200);

//.day
bol[day_show]         :=a.b['day.show'];
bol[day_uppercase]    :=a.b['day.uppercase'];
bol[day_top]          :=a.b['day.top'];
bol[day_full]         :=a.b['day.full'];

//.date
bol[date_show]        :=a.b['date.show'];
bol[date_uppercase]   :=a.b['date.uppercase'];
bol[date_top]         :=a.b['date.top'];
bol[date_full]        :=a.b['date.full'];

//.pod
bol[pod_show]         :=a.b['pod.show'];
bol[pod_uppercase]    :=a.b['pod.uppercase'];

//.rem
//was: iremshow       :=a.b['rem.show'];
bol[rem_uppercase]    :=a.b['rem.uppercase'];
bol[rem_top]          :=a.b['rem.top'];

//.part of day labels - 13mar2022
ilabel_predawn.value  :=strcopy1(a.s['label.predawn'],1,ishortlabellimit);
ilabel_morning.value  :=strcopy1(a.s['label.morning'],1,ishortlabellimit);
ilabel_afternoon.value:=strcopy1(a.s['label.afternoon'],1,ishortlabellimit);
ilabel_evening.value  :=strcopy1(a.s['label.evening'],1,ishortlabellimit);

//.customcolors
for p:=0 to high(icolor1) do
begin
icolor1[p]            :=a.i['f.col'+intstr32(p)];
icolor2[p]            :=a.i['b.col'+intstr32(p)];
end;//p

colorname             :=icolorname[xfindcolor(a.s['colname'])];

//showpage
showpage              :=a.s['showpage'];

//sync
prgsettings.data      :=a.data;


//cancel chime test playback on first load - 01dec2025
if not iloaded then xmustreplaytestchime;

except;end;

//free
freeobj(@a);
iloaded:=true;

end;

procedure tapp.xsavesettings;
var
   a:tvars8;
   p:longint;
begin
try

//check
if not iloaded then exit;

//defaults
a:=nil;
a:=vnew2(951);

//get
a.s['colname']              :=colorname;
a.b['swapcolors']           :=bol[swap_colors];
a.b['backmix']              :=bol[back_mix];
a.b['flashsep']             :=bol[flash_sep];//11apr2026
a.i['autodim']              :=frcrange32(iautodim.val,0,9);
a.i['feather']              :=frcrange32(ifeather.val,0,4);//01dec2025, 13nov2022
a.i['shadepower']           :=frcrange32(ishadepower.val,-100,100);//04dec2025, 13nov2022
a.i['shadestyle']           :=frcrange32(ishadestyle.val,0,4);//13nov2022
a.i['autoquieten']          :=frcrange32(iautoquieten.val,0,9);//12mar2022
a.i['dateformat']           :=frcrange32(idateformat.val,0,5);
a.i['timeformat']           :=frcrange32(itimeformat.val,0,2);//13mar2022
a.i['framestyle']           :=frcrange32(iframestyle.val,0,iframestyle.max);//04dec2025
a.i['brightness.frame']     :=frcrange32(ibrightness2.val,10,100);
a.i['brightness']           :=frcrange32(ibrightness.val,10,100);
a.i['morning']              :=frcrange32(imorning.val,0,600);
a.i['evening']              :=frcrange32(ievening.val,0,600);
a.s['alarmlist']            :=ialarmlist.text64;
a.s['reminderlist']         :=ireminderlist.text64;//09mar2022
a.s['showpage']             :=showpage;

//.window
a.b['wakeonclick']          :=iwakeonclick;

//.chime
a.s['chimename']            :=chm_safename(chimename,'*');
a.b['normal0']              :=xnormals(0);
a.b['normal15']             :=xnormals(15);
a.b['normal30']             :=xnormals(30);
a.b['normal45']             :=xnormals(45);
a.b['bell0']                :=xbells(0);
a.b['son0']                 :=xsons(0);
a.b['son15']                :=xsons(15);
a.b['son30']                :=xsons(30);
a.b['son45']                :=xsons(45);
a.b['keepopen']             :=ichimeoptions.vals2['keepopen'];
a.b['samplechime']          :=ichimeoptions.vals2['samplechime'];
a.i['chimespeed']           :=frcrange32(ichimespeed.val,25,400);
a.i['midvol']               :=frcrange32(mmsys_mid_basevol,0,200);//09nov2022

//.day
a.b['day.show']             :=bol[day_show];
a.b['day.uppercase']        :=bol[day_uppercase];
a.b['day.top']              :=bol[day_top];
a.b['day.full']             :=bol[day_full];

//.date
a.b['date.show']            :=bol[date_show];
a.b['date.uppercase']       :=bol[date_uppercase];
a.b['date.top']             :=bol[date_top];
a.b['date.full']            :=bol[date_full];

//.pod
a.b['pod.show']             :=bol[pod_show];
a.b['pod.uppercase']        :=bol[pod_uppercase];

//.rem
//was: a.b['rem.show']      :=iremshow;
a.b['rem.uppercase']        :=bol[rem_uppercase];
a.b['rem.top']              :=bol[rem_top];

//.part of day labels - 13mar2022
a.s['label.predawn']        :=strcopy1(ilabel_predawn.value,1,ishortlabellimit);
a.s['label.morning']        :=strcopy1(ilabel_morning.value,1,ishortlabellimit);
a.s['label.afternoon']      :=strcopy1(ilabel_afternoon.value,1,ishortlabellimit);
a.s['label.evening']        :=strcopy1(ilabel_evening.value,1,ishortlabellimit);

//.customcolors
for p:=0 to high(icolor1) do
begin
a.i['f.col'+intstr32(p)]    :=icolor1[p];
a.i['b.col'+intstr32(p)]    :=icolor2[p];
end;//p

//set
prgsettings.data            :=a.data;
siSaveprgsettings;

except;end;

//free
freeobj(@a);

end;

procedure tapp.xautosavesettings;//04dec2025
var
   str0,str1:string;
   p:longint;
begin

//check
if (not iloaded) or gui.mousedown then exit;

//get
str1:=

//.general
bolstr(iwakeonclick)+

//.showpage
#1+
showpage+#1+

//.part of day labels
ilabel_predawn.value+#1+
ilabel_morning.value+#1+
ilabel_afternoon.value+#1+
ilabel_evening.value+#1+

//.normal
bolstr(xnormals(0))+bolstr(xnormals(15))+bolstr(xnormals(30))+bolstr(xnormals(45))+

//.bell
bolstr(xbells(0))+

//.son
bolstr(xsons(0))+bolstr(xsons(15))+bolstr(xsons(30))+bolstr(xsons(45))+

//.chime
bolstr(ichimeoptions.vals2['keepopen'])+bolstr(ichimeoptions.vals2['samplechime'])+
'|'+ intstr32(ichimespeed.val) +'|'+ chimename +#1+

//.date
intstr32(idate.val)+'|'+

//.day
intstr32(iday.val)+'|'+

//.reminder
intstr32(irem.val)+'|'+

//.part of day
intstr32(ipod.val)+'|'+

//.alarm list and reminder list
intstr32(ialarmlist.core.id) +'|'+ intstr32(ireminderlist.core.id) +'|'+

//.window position/size
intstr32(gui.left)+'|'+intstr32(gui.top)+'|'+intstr32(gui.width)+'|'+intstr32(gui.height)+'|'+

//.other
intstr32(icolopts.val)+'|'+
intstr32(iautodim.val)+'|'+intstr32(ifeather.val)+'|'+intstr32(ishadepower.val)+'|'+intstr32(ishadestyle.val)+'|'+intstr32(iautoquieten.val)+'|'+
intstr32(idateformat.val)+'|'+intstr32(itimeformat.val)+'|'+
intstr32(iframestyle.val)+'|'+
intstr32(ibrightness2.val)+'|'+intstr32(ibrightness.val)+'|'+intstr32(ievening.val)+'|'+intstr32(imorning.val)+'|'+colorname;

//.custom colors
str0:='';
for p:=0 to high(icolor1) do str0:=str0+intstr32(icolor1[p])+'|'+intstr32(icolor2[p])+'|';

//set
if low__setstr(isettingsref,str0+str1) then xsavesettings;

end;

procedure tapp.__onclick(sender:tobject);
begin
xcmd(sender,0,'');
end;

procedure tapp.xcmd(sender:tobject;xcode:longint;xcode2:string);
label
   skipend;
var
   xfilterindex,int1,xtepcolor:longint;
   zok:boolean;
   v:string;
   v32:longint;

   function mv(const x:string):boolean;
   begin
   result:=strm(xcode2,x,v,v32);
   end;

   function m(const x:string):boolean;
   begin
   result:=strmatch(x,xcode2);
   end;

begin

//defaults
v       :='';
v32     :=0;

try
//init
zok     :=zzok(sender,7455);

if zok and (sender is tbasictoolbar) then
   begin
   //ours next
   xcode:=(sender as tbasictoolbar).ocode;
   xcode2:=strlow((sender as tbasictoolbar).ocode2);
   end;

//get
if      m('stop')         then chm_stop
else if m('chime.stop')   then chm_stop
else if m('chime.play')   then
   begin

   case chm_playing of
   false:xplaytestchime;
   true:chm_stop;
   end;

   end
else if mv('page.') then showpage:=v

else
   begin

   if system_debug then showbasic('Unknown Command>'+xcode2+'<<');

   end;

skipend:

//sync
xupdatebuttons;

except;end;
end;

procedure tapp.setshowpage(x:string);
begin

//range
x:=strlow(x);

if (x<>'face') and (x<>'chime') and (x<>'alarms') and (x<>'reminders') and (x<>'display') then x:='';

//get
if low__setstr(ishowpage,x) then
   begin

   rootwin.xcols.vis[isetcol]:=(ishowpage<>'');
   rootwin.xcols.cols[isetcol].page:=strdefb(ishowpage,'face');

   xnotidle;//04dec2025

   end;

//sync
xupdatebuttons;

end;


procedure tapp.xupdatebuttons;
var
   xpodshow,xmustalign:boolean;
   xnow:tdatetime;
   p:longint;
   str1:string;

   procedure sp(const n:string);//show page
   begin

   rootwin.xhead.bmarked2['page.'+n]  :=strmatch(n,ishowpage);

   end;

   function v(x:tbasiccontrol;xvisible:boolean):boolean;
   begin

   result:=(x<>nil) and (x.visible<>xvisible);

   if result then
      begin

      x.visible:=xvisible;
      xmustalign:=true;

      end;

   end;

begin

//init
xmustalign           :=false;
xnow                 :=xdate__now;
xpodshow             :=bol[pod_show];

//get
sp('face');
sp('chime');
sp('alarms');
sp('reminders');
sp('display');
sp('');//hide settings

//.auto dim
if (iautodim.val=0) then iautodim.caption:='Dim To (Off)'
else                     iautodim.caption:='Dim To  ('+xmorn_even(false)+' - '+xmorn_even(true)+')';

//.auto quieten
if (iautoquieten.val=0) then iautoquieten.caption:='Reduce Chime Volume (Off)'
else                         iautoquieten.caption:='Reduce Chime Volume To  ('+xmorn_even(false)+' - '+xmorn_even(true)+')';

//.chime speed
if (mid_speed<>ichimespeed.val) then mid_setspeed(ichimespeed.val);

//.formats
ialarmlist.otimeformat:=itimeformat.val;
ialarmlist.odateformat:=idateformat.val;

ireminderlist.otimeformat:=itimeformat.val;
ireminderlist.odateformat:=idateformat.val;

for p:=0 to 5 do
begin
str1:=xclockdatestr(xnow,p,bol[date_full]);
if bol[date_uppercase] then str1:=strup(str1);

idateformat.caps[p]:=str1;
idateformat.hlps[p]:='Date Format|Format date as "'+str1+'"';//13mar2022

end;



//.show or hide sound panels
v(inormal0,ichimelist.itemindex<ichimelist.onumberfrom2);
v(inormal,ichimelist.itemindex<ichimelist.onumberfrom2);

v(ibell0,(ichimelist.itemindex>=ichimelist.onumberfrom2) and (ichimelist.itemindex<ichimelist.onumberfrom3) );

v(ison0,ichimelist.itemindex>=ichimelist.onumberfrom3);
v(ison,ichimelist.itemindex>=ichimelist.onumberfrom3);

v(ishadepower,ishadestyle.val>=1);

v(icustomcolors,strmatch(strcopy1(colorname,1,6),'custom') );

v(idateformat,bol[date_show]);//05dec2025

v(ilabel_afternoon ,xpodshow);
v(ilabel_evening   ,xpodshow);
v(ilabel_predawn   ,xpodshow);
v(ilabel_morning   ,xpodshow);

if xmustalign then gui.fullalignpaint;

end;

procedure tapp.xplaytestchime;
begin

xmustreplaytestchime;
chm_playname3(chimename,0,xnormals(0),xnormals(15),xnormals(30),xnormals(45),xbells(0),xsons(0),xsons(15),xsons(30),xsons(45),true);

end;

function tapp.xmustreplaytestchime:boolean;
begin

result:=false;

if low__setstr(ilastchimename,chimename) then result:=true;

if low__setstr(ilasttestchimeref,

 bolstr(xnormals(0))+bolstr(xnormals(15))+bolstr(xnormals(30))+bolstr(xnormals(45))+
 bolstr(xbells(0))+
 bolstr(xsons(0))+bolstr(xsons(15))+bolstr(xsons(30))+bolstr(xsons(45))+
 '') then result:=true;

end;

procedure tapp.xnotidle;
begin

iidleref:=ms64;

end;

function tapp.xidleDelay:longint;
begin

result:=3000;//3 seconds
if viHelp_show then result:=result*10;//longer when help is visible

end;

procedure tapp.xmakeidle;
begin

iidleref       :=sub64(ms64,xidleDelay);
imousemoveoff  :=10;

end;

function tapp.xidletime(xdropBeginning:boolean):comp;

   function xreset:boolean;
   begin

   result   :=true;
   iidleref :=slowms64;

   end;
   
begin

if      (gui.winlist.count>1) and xreset then result:=0//don't allow idle when more than one window is showing -> should only be the main window (clock face)
else                                          result:=frcmin64( sub64(slowms64,iidleref) ,0 );

if xdropBeginning and (result<500)       then result:=0;

end;

procedure tapp.xautohideControlsCursor;
var
   dpert:extended;
   dshow:boolean;
begin

case (showpage='') of
true:dpert:=low__percentage64( frcmax64(xidletime(true),xidleDelay),xidleDelay);
else dpert:=0;
end;//cse

dshow                         :=(dpert<100);

rootwin.xhead.bpert2['page.'] :=dpert;

if (rootwin.xhead.visible<>dshow) or (rootwin.xhelp.showhelp<>dshow) then
   begin

   if rootwin.xhead.visible then iwasshowinghelp:=vihelp_show;

   rootwin.xhead.visible         :=dshow;
   rootwin.xhelp.showhelp        :=dshow;

   //.main help
   case dshow of
   true:if iwasshowinghelp then low__showhelp(true);
   else low__showhelp(false);
   end;

   //focus screen
   if not dshow then gui.focuscontrol:=iscreen;

   //align and paint
   rootwin.gui.fullalignpaint;

   end;

case dshow or (iwakeonclick and (low__moveidle<xidleDelay)) of
true:gui.showcursor;
else gui.hidecursor;
end;//case

gui.gamemode:=(not dshow) and (not gui.backgroundinuse) and (viBrightness=100) and viStartupdone;//viStartupdone=allows for splash screen to show during startup if enabled - 13jan2026

end;

procedure tapp.__ontimer(sender:tobject);//._ontimer
label
   skipend;
var
   a:tint4;
   b:tstr8;
   int0,int1,int2:longint;
   bol1,xmustpaintalign,xmustpaintframe,xmustpaint,xmustturbo:boolean;
   //current alarm info
   xindex,xremsecs,xbuzzer:longint;
   str1,e,xmsg:string;
   xhavebuzzer,xhavemsg:boolean;
begin
try

//init
b                :=nil;
xmustpaint       :=false;
xmustpaintframe  :=false;
xmustpaintalign  :=false;
xmustturbo       :=false;


//timer100 ---------------------------------------------------------------------

if (ms64>=itimer100) and iloaded then
   begin

   //brightness change
   if low__setint( ibrightnessREF ,ifinalBrightness ) then
      begin

      xmustpaint      :=true;//07apr2026
      xmustturbo      :=true;

      if gui.mousedown then xmustturbo:=true;//07apr2026

      end;

   //disable idle whilst one or more windows/dialogs/menus are visible - 04dec2024
   if (gui.winlist.count>1)                 then xnotidle;
   if vihelp_show and (low__inputidle<3000) then xnotidle;


   //pchimetest -> when enabled, allows for text editing/creation of midi chime and playback
   if (pchimetest<>nil) and mm_inited and low__setstr(ilastmidtest,intstr32(pchimetest.core.dataid2)) then
      begin

      if (b=nil) then b:=str__new8;

      pchimetest.iogettxt(b);

      str1            :=b.text;
      b.clear;

      if not simplemidi__make(str1,b,e) then showerror(e);

      mid_playmidi(b);

      end;


   //xmustclock
   if xmustclock then
      begin

      xmustpaint      :=true;

      if gui.mousedown then xmustturbo:=true;//13nov2022

      end;


   //xmustframe
   if xmustframe then
      begin

      xmustpaint      :=true;
      xmustpaintframe :=true;

      if gui.mousedown then xmustturbo:=true;//13nov2022

      end;


   //auto hide
   xautohideControlsCursor;


   //reset
   itimer100:=add64( ms64 ,low__aorb(100,50,xmustturbo) );


   end;

//timer250
if (ms64>=itimer250) and iloaded then
   begin

   //play
   if (ichimeoptions.vals2['samplechime'] or chm_chiming) and xmustreplaytestchime then xplaytestchime;

   if (ichimebar<>nil) then
      begin

      bol1                                :=chm_playing;
      ichimebar.benabled2['chime.stop']   :=bol1;
      ichimebar.benabled2['chime.play']   :=bol1 or (not strmatch(chimename,'none'));
      ichimebar.bflash2['chime.play']     :=bol1;
      ichimebar.bpert2['chime.play']      :=chm_chimingpert;//show chiming progress - 07mar2022

      rootwin.xhead.bflash2['page.chime'] :=bol1;
      rootwin.xhead.bpert2 ['page.chime'] :=chm_chimingpert;//show chiming progress - 07mar2022

      end;

   //check alarms + reminders
   ialarmlist.   core.findactive(xdate__now,iactindex,int0     ,int1   ,iactbuzzer,iactmsg,ihavebuzzer,ihavemsg);
   ireminderlist.core.findactive(xdate__now,iremindex,int0     ,int1   ,int2      ,iremmsg,bol1       ,ihaveremmsg);

   //sound alarm buzzer -> need to interrupt chimes playback - 01mar2022
   if ((ialarmlist<>nil) and (not ialarmlist.testingbuzzer)) and (iactbuzzer<>chm_buzzer) then chm_setbuzzer(iactbuzzer);

   //reset
   itimer250:=add64(ms64,250);

   end;

//timer500
if (ms64>=itimer500) and iloaded then
   begin

   //savesettings
   xautosavesettings;

   //chime vol (quieten to)
   if imustquieten then int1:=frcrange32((10-iautoquieten.val)*10,1,100) else int1:=100;
   if (int1<>chm_vol) then chm_setvol(int1);

   //chime playback
   //.no chiming
   if strmatch(chimename,'none') then ichimemins:=-1
   //.play chimes -> check once per minute
   else if low__setint(ichimemins, nowmin2(xdate__now) ) and chm_mustplayname(chimename,ichimemins) then
      begin

      xmustreplaytestchime;
      chm_playname3(chimename,ichimemins,xnormals(0),xnormals(15),xnormals(30),xnormals(45),xbells(0),xsons(0),xsons(15),xsons(30),xsons(45),false);

      end;

   //keep open - midi
   bol1:=ichimeoptions.vals2['keepopen'];
   if (bol1<>mid_keepopen) then mid_setkeepopen(bol1);

   //xupdatebuttons
   xupdatebuttons;

   //reset
   itimer500:=add64(ms64,500);

   end;

//timer1000
if (ms64>=itimer1000) and iloaded then
   begin

   //sync
   iflash1000         :=not iflash1000;

   //reset
   itimer1000:=add64(ms64,1000);

   end;

//debug support
if system_debug then
   begin
   if system_debugFAST then rootwin.paintallnow;
   end;
if system_debug and system_debugRESIZE then
   begin
   if (system_debugwidth<=0) then system_debugwidth:=gui.width;
   if (system_debugheight<=0) then system_debugheight:=gui.height;
   //change the width and height to stress
   //was: if (random(10)=0) then gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   end;


//mustpaint --------------------------------------------------------------------

if      gui.gamemode and (xmustpaintalign or xmustpaint) then gui.paintnow
else if xmustpaintalign                                  then gui.fullalignpaint
else if xmustpaint then
   begin

   case xmustpaintframe of
   true:rootwin.paintallnow;
   else iscreen.paintnow;
   end;//case

   end;


//mustturbo --------------------------------------------------------------------
if xmustturbo then
   begin

   app__turbo;

   end;


skipend:
except;end;

//free
if (b<>nil) then str__free(@b);

end;

function low__clockface(const xscreenBuffer:trawimage;const xbellBuffer:tbasicimage;var xscreenref,xbellref:string;var xfontlist:tfontlist;var f:tclockfaceinfo;var xoutminfontsize,xoutbackcolor,xoutfontcolor,xoutbrightness,xscrollref,xscrollref2:longint;var xscrollref64:comp;var xoutquieten:boolean):boolean;//03dec2025, 28feb2022
label//Note: Always uses "0,0,0" for transparent background no matter what tehe value of "xbackcolor" or "xfontcolor" are - 28feb2022
     //Note: Generates a greyscale image for rendering in color later
     //Note: Alarm message uses the POD (Part of Day) line for display, if POD is not visible, then it is temporarily made visible - 04dec2025
   skipend;

var
   fd:tresslot;
   fold:pfastdraw;
   b:twinrect;
   xdim,xalarmy,p,xallmin,int1,int2,int3,fi,dx,dy,xpad,hsep,sbits,sw,sh:longint;
   xth,xday,xdes,xtime,xtime2,xdate,xampm:string;
   y,m,d:word;//date
   h,min,sec,ms:word;//time

   xcanrem,xmustquieten,xdraw,bol1,bol2,dPM:boolean;

   d1:double;

   //fonts
   ai,aw,ah,ahh       :longint;//day
   bi,bw,bh,bhh       :longint;//des
   ci,cw,ch,chh,cw2   :longint;//time
   pi,pw,ph,phh       :longint;//time -> AM/PM
   di,dw,dh,dhh       :longint;//date
   ei,ew,eh,ehh       :longint;//alarm message - 01mar2022
   ri,rw,rh,rhh       :longint;//reminder message - 09mar2022

   //colors
   b32                :tcolor32;
   f32                :tcolor32;
   c1,c2              :tcolor32;

   procedure finit(xfontindex:longint32;const x:string;xsize:longint;xbold:boolean;var i,w,h,h1:longint);
   begin

   //range
   xfontindex         :=frcrange32(xfontindex,0,high(xfontlist));

   //init
   if (xfontlist[xfontindex]=res_nil) then xfontlist[xfontindex]:=res__newfont;

   i                  :=xfontlist[ xfontindex ];

   //get
   xsize              :=frcrange32(round32(xsize*f.zoom),6,900);

   res__font( i ).setparams( vifontname ,xsize ,true ,xbold ,false );

   h                  :=resfont__height(i);
   h1                 :=resfont__height1(i);
   w                  :=font__textwidth('',x,i);

   if (xsize<xoutminfontsize) then xoutminfontsize:=xsize;

   end;

   procedure fdraw2(const x:string;const dcolor,di,dx,dy:longint);
   begin

   fast__drawText( clnone ,maxarea ,maxarea ,dx ,dy ,dcolor ,'' ,x ,di ,cdNone ,f.feather );

   end;

   procedure fdraw(const x:string;const di,dx,dy:longint);
   begin

   fdraw2( x ,xoutfontcolor ,di ,dx ,dy );

   end;

   procedure xdrawbell(dx,dy,dcol:longint);
   var//Note: xbell has transparent background of red "255,0,0" don't use this color to draw the TEA - 07mar2022
      xoffset,int1,dw,dh:longint;
      dscale:double;
      rle8:tbasicrle8;
      e:string;

   begin

   //defaults
   rle8     :=nil;

   //check
   if (xbellbuffer=nil) then exit;

   try

   //bell image
   if low__setstr(xbellref ,intstr32(dcol)+'|'+intstr32(f.feather) ) then
      begin

      //tep_bell -> xbellBuffer
      mis__fromarray( xbellBuffer ,tep_bell ,e );

      //ibellBuffer -> rle8
      rle8  :=tbasicrle8.create;
      rle8.fast__makefromR2( xbellBuffer ,maxarea ,true ,false );

      //rle8 -> custom color + system feather -> ibellBuffer
      rle8.copytoimage2( xbellBuffer ,dcol ,f.feather );

      end;

   //offset
   xoffset  :=0;
   dh       :=frcmin32((ch-ph) div 2,1);
   dscale   :=dh / frcmin32(xbellbuffer.height,1);//09apr2026
   dw       :=frcmin32( round32( xbellbuffer.width * dscale ) ,1 );

   if (xampm<>'') then xoffset:=( pw - round32(xbellbuffer.width*dscale) ) div 2;

   //draw
   inc( dx ,resfont__textwidth(pi,#32) );

   //was: miscopyareaxx(maxarea,dx+xoffset,dy-dh,dw,dh,misarea(sbell),s,sbell,255,frcrange32(largest32(low__insint(2,f.feather>=1),low__insint(2,f.feather>=1)),1,2),255,0);
   mis__copyfast2( maxarea ,misarea(xbellBuffer) ,dx+xoffset ,dy-dh ,dw ,dh ,xbellBuffer ,xscreenBuffer ,255 );

   except;end;

   //free
   if (rle8<>nil)  then freeobj(@rle8);

   end;

   //paint handlers ------------------------------------------------------------

   procedure prem;
   begin

   if (f.remmsg='') or (not f.showrem) then exit;

   if not f.remtop                     then inc(dy,hsep);

   case (rw<sw) of
   true:if xdraw then fdraw(f.remmsg,ri,(sw-rw) div 2,dy);
   else begin

      int1:=resfont__textwidth(ri,strcopy1(f.remmsg,1,frcmin32(xscrollref2-6,0)));

      if xdraw then fdraw(f.remmsg,ri,-int1,dy);
      if (xscrollref2>=low__len32(f.remmsg)) then xscrollref2:=0;

      end;
   end;//case

   inc(dy,rh);

   end;

   procedure pday;
   begin

   if not f.showday then exit;
   if xdraw then fdraw(xday,ai,(sw-aw) div 2,dy);

   inc(dy,ah);

   end;

   procedure pdate;
   begin

   if not f.showdate then exit;
   if xdraw then fdraw(xdate,di,(sw-dw) div 2,dy);

   inc(dy,dh);//xx+hsep);

   end;

   procedure ppod;
   begin

   if not f.showpod then exit;
   if xdraw then fdraw(xdes,bi,(sw-bw) div 2,dy);

   xalarmy:=dy;

   inc(dy,bh);

   end;

   procedure ptime;

      procedure vdraw(const x:string;const di:longint32;dx:longint32;const dy:longint32);
      var
         h,m:string;
         p:longint;

         procedure adraw(const v:string;const vshow:boolean);
         begin

         if (v<>'') then
            begin

            if vshow then fdraw2( v ,xoutfontcolor ,di ,dx ,dy );
            
            inc( dx ,fast__textwidth( '' ,v ,di ) );

            end;

         end;

      begin

      //defaults
      h     :='';
      m     :='';

      //get
      for p:=1 to low__len32(x) do if (x[p-1+stroffset]=time_sep) then
         begin

         h  :=strcopy1(x,1,p-1);
         m  :=strcopy1(x,p+1,low__len32(x));

         break;

         end;

      //set
      adraw( h ,true );

      adraw( time_sep ,f.showsep );

      adraw( m ,true );

      end;

   begin

   //.time
   case (xampm='') of
   true:begin

      int1:=(sw-cw) div 2;
      if xdraw then vdraw(xtime,ci,int1,dy);//24hr

      end;
   else begin

      int1:=(sw-(cw+pw)) div 2;

      if xdraw then vdraw(xtime,ci,int1,dy);
      if xdraw then fdraw(xampm,pi,int1+cw,dy+chh-phh);

      end;
   end;//case

   //draw alarm bell - 07mar2022
   case (f.actbuzzer>=1) or (f.actmsg<>'') of
   true:if f.flash and xdraw                     then xdrawbell( int1+cw ,dy+chh-phh ,xoutfontcolor );
   else if xdraw and (f.havebuzzer or f.havemsg) then xdrawbell( int1+cw ,dy+chh-phh ,xoutfontcolor );
   end;//case

   inc(dy,ch);

   end;

   procedure palarm;
   var
      int1,hpad,xbordersize,eew,eeh:longint;
      b:twinrect;
   begin

   //check
   if (f.actmsg='') then exit;

   //init
   xbordersize  :=4;//not zoom based -> we use a separate system from the system zoomed font - 15mar2022
   hpad         :=xbordersize div 2;
   eew          :=frcmin32(frcmax32(ew,sw-(2*xbordersize)-(2*hpad)),0);
   eeh          :=frcmin32(frcmax32(eh,sh-(2*xbordersize)),0);

   //get - scroll long messages - 06nov2022
   b.left       :=((sw-eew) div 2)-xbordersize-hpad;
   b.right      :=b.left+eew-1+(2*xbordersize)+(2*hpad);
   b.top        :=xalarmy-xbordersize;
   //was: if xflash then inc(b.top,10);//10px or more due to image being scaled up or down -> less than 10 and we risk loosing descernable movement - 15mar2022
   b.bottom     :=b.top+eh-1+(2*xbordersize);

   //.window
   if xdraw then
      begin

      //init
      c1    :=c32__aorb(b32,f32,f.flash);
      c2    :=c32__aorb(f32,b32,f.flash);

      //cls -> erase current label, e.g. "part of day" - 10apr2026
      mis__cls2(xscreenBuffer,area__make(0,b.top,sw,b.bottom),0,0,0,0);

      //background -> color for "flash on"
      if f.flash then mis__cls2(xscreenBuffer,b,c1.r,c1.g,c1.b,c1.a);

      //text
      case (ew<sw) of
      true:fdraw2(f.actmsg,c32__int(c2),ei,b.left+(xbordersize div 2)+hpad,b.top+(xbordersize div 2));
      else begin

         int1:=resfont__textwidth(ei,strcopy1(f.actmsg,1,frcmin32(xscrollref-6,0)));

         fdraw2(f.actmsg,c32__int(c2),ei,b.left-int1,b.top+(xbordersize div 2));

         if (xscrollref>=low__len32(f.actmsg)) then xscrollref:=0;//reset

         end;
      end;//case

      end;
   end;

   procedure xdrawface;
   begin

   if f.remtop then prem;
   if f.daytop then pday;
   if f.datetop then pdate else ppod;

   ptime;

   if f.datetop then ppod else pdate;
   if not f.daytop then pday;
   if not f.remtop then prem;

   palarm;

   end;

begin
try

//defaults
result                    :=false;
fd                        :=res_nil;
fold                      :=nil;
dPM                       :=false;
hsep                      :=10;
xpad                      :=20;//edge
xoutminfontsize           :=300;
xoutbackcolor             :=f.backcolor;
xoutfontcolor             :=f.fontcolor;
xdraw                     :=false;
xmustquieten              :=false;
xalarmy                   :=0;

//.pod for alarm message
if (f.actmsg<>'') then f.showpod:=true;//04dec2025

//.dim
xdim                      :=100;//off
f.autodim                 :=frcrange32((10-f.autodim)*10,10,100);//0(off) -> 9(10%) ==>> 100% -> 10% - 12mar2022
if f.forcedim then xdim   :=f.autodim;

//range
if (f.zoom<0.1) then f.zoom:=0.1 else if (f.zoom>20) then f.zoom:=20;

d1:=f.zoom;

if not f.showday then f.zoom:=f.zoom+(d1*0.2);
if not f.showpod then f.zoom:=f.zoom+(d1*0.1);
//if (not xshowdate) or (xactmsg<>'') then xzoom:=xzoom+(d1*0.2);
if not f.showdate then f.zoom:=f.zoom+(d1*0.2);
if not f.showrem  then f.zoom:=f.zoom+(d1*0.1);

f.morningMIN               :=60+frcrange32(f.morningMIN,0,600);//1am - 11am (1 - 11)
f.eveningMIN               :=(13*60)+frcrange32(f.eveningMIN,0,600);//1pm - 11pm (13 - 23)
f.dateformat               :=frcrange32(f.dateformat,0,5);//09mar2022
f.timeformat               :=frcrange32(f.timeformat,0,2);//13mar2022

//check
if (not misok82432(xscreenBuffer,sbits,sw,sh)) or ((sbits<>24) and (sbits<>32)) then exit;

//init
if f.showrem and f.remUppercase and (f.remmsg<>'') then f.remmsg:=strup(f.remmsg);

low__decodedate2(f.date,y,m,d);
low__decodetime2(f.date,h,min,sec,ms);//h=0..23, min=0..59

xallmin                   :=(h*60)+min;

//.xday
xday                      :=low__dayofweekstr(f.date,f.dayFull);//13mar2022

if f.dayUppercase then xday:=strup(xday);

//.xzone
if (xallmin>=0) and (xallmin<f.morningmin) then
   begin

   xdes           :=strdefb(f.lpredawn,'Predawn');
   xdim           :=f.autodim;
   xmustquieten   :=true;//for host

   end
else if (xallmin>=f.morningmin) and (xallmin<(12*60)) then xdes:=strdefb(f.lmorning,'Morning')
else if (xallmin>=(12*60)) and (xallmin<f.eveningmin) then xdes:=strdefb(f.lafternoon,'Afternoon')
else if (xallmin>=f.eveningmin) and (xallmin<(24*60)) then
   begin

   xdes           :=strdefb(f.levening,'Evening');
   xdim           :=f.autodim;
   xmustquieten   :=true;//for host

   end;

if f.podUppercase then xdes:=strup(xdes);

//.xtime
case f.timeformat of
0:begin

   xtime          :=intstr32(h) + time_sep + low__digpad11(min,2);
   xtime2         :=low__digpad11(h,2) + time_sep + low__digpad11(min,2);
   xampm          :='';

   end;
else
   begin

   dPM            :=(h>=12);

   case h of
   13..23 :dec(h,12);
   24     :h:=12;//never used - 28feb2022
   0      :h:=12;//"0:00" -> "12:00am"
   end;//case

   xtime          :=intstr32(h) + time_sep + low__digpad11(min,2);
   xtime2         :=low__digpad11(h,2) + time_sep + low__digpad11(min,2);
   xampm          :=#32+low__aorbstr('am','pm',dPM);

   if (f.timeformat=1) then xampm:=strup(xampm);

   end;
end;//case

//.xdate
xdate             :=xclockdatestr(f.date,f.dateformat,f.dateFull);

if f.dateUppercase then xdate:=strup(xdate);

//.dim
f.brightness                     :=frcrange32(f.brightness,10,100);
if (xdim<100) then f.brightness  :=frcrange32((f.brightness*frcrange32(xdim,10,100)) div 100,5,100);//12mar2022
xoutbrightness                   :=f.brightness;

//.colors
xoutfontcolor                    :=int__makevis24(f.fontcolor,f.backcolor,30);
xoutbackcolor                    :=f.backcolor;

//.finit -----------------------------------------------------------------------

//.clockface.rem
if f.showrem then finit(0,strdefb(f.remmsg,'AWE'),10,false,ri,rw,rh,rhh);//larger font size of 10 required for stable operation of reminder message - 15mar2022

//.clockface.day
if f.showday then finit(1,xday,30,true,ai,aw,ah,ahh)
else
   begin

   aw       :=0;
   ah       :=0;
   ahh      :=0;

   end;

//.clockface.pod
if f.showpod then finit(2,xdes,14,true,bi,bw,bh,bhh)
else
   begin

   bw       :=0;
   bh       :=0;
   bhh      :=0;

   end;

//.clockface.time
finit(3,xtime,50,true,ci,cw,ch,chh);

//.clockface.time2
finit(4,xtime2,50,true,ci,cw2,ch,chh);//larger padding

//.clockface.ampm
finit(5,strdefb(xampm,'AWE'),25,true,pi,pw,ph,phh);

//.clockface.date
if f.showdate then finit(6,xdate,14,true,di,dw,dh,dhh);

//.clockface.msg
finit(7,f.actmsg,14,true,ei,ew,eh,ehh);//alarm

//.sw + sh
sw          :=0;

if f.showday then sw:=largest32(sw,aw);
if f.showpod then sw:=largest32(sw,bw);

sw          :=largest32(sw,pw+cw);
sw          :=largest32(sw,pw+cw2);//larger time padding

if f.showdate then sw:=largest32(sw,dw);

//was: sw:=largest(sw,ew);
inc(sw,xpad*2);

//.calc face height
dy          :=xpad;
xdraw       :=false;

xdrawface;//does not draw, only calculates dimensions

sh          :=dy+1+xpad;

//.special
xcanrem     :=f.showrem and f.haveremmsg and (f.remmsg<>'');

//detect changes - if none, then ignore - 27feb2022
if not low__setstr(xscreenref,

   //.time
   intstr32(f.timeformat)+'|'+

   //.date
   insstr( intstr32(f.dateformat)+'|'+bolstr(f.dateUppercase)+bolstr(f.datetop)+bolstr(f.dateFull),f.showdate)+

   //.day
   insstr( bolstr(f.dayUppercase)+bolstr(f.daytop)+bolstr(f.dayFull), f.showday)+

   //.reminder
   insstr( bolstr(f.showrem)+bolstr(f.remUppercase)+bolstr(f.remtop)+bolstr(f.haveremmsg)+bolstr(f.remmsg<>''), xcanrem)+

   //.part of day
   insstr( bolstr(f.showpod)+bolstr(f.podUppercase), f.showpod )+

   //.booleans
   bolstr(f.showsep) + bolstr(f.havebuzzer) + bolstr(f.havemsg) + bolstr(f.actmsg<>'')+ bolstr(f.flash) +

   //.integer32
   '|'+
   intstr32(xoutfontcolor)+'|'+intstr32(xoutbackcolor)+'|'+//07apr2026
   intstr32(f.actbuzzer) +'|'+ intstr32(xoutminfontsize) +'|'+ intstr32(f.feather) +'|'+
   floattostrex2(f.zoom) +'|'+ intstr32(sw) +'|'+ intstr32(sh) +'|'+ intstr32(hsep) +'|'+
   intstr32(aw) +'|'+ intstr32(ah) +'|'+ intstr32(bw) +'|'+ intstr32(bh) +'|'+
   intstr32(cw) +'|'+ intstr32(ch) +'|'+ intstr32(dw) +'|'+ intstr32(dh) +'|'+
   intstr32(d)+ '|'+ intstr32(m) +'|'+ intstr32(y) +'|'+
   intstr32(h) +'|'+ intstr32(min) +'|'+ f.actmsg +#1+ insstr(f.remmsg,xcanrem)

   ) then

   begin

   if (ms64>=xscrollref64) and ((ew>sw) or (rw>sw)) then
      begin
      //nil
      end
   else goto skipend;

   end;


//size + cls -------------------------------------------------------------------

if not missize(xscreenBuffer,sw,sh)         then goto skipend;
if not mis__cls(xscreenBuffer ,0 ,0 ,0 ,0 ) then goto skipend;

//.refs
if (ms64>=xscrollref64) then
   begin

   inc(xscrollref,3);
   inc(xscrollref2,3);

   xscrollref64:=ms64+1000;

   end;

if (xscrollref>1000)  then xscrollref:=0;//limit to safe max value - 06nov2022
if (xscrollref2>1000) then xscrollref2:=0;

//.colors
b32                   :=inta__c32( xoutbackcolor ,255 );
f32                   :=inta__c32( xoutfontcolor ,255 );


//.draw face
xdraw                 :=true;
dy                    :=xpad;
fd                    :=res__newfd;
fd__selstore( fold );
fd__select( fd );
fd_focus.write_a      :=true;
fd__setbuffer( fd_buffer ,xscreenBuffer );

xdrawface;//actually draws the clock face

//.mask feather
case f.feather of
1:mask__blur32( xscreenBuffer ,1 ,255 );
2:mask__blur32( xscreenBuffer ,3 ,255 );
3:mask__blur32( xscreenBuffer ,6 ,255 );
4:mask__blur32( xscreenBuffer ,9 ,255 );
end;//case

//successful
result:=true;
skipend:

except;end;

//finalise
xoutquieten           :=xmustquieten;//return reply to host -> only sync the value ONCE we have the final value - 14mar2022

//restore
if (fold<>nil)   then fd__selrestore( fold );
if (fd<>res_nil) then res__del( fd );

end;

function low__hhmm(h,m,xtimeformat:longint):string;
var
   dPM:boolean;
   str1:string;
begin

//.xtime
case xtimeformat of
0:result:=intstr32(h) + time_sep + low__digpad11(m,2);
else
   begin

   dPM      :=(h>=12);

   case h of
   13..23:dec(h,12);
   24    :h:=12;//never used - 28feb2022
   0     :h:=12;//"0:00" -> "12:00am"
   end;//case

   str1     :=low__aorbstr('am','pm',dPM);

   if (xtimeformat=1) then str1:=strup(str1);

   result   :=intstr32(h) + time_sep + low__digpad11(m,2) + #32 + str1;

   end;
end;//case

end;

function low__hhmm2(m,xtimeformat:longint):string;
var
   h:longint;
begin

h:=(m div 60);
result:=low__hhmm(h,m-(h*60),xtimeformat);

end;

function low__colsplice(x,c1,c2:longint):longint;
begin

result:=int__splice24_100(x,c2,c1);

end;

function low__sc1(xpert:extended;sc,dc:longint):longint;//shift color
begin

result:=int__splice24_100( round(xpert*100) ,sc,dc);

end;

procedure xdrawframe(const dcol,dcol2,dsize:longint;const xframecode:tstr8;const xround:boolean);
var
   da:twinrect;

   function xcornerCode:longint32;//05jan2026
   begin

   case xround of
   true:result:=fd_roundCorner;
   else result:=fd_roundNone;
   end;//case

   end;

begin

//init
da          :=fd__area( fd_bufferarea );

//reset sparkle
fd__sparkleSetPos( 0 );

//get
case (xframecode<>nil) and (xframecode.len>=1) of
true:fast__frameArea( da ,da ,xframecode ,dsize ,dcol ,dcol2 ,255 ,xcornerCode ,rmAll ,true ,xround );
else fast__frameSimpleArea( da ,da ,dsize ,dcol ,255 ,xcornerCode ,rmAll ,true ,xround);
end;//case

end;

function xdate__now:tdatetime;//override for chime debugging - 04dec2025
begin

result:=date__now;

end;

function xclockdatestr(xdate:tdatetime;xformat:longint;xfullname:boolean):string;//09mar2022
var
   y,m,d:word;
begin
//init
low__decodedate2(xdate,y,m,d);
//get
result:=xclockdate1(y,m,d,xformat,xfullname);
end;

function xclockdate1(xyear,xmonth1,xday1:longint;xformat:longint;xfullname:boolean):string;
begin
result:=xclockdate0(xyear,xmonth1-1,xday1-1,xformat,xfullname);
end;

function xclockdate0(xyear,xmonth,xday:longint;xformat:longint;xfullname:boolean):string;//03sep2025
const
   xslash=' / ';
var
   xmonthstr,xth:string;
begin

//range
xday       :=1+frcrange32(xday,0,30);
xmonth     :=1+frcrange32(xmonth,0,11);
xmonthstr  :=low__month1(xmonth,xfullname);

//init
case xday of
1,21,31 :xth:='st';
2,22    :xth:='nd';
3,23    :xth:='rd';
else     xth:='th';
end;

//get
case frcrange32(xformat,0,5) of
1    :result:=low__digpad11(xday,1)+xth+#32+xmonthstr+insstr(#32+low__digpad11(xyear,4),xyear>=0);
2    :result:=xmonthstr+#32+low__digpad11(xday,1)+insstr(', '+low__digpad11(xyear,4),xyear>=0);
3    :result:=xmonthstr+#32+low__digpad11(xday,1)+xth+insstr(', '+low__digpad11(xyear,4),xyear>=0);
4    :result:=low__digpad11(xday,1) +xslash+ low__digpad11(xmonth,1) +insstr( xslash+ low__digpad11(xyear,4),xyear>=0);//05dec2025
5    :result:=low__digpad11(xmonth,1) +xslash+ low__digpad11(xday,1) +insstr( xslash+ low__digpad11(xyear,4),xyear>=0);//05dec2025
else  result:=low__digpad11(xday,1)+#32+xmonthstr+insstr(#32+low__digpad11(xyear,4),xyear>=0);
end;//case

end;

end.

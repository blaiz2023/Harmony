unit Harmony1;
//#######################################################################################################################################
//## Control Structure:
//## TForm1 -> tbasicprg1 -> tbasicsystem (gosscore)
//## Gossamer connects to a standard Delphi form (tform1) using the tbasicprg1 object.  This object has a a tbasicsystem
//## attached (.gui), which takes control of the form and allows Gossamer to interact, paint and function.  All mouse, pen and
//## keyboard inputs funnel through into queues, and paint handling is handled internally by Gossamer.  The Delphi form itself
//## requires no special modifications.
//##
//## Code for the program is placed inside a modified copy of "tbasicprg2" object, in this case "tprogram", a compatible
//## descendant of tbasicprg1, which has the additional property of rootwin, a direct reference to the main Gossamer window.
//##
//## TForm1 loads and creates a copy of tprogram in "tform1.icore", and basically becomes a paint target and input funnel.
//##
//## Copyright (c) 1997-2023 Blaiz Enterprises
//#######################################################################################################################################
//##
//## TForm1   v1.00.032 / 22sep2021 = standard Delphi 3 form with some control handling code added to tie it to gosscore.
//##
//#######################################################################################################################################

interface

uses
{$ifdef D3}
   Windows, Forms, Controls, SysUtils, Classes, ShellApi, ShlObj, Graphics, Clipbrd,
   messages, math, extctrls{tpanel}, filectrl{tdrivetype}, ActiveX, ComObj, registry,
   gosscore, gossdat;
{$endif}
{$ifdef D10}
   System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
   FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.surfaces,
   system.dateutils, gosscore, gossdat;
{$endif}

type
  TForm1 = class(TForm)
   procedure FormCreate(Sender: TObject);
   procedure FormDestroy(Sender: TObject);
  private
   icore:tbasicprg1;//holds an active copy of "tprogram", which uses Gossamer to display the program and interact
   fonaccept:tonacceptfilesevent;
   procedure wmerasebkgnd(var message:twmerasebkgnd); message wm_erasebkgnd;
   procedure wmmousewheel(var message:tmessage); message wm_mousewheel;
   procedure wmacceptfiles(var msg:tmessage); message wm_dropfiles;//drag&drop files - 24APR2011, 07DEC2009
   procedure wndproc(var message:tmessage); override;
  public
   property onaccept:tonacceptfilesevent read fonaccept write fonaccept;//18jun2021
  end;

const
   def_vsep=10;
//high resolution sharp edged bell with a background color of "red(255,0,0)" and foreground color of "black(0,0,0)" - 07mar2022
tep_bell:array[0..1272] of byte=(
84,69,65,49,35,141,0,0,0,160,0,0,0,255,0,0,250,255,0,0,97,0,0,0,11,255,0,0,128,0,0,0,15,255,0,0,124,0,0,0,19,255,0,0,120,0,0,0,23,255,0,0,117,0,0,0,25,255,0,0,115,0,0,0,27,255,0,0,113,0,0,0,29,255,0,0,111,0,0,0,31,255,0,0,109,0,0,0,33,255,0,0,108,0,0,0,33,255,0,0,107,0,0,0,35,255,0,0,106,0,0,0,35,255,0,0,105,0,0,0,37,255,0,0,103,0,0,0,39,255,0,0,99,0,0,0,45,255,0,0,94,0,0,0,49,255,0,0,90,0,0,0,53,255,0,0,87,0,0,0,55,255,0,0,84,0,0,0,59,255,0,0,81,0,0,0,61,255,0,0,78,0,0,0,65,255,0,0,75,0,0,0,67,255,0,0,73,0,0,0,69,255,0,0,71,0,0,0,71,255,0,0,69,0,0,0,74,255,0,0,65,0,0,0,77,255,0,0,63,0,0,0,79,255,0,0,62,0,0,0,79,255,0,0,61,0,0,0,81,255,0,0,59,0,0,0,83,255,0,0,57,0,0,0,85,255,0,0,55,0,0,0,87,255,0,0,54,0,0,0,88,255,0,0,52,0,0,0,89,255,0,0,51,0,0,0,91,255,0,0,50,0,0,0,91,255,0,0,49,0,0,0,93,255,0,0,48,0,0,0,94,255,0,0,46,0,0,0,95,255,0,0,45,0,0,0,97,255,0,0,44,0,0,0,97,255,0,0,44,0,0,0,97,255,0,0,43,0,0,0,99,255,0,0,42,0,0,0,99,255,0,0,41,0,0,0,101,255,0,0,40,0,0,0,101,255,0,0,40,0,0,0,101,255,0,0,
39,0,0,0,103,255,0,0,38,0,0,0,103,255,0,0,38,0,0,0,103,255,0,0,38,0,0,0,103,255,0,0,37,0,0,0,105,255,0,0,36,0,0,0,105,255,0,0,36,0,0,0,105,255,0,0,36,0,0,0,105,255,0,0,36,0,0,0,106,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,34,0,0,0,107,255,0,0,33,0,0,0,109,255,0,0,32,0,0,0,109,255,0,0,32,0,0,0,109,255,0,0,32,
0,0,0,109,255,0,0,32,0,0,0,109,255,0,0,31,0,0,0,111,255,0,0,30,0,0,0,111,255,0,0,30,0,0,0,111,255,0,0,29,0,0,0,113,255,0,0,28,0,0,0,113,255,0,0,28,0,0,0,113,255,0,0,27,0,0,0,115,255,0,0,26,0,0,0,115,255,0,0,25,0,0,0,117,255,0,0,24,0,0,0,117,255,0,0,23,0,0,0,119,255,0,0,21,0,0,0,121,255,0,0,20,0,0,0,121,255,0,0,19,0,0,0,123,255,0,0,17,0,0,0,125,255,0,0,15,0,0,0,127,255,0,0,13,0,0,0,128,255,0,0,13,0,0,0,129,255,0,0,11,0,0,0,131,255,0,0,9,0,0,0,133,255,0,0,7,0,0,0,135,255,0,0,5,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,4,0,0,0,137,255,0,0,50,0,0,0,45,255,0,0,97,0,0,0,43,255,0,0,99,0,0,0,42,255,0,0,99,0,0,0,41,
255,0,0,101,0,0,0,39,255,0,0,102,0,0,0,39,255,0,0,103,0,0,0,37,255,0,0,105,0,0,0,35,255,0,0,107,0,0,0,33,255,0,0,109,0,0,0,31,255,0,0,112,0,0,0,27,255,0,0,115,0,0,0,25,255,0,0,118,0,0,0,21,255,0,0,122,0,0,0,17,255,0,0,128,0,0,0,9,255,0,0,250,255,0,0,98);
var
   tepBell:tlistptr;
type
{talarmlist}
//xxxxxxxxxxxxxxxxxxxxxxxxx//bbbbbbbbbbbbbbbbbbbbbbbbb
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
    ilastmin,imax,icount,iid,ipos:longint;
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
    procedure _flush;
    procedure _flushone(x:longint);
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
    property count:longint read icount;//statically locked at 30
    property id:longint read iid;//changes each time an aspect of ANY alarm changes
    property pos:longint read ipos write setpos;//0..count-1
    //pos specific information
    property year:longint read getyear write setyear;
    property month:longint read getmonth write setmonth;
    property day:longint read getday write setday;
    property dayFiltered:longint read getdayFiltered;//restricts the day to the month's upper limit based on Alarm style - 09mar2022
    property dayOfweek:longint read getdayOfweek write setdayOfweek;
    property hour:longint read gethour write sethour;
    property minute:longint read getminute write setminute;
    property duration:longint read getduration write setduration;
    property style:longint read getstyle write setstyle;
    property buzzer:longint read getbuzzer write setbuzzer;
    property msg:string read getmsg write setmsg;
    //workers
    procedure flush;//clear all
    procedure clearone;//clear one
    function finditem(xpos:longint;var xyear,xmonth,xday,adayFiltered,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer:longint;var xmsg:string):boolean;
    function findactive(xdate:tdatetime;var xindex,xremsecs,xbuzzer:longint;var xmsg:string;var xhavebuzzer,xhavemsg:boolean):boolean;
    function findalarm(xdate:tdatetime;var xindex,xremsecs,xbuzzer:longint;var xmsg:string;var xhavebuzzer,xhavemsg:boolean):boolean;//requires "omode=0"
    function findreminder(xdate:tdatetime;var xindex:longint;var xmsg:string;var xhavemsg:boolean):boolean;//09mar2022
    procedure stopactive;
    //io
    property one:string read getone write setone;//current item's data
    property text:string read gettext write settext;
    property text64:string read gettext64 write settext;
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
   end;

{tbasicalarmlist}
//xxxxxxxxxxxxxxxxxxxxxxxxxxx//aaaaaaaaaaaaaaaaaaaaaaaa
   tbasicalarmlist=class(tbasicscroll)
   private
    icore:talarmlist;
    iextcore:talarmlist;//pointer only - pointer to an external core - 13mar2022
    ilist:tbasicmenu;
    istyle,imonth,iday:tbasicsel;
    ibuzbar:tbasictoolbar;
    ibuzlist:tbasicmenu;
    idow:tbasicset;
    idur,iminute,ihour:tbasicint;
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
    procedure setextcore(x:talarmlist);
    function _onbuzlistitem(sender:tobject;xindex:longint;var xtab,xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep:boolean):boolean;
   public
    //options
    odateformat:longint;//display purposes only
    otimeformat:longint;//display purposes only
    omode:longint;//default=0=alarms, 1=reminders
    //create
    constructor create2(xparent:tobject;xscroll,xstart:boolean); override;
    destructor destroy; override;
    function xcore:talarmlist;//current core in use
    //core
    property core:talarmlist read icore;//use carefully - 09mar2022
    //internal
    procedure _ontimer(sender:tobject); override;
    procedure ____onclick(sender:tobject);
    procedure showmenuFill(xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string); override;
    function showmenuClick(sender:tobject;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean; override;
    function xlistitem(sender:tobject;xindex:longint;var xtab,xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep:boolean):boolean;
    function xtogui:boolean;//pass-thru
    function xfromgui:boolean;//pass-thru
    function xmustfromgui:boolean;
    //pos
    property pos:longint read getpos write setpos;
    //buzzer support - 14nov2022
    function canplaybuzzer:boolean;
    procedure playbuzzer;
    function canstopbuzzer:boolean;
    procedure stopbuzzer;
    function testingbuzzer:boolean;
    procedure _playbuzzer;
    //io
    property text:string read gettext write settext;
    property text64:string read gettext64 write settext;
    //special
    property extcore:talarmlist read iextcore write setextcore;//uses external core instead of internal one - 13mar2022
    //makers
    function makeAlarms:boolean;//pass-thru
    function makeReminders:boolean;//pass-thru
   end;

{tprogram}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxx//sssssssssssssssssssssssssssssssssss
   tprogram=class(tbasicprg2)
   private
    ialarmlist,ireminderlist:talarmlist;
    pchimebar:tbasictoolbar;
    iscreenbuffer,ibellbuffer:tbasicimage;
    ilastmidtest,ilabel_predawn,ilabel_morning,ilabel_afternoon,ilabel_evening,iautodimcap,iautoquietencap,iframeref,ibellref,iscreenref,iscreenref2:string;
    iscreen:tbasiccontrol;
    imustquieten,iinsidescreen,isettingssynclock,isettingsshowing,ibackmix,iswapcolors,ibuildingcontrol,iloaded:boolean;
    iscrollref64,iignoreclick64,ilaststopactive64,iflashref,iinfotimer,itimer100,itimer250,itimer500:comp;
    isettingsref:string;
    iscrollref,iscrollref2,isettings_display_firstpos,ishortlabellimit,iautodim,ishadepower,ilastfeather,ifeather,ishadestyle,iautoquieten,ialarmpos,ireminderpos,iframebrightness,itimeformat,idateformat,imorning,ievening,ibrightness4,ibrightness:longint;
    //.color support
    icolorname:array[0..199] of string;
    icolorfont:array[0..199] of longint;
    icolorback:array[0..199] of longint;
    icolorfrom1,icolorfrom2,icolorcount:longint;
    icolname:string;
    icolorindex:longint;//read only - used for painting purposes
    iminfontsize2,ifontcolor2,ibackcolor2,ibackcolor,ifontcolor:longint;//set via "xmustcolor"
    ilastcolname:string;
    //.custom colors
    icolor1:array[0..9] of longint;
    icolor2:array[0..9] of longint;
    //.alarm support
    iactindex,iactbuzzer,iactrem:longint;
    iactmsg:string;
    ihavebuzzer,ihavemsg:boolean;
    //.reminder support
    iremindex:longint;
    iremmsg:string;
    ihaveremmsg:boolean;
    //.chime support
    ichimename:string;
    ichimemins:longint;
    isamplechime,ikeepopen,inormal0,inormal15,inormal30,inormal45,ibell0,ison0,ison15,ison30,ison45:boolean;
    idayshow,idayuppercase,idaytop,idayfull:boolean;
    idateshow,idateuppercase,idatetop,idatefull,idatespread:boolean;
    ipodshow,ipoduppercase:boolean;
    iremuppercase,iremtop:boolean;
    //pointers
    ptoolbar:tbasictoolbar;
    pnormal,pson,pday,ppod,pdate,prem,pchimeoptions,psettings,pcolorsettings:tbasicset;
    pbell0,pson0,pnormal0,pdateformat,ptimeformat,pautodim,pfeather,pshadestyle,pautoquieten:tbasicsel;
    pchimespeed,pbrightness,pbrightness3,pbrightnessF,pshadepower,pmorning,pevening:tbasicint;
    plabel_predawn,plabel_morning,plabel_afternoon,plabel_evening:tbasicedit;
    pchimetest:tbasicbwp;
    pcustomcolors:tbasiccolors;
    pcolorlist,pchimelist:tbasicmenu;
    palarmlist,preminderlist:tbasicalarmlist;
    pdisplay:tbasicscroll;
    //.status support
    procedure xcmd(sender:tobject;xcode:longint;xcode2:string);
    procedure __onclick(sender:tobject);
    procedure __ontimer(sender:tobject); override;
    procedure xloadsettings;
    procedure xsavesettings;
    procedure xautosavesettings;
    procedure xshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
    function xshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
    function xstopactive:boolean;
    function xmustframe:boolean;
    function xmustcolor:boolean;
    function xmustclock:boolean;
    procedure xscreenpaint(sender:tobject);
    function xrootwinnotify(sender:tobject):boolean;
    function xscreennotify(sender:tobject):boolean;
    procedure xshowsettings_showhide;
    procedure xshowsettings_sync(sender:tobject);
    procedure xshowsettings_sync2(sender:tobject;xname:string);
    procedure xcustomcolorchanged(sender:tobject);
    procedure xshowsettings_reload;
    procedure _showsettings1(sender:tobject);
    procedure _showsettings2(sender:tobject);
    function xmorn_even(xmorning:boolean):string;
    procedure _onvalcap(sender:tobject;var xcap:string);
    function xfindcolor(xname:string):longint;
    function xfindcolor2(xname:string;var xindex:longint):boolean;
    function xlistitem(sender:tobject;xindex:longint;var xtab,xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep:boolean):boolean;
    function xsyscol(x:longint;xforeground:boolean):longint;
    procedure playtestchime;
    procedure replaychime;
    procedure __onvisync(sender:tobject);
    procedure pclear;
    procedure xfillCustomcolors(xcolname:string);
    procedure xfromCustomcolors(xcolname:string);
    //init support
    procedure xinitColors;
    procedure xinitAlarms;
    procedure xinitReminders;
   public
    //create
    constructor create(xminsysver:longint;xhost:tobject;dwidth,dheight:longint); override;
    destructor destroy; override;
    //information

    //workers

   end;

var
  Form1: TForm1;

//support for Gossamer
function tep__findcustom(xindex:longint;var xdata:tlistptr):boolean;
function low__createprogram(xhost:tobject):tbasicprg1;
procedure program__init;
procedure program__close;

//program specific low level procs
//xxxxxxxxxxxxxx//fffffffffffffffffffffffff
function low__clockface(x:tdatetime;xzoom:double;xactbuzzer:longint;xactmsg,xremmsg:string;xdaytop,xremtop,xdatetop,xhavebuzzer,xhavemsg,xhaveremmsg,xflash:boolean;xdateformat,xtimeformat,xbackcolor,xfontcolor,xbrightness,xmorningMIN,xeveningMIN,xautodim,xfeather:longint;xshowday,xshowpod,xshowrem,xshowdate,xurem,xfdate,xudate,xfday,xuday,xupod,xforcedim:boolean;var xlabel_predawn,xlabel_morning,xlabel_afternoon,xlabel_evening,xref,xbellref:string;s,sbell:tbasicimage;var xoutminfontsize,xoutbackcolor,xoutfontcolor,xoutbrightness,xscrollref,xscrollref2:longint;var xscrollref64:comp;var xoutquieten:boolean):boolean;
function low__hhmm(h,m,xtimeformat:longint):string;
function low__hhmm2(m,xtimeformat:longint):string;

//.date + alarm support procs
function low__encodealarm(xyear,xmonth,xday,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer:longint;xmsg:string;var xdata:string):boolean;
function low__decodealarm(xdata:string;var xyear,xmonth,xday,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer:longint;var xmsg:string;var xcanalarm,xchanged:boolean):boolean;
function low__decodealarmDOW(xdayOfweek:longint;var xsun,xmon,xtue,xwed,xthu,xfri,xsat:boolean):boolean;
function low__decodealarmDOW2(xdayOfweek:longint;var xsun,xmon,xtue,xwed,xthu,xfri,xsat:boolean;var xlabel:string):boolean;

implementation

{$R *.DFM}

//## tep__findcustom ##
function tep__findcustom(xindex:longint;var xdata:tlistptr):boolean;
  //## m ##
  procedure m(const x:array of byte);//map array to pointer record
  begin
  xdata:=low__maplist(x);
  end;
begin//Provide the program with a set of optional custom "tep" images, supports images in the TEA format (binary text image)
try
//defaults
result:=false;

//sample custom image support
{
case xindex of
tepRect20:m(_teprect20);
end;
{}

//successful
result:=(xdata.count>=1);
except;end;
end;
//## low__createprogram ##
function low__createprogram(xhost:tobject):tbasicprg1;
begin
try
result:=tprogram.create(0,xhost,1300,800);
result.createfinish;//perform form and POST create operations like sync main form's help visible state - 30jul2021
except;end;
end;
//## program__init ##
procedure program__init;
begin
//nil
end;
//## program__close ##
procedure program__close;
begin
//nil
end;

//## wmerasebkgnd ##
procedure tform1.wmerasebkgnd(var message:twmerasebkgnd);
begin
try;low__wmerasebkgnd(self,message);except;end;
end;
//## wmmousewheel ##
procedure tform1.wmmousewheel(var Message:tmessage);
begin
try;low__wmmousewheel(icore.gui,message);except;end;
end;
//## wmacceptfiles ##
procedure tform1.wmacceptfiles(var msg:tmessage);//drag&drop files - 24APR2011, 07DEC2009
begin
try;if assigned(fonaccept) then fonaccept(self,msg);except;end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
zzadd(self);
icore:=low__createprogram(sender);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
try;freeobj(@icore);except;end;
end;

//## wndproc ##
procedure TForm1.wndproc(var message:tmessage);//26aug2021
begin
try
//.system close - 26aug2021
if (message.msg=wm_close) then
   begin
   siCloseprompt(icore.sys);
   message.result:=0;//OK
   exit;
   end
else if (message.msg=wm_queryendsession) then//Note: this message is not always called, system overrides can bypass this and skip straight to "wm_endsession"
   begin
   message.result:=1;//OK - 26aug2021
   exit;
   end
else if (message.msg=wm_endsession) then//called if "wm_queryendsession=true"
   begin
   siCloseprompt(icore.sys);
   message.result:=0;//OK
   exit;
   end;
//.self
inherited wndproc(message);
except;end;
end;

//## talarmlist ################################################################
//## low__encodealarm ##
function low__encodealarm(xyear,xmonth,xday,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer:longint;xmsg:string;var xdata:string):boolean;
begin
try
result:=true;//pass-thru
xdata:='';
//range
xyear     :=frcrange(xyear,0000,9999);//4
xmonth    :=frcrange(xmonth,0,11);//2
xday      :=frcrange(xday,0,30);//2
xhour     :=frcrange(xhour,0,23);//2
xminute   :=frcrange(xminute,0,59);//2
xdayofweek:=frcrange(xdayofweek,0,255);//3
xduration :=frcrange(xduration,10,99999);//5 -> in seconds = 1.x days
xstyle    :=frcrange(xstyle,0,4);//1 - 0=off, 1=Daily, 2=Day of Week, 3=Month, 4=Date
xbuzzer   :=frcrange(xbuzzer,0,chm_buzzercount);//1
xmsg      :=strcopy1(xmsg,1,55);//N - short message
//get
xdata:='*'+low__digpad11(xyear,4)+low__digpad11(xmonth,2)+low__digpad11(xday,2)+low__digpad11(xhour,2)+low__digpad11(xminute,2)+low__digpad11(xdayofweek,3)+low__digpad11(xduration,5)+inttostr(xstyle)+low__digpad11(xbuzzer,2)+xmsg;//14nov2022
except;end;
end;
//## low__decodealarm ##
function low__decodealarm(xdata:string;var xyear,xmonth,xday,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer:longint;var xmsg:string;var xcanalarm,xchanged:boolean):boolean;
begin
try
//defaults
result     :=true;//pass-thru
xchanged   :=false;
//get
if (strcopy1(xdata,1,1)='*') then
   begin
   if low__setint(xyear      ,frcrange(strint(strcopy1(xdata, 2,4)),0,9999)) then xchanged:=true;
   if low__setint(xmonth     ,frcrange(strint(strcopy1(xdata, 6,2)),0,11)) then xchanged:=true;
   if low__setint(xday       ,frcrange(strint(strcopy1(xdata, 8,2)),0,30)) then xchanged:=true;
   if low__setint(xhour      ,frcrange(strint(strcopy1(xdata,10,2)),0,23)) then xchanged:=true;
   if low__setint(xminute    ,frcrange(strint(strcopy1(xdata,12,2)),0,59)) then xchanged:=true;
   if low__setint(xdayofweek ,frcrange(strint(strcopy1(xdata,14,3)),0,255)) then xchanged:=true;
   if low__setint(xduration  ,frcrange(strint(strcopy1(xdata,17,5)),10,99999)) then xchanged:=true;//in seconds = 1.x days
   if low__setint(xstyle     ,frcrange(strint(strcopy1(xdata,22,1)),0,4)) then xchanged:=true;//0=off, 1=Daily, 2=Day of Week, 3=Month, 4=Date
   if low__setint(xbuzzer    ,frcrange(strint(strcopy1(xdata,23,2)),0,chm_buzzercount)) then xchanged:=true;//14nov2022
   if low__setstr(xmsg       ,strcopy1(xdata,25,frcmax(length(xdata),55))) then xchanged:=true;//14nov2022, short message - 13mar2022
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
except;end;
end;
//## low__decodealarmDOW ##
function low__decodealarmDOW(xdayOfweek:longint;var xsun,xmon,xtue,xwed,xthu,xfri,xsat:boolean):boolean;
var
   a:tint4;
begin
try
//defaults
result:=true;//pass-thru
//get
a.val:=frcrange(xdayOfweek,0,255);
xsun:=(0 in a.bits);
xmon:=(1 in a.bits);
xtue:=(2 in a.bits);
xwed:=(3 in a.bits);
xthu:=(4 in a.bits);
xfri:=(5 in a.bits);
xsat:=(6 in a.bits);
except;end;
end;
//## low__decodealarmDOW2 ##
function low__decodealarmDOW2(xdayOfweek:longint;var xsun,xmon,xtue,xwed,xthu,xfri,xsat:boolean;var xlabel:string):boolean;
var
   a:tint4;
begin
try
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
except;end;
end;
//## create ##
constructor talarmlist.create;
begin
//self
inherited create;
//vars
ilastmin:=-1;
omode:=0;//0=alarms, 1=reminders
imax:=high(istyle);
icount:=imax+1;
iid:=0;
flush;
ipos:=0;
end;
//## destroy ##
destructor talarmlist.destroy;
begin
try
//clear

//controls

//self
inherited destroy;
except;end;
end;
//## makeAlarms ##
function talarmlist.makeAlarms:boolean;//pass-thru
begin
try;result:=true;omode:=0;except;end;
end;
//## makeReminders ##
function talarmlist.makeReminders:boolean;//pass-thru
begin
try;result:=true;omode:=1;except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxx//bbbbbbbbbbbbbbbbbbbbbbbbb
//## cancopy ##
function talarmlist.cancopy:boolean;
begin
try;result:=true;except;end;
end;
//## canpaste ##
function talarmlist.canpaste:boolean;
begin
try;result:=low__canpastetxt;except;end;
end;
//## pasteprompt1 ##
function talarmlist.pasteprompt1(xgui:tbasicsystem):boolean;//step 1 of 2
var
   l:string;
begin
try;l:=iolabel;result:=(xgui<>nil) and canpaste and xgui.popquery('Replace the currently selected '+iolabel+' with the '+l+' in Clipboard?');except;end;
end;
//## paste2 ##
function talarmlist.paste2(var e:string):boolean;//step 2 of 2
begin
try
result:=false;
e:=gecTaskfailed;
one:=clipboard.astext;
result:=true;
except;end;
end;
//## iolabel ##
function talarmlist.iolabel:string;
begin
try
case omode of
0:result:='Alarm';
1:result:='Reminder';
else result:='Alarm';
end;//case
except;end;
end;
//## ioheader ##
function talarmlist.ioheader:string;
begin
try
case omode of
0:result:='[alarms]';
1:result:='[reminders]';
else result:='[alarms]';
end;//case
except;end;
end;
//## ioext ##
function talarmlist.ioext:string;
begin
try
case omode of
0:result:=peAlarms;
1:result:=peReminders;
else result:=peAlarms;
end;//case
except;end;
end;
//## saveas ##
function talarmlist.saveas(xgui:tbasicsystem;var xlastfilename:string;xprompt:boolean;var e:string):boolean;
label
   skipend;
var
   a:tstr8;
   h:string;
begin
try
//defaults
result:=false;
e:=gecTaskfailed;
a:=nil;
h:=ioheader;
//prompt
if xprompt then
   begin
   if (xgui=nil) then goto skipend
   else if not xgui.popsave(xlastfilename,ioext,low__platfolder('misc')) then
      begin
      result:=true;
      goto skipend;
      end;
   end;
//get
a:=bnew;
a.text:=h+#10+text;
if not low__tofile(xlastfilename,a,e) then goto skipend;
//successful
result:=true;
skipend:
except;end;
try;bfree(a);except;end;
end;
//## open ##
function talarmlist.open(xgui:tbasicsystem;var xlastfilename:string;var xlastfilterindex:longint;xprompt:boolean;var e:string):boolean;
label
   skipend;
var
   a:tstr8;
   h:string;
begin
try
//defaults
result:=false;
e:=gecTaskfailed;
a:=nil;
h:=ioheader;
//prompt
if xprompt then
   begin
   if (xgui=nil) then goto skipend
   else if not xgui.popopen(xlastfilename,xlastfilterindex,ioext,low__platfolder('misc')) then
      begin
      result:=true;
      goto skipend;
      end;
   end;
//get
a:=bnew;
if not low__fromfile(xlastfilename,a,e) then goto skipend;
if not low__comparetext(strcopy1(a.text,1,length(h)),h) then
   begin
   e:=gecUnknownformat;
   goto skipend;
   end;
//set
text:=a.text;
//successful
result:=true;
skipend:
except;end;
try;bfree(a);except;end;
end;
//## stopactive ##
procedure talarmlist.stopactive;
var
   p:longint;
begin
try;for p:=0 to imax do if (ifrom64[p]<>0) then ifrom64[p]:=0;except;end;
end;
//## findactive ##
function talarmlist.findactive(xdate:tdatetime;var xindex,xremsecs,xbuzzer:longint;var xmsg:string;var xhavebuzzer,xhavemsg:boolean):boolean;
begin
try
//defaults
result:=false;
xindex:=0;
xremsecs:=0;
xbuzzer:=0;
xmsg:='';
xhavebuzzer:=false;
xhavemsg:=false;
//get
case omode of
0:result:=findalarm(xdate,xindex,xremsecs,xbuzzer,xmsg,xhavebuzzer,xhavemsg);
1:result:=findreminder(xdate,xindex,xmsg,xhavemsg);
end;//case
except;end;
end;
//## findalarm ##
function talarmlist.findalarm(xdate:tdatetime;var xindex,xremsecs,xbuzzer:longint;var xmsg:string;var xhavebuzzer,xhavemsg:boolean):boolean;
var
   y1,m1,d1:word;
   hr,min,sec,ms:word;
   xnowmin,m0,d0,di,p,xdow:longint;
   xlastfrom64,x64:comp;
   bol1:boolean;
   //## xdowOK ##
   function xdowOK(xindex:longint):boolean;
   var
      v:longint;
      xsun,xmon,xtue,xwed,xthu,xfri,xsat:boolean;
   begin
   result:=false;
   low__decodealarmDOW(idayOfweek[xindex],xsun,xmon,xtue,xwed,xthu,xfri,xsat);
   if ((xdow=0) and xsun) or ((xdow=1) and xmon) or ((xdow=2) and xtue) or ((xdow=3) and xwed) or ((xdow=4) and xthu) or ((xdow=5) and xfri) or ((xdow=6) and xsat) then result:=true;
   end;
   //## xto64 ##
   function xto64(xpos:longint):comp;
   begin
   result:=0;
   if (ifrom64[xpos]>=1) then result:=low__add64(ifrom64[xpos],iduration[xpos]*1000);
   end;
   //## xhave ##
   function xhave:boolean;
   begin
   result:=((ibuzzer[p]>=1) or (imsg[p]<>''));
   if (ibuzzer[p]>=1) then xhavebuzzer:=true;//any buzzer on any alarm
   if (imsg[p]<>'')   then xhavemsg:=true;//sames as buzzer above
   end;
begin
try
//defaults
result:=false;
xindex:=0;
xremsecs:=0;
xbuzzer:=0;
xmsg:='';
xhavebuzzer:=false;
xhavemsg:=false;
di:=-1;
x64:=frcmin64(ms64,2);//0 and 1 reserved for special purposes - 09mar2022
xlastfrom64:=0;
//check
if (omode<>0) then exit;//alarm mode only - 09mar2022
//init
low__decodedate2(xdate,y1,m1,d1);
m0:=m1-1;
d0:=d1-1;
low__decodetime2(xdate,hr,min,sec,ms);
xdow:=low__dayofweek0(xdate);
xnowmin:=(hr*60)+min;
//activate alarm -> check ONLY once per minute
if low__setint(ilastmin,xnowmin) then
   begin
   for p:=0 to imax do
   begin
   //get
   bol1:=false;
   case istyle[p] of
   1:if xhave and (hr=ihour[p]) and (min=iminute[p]) then bol1:=true;//daily
   2:if xhave and (hr=ihour[p]) and (min=iminute[p]) and xdowOK(p) then bol1:=true;//week
   3:if xhave and (hr=ihour[p]) and (min=iminute[p]) and (m0=imonth[p]) and (d0=xdayFiltered(p)) then bol1:=true;//month
   4:if xhave and (hr=ihour[p]) and (min=iminute[p]) and (y1=iyear[p]) and (m0=imonth[p]) and (d0=xdayFiltered(p)) then bol1:=true;//date
   end;//case
   //set
   if bol1 and (ifrom64[p]=0) then ifrom64[p]:=x64;//start
   end;//p
   end;

//stop alarm -> always check
for p:=0 to imax do
begin
if (istyle[p]>=1) then xhave;
if (ifrom64[p]<>0) and (x64>=xto64(p)) then ifrom64[p]:=0;//turn off the alarm - 13mar2022
end;//p

//find most recently STARTED alarm with the HIGHEST priority - 09mar2022
//.daily - lowest priority
for p:=0 to imax do if (istyle[p]=1) and (ifrom64[p]>=1) and (x64>=ifrom64[p]) and (x64<xto64(p)) and (ifrom64[p]>=xlastfrom64) then
   begin
   xlastfrom64:=ifrom64[p];
   di:=p;
   end;
//.week
for p:=0 to imax do if (istyle[p]=2) and (ifrom64[p]>=1) and (x64>=ifrom64[p]) and (x64<xto64(p)) and (ifrom64[p]>=xlastfrom64) then
   begin
   xlastfrom64:=ifrom64[p];
   di:=p;
   end;
//.month
for p:=0 to imax do if (istyle[p]=3) and (ifrom64[p]>=1) and (x64>=ifrom64[p]) and (x64<xto64(p)) and (ifrom64[p]>=xlastfrom64) then
   begin
   xlastfrom64:=ifrom64[p];
   di:=p;
   end;
//.date
for p:=0 to imax do if (istyle[p]=4) and (ifrom64[p]>=1) and (x64>=ifrom64[p]) and (x64<xto64(p)) and (ifrom64[p]>=xlastfrom64) then
   begin
   xlastfrom64:=ifrom64[p];
   di:=p;
   end;

//get
if (di>=0) and (di<=imax) and (istyle[di]>=1) then
   begin
   xindex:=di;
   xremsecs:=restrict32(frcmin64(low__div64(low__sub64(xto64(di),x64),1000),0));
   xbuzzer:=ibuzzer[di];
   xmsg:=imsg[di];
   result:=true;
   end;
except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//ffffffffffffffffffffffffffffff
//## findreminder ##
function talarmlist.findreminder(xdate:tdatetime;var xindex:longint;var xmsg:string;var xhavemsg:boolean):boolean;//09mar2022
var
   y1,m1,d1:word;
   m0,d0,di,p,xdow:longint;
   //## xdowOK ##
   function xdowOK(xindex:longint):boolean;
   var
      v:longint;
      xsun,xmon,xtue,xwed,xthu,xfri,xsat:boolean;
   begin
   result:=false;
   low__decodealarmDOW(idayOfweek[xindex],xsun,xmon,xtue,xwed,xthu,xfri,xsat);
   if ((xdow=0) and xsun) or ((xdow=1) and xmon) or ((xdow=2) and xtue) or ((xdow=3) and xwed) or ((xdow=4) and xthu) or ((xdow=5) and xfri) or ((xdow=6) and xsat) then result:=true;
   end;
   //## xhave ##
   function xhave:boolean;
   begin
   result:=(imsg[p]<>'');
   if result then xhavemsg:=true;
   end;
begin
try
//defaults
result:=false;
xindex:=0;
xmsg:='';
xhavemsg:=false;
di:=-1;
//check
if (omode<>1) then exit;//reminder mode only - 09mar2022
//init
low__decodedate2(xdate,y1,m1,d1);
m0:=m1-1;
d0:=d1-1;
xdow:=low__dayofweek0(xdate);

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
   xindex:=di;
   xmsg:=imsg[di];
   result:=true;
   end;
except;end;
end;
//## xsafepos ##
function talarmlist.xsafepos(x:longint):longint;
begin
try;result:=frcrange(x,0,imax);except;end;
end;
//## finditem ##
function talarmlist.finditem(xpos:longint;var xyear,xmonth,xday,adayFiltered,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer:longint;var xmsg:string):boolean;
begin
try
//defaults
result:=true;//pass-thru
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
except;end;
end;
//## settext ##
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
xmustid:=false;
i:=0;//must set here
s:=nil;
d:=nil;
//init
xlen:=length(x);
if (xlen<=0) then goto skipdone;
x:=x+#10;//enforce trailing return code
//base64
if low__comparetext(strcopy1(x,1,4),'b64:') then
   begin
   s:=bnew;
   d:=bnew;
   s.text:=x;
   if not low__fromb641(s,d,5,e) then goto skipdone;
   x:=d.text;
   xlen:=length(x);
   if (xlen<=0) then goto skipdone;
   bfree(s);
   bfree(d);
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
   for p:=i to imax do _flushone(p);
   xmustid:=true;
   end;
except;end;
try
if xmustid then xincid;
bfree(s);
bfree(d);
except;end;
end;
//## getone ##
function talarmlist.getone:string;
var
   i:longint;
begin
try
//defaults
result:='*';
i:=xsafepos(ipos);
//get
low__encodealarm(iyear[i],imonth[i],iday[i],ihour[i],iminute[i],idayofweek[i],iduration[i],istyle[i],ibuzzer[i],imsg[i],result);
except;end;
end;
//## setone ##
procedure talarmlist.setone(xdata:string);
var
   i:longint;
   bol1,xchanged:boolean;
begin
try
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
except;end;
end;
//## xresetactive ##
procedure talarmlist.xresetactive(xpos:longint);
begin
try;ifrom64[xsafepos(xpos)]:=0;except;end;
end;
//## _gettext ##
function talarmlist._gettext(xb64:boolean):string;
var
   a,b:tstr8;
   i:longint;
   v,e:string;
begin
try
//defaults
result:='';
a:=nil;
b:=nil;
//get
a:=bnew;
for i:=0 to imax do if low__encodealarm(iyear[i],imonth[i],iday[i],ihour[i],iminute[i],idayofweek[i],iduration[i],istyle[i],ibuzzer[i],imsg[i],v) then a.sadd(v+#10);
//set
if (a.len>=1) then
   begin
   if xb64 then
      begin
      b:=bnew;
      low__tob64(a,b,0,e);
      result:='b64:'+b.text;
      end
   else result:=a.text;
   end;
except;end;
try
bfree(a);
bfree(b);
except;end;
end;
//## gettext ##
function talarmlist.gettext:string;
begin
try;result:=_gettext(false);except;end;
end;
//## gettext64 ##
function talarmlist.gettext64:string;
begin
try;result:=_gettext(true);except;end;
end;
//## setpos ##
procedure talarmlist.setpos(x:longint);
begin
try;ipos:=xsafepos(x);except;end;
end;
//## xincid ##
function talarmlist.xincid:boolean;//pass-thru
begin
try;result:=true;low__iroll(iid,1);except;end;
end;
//## setyear ##
procedure talarmlist.setyear(x:longint);
begin
try
if low__setint(iyear[ipos],frcrange(x,0,9999)) then
   begin
   xresetactive(ipos);
   xincid;
   end;
except;end;
end;
//## getyear ##
function talarmlist.getyear:longint;
begin
try;result:=iyear[ipos];except;end;
end;
//## setmonth ##
procedure talarmlist.setmonth(x:longint);
begin
try
if low__setint(imonth[ipos],frcrange(x,0,11)) then
   begin
   xresetactive(ipos);
   xincid;
   end;
except;end;
end;
//## getmonth ##
function talarmlist.getmonth:longint;
begin
try;result:=imonth[ipos];except;end;
end;
//## setday ##
procedure talarmlist.setday(x:longint);
begin
try
if low__setint(iday[ipos],frcrange(x,0,30)) then
   begin
   xresetactive(ipos);
   xincid;
   end;
except;end;
end;
//## getday ##
function talarmlist.getday:longint;
begin
try;result:=iday[ipos];except;end;
end;
//## getdayFiltered ##
function talarmlist.getdayFiltered:longint;
begin
try;result:=xdayFiltered(ipos);except;end;
end;
//## getdayFiltered ##
function talarmlist.xdayFiltered(xpos:longint):longint;
begin
try
//range
xpos:=xsafepos(xpos);
//init
result:=iday[xpos];
//get
case istyle[xpos] of
3:result:=low__monthdayfilter0(result,imonth[xpos],low__year(1900));
4:result:=low__monthdayfilter0(result,imonth[xpos],iyear[xpos]);
end;
except;end;
end;
//## sethour ##
procedure talarmlist.sethour(x:longint);//24 hour time -> hour=0..23
begin
try
if low__setint(ihour[ipos],frcrange(x,0,23)) then
   begin
   xresetactive(ipos);
   xincid;
   end;
except;end;
end;
//## gethour ##
function talarmlist.gethour:longint;
begin
try;result:=ihour[ipos];except;end;
end;
//## setminute ##
procedure talarmlist.setminute(x:longint);//minute=0..59
begin
try
if low__setint(iminute[ipos],frcrange(x,0,59)) then
   begin
   xresetactive(ipos);
   xincid;
   end;
except;end;
end;
//## getminute ##
function talarmlist.getminute:longint;
begin
try;result:=iminute[ipos];except;end;
end;
//## setdayOfweek ##
procedure talarmlist.setdayOfweek(x:longint);
begin
try
if low__setint(idayOfweek[ipos],frcrange(x,0,255)) then
   begin
   xresetactive(ipos);
   xincid;
   end;
except;end;
end;
//## getdayOfweek ##
function talarmlist.getdayOfweek:longint;
begin
try;result:=idayOfweek[ipos];except;end;
end;
//## setduration ##
procedure talarmlist.setduration(x:longint);
begin
try;if low__setint(iduration[ipos],frcrange(x,10,99999)) then xincid;except;end;
end;
//## getduration ##
function talarmlist.getduration:longint;
begin
try;result:=iduration[ipos];except;end;
end;
//## setstyle ##
procedure talarmlist.setstyle(x:longint);
begin
try
if low__setint(istyle[ipos],frcrange(x,0,4)) then
   begin
   xresetactive(ipos);
   xincid;
   end;
except;end;
end;
//## getstyle ##
function talarmlist.getstyle:longint;
begin
try;result:=istyle[ipos];except;end;
end;
//## setbuzzer ##
procedure talarmlist.setbuzzer(x:longint);
begin
try;if low__setint(ibuzzer[ipos],frcrange(x,0,chm_buzzercount)) then xincid;except;end;
end;
//## getbuzzer ##
function talarmlist.getbuzzer:longint;
begin
try;result:=ibuzzer[ipos];except;end;
end;
//## setmsg ##
procedure talarmlist.setmsg(x:string);
begin
try;if low__setstr(imsg[ipos],strcopy1(x,1,100)) then xincid;except;end;
end;
//## getmsg ##
function talarmlist.getmsg:string;
begin
try;result:=strcopy1(imsg[ipos],1,100);except;end;
end;
//## flush ##
procedure talarmlist.flush;
begin
try;_flush;xincid;except;end;
end;
//## _flush ##
procedure talarmlist._flush;
var
   p:longint;
begin
try;for p:=0 to imax do _flushone(p);except;end;
end;
//## _flushone ##
procedure talarmlist._flushone(x:longint);
var
   p:longint;
begin
try
//range
x:=frcrange(x,0,imax);
//get
iyear[p]      :=low__year(1900);
imonth[p]     :=0;//jan
iday[p]       :=30;//31st for Dyani "DJ" the Brave Spirit - 09mar2022
ihour[p]      :=0;
iminute[p]    :=0;
idayOfweek[p] :=0;
iduration[p]  :=60;//1 minute - 15mar2022
istyle[p]     :=0;
ibuzzer[p]    :=0;
ifrom64[p]    :=0;//off
imsg[p]       :='';
except;end;
end;
//## clearone ##
procedure talarmlist.clearone;
begin
try
_flushone(ipos);
xincid;
except;end;
end;

//## tbasicalarmlist ###########################################################
//xxxxxxxxxxxxxxxxxxxxxx//aaaaaaaaaaaaaaaaa
//## create2 ##
constructor tbasicalarmlist.create2(xparent:tobject;xscroll,xstart:boolean);
var
   xhost:tbasiccontrol;
   xtmp:tbasiccontrol;
   p:longint;
   xcolorise:boolean;
   //## dint3 ##
   function dint3(xlabel,xname,xhelp:string;xmin,xmax,xdef:longint;xvalname:string):tbasicint;
   begin
   if zznil(xhost,2291) then exit;
   result:=xhost.nint3(xlabel,xhelp,xmin,xmax,xdef,0,'',xvalname);
   result.tagstr:=xname;
//   result.oautoreload:=true;
   end;
   //## dint3b ##
   function dint3b(var xout:tbasicint;xlabel,xname,xhelp:string;xmin,xmax,xdef:longint;xvalname:string):tbasicint;
   begin
   result:=dint3(xlabel,xname,xhelp,xmin,xmax,xdef,xvalname);
   xout:=result;
   end;
   //## dset ##
   function dset(xlabel,xname,xhelp:string;xdef:longint):tbasicset;
   begin
   if zznil(xhost,2292) then exit;
   result:=xhost.nset(xlabel,xhelp,xdef,0);
   result.tagstr:=xname;
//   result.oautoreload:=true;
   end;
   //## dsel3 ##
   function dsel3(xlabel,xname,xhelp:string;xdef:longint;xvalname:string):tbasicsel;
   begin
   if zznil(xhost,2293) then exit;
   result:=xhost.nsel3(xlabel,xhelp,xdef,xvalname);
   result.tagstr:=xname;
//   result.oautoreload:=true;
   end;
begin
{tbasicalarmlist}
inherited create2(xparent,false,false);//force "xscroll=false" - fixed 02aug2021
//Important Note: This options sizes the columns vertical as expected with ZERO complication - 07mar2022
oautoheight:=true;//resizable
xcolsh.ofillheight:=true;//use all client height if available
xcolorise:=true;//false;
ocanshowmenu:=true;

//options
iextcore:=nil;
odateformat:=0;
otimeformat:=1;
omode:=0;//0=alarms, 1=reminders
//vars
icore:=talarmlist.create;
ilastref:='';
ilastref2:='';
ilastref3:='';
ilastref4:='';
ilastref5:='';
itimer250:=ms64;
iplayingbuzzerREF64:=ms64;
iplayingbuzzerLEN:=30000;
ilastfilterindex:=0;
ilastfilename:=windrive+'Untitled.'+feAlarms;
imustplay:=0;//off
//controls
//.toolbar
xtoolbar.caption:='Alarms';
xtoolbar.add('Copy',tepCopy20,0,'copy','Copy selected alarm to Clipboard');
xtoolbar.add('Paste',tepPaste20,0,'paste','Replace selected alarm with Clipboard alarm');
xtoolbar.add('Open',tepOpen20,0,'open','Open alarms from file');
xtoolbar.add('Save As',tepSave20,0,'saveas','Save alarms to file');

//col 0 ------------------------------------------------------------------------
with xcolsh.cols2[0,45,false] do
begin
xhost:=client;
ilist:=nlistx('','Select item to edit',icore.count,0,nil);
ilist.ongetitem:=xlistitem;
ilist.itemindex:=0;

{
with xhigh2 do
begin
xhost:=client;
end;
{}

end;

//col 1 ------------------------------------------------------------------------
with xcolsh.cols2[1,60,true] do
begin
xhost:=client;
istyle:=dsel3('Style','style','Select alarm style',0,'');
if xcolorise then istyle.ospbackname:='blue';
istyle.xadd('Off','0','');
istyle.xadd('Daily','1','');
istyle.xadd('Week','2','');
istyle.xadd('Month','3','');
istyle.xadd('Date','4','');

iday:=dsel3('Day','day','Select day',0,'');
if xcolorise then iday.ospbackname:='green';
iday.itemsperline:=7;
for p:=0 to 30 do
begin
iday.xadd(inttostr(p+1),inttostr(p),'');
end;

imonth:=dsel3('Month','month','Select month',0,'');
if xcolorise then imonth.ospbackname:='yellow';
imonth.itemsperline:=6;
for p:=low(system_month_abrv) to high(system_month_abrv) do
begin
imonth.xadd(system_month_abrv[p],inttostr(p-1),'');
end;//p

iyear:=nedit('','Select year');
iyear.makedrop;
iyear.title:='Year';
if xcolorise then iyear.ospbackname:='orange';


idow:=dset('Day of Week','dow','Select day(s) of week',0);
if xcolorise then idow.ospbackname:='green';
idow.itemsperline:=4;
with idow do
begin
for p:=low(system_dayOfweek_abrv) to high(system_dayOfweek_abrv) do
begin
xset3(p-1,system_dayOfweek_abrv[p],'d:'+inttostr(p-1),'Select day',false,'');
end;//p
end;

ihour:=dint3('Hour','hour','Select hour',0,23,0,'');
ihour.osepv:=def_vsep;
ihour.oshowdef:=false;
if xcolorise then ihour.ospbackname:='purple';

iminute:=dint3('Minute','minute','Select minute',0,59,0,'');
iminute.oshowdef:=false;
if xcolorise then iminute.ospbackname:='purple';

idur:=dint3('Duration','dur','Set message display / audio alert duration',1,720,30,'');//2hr max in increments of 10seconds
with idur do
begin
omore:=1;
oless:=-1;
omorecap:='+10s';
olesscap:='-10s';
oshow2:=false;
oshowdef:=false;
end;//with
if xcolorise then idur.ospbackname:='purple';

imsg:=nedit('<Type a short message>','Type a short message to display on-screen when activated');
imsg.osepv:=def_vsep;
imsg.title:='Message';
imsg.olimit:=55;//55c

//.ibuzlist
ibuzbar:=ntoolbar('List of audio alerts');
ibuzbar.osepv:=10;
ibuzbar.caption:='Audio Alerts';
ibuzbar.add('Stop',tepStop20,0,'buzzer.stop','Stop audio alert');
ibuzbar.add('Play Sample',tepPlay20,0,'buzzer.play','Toggle play/stop of selected audio alert');
ibuzlist:=nlistx('','List of audio alerts',chm_buzzercount+1,frcmax(8,chm_buzzercount),_onbuzlistitem);
ibuzlist.onumberfrom:=0;
end;

//events
xtoolbar.onclick:=____onclick;
ibuzbar.onclick:=____onclick;
iyear.onclick2:=____onclick;
ihour.onvalcap:=_onvalcap;
iminute.onvalcap:=_onvalcap;
idur.onvalcap:=_onvalcap;

//start
if xstart then start;//02aug2021
end;
//## destroy ##
destructor tbasicalarmlist.destroy;
begin
try
//controls
iextcore:=nil;
freeobj(@icore);
//self
inherited destroy;
except;end;
end;
//## _onbuzlistitem ##
function tbasicalarmlist._onbuzlistitem(sender:tobject;xindex:longint;var xtab,xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep:boolean):boolean;
begin
try
xcaption:=chm_buzzerlabel(xindex);
xcaplabel:=xcaption;
xtep:=low__aorb(tepBlank20,tepMid20,xindex>=1);
except;end;
end;
//## setextcore ##
procedure tbasicalarmlist.setextcore(x:talarmlist);
begin
try
//check
if (x=iextcore) then exit;
//get
if xmustfromgui then xfromgui;
iextcore:=x;
xtogui;
except;end;
end;
//## xcore ##
function tbasicalarmlist.xcore:talarmlist;
begin
try
result:=icore;
if (iextcore<>nil) then result:=iextcore;
except;end;
end;
//## makeAlarms ##
function tbasicalarmlist.makeAlarms:boolean;//pass-thru
begin
try
result:=true;
omode:=0;
xcore.makeAlarms;
xtoolbar.caption:='Alarms';
except;end;
end;
//## makeReminders ##
function tbasicalarmlist.makeReminders:boolean;//pass-thru
begin
try
result:=true;
omode:=1;
xcore.makeReminders;
xtoolbar.caption:='Reminders';
except;end;
end;
//## _onvalcap ##
procedure tbasicalarmlist._onvalcap(sender:tobject;var xval:string);
var
   v,h,m,s:longint;
begin
try
if (sender=ihour) then
   begin
   xval:='Hour '+low__hour0(ihour.val,'',otimeformat=1,true,otimeformat=0);
   end
else if (sender=iminute) then
   begin
   xval:='Minute '+inttostr(iminute.val);
   end
else if (sender=idur) then
   begin
   //init
   v:=idur.val*10;//blocks of 10 seconds -> seconds
   //.h
   h:=v div 3600;
   v:=frcmin(v-(h*3600),0);
   //.m
   m:=v div 60;
   v:=frcmin(v-(m*60),0);
   //.s
   s:=v;
   //get
   xval:='Duration '+low__insstr(inttostr(h)+'h ',h>=1)+low__insstr(low__digpad11(m,2)+'m ',(h>=1) or (m>=1))+low__digpad11(s,2)+'s';
   end;
except;end;
end;
//## gettext ##
function tbasicalarmlist.gettext:string;
begin
try
if xmustfromgui then xfromgui;
result:=xcore.text;
except;end;
end;
//## gettext64 ##
function tbasicalarmlist.gettext64:string;
begin
try
if xmustfromgui then xfromgui;
result:=xcore.text64;
except;end;
end;
//## settext ##
procedure tbasicalarmlist.settext(x:string);
begin
try
if xmustfromgui then xfromgui;
xcore.text:=x;
xcore.pos:=pos;
except;end;
end;
//## xmustfromgui ##
function tbasicalarmlist.xmustfromgui:boolean;
begin
try
result:=low__setstr(ilastref2,
 inttostr(imonth.val)+'|'+
 inttostr(iday.val)+'|'+
 inttostr(ihour.val)+'|'+
 inttostr(iminute.val)+'|'+
 inttostr(idow.val)+'|'+
 inttostr(idur.val)+'|'+
 inttostr(istyle.val)+'|'+
 inttostr(ibuzlist.itemindex)+'|'+
 iyear.value+#1+
 imsg.value+
 '');
except;end;
end;
//## getpos ##
function tbasicalarmlist.getpos:longint;
begin
try;result:=frcrange(ilist.itemindex,0,xcore.count-1);except;end;
end;
//## getpos ##
procedure tbasicalarmlist.setpos(x:longint);
begin
try
x:=frcrange(x,0,xcore.count-1);
if (x<>ilist.itemindex) then
   begin
   if xmustfromgui then xfromgui;
   ilist.itemindex:=x;
   end;
except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxx//aaaaaaaaaaaaaaaaaaa
//## xtogui ##
function tbasicalarmlist.xtogui:boolean;//pass-thru
begin
try
result:=true;
if xmustfromgui then xfromgui;
imonth.val:=xcore.month;
iday.val:=xcore.day;
iminute.val:=xcore.minute;
ihour.val:=xcore.hour;
idow.val:=xcore.dayOfweek;
idur.val:=xcore.duration div 10;
ibuzlist.itemindex:=xcore.buzzer;//14nov2022
istyle.val:=xcore.style;
iyear.value:=inttostr(xcore.year);
imsg.value:=xcore.msg;
except;end;
end;
//## xfromgui ##
function tbasicalarmlist.xfromgui:boolean;//pass-thru
begin
try
result:=true;
xcore.month:=imonth.val;
xcore.minute:=iminute.val;
xcore.hour:=ihour.val;
xcore.day:=iday.val;
xcore.dayOfweek:=idow.val;
xcore.buzzer:=ibuzlist.itemindex;
xcore.duration:=idur.val*10;
xcore.style:=istyle.val;
xcore.year:=strint(low__udv(iyear.value,low__yearstr(0)));
xcore.msg:=imsg.value;
xmustfromgui;
except;end;
end;
//## xlistitem ##
function tbasicalarmlist.xlistitem(sender:tobject;xindex:longint;var xtab,xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep:boolean):boolean;
var
   xyear,xmonth,xday,xdayFiltered,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer:longint;
   n,xdow,asep,xtime,xmsg:string;
   xsun,xmon,xtue,xwed,xthu,xfri,xsat:boolean;
begin
try
//defaults
result:=false;
//get
if (sender=ilist) then
   begin
   //init
   asep:=' .. ';
   xindex:=frcrange(xindex,0,xcore.count-1);
   n:=inttostr(xindex+1)+'.  ';
   case omode of
   0:xtep:=tepClock20;//alarm
   1:xtep:=tepAlert20;//reminder
   else xtep:=tepClock20;//other
   end;
   xcore.finditem(xindex,xyear,xmonth,xday,xdayFiltered,xhour,xminute,xdayofweek,xduration,xstyle,xbuzzer,xmsg);
   case omode of
   0:xtime:=low__time0(xhour,xminute,'','',otimeformat=1,otimeformat=0)+asep;
   else xtime:='';
   end;//case
   low__decodealarmDOW2(xdayofweek,xsun,xmon,xtue,xwed,xthu,xfri,xsat,xdow);
   //get
   if (xstyle>=1) and (xmsg='') and (xbuzzer=0) then
      begin
      case omode of
      0:xcaption:='< Set Message / Audio Alert>';
      else xcaption:='< Set Message >';
      end;//case
      end
   else
      begin
      case xstyle of
      1:xcaption:=n+xtime+'Daily';
      2:xcaption:=n+xtime+low__udv(xdow,'< Select a Day >');
      3:xcaption:=n+xtime+low__date0(-1,xmonth,xdayFiltered,odateformat,false);
      4:xcaption:=n+xtime+low__date0(xyear,xmonth,xdayFiltered,odateformat,false);
      else xcaption:=n+low__aorbstr('< Not Set >','< Off >',(xbuzzer>=1) or (xmsg<>''))
      end;//case
      end;
   end;
except;end;
end;
//## showmenuFill ##
procedure tbasicalarmlist.showmenuFill(xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
var
   bol1:boolean;
   int1,p:longint;
begin
try
//check
if zznil(xmenudata,2318) then exit;
xmenuname:='alarmlist.'+xstyle;
//checkers

//get
if (xstyle='year') then
   begin
   low__menutitle(xmenudata,tepnone,'Year','');
   int1:=low__year(1900);
   for p:=int1 to (int1+10) do low__menuitem2(xmenudata,tep__tick(false),inttostr(p),'Select year '+inttostr(p),'y:'+inttostr(p),100,aknone,true);
   end;
except;end;
end;
//## showmenuClick ##
function tbasicalarmlist.showmenuClick(sender:tobject;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
begin
try
//handled
result:=true;
//get
if (strcopy1(xcode2,1,2)='y:') then iyear.value:=strcopy1(xcode2,3,length(xcode2))
//.not handled
else result:=false;
except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxx//aaaaaaaaaaaaaaaaa
//## _ontimer ##
procedure tbasicalarmlist._ontimer(sender:tobject);
var
   p,xmode,xdaylimit,xstyle:longint;
   xfull,bol1:boolean;
   ext1:extended;
   //## xshowhide ##
   procedure xshowhide(x:tbasiccontrol;xvisible:boolean);
   begin
   if (x<>nil) and (x.visible<>xvisible) then
      begin
      xfull:=true;
      x.visible:=xvisible;
      end;
   end;
   //## xhide ##
   procedure xhide(x:tbasiccontrol);
   begin
   xshowhide(x,false);
   end;
   //## xshow ##
   procedure xshow(x:tbasiccontrol);
   begin
   xshowhide(x,true);
   end;
   //## xshowhideday ##
   procedure xshowhideday(xday:longint;xshow:boolean);
   begin
   if xshow then
      begin
      if (iday.caps[xday]='-') then
         begin
         iday.caps[xday]:=inttostr(xday+1);
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
try
//self
inherited _ontimer(sender);

//.timer250
if (ms64>=itimer250) then
   begin
   //get
   if xmustfromgui then xfromgui;
   if low__setstr(ilastref,inttostr(pos)) then
      begin
      xcore.pos:=pos;
      xtogui;
      end;
   if low__setstr(ilastref3,inttostr(otimeformat)) then
      begin
      ihour.paintnow;
      end;
   if low__setstr(ilastref4,inttostr(omode)+'|'+inttostr(xcore.id)+'|'+inttostr(pos)) then
      begin
      ilist.paintnow;
      end;
   if low__setstr(ilastref5,inttostr(omode)+'|'+inttostr(xcore.style)+'|'+inttostr(pos)+'|'+inttostr(xcore.id)) then
      begin
      xmode:=omode;
      xstyle:=xcore.style;
      bol1:=(xstyle>=1) and (xstyle<=4);
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
      xshowhide(ihour,bol1 and (xmode=0));
      xshowhide(iminute,bol1 and (xmode=0));
      xshowhide(idur,bol1 and (xmode=0));
      xshowhide(ibuzbar,bol1 and (xmode=0));
      xshowhide(ibuzlist,bol1 and (xmode=0));
      xshowhide(imsg,bol1);
      //sync
      if iday.visible then
         begin
         xdaylimit:=low__monthdaycount0(xcore.month,xcore.year);
         for p:=28 to 30 do xshowhideday(p,p<xdaylimit);
         end;
      if xfull then gui.fullalignpaint;
      end;
   //buttons
   xtoolbar.benabled2['copy']:=true;
   xtoolbar.benabled2['paste']:=low__canpastetxt;
   //.alarms support
   bol1:=(omode=0);
   ibuzbar.bvisible2['buzzer.stop']:=bol1;
   ibuzbar.bvisible2['buzzer.play']:=bol1;
   ibuzbar.benabled2['buzzer.stop']:=bol1 and canstopbuzzer;
   ibuzbar.benabled2['buzzer.play']:=bol1 and (canplaybuzzer or canstopbuzzer);
   ibuzbar.bflash2['buzzer.play']:=bol1 and canstopbuzzer;
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
   //.buzzer play progress
   ext1:=0;
   if testingbuzzer then ext1:=low__percentage64(low__sub64(iplayingbuzzerLEN,low__sub64(iplayingbuzzerREF64,ms64)),iplayingbuzzerLEN);
   ibuzbar.bpert2['buzzer.play']:=ext1;
   //reset
   itimer250:=ms64+250;
   end;
except;end;
end;
//## canplaybuzzer ##
function tbasicalarmlist.canplaybuzzer:boolean;
begin
try;result:=(ibuzlist.itemindex>=1);except;end;
end;
//## playbuzzer ##
procedure tbasicalarmlist.playbuzzer;
begin
try
if canplaybuzzer then
   begin
   imustplay:=1;//play
   iplayingbuzzerREF64:=ms64+iplayingbuzzerLEN;
   end;
except;end;
end;
//## _playbuzzer ##
procedure tbasicalarmlist._playbuzzer;
begin
try
if canplaybuzzer and (ibuzlist.itemindex<>chm_buzzer) and (iplayingbuzzerREF64>ms64) then
   begin
   iplayingbuzzerREF64:=ms64+iplayingbuzzerLEN;
   chm_setbuzzer(ibuzlist.itemindex);
   end;
//turn of time
if not canplaybuzzer and (iplayingbuzzerREF64>ms64) then
   begin
   iplayingbuzzerREF64:=ms64;
   end;
except;end;
end;
//## canstopbuzzer ##
function tbasicalarmlist.canstopbuzzer:boolean;
begin
try;result:=(chm_buzzer>=1) or testingbuzzer;except;end;
end;
//## stopbuzzer ##
procedure tbasicalarmlist.stopbuzzer;
begin
try
chm_setbuzzer(0);
iplayingbuzzerREF64:=ms64;
except;end;
end;
//## testingbuzzer ##
function tbasicalarmlist.testingbuzzer:boolean;
begin
try;result:=(ibuzlist.itemindex>=1) and (iplayingbuzzerREF64>ms64);except;end;
end;
//## ____onclick ##
procedure tbasicalarmlist.____onclick(sender:tobject);
var
   e,n:string;
   int1:longint;
   a:tstr8;
begin
try
//defaults
a:=nil;
if (sender<>nil) and (sender is tbasictoolbar) then
   begin
   n:=low__lowercase((sender as tbasictoolbar).ocode2);
   if (n='copy') then clipboard.astext:=xcore.one
   else if (n='paste') then
      begin
      if xcore.pasteprompt1(gui) then
         begin
         xmustfromgui;
         if not xcore.paste2(e) then gui.poperror(e);
         xtogui;
         end;
      end
   else if (n='saveas') then
      begin
      if not xcore.saveas(gui,ilastfilename,true,e) then gui.poperror(e);
      end
   else if (n='open') then
      begin
      if not xcore.open(gui,ilastfilename,ilastfilterindex,true,e) then gui.poperror(e);
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
except;end;
try;bfree(a);except;end;
end;

//## tprogram ##################################################################
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxx//ssssssssssssssssssssssssssssssssssss
//## create ##
constructor tprogram.create(xminsysver:longint;xhost:tobject;dwidth,dheight:longint);
var
   dfolder,e:string;
   p:longint;
   //xxxxxxxxxxxxxxxxxx
   b:tstr8;
   a:string;
{
   //## xmakeship ##
   procedure xmakeship(n,v1,v2:string);
   var
      b:tstr8;
      e:string;
   begin
   try
   b:=nil;
   b:=bnew;
   //v1
   if not low__makemid(v1,b,e) then showbasic('e1.1>'+e+'<<');//xxxxxxxxxx
   if not low__tofile('d:\temp\ships_ bells\'+n+'-1.mid',b,e) then showbasic('e1.2>'+e+'<<');//xxxxxxxxx
   //v2
   if not low__makemid(v2,b,e) then showbasic('e2.1>'+e+'<<');//xxxxxxxxxx
   if not low__tofile('d:\temp\ships_ bells\'+n+'-2.mid',b,e) then showbasic('e2.2>'+e+'<<');//xxxxxxxxx
   except;end;
   try;bfree(b);except;end;
   end;
   //## xmakeship2 ##
   procedure xmakeship2(n:string;xinstrument,xnote:longint);
   begin
   //init
   xinstrument:=frcrange(xinstrument,0,127);
   xnote:=frcrange(xnote,0,127);
   //get
   xmakeship(n,'0i'+inttostr(xinstrument)+' 0n'+inttostr(xnote)+' 1500x0 1500d500', '0i'+inttostr(xinstrument)+' 0n'+inttostr(xnote)+' 333x80 0n'+inttostr(xnote)+' 333x80 1000x80');
   end;
   //## xmakeship3 ##
   procedure xmakeship3(n:string;xinstrument:longint);
   var
      v:longint;
   begin
   //init
   xinstrument:=frcrange(xinstrument,0,127);
   //get
   v:=40;xmakeship2(n+low__digpad11(v,3),xinstrument,v);
   v:=50;xmakeship2(n+low__digpad11(v,3),xinstrument,v);
   v:=60;xmakeship2(n+low__digpad11(v,3),xinstrument,v);
   v:=70;xmakeship2(n+low__digpad11(v,3),xinstrument,v);
   v:=80;xmakeship2(n+low__digpad11(v,3),xinstrument,v);
   v:=90;xmakeship2(n+low__digpad11(v,3),xinstrument,v);
   v:=100;xmakeship2(n+low__digpad11(v,3),xinstrument,v);
   v:=110;xmakeship2(n+low__digpad11(v,3),xinstrument,v);
   end;
   {}//xxxxxxxxxxx debug only
begin
if system_debug then dbstatus(38,'Debug 010');//yyyy



//popup menu should have these items:
//maximise, window, minimise, close, settings, options, on top, help, mixer = 9 items

//b:=bnew;
{
a:=
'0v127'+rcode+
'0n80'+rcode+
'250n80'+rcode+
'250e'+rcode+
'';
{}

//a:='0i10 0n80 250x80 250x80';
//a:='0i10 0n70 250x70 500f100 0n80 500u100 250x80 0n70 250x70 250x70';
//a:='0i9 0n70 250x70 0d200 0n80 0u200 250x80 0n70 250x70 250x70';

//a:='0i9 0n70 250x70 0n80 250x80 0n70 250x70 250x70   0i0 0n70 250x70 0n80 250x80 0n70 250x70 250x70';
//a:='0i9 0n100 300x100 0n105 300x105 0n105 200x105 0n100 300x100 500x100';

//a:='0i9 0n100 150x100 0n100 150x100 0n105 150x105 0n105 150x105 500x105';//fast double beat

//a:='0i14 0n80 333x80 0n80 333x80 1000x80';//ships bells


//a:='0i14 0n80 333x80 1000x80';//ships bells

//a:='0i15 0n100 3600x100 100x60';
//a:='0i35 0n110 500f300 0x110 2500x110 500x110';
//a:='0i35 0n110 0x110 2500x110 500x110';

//make Ships Bells - 09nov2022
//xaddBells2(0, 'Bells 1' , '0i14 0n80 1500x0 1500d500', '0i14 0n80 333x80 0n80 333x80 1000x80' );


{
xmakeship('Twinkle','0i14 0n80 1500x0 1500d500', '0i14 0n80 333x80 0n80 333x80 1000x80');
xmakeship('Dong','0i14 0n70 1500x0 1500d500', '0i14 0n70 333x80 0n70 333x80 1000x80');
xmakeship('Low','0i14 0n50 1500x0 1500d500', '0i14 0n50 333x80 0n50 333x80 1000x80');
xmakeship('High','0i14 0n95 1500x0 1500d500', '0i14 0n95 333x80 0n95 333x80 1000x80');
xmakeship('Muted','0i15 0n95 1500x0 1500d500', '0i15 0n95 333x80 0n95 333x80 1000x80');


xmakeship('Muted','0i15 0n95 1500x0 1500d500', '0i15 0n95 333x80 0n95 333x80 1000x80');
xmakeship('Muted 2','0i13 0n95 1500x0 1500d500', '0i13 0n95 333x80 0n95 333x80 1000x80');

xmakeship('Echo','0i9 0n60 1500x0 1500d500', '0i9 0n60 333x80 0n60 333x80 1000x80');
{}

//xmakeship('Vibraphone60','0i11 0n60 1500x0 1500d500', '0i11 0n60 333x80 0n60 333x80 1000x80');
//xmakeship('Vibraphone70','0i11 0n70 1500x0 1500d500', '0i11 0n70 333x80 0n70 333x80 1000x80');
//xmakeship('Vibraphone80','0i11 0n80 1500x0 1500d500', '0i11 0n80 333x80 0n80 333x80 1000x80');
//xmakeship('Vibraphone90','0i11 0n90 1500x0 1500d500', '0i11 0n90 333x80 0n90 333x80 1000x80');
{

for p:=0 to 127 do
begin
xmakeship3('Instrument'+low__digpad11(p,3)+'__',p);
end;//i

siclose;
{}

//needers - 26sep2021
//need_man;
need_jpeg;
//need_gif;
//need_ico;
need_mm;//required
need_chimes;//required

//self
inherited create(10020602,xhost,dwidth,dheight);
ibuildingcontrol:=true;

//init
ilastmidtest:='';
imustquieten:=false;
ishortlabellimit:=22;//max of 22 chars - 15mar2022
isettings_display_firstpos:=0;
ialarmpos:=0;
ireminderpos:=0;
tepBell:=low__maplist(tep_bell);
gui.omax_entirescreen:=true;
pclear;
iinfotimer:=ms64;
itimer100:=ms64;
itimer250:=ms64;
itimer500:=ms64;
iflashref:=ms64;
iignoreclick64:=ms64;
iscrollref:=0;
iscrollref2:=0;
iscrollref64:=ms64;
ilaststopactive64:=ms64;
iframebrightness:=100;
//vars
iloaded:=false;
icolorfrom1:=0;
icolorfrom2:=0;
isettingsshowing:=false;
isettingssynclock:=false;
iscreenbuffer:=misimg32(1,1);
ibellbuffer:=misimg24(1,1);
ilabel_predawn:='';
ilabel_morning:='';
ilabel_afternoon:='';
ilabel_evening:='';
iscreenref:='';
iscreenref2:='';
ibellref:='';
iframeref:='';
iinsidescreen:=false;
iswapcolors:=false;
ibackmix:=false;
iautodim:=0;
ishadestyle:=0;
ifeather:=0;
ilastfeather:=0;
ishadepower:=20;
iautoquieten:=0;
idateformat:=0;
itimeformat:=1;
icolname:='Default';
icolorindex:=-1;//not set
ilastcolname:='';
ibackcolor:=0;
ibackcolor2:=0;
iminfontsize2:=300;
ifontcolor2:=low__rgb(255,255,255);
ifontcolor:=low__rgb(255,255,255);
ichimemins:=-1;
ialarmlist:=talarmlist.create;
ialarmlist.makeAlarms;
ireminderlist:=talarmlist.create;//09mar2022
ireminderlist.makeReminders;
ikeepopen:=false;
isamplechime:=false;

//init support -----------------------------------------------------------------
//xgrabfiles;//xxxxxxxxxx

xinitColors;
xinitAlarms;
xinitReminders;

//.midi handler
mid_setkeepopen(false);//auto closes midi device after 5 seconds of inactivity

//controls
with rootwin do
begin
scroll:=false;
xhead;
with xtoolbar do
begin
xtoolbar.xaddontop;
xtoolbar.xaddmax;
xaddmixer;//07mar2022
//was: add('Settings',tepSettings20,0,'settings','Show settings window');
//add('Test',tepNew20,0,'test','Show menu');//xxxxxxxxxx
//add('Test 2',tepNew20,0,'test2','Show menu');//xxxxxxxxxx
//add('Stop',tepNew20,0,'stop','Show menu');//xxxxxxxxxx
end;
end;

//left
//.screen
iscreen:=rootwin.ncontrol;//create a control
iscreen.oautoheight:=true;
iscreen.bordersize:=0;
iscreen.help:='Click, tap or press any key to silence active alarm(s) | Press Escape key to toggle full screen mode | Click, tap or press any key to display toolbar / controls';

//.last links on toolbar - 22mar2021
with rootwin.xtoolbar do
begin
xaddoptions;//add the system "Options" link to the toolbar
xaddhelp;//add the sytem "Help" link to the toolbar -> won't display if no help document data present in "gossdat.pas -> progamhelp array"
end;


//events
rootwin.xtoolbar.onclick:=__onclick;
rootwin.onnotify:=xrootwinnotify;//15mar2022
iscreen.onpaint:=xscreenpaint;
iscreen.onnotify:=xscreennotify;
iscreen.ocanshowmenu:=true;
//was: iscreen.showmenuFill1:=xshowmenuFill1;
//was: iscreen.showmenuClick1:=xshowmenuClick1;
visyncevent:=__onvisync;
system_onshowoptions1:=_showsettings1;//open
system_onshowoptions2:=_showsettings2;//close
system_onshowoptionsCLOSEDELAY:=10*60;//10 minutes since we have MORE tabs than the standard system - 12nov2022

//defaults
system_onshowoptionsNEWWIDTH:=740;
system_onshowoptionsNEWHEIGHT:=530;
system_onshowoptionsINITPAGENAME:='colorset';

//start timer event
ibuildingcontrol:=false;
xloadsettings;//load program settings, separate to the system settings
xstarttimer;
//.flicker and stutter free intial display mode - 15mar2022
xmustclock;
xmustframe;
//.hide the window head and realtime help and toolbar -> not required
rootwin.xhead.visible:=false;
rootwin.xhelp.showhelp:=false;
rootwin.xtoolbar.visible:=false;
end;
//## destroy ##
destructor tprogram.destroy;
var
   p:longint;
begin
try
//settings
xsavesettings;
//controls
visyncevent:=nil;
freeobj(@iscreenbuffer);
freeobj(@ibellbuffer);
freeobj(@ialarmlist);
freeobj(@ireminderlist);
//self
inherited destroy;
except;end;
end;
//## xinitColors ##
procedure tprogram.xinitColors;//build clock face color sets (first tab on left of Options window)
var
   xlastfont,xlastback,p:longint;
   xlastname:string;
   //## xaddcolor ##
   procedure xaddcolor(xname:string;xfont,xback:longint);
   label
      redo;
   var
      xnamecount,p,int1:longint;
      str1:string;
   begin
   try
   //init
   if (icolorcount>high(icolorname)) then exit;
   if (xname='') then exit;
   xlastname:=xname;//before it's modified below - 13nov2022
   //new name
   if (icolorcount>=1) then
      begin
      xnamecount:=1;
      redo:
      str1:=xname+low__insstr(#32+inttostr(xnamecount),xnamecount>=2);
      for p:=0 to (icolorcount-1) do if low__comparetext(str1,icolorname[p]) then
         begin
         inc(xnamecount);
         if (xnamecount<=100) then goto redo;
         end;
      //set
      xname:=str1;
      end;
   //get
   icolorname[icolorcount]:=xname;
   icolorfont[icolorcount]:=xfont;
   icolorback[icolorcount]:=xback;
   inc(icolorcount);
   except;end;
   end;
   //## xaddcolor0 ##
   procedure xaddcolor0(xname:string;xfont,xback:longint);
   begin
   try
   xlastfont:=xfont;
   xlastback:=xback;
   xaddcolor(xname,xfont,xback);
   except;end;
   end;
   //## xaddcolor1 ##
   procedure xaddcolor1(xname:string;xfont,xback,xshift,xshift2:longint);
   var
      a:tcolor24;
   begin
   try
   //filter
   if (xname='') then xname:=xlastname;
   if (xfont=-1) then xfont:=xlastfont;
   if (xback=-1) then xback:=xlastback;
   //xfont
   a:=low__intrgb(xfont);
   if (xshift<>0) then
      begin
      a.r:=frcrange(a.r+xshift,0,255);
      a.g:=frcrange(a.g+xshift,0,255);
      a.b:=frcrange(a.b+xshift,0,255);
      xfont:=low__rgbint(a);
      end;
   //xback
   a:=low__intrgb(xback);
   if (xshift2<>0) then
      begin
      a.r:=frcrange(a.r+xshift2,0,255);
      a.g:=frcrange(a.g+xshift2,0,255);
      a.b:=frcrange(a.b+xshift2,0,255);
      xback:=low__rgbint(a);
      end;
   //get
   xaddcolor(xname,xfont,xback);
   except;end;
   end;
   //## xaddcolor2 ##
   procedure xaddcolor2(xname:string;xfont,xback,xpert,xpert2:longint);
   begin
   try
   xfont:=low__colsplice(frcrange(xpert,0,100),low__rgb(255,255,255),xfont);
   xback:=low__colsplice(frcrange(xpert2,0,100),0,xback);
   xaddcolor(xname,xfont,xback);
   except;end;
   end;
   //##xaddcolor3 ##
   procedure xaddcolor3(xname:string;xfont,xback:longint);
   var
      c1,c2,p:longint;
      //## xcol1 ##
      function xcol1(xpert:longint):longint;
      begin
      try
      if (xpert>=0) then result:=low__colsplice(frcrange(xpert,0,100),low__rgb(255,255,255),xfont)
      else               result:=low__colsplice(frcrange(-xpert,0,100),xback,xfont);
      except;end;
      end;
      //## xcol2 ##
      function xcol2(xpert:longint):longint;
      begin
      try
      if (xpert>=0) then result:=low__colsplice(frcrange(xpert,0,100),0,xback)
      else               result:=low__colsplice(frcrange(-xpert,0,100),xfont,xback);
      except;end;
      end;
   begin
   try
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
   end;
   xaddcolor(xname+low__insstr(#32+inttostr(p),p>=1),c1,c2);
   end;//p
   except;end;
   end;
   //## xaddTitle ##
   procedure xaddTitle(xname:string);
   begin
   try;xaddcolor(xname,-99,-99);except;end;
   end;
begin
try
//init
xlastname:='Untitled';
xlastfont:=255;
xlastback:=0;
icolorcount:=0;
for p:=0 to high(icolor1) do
begin
icolor1[p]:=low__rgb(255,255,255);//text
icolor2[p]:=0;//back
end;//p

//get
//.built-in
xaddTitle('Built-In');
icolorfrom1:=1;//09nov2022
xaddcolor('Default',low__rgb(255,255,255),0);

xaddcolor('System Frame',-3,-3);
xaddcolor('System Title',-2,-2);
xaddcolor('System Standard',-1,-1);

xaddcolor0('Aqua',low__rgb(0,255,255),0);
xaddcolor1('',-1,low__rgb(30,0,0),0,0);
xaddcolor1('',-1,low__rgb(60,0,0),0,0);
xaddcolor1('',-1,low__rgb(0,0,30),0,0);
xaddcolor1('',-1,low__rgb(0,0,60),0,0);
xaddcolor1('',-1,low__rgb(30,30,0),0,0);
xaddcolor1('',-1,low__rgb(60,60,0),0,0);
xaddcolor1('',-1,low__rgb(30,0,30),0,0);
xaddcolor1('',-1,low__rgb(60,0,60),0,0);

xaddcolor0('Aqua',low__rgb(0,200,200),0);
xaddcolor0('Aqua',low__rgb(100,200,200),0);

xaddcolor0('Biege',low__rgb(255,242,235),low__rgb(22,13,8));
xaddcolor1('',-1,low__rgb(20,0,20),0,0);
xaddcolor1('',-1,low__rgb(40,0,40),0,0);
xaddcolor1('',-1,low__rgb(60,0,60),0,0);

xaddcolor1('',-1,low__rgb(40,40,0),0,0);
xaddcolor1('',-1,low__rgb(40,0,0),0,0);
xaddcolor1('',-1,low__rgb(200,100,100),0,0);
xaddcolor1('',-1,low__rgb(100,200,100),0,0);
xaddcolor1('',-1,low__rgb(100,100,200),0,0);
xaddcolor1('',-1,low__rgb(200,200,100),0,0);
xaddcolor1('',-1,low__rgb(200,100,200),0,0);

xaddcolor1('Biege',low__rgb(255,242,235),low__rgb(172,163,158),-10,-100);
xaddcolor1('Biege',low__rgb(255,242,235),low__rgb(172,163,158),0,-50);
xaddcolor1('Biege',low__rgb(255,242,235),low__rgb(172,163,158),0,0);

xaddcolor0('Black',0,low__rgb(255,255,255));
xaddcolor1('',-1,low__rgb(170,70,70),0,0);
xaddcolor1('',-1,low__rgb(70,170,70),0,0);
xaddcolor1('',-1,low__rgb(70,70,170),0,0);
xaddcolor1('',-1,low__rgb(170,70,170),0,0);
xaddcolor1('',-1,low__rgb(170,170,70),0,0);
xaddcolor1('',-1,low__rgb(70,170,170),0,0);
xaddcolor0('Black',0,low__rgb(128,128,128));
xaddcolor0('Black',0,low__rgb(60,60,60));

xaddcolor0('Blue',low__rgb(0,0,255),0);
xaddcolor1('',-1,low__rgb(20,0,0),0,0);
xaddcolor1('',-1,low__rgb(50,0,0),0,0);
xaddcolor1('',-1,low__rgb(20,30,0),0,0);

xaddcolor0('Blue',low__rgb(0,128,255),0);
xaddcolor1('',-1,low__rgb(18,0,0),0,0);
xaddcolor1('',-1,low__rgb(30,10,10),0,0);

xaddcolor0('Blue',low__rgb(0,64,200),0);
xaddcolor0('Blue',low__rgb(100,100,200),0);
xaddcolor1('',-1,low__rgb(18,0,0),0,0);
xaddcolor1('',-1,low__rgb(30,0,0),0,0);

xaddcolor0('Green',low__rgb(0,255,0),0);
xaddcolor1('',-1,low__rgb(20,20,0),0,0);
xaddcolor1('',-1,low__rgb(5,20,5),0,0);
xaddcolor1('',-1,low__rgb(0,0,20),0,0);
xaddcolor1('',-1,low__rgb(20,20,50),0,0);
xaddcolor0('Green',low__rgb(0,200,0),0);
xaddcolor0('Green',low__rgb(80,190,80),0);

xaddcolor0('Grey',low__rgb(190,190,190),0);
xaddcolor1('',-1,low__rgb(20,10,0),0,0);
xaddcolor1('',-1,low__rgb(20,0,0),0,0);
xaddcolor1('',-1,low__rgb(50,0,0),0,0);
xaddcolor1('',-1,low__rgb(0,0,15),0,0);
xaddcolor1('',-1,low__rgb(0,10,0),0,0);
xaddcolor1('',-1,low__rgb(0,25,0),0,0);

xaddcolor0('Grey',low__rgb(120,120,120),0);
xaddcolor1('',-1,low__rgb(20,10,0),0,0);
xaddcolor1('',-1,low__rgb(20,0,0),0,0);
xaddcolor1('',-1,low__rgb(50,0,0),0,0);
xaddcolor1('',-1,low__rgb(0,0,15),0,0);
xaddcolor1('',-1,low__rgb(0,10,0),0,0);
xaddcolor1('',-1,low__rgb(0,25,0),0,0);

xaddcolor('Grey',low__rgb(150,140,130),0);
xaddcolor('Grey',low__rgb(140,150,130),0);
xaddcolor('Grey',low__rgb(130,140,150),0);

xaddcolor0('Orange',low__rgb(255,128,0),0);
xaddcolor1('',-1,low__rgb(20,10,0),0,0);
xaddcolor1('',-1,low__rgb(20,0,0),0,0);
xaddcolor1('',-1,low__rgb(50,0,0),0,0);
xaddcolor1('',-1,low__rgb(0,0,15),0,0);
xaddcolor1('',-1,low__rgb(0,10,0),0,0);
xaddcolor1('',-1,low__rgb(0,25,0),0,0);

xaddcolor0('Orange',low__rgb(245,150,0),0);
xaddcolor1('',-1,low__rgb(20,10,0),0,0);
xaddcolor1('',-1,low__rgb(20,0,0),0,0);
xaddcolor1('',-1,low__rgb(50,0,0),0,0);
xaddcolor1('',-1,low__rgb(0,0,15),0,0);
xaddcolor1('',-1,low__rgb(0,10,0),0,0);
xaddcolor1('',-1,low__rgb(0,25,0),0,0);

xaddcolor0('Orange',low__rgb(240,190,0),0);
xaddcolor1('',-1,low__rgb(20,10,0),0,0);
xaddcolor1('',-1,low__rgb(20,0,0),0,0);
xaddcolor1('',-1,low__rgb(50,0,0),0,0);
xaddcolor1('',-1,low__rgb(0,0,15),0,0);
xaddcolor1('',-1,low__rgb(0,10,0),0,0);
xaddcolor1('',-1,low__rgb(0,25,0),0,0);

xaddcolor0('Pink',low__rgb(228,199,230),low__rgb(97,84,98));
xaddcolor1('',-1,low__rgb(15,0,0),0,0);
xaddcolor1('',-1,low__rgb(30,0,0),0,0);
xaddcolor1('',-1,low__rgb(30,0,30),0,0);
xaddcolor1('',-1,low__rgb(20,20,30),0,0);
xaddcolor('Pink',low__rgb(228-20,199-20,230-20),low__rgb(97-20,84-20,98-20));

xaddcolor0('Purple',low__rgb(128,0,255),0);
xaddcolor1('',-1,low__rgb(15,0,0),0,0);
xaddcolor1('',-1,low__rgb(30,0,0),0,0);
xaddcolor1('',-1,low__rgb(50,0,0),0,0);
xaddcolor1('',-1,low__rgb(30,0,30),0,0);
xaddcolor1('',-1,low__rgb(50,0,70),0,0);
xaddcolor('Purple',low__rgb(128,0,255),low__rgb(25,0,50));

xaddcolor0('Red',low__rgb(255,0,0),0);
xaddcolor1('',-1,low__rgb(10,30,0),0,0);//green
xaddcolor0('Red',low__rgb(200,0,0),0);
xaddcolor1('',-1,low__rgb(0,0,50),0,0);//blue
xaddcolor0('Red',low__rgb(200,45,22),0);
xaddcolor1('',-1,low__rgb(30,0,30),0,0);//purple
xaddcolor0('Red',low__rgb(190,80,80),0);
xaddcolor1('',-1,low__rgb(50,0,0),0,0);
xaddcolor0('Red',low__rgb(255,50,50),0);
xaddcolor1('',-1,low__rgb(70,0,30),0,0);

xaddcolor0('White',low__rgb(255,255,255),0);
xaddcolor1('',-1,low__rgb(20,0,0),0,0);
xaddcolor1('',-1,low__rgb(0,20,0),0,0);
xaddcolor1('',-1,low__rgb(0,0,20),0,0);
xaddcolor1('',-1,low__rgb(20,20,0),0,0);
xaddcolor1('',-1,low__rgb(20,0,20),0,0);
xaddcolor('White',low__rgb(230,230,230),0);
xaddcolor('White',low__rgb(200,200,200),0);

xaddcolor('Yellow',low__rgb(255,255,0),0);
xaddcolor1('Yellow',low__rgb(255,255,0),low__rgb(255,255,200),-10,-255);
xaddcolor1('Yellow',low__rgb(255,255,0),low__rgb(255,255,200),0,-150);
xaddcolor1('Yellow',low__rgb(255,255,0),low__rgb(255,255,200),0,-90);
xaddcolor1('Yellow',low__rgb(240,220,0),0,0,0);
xaddcolor1('Yellow',low__rgb(240,220,0),low__rgb(0,0,50),0,0);
xaddcolor1('Yellow',low__rgb(240,220,0),low__rgb(0,0,100),0,0);
xaddcolor1('Yellow',low__rgb(240,220,0),low__rgb(0,50,0),0,0);
xaddcolor1('Yellow',low__rgb(240,220,0),low__rgb(0,100,0),0,0);
xaddcolor1('Yellow',low__rgb(240,220,0),low__rgb(50,0,0),0,0);
xaddcolor1('Yellow',low__rgb(240,220,0),low__rgb(100,0,0),0,0);

//.custom
xaddTitle('Custom');
icolorfrom2:=icolorcount;//09nov2022

for p:=0 to 9 do
begin
xaddcolor('Custom '+inttostr(p+1),-100-p,-100-p);
end;
except;end;
end;
//## xinitAlarms ##
procedure tprogram.xinitAlarms;
var
   p:longint;
begin
try
iactindex:=-1;
iactrem:=0;//seconds of active alarm remaining in seconds
iactbuzzer:=0;//off
iactmsg:='';
ihavebuzzer:=false;
ihavemsg:=false;
except;end;
end;
//## xinitReminders ##
procedure tprogram.xinitReminders;
var
   p:longint;
begin
try
iremindex:=-1;
iremmsg:='';
ihaveremmsg:=false;
except;end;
end;
//## xlistitem ##
function tprogram.xlistitem(sender:tobject;xindex:longint;var xtab,xtep,xtepcolor:longint;var xcaption,xcaplabel,xhelp,xcode2:string;var xcode,xshortcut,xindent:longint;var xflash,xenabled,xtitle,xsep:boolean):boolean;
var
   xstyle:longint;
   xintro,xdong,xdong2:tstr8;
begin
try
//defaults
result:=false;
//get
if (sender=pcolorlist) and (pcolorlist<>nil) then
   begin
   xindex:=frcmax(frcrange(xindex,0,frcmin(icolorcount-1,0)),high(icolorname));
   xcaplabel:=icolorname[xindex];
   //.title
   if (icolorfont[xindex]=-99) then
      begin
      xtitle:=true;
      end
   //.color
   else
      begin
      xtep:=tepColorPal20;
      xtepcolor:=icolorfont[xindex];
      if (xtepcolor<0) then xtepcolor:=xsyscol(xtepcolor,true);
      end;
   end
else if (sender=pchimelist) and (pchimelist<>nil) then
   begin
   chm_info(xindex,xcaption,xstyle,xtep,xintro,xdong,xdong2);
   xtitle:=(xstyle=chmsTitle);
   if (strcopy1(xcaption,2,1)=':') then xcaplabel:=strcopy1(xcaption,3,length(xcaption));//1st two chars signifies chime type: m:=melody, b:=ships bells, s:=sonnerie - 09nov2022
   end;
except;end;
end;

//xxxxxxxxxxxxxxxxxxxxxxxxxx//sssssssssssssssss
//## _showsettings1 ##
procedure tprogram._showsettings1(sender:tobject);
const
   vsp=5;
   xcol1=42;//%
   xmodcol='purple';
   xvolcol='yellow';
   xothcol='blue';
   xquasym='m';
var
   xnow:tdatetime;
   xalarmindex,i,p,p2,dw,dh,int1,xpreviousfocus:longint;
   a:tbasicscroll;
   str1:string;
   bs:longint;
   xhost:tbasiccontrol;
   bol1,xmustfocus:boolean;
   //## dint3 ##
   function dint3(xlabel,xname,xhelp:string;xmin,xmax,xdef:longint;xvalname:string):tbasicint;
   begin
   if zznil(xhost,2291) then exit;
   result:=xhost.nint3(xlabel,xhelp,xmin,xmax,xdef,0,'',xvalname);
   result.tagstr:=xname;
   result.onvalue:=xshowsettings_sync;
//   result.oautoreload:=true;
   end;
   //## dint3b ##
   function dint3b(var xout:tbasicint;xlabel,xname,xhelp:string;xmin,xmax,xdef:longint;xvalname:string):tbasicint;
   begin
   result:=dint3(xlabel,xname,xhelp,xmin,xmax,xdef,xvalname);
   xout:=result;
   end;
   //## dset ##
   function dset(xlabel,xname,xhelp:string;xdef:longint):tbasicset;
   begin
   if zznil(xhost,2292) then exit;
   result:=xhost.nset(xlabel,xhelp,xdef,0);
   result.tagstr:=xname;
   result.onvalue:=xshowsettings_sync;
//   result.oautoreload:=true;
   end;
   //## dsel3 ##
   function dsel3(xlabel,xname,xhelp:string;xdef:longint;xvalname:string):tbasicsel;
   begin
   if zznil(xhost,2293) then exit;
   result:=xhost.nsel3(xlabel,xhelp,xdef,xvalname);
   result.tagstr:=xname;
   result.onvalue:=xshowsettings_sync;
//   result.oautoreload:=true;
   end;
   //## dedit ##
   function dedit(xtitle,xvalue,xhelp,xspbackname:string;xlenlimit:longint):tbasicedit;
   begin
   if zznil(xhost,2293) then exit;
   result:=xhost.nedit(xvalue,xhelp);
   result.title:=xtitle;
   result.value:=xvalue;
   result.ospbackname:=xspbackname;
   if (xlenlimit>=1) then result.olimit:=xlenlimit;
   result.onchange:=xshowsettings_sync;
   end;
begin
try
//check
if isettingsshowing then exit else isettingsshowing:=true;
isettingssynclock:=true;
//defaults
a:=nil;
if (sender is tbasicscroll) then a:=(sender as tbasicscroll) else exit;

//xpreviousfocus:=gui.winfocus;
xmustfocus:=(gui.focuscontrol=iscreen);
xhost:=nil;
//check
//if ishowoptions_inuse then exit else ishowoptions_inuse:=true;
//init
//ishowoptions_timer100:=ms64;
//get
//dw:=490;
//dh:=470;
//low__winzoom(dw,dh);//17mar2021
bs:=vibordersize;
//a:=gui.ndlg2(rect(0,0,dw+(2*bs),dh+(2*bs)),true,true);
//a.xhead.caption:=ntranslate('Settings');
//a.xtoolbar2.cadd(ntranslate(protect_text(16770871,'OK')),tepYes20,1,scdlg,rthtranslate('Close window'),60*10);
//a.xtoolbar2.add(ntranslate(protect_text(16771396,'Restore Defaults...')),tepRefresh20,2,'defaults',rthtranslate('Restore default settings'));



//-- Color --------------------------------------------------------------------
with a.xpage2('colorset','Face Color','','Face color settings',tepColor20,true) do
begin
xhost:=client;

xtoolbar.maketitle3('Face Colors',false,false);
xcolsh.ofillheight:=true;//use all client height if available
with xcolsh.cols2[0,xcol1,false] do
begin
xhost:=client;
pcolorlist:=nlist3('','Select color',nil,1,'');//read/write via system var.name of "colorname" - 09oct2020
pcolorlist.makelistx(icolorcount);
pcolorlist.ongetitem:=xlistitem;
pcolorlist.onclick:=xcustomcolorchanged;//xshowsettings_sync;
pcolorlist.onumberfrom:=icolorfrom1;
pcolorlist.onumberfrom2:=icolorfrom2;
end;

with xcolsh.cols2[1,100,true] do
begin
xhost:=client;

//.display brightness
dint3b(pbrightness3,'Brightness','brightness','Display Brightness',10,100,100,'').ospbackname:='yellow';pbrightness3.ovalunit:='%';
//.frame brightness
dint3b(pbrightnessF,'Frame Brightness','brightnessf','Frame Brightness',10,100,100,'').ospbackname:='yellow';pbrightnessF.ovalunit:='%';

//.auto dim
pautodim:=dsel3('Reduce Brightness','','Reduce display brightness to selected level at night',0,'');
with pautodim do
begin
osepv:=def_vsep;
itemsperline:=5;
for p:=0 to 9 do
begin
if (p=0) then str1:='Off' else str1:=inttostr((10-p)*10)+'%';
xadd(str1,'',str1);
end;
ospbackname:='blue';
end;


//.shade style
pshadestyle:=dsel3('Shade Style','','Clock face background shade style',0,'');
with pshadestyle do
begin
osepv:=def_vsep;
itemsperline:=5;
for p:=0 to 4 do
begin
case p of
0:str1:='Flat';
1:str1:='Shade';
2:str1:='Shade 2';
3:str1:='Round';
4:str1:='Glow';
end;
xadd(str1,'',str1);
end;
ospbackname:='blue';
end;

//.shade power - 13nov2022
dint3b(pshadepower,'Shade Power','shadepower','Clock face background shade power',10,100,20,'').ospbackname:='blue';pshadepower.ovalunit:='%';

//.feather
pfeather:=dsel3('Feathering','','Set feather level',0,'');
with pfeather do
begin
osepv:=def_vsep;
itemsperline:=5;
for p:=0 to 4 do
begin
case p of
0:str1:='None';//Sharp
1:str1:='Low';//Blur 1
2:str1:='Medium';//Blur 2
3:str1:='High';//Greyscale + Blur 1
4:str1:='Ultra';//Greyscale + Blur 2
end;
xadd(str1,'',str1);
end;
ospbackname:='blue';
end;

//.options
pcolorsettings:=dset('Options','','',0);
with pcolorsettings do
begin
xset3(0,'Tint Background','backmix','Selected: Tint background with foreground color',false,'');//xxxxxxxxxx
xset3(1,'Swap Colors','swapcolors','Selected: Swap foreground and background colors',false,'');
ospbackname:='blue';
end;


pcustomcolors:=client.ncolors;
with pcustomcolors do
begin
osepv:=def_vsep;
makeadjustable2(2);
addtitle('Custom Color','');
addcol('Text','f','Text color');
addcol('Background','b','Background color');
pcustomcolors.oncolorchanged:=xcustomcolorchanged;//dedicated event handler => avoids any slow downs - 15mar2022
end;//with

end;
end;



//xxxxxxxxxxxxxxxxxxxxxxxxx//ssssssssssssssssss
//-- Chime ---------------------------------------------------------------------
with a.xpage2('chime','Chime','','Chime Settings',tepMid20,true) do
begin
xhost:=client;
pchimebar:=xtoolbar.maketitle3('Chimes',false,false);
with pchimebar do
begin
xaddmixer;//07mar2022
add('Stop',tepStop20,0,'chime.stop','Stop sample chime');
add('Play Sample',tepPlay20,0,'chime.play','Play / Stop sample chime');
pchimebar.onclick:=__onclick;
end;

xcolsh.ofillheight:=true;//use all client height if available
with xcolsh.cols2[0,xcol1,false] do
begin
pchimelist:=nlist3('','Select chime',nil,1,'');
pchimelist.makelistx(chm_count);
pchimelist.ongetitem:=xlistitem;
pchimelist.onclick:=xshowsettings_sync;

pchimelist.onumberfrom:=chm_numberfrom1;
pchimelist.onumberfrom2:=chm_numberfrom2;
pchimelist.onumberfrom3:=chm_numberfrom3;
end;

with xcolsh.cols2[1,100,true] do
begin
xhost:=client;

//.normal
pnormal0:=dsel3('Mode','','Set chime mode',0,'');
with pnormal0 do
begin
xadd('Melody and Dongs','','Selected: Chime introduction melody and dongs');
xadd('Dongs Only','','Selected: Chime dongs only');
ospbackname:=xmodcol;
end;

pnormal:=dset('Quarterly','','Set quarter dongs to chime',0);
with pnormal do
begin
xset3(0,'15'+xquasym,'15','Selected: Chime quarter past dong',false,'');
xset3(1,'30'+xquasym,'30','Selected: Chime half past dong',false,'');
xset3(2,'45'+xquasym,'45','Selected: Chime quarter to dong',false,'');
ospbackname:=xmodcol;
end;

//.bells
pbell0:=dsel3('Mode','','',0,'');
with pbell0 do
begin
xadd('Standard','','Chime the standard Ships Bells');
xadd('British Royal','','Chime the modified British Royal Ships Bells | In 1797 at Nore a mutiny started during the dogwatch at five bells (6:30 PM), afterwards British ships changed the sequence to omit the five bells');
ospbackname:=xmodcol;
end;

//.sonnerie
pson0:=dsel3('Mode','','',0,'');
with pson0 do
begin
xadd('Grande Sonnerie','','Selected: Chime hour dongs quarterly followed by quarter past / half past or quarter to dongs');
xadd('Petite Sonnerie','','Selected: Chime hour dongs on the hour and quarterly dongs');
ospbackname:=xmodcol;
end;

pson:=dset('Quarterly','','Set quarter dongs to chime',0);
with pson do
begin
xset3(0,'15'+xquasym,'15','Selected: Chime quarter past dong',false,'');
xset3(1,'30'+xquasym,'30','Selected: Chime half past dong',false,'');
xset3(2,'45'+xquasym,'45','Selected: Chime quarter to dong',false,'');
ospbackname:=xmodcol;
end;

//.volume
with nmidivol('Volume','Chime Volume') do
begin
ospbackname:=xvolcol;
osepv:=def_vsep;
end;

//.speed
dint3b(pchimespeed,'Speed','chimespeed','Chime Speed',25,400,100,'').ospbackname:=xvolcol;
pchimespeed.ovalunit:='%';
pchimespeed.odefcap:='100%';
//.auto quieten
pautoquieten:=dsel3('Reduce Volume','','Reduce Chime volume to selected volume level at night',0,'');
with pautoquieten do
begin
osepv:=def_vsep;
itemsperline:=5;
for p:=0 to 9 do
begin
if (p=0) then str1:='Off' else str1:=inttostr((10-p)*10)+'%';
xadd(str1,'',str1);
end;
ospbackname:=xothcol;
end;
//.device
with nmidi('','') do
begin
ospbackname:=xothcol;
itemsperline:=6;
end;

pchimeoptions:=dset('Options','','',0);
with pchimeoptions do
begin
xset3(0,'Always On Midi','keepopen','Selected: Remain connected to midi device | Not Selected: Disconnect and close midi device after chiming / alarm(s) complete',false,'');
xset3(1,'Preview Sample Chime','samplechime','Selected: Play sample chime automatically',false,'');
ospbackname:=xothcol;
end;

//test/debug usage only - disable before release - 15nov2022
//disabled: pchimetest:=nbwp('',nil);pchimetest.maketxt1
end;//xhigh2
end;//page2


//-- Alarms --------------------------------------------------------------------
with a.xpage2('alarms','Alarms','','Alarm Settings',tepClock20,true) do
begin
xhost:=client;
palarmlist:=tbasicalarmlist.create(gui);
palarmlist.parent:=xhost;
palarmlist.extcore:=ialarmlist;//works directly with core - 13mar2022
palarmlist.makeAlarms;
palarmlist.otimeformat:=itimeformat;
palarmlist.odateformat:=idateformat;
(palarmlist as tbasicalarmlist).pos:=ialarmpos;
end;


//-- Reminders -----------------------------------------------------------------
with a.xpage2('reminders','Reminders','','Reminder Settings',tepAlert20,true) do
begin
xhost:=client;
preminderlist:=tbasicalarmlist.create(gui);
preminderlist.parent:=xhost;
preminderlist.extcore:=ireminderlist;//works directly with core - 13mar2022
preminderlist.makeReminders;
preminderlist.otimeformat:=itimeformat;
preminderlist.odateformat:=idateformat;
(preminderlist as tbasicalarmlist).pos:=ireminderpos;
end;


//-- Display -------------------------------------------------------------------
pdisplay:=a.xpage2('display','Display','','Display settings',tepScreen20,false);
with pdisplay do
begin
xhost:=client;

//.general
psettings:=dset('General','','',0);
with psettings do
begin
itemsperline:=4;
xset3(0,'Frame Maximised','framemax','Selected: Display frame when maximised | Not Selected: Hide frame when maximised',false,'');
xset3(2,'On Top','ontop','Selected: Position clock above other programs',false,'');
ospbackname:='green';
end;

//.time format
ptimeformat:=dsel3('Time Format','','',0,'');
with ptimeformat do
begin
osepv:=def_vsep;
xadd('24hr','','');
xadd('12hr AM/PM','','');
xadd('12hr am/pm','','');
ospbackname:='blue';
end;

//.date
pdate:=dset('Date','','',0);
with pdate do
begin
itemsperline:=4;
xset3(0,'Show','date.show','Selected: Show Date | Not Selected: Hide Date',false,'');
xset3(1,'Uppercase','date.uppercase','Selected: Show current Date in uppercase characters',false,'');
xset3(2,'At Top','date.top','Selected: Display Date at top | Not Selected: Display Date at bottom',false,'');
xset3(3,'Full','date.full','Selected: Date in full e.g. 12 March 2022 | Not Selected: Short date e.g. 12 Mar 2022',false,'');
ospbackname:='blue';
end;

//.date format
pdateformat:=dsel3('Date Format','','',0,'');
xnow:=now;
with pdateformat do
begin
itemsperline:=2;
for p:=0 to 3 do
begin
xadd('*','','*');//filled later in "*_showhide" - 13mar2022
end;
ospbackname:='blue';
end;

//.day
pday:=dset('Day of Week','','',0);
with pday do
begin
osepv:=def_vsep;
itemsperline:=4;
xset3(0,'Show','day.show','Selected: Show Day | Not Selected: Hide Day',false,'');
xset3(1,'Uppercase','day.uppercase','Selected: Show current Day in uppercase characters',false,'');
xset3(2,'At Top','day.top','Selected: Display Day at top | Not Selected: Display Day at bottom',false,'');
xset3(3,'Full','day.full','Selected: Day of week in full e.g. Wednesday | Not Selected: Short day of week e.g. Wed',false,'');
ospbackname:='yellow';
end;

//.reminder
prem:=dset('Reminder','','',0);
with prem do
begin
itemsperline:=4;
//was: xset3(0,'Show','rem.show','Selected: Show Reminder | Not Selected: Hide Reminder',false,'');
xset3(0,'Uppercase','rem.uppercase','Selected: Show current Reminder in uppercase characters',false,'');
xset3(1,'At Top','rem.top','Selected: Display Reminder at top | Not Selected: Display Reminder at bottom',false,'');
ospbackname:='yellow';
end;

//.evening + morning
with dint3b(pevening,'Begin Evening at','Evening','Set time Afternoon becomes Evening',0,600,360,'') do
begin
osepv:=def_vsep;
ospbackname:='orange';
end;
pevening.onvalcap:=_onvalcap;
dint3b(pmorning,'Begin Morning at','morning','Set time Predawn becomes Morning',0,600,360,'').ospbackname:='orange';
pmorning.onvalcap:=_onvalcap;

//.pod
ppod:=dset('Part of Day','','',0);
with ppod do
begin
osepv:=def_vsep;
itemsperline:=4;
xset3(0,'Show','pod.show','Selected: Show Part of Day | Not Selected: Hide Part of Day',false,'');
xset3(1,'Uppercase','pod.uppercase','Selected: Show current Part of Day in uppercase characters',false,'');
ospbackname:='green';
end;
//.part of day labels
//was: ntitle(false,'Part of Day Labels','Type a custom label or leavel blank to use default');
str1:='< Type a custom label >';
plabel_afternoon:=dedit('Afternoon Label',str1,'Type a custom label for Afternoon | Leave blank for default','green',ishortlabellimit);
plabel_evening:=dedit('Evening Label',str1,'Type a custom label for Evening | Leave blank for default','green',ishortlabellimit);
plabel_predawn:=dedit('Predawn Label',str1,'Type a custom label for Predrawn | Leave blank for default','green',ishortlabellimit);
plabel_morning:=dedit('Morning Label',str1,'Type a custom label for Morning | Leave blank for default','green',ishortlabellimit);
ofirstpos:=isettings_display_firstpos;
end;//end of Display -----------------------------------------------------------

//.etc
with a do
begin
//xtoolbar.xaddoptions2('options');
end;
ptoolbar:=a.xtoolbar;

//reload
xshowsettings_reload;

//events
a.xtoolbar.onclick:=__onclick;
if (pchimebar<>nil) then pchimebar.onclick:=__onclick;

//set
isettingssynclock:=false;
except;end;
end;
//## _showsettings2 ##
procedure tprogram._showsettings2(sender:tobject);
var
   a:tbasicscroll;
begin
try
//defaults
a:=nil;
if (sender is tbasicscroll) then a:=(sender as tbasicscroll) else exit;
//get
//if xmustfocus then gui.focuscontrol:=iscreen;
//sync
if (palarmlist<>nil) then ialarmpos:=(palarmlist as tbasicalarmlist).pos;
if (preminderlist<>nil) then ireminderpos:=(preminderlist as tbasicalarmlist).pos;

xshowsettings_sync2(nil,'');//sync everything, including edit boxes for alarms - 01mar2022
//viSyncandsave;
except;end;
try
if (pdisplay<>nil) then isettings_display_firstpos:=pdisplay.pos;
pclear;
isettingsshowing:=false;
isettingssynclock:=false;
except;end;
end;
{//was:
//## xshowsettings ##
procedure tprogram.xshowsettings;
const
   vsp=5;
   xcol1=42;//%
var
   xnow:tdatetime;
   xalarmindex,i,p,p2,dw,dh,int1,xpreviousfocus:longint;
   a:tbasicscroll;
   str1:string;
   bs:longint;
   xhost:tbasiccontrol;
   bol1,xmustfocus:boolean;
   //## dint3 ##
   function dint3(xlabel,xname,xhelp:string;xmin,xmax,xdef:longint;xvalname:string):tbasicint;
   begin
   if zznil(xhost,2291) then exit;
   result:=xhost.nint3(xlabel,xhelp,xmin,xmax,xdef,0,'',xvalname);
   result.tagstr:=xname;
   result.onvalue:=xshowsettings_sync;
//   result.oautoreload:=true;
   end;
   //## dint3b ##
   function dint3b(var xout:tbasicint;xlabel,xname,xhelp:string;xmin,xmax,xdef:longint;xvalname:string):tbasicint;
   begin
   result:=dint3(xlabel,xname,xhelp,xmin,xmax,xdef,xvalname);
   xout:=result;
   end;
   //## dset ##
   function dset(xlabel,xname,xhelp:string;xdef:longint):tbasicset;
   begin
   if zznil(xhost,2292) then exit;
   result:=xhost.nset(xlabel,xhelp,xdef,0);
   result.tagstr:=xname;
   result.onvalue:=xshowsettings_sync;
//   result.oautoreload:=true;
   end;
   //## dsel3 ##
   function dsel3(xlabel,xname,xhelp:string;xdef:longint;xvalname:string):tbasicsel;
   begin
   if zznil(xhost,2293) then exit;
   result:=xhost.nsel3(xlabel,xhelp,xdef,xvalname);
   result.tagstr:=xname;
   result.onvalue:=xshowsettings_sync;
//   result.oautoreload:=true;
   end;
   //## dedit ##
   function dedit(xtitle,xvalue,xhelp,xspbackname:string;xlenlimit:longint):tbasicedit;
   begin
   if zznil(xhost,2293) then exit;
   result:=xhost.nedit(xvalue,xhelp);
   result.title:=xtitle;
   result.value:=xvalue;
   result.ospbackname:=xspbackname;
   if (xlenlimit>=1) then result.olimit:=xlenlimit;
   result.onchange:=xshowsettings_sync;
   end;
begin
try
//check
if isettingsshowing then exit else isettingsshowing:=true;
isettingssynclock:=true;
//defaults
a:=nil;
xpreviousfocus:=gui.winfocus;
xmustfocus:=(gui.focuscontrol=iscreen);
xhost:=nil;
//check
//if ishowoptions_inuse then exit else ishowoptions_inuse:=true;
//init
//ishowoptions_timer100:=ms64;
//get
dw:=490;
dh:=470;
low__winzoom(dw,dh);//17mar2021
bs:=vibordersize;
a:=gui.ndlg2(rect(0,0,dw+(2*bs),dh+(2*bs)),true,true);
a.xhead.caption:=ntranslate('Settings');
a.xtoolbar2.cadd(ntranslate(protect_text(16770871,'OK')),tepYes20,1,scdlg,rthtranslate('Close window'),60*10);
//a.xtoolbar2.add(ntranslate(protect_text(16771396,'Restore Defaults...')),tepRefresh20,2,'defaults',rthtranslate('Restore default settings'));


//-- Color --------------------------------------------------------------------
with a.xpage2('colorset','Color Set','','Color Settings',tepColor20,true) do
begin
xhost:=client;

xtoolbar.maketitle3('Colors',false,false);
xcolsh.ofillheight:=true;//use all client height if available
with xcolsh.cols2[0,xcol1,false] do
begin
xhost:=client;
pcolorlist:=nlist3('','Select color',nil,1,'');//read/write via system var.name of "colorname" - 09oct2020
pcolorlist.makelistx(icolorcount);
pcolorlist.ongetitem:=xlistitem;
pcolorlist.onclick:=xcustomcolorchanged;//xshowsettings_sync;
end;

with xcolsh.cols2[1,100,true] do
begin
xhost:=client;

//.options
pcolorsettings:=dset('Options','','',0);
with pcolorsettings do
begin
xset3(0,'Tint Background','backmix','Selected: Tint background with foreground color',false,'');//xxxxxxxxxx
xset3(1,'Swap Colors','swapcolors','Selected: Swap foreground and background colors',false,'');
ospbackname:='green';
end;

//.display brightness
dint3b(pbrightness3,'Display Brightness','brightness','Display Brightness',10,100,100,'').ospbackname:='blue';pbrightness3.ovalunit:='%';
//.auto dim
pautodim:=dsel3('Dim','','Reduce display brightness to selected level at night',0,'');
with pautodim do
begin
itemsperline:=5;
for p:=0 to 9 do
begin
if (p=0) then str1:='Off' else str1:=inttostr((10-p)*10)+'%';
xadd(str1,'',str1);
end;
ospbackname:='blue';
end;
//.frame brightness
dint3b(pbrightnessF,'Frame Brightness','brightnessf','Frame Brightness',10,100,100,'').ospbackname:='yellow';pbrightnessF.ovalunit:='%';

pcustomcolors:=client.ncolors;
with pcustomcolors do
begin
makeadjustable2(2);
addtitle('Custom Color','');
addcol('Text','f','Text color');
addcol('Background','b','Background color');
pcustomcolors.oncolorchanged:=xcustomcolorchanged;//dedicated event handler => avoids any slow downs - 15mar2022
end;//with

end;
end;



//xxxxxxxxxxxxxxxxxxxxxxxxx//ssssssssssssssssss
//-- Chime ---------------------------------------------------------------------
with a.xpage2('chime','Chime','','Chime Settings',tepMid20,true) do
begin
xhost:=client;
pchimebar:=xtoolbar.maketitle3('Chimes',false,false);
with pchimebar do
begin
xaddmixer;//07mar2022
add('Stop',tepStop20,0,'chime.stop','Stop sample chime');
add('Play',tepPlay20,0,'chime.play','Play / Stop sample chime');
pchimebar.onclick:=__onclick;
end;

xcolsh.ofillheight:=true;//use all client height if available
with xcolsh.cols2[0,xcol1,false] do
begin
pchimelist:=nlist3('','Select chime',nil,1,'');
pchimelist.makelistx(chm_count);
pchimelist.ongetitem:=xlistitem;
pchimelist.onclick:=xshowsettings_sync;
end;

with xcolsh.cols2[1,100,true] do
begin
xhost:=client;

//.normal
pnormal0:=dsel3('Mode','','Set chime mode',0,'');
with pnormal0 do
begin
xadd('Melody and Dongs','','Selected: Chime introduction melody and dongs');
xadd('Dongs Only','','Selected: Chime dongs only');
ospbackname:='purple';//was: 'green';
end;

pnormal:=dset('Quarterly','','Set quarter dongs to chime',0);
with pnormal do
begin
xset3(0,'15m','15','Selected: Chime quarter past dong',false,'');
xset3(1,'30m','30','Selected: Chime half past dong',false,'');
xset3(2,'45m','45','Selected: Chime quarter to dong',false,'');
ospbackname:='purple';
end;

//.bells
pbell0:=dsel3('Mode','','',0,'');
with pbell0 do
begin
xadd('Standard','','Chime the standard Ships Bells');
xadd('British Royal','','Chime the modified British Royal Ships Bells | In 1797 at Nore a mutiny started during the dogwatch at five bells (6:30 PM), afterwards British ships changed the sequence to omit the five bells');
ospbackname:='purple';//was: 'green';
end;

//.sonnerie
pson0:=dsel3('Mode','','',0,'');
with pson0 do
begin
xadd('Grande Sonnerie','','Selected: Chime hour dongs quarterly followed by quarter past / half past or quarter to dongs');
xadd('Petite Sonnerie','','Selected: Chime hour dongs on the hour and quarterly dongs');
ospbackname:='green';
end;

pson:=dset('Quarterly','','Set quarter dongs to chime',0);
with pson do
begin
xset3(0,'15','15','Selected: Chime quarter past dong',false,'');
xset3(1,'30','30','Selected: Chime half past dong',false,'');
xset3(2,'45','45','Selected: Chime quarter to dong',false,'');
ospbackname:='purple';
end;


pchimeoptions:=dset('Options','','',0);
with pchimeoptions do
begin
xset3(0,'Always On Midi','keepopen','Selected: Remain connected to midi device | Not Selected: Disconnect and close midi device after chiming / alarm(s) complete',false,'');
ospbackname:='green';
end;

//.volume
nmidivol('Chime Volume','Volume').ospbackname:='blue';
//.auto quieten
pautoquieten:=dsel3('Quieten at Night to','','Reduce Chime volume to selected volume level at night',0,'');
with pautoquieten do
begin
itemsperline:=5;
for p:=0 to 9 do
begin
if (p=0) then str1:='Off' else str1:=inttostr((10-p)*10)+'%';
xadd(str1,'',str1);
end;
ospbackname:='blue';
end;
//.speed
dint3b(pchimespeed,'Chime Speed','chimespeed','Chime Speed',25,400,100,'').ospbackname:='yellow';
pchimespeed.ovalunit:='%';
pchimespeed.odefcap:='100%';
//.device
with nmidi('','') do
begin
ospbackname:='yellow';
itemsperline:=6;
end;

end;//xhigh2
end;//page2


//-- Reminders -----------------------------------------------------------------
with a.xpage2('reminders','Reminders','','Reminder Settings',tepAlert20,true) do
begin
xhost:=client;
preminderlist:=tbasicalarmlist.create(gui);
preminderlist.parent:=xhost;
preminderlist.extcore:=ireminderlist;//works directly with core - 13mar2022
preminderlist.makeReminders;
preminderlist.otimeformat:=itimeformat;
preminderlist.odateformat:=idateformat;
(preminderlist as tbasicalarmlist).pos:=ireminderpos;
end;


//-- Alarms --------------------------------------------------------------------
with a.xpage2('alarms','Alarms','','Alarm Settings',tepClock20,true) do
begin
xhost:=client;
palarmlist:=tbasicalarmlist.create(gui);
palarmlist.parent:=xhost;
palarmlist.extcore:=ialarmlist;//works directly with core - 13mar2022
palarmlist.makeAlarms;
palarmlist.otimeformat:=itimeformat;
palarmlist.odateformat:=idateformat;
(palarmlist as tbasicalarmlist).pos:=ialarmpos;
end;


//-- Display -------------------------------------------------------------------
pdisplay:=a.xpage2('display','Display','','Display settings',tepScreen20,false);
with pdisplay do
begin
xhost:=client;

//.general
psettings:=dset('General','','',0);
with psettings do
begin
itemsperline:=4;
xset3(0,'Frame Maximised','framemax','Selected: Display frame when maximised | Not Selected: Hide frame when maximised',false,'');
xset3(1,'Start Maximised','maxonstart','Selected: Maximise on start',false,'');
xset3(2,'On Top','ontop','Selected: Position clock above other programs',false,'');
ospbackname:='green';
end;

//.time format
ptimeformat:=dsel3('Time Format','','',0,'');
with ptimeformat do
begin
xadd('24hr','','');
xadd('12hr AM/PM','','');
xadd('12hr am/pm','','');
ospbackname:='blue';
end;

//.date
pdate:=dset('Date','','',0);
with pdate do
begin
itemsperline:=4;
xset3(0,'Show','date.show','Selected: Show Date | Not Selected: Hide Date',false,'');
xset3(1,'Uppercase','date.uppercase','Selected: Show current Date in uppercase characters',false,'');
xset3(2,'At Top','date.top','Selected: Display Date at top | Not Selected: Display Date at bottom',false,'');
xset3(3,'Full','date.full','Selected: Date in full e.g. 12 March 2022 | Not Selected: Short date e.g. 12 Mar 2022',false,'');
ospbackname:='green';
end;

//.date format
pdateformat:=dsel3('Date Format','','',0,'');
xnow:=now;
with pdateformat do
begin
itemsperline:=2;
for p:=0 to 3 do
begin
xadd('*','','*');//filled later in "*_showhide" - 13mar2022
end;
ospbackname:='green';
end;

//.day
pday:=dset('Day of Week','','',0);
with pday do
begin
itemsperline:=4;
xset3(0,'Show','day.show','Selected: Show Day | Not Selected: Hide Day',false,'');
xset3(1,'Uppercase','day.uppercase','Selected: Show current Day in uppercase characters',false,'');
xset3(2,'At Top','day.top','Selected: Display Day at top | Not Selected: Display Day at bottom',false,'');
xset3(3,'Full','day.full','Selected: Day of week in full e.g. Wednesday | Not Selected: Short day of week e.g. Wed',false,'');
ospbackname:='blue';
end;

//.pod
ppod:=dset('Part of Day','','',0);
with ppod do
begin
itemsperline:=4;
xset3(0,'Show','pod.show','Selected: Show Part of Day | Not Selected: Hide Part of Day',false,'');
xset3(1,'Uppercase','pod.uppercase','Selected: Show current Part of Day in uppercase characters',false,'');
ospbackname:='yellow';
end;

//.reminder
prem:=dset('Reminder','','',0);
with prem do
begin
itemsperline:=4;
//was: xset3(0,'Show','rem.show','Selected: Show Reminder | Not Selected: Hide Reminder',false,'');
xset3(0,'Uppercase','rem.uppercase','Selected: Show current Reminder in uppercase characters',false,'');
xset3(1,'At Top','rem.top','Selected: Display Reminder at top | Not Selected: Display Reminder at bottom',false,'');
ospbackname:='red';
end;

//.evening
pnighttitle:=ntitle(false,'Evening / Morning Adjustment','Set Begin time and End time for Evening');
//.evening + morning
dint3b(pevening,'Begin Evening at','Evening','Set time Afternoon becomes Evening',0,600,360,'').ospbackname:='red';
pevening.onvalcap:=_onvalcap;
dint3b(pmorning,'Begin Morning at','morning','Set time Predawn becomes Morning',0,600,360,'').ospbackname:='yellow';
pmorning.onvalcap:=_onvalcap;

//.part of day labels
ntitle(false,'Part of Day Labels','Type a custom label or leavel blank to use default');
str1:='< Type a custom label >';
plabel_afternoon:=dedit('Afternoon Label',str1,'Type a custom label for Afternoon | Leave blank for default','orange',ishortlabellimit);
plabel_evening:=dedit('Evening Label',str1,'Type a custom label for Evening | Leave blank for default','red',ishortlabellimit);
plabel_predawn:=dedit('Predawn Label',str1,'Type a custom label for Predrawn | Leave blank for default','blue',ishortlabellimit);
plabel_morning:=dedit('Morning Label',str1,'Type a custom label for Morning | Leave blank for default','yellow',ishortlabellimit);
ofirstpos:=isettings_display_firstpos;
end;//end of Display -----------------------------------------------------------

//.etc
with a do
begin
xtoolbar.xaddoptions2('options');
end;
ptoolbar:=a.xtoolbar;

//reload
xshowsettings_reload;

//events
a.xtoolbar.onclick:=__onclick;
if (pchimebar<>nil) then pchimebar.onclick:=__onclick;

//set
a.page:=low__udv(isettingspage,'colorset');
isettingssynclock:=false;
gui.xcenter(a);
gui.xshowwait(a,xpreviousfocus);
isettingspage:=a.page;
if xmustfocus then gui.focuscontrol:=iscreen;
//sync
if (palarmlist<>nil) then ialarmpos:=(palarmlist as tbasicalarmlist).pos;
if (preminderlist<>nil) then ireminderpos:=(preminderlist as tbasicalarmlist).pos;

xshowsettings_sync2(nil,'');//sync everything, including edit boxes for alarms - 01mar2022
viSyncandsave;
except;end;
try
if (pdisplay<>nil) then isettings_display_firstpos:=pdisplay.pos;
pclear;
freeobj(@a);
isettingsshowing:=false;
isettingssynclock:=false;
except;end;
end;
{}//yyyyyyyyyyyy
//## pclear ##
procedure tprogram.pclear;
begin
try
pdisplay:=nil;
plabel_predawn:=nil;//13mar2022
plabel_morning:=nil;
plabel_afternoon:=nil;
plabel_evening:=nil;
pcustomcolors:=nil;
pchimebar:=nil;
ptoolbar:=nil;
pday:=nil;
ppod:=nil;
pdate:=nil;
prem:=nil;
pnormal0:=nil;
pnormal:=nil;
pbell0:=nil;
pson0:=nil;
pson:=nil;
pchimetest:=nil;
pchimeoptions:=nil;
psettings:=nil;
pcolorsettings:=nil;
pdateformat:=nil;
ptimeformat:=nil;
pautodim:=nil;
pfeather:=nil;
pshadestyle:=nil;
pshadepower:=nil;
pautoquieten:=nil;
pchimespeed:=nil;
pbrightness:=nil;
pbrightness3:=nil;
pbrightnessF:=nil;
pmorning:=nil;
pevening:=nil;
pcolorlist:=nil;
pchimelist:=nil;
palarmlist:=nil;
preminderlist:=nil;
//was: pnighttitle:=nil;
except;end;
end;
//## xfindcolor ##
function tprogram.xfindcolor(xname:string):longint;
begin
try;xfindcolor2(xname,result);except;end;
end;
//## xfindcolor2 ##
function tprogram.xfindcolor2(xname:string;var xindex:longint):boolean;
var
   p:longint;
begin
try
//defaults
result:=false;
xindex:=0;
//find
for p:=0 to (icolorcount-1) do
begin
if low__comparetext(xname,icolorname[p]) then
   begin
   xindex:=p;
   result:=true;
   break;
   end;
end;//p
except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxxx//sssssssssssssssssssssssssssss
//## xmorn_even ##
function tprogram.xmorn_even(xmorning:boolean):string;
begin
try
result:='';
case xmorning of
true:if (pmorning<>nil) then result:=low__hhmm2(60+pmorning.val,itimeformat);
false:if (pevening<>nil) then result:=low__hhmm2((13*60)+pevening.val,itimeformat);
end;
except;end;
end;
//## _onvalcap ##
procedure tprogram._onvalcap(sender:tobject;var xcap:string);
var
   p:longint;
begin
try
//get
if (sender=nil) then exit
else if (sender=pmorning) then
   begin
   xcap:=pmorning.caption+#32+xmorn_even(true);
   pmorning.odefcap:=low__hhmm2(60+pmorning.def,itimeformat);
   end
else if (sender=pevening) then
   begin
   xcap:=pevening.caption+#32+xmorn_even(false);
   pevening.odefcap:=low__hhmm2((13*60)+pevening.def,itimeformat);
   end
else
   begin
   end;

except;end;
end;
//## xfillCustomcolors ##
procedure tprogram.xfillCustomcolors(xcolname:string);
var
   xindex,f,b:longint;
begin
try
xindex:=xfindcolor(xcolname);
if (pcustomcolors<>nil) and (xindex>=0) and (xindex<=high(icolorname)) and (icolorfont[xindex]<=-100) then
   begin
   f:=frcrange(-icolorfont[xindex]-100,0,high(icolor1));//0..9
   b:=frcrange(-icolorback[xindex]-100,0,high(icolor1));//0..9
   pcustomcolors.col2['f']:=icolor1[f];
   pcustomcolors.col2['b']:=icolor2[b];
   end;
except;end;
end;
//## xfromCustomcolors ##
procedure tprogram.xfromCustomcolors(xcolname:string);
var
   xindex,f,b:longint;
begin
try
xindex:=xfindcolor(xcolname);
if (pcustomcolors<>nil) and (xindex>=0) and (xindex<=high(icolorname)) then
   begin
   f:=frcrange(-icolorfont[xindex]-100,0,high(icolor1));//0..9
   b:=frcrange(-icolorback[xindex]-100,0,high(icolor1));//0..9
   icolor1[f]:=pcustomcolors.col2['f'];
   icolor2[b]:=pcustomcolors.col2['b'];
   end;
except;end;
end;
//## xshowsettings_reload ##
procedure tprogram.xshowsettings_reload;
var
   p,int1:longint;
begin
try
if (pfeather<>nil) then pfeather.val:=ifeather;
if (pshadepower<>nil) then pshadepower.val:=ishadepower;
if (pshadestyle<>nil) then pshadestyle.val:=ishadestyle;
if (pautodim<>nil) then pautodim.val:=iautodim;
if (pautoquieten<>nil) then pautoquieten.val:=iautoquieten;

//was: if (palarmlist<>nil) then palarmlist.text:=ialarmlist.text;
//was: if (preminderlist<>nil) then preminderlist.text:=ireminderlist.text;//09mar2022

if (psettings<>nil) then
   begin
   psettings.vals2['swapcolors']:=iswapcolors;
   psettings.vals2['datetop']:=idatetop;
   psettings.vals2['daytop']:=idaytop;
   psettings.vals2['ontop']:=viontop;
   psettings.vals2['framemax']:=viframemax;
   end;
if (pdateformat<>nil) then pdateformat.val:=idateformat;
if (ptimeformat<>nil) then ptimeformat.val:=itimeformat;

if (pbrightness<>nil) then pbrightness.val:=ibrightness;
if (pbrightnessF<>nil) then pbrightnessF.val:=ibrightness4;
if (pmorning<>nil) then pmorning.val:=imorning;
if (pevening<>nil) then pevening.val:=ievening;

if (pcolorlist<>nil) then
   begin
   pcolorlist.itemindex:=xfindcolor(icolname);
   xfillCustomcolors(icolname);
   end;
if (pcolorsettings<>nil) then
   begin
   pcolorsettings.vals2['swapcolors']:=iswapcolors;
   pcolorsettings.vals2['backmix']:=ibackmix;
   end;

//.chime
if (pchimelist<>nil) then pchimelist.itemindex:=pchimelist.xfindbycaption2(ichimename);

if (pchimeoptions<>nil) then
   begin
   pchimeoptions.vals2['keepopen']:=ikeepopen;
   pchimeoptions.vals2['samplechime']:=isamplechime;
   end;
//.normal
if (pnormal0<>nil) then
   begin
   pnormal0.val:=low__insint(1,inormal0);
   end;
if (pnormal<>nil) then
   begin
   pnormal.vals2['15']:=inormal15;
   pnormal.vals2['30']:=inormal30;
   pnormal.vals2['45']:=inormal45;
   end;
//.bells
if (pbell0<>nil) then
   begin
   pbell0.val:=low__insint(1,ibell0);
   end;
//.sonnerie
if (pson0<>nil) then
   begin
   pson0.val:=low__insint(1,ison0);
   end;
if (pson<>nil) then
   begin
   pson.vals2['15']:=ison15;
   pson.vals2['30']:=ison30;
   pson.vals2['45']:=ison45;
   end;
if (pchimespeed<>nil) then pchimespeed.val:=mid_speed;

//.day
if (pday<>nil) then
   begin
   pday.vals2['day.show']:=idayshow;
   pday.vals2['day.uppercase']:=idayuppercase;
   pday.vals2['day.top']:=idaytop;
   pday.vals2['day.full']:=idayfull;
   end;
//.date
if (pdate<>nil) then
   begin
   pdate.vals2['date.show']:=idateshow;
   pdate.vals2['date.uppercase']:=idateuppercase;
   pdate.vals2['date.top']:=idatetop;
   pdate.vals2['date.full']:=idatefull;
   end;
//.pod
if (ppod<>nil) then
   begin
   ppod.vals2['pod.show']:=ipodshow;
   ppod.vals2['pod.uppercase']:=ipoduppercase;
   end;
//.rem
if (prem<>nil) then
   begin
   prem.vals2['rem.uppercase']:=iremuppercase;
   prem.vals2['rem.top']:=iremtop;
   end;
//.part of day labels
if (plabel_predawn<>nil)     then plabel_predawn.value:=ilabel_predawn;
if (plabel_morning<>nil)     then plabel_morning.value:=ilabel_morning;
if (plabel_afternoon<>nil)   then plabel_afternoon.value:=ilabel_afternoon;
if (plabel_evening<>nil)     then plabel_evening.value:=ilabel_evening;
except;end;
try;xshowsettings_showhide;except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxx//sssssssssssssssssssssssss//hhhhhhhhhhhhhh
//## xshowsettings_showhide ##
procedure tprogram.xshowsettings_showhide;
var
   bol1,xmustalignpaint:boolean;
   xname,str1:string;
   xtep,xstyle,xindex,p:longint;
   xintro,xdong,xdong2:tstr8;
   xnow:tdatetime;
   //## pshowBychimestyle ##
   procedure pshowBychimestyle(x:tbasiccontrol;xchimestyle:longint);
   var
      bol1:boolean;
   begin
   if (x<>nil) then
      begin
      bol1:=(xstyle=xchimestyle);
      if (bol1<>x.visible) then
         begin
         x.visible:=bol1;
         xmustalignpaint:=true;
         end;
      end;
   end;
begin
try
//defaults
xmustalignpaint:=false;
chm_findname(ichimename,xindex);
chm_info(xindex,xname,xstyle,xtep,xintro,xdong,xdong2);
//get
//.normal - 14mar2022
pshowBychimestyle(pnormal0,chmsStandard);
pshowBychimestyle(pnormal,chmsStandard);
//.bells - 14mar2022
pshowBychimestyle(pbell0,chmsBells);
//.sonnerie - 15mar2022
pshowBychimestyle(pson0,chmsSonnerie);
pshowBychimestyle(pson,chmsSonnerie);
//.auto dim
if (pautodim<>nil) then
   begin
//was:   if (pautodim.val=0) then pautodim.caption:='Dim is off'
//       else                     pautodim.caption:='Dim between '+xmorn_even(false)+' and '+xmorn_even(true)+' to';
   if (pautodim.val=0) then pautodim.caption:='Reduce Brightness Off'
   else                     pautodim.caption:='Reduce Brightness To  ('+xmorn_even(false)+' - '+xmorn_even(true)+')';
   end;
//.auto quieten
if (pautoquieten<>nil) then
   begin
//was:    if (pautoquieten.val=0) then pautoquieten.caption:='Quieten is off'
//        else                         pautoquieten.caption:='Quieten between '+xmorn_even(false)+' and '+xmorn_even(true)+' to';
   if (pautoquieten.val=0) then pautoquieten.caption:='Reduce Volume Off'
   else                         pautoquieten.caption:='Reduce Volume To  ('+xmorn_even(false)+' - '+xmorn_even(true)+')';
   end;
//.date format
if (pdateformat<>nil) then
   begin
   xnow:=now;
   for p:=0 to 3 do
   begin
   str1:=low__datestr(xnow,p,idatefull);
   if idateUppercase then str1:=low__uppercase(str1);
   pdateformat.caps[p]:=str1;
   pdateformat.hlps[p]:='Set date format to "'+str1+'"';//13mar2022
   end;
   end;
//.custom colors
if (pcustomcolors<>nil) then
   begin
   bol1:=low__comparetext(strcopy1(icolname,1,6),'custom');
   if (pcustomcolors.visible<>bol1) then
      begin
      pcustomcolors.visible:=bol1;
      xmustalignpaint:=true;
      end;
   end;
//set
if xmustalignpaint then gui.fullalignpaint;
except;end;
end;
//## xcustomcolorchanged ##
procedure tprogram.xcustomcolorchanged(sender:tobject);
begin
try
if (sender=pcustomcolors) then
   begin
   xfromCustomcolors(icolname);
   if (pcolorlist<>nil) then pcolorlist.paintnow;
   end
else if (sender=pcolorlist) then
   begin
   icolname:=icolorname[frcrange(pcolorlist.itemindex,0,high(icolorname))];
   xmustcolor;//sync frame colors and owinLdrcolor before initing a paint request to prevent "frame corners" from being momentarialy out-of-color-sync - 15mar2022
   xfillCustomcolors(icolname);
   xshowsettings_showhide;
   end;
except;end;
end;
//## xshowsettings_sync ##
procedure tprogram.xshowsettings_sync(sender:tobject);
begin
try;xshowsettings_sync2(sender,'');except;end;
end;
//## xshowsettings_sync2 ##
procedure tprogram.xshowsettings_sync2(sender:tobject;xname:string);
label
   skipend;
var
   str1,e,n,v:string;
   p,int1,int2:longint;
   bol1:boolean;
   aset:tbasicset;//pointer only
   a:tbasiccontrol;
   xmustchime,xSyncandsave,xsubpaint:boolean;
begin
try
//check
if isettingssynclock then exit;
//init
xmustchime:=false;
xSyncandsave:=false;
xsubpaint:=false;
//get
if (pfeather<>nil) then ifeather:=pfeather.val;//13nov2022
if (pshadepower<>nil) then ishadepower:=pshadepower.val;//13nov2022
if (pshadestyle<>nil) then ishadestyle:=pshadestyle.val;//13nov2022
if (pautodim<>nil) then iautodim:=pautodim.val;
if (pautoquieten<>nil) then iautoquieten:=pautoquieten.val;
if (pchimelist<>nil) and (sender=pchimelist) and isamplechime then playtestchime;//06nov2022


//was: if (palarmlist<>nil) then ialarmlist.text:=palarmlist.text;
//was: if (preminderlist<>nil) then ireminderlist.text:=preminderlist.text;//09mar2022
if (psettings<>nil) then
   begin
   if (psettings.vals2['ontop']<>viontop) then
      begin
      syssettings.b['ontop']:=psettings.vals2['ontop'];
      xSyncandsave:=true;
      end;
   if (psettings.vals2['framemax']<>viframemax) then
      begin
      syssettings.b['framemax']:=psettings.vals2['framemax'];
      xSyncandsave:=true;
      end;
   xsubpaint:=true;
   end;
if (pcolorsettings<>nil) and (sender=pcolorsettings) then
   begin
   iswapcolors:=pcolorsettings.vals2['swapcolors'];
   ibackmix:=pcolorsettings.vals2['backmix'];
   end;
if (pdateformat<>nil) then idateformat:=pdateformat.val;
if (ptimeformat<>nil) then itimeformat:=ptimeformat.val;

if (pbrightness<>nil) and (sender=pbrightness) then ibrightness:=frcrange(pbrightness.val,10,100);
if (pbrightnessF<>nil) then ibrightness4:=frcrange(pbrightnessF.val,10,100);
if (pbrightness3<>nil) and (sender=pbrightness3) then ibrightness:=frcrange(pbrightness3.val,10,100);
if (pmorning<>nil) then imorning:=frcrange(pmorning.val,0,600);
if (pevening<>nil) then ievening:=frcrange(pevening.val,0,600);

if (pmorning<>nil) or xsubpaint then pmorning.paintnow;
if (pevening<>nil) or xsubpaint then pevening.paintnow;
//.chime
if (pchimelist<>nil) and (sender=pchimelist) then
   begin
   if low__setstr(ichimename,pchimelist.xgetval2(pchimelist.itemindex)) then xmustchime:=true;
   end;
//.chime options
if (pchimeoptions<>nil) then
   begin
   ikeepopen:=pchimeoptions.vals2['keepopen'];
   isamplechime:=pchimeoptions.vals2['samplechime'];
   end;
//.standard
if (pnormal0<>nil) then
   begin
   if low__setbol(inormal0 ,pnormal0.val<>0)  then xmustchime:=true;
   end;
if (pnormal<>nil) then//14mar2022
   begin
   if low__setbol(inormal15,pnormal.vals2['15']) then xmustchime:=true;
   if low__setbol(inormal30,pnormal.vals2['30']) then xmustchime:=true;
   if low__setbol(inormal45,pnormal.vals2['45']) then xmustchime:=true;
   end;
//.bells
if (pbell0<>nil) then
   begin
   if low__setbol(ibell0 ,pbell0.val<>0)  then xmustchime:=true;
   end;
//.sonnerie
if (pson0<>nil) then
   begin
   if low__setbol(ison0 ,pson0.val<>0)  then xmustchime:=true;
   end;
if (pson<>nil) then
   begin
   if low__setbol(ison15,pson.vals2['15']) then xmustchime:=true;
   if low__setbol(ison30,pson.vals2['30']) then xmustchime:=true;
   if low__setbol(ison45,pson.vals2['45']) then xmustchime:=true;
   end;

if (pchimespeed<>nil) then mid_setspeed(pchimespeed.val);
//.day
if (pday<>nil) then
   begin
   idayshow        :=pday.vals2['day.show'];
   idayuppercase   :=pday.vals2['day.uppercase'];
   idaytop         :=pday.vals2['day.top'];
   idayfull        :=pday.vals2['day.full'];
   end;
//.date
if (pdate<>nil) then
   begin
   idateshow       :=pdate.vals2['date.show'];
   idateuppercase  :=pdate.vals2['date.uppercase'];
   idatetop        :=pdate.vals2['date.top'];
   idatefull       :=pdate.vals2['date.full'];
   end;
//.pod
if (ppod<>nil) then
   begin
   ipodshow        :=ppod.vals2['pod.show'];
   ipoduppercase   :=ppod.vals2['pod.uppercase'];
   end;
//.rem
if (prem<>nil) then
   begin
   iremuppercase   :=prem.vals2['rem.uppercase'];
   iremtop         :=prem.vals2['rem.top'];
   end;
//.part of day labels
if (plabel_predawn<>nil)     then ilabel_predawn:=strcopy1(plabel_predawn.value,1,ishortlabellimit);
if (plabel_morning<>nil)     then ilabel_morning:=strcopy1(plabel_morning.value,1,ishortlabellimit);
if (plabel_afternoon<>nil)   then ilabel_afternoon:=strcopy1(plabel_afternoon.value,1,ishortlabellimit);
if (plabel_evening<>nil)     then ilabel_evening:=strcopy1(plabel_evening.value,1,ishortlabellimit);

//sync
if (psettings<>nil) then
   begin
   psettings.vals2['swapcolors']:=iswapcolors;
   end;
if (pcolorsettings<>nil) then
   begin
   pcolorsettings.vals2['swapcolors']:=iswapcolors;
   end;
if (pbrightness<>nil) then pbrightness.val:=ibrightness;
if (pbrightness3<>nil) then pbrightness3.val:=ibrightness;

if (palarmlist<>nil) then//08mar2022
   begin
   palarmlist.otimeformat:=itimeformat;
   palarmlist.odateformat:=idateformat;
   end;
if (preminderlist<>nil) then//09mar2022
   begin
   preminderlist.otimeformat:=itimeformat;
   preminderlist.odateformat:=idateformat;
   end;
//.viSyncandsave
if xSyncandsave then viSyncandsave;

//.xmustchime
if xmustchime then
   begin
   if (pchimelist<>nil) then pchimelist.paintnow;
   replaychime;
   end;
skipend:
except;end;
try;xshowsettings_showhide;except;end;
end;
//## xstopactive ##
function tprogram.xstopactive:boolean;
var
   amsg:string;
   abuzzer:boolean;
   p:longint;
begin
try
//defaults
result:=false;
//get
if (iactbuzzer>=1) or (iactmsg<>'') then
   begin
   result:=true;
   ialarmlist.stopactive;
   ilaststopactive64:=ms64+1000;
   end;
//delayed
if (ilaststopactive64>=ms64) then result:=true;//allows for double clicks or multiple user clicks without accidently altering maximised mode - 01mar2022
except;end;
end;
//## xsyscol ##
function tprogram.xsyscol(x:longint;xforeground:boolean):longint;
begin
try
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
except;end;
end;
//## xmustcolor ##
function tprogram.xmustcolor:boolean;
var
   b,f,int1:longint;
   xswapcolors:boolean;
   //## xrunframe_findcolor ##
   function xrunframe_findcolor:longint;//returns minsize for frame
   var
      int1,s,d:longint;
   begin
   low__framecols(ibackcolor,rootwin.oframecolor,rootwin.oframecolor2,int1,s,d);
   result:=d;
   end;
begin
try
result:=false;
//init
xswapcolors:=iswapcolors;
if low__setstr(ilastcolname,icolname) or (icolorindex<0) or (icolorindex>high(icolorname)) then icolorindex:=xfindcolor(icolname);
//.b
b:=xsyscol(icolorback[icolorindex],false);
//.f
f:=xsyscol(icolorfont[icolorindex],true);
//.mix
if ibackmix then
   begin
   b:=low__colsplice(20,f,b);
   end;
//.back
if low__setint(ibackcolor,low__aorb(b,f,xswapcolors)) then result:=true;
if low__setint(rootwin.oframecolor2,low__aorb(b,f,xswapcolors)) then result:=true;
//.font
if low__setint(ifontcolor,low__aorb(f,b,xswapcolors)) then result:=true;
if low__setint(rootwin.oframecolor,low__aorb(f,b,xswapcolors)) then result:=true;
//.find the correct inner frame color for proper cornering - 15mar2022
if low__setint(rootwin.owinLdrCOLOR,xrunframe_findcolor) then result:=true;
except;end;
end;
//## xmustframe ##
function tprogram.xmustframe:boolean;//fixed 06nov2022
var
   xok:boolean;
begin
try
result:=false;
//framebrightness
xok:=gui.omax_entirescreen;
rootwin.oframebrightnessDARK:=ibackcolor2;
rootwin.oframebrightness:=iframebrightness;
//ref
if low__setstr(iframeref,inttostr(rootwin.oframecolor)+'|'+inttostr(rootwin.oframecolor2)+'|'+inttostr(vititle.frame)+'|'+inttostr(vititle.frame2)+'|'+inttostr(rootwin.oframebrightness)+'|'+inttostr(rootwin.oframebrightnessDARK)+'|'+bnc(gui.omax_entirescreen)) then result:=true;
except;end;
end;
//## xmustclock ##
function tprogram.xmustclock:boolean;
var
   xzoom:double;
   xmustquieten,xmustquieten2,xforcebright,xforcedim:boolean;
   dfeather,xshadepower,xshadestyle,xautodim,int1:longint;
   v:string;
begin
try
//defaults
result:=false;
xmustquieten:=false;
xmustquieten2:=false;
//init
xautodim:=iautodim;
xshadepower:=ishadepower;
xshadestyle:=ishadestyle;
ilastfeather:=ifeather;
dfeather:=low__insint(4,ilastfeather>=3);
xforcedim:=false;
xforcebright:=false;
//get
//case misscreenw of
case gui.width of
0..400:       xzoom:=2;
401..800:     xzoom:=3;
801..1300:    xzoom:=5;
1301..1920:   xzoom:=6;
1921..maxint: xzoom:=10;
else          xzoom:=2;
end;
//set
if xmustcolor then result:=true;//check color

if low__clockface(now,xzoom,iactbuzzer,iactmsg,iremmsg,idaytop,iremtop,idatetop,ihavebuzzer,ihavemsg,ihaveremmsg,(sysflash and ((iactbuzzer>=1) or (iactmsg<>''))),idateformat,itimeformat,ibackcolor,ifontcolor,ibrightness,imorning,ievening,xautodim,dfeather,idayshow,ipodshow,true,idateshow,iremUppercase,idatefull,idateUppercase,idayfull,idayUppercase,ipodUppercase,xforcedim,ilabel_predawn,ilabel_morning,ilabel_afternoon,ilabel_evening,iscreenref,ibellref,iscreenbuffer,ibellbuffer,iminfontsize2,ibackcolor2,ifontcolor2,int1,iscrollref,iscrollref2,iscrollref64,xmustquieten2) then result:=true;
if low__setstr(iscreenref2,inttostr(ilastfeather)+'|'+inttostr(dfeather)+'|'+inttostr(xshadepower)+'|'+inttostr(xshadestyle)+'|'+inttostr(iminfontsize2)+'|'+inttostr(ibackcolor2)+'|'+inttostr(ifontcolor2)) then result:=true;
if low__setint(iframebrightness,(int1*ibrightness4) div 100) then result:=true;

//.quieten
imustquieten:=xmustquieten or xmustquieten2;
except;end;
end;
//## xscreenpaint ##
procedure tprogram.xscreenpaint(sender:tobject);
var
   //infovars
   a:pvirtualinfo;
   cs,ci:trect;
   fn,fb,fnH,fbH,fnbH,cw,ch,xfont,xfontdisable,xback,xborder,xhover,xfontheight,xfeather,xbordersize:longint;
   xenabled,xround,xnormal:boolean;
   //other
   xfontcolor2,xback2,xshadepower,dfeather,xshadestyle,xsparkle:longint;
   sw,sh,dw,dh:longint;
   //## xlum ##
   function xlum(xcol:longint):longint;
   var
      a:tcolor24;
   begin
   result:=low__greyscale2b(low__intrgb(xcol));
   end;
begin
try
//init
iscreen.infovars(a,cs,ci,fn,fb,fnH,fbH,fnbH,cw,ch,xfont,xfontdisable,xback,xborder,xhover,xfontheight,xfeather,xbordersize,xenabled,xround,xnormal);
xshadepower:=frcrange(ishadepower,0,100);
xshadestyle:=frcrange(ishadestyle,0,4);
xfontcolor2:=ifontcolor2;
xback:=ibackcolor2;
xback2:=low__sc1(xshadepower/100,xback,xfontcolor2);

//make
xmustcolor;
xmustclock;
case frcrange(ilastfeather,0,4) of
0..2:dfeather:=1+ilastfeather;
3:dfeather:=2;//blur 1
4:dfeather:=3;//blur 2
end;

if (xshadestyle>=1) then
   begin
   if (xlum(xback)<xlum(xback2)) then low__swapint(xback,xback2);
   if vishadeglow then low__swapint(xback,xback2);
   end;

//cls
case xshadestyle of
0:iscreen.lds(cs,xback,false);//flat
1:iscreen.lds2(cs,xback,xback2,xback,0,'g50',false);//shade
2:iscreen.lds2(cs,xback2,xback,xback,0,'g50',false);//shade 2
3:iscreen.lds2(cs,xback2,xback,xback,0,'g-50',false);//round
4:iscreen.lds2(cs,xback,xback2,xback,0,'g-50',false);//glow
end;

//draw
cw:=ci.right-ci.left+1;
ch:=ci.bottom-ci.top+1;
sw:=misw(iscreenbuffer);
sh:=mish(iscreenbuffer);
low__scale(cw,ch,sw,sh,dw,dh);

//.important: uses a static feather level of 1px - anything more can cause distortion problems between the 2 different text anti-alias systems - 15mar2022
//iscreen.ldc2(ci,ci.left+(cw-dw) div 2,ci.top+(ch-dh) div 2,dw,dh,miscellarea(iscreenbuffer,0),iscreenbuffer,255,1,0,ifontcolor2,0,true);
iscreen.ldc2(ci,ci.left+(cw-dw) div 2,ci.top+(ch-dh) div 2,dw,dh,miscellarea(iscreenbuffer,0),iscreenbuffer,255,dfeather,0,ifontcolor2,0,true);
//other
iscreen.xparentcorners;
except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxx//sssssssssssssssssss
//## xrootwinnotify ##
function tprogram.xrootwinnotify(sender:tobject):boolean;
begin
try
//defaults
result:=false;

//key
if (gui.key<>aknone) then
   begin
   case gui.key of
   akEscape:begin
      result:=true;//handled
      if not xstopactive then gui.fullscreen:=not gui.fullscreen;
      end;
   end;//case
   end;
except;end;
end;
//## xscreennotify ##
function tprogram.xscreennotify(sender:tobject):boolean;
var
   xstoppingalarm,xmustnormal,xmustpaint:boolean;
begin
try
//defaults
result:=true;//handled
xmustpaint:=false;
xmustnormal:=false;
xstoppingalarm:=false;

//key
if (gui.key<>aknone) then
   begin
   xstoppingalarm:=xstopactive;//all other keys silence the alarms
   case gui.key of
   akEscape:if not xstoppingalarm then xmustnormal:=not xmustnormal;
   end;//case
   end;

//.inside area of screen
if gui.mousedownstroke or gui.mouseupstroke then
   begin
   iinsidescreen:=iscreen.xinsideclientarea2(iscreen.mousex,iscreen.mousey);
   //silence the alarms
   xstoppingalarm:=xstopactive;
   end;

//.don't display the toolbar since user is cancelling the buzzer alarm etc - 07mar2022
if xstoppingalarm then iignoreclick64:=ms64+2000;

//xmustnormal
if xmustnormal then gui.fullscreen:=not gui.fullscreen;

//xmustpaint
if xmustpaint then iscreen.paintnow;

//drag support -> pass-thru "rootwin.xhead"
if gui.mousedown or gui.mousedragging or gui.mouseupstroke then rootwin.xhead.xdragthewindow;

//right click -> show program menu - 06nov2022
if gui.mouseupstroke and gui.mouseright then rootwin.xhead.xcmd('i');
except;end;
end;
//## xshowmenuFill1 ##
procedure tprogram.xshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
begin
try
//check
if zznil(xmenudata,5000) then exit;
except;end;
end;
//## xshowmenuClick1 ##
function tprogram.xshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
begin
try
//handled
result:=true;
except;end;
end;
//## xloadsettings ##
procedure tprogram.xloadsettings;
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
a.s['alarmlist']:=prgsettings.sdef('alarmlist','');
a.s['reminderlist']:=prgsettings.sdef('reminderlist','');
a.s['colname']:=prgsettings.sdef('colname','Default');
a.b['swapcolors']:=prgsettings.bdef('swapcolors',false);
a.b['backmix']:=prgsettings.bdef('backmix',false);
a.b['showrem']:=prgsettings.bdef('showrem',true);//09mar2022
a.i['autodim']:=prgsettings.idef('autodim',0);
a.i['feather']:=prgsettings.idef('feather',1);//13nov2022
a.i['shadepower']:=prgsettings.idef('shadepower',20);//13nov2022
a.i['shadestyle']:=prgsettings.idef('shadestyle',3);//13nov2022
a.i['autoquieten']:=prgsettings.idef('autoquieten',0);
a.i['dateformat']:=prgsettings.idef('dateformat',2);//15nov2022
a.i['timeformat']:=prgsettings.idef('timeformat',1);//13mar2022
a.i['brightness.frame']:=prgsettings.idef('brightness.frame',100);
a.i['brightness']:=prgsettings.idef('brightness',100);
a.i['brightness2']:=prgsettings.idef('brightness2',40);
a.i['morning']:=prgsettings.idef('morning',360);
a.i['evening']:=prgsettings.idef('evening',360);
//.customcolors
for p:=0 to high(icolor1) do
begin
a.i['f.col'+inttostr(p)]:=prgsettings.idef('f.col'+inttostr(p),low__rgb(255,255,255));
a.i['b.col'+inttostr(p)]:=prgsettings.idef('b.col'+inttostr(p),0);
end;
//.chime
a.s['chimename']:=prgsettings.sdef('chimename','');//14nov2022, 14mar2022
a.b['normal0']   :=prgsettings.bdef('normal0',false);//0=Melody and Dongs, 1=Donlys Only - 14nov2022
a.b['normal15']  :=prgsettings.bdef('normal15',true);
a.b['normal30']  :=prgsettings.bdef('normal30',true);
a.b['normal45']  :=prgsettings.bdef('normal45',true);
a.b['bell0']     :=prgsettings.bdef('bell0',false);//off
a.b['bell15']    :=prgsettings.bdef('bell15',true);
a.b['bell30']    :=prgsettings.bdef('bell30',true);
a.b['bell45']    :=prgsettings.bdef('bell45',true);
a.b['son0']      :=prgsettings.bdef('son0',false);//off
a.b['son15']     :=prgsettings.bdef('son15',true);
a.b['son30']     :=prgsettings.bdef('son30',true);
a.b['son45']     :=prgsettings.bdef('son45',true);
a.b['keepopen']:=prgsettings.bdef('keepopen',false);//13mar2022
a.b['samplechime']:=prgsettings.bdef('samplechime',true);//06nov2022
a.i['chimespeed']:=prgsettings.idef('chimespeed',100);
a.i['midvol']:=prgsettings.idef('midvol',100);//09nov2022
//.day
a.b['day.show']       :=prgsettings.bdef('day.show',true);//13mar2022
a.b['day.uppercase']  :=prgsettings.bdef('day.uppercase',true);//13mar2022
a.b['day.top']        :=prgsettings.bdef('day.top',true);//13mar2022
a.b['day.full']       :=prgsettings.bdef('day.full',true);//13mar2022
//.date
a.b['date.show']      :=prgsettings.bdef('date.show',true);//13mar2022
a.b['date.uppercase'] :=prgsettings.bdef('date.uppercase',true);//13mar2022
a.b['date.top']       :=prgsettings.bdef('date.top',true);//13mar2022
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
icolname:=icolorname[xfindcolor(a.s['colname'])];
iswapcolors:=a.b['swapcolors'];
ibackmix:=a.b['backmix'];
iautodim:=frcrange(a.i['autodim'],0,9);
ifeather:=frcrange(a.i['feather'],0,3);//13nov2022
ishadepower:=frcrange(a.i['shadepower'],0,100);//13nov2022
ishadestyle:=frcrange(a.i['shadestyle'],0,4);//13nov2022
iautoquieten:=frcrange(a.i['autoquieten'],0,9);
idateformat:=frcrange(a.i['dateformat'],0,3);
itimeformat:=frcrange(a.i['timeformat'],0,2);//13mar2022
ibrightness4:=frcrange(a.i['brightness.frame'],10,100);
ibrightness:=frcrange(a.i['brightness'],10,100);
imorning:=frcrange(a.i['morning'],0,600);
ievening:=frcrange(a.i['evening'],0,600);
idaytop:=a.b['daytop'];
idatetop:=a.b['datetop'];
ialarmlist.text64:=a.s['alarmlist'];//08mar2022
ireminderlist.text64:=a.s['reminderlist'];//09mar2022
//.chime
ichimename:=chm_safename(a.s['chimename'],'*');//use system default defined internally at "tbasicchimes" as "m:Westminster" - 15nov2022
inormal0   :=a.b['normal0'];
inormal15  :=a.b['normal15'];
inormal30  :=a.b['normal30'];
inormal45  :=a.b['normal45'];
ibell0     :=a.b['bell0'];
ison0      :=a.b['son0'];
ison15     :=a.b['son15'];
ison30     :=a.b['son30'];
ison45     :=a.b['son45'];
ikeepopen:=a.b['keepopen'];
isamplechime:=a.b['samplechime'];
mid_setspeed(frcrange(a.i['chimespeed'],25,400));
mmsys_mid_basevol:=frcrange(a.i['midvol'],0,200);
//.day
idayshow         :=a.b['day.show'];
idayuppercase    :=a.b['day.uppercase'];
idaytop          :=a.b['day.top'];
idayfull         :=a.b['day.full'];
//.date
idateshow        :=a.b['date.show'];
idateuppercase   :=a.b['date.uppercase'];
idatetop         :=a.b['date.top'];
idatefull        :=a.b['date.full'];
idatespread      :=a.b['date.spread'];
//.pod
ipodshow         :=a.b['pod.show'];
ipoduppercase    :=a.b['pod.uppercase'];
//.rem
//was: iremshow         :=a.b['rem.show'];
iremuppercase    :=a.b['rem.uppercase'];
iremtop          :=a.b['rem.top'];
//.part of day labels - 13mar2022
ilabel_predawn   :=strcopy1(a.s['label.predawn'],1,ishortlabellimit);
ilabel_morning   :=strcopy1(a.s['label.morning'],1,ishortlabellimit);
ilabel_afternoon :=strcopy1(a.s['label.afternoon'],1,ishortlabellimit);
ilabel_evening   :=strcopy1(a.s['label.evening'],1,ishortlabellimit);
//.customcolors
for p:=0 to high(icolor1) do
begin
icolor1[p]:=a.i['f.col'+inttostr(p)];
icolor2[p]:=a.i['b.col'+inttostr(p)];
end;//p

//sync
prgsettings.data:=a.data;
except;end;
try
freeobj(@a);
iloaded:=true;
except;end;
end;
//## xsavesettings ##
procedure tprogram.xsavesettings;
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
a.s['colname']:=icolname;
a.b['swapcolors']:=iswapcolors;
a.b['backmix']:=ibackmix;
a.i['autodim']:=frcrange(iautodim,0,9);
a.i['feather']:=frcrange(ifeather,0,3);//13nov2022
a.i['shadepower']:=frcrange(ishadepower,0,100);//13nov2022
a.i['shadestyle']:=frcrange(ishadestyle,0,4);//13nov2022
a.i['autoquieten']:=frcrange(iautoquieten,0,9);//12mar2022
a.i['dateformat']:=frcrange(idateformat,0,3);
a.i['timeformat']:=frcrange(itimeformat,0,2);//13mar2022
a.i['brightness.frame']:=frcrange(ibrightness4,10,100);
a.i['brightness']:=frcrange(ibrightness,10,100);
a.i['morning']:=frcrange(imorning,0,600);
a.i['evening']:=frcrange(ievening,0,600);
a.s['alarmlist']:=ialarmlist.text64;
a.s['reminderlist']:=ireminderlist.text64;//09mar2022
//.chime
a.s['chimename']:=chm_safename(ichimename,'*');
a.b['normal0']   :=inormal0;
a.b['normal15']  :=inormal15;
a.b['normal30']  :=inormal30;
a.b['normal45']  :=inormal45;
a.b['bell0']     :=ibell0;
a.b['son0']      :=ison0;
a.b['son15']     :=ison15;
a.b['son30']     :=ison30;
a.b['son45']     :=ison45;
a.b['keepopen']:=ikeepopen;
a.b['samplechime']:=isamplechime;
a.i['chimespeed']:=frcrange(mid_speed,25,400);
a.i['midvol']:=frcrange(mmsys_mid_basevol,0,200);//09nov2022
//.day
a.b['day.show']       :=idayshow;
a.b['day.uppercase']  :=idayuppercase;
a.b['day.top']        :=idaytop;
a.b['day.full']       :=idayfull;
//.date
a.b['date.show']      :=idateshow;
a.b['date.uppercase'] :=idateuppercase;
a.b['date.top']       :=idatetop;
a.b['date.full']      :=idatefull;
a.b['date.spread']    :=idatespread;
//.pod
a.b['pod.show']       :=ipodshow;
a.b['pod.uppercase']  :=ipoduppercase;
//.rem
//was: a.b['rem.show']       :=iremshow;
a.b['rem.uppercase']  :=iremuppercase;
a.b['rem.top']        :=iremtop;
//.part of day labels - 13mar2022
a.s['label.predawn']  :=strcopy1(ilabel_predawn,1,ishortlabellimit);
a.s['label.morning']  :=strcopy1(ilabel_morning,1,ishortlabellimit);
a.s['label.afternoon']:=strcopy1(ilabel_afternoon,1,ishortlabellimit);
a.s['label.evening']  :=strcopy1(ilabel_evening,1,ishortlabellimit);
//.customcolors
for p:=0 to high(icolor1) do
begin
a.i['f.col'+inttostr(p)]:=icolor1[p];
a.i['b.col'+inttostr(p)]:=icolor2[p];
end;//p
//set
prgsettings.data:=a.data;
siSaveprgsettings;
except;end;
try;freeobj(@a);except;end;
end;
//## xautosavesettings ##
procedure tprogram.xautosavesettings;
var
   str0,str1:string;
   p:longint;
begin
try
//check
if (not iloaded) or gui.mousedown then exit;
//get
//.misc
str1:=
bnc(idayshow)+
bnc(idayuppercase)+
bnc(idaytop)+
bnc(idayfull)+
//.date
bnc(idateshow)+
bnc(idateuppercase)+
bnc(idatetop)+
bnc(idatefull)+
bnc(idatespread)+
//.pod
bnc(ipodshow)+
bnc(ipoduppercase)+
//.rem
//was: bnc(iremshow)+
bnc(iremuppercase)+
bnc(iremtop)+
//.part of day labels
#1+
ilabel_predawn+#1+
ilabel_morning+#1+
ilabel_afternoon+#1+
ilabel_evening+#1+
//.other
bnc(iswapcolors)+bnc(ibackmix)+'|'+
inttostr(iautodim)+'|'+inttostr(ifeather)+'|'+inttostr(ishadepower)+'|'+inttostr(ishadestyle)+'|'+inttostr(iautoquieten)+'|'+
inttostr(ialarmlist.id)+'|'+inttostr(ireminderlist.id)+'|'+inttostr(idateformat)+'|'+inttostr(itimeformat)+'|'+
inttostr(ibrightness4)+'|'+inttostr(ibrightness)+'|'+inttostr(ievening)+'|'+inttostr(imorning)+'|'+icolname+'|'+
bnc(ikeepopen)+bnc(isamplechime)+
//.normal
bnc(inormal0)+bnc(inormal15)+bnc(inormal30)+bnc(inormal45)+
//.bell
bnc(ibell0)+
//.son
bnc(ison0)+bnc(ison15)+bnc(ison30)+bnc(ison45)+
//.other
'|'+inttostr(mid_speed)+'|'+ichimename;
//.custom colors
str0:='';
for p:=0 to high(icolor1) do str0:=str0+inttostr(icolor1[p])+'|'+inttostr(icolor2[p])+'|';
//set
if low__setstr(isettingsref,str0+str1) then xsavesettings;
except;end;
end;
//## __onclick ##
procedure tprogram.__onclick(sender:tobject);
begin
try;xcmd(sender,0,'');except;end;
end;
//## xcmd ##
procedure tprogram.xcmd(sender:tobject;xcode:longint;xcode2:string);
label
   skipend;
var
   xfilterindex,int1,xtepcolor:longint;
   zok:boolean;
begin//use for testing purposes only - 15mar2020
try
//init
zok:=zzok(sender,7455);
if zok and (sender is tbasictoolbar) then
   begin
   //ours next
   xcode:=(sender as tbasictoolbar).ocode;
   xcode2:=low__lowercase((sender as tbasictoolbar).ocode2);
   end;
//get
if (xcode2='options') then
   begin
   gui.xshowoptions;
   xshowsettings_reload;
   end
else if (xcode2='test') then chm_setbuzzer(not chm_buzzer)
else if (xcode2='test2') then chm_playname('m:westminster',0,true,true,true,true,true)
else if (xcode2='stop') then chm_stop
else if (xcode2='chime.stop') then chm_stop
else if (xcode2='chime.play') then
   begin
   case chm_playing of
   false:playtestchime;
   true:chm_stop;
   end;
   end
else
   begin
   if system_debug then showbasic('Unknown Command>'+xcode2+'<<');
   end;
skipend:
except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxx//ssssssssssssssssssssssssssssssss
//## replaychime ##
procedure tprogram.replaychime;
begin
try
//check
if not chm_chiming then exit;
//get
case chm_testing of
true:playtestchime;
//false:chm_playname(ichimename,ichimestyle,0,false,false,false,true);except;end;
end;
except;end;
end;
//## playtestchime ##
procedure tprogram.playtestchime;
begin
try
chm_playname3(ichimename,0,inormal0,inormal15,inormal30,inormal45,ibell0,ison0,ison15,ison30,ison45,true);
except;end;
end;
//## __onvisync ##
procedure tprogram.__onvisync(sender:tobject);
begin
try
//sync frame color NOW so when paint fires the colors are already sorted first time round - 07mar2022
xmustcolor;
xmustframe;
except;end;
end;
//## __ontimer ##
procedure tprogram.__ontimer(sender:tobject);//._ontimer
label
   skipend;
var
   a:tint4;
   b:tstr8;
   int1,int2:longint;
   bol1,xmustpaintalign,xmustpaintframe,xmustpaint:boolean;
   //current alarm info
   xindex,xremsecs,xbuzzer:longint;
   str1,e,xmsg:string;
   xhavebuzzer,xhavemsg:boolean;
begin
try
//init
b:=nil;
xmustpaint:=false;
xmustpaintframe:=false;
xmustpaintalign:=false;

//timer100
if (ms64>=itimer100) and iloaded then
   begin
   //pchimetest
   if (pchimetest<>nil) and mm_inited and low__setstr(ilastmidtest,inttostr(pchimetest.core.dataid2)) then
      begin
      if (b=nil) then b:=bnew;
      pchimetest.iogettxt(b);
      str1:=b.text;
      b.clear;
      if not low__makemid(str1,b,e) then showerror(e);
      mid_playmidi(b);
      end;

   //xmustclock
   if xmustclock then
      begin
      xmustpaint:=true;
      if gui.mousedown then app__turbo;//13nov2022
      end;
   //xmustframe
   if xmustframe then
      begin
      xmustpaint:=true;
      xmustpaintframe:=true;
      if gui.mousedown then app__turbo;//13nov2022
      end;
   //reset
   itimer100:=ms64+100;
   end;

//timer250
if (ms64>=itimer250) then
   begin
   //play
   if (pchimebar<>nil) then
      begin
      bol1:=chm_playing;
      pchimebar.benabled2['chime.stop']:=bol1;
      pchimebar.benabled2['chime.play']:=bol1 or (not low__comparetext(ichimename,'none'));
      pchimebar.bflash2['chime.play']:=bol1;
      end;
   if (ptoolbar<>nil) then
      begin
      bol1:=chm_playing;
      ptoolbar.bflash2[scPage+'chime']:=bol1;
      ptoolbar.bpert2[scPage+'chime']:=chm_chimingpert;//show chiming progress - 07mar2022
      end;

   //hide cursor
   if gui.omax_entirescreen then
      begin
      if gui.fullscreen and (low__inputidle>=1000) and (not isettingsshowing) and (not sys.showingoptions) then gui.hidecursor else gui.showcursor;
      end;

   //check alarms + reminders
   ialarmlist.findactive(now,iactindex,iactrem,iactbuzzer,iactmsg,ihavebuzzer,ihavemsg);
   ireminderlist.findactive(now,iremindex,int1,int2,iremmsg,bol1,ihaveremmsg);

   //sound alarm buzzer -> need to interrupt chimes playback - 01mar2022
   if ((palarmlist<>nil) and (not palarmlist.testingbuzzer)) and (iactbuzzer<>chm_buzzer) then chm_setbuzzer(iactbuzzer);

   //reset
   itimer250:=ms64+250;
   end;

//timer500
if (ms64>=itimer500) then
   begin

//debug: rootwin.xhead.caption:=inttostr(largest(viFeather,vifeatherf))+'<<'+ms64str;//xxxxxxxxxxxx

   //savesettings
   xautosavesettings;

   //chime vol (quieten to)
   if imustquieten then int1:=frcrange((10-iautoquieten)*10,1,100) else int1:=100;
   if (int1<>chm_vol) then chm_setvol(int1);

   //chime playback
   //.no chiming
   if low__comparetext(ichimename,'none') then ichimemins:=-1
   //.play chimes -> check once per minute
   else if low__setint(ichimemins,nowmin) and chm_mustplayname(ichimename,ichimemins) then
      begin                             
      chm_playname3(ichimename,ichimemins,inormal0,inormal15,inormal30,inormal45,ibell0,ison0,ison15,ison30,ison45,false);
      end;

   //keep open - midi
   bol1:=ikeepopen;
   if (bol1<>mid_keepopen) then mid_setkeepopen(bol1);

   //reset
   itimer500:=ms64+500;
   end;

//debug support
if system_debug then
   begin
   if system_debugFAST then rootwin.paintallnow;
   end;
if system_debug and system_debugRESIZE then
   begin
   if (system_debugwidth<=0) then system_debugwidth:=gui.host.width;
   if (system_debugheight<=0) then system_debugheight:=gui.host.height;
   //change the width and height to stress
   //was: if (random(10)=0) then gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   end;

//mustpaint
if xmustpaintalign then gui.fullalignpaint
else if xmustpaint then
   begin
   if xmustpaintframe then rootwin.paintallnow else iscreen.paintnow;
   end;

skipend:
except;end;
try;if (b<>nil) then bfree(b);except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//cccccccccccccccccccc
//## low__clockface ##
function low__clockface(x:tdatetime;xzoom:double;xactbuzzer:longint;xactmsg,xremmsg:string;xdaytop,xremtop,xdatetop,xhavebuzzer,xhavemsg,xhaveremmsg,xflash:boolean;xdateformat,xtimeformat,xbackcolor,xfontcolor,xbrightness,xmorningMIN,xeveningMIN,xautodim,xfeather:longint;xshowday,xshowpod,xshowrem,xshowdate,xurem,xfdate,xudate,xfday,xuday,xupod,xforcedim:boolean;var xlabel_predawn,xlabel_morning,xlabel_afternoon,xlabel_evening,xref,xbellref:string;s,sbell:tbasicimage;var xoutminfontsize,xoutbackcolor,xoutfontcolor,xoutbrightness,xscrollref,xscrollref2:longint;var xscrollref64:comp;var xoutquieten:boolean):boolean;
label//Note: Always uses "0,0,0" for transparent background no matter what tehe value of "xbackcolor" or "xfontcolor" are - 28feb2022
     //Note: Generates a greyscale image for rendering in color later
   skipend;
var
   a,xfc:tstr8;
   b:trect;
   c1,c2,xwhite,xblack,xdim,xalarmy,p,xallmin,int1,int2,int3,fi,dx,dy,xpad,hsep,sbits,sw,sh:longint;
   xth,xfontname,xday,xdes,xtime,xtime2,xdate,xampm:string;
   y,m,d:word;//date
   h,min,sec,ms:word;//time
   xmustquieten,xdraw,bol1,bol2,dPM:boolean;
   d1:double;
   //bell
   xbellw,xbellh,xbellSOD:longint;
   //fonts
   ai,aw,ah,ahh:longint;//day
   bi,bw,bh,bhh:longint;//des
   ci,cw,ch,chh,cw2:longint;//time
   pi,pw,ph,phh:longint;//time -> AM/PM
   di,dw,dh,dhh:longint;//date
   ei,ew,eh,ehh:longint;//alarm message - 01mar2022
   ri,rw,rh,rhh:longint;//reminder message - 09mar2022
   //## finit ##
   procedure finit(x:string;xsize:longint;xbold:boolean;var i,w,h,h1:longint);
   begin
   //i:=low__font1(xFontname,xsize,xbold);
   xsize:=frcrange(round(xsize*xzoom),6,900);
   i:=low__font2('',xFontname,xsize,xbold);
   i:=low__fontdata(i);
   if (i<>0) and (sysfont_data[i].count<=0) then i:=0;//revert to "root/0" font when something goes wrong
   h:=low__fontmaxh(i);
   h1:=low__fromLGF_height1(sysfont_data[i]);
   w:=low__fonttextwidth2(i,x);
   if (xsize<xoutminfontsize) then xoutminfontsize:=xsize;
   end;
   //## fdraw2 ##
   procedure fdraw2(x:string;dcolor,di,dx,dy:longint);
   begin
   try
   //check
   if zznil(a,1) then exit;
   if (xfc=nil) and (xfeather>=1) then xfc:=bnew;

   //init
   a.text:=x;
   di:=low__fontdata(di);
   if (di<>0) and (sysfont_data[di].count<=0) then di:=0;//revert to "root/0" font when something goes wrong
   //get
   //was: low__fromLGF_drawtext2432TAB2(0,sysfont_data[di],a,dx,dy,sw,sh,dcolor,misarea(s),misarea(s),s,nil,-1,xfc,viFeather,false,false,false,false,false,corNone);
   //was: low__fromLGF_drawtext2432TAB2(0,sysfont_data[di],a,dx,dy,sw,sh,dcolor,misarea(s),misarea(s),s,nil,-1,xfc,4,false,false,false,false,false,corNone);
//   low__fromLGF_drawtext2432TAB2(0,sysfont_data[di],a,dx,dy,sw,sh,dcolor,misarea(s),misarea(s),s,nil,-1,xfc,4,false,false,false,false,false,false,corNone);
//   low__fromLGF_drawtext2432TAB2(0,sysfont_data[di],a,dx,dy,sw,sh,dcolor,misarea(s),misarea(s),s,nil,-1,xfc,4,false,false,false,false,false,false,corNone);
   low__fromLGF_drawtext2432TAB2(0,sysfont_data[di],a,dx,dy,sw,sh,dcolor,misarea(s),misarea(s),s,nil,-1,xfc,xfeather,false,false,false,false,false,false,false,corNone);
//function low__fromLGF_drawtext2432TAB2(xtab:longint;x,xtext:tobject;ax,ay,aw,ah,dcolor:longint;xarea,xarea2:trect;s:tobject;xmask:tmask8;xmaskval:longint;xfc:tstr8;xfeather:longint;xbold,xitalic,xunderline,xlink,xstrikeout,xspell,xround:boolean;xroundstyle:longint):boolean;//23feb2021

   except;end;
   end;
   //## fdraw ##
   procedure fdraw(x:string;di,dx,dy:longint);
   begin
   fdraw2(x,xwhite,di,dx,dy);
   end;
   //## xdrawbell ##
   procedure xdrawbell(dx,dy:longint);
   var//Note: xbell has transparent background of red "255,0,0" don't use this color to draw the TEA - 07mar2022
      xoffset,dbits,ddw,ddh,int1,dw,dh,dc:longint;
   begin
   try
   //check
   if not misok82432(sbell,dbits,ddw,ddh) then exit;
   //color
   dc:=xwhite;
   if (dc=255) then dc:=254;
   //build bell image
//xxxxxxxxxxxxxxxxxxxxxx
   if low__setstr(xbellref,inttostr(xbellw)+'|'+inttostr(xbellh)+'|'+inttostr(dc)) or (xbellw<>ddw) or (xbellh<>ddh) then
      begin
      missize(sbell,xbellw,xbellh);
      miscls(sbell,255);
      low__teadraw(false,false,0,0,dc,dc,maxarea,maxarea,sbell,tepBell,false,false,false,corNone);
      end;
   //offset
   xoffset:=0;
   if (xampm<>'') then xoffset:=(pw-xbellw) div 2;
   //draw
   inc(dx,low__fonttextwidth2(pi,#32));
   dh:=frcmin((ch-ph) div 2,1);
   dw:=frcmin(round(xbellw*(dh/frcmin(xbellh,1))),1);
//   miscopyareaxx(maxarea,dx,dy-dh,dw,dh,misarea(sbell),s,sbell,255,frcrange(largest(low__insint(2,vifeather>=1),low__insint(2,vifeatherf>=1)),1,2),255,0);
   miscopyareaxx(maxarea,dx+xoffset,dy-dh,dw,dh,misarea(sbell),s,sbell,255,frcrange(largest(low__insint(2,xfeather>=1),low__insint(2,xfeather>=1)),1,2),255,0);
   except;end;
   end;
   //paint handlers ------------------------------------------------------------
   //## prem ##
   procedure prem;
   begin
   if (xremmsg='') or (not xshowrem) then exit;
   if not xremtop then inc(dy,hsep);
   case (rw<sw) of
   true:fdraw(xremmsg,ri,(sw-rw) div 2,dy);
   false:begin
      int1:=low__fonttextwidth2(ri,strcopy1(xremmsg,1,frcmin(xscrollref2-6,0)));
      fdraw(xremmsg,ri,-int1,dy);
      if (xscrollref2>=length(xremmsg)) then xscrollref2:=0;
      end;
   end;//case
   inc(dy,rh);
   end;
   //## pday ##
   procedure pday;
   begin
   if not xshowday then exit;
   if xdraw then fdraw(xday,ai,(sw-aw) div 2,dy);
   inc(dy,ah);//+hsep);
   end;
   //## pdate ##
   procedure pdate;
   begin
   if not xshowdate then exit;
   if xdraw then fdraw(xdate,di,(sw-dw) div 2,dy);
   inc(dy,dh);//xx+hsep);
   end;
   //## ppod ##
   procedure ppod;
   begin
   if not xshowpod then exit;
   if xdraw then fdraw(xdes,bi,(sw-bw) div 2,dy);
   inc(dy,bh);//+hsep);
   end;
   //## ptime ##
   procedure ptime;
   begin
   //.time
   case (xampm='') of
   true:begin
      int1:=(sw-cw) div 2;
      if xdraw then fdraw(xtime,ci,int1,dy);//24hr
      end;
   false:begin
      int1:=(sw-(cw+pw)) div 2;
      if xdraw then fdraw(xtime,ci,int1,dy);
      if xdraw then fdraw(xampm,pi,int1+cw,dy+chh-phh);
      end;
   end;

   //draw alarm bell - 07mar2022
   case (xactbuzzer>=1) or (xactmsg<>'') of
   true:if xflash and xdraw then xdrawbell(int1+cw,dy+chh-phh);
   false:if xdraw and (xhavebuzzer or xhavemsg) then xdrawbell(int1+cw,dy+chh-phh);
   end;

   inc(dy,ch);
   end;
   //## palarm ##
   procedure palarm;
   var
      int1,bc,fc,hpad,xbordersize,eew,eeh:longint;
      b:trect;
   begin
   //check
   if (xactmsg='') then exit;
   //init
   xbordersize:=4;//not zoom based -> we use a separate system from the system zoomed font - 15mar2022
   hpad:=xbordersize div 2;
   eew:=frcmin(frcmax(ew,sw-(2*xbordersize)-(2*hpad)),0);
   eeh:=frcmin(frcmax(eh,sh-(2*xbordersize)),0);
   fc:=xwhite;
   bc:=xblack;
   //get - scroll long messages - 06nov2022
   b.left:=((sw-eew) div 2)-xbordersize-hpad;
   b.right:=b.left+eew-1+(2*xbordersize)+(2*hpad);
   b.top:=xalarmy-xbordersize;
   //was: if xflash then inc(b.top,10);//10px or more due to image being scaled up or down -> less than 10 and we risk loosing descernable movement - 15mar2022
   b.bottom:=b.top+eh-1+(2*xbordersize);
   //.window
   if xdraw then
      begin
      //init
      c1:=low__aorb(xblack,xwhite,xflash);
      c2:=low__aorb(xwhite,xblack,xflash);
      //clear background strip - full width for contrast with alarm banner
      misclsarea(s,rect(0,b.top,sw,b.bottom),xblack);
      //window background
      misclsarea(s,b,c1);
      //.text
      case (ew<sw) of
      true:fdraw2(xactmsg,c2,ei,b.left+(xbordersize div 2)+hpad,b.top+(xbordersize div 2));
      false:begin
         int1:=low__fonttextwidth2(ei,strcopy1(xactmsg,1,frcmin(xscrollref-6,0)));
         fdraw2(xactmsg,c2,ei,b.left-int1,b.top+(xbordersize div 2));
         if (xscrollref>=length(xactmsg)) then xscrollref:=0;//reset
         end;
      end;//case
      end;
   end;
   //## xdrawface ##
   procedure xdrawface;
      //## aalarm ##
      procedure aalarm;
      begin
      if (xactmsg<>'') then//hang point of alarm window
         begin
         xalarmy:=dy;
         if not (((not xdatetop) and xshowdate) or (xshowpod and xdatetop)) then inc(dy,eh);//make room
         end;
      end;
   begin
   if xremtop then prem;
   if xdaytop then pday;
   if not xdatetop then aalarm;
   if xdatetop then pdate else ppod;
   ptime;
   if xdatetop then aalarm;
   if xdatetop then ppod else pdate;
   if not xdaytop then pday;
   if not xremtop then prem;
   palarm;
   end;
begin
try
//defaults
result:=false;
a:=nil;
xfc:=nil;
//debug only: xactmsg:='aaaaaaaaAaaaaaaa';xflash:=sysflash;//xxxxxxxxxxxx
//xactmsg:='a1234567890_1234567890b_1234567890c';//xxxxxxxxxx
//xactmsg:='Go shopping tommorrow! (FRiday)';//xxxxxxxxxx

dPM:=false;
xfontname:=viFontname;
xwhite:=low__rgb(255,255,255);
xblack:=0;
hsep:=10;
xpad:=20;//edge
xoutminfontsize:=300;
xoutbackcolor:=xbackcolor;
xoutfontcolor:=xfontcolor;
xdraw:=false;
xmustquieten:=false;
//.dim
xdim:=100;//off
xautodim:=frcrange((10-xautodim)*10,10,100);//0(off) -> 9(10%) ==>> 100% -> 10% - 12mar2022
if xforcedim then xdim:=xautodim;
//range
if (xzoom<0.1) then xzoom:=0.1 else if (xzoom>20) then xzoom:=20;
d1:=xzoom;
if not xshowday then xzoom:=xzoom+(d1*0.2);
if not xshowpod then xzoom:=xzoom+(d1*0.1);
//if (not xshowdate) or (xactmsg<>'') then xzoom:=xzoom+(d1*0.2);
if not xshowdate then xzoom:=xzoom+(d1*0.2);
if not xshowrem then xzoom:=xzoom+(d1*0.1);

xmorningMIN:=60+frcrange(xmorningMIN,0,600);//1am - 11am (1 - 11)
xeveningMIN:=(13*60)+frcrange(xeveningMIN,0,600);//1pm - 11pm (13 - 23)
xdateformat:=frcrange(xdateformat,0,3);//09mar2022
xtimeformat:=frcrange(xtimeformat,0,2);//13mar2022
//check
if (not misok82432(s,sbits,sw,sh)) or ((sbits<>24) and (sbits<>32)) then exit;

//init
if xshowrem and xurem and (xremmsg<>'') then xremmsg:=low__uppercase(xremmsg);
low__decodedate2(x,y,m,d);
low__decodetime2(x,h,min,sec,ms);//h=0..23, min=0..59
xallmin:=(h*60)+min;
//.bell
low__teainfo(tepBell,false,xbellw,xbellh,xbellSOD,int1,int2,int3,bol1,bol2);

//.xday
xday:=low__dayofweekstr(x,xfday);//13mar2022
if xuday then xday:=low__uppercase(xday);

//.xzone
if (xallmin>=0) and (xallmin<xmorningmin) then
   begin
   xdes:=low__udv(xlabel_predawn,'Predawn');
   xdim:=xautodim;
   xmustquieten:=true;//for host
   end
else if (xallmin>=xmorningmin) and (xallmin<(12*60)) then xdes:=low__udv(xlabel_morning,'Morning')
else if (xallmin>=(12*60)) and (xallmin<xeveningmin) then xdes:=low__udv(xlabel_afternoon,'Afternoon')
else if (xallmin>=xeveningmin) and (xallmin<(24*60)) then
   begin
   xdes:=low__udv(xlabel_evening,'Evening');
   xdim:=xautodim;
   xmustquieten:=true;//for host
   end;
if xupod then xdes:=low__uppercase(xdes);

//.xtime
case xtimeformat of
0:begin
   xtime:=inttostr(h)+':'+low__digpad11(min,2);
   xtime2:=low__digpad11(h,2)+':'+low__digpad11(min,2);
   xampm:='';
   end;
else
   begin
   dPM:=(h>=12);
   case h of
   13..23:dec(h,12);
   24:h:=12;//never used - 28feb2022
   0:h:=12;//"0:00" -> "12:00am"
   end;
   xtime:=inttostr(h)+':'+low__digpad11(min,2);
   xtime2:=low__digpad11(h,2)+':'+low__digpad11(min,2);
   xampm:=#32+low__aorbstr('am','pm',dPM);
   if (xtimeformat=1) then xampm:=low__uppercase(xampm);
   end;
end;//case

//.xdate
xdate:=low__datestr(x,xdateformat,xfdate);
if xudate then xdate:=low__uppercase(xdate);

//.dim
xbrightness:=frcrange(xbrightness,10,100);
if (xdim<100) then xbrightness:=frcrange((xbrightness*frcrange(xdim,10,100)) div 100,5,100);//12mar2022
xoutbrightness:=xbrightness;

//.color
xoutfontcolor:=low__colsplice(xbrightness,low__colsplice(xbrightness,low__ecv(xfontcolor,xbackcolor,30),xbackcolor),0);
if (xoutfontcolor=0) then xoutfontcolor:=low__rgb(1,1,1);

//.backcolor
xoutbackcolor:=low__colsplice(xbrightness,xbackcolor,0);

//.finit
if xshowrem then finit(low__udv(xremmsg,'AWE'),10,false,ri,rw,rh,rhh);//larger font size of 10 required for stable operation of reminder message - 15mar2022
if xshowday then finit(xday,30,true,ai,aw,ah,ahh);
if xshowpod then finit(xdes,14,true,bi,bw,bh,bhh);
finit(xtime,50,true,ci,cw,ch,chh);
finit(xtime2,50,true,ci,cw2,ch,chh);//larger padding
finit(low__udv(xampm,'AWE'),25,true,pi,pw,ph,phh);
if xshowdate then finit(xdate,14,true,di,dw,dh,dhh);
finit(xactmsg,14,true,ei,ew,eh,ehh);//alarm

//.sw + sh
sw:=0;
if xshowday then sw:=largest(sw,aw);
if xshowpod then sw:=largest(sw,bw);
sw:=largest(sw,pw+cw);
sw:=largest(sw,pw+cw2);//larger time padding
if xshowdate then sw:=largest(sw,dw);
//was: sw:=largest(sw,ew);
inc(sw,xpad*2);

//.calc face height
dy:=xpad;
xdraw:=false;
xdrawface;
sh:=dy+1+xpad;


//detect changes - if none, then ignore - 27feb2022
//was: if not low__setstr(xref,inttostr(vifeather)+'|'+bnc(xshowrem)+bnc(xurem)+bnc(xdaytop)+bnc(xremtop)+bnc(xdatetop)+bnc(xhavebuzzer)+bnc(xhavemsg)+bnc(xhaveremmsg)+bnc(xactmsg<>'')+bnc(xremmsg<>'')+inttostr(xactbuzzer)+bnc(xflash)+bnc(xudate)+bnc(xfday)+bnc(xuday)+bnc(xupod)+bnc(xshowday)+bnc(xshowdate)+'|'+floattostr(xzoom)+'|'+inttostr(sw)+'|'+inttostr(sh)+'|'+inttostr(hsep)+'|'+inttostr(aw)+'x'+inttostr(ah)+'|'+inttostr(bw)+'x'+inttostr(bh)+'|'+inttostr(cw)+'x'+inttostr(ch)+'|'+inttostr(dw)+'x'+inttostr(dh)+'|'+inttostr(xbrightness)+'|'+inttostr(xusecolor)+'|'+inttostr(xoutbackcolor)+'|'+inttostr(xfontcolor)+'|'+inttostr(d)+'|'+inttostr(m)+'|'+inttostr(y)+'|'+inttostr(h)+'|'+inttostr(min)+'|'+xactmsg+#1+xremmsg) then goto skipend;
if not low__setstr(xref,inttostr(xoutminfontsize)+'|'+inttostr(xfeather)+'|'+bnc(xshowrem)+bnc(xurem)+bnc(xdaytop)+bnc(xremtop)+bnc(xdatetop)+bnc(xhavebuzzer)+bnc(xhavemsg)+bnc(xhaveremmsg)+bnc(xactmsg<>'')+bnc(xremmsg<>'')+inttostr(xactbuzzer)+bnc(xflash)+bnc(xudate)+bnc(xfday)+bnc(xuday)+bnc(xupod)+bnc(xshowday)+bnc(xshowdate)+'|'+floattostr(xzoom)+'|'+inttostr(sw)+'|'+inttostr(sh)+'|'+inttostr(hsep)+'|'+inttostr(aw)+'x'+inttostr(ah)+'|'+inttostr(bw)+'x'+inttostr(bh)+'|'+inttostr(cw)+'x'+inttostr(ch)+'|'+inttostr(dw)+'x'+inttostr(dh)+'|'+inttostr(xbrightness)+'|'+inttostr(d)+'|'+inttostr(m)+'|'+inttostr(y)+'|'+inttostr(h)+'|'+inttostr(min)+'|'+xactmsg+#1+xremmsg) then
   begin
   if (ms64>=xscrollref64) and ((ew>sw) or (rw>sw)) then
      begin
      //nil
      end
   else goto skipend;
   end;

//size + cls
if not missize(s,sw,sh) then goto skipend;
if not miscls(s,xblack) then goto skipend;//background is ALWAYS "0,0,0" for stable transparency

//.refs
if (ms64>=xscrollref64) then
   begin
   inc(xscrollref,3);
   inc(xscrollref2,3);
   xscrollref64:=ms64+1000;
   end;
if (xscrollref>1000)  then xscrollref:=0;//limit to safe max value - 06nov2022
if (xscrollref2>1000) then xscrollref2:=0;


//.draw face
a:=bnew;
dy:=xpad;
xdraw:=true;
xdrawface;

//enforce top left-pixel transparency
missetpixel32VAL(s,0,0,xblack);
//successful
result:=true;
skipend:
except;end;
try
xoutquieten:=xmustquieten;//return reply to host -> only sync the value ONCE we have the final value - 14mar2022
bfree(a);
bfree(xfc);
except;end;
end;
//## low__hhmm ##
function low__hhmm(h,m,xtimeformat:longint):string;
var
   dPM:boolean;
   str1:string;
begin
try
//.xtime
case xtimeformat of
0:begin
   result:=inttostr(h)+':'+low__digpad11(m,2);
   end;
else
   begin
   dPM:=(h>=12);
   case h of
   13..23:dec(h,12);
   24:h:=12;//never used - 28feb2022
   0:h:=12;//"0:00" -> "12:00am"
   end;
   str1:=low__aorbstr('am','pm',dPM);
   if (xtimeformat=1) then str1:=low__uppercase(str1);
   result:=inttostr(h)+':'+low__digpad11(m,2)+#32+str1;
   end;
end;//case
except;end;
end;
//## low__hhmm2 ##
function low__hhmm2(m,xtimeformat:longint):string;
var
   h:longint;
begin
try;h:=(m div 60);result:=low__hhmm(h,m-(h*60),xtimeformat);except;end;
end;

initialization
   siInit;

finalization
   siHalt;

end.

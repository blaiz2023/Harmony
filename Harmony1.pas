unit Harmony1;
//##############################################################################
//## Name......... basichost
//## Type......... Generic semi-managed program outline connector form
//## Desciption... Simple reusable interface between D3/MS to tbasicsystem handler which also prevents Win8/10 full screen form "stuff up" under D3 programs - 05oct2020
//## Version...... 1.00.032
//## Date......... 22sep2021, 07oct2020
//## Lines........ 66
//## Copyright.... (c) 1997-2020 Blaiz Enterprises
//##############################################################################

//xxxxxx Note: swap mid_vol/mid_setvol => mid_vol1 and mid_setvol1 (1 as in one layer volume)
//xxxxxx Note: swap out mm_vol/mm_setvol => mid_vol/mid_setvol (master/system volume)
//xxxxxx Note: swap "nvol()" with "nmidivol()"

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  clipbrd, Harmony2, gosscore;

type
  TForm1 = class(TForm)
   procedure FormCreate(Sender: TObject);
   procedure FormDestroy(Sender: TObject);
  private
   icore:tbasicprg1;//universial program object handler - 05oct2020
   fonaccept:tonacceptfilesevent;
   procedure wmerasebkgnd(var message:twmerasebkgnd); message wm_erasebkgnd;
   procedure wmmousewheel(var message:tmessage); message wm_mousewheel;
   procedure wmacceptfiles(var msg:tmessage); message wm_dropfiles;//drag&drop files - 24APR2011, 07DEC2009
   procedure wndproc(var message:tmessage); override;
  public
   property onaccept:tonacceptfilesevent read fonaccept write fonaccept;//18jun2021
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

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


initialization
   siInit;

finalization
   siHalt;

end.

program harmony;

{$mode delphi}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  main,
  gossdat,
  gossroot,
  gossgui,
  gossio,
  gossimg,
  gossgame,
  gosssnd,
  gossjpg,
  gosswin,
  gossnet,
  gosswin2,
  gosszip,
  gossfast,
  gossteps,
  gosstext;
  { you can add units after this }


//{$R *.RES}
//include multi-format icon - Delphi 3 can't compile an icon of 256x256 @ 32 bit -> resource error/out of memory error - 19nov2024
{$R harmony-256.res}

//include app version information
{$R ver.res}

begin
//(1)true=timer event driven and false=direct processing, (2)false=file handle caching disabled, (3)true=gui app mode
app__boot(true,false,not isconsole);
end.


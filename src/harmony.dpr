program Harmony;

uses
  main in 'main.pas',
  gossdat in 'gossdat.pas',
  gossroot in 'gossroot.pas',
  gossgui in 'gossgui.pas',
  gossio in 'gossio.pas',
  gossimg in 'gossimg.pas',
  gossgame in 'gossgame.pas',
  gosssnd in 'gosssnd.pas',
  gossjpg in 'gossjpg.pas',
  gosswin in 'gosswin.pas',
  gossnet in 'gossnet.pas',
  gosswin2 in 'gosswin2.pas',
  gosszip in 'gosszip.pas',
  gossfast in 'gossfast.pas',
  gossteps in 'gossteps.pas',
  gosstext in 'gosstext.pas';

//{$R *.RES}
//include multi-format icon - Delphi 3 can't compile an icon of 256x256 @ 32 bit -> resource error/out of memory error - 19nov2024
{$R harmony-256.res}

//include app version information
{$R ver.res}

begin
//(1)true=timer event driven and false=direct processing, (2)false=file handle caching disabled, (3)true=gui app mode
app__boot(true,false,not isconsole);
end.


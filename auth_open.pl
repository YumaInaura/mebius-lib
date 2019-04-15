
package main;

#-------------------------------------------------
# プロフィールファイルを開く（普通の閲覧）
#-------------------------------------------------
sub do_auth_open{

# 開くファイルの選別
my($open,$type,$lock) = @_;
my(undef,undef,undef,%renew) = @_ if($type =~ /Renew/);
my($prof_handler,%account);

# 汚染チェック
$open =~ s/[^0-9a-z]//g;

# 引数がない場合
if($open eq ""){ &error("このアカウント $open は存在しません。"); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($open);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ＩＤファイルを開く
open($prof_handler,"${account_directory}$open.cgi") || &error("このアカウント $open は存在しません。");
chomp(my $pptop1 = <$prof_handler>);
chomp(my $pptop2 = <$prof_handler>);
chomp(my $pptop3 = <$prof_handler>);
chomp(my $pptop4 = <$prof_handler>);
chomp(my $pptop5 = <$prof_handler>);
chomp(my $pptop6 = <$prof_handler>);

# データを分解
($ppkey,$ppaccount,$pppass,$ppsalt,$ppfirsttime,$ppblocktime,$pplasttime,$ppadlasttime) = split (/<>/,$pptop1);
($ppname,$ppmtrip,$ppcolor1,$ppcolor2,$ppprof,$ppedittime) = split (/<>/,$pptop2);
($ppocomment,$ppodiary,$ppobbs,$pposdiary,$pposbbs,$pporireki) = split (/<>/,$pptop3);
($ppencid,$ppenctrip) = split (/<>/,$pptop4);
($pplevel,$pplevel2,$ppsurl,$ppadmin,$ppchat,$ppreason) = split (/<>/,$pptop5);
($ppemail,$ppmlpass) = split (/<>/,$pptop6);
close($prof_handler);

# アカウントロックの解除日
if($ppkey eq "2" && $ppblocktime && $time > $ppblocktime){ $ppkey = 1; }

# キーチェック
if($type !~ /nocheck/){
	if($ppkey eq "0"){
		if($myadmin_flag){ $error_text = qq(このアカウントは削除済みです。); }
		else{ &error("このアカウントは削除済みです。","410 Gone"); }
	}
		if($ppkey eq "2"){
		if($lock && !$myadmin_flag){ &error("このアカウントはロック中です。"); }
	}
}

# マイプロフの場合
if($pmfile eq $open){ $myprof_flag = 1; }

# 筆名、プロフない場合
if($ppname eq ""){ $herbirdflag = 1; $ppname = "名無し"; }

# メルアド配信設定の場合
if($ppemail ne "" && $ppmlpass ne ""){ $sendmail_flag = 1; }

$ppfile = $open;

return(%account);


}




1;

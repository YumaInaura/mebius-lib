#-------------------------------------------------
# 編集を実行 - マイアカウント
#-------------------------------------------------
sub auth_baseedit{

# 局所化
my($line,$bkline,$max_bkup,$bki);

# 管理者のみ
if($myadmin_flag < 5){ &error("不明な処理です。") }

# アクセス制限
&axscheck("");

# 汚染チェック
$file = $in{'account'};
$file =~ s/[^0-9a-z]//;
if($file eq ""){ &error("値を設定してください。"); }

# ディレクトリ作成
&Mebius::Mkdir("","${int_dir}_id/$file",$dirpms);

# タイトルなど定義
$head_link3 = "&gt; 特殊編集";

# アカウントファイルを開く
if($server_domain eq $auth_domain || -e "${int_dir}_id/$file/$file.cgi"){ &open($file); }

# ロック開始
&lock("auth$file") if($lockkey);

# アカウント名，パスが一致しない場合エラー
if(!$idcheck){ &error("編集するにはログインしてください。"); }

# アカウントロック（削除）の場合、新規アカウント作成をブロック
if($in{'ppkey'} eq "0" || $in{'ppkey'} eq "2"){ &block_anewmake($file); }

# アカウント停止の場合、コメント設定を変更
if($in{'ppkey'} eq "0" || $in{'ppkey'} eq "2"){
$ppobbs = "0";
$ppodiary = "0";
$ppocomment = "0";
}


# 変更内容の定義

if($in{'ppkey'} ne ""){
$ppkey = $in{'ppkey'};
$ppkey =~ s/\D//g;
}

if($in{'pplevel'} ne ""){
$pplevel = $in{'pplevel'};
$pplevel =~ s/\D//g;
}

if($in{'pplevel2'} ne ""){
$pplevel2 = $in{'pplevel2'};
$pplevel2 =~ s/\D//g;
}

if($in{'ppadmin'} ne ""){
$ppadmin = $in{'ppadmin'};
$ppadmin =~ s/\D//g;
}


if($in{'ppsurl'} ne ""){
$ppsurl = $in{'ppsurl'};
}

if($in{'ppchat'} ne ""){
$ppchat = $in{'ppchat'};
$ppchat =~ s/\D//g;
}

if($in{'ppblocktime'} ne ""){
$ppblocktime = $in{'ppblocktime'};
$ppblocktime =~ s/\D//g;
}
if($in{'ppblocktime'} eq "none"){ $ppblock_time = ""; }

$ppreason = $in{'ppreason'};
$ppreason =~ s/\D//g;

$ppadlasttime = $time;

# 編集実行
require "${int_dir}auth_seditprof.pl";
&seditprof($file);


# ロック解除
&unlock("auth$file") if($lockkey);

	# リダイレクト(１回目)
	if($mebi_mode && !$in{'moved'} && !$alocal_mode){
		if($alocal_mode){ &Mebius::Redirect("","http://localhost/_auth/?$postbuf&moved=1\n\n"); }
		else{ &Mebius::Redirect("","http://aurasoul.mb2.jp/_auth/?$postbuf&moved=1"); }
		exit;
	}

	# リダイレクト(２回目)
	else{
		my $redirect_url = "${auth_url}${file}/#BASEEDIT";
		if($in{'backurl'}){ $redirect_url = $backurl; }
		&Mebius::Redirect("",$redirect_url);
	}

# 編集後、ページジャンプ
$jump_sec = $auth_jump;
$jump_url = qq(${auth_url}${file}/#BASEEDIT);
if($aurl_mode){ $jump_url = "$script?account=$file#BASEEDIT"; }

# ヘッダ
&header();

# HTML
print <<"EOM";
<div class="body1">
編集しました。
<a href="$jump_url">アカウント</a>へ移動します。<br>
</div>
EOM

# フッタ
&footer;

# 処理終了
exit;

}

#-----------------------------------------------------------
# 新規アカウント作成をブロック
#-----------------------------------------------------------
sub block_anewmake{

my($file) = @_;

# ログイン履歴を開く
open(RLOGIN_IN,"${int_dir}_id/$file/${file}_rlogin.cgi");
while(<RLOGIN_IN>){
chomp;
my($lasttime,$xip_enc2,$host2,$number,$id) = split(/<>/);
if($number ne ""){ &block_cnumber($number); }
if($xip_enc2 ne ""){ &block_xip($xip_enc2); }
}
close(RLOGIN_IN);


# クッキーブロック ---------------------
sub block_cnumber{
my($file) = @_;
my $line = qq(9999999999999999<>\n);
open(CFILE_OUT,">${ip_dir}_ip_cidmake/$file.cgi");
print CFILE_OUT $line;
close(CFILE_OUT);
chmod($logpms,"${ip_dir}_ip_cidmake/$file.cgi");
}

# ＸＩＰブロック ---------------------
sub block_xip{
my($file) = @_;
my $line = qq(9999999999999999<>\n);
open(XIP_OUT,">${ip_dir}_ip_idmake/$file.cgi");
print XIP_OUT $line;
close(XIP_OUT);
chmod($logpms,"${ip_dir}_ip_idmake/$file.cgi");
}

}


1;


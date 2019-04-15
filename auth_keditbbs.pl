
package main;

#-----------------------------------------------------------
# SNS BBSの記事を操作
#-----------------------------------------------------------
sub auth_keditbbs{

# 局所化
my($file,$open,$line,$indexline,$pastline,$flag,$top1,$yearfile,$monthfile,$newkey);

# 変更するキー値を定義
# ロックする場合
if($in{'decide'} eq "lock"){ $newkey = "0"; }
# 削除する場合
elsif($in{'decide'} eq "delete"){
if($myadmin_flag){ $newkey = "4"; } else { $newkey = "2"; }
}
elsif($in{'decide'} eq "revive"){ $newkey = "1"; }
else{ &error("値を正しく指定してください。"); }

# 汚染チェック１
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("値を正しく指定してください。"); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# 汚染チェック１
$open = $in{'num'};
$open =~ s/\D//g;
if($open eq ""){ &error("値を正しく指定してください。"); }

# ログインしていない場合
if(!$idcheck){ &error("記事を削除するには、ログインしてください。"); }

# 本人でも管理者でもない場合
if(!$myadmin_flag && $file ne $pmfile){ &error("記事は本人しか削除できません。"); }

# プロフィールを開く
&open($file);

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);

# ファイル定義
my $bbs_thread_file = "${account_directory}bbs/${file}_bbs_${open}.cgi";
my $bbs_index_file = "${account_directory}bbs/${file}_bbs_index.cgi";

# プレビューの場合
if($in{'preview'} eq "on"){ &auth_keditbbs_preview("",$file,$open); }

# ロック開始
&lock("auth$file") if $lockkey;

# 記事単体ファイルを開く
open(BBS_IN,"<",$bbs_thread_file) || &error("記事が開けません。");
my $top1 = <BBS_IN>;
chomp $top1;
my($key,$num,$sub,$res,$dates,$newtime,$restime,$resaccount,$resname) = split(/<>/,$top1);
my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);
$keytop1 = $key;
$key = $newkey;

$line .= qq($key<>$num<>$sub<>$res<>$dates<>$newtime<>$restime<>$resaccount<>$resname<>\n);
while(<BBS_IN>){ $line .= $_; }
close(BBS_IN);

# キーにより処理変更
if( ($keytop1 eq "4" || $keytop1 eq "2") && !$myadmin_flag){ &error("実行できませんでした。"); }

# 記事単体ファイルを書き出し
Mebius::Fileout(undef,$bbs_thread_file,$line);

# 現行インデックスを開く
open(BBS_INDEX_IN,"<",$bbs_index_file);
my $nowtop1 = <BBS_INDEX_IN>;
$indexline .= $nowtop1;
while(<BBS_INDEX_IN>){
chomp $_;
my($key,$num,$sub,$res,$dates,$newtime,$restime,$resaccount,$resname) = split(/<>/,$_);
if($open eq $num){
$key = $newkey;
$indexline .= qq($key<>$num<>$sub<>$res<>$dates<>$newtime<>$restime<>$resaccount<>$resname<>\n);
my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);
}
else{ $indexline .= qq($_\n); }
}
close(BBS_INDEX_IN);

# 現行インデックスを書き出し
Mebius::Fileout(undef,$bbs_index_file,$index_line)

# 管理者削除の場合、ペナルティを生成
if($myadmin_flag && !$myprof_flag && $in{'decide'} eq "delete"){ &auth_keditbbs_makewait("",$file); }

# ロック解除
&unlock("auth$file") if $lockkey;

# ジャンプ先定義
$jump_sec = $auth_jump;
$jump_url = "${file}/#BBS";
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }


# HTML
my $print = <<"EOM";
実行しました。<a href="$jump_url">BBSエリア</a>に移動します。
EOM

Mebius::Template::gzip_and_print_all({},$print);

# 終了
exit;

}

#-----------------------------------------------------------
# ペナルティを作る
#-----------------------------------------------------------
sub auth_keditbbs_makewait{

my($type,$file) = @_;

my $waitsec_bbs = 60*60*24*3;
my $waitline = qq($time<>$waitsec_bbs<>\n);

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

Mebius::Fileout(undef,"${account_directory}${file}_time_postbbs.cgi",$waitline);

}


#-----------------------------------------------------------
# 削除前のプレビュー画面
#-----------------------------------------------------------

sub auth_keditbbs_preview{

# 宣言
my($type,$file,$open) = @_;

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# 記事単体ファイルを開く
open(BBS_IN,"<","${account_directory}bbs/${file}_bbs_${open}.cgi") || &error("記事が開けません。");
my $top1 = <BBS_IN>;
my($key,$num,$sub,$res,$dates,$newtime,$restime) = split(/<>/,$top1);
close(BBS_IN);

# URL変換
my $link = qq($file/b-$open);
if($aurl_mode){ ($link) = &aurl($link); }

# HTML
my $print = <<"EOM";
$footer_link
<h1>記事の削除</h1>
<h2>実行</h2>
記事（<a href="$link">$sub</a>）を削除しますが、よろしいですか？<br>
一度削除すると、この記事内の全投稿が表\示できなくなります。<br><br>
<a href="$script?mode=keditbbs&amp;account=$file&amp;num=$open&amp;decide=delete">→削除を実行する</a>（復活不可）
<br><br><hr>
$footer_link
EOM

Mebius::Template::gzip_and_print_all({},$print);

# 終了
exit;

}




1;

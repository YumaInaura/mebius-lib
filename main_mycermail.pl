
use Mebius::Auth;
package main;

#-----------------------------------------------------------
# メール認証
#-----------------------------------------------------------

# タイトル定義
sub main_mycermail{
$sub_title = "メール認証";
$head_link3 = " &gt; メール認証";

# スクリプト名
if($alocal_mode){ $script = "main.cgi"; }

# 送信先定義
if($alocal_mode){ $action = "$script"; } else { $action = "./"; }
# モード振り分け
if($in{'deny'}){ &deny_cermail(); }
else{ &from_email(); }
}


#-----------------------------------------------------------
# メール認証（メールからリンクをたどった場合）
#-----------------------------------------------------------

sub from_email{

# 局所化
my($flag,$file,$line);

# ファイル定義
$file = $in{'email'};
$file =~ s/(\W)/'%' . unpack('H2' , $1)/eg;
$file =~ tr/ /+/;

# 既に認証済みの場合
#if(-e "${int_dir}_2sendmail/$file/main.cgi"){ &error("このメールアドレスは既に認証済みです。"); }

# メルアド認証前のファイルを開く
open(CERMAIL_IN,"${int_dir}_2cermail/$file.cgi")||&error("ファイルが存在しません。既に認証済みの可能\性があります。");
my $top1 = <CERMAIL_IN>; chomp $top;
my($key,$pass,$lasttime,$host2,$addr2,$cnumber2,$pmfile2) = split(/<>/,$top1);
close(CERMAIL_IN);

# 認証できた場合、フラグを立てる
if($pass ne $in{'pass'}){ &error("認証できませんでした"); }

# 書き出す行
$line = qq(1<>$pass<><><>$time<>$host<>$addr<>$cnumber<>$pmfile<>\n);

# メルアド認証ファイルを書き出す
&Mebius::Mkdir("","${int_dir}_2sendmail/$file",$dirpms);
open(SENDMAIL_OUT,">${int_dir}_2sendmail/$file/main.cgi");
print SENDMAIL_OUT $line;
close(SENDMAIL_OUT);
chmod($logpms,"${int_dir}_2sendmail/$file/main.cgi");

# 元の認証ファイルを削除
unlink("${int_dir}_2cermail/$file.cgi");

# ページジャンプ
$jump_sec = 10;
$jump_url = "/_main/?mode=my";

	# SNS認証の場合、アカウントファイルを更新
	if($key eq "2"){
		my(%renew);
		$renew{'email'} = $in{'email'};
		$renew{'mlpass'} = $pass;
		&Mebius::Auth::File("Renew",$pmfile2,%renew);
		$jump_url = "$auth_url$pmfile2/";
	}

# ヘッダ
&header;

# HTML
print qq(
<div class="body1">
メール認証に成功しました。<a href="$jump_url">→移動する</a>
</div>
);

# フッタ
&footer;

exit;

}

#-----------------------------------------------------------
# イタズラ制限 表示画面
#-----------------------------------------------------------
sub deny_cermail{

# 局所化
my($line,$file,$email);

# ファイル定義
$file = $in{'email'};
$file =~ s/(\W)/'%' . unpack('H2' , $1)/eg;
$file =~ tr/ /+/;

# メールアドレスのデコード
$email = $file;
$email =~ tr/+/ /;
$email =~ s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2', $1)/eg;

# アドレスファイルを開く
open(CERMAIL_IN,"${int_dir}_2cermail/$file.cgi") || &error("ファイルが存在しません");
$top1 = <CERMAIL_IN>;
my($key,$pass,$lasttime,$xip_enc2,$number) = split(/<>/,$top1);
close(CERMAIL_IN);

# 認証できた場合、フラグを立てる
if($pass ne $in{'pass'}){ &error("認証できませんでした"); }

# 制限の実行
if($in{'action'}){ &deny_cermail_action($file); }

# ヘッダ
&header();

# HTML
print qq(
<div class="body1">
イタズラや手違いで認証メールが送られた場合、<br>
このメールアドレスへの送信を禁止することが出来ます。<br>
また、送信者のアクションを禁止することも出来ます。<br><br>

（ <a href="http://$server_domain/">$server_domain</a> のドメインのみ ）。

<form action="$action" method="post">
<div>
<input type="hidden" name="pass" value="$pass">
<input type="hidden" name="email" value="$email">
<input type="hidden" name="mode" value="my">
<input type="hidden" name="type" value="cermail">
<input type="hidden" name="deny" value="1">
<input type="hidden" name="action" value="1">
<input type="checkbox" name="deny_address" value="1" id="deny_address" $main::checked> <label for="deny_address">このメールアドレスを禁止する</label>
<input type="checkbox" name="deny_sender" value="1" id="deny_sender" $main::checked> <label for="deny_sender">この送信者を禁止する</label>
<input type="submit" value="この内容で送信する">

</div>
</form>

</div>
);

# フッタ
&footer();

exit;

}

#-----------------------------------------------------------
# イタズラ制限の実行
#-----------------------------------------------------------
sub deny_cermail_action{

# GET送信を禁止
if(!$postflag){ &error("不正なアクセスです。"); }

# 局所化
my($denyline1,$denyline2,$oktime);

# 禁止する時間
$oktime = $time+60*60*24*365;

# ファイル定義
my($file) = @_;

# アドレスファイルを開く
open(CERMAIL_IN,"${int_dir}_2cermail/$file.cgi")||&error("ファイルが存在しません");
$top1 = <CERMAIL_IN>;
my($key,$pass,$lasttime,$xip_enc2,$number) = split(/<>/,$top1);
close(CERMAIL_IN);

# メールアドレス禁止ファイルを書き込み
if($in{'deny_address'}){
my $line_denyaddress = qq($time<>\n);
open(DENYMAIL_OUT,">${ip_dir}_ip_denycermail_address/$file.cgi");
print DENYMAIL_OUT $line_denyaddress;
close(DENYMAIL_OUT);
chmod($logpms,"${ip_dir}_ip_denycermail_address/$file.cgi");
}

# 送信者の禁止ファイルを書き込み - XIP
if($in{'deny_sender'}){
$denyline1 = qq($oktime<>\n);
open(DENY1_OUT,">${ip_dir}_ip_denycermail_xip/$xip_enc2.cgi");
print DENY1_OUT $denyline1;
close(DENY1_OUT);
chmod($logpms,"${ip_dir}_ip_denycermail_xip/$xip_enc2.cgi");
}


# 禁止ファイルを書き込み - CNUMBER
if($in{'deny_sender'}){
$denyline2 = qq($oktime<>\n);
open(DENY2_OUT,">${ip_dir}_ip_denycermail_cnumber/$number.cgi");
print DENY2_OUT $denyline2;
close(DENY2_OUT);
chmod($logpms,"${ip_dir}_ip_denycermail_cnumber/$number.cgi");
}

# ヘッダ
&header;

# HTML
print qq(
<div class="body1">
正常に禁止設定が完了しました。<br>
迷惑行為が続く場合は、お手数ですが<a href="http://aurasoul.mb2.jp/etc/mail.html">メールフォーム</a>でご連絡ください（メビウスリング管理者に繋がります）。
</div>
);

# フッタ
&footer;

exit;

}


1;


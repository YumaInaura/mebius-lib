#-----------------------------------------------------------
# 確認メールの配信
#-----------------------------------------------------------

sub send_cermail{

# 宣言
my($type,$input_email) = @_;
my($file) = @_;
my($line,$top1,$random,$subject,$body,$file_deny2,$top_deny1,$top_deny2);

my $max_submitlog = 50;

# 投稿制限
require "${int_dir}part_axscheck.pl";
if($emd){ $e_access =~ s/<br>//g; $e_access =~ s/　//g; &error("$e_access"); }

# 認証済みの場合、リターン
if($in{'certype'} eq "sns"){
if($pmmlpass) { return; }
}
else{
if($cmon_flag) { return; }
}

# メールアドレスの書式判定
if($input_email =~ /[^0-9a-zA-Z_\-\.\@]/) { &error("メールアドレスに使えない文字が含まれています。"); }
if($input_email && $input_email !~ /^[\w\.\-]+\@[\w\.\-]+\.[a-zA-Z]{2,6}$/) { &error("メールアドレスの書式が間違っています。"); }

# ファイル定義
$file = $input_email;
$file =~ s/(\W)/'%' . unpack('H2' , $1)/eg;
$file =~ tr/ /+/;
if($file eq ""){ &error("メールアドレスが空(カラ)です。"); }

# 連続送信を禁止
open(SUBMITLOG_IN,"${int_dir}_cermail/submitlog.cgi");
my($i_submitlog);
while(<SUBMITLOG_IN>){
$i_submitlog++;
my($mail,$submit_xip,$oktime) = split(/<>/);
if( ($input_email eq $mail || $submit_xip eq $xip_enc) && $time < $oktime && !$alocal_mode){ $return = qq(短時間での連続申\請はできません。しばらく後で送信してください。); }
if($i_submitlog < $max_submitlog){ $line_submitlog .= $_; }
}
close(SUBMITLOG_IN);

# 迷惑情報がある場合、ブロック
open(DENY1_IN,"${ip_dir}_ip_denycermail_xip/${xip_enc}.cgi");
$top_deny1 = <DENY1_IN>;
my($oktime1) = split(/<>/,$top_deny1);
if($oktime1 && $time < $oktime1 && !$alocal_mode){ $return = qq(迷惑行為の報告により、認証メールを送れませんでした。); }
close(DENY1_IN);

# 汚染チェック
$file_deny2 = $cnumber;
$file_deny2 =~ s/\W//g;

# 迷惑情報がある場合、ブロック
open(DENY2_IN,"${ip_dir}_ip_denycermail_cnumber/$file_deny2.cgi");
$top_deny2 = <DENY2_IN>;
my($oktime2) = split(/<>/,$top_deny2);
if($oktime2 && $time < $oktime2 && !$alocal_mode){ $return = qq(迷惑行為の報告により、認証メールを送れませんでした。); }
close(DENY2_IN);

# メールアドレスが禁止されている場合、ブロック
open(DENYMAIL_IN,"${ip_dir}_ip_denycermail_address/$file.cgi");
my $top_denyaddress = <DENYMAIL_IN>;
my($btime_denyaddress) = split(/<>/,$top_denyaddress);
close(DENYMAIL_IN);
if($btime_denyaddress){ $return = qq(このメールアドレスは禁止されています。); }

# エラーでリターンする場合
if($return){ return; }

# ロック開始
&lock("cermail") if($lockkey);

# アドレスファイルを開く
open(CERMAIL_IN,"${int_dir}_2cermail/$file.cgi");
$top1 = <CERMAIL_IN>;
my($key,$pass,$lasttime) = split(/<>/,$top1);
close(CERMAIL_IN);

# エラーをだす場合
#if($lasttime > $time - 1*60*60 && !$alocal_mode){ $return = qq(このメールアドレスは申\請済みです、メールボックスを確認してください。再送信する場合は、1時間ほど時間を空けてください。); }

# ランダムな文字列
@charpass = ('a'..'z', 'A'..'Z', '0'..'9');
for(0..10){
$putpass .= $charpass[int(rand(@charpass))]; 
}

# 認証ファイルのキー定義
my($putkey);
if($in{'certype'} eq "sns"){ $putkey = "2"; } else{ $putkey = 1; }

# 書き出す行
$line = qq($putkey<>$putpass<>$time<>$host<>$xip_enc<>$cnumber<>$pmfile<>\n);

# アドレスファイルを書き出す
open(CERMAIL_OUT,">${int_dir}_2cermail/$file.cgi");
print CERMAIL_OUT $line;
close(CERMAIL_OUT);
chmod($logpms,"${int_dir}_2cermail/$file.cgi")

# ロック解除
&unlock("cermail") if($lockkey);

# ＩＤ付与
&id;

# 連続送信禁止ファイルを書き込み
my $nexttime_submitlog = $time + 60*5;
$line_submitlog = qq($input_email<>$xip_enc<>$nexttime_submitlog<>\n) . $line_submitlog;
open(SUBMITLOG_OUT,">${int_dir}_cermail/submitlog.cgi");
print SUBMITLOG_OUT $line_submitlog;
close(SUBMITLOG_OUT);
chmod($logpms,"${int_dir}_cermail/submitlog.cgi");

# メール件名
$subject = qq(メールアドレス認証 -メビウスリング);
# メール本文
$body = qq(メビウスリングでのメール認証をおこないます。
メールアドレスは非公開で、お知らせ配信以外には使われません。

次のＵＲＬにアクセスすると、認証が完了します。
http://$server_domain/_main/?mode=my&type=cermail&pass=$putpass&email=$file$kmailtag

このメールに覚えがない場合は、お手数ですがメールを削除お願いします。
次のＵＲＬから送信を禁止することも出来ます。
http://$server_domain/_main/?mode=my&type=cermail&deny=1&pass=$putpass&email=$file$kmailtag

送信者情報
筆名: $chandle
ID: $encid
ホスト名: $host
接続元: $xip);

# ローカル
if($alocal_mode){
$after_text1 = qq(
<a href="/_main/?mode=my&amp;type=cermail&amp;pass=$putpass&amp;email=$file$kmailtag">認証</a>
<a href="/_main/?mode=my&amp;type=cermail&amp;pass=$putpass&amp;deny=1&amp;email=$file$kmailtag">制限</a>
);
}

# メール送信
&Mebius::Email(undef,$input_email,$subject,$body);

# フラグを立てる
$sendcermail_flag = 1;

}

1;

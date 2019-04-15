
package main;

#-----------------------------------------------------------
# モード振り分け
#-----------------------------------------------------------
sub bbs_scmail{
if($in{'action'}){ &bbs_scmail_action(); }
else{ &bbs_scmail_form(); }
}

#-----------------------------------------------------------
# 送信用フォーム
#-----------------------------------------------------------
sub bbs_scmail_form{

# 局所化
my($line,$flag,$i);

# モードエラー
if(!$secret_mode){ &error("ページがありません。"); }

# CSS定義
$css_text .= qq(
textarea{width:80%;height:200px;}
input.text{width:12em;}
form{margin:1em 0em;}
);

# タイトル定義
$sub_title = qq( $scad_name にメール );
$head_link3 = qq( &gt; $scad_name にメール );

# HTML
my $print = qq(
<h1>管理者 ( $scad_name ) 宛てのメールフォーム</h1>
<span class="alert">※「ユーザー名」も一緒に送信されます。</span>

<form action="$script" method="post"$sikibetu>
<div>
<input type="hidden" name="mode" value="scmail">
<input type="hidden" name="moto" value="$realmoto">
筆名 <input type="text" name="name" value="$scmy_handle" class="text" disabled>
メールアドレス <input type="text" name="email" value="$scmy_email" class="text"><br>
本文
<textarea name="comment" class="comment"></textarea>
<br><br>
<input type="submit" name="action" value="この内容で送信する">
</div>
</form>
);

Mebius::Template::gzip_and_print_all({},$print);

# 終了
exit;
}
#-----------------------------------------------------------
# メールを送信
#-----------------------------------------------------------
sub bbs_scmail_action{

# 局所化
my($basic_init) = Mebius::basic_init();
my($mailto,$subject,$body,$address,$comment);

# アクセス制限
&axscheck;

# GET送信を禁止
if(!$postflag){ &error("GET送信は出来ません。"); }

# 本文をフック
$fook_error = qq(本文： $in{'comment'});

# 各種チェック
if(length($in{'comment'}) > 5000*2 || length($in{'comment'}) < 10*2){ &error("全角10文字以上、5000文字以内で送信してください。"); }
if($scad_email eq ""){ &error("管理者がメールアドレスを設定していません。<a href=\"mailto:$basic_init->{'admin_email'}\">$basic_init->{'admin_email'}</a> までご連絡ください。"); }

# 宛先
$mailto = $scad_email;

# E-Mail書式チェック
$address = $in{'email'};
$address =~ s/( |　)//g;
if($address eq "") { &error("メールアドレスを入力してください。"); }
if(length($address) > 256) { &error("メールアドレスが長すぎます。"); }
if($address =~ /[^0-9a-zA-Z_\-\.\@]/) { &error("メールアドレスの書式が間違っています。"); }
if($address && $address !~ /^[\w\.\-]+\@[\w\.\-]+\.[a-zA-Z]{2,6}$/) { &error("メールアドレスの書式が間違っています。"); }

# メール題名
$subject = qq(会員制メールフォームより - $scmy_handle);

# メール本文を整形
$comment = $in{'comment'};
$comment =~ s/<br>/\n/g;

# メール本文
$body = qq(
$comment

──────────────────────────────

筆名： $scmy_handle
ユーザー名： $username
メールアドレス（入力）： $address
メールアドレス（登録）： $scmy_email
管理番号： $cnumber
アカウント： ${main::auth_url}$pmfile/
ＵＡ： $age
ＵＲＬ： http://aurasoul.mb2.jp/jak/$moto.cgi

──────────────────────────────);

# メールを送信
Mebius::send_email(undef,$mailto,$subject,$body);

# ジャンプ
$jump_url = $script;
$jump_sec = 2;


# HTML
my $print = qq(正常に送信されました。( <a href="$jump_url">→戻る</a> ));

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


1;

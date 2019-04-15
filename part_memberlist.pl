
package main;
use Mebius::Export;

#-----------------------------------------------------------
# モード振り分け
#-----------------------------------------------------------

sub bbs_memberlist{
if($in{'type'} eq "vedit"){ &bbs_memberlist_vedit; }
elsif($in{'type'} eq "edit"){ &bbs_memberlist_edit; }
elsif($in{'type'} eq ""){ &bbs_memberlist_view; }
else{ &error("ページが存在しません。"); }
}

#-----------------------------------------------------------
# 編集フォーム
#-----------------------------------------------------------
sub bbs_memberlist_vedit{

# 局所化
my($file,$line);

# モードによるエラー
if(!$secret_mode){ &error("ページが存在しません。"); }

# CSS定義
$css_text .= qq(
.blue{color:#00f;}
table,th,tr,td{border-style:none;}
th,td{padding:0.4em;}
input.text{width:12em;}
);

# タイトル定義
$sub_title = qq(メンバー設定);
$head_link3 = qq(&gt; <a href="member.html">メンバーリスト</a>);
$head_link4 = qq(&gt; メンバー設定);


# フォームを取得
my($form) = &bbs_memberlist_getform;

# HTML
my $print = qq(
<h1>メンバー設定 - $scmy_handle</h1>
$form
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# フォームを取得
#-----------------------------------------------------------
sub bbs_memberlist_getform{

my($line);

$line .= qq(
<form action="$script" method="post"$sikibetu>
<div>
<input type="hidden" name="mode" value="member">
<input type="hidden" name="moto" value="$realmoto">
<input type="hidden" name="type" value="edit">
<table>
);

#$line .= qq(<tr><td>筆名</td><td><input type="text" name="handle" value="$scmy_handle" class="text"></td><td></td></tr>);
$line .= qq(<tr><td>メールアドレス</td><td><input type="text" name="email" value="$scmy_email" class="text">$address</td><td></td></tr>);

if($allowaddress_mode){
my $checked0 = " checked" if(!$scmy_emailkey);
my $checked1 = " checked" if($scmy_emailkey eq "1");
$line .= qq(
<tr><td>アドレス公開</td><td>
<input type="radio" name="emailkey" value="1"$checked1> 公開
<input type="radio" name="emailkey" value=""$checked0> 非公開
</td>
<td><span class="guide"> 「公開」を選ぶと<a href="member.html">メンバーリスト</a>にあなたのメールアドレスが表\示されます</span></td>
</tr>
);
}


# レスお知らせメール
if($allowaddress_mode){
my $checked0 = " checked" if(!$scmy_sendmail);
my $checked1 = " checked" if($scmy_sendmail eq "1");
my $checked2 = " checked" if($scmy_sendmail eq "2");
$line .= qq(
<tr><td>レスお知らせ</td><td>
<input type="radio" name="sendmail" value="1"$checked1> 受け取る(ＰＣ版)
<input type="radio" name="sendmail" value="2"$checked2> 受け取る(携帯版)
<input type="radio" name="sendmail" value=""$checked0> 受け取らない
<td><span class="guide"> 「受け取る」を選ぶと、どの記事にレスがあった場合でも、お知らせメールが届きます</span></td>
</td></tr>
);
}


$line .= qq(
</table>
<br><br>
<input type="submit" value="この内容で設定変更する">
</div>
</form>
);



$line;

}

#-----------------------------------------------------------
# 編集実行
#-----------------------------------------------------------
sub bbs_memberlist_edit{

# 局所化
my($line,$newemail_flag,$flag,$line_address);

# 各種エラー
if(!$postflag){ &error("GET送信は出来ません。"); }
$in{'emailkey'} =~ s/\D//g;
if($in{'emailkey'} > 1){ &error("設定値が変です。"); }
$in{'sendmail'} =~ s/\D//g;
if($in{'sendmail'} > 2){ &error("設定値が変です。"); }
require "${int_dir}regist_allcheck.pl";
($in{'email'}) = &address_check($in{'email'});

&error_view;

# ロック開始
&lock("MEMBER") if($lockkey);

# メンバーファイルを開く
open(MEMBER_IN,"${int_dir}_invite/member_${secret_mode}.cgi");
while(<MEMBER_IN>){
chomp;
my($key,$user,$pass,$handle,$file2,$lasttime,$email,$submittime,$emailkey,$sendmail) = split(/<>/);
if($user eq $username){
$flag = 1;
if($email ne $in{'email'}){ $newemail_flag = 1; }
if(!$submittime){ $submittime = $time; }
($email,$emailkey,$sendmail) = ($in{'email'},$in{'emailkey'},$in{'sendmail'});
}
$line .= qq($key<>$user<>$pass<>$handle<>$file2<>$lasttime<>$email<>$submittime<>$emailkey<>$sendmail<>\n);
}
close(MEMBER_IN);

# エラー
if(!$flag){ &error("ユーザー登録がありません。"); }

# 会員ファイルを書き込む
open(MEMBER_OUT,">${int_dir}_invite/member_${secret_mode}.cgi");
print MEMBER_OUT $line;
close(MEMBER_OUT);
Mebius::Chmod(undef,"${int_dir}_invite/member_${secret_mode}.cgi");

# メールアドレス記録ファイルを開く
if($newemail_flag){
$line_address .= qq($username<>$in{'email'}<>$in{'handle'}<>\n);
open(ADDRESS_IN,"${int_dir}_invite/address_$adfile.cgi");
while(<ADDRESS_IN>){
chomp;
my($user,$address,$handle) = split(/<>/,$_);
if($user ne $username || $address ne $in{'email'}){ $line_address .= qq($user<>$address<>$handle<>\n); }
}
close(ADDRESS_IN);
}

# メールアドレス記録ファイルを更新
if($newemail_flag){
open(ADDRESS_OUT,">${int_dir}_invite/address_$adfile.cgi");
print ADDRESS_OUT $line_address;
close(ADDRESS_OUT);
Mebius::Chmod(undef,"${int_dir}_invite/address_$adfile.cgi");
}

# ロック解除
&unlock("MEMBER") if($lockkey);

# リダイレクト
if($alocal_mode){ Mebius::Redirect("","$script?mode=member"); }
else{ Mebius::Redirect("","member.html"); }

}

#-----------------------------------------------------------
# 現在のメンバーを表示
#-----------------------------------------------------------
sub bbs_memberlist_view{

# 局所化
my($file,$line);

# モードによるエラー
if(!$secret_mode){ &error("ページが存在しません。"); }

# CSS定義
$css_text .= qq(
.blue{color:#00f;}
table,tr,th,td{border-style:none;}
th,td{padding:0.3em 2em 0.3em 0em;}
th{background-color:#dee;}
);

# 管理者をメンバーに
$line .= qq(<tr><td>$scad_name</td><td><span class="red">管理者</span></td><td><a href="scmail.html">管理者にメール</a></td></tr>\n);

# メンバーファイルを開く
open(MEMBER_IN,"${int_dir}_invite/member_${secret_mode}.cgi");
while(<MEMBER_IN>){
chomp;
my($mark);
my($key,$user,$pass,$handle,$file2,$lasttime,$email,$submittime,$emailkey,$sendmail) = split(/<>/);
$line .= qq(<tr>);
if($submittime){ $mark = qq( <span class="red">参加</span> ); } else { $mark = qq( <span class="blue">招待中</span> ); }
$line .= qq(<td>$handle</td><td>$mark</td><td>);
if($emailkey eq "1" && $email ne "" && $allowaddress_mode){ $line .= qq(<a href="mailto:$email">$email</a> (自主公開) );  }
if($user eq $username){ $line .= qq( <a href="$script?mode=member&amp;type=vedit">→編集</a>); }
$line .= qq(</td></tr>\n);
}
close(MEMBER_IN);

#<th>筆名</th><th>参加状態</th><th>メールアドレス（自主公開）</th>

# 表示整形
$line = qq(
<table summary="メンバーリスト">
$line
</table>
);

# タイトル定義
$sub_title = qq(メンバーリスト - $title);
$head_link3 = qq(&gt; メンバーリスト);


# HTML
my $print = qq(
<h1>参加中のメンバー</h1>
<a href="./">掲示板に戻る</a>
<h2>メンバーリスト</h2>
$line
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


1;

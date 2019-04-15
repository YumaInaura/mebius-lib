
use Mebius::Admin;

#-----------------------------------------------------------
# 管理者のメールアドレス
#-----------------------------------------------------------
sub main_admins{

my($line) = Mebius::Admin::MemberList("Get-index-normal");

	# 各管理者のメルフォ
	if($submode2 eq "form"){ &main_admins_mailform("$line"); }
	else{ &admins_list("$line"); }

}

#-----------------------------------------------------------
# 管理者の一覧を表示
#-----------------------------------------------------------

sub admins_list{

my($line) = @_;

# タイトル定義
$sub_title = "管理者一覧";
$head_link3 = qq(&gt; 管理者一覧);


# HTML
my $print = <<"EOM";
<a href="http://aurasoul.mb2.jp/">ＴＯＰページ</a>
<a href="JavaScript:history.go(-1)">前の画面へ</a><br><br>

<h1>管理者一覧</h1>
$line
EOM

Mebius::Template::gzip_and_print_all({},$print);

# 終了
exit;
}

#-----------------------------------------------------------
# 各管理者へメール
#-----------------------------------------------------------
sub main_admins_mailform{

my $second_id = $main::submode3;

	my(%fook_member) = Mebius::Admin::MemberFookFile("Get-hash File-check-error",$second_id);
	my(%member) = Mebius::Admin::MemberFile("Get-hash File-check-error Allow-empty-password",$fook_member{'id'});

	if($member{'use_mailform'} ne "1" || !$member{'email'}){ main::error("この管理者はメールフォームを設定していません。"); }


	# メール送信処理
	if($main::postflag && $main::in{'send_mail'}){
		Mebius::Redun(undef,"Mail-to-admin",5*60);
		Mebius::send_email(undef,$member{'email'},"$member{'name'}へのメッセージ - $main::in{'name'}",qq($main::in{'comment'}),$main::in{'email'});
	}

# タイトル定義
$sub_title = "$member{'name'}へのメール";
$head_link3 = qq(&gt; $member{'name'}へのメール);

# CSS定義
$css_text .= qq(
.msgform{width:80%;height:200px;}
);


# 管理者にアカウントある場合
if($faccount){ $pri_fname = qq(<a href="${auth_url}$faccount/">$fname</a>); }

# HTML
my $print = <<"EOM";
<div>
<a href="http://aurasoul.mb2.jp/">ＴＯＰページ</a>
<a href="JavaScript:history.go(-1)">前の画面へ</a>
</div>
<h1>$member{'name'}へのメール</h1>

$member{'name'} へのメッセージ、ご連絡はこちらからどうぞ。<br>
ただし、同じ内容が総合管理者（愛浦マスター）にも送信されます。<br><br>

＊ここでは削除依頼などの重要連絡は受け付けていません。<br><br>

<h2>送信フォーム</h2>

<form action="./" method="post">
<div>
<input type="hidden" name="mode" value="admins-form-$second_id">
<input type="hidden" name="send_mail" value="1">
筆名<br>
<input type="text" name="name" value="$main::chandle"><br>
メールアドレス<br>
<input type="text" name="email" value="$main::cemail"><br>
本文<br>
<textarea name="comment" rows="6" cols="50" class="msgform"></textarea>
<br><input type="submit" value="この内容で送信する">
</div>
</form>
EOM

Mebius::Template::gzip_and_print_all({},$print);

# 終了
exit;

}


1;

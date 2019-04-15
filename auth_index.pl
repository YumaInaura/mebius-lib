
use strict;
package Mebius::Auth;

#-------------------------------------------------
# 新規登録・ログインフォーム
#-------------------------------------------------
sub Index{

my($type) = @_;
my(undef,$error_message) = @_ if($type =~ /Error-browse/);
my($maxlengthac,$form,$error_line,%use_header);

# Canonical属性
$main::canonical = "${main::auth_url}";

# CSS定義
$main::css_text .= qq(
.putid{}
.nowrap{white-space:nowrap;}
.secure{font-weight:normal;font-size:90%;color:red;}
.guide_text{font-size:90%;color:#080;}
span.alert{font-size:90%;color:#f00;}
);

$main::head_link2 = qq( &gt; $main::title );

# CSS定義
$main::css_text .= qq(
.forgot{font-size:90%;color:#f00;}
);

# ログインフォームを取得 ( 処理タイプをそのまま引渡し )
($form) = Mebius::Auth::LoginForm($type,$error_message);

$main::meta_tag_free .= qq(\n<meta name="google-site-verification" content="maWaXY_1fhtNFnNdUn7WH2Jg36BcB1YP3TxvF8pQ3WY">);

	# ヘッダ
	if($ENV{'REQUEST_METHOD'} eq "GET"){
		$use_header{'BodyTagJavascript'} = qq( onload="document.login_form.authid.focus()");
	}


my $print = <<"EOM";
$main::footer_link
<h1>メビウスリング アカウント</h1>
$error_line
$form
$main::footer_link2
EOM

Mebius::Template::gzip_and_print_all(\%use_header,$print);


exit;

}

#-----------------------------------------------------------
# ログインフォームを取得
#-----------------------------------------------------------
sub LoginForm{

# 宣言
my($type,$error_message) = @_;
my($form,$error_line,$inputed_account,$inputed_password);
my($checked_check1,$checked_check2,$password_input_type);
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
require "${init_directory}auth_prof.pl";
my($my_account) = Mebius::my_account();

		# 整形
	if($my_account->{'login_flag'}){
		Mebius::Redirect(undef,"$my_account->{'profile_url'}feed");
	} else {
		$form .= qq(
		アカウントに登録すると、以下のサービスがご利用いただけます。
		<ul class="margin">
		<li>メビリンSNS （<a href="${main::guide_url}%A4%E8%A4%AF%A4%A2%A4%EB%BC%C1%CC%E4%A1%CA%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A1%CB">→よくある質問</a>）</li>
		<li>メビリン・アドベンチャー</li>
		</ul>
		<h2>ログイン</h2>
		);
	}

	# クッキーなしの場合
	if(!$main::cookie && !Mebius::Device::bot_judge()){
			if($main::in{'redirected'}){
					$form .= qq(<strong class="red">＊この環境では、アカウントを発行できません。いちど画面を更新してみてください。</strong>);
			}
			else{
				Mebius::Cookie::set_main();
				Mebius::Redirect(undef,"$basic_init->{'auth_url'}?redirected=1&$ENV{'QUERY_STRING'}");
			}
		return($form);
	}

	# ログイン中の場合
	if($main::pmfile && $type !~ /Error-browse/){
		$form .= qq(既にログイン中です。);
		$form .= qq(<ul class="margin">);
		$form .= qq(<li><a href="${main::auth_url}$main::pmfile/">→あなたのプロフィールへ</a></li>);
		$form .= qq(<li><a href="http://aurasoul.mb2.jp/gap/ff/ff.cgi">→メビリンアドベンチャーへ</a></li>);
		$form .= qq(</ul>);
		return($form);
	}

	# パスワード入力欄のタイプ
	$password_input_type = "password";

	# 初期チェック
	if($main::k_access || $ENV{'USER_AGENT'} =~ /3DS/){
		$checked_check1 = $main::parts{'checked'};
		$checked_check2 = $main::parts{'checked'};
	}

	if(Mebius::Query::post_method_judge()){
		$inputed_account = $main::in{'authid'};
		$inputed_password = $main::in{'passwd1'};
			if($main::in{'checkpass'}){
				$checked_check1 = $main::parts{'checked'};
				$password_input_type = "text";
			}
			if($main::in{'other'}){
				$checked_check2 = $main::parts{'checked'};
			}
	}


	# エラーメッセージ
	if($error_message){
		$error_line = qq(<div class="line-height padding" style="background:#fee;color:#f00;">エラー： $error_message</div>);
		$form .= qq($error_line);
	}

# フォーム部分
$form .= qq(
<form action="./" method="post" name="login_form" $main::sikibetu>
<div><table>
<tr>
<td class="nowrap">アカウント名
</td><td>
<input type="text" name="authid" value="$inputed_account" pattern="^[0-9a-zA-Z]+\$" class="putid">
( 例： mickjagger )

</td>
</tr>
<tr>
<td class="nowrap">パスワード</td>
<td><input type="$password_input_type" name="passwd1" value="$inputed_password" maxlength="20">
(例： Adfk432d ) 
　 <a href="./?mode=aview-remain" class="size80">※パスワードを忘れてしまった場合は…</a>
</td>
</tr>
<tr><td></td><td>
<input type="submit" value="ログインする">
<input type="hidden" name="mode" value="login">
<input type="hidden" name="back" value="$main::in{'back'}">
<input type="hidden" name="backurl" value="$main::in{'backurl'}">
<input type="hidden" name="login_doned" value="1">
<br><br>

<input type="checkbox" name="checkpass" value="1" id="login_check1"$checked_check1>
<span class="alert"><label for="login_check1">スペルチェック　…　ログインに失敗した場合、入力した「パスワード」を、画面にそのまま表\示させます（後ろに人がいないかご確認ください）。</label></span><br>
<input type="checkbox" name="other" value="1" id="login_check2"$checked_check2>
<span class="alert"><label for="login_check2">強力ログイン　…　「一部の掲示板で筆名がリンクにならない」「新チャット城、マイログが使えない」などの不具合が起こる場合は、チェックを入れてください。</label></span><br>


</td></tr>
</table><br>);


$form .= qq(

<a href="./?mode=aview-newform$main::backurl_query_enc">→アカウントをお持ちでない方は、こちらから新規登録してください。</a><br><br>

);


$form .= qq(
</div>
</form>
);

$form .= qq(<h2>ログイン時のご注意</h2>);

$form .= qq(<ul>\n);
$form .= qq(<li>アカウントにメールアドレスが登録されている場合、ログインした時点で自分にメールが送信されます。\n);

$form .= qq(</ul>\n);

return($form);


}


1;


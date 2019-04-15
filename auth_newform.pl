

#-------------------------------------------------
# 新規登録・ログインフォーム
#-------------------------------------------------
sub auth_newform{

my($maxlengthac,$form);

# Canonical属性
$canonical = "${auth_url}";

# CSS定義
$css_text .= qq(
.putid{}
.nowrap{white-space:nowrap;}
.secure{font-weight:normal;font-size:90%;color:red;}
.guide_text{font-size:90%;color:#080;}
span.alert{font-size:90%;color:#f00;}
);

$head_link2 = qq( &gt; $title );

# CSS定義
$css_text .= qq(
.forgot{font-size:90%;color:#f00;}
);

# ログインフォームを取得
($form) = &get_form_auth_index();

# ヘッダ
&header();

print <<"EOM";
<div class="body1">
$footer_link
<h1>$title</h1>

$form
$footer_link2</div>
EOM

# フッタ
&footer();

exit;

}


use strict;

#-----------------------------------------------------------
# ログインフォームを取得
#-----------------------------------------------------------
sub get_form_auth_index{

# 宣言
my($form);
our($guide_url,$action,$sikibetu,%in,$script,$backurl_query_enc,$friend_tag,$pmfile,$cookie);

# 整形
$form .= qq(
公開性のＳＮＳです。メンバー登録すると、日記を書いたり、他のメンバーと$friend_tag登録したりできます。
（<a href="${guide_url}%A4%E8%A4%AF%A4%A2%A4%EB%BC%C1%CC%E4%A1%CA%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A1%CB">→よくある質問</a>）
<h2>ログイン</h2>
);

	# クッキーなしの場合
	if(!$cookie){
		$form .= qq(<strong class="red">＊この環境では、アカウントを発行できません。いちど画面を更新してみてください。</strong>);
		return($form);
	}

	# ログイン中の場合
	if($pmfile){

		$form .= qq(既にログイン中です。);
		return($form);

	}

# ログイン中の場合、プロフィールページにリダイレクト
#if($pmfile){
#&redirect("${auth_url}${pmfile}/");
#&jump("","${auth_url}$pmfile/","1","SNSのトップページです。");
#&error("$titleのトップページですが、既にログイン中です。<a href=\"${auth_url}${pmfile}/\">プロフィールページ</a>へ進んでください。");
#}

# フォーム部分
$form .= qq(
<form action="./" method="post"$sikibetu>
<div><table>
<tr>
<td class="nowrap">アカウント名</td><td>
<input type="text" name="authid" value="" class="putid">
( 例： mickjagger )</td>
</tr>
<tr>
<td class="nowrap">パスワード</td>
<td><input type="password" name="passwd1" value="" maxlength="20">
(例： Adfk432d )</td>
</tr>
<tr><td></td><td>
<input type="submit" value="ログインする">
<input type="hidden" name="mode" value="login">
<input type="hidden" name="back" value="$in{'back'}">
<input type="hidden" name="backurl" value="$in{'backurl'}">
<br><br>

<input type="checkbox" name="checkpass" value="1">
<span class="alert">チェック１　…　パスワードが間違っている場合、エラー画面に「アカウント名」と「パスワード」を表\示させます（スペルチェック用）。</span><br>
<input type="checkbox" name="other" value="1">
<span class="alert">チェック２　…　「一部の掲示板で筆名がリンクにならない」「新チャット城、マイログが使えない」などの不具合が起こる場合は、チェックを入れてください。</span>

</td></tr>
</table><br>);


$form .= qq(
<a href="$script?mode=aview-newform$backurl_query_enc">→アカウントをお持ちでない方は、こちらから新規登録してください。</a><br><br>
<a href="$script?mode=aview-remain">→パスワードを忘れた場合は…。</a>
);


$form .= qq(
</div>
</form>
);

return($form);


}


1;


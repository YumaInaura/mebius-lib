

#-------------------------------------------------
# 新規登録・ログインフォーム
#-------------------------------------------------

my($maxlengthac,$alert_text,$form);

# maxlengthを定義
unless($age =~ /PSP/){ $maxlengthac = qq( maxlength="10"); }

$css_text .= qq(
.putid{}
.nowrap{white-space:nowrap;}
.secure{font-weight:normal;font-size:90%;color:red;}
.guide_text{font-size:90%;color:#080;}
);

$thisis_bbstop = 1;

# ログイン中の場合、プロフィールページにリダイレクト
#if($idcheck){ location "view-$pmfile-all-1.html\n\n"; }

# CSS定義
$css_text .= qq(
.forgot{font-size:90%;color:#f00;}
);

# フォーム部分
$form = qq(

<h2 id="NEW">新規メンバー登録</h2>

$alert_text
<strong class="red">＊注意！　
クレジットカードの暗証番号など、大事なパスワードを入力しないでください。<br>
</strong>
<br>

<form action="$auth_url" method="post"$sikibetu><div>
希望アカウント名（半角英数字 3-10文字）<br>
<input type="text" name="authid" value="" class="putid"$maxlengthac> ( 例： mickjagger )<br>

パスワード（半角英数字 4-8文字）<br>
<input type="password" name="passwd1" value="" maxlength="8"> ( 例： Adfk432d )<br>
パスワード確認（半角英数字 4-8文字）<br>
<input type="password" name="passwd2" value="" maxlength="8"> ( 例： Adfk432d )<br>
メールアドレス(未入力可)<br>
<input type="text" name="email" value="" class="putid">
<span class="guide_text">＊アカウント名、パスワードの控えが送信されます。</span><br><br>

<input type="hidden" name="mode" value="makeid">
<input type="hidden" name="back" value="one"><br>
<input type="submit" value="アカウントを作成する">
</div></form>
);

# クッキーなしの場合
if(!$cookie && $mebi_mode){ $form = qq(<strong class="red">＊この環境では、アカウントを発行できません。いちど画面を更新してみてください。</strong><br><br>); }

my $print = <<"EOM";
<h1>アカウント新規登録</h1>
$form
$footer_link
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

1;


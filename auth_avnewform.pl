
package main;

#-------------------------------------------------
# 新規登録フォーム
#-------------------------------------------------
sub auth_avnewform{

my($maxlengthac,$form);

# maxlengthを定義
unless($age =~ /PSP/){ $maxlengthac = qq( maxlength="10"); }

# CSS定義
$css_text .= qq(
.putid{}
.nowrap{white-space:nowrap;}
.secure{font-weight:normal;font-size:90%;color:red;}
.guide_text{font-size:90%;color:#080;}
input{margin:0.3em 0em;}
.forgot{font-size:90%;color:#f00;}
ul{color:#f00;}
);

	# ストップモード
	if($main::stop_mode =~ /SNS|Make-new-account/){ main::error("現在、新規登録は停止中です。","503 Service Temporarily Unavailable"); }

# タイトル定義
$sub_title = "新規メンバー登録 - $title";
$head_link3 = " &gt; 新規メンバー登録";

# 金貨引継ぎなどの説明
my($gold_text);
$gold_text = qq(
<li>「金貨」「投稿回数」「総文字数」はリセットされ、アカウント毎に記録されるようになります。ログアウトすると元の記録から始められる場合があります。</li>
<li>ログイン中は、マイページの「金貨」「投稿回数」「総文字数」などはサーバー毎に記録されるようになります。</li>
);

#if($kaccess_one){  $gold_text = qq(<li>登録すると「金貨」「投稿回数」「総文字数」の記録は、アカウントデータとして引き継がれます。ログアウトした場合の「金貨」「投稿回数」「総文字数」はリセットされます。</li>); }

# ローカルでの初期入力
my $first_input_password = "qaswqasw" if Mebius::AlocalJudge();
my $first_checked_agree1 = my $first_checked_agree2 = my $first_checked_agree3 = " checked" if Mebius::AlocalJudge();
my $input_password_type;
if(Mebius::AlocalJudge()){ $input_password_type = "text"; } else { $input_password_type = "password"; }

# フォーム部分
$form = qq(
<h2 id="ALERT">ご注意 ( 必ずお読みください )</h2>

$alert_text
<ul>
<li>クレジットカードの暗証番号など、大事なパスワードを入力しないでください。</li>
<li>アカウントの乱立はご遠慮ください。既にアカウントをお持ちの方は<a href="$auth_url">ログイン</a>してください。</li>
<li>いちどアカウントを作ると、完全閉鎖は出来ません。日記やコメントをひとつずつ削除して、何もない状態にする必要があります。</li>
<li>パスワード忘れが起きがちです。大文字・小文字の違いなどに注意して、パスワードは必ずなくさない場所にメモしておいてください。</li>
<li>メールアドレスを入力すると、アカウント名の控えが自動送信されます。</li>
$gold_text
</ul>


<h2 id="NEW">登録フォーム</h2>

<form action="$action" method="post"$sikibetu><div>
希望アカウント名<br>
<input type="text" name="authid" value="" pattern="^[0-9a-z]+\$" class="putid"$maxlengthac>
<span class="guide_text">　( 半角英数字 3-10文字 )　例： mickjagger </span><br>

パスワード<br>
<input type="$input_password_type" name="passwd1" value="$first_input_password" maxlength="20">
<span class="guide_text">　例： Adfk432d </span><br>
パスワード確認<br>
<input type="$input_password_type" name="passwd2" value="$first_input_password" maxlength="20">
<span class="guide_text">　例： Adfk432d</span><br>
<input type="hidden" name="mode" value="makeid">
メールアドレス<br>
<input type="text" name="email" value="" class="putid">

<span class="guide_text">　( 未入力可 )　※アカウント名の控えが送信されます。</span>

<h3>利用規約</h3>

<ul>
<li><input type="checkbox" name="check1" value="1"$first_checked_agree1> 私は<a href="${guide_url}%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A4%CE%A5%EB%A1%BC%A5%EB" target="_blank">$titleのルール</a>と、必要なリンク先のガイドを熟読しました。
<li><input type="checkbox" name="check2" value="1"$first_checked_agree2> 私は<strong class="red">「個人情報の掲載、交換」「悪口、陰口、罵倒」「晒し行為」「マナーを欠いたグチ」「チェーン投稿」</strong>などの不正利用は、決しておこないません。
<li><input type="checkbox" name="check3" value="1"$first_checked_agree3> 不適切な利用があった場合、私は予\告なしに「コメント削除」「アカウントロック（削除）」「投稿制限」「プロバイダ連絡」などの処置を取られても構\いません。
</ul>
<br>
$backurl_input
<input type="submit" value="利用上の注意に同意して、アカウントを作成する"><br>
<br>

</div></form>

);

	# クッキーなしの場合
	if(!$cookie){
		$form = qq(<strong class="red">＊この環境では、アカウントを発行できません。いちど画面を更新してみてください。</strong><br><br>);
	}

my $print = <<"EOM";
$footer_link
<h1>新規アカウント登録 - メビウスリング</h1>

$form
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;



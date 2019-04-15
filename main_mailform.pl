
# 基本宣言
use strict;
package Mebius::MailForm;

#-----------------------------------------------------------
# モード振り分け
#-----------------------------------------------------------
sub Start{

	# モバイル用の処理
	if($main::device_type eq "mobile"){ main::kget_items(); }

	# リンク議定
	$main::sub_title = qq(メビウスリング - メールフォーム);
	$main::head_link4 = qq(&gt; メールフォーム);

	# モード振り分け
	if($main::in{'type'} eq "sendmail"){ &SendMail(); }
	else{ &Index(); }

}

#-----------------------------------------------------------
# フォームを表示
#-----------------------------------------------------------
sub Index{

# 局所化
my($type) = @_;
my(undef,$error_message) = @_ if($type =~ /Error-view/);
my($form_line,$inputed_name,$inputed_email,$inputed_comment,$preview_line);

	# 初期入力を定義
	if($main::in{'name'} && $main::postflag){
		$inputed_name = $main::in{'name'};
	}
	else{
		$inputed_name = $main::cnam;
	}

	# 初期入力を定義
	if($main::in{'email'} && $main::postflag){
		$inputed_email = $main::in{'email'};
	}
	else{
		$inputed_email = $main::cemail;
	}

	# 初期入力の本文
	if($main::in{'comment'} && $main::postflag){
		$inputed_comment = $main::in{'comment'};
		$inputed_comment =~ s/<br>/\n/g;
	}
	

$form_line .= qq(
<h1$main::kstyle_h1>メビウスリング メールフォーム</h1>

ここでメッセージを送信すると、メビウスリングの総合管理者（あうらゆうま）に届きます。
);


	# エラーを表示する場合
	if($error_message){
		$form_line .= qq(<div style="background:#fee;color:#f00;padding:0.5em 1.0em;margin:1em 0em;">\n);
		$form_line .= qq(エラー： $error_message\n);
		$form_line .= qq(</div>\n);
	}

	# プレビューを表示する場合
	if($main::postflag && $main::in{'preview'}){
		$preview_line .= qq(<div style="background:#eef;padding:1em;margin:1em 0em;">\n);
		$preview_line .= qq(プレヴュー：<br$main::xclose><br$main::xclose>\n);
		$preview_line .= qq($main::in{'comment'}\n);
		$preview_line .= qq(</div>\n);

	}

$form_line .= qq(
$preview_line
<form action="./mailform.html" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="mailform">
<input type="hidden" name="type" value="sendmail">
$main::backurl_input
<table style="margin:1em 0em;"><tr><td nowrap class="valign-top">
お名前
</td><td>

<input type="text" name="name" size="25" style="width:50%;" value="$inputed_name">
<br><span style="font-size:90%;color:#f00;">＊必須 … サイト内の筆名（ハンドルネーム）などを入力してください。</span>
</td></tr><tr><td nowrap class="valign-top">

メールアドレス<br>

</td><td class="line-height"><input type="text" name="email" value="$inputed_email" size="25" style="width:50%;">
<ul style="font-size:90%;color:#f00;">
<li><strong>メールアドレスをお持ちの場合は必ず入力してください。</strong><br$main::xclose>
<li>当方にて<strong>返信の必要があると判断したお問い合わせ</strong>については、記入されたメールアドレスへご連絡さしあげております。<br$main::xclose>
<li>アドレス未記入のご連絡、削除依頼には応じかねる場合がございます。また、アドレスをお間違いの場合は当方から返信できません。<br$main::xclose>
</ul>

</td></tr><tr>
<td nowrap class="valign-top">
本文</td><td class="line-height">
<textarea name="comment" rows="6" cols="50" style="width:90%;height:200px;">$inputed_comment</textarea>


<ul style="font-size:90%;color:#f00;line-height:1.4;">
<li>メール送信する特別な理由がない場合、ご質問・ご連絡は必ず<a href="http://aurasoul.mb2.jp/_qst/" target="_blank" class="blank">メビウスリング質問運営</a>をご利用ください。<br>
<li>メール送信する特別な理由がない場合、削除依頼は必ず<a href="http://aurasoul.mb2.jp/_delete/" target="_blank" class="blank">削除依頼掲示板</a>をご利用ください。<br>
<li>削除依頼の場合、<a href="http://aurasoul.mb2.jp/wiki/guid/%BA%EF%BD%FC%B0%CD%CD%EA" target="_blank" class="blank">削除依頼のガイド</a>を参考に、必ず「ＵＲＬ」「レス番」「依頼理由」などを明記してください。<br>
<li>不具合報告をいただく際は、<a href="http://aurasoul.mb2.jp/wiki/guid/%C9%D4%B6%F1%B9%E7%CA%F3%B9%F0" target="_blank" class="blank">不具合報告表</a> にご記入いただければ、解決が早くなるかもしれません。
<li>セキュリティ上の理由で、メールの控えは送信されません。記録が必要なメッセージは、ユーザー様側で保存をお願いいたします。<br>
</ul>

</td></tr><tr><td></td><td>
<input type="submit" name="preview" value="この内容でプレビューする" class="ipreview">
<input type="submit" value="この内容で送信する" class="isubmit">
</td></tr></table>
</div>
</form>

);



Mebius::Template::gzip_and_print_all({},$form_line);

exit;


}

#-----------------------------------------------------------
# メールを送信
#-----------------------------------------------------------
sub SendMail{

# 宣言
my($type) = @_;
my($mail_body);
my($my_account) = Mebius::my_account();

	# 長さチェック
	if(length($main::in{'comment'}) >= 2*100000){ &Index("Error-view","本文が長すぎます。"); }
	if($main::in{'comment'} =~ /^((\s|　|<br>)+)?$/){ &Index("Error-view","本文を入力してください。"); }
	if(length($main::in{'name'}) >= 2*100){ &Index("Error-view","お名前が長すぎます。"); }

	# 重複チェック
	my($redun_error) = Mebius::Redun("Read-only","Mailform-send");
	if($redun_error && !$main::myadmin_flag){
		&Index("Error-view",$redun_error);
	}

	# メールの書式チェック
	if($main::in{'email'}){
		my($format_error) = Mebius::mail_format("",$main::in{'email'});
			if($format_error){ &Index("Error-view",$format_error); }
	}

	# 本文のスパムチェック
	if($main::in{'comment'} =~ /(\[url)/){
		&Index("Error-view","本文に $& というキーワードは使えません。");
	}

	# プレビュー
	if($main::in{'preview'}){
		&Index("Preview-view");
	}

# トリップを付与
my($enctrip,$handle) = main::trip($main::in{'name'});
	my $name = $handle;
	if($enctrip){ $name = "$handle☆$enctrip"; }

# メール本文
$mail_body .= qq(────────────-────────────────\n);
$mail_body .= qq(▼送信内容\n);
$mail_body .= qq(────────────────────────────\n\n);

$mail_body .= qq(お名前 = $name\n);
$mail_body .= qq(メールアドレス = $main::in{'email'}\n);
$mail_body .= qq(本文 = $main::in{'comment'}\n);

# メール送信
my($error_message) = Mebius::send_email("To-master",undef,"メビウスリングメールフォーム - $name",$mail_body,$main::in{'email'});
	#if($error_message && $error_message != 1){ main::error($error_message); }

	# テスト
	if($my_account->{'master_flag'}){
		Mebius::send_email("",$main::in{'email'},"テスト送信 - メビウスリングメールフォーム - $name",$mail_body);
	}

# クッキーをセット
Mebius::Cookie::set_main({ name => $main::in{'name'} , email => $main::in{'email'} },{ SaveToFile => 1 });

# 重複ファイルを更新
Mebius::Redun("Renew-only","Mailform-send");

my $print = qq(メールを送信しました。);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


1;
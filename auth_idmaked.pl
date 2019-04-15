
package main;


#-------------------------------------------------
# ＩＤを作成しました
#-------------------------------------------------
sub auth_idmaked{

my($print);

# CSS定義
$css_text .= qq(
.maked{width:70%;background-color:#fcc;padding:1em;}
);


	# アカウント作成から２４時間以内であれば、

	if($idcheck){

		# リンク先
		my $link = "${pmfile}/";
		my $text = qq(<a href="$link">マイアカウント</a>へ移動すると、データの編集できます。);

		if($in{'back'} eq "one"){
		$text = qq(次にマイログの<a href="http://aurasoul.mb2.jp/_one/start.html">新規登録処理</a>をしてください。);
		}
		if($aurl_mode){ ($link) = &aurl($link); }

		$print = qq(アカウントを作成しました。<br>$text<br>);
	}

	# ２４時間経過後、アカウント名やＰＡＳＳがない場合
	else{
		$print = qq(アカウントを作成しました。入力したアカウント名，パスワードを使って<a href="$auth_url">ログイン</a>してください。<br><br>$footer_link2);

	}

Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;

}

1;

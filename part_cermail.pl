
use strict;
use Mebius::Auth;
use Mebius::BBS;
package Mebius::Email;

#-----------------------------------------------------------
# 掲示板記事のメール認証
#-----------------------------------------------------------
sub CermailStart{

	# 携帯モード
	if($main::device{'type'} eq "Mobile"){ main::kget_items(); }

# リペア避け
$main::not_repair_url_flag = 1;

# 検索よけ
$main::noindex_flag = 1;

# 元記事ファイルを開く
my($thread) = Mebius::BBS::thread_state($main::in{'no'},$main::moto);

# リンク定義
$main::head_link3 = qq( &gt; <a href="$main::in{'no'}.html">$thread->{'subject'}</a>);
$main::head_link4 = qq( &gt; お知らせメール登録);

	# モード振り分け	# 登録削除
	if($main::in{'type'} eq "cancel"){
		CancelMailBBSThread(undef,$main::in{'email'},$main::in{'char'},$main::moto,$main::in{'no'});
	# 確認メールの配信
	} elsif($main::in{'type'} eq "send_cermail"){
		my($error_flag) = SendCermail("BBS-thread From-form Set-cookie View-HTML",$main::in{'email'},$main::moto,$main::in{'no'});
			if($error_flag){ main::error("$error_flag"); }
	# ?
	}	else {
		FormSendCermailThread();
	}

}

#-----------------------------------------------------------
# お知らせメール登録フォーム - 掲示板の記事用
#-----------------------------------------------------------
sub FormSendCermailThread{

# 局所化
my($myaddress) = Mebius::my_address();
my($top);
my($guide_text1,$alert_text,$mail_input,$mail_submit,$cancel_hidden,$type_input);

# メルアド毎の登録状況の取得
my($still_flag) = Mebius::Email::BBSThread("Still-check",$myaddress->{'address'},$main::moto,$main::in{'no'});

# 元記事ファイルを開く
my(%thread) = Mebius::BBS::thread({},$main::moto,$main::in{'no'});

# CSS定義
$main::css_text .= qq(
.mail{width:15em;}
.manual{font-size:90%;border:solid 1px #666;padding:1em 2em;line-height:1.5em;margin-top:2em;}
);

# タイトル定義
$main::sub_title = "メール配信登録 | $thread{'subject'}";

# フォーカスを当てる
$main::body_javascript = qq( onload="document.cermailform.email.focus()");

# 説明文を定義 - 認証済みの場合
$guide_text1 = qq(
<div class="line-height">
ここでメールアドレスを登録すると、<br$main::xclose>
<a href="./">$main::title</a>の<a href="$main::in{'no'}.html">$thread{'subject'}</a>に書き込みがあったとき、
メールでお知らせが届きます。
</div><br$main::xclose>
);

	# 注意書きを定義 - 認証済みの場合
	if($myaddress->{'myaddress_flag'}){
		$alert_text = qq(
		<br$main::xclose><br$main::xclose><span class="red">
		→<a href="${main::main_url}?mode=my">マイページ</a>でもお知らせメールの管理、解除が出来ます。</span>);
	}
	# 注意書きを定義 - 認証なしの場合
	else{
		$alert_text = qq(
		<br$main::xclose><br$main::xclose>
		<div class="red line-height">
		＊イタズラ防止のため、入力されたメールアドレスに、あなたの「ＩＤ情報」「ＩＰ（接続情報）」などが送信されます（本人のアドレスである場合は、問題ありません）。<br$main::xclose>
		＊お知らせメールに書かれた「解除用ＵＲＬ」にアクセスすることで、記事ごとの配信解除が出来ます。
		</div>);
	}

	# 認証済み＆登録済みの場合
	if($still_flag eq "Still"){
		$mail_submit .= qq(<input type="submit" value="お知らせメールを解除する"$main::xclose>\n);
		$mail_submit .= qq(<input type="hidden" name="email" value="$myaddress->{'address'}"$main::xclose>\n);
		$mail_input .= qq(<strong style="color:#f00;">$myaddress->{'address'}</strong>);
		$mail_input .= qq(<input type="hidden" name="email" value="$myaddress->{'address'}"$main::xclose>);
		$guide_text1 = qq(この記事 ( $thread{'subject'} )にはお知らせメールを<strong style="color:#00f;">登録済み</strong>です。　解除しますか？<br$main::xclose><br$main::xclose>);
		$cancel_hidden = qq(<input type="hidden" name="cancel" value="1"$main::xclose>);
		$type_input = "cancel";
	}

	# 認証済み
	elsif($myaddress->{'myaddress_flag'}){

		# 元記事のキーがない場合 
		if($thread{'keylevel'} < 1){ main::error("この記事にはお知らせメールを登録できません。"); }

		# メールパーツを定義
		$mail_input .= qq(<input type="text" name="email" value="$myaddress->{'address'}" class="mail" id="cermail_address"$main::xclose>);
		$mail_input .= qq(　<strong style="color:#f00;">(認証済み)</strong>);
		$mail_submit .= qq(<input type="submit" value="このアドレスを登録する"$main::xclose>\n);

		$type_input = "send_cermail";
	}

	# 認証なし
	else{

		# 元記事のキーがない場合 
		if($thread{'keylevel'} < 1){ main::error("この記事にはお知らせメールを登録できません。"); }
	
		# メールパーツを定義
		$mail_input .= qq(<input type="text" name="email" value="$main::cemail" class="mail" id="cermail_address"$main::xclose>);
		$mail_submit = qq(<input type="submit" value="配信確認メールを送る"$main::xclose>);
		$type_input = "send_cermail";
	}


	if(Mebius::Switch::stop_bbs()){ $mail_input = ""; $mail_submit = qq(<span class="alert">※現在、登録出来ません。</span>); }

# HTML
my $print = <<"EOM";
<h1>お知らせメール登録</h1>
$guide_text1
<form action="./?regist" method="post" name="cermailform"$main::sikibetu><div>
<label for="cermail_address">メールアドレス</label>
$mail_input
$mail_submit
$cancel_hidden
<input type="hidden" name="mode" value="cermail"$main::xclose>
<input type="hidden" name="type" value="$type_input"$main::xclose>
<input type="hidden" name="moto" value="$main::moto"$main::xclose>
<input type="hidden" name="no" value="$main::in{'no'}"$main::xclose>
<input type="hidden" name="action" value="1"$main::xclose>
$alert_text
</div></form>
EOM

	# 登録時の詳しい説明文
	if($type_input ne "cancel"){
		$print .= qq(
		<ul class="manual">
		<li>登録作業をすると、一度確認メールが届きます。次に記載されたＵＲＬにアクセスすると、お知らせ配信が開始します。</li>
		<li>いちど認証作業を済ますと、次からはダイレクトに登録できるようになります（ただし、環境によります）。</li>
		<li>お知らせがあるのは、「<a href="./">$main::title</a>」の「<a href="$main::in{'no'}.html">$thread{'subject'}</a>」に書き込みがあったときだけです。（掲示板全体ではありません）</li>
		<li>複数の記事にお知らせが欲しいときは、記事ごとに登録作業をしてください。</li>
		<li>あなたのメールアドレス以外は登録しないでください。</li>
		</ul>
		);
	}

# フッタ
Mebius::Template::gzip_and_print_all({},$print);

# 終了
exit;

}

#-----------------------------------------------------------
# 確認メールを配信する
#-----------------------------------------------------------
sub SendCermail{

# 宣言
my($basic_init) = Mebius::basic_init();
my($type,$address) = @_;
my($moto,$no,$account);
if($type =~ /BBS-thread/) { (undef,undef,$moto,$no) = @_; }
if($type =~ /SNS-account/) { (undef,undef,$account) = @_; }
my($top,$top_deny1,$top_deny2,$line,$i_cermail,$link1,$flow,$line_submitout,$error_message);
my($cermail_url,%thread,$guide_cermail,$mail_body,$mail_subject,$plustype_mailaddress);
my(%renew_address,$message_line);

# サンプルアドレス
if($address =~ /example\@ne.jp/){ return(); }

# 投稿制限
main::axscheck("Deny-bot");

# ＩＤ付与
my($encid) = main::id();

# メールアドレス単体データを取得
my(%address) = Mebius::Email::address_file("Get-hash-detail Skip-undelivered-count",$address);

	# 各種エラー
	if(!$address{'myaddress_flag'}){
			if($address{'deny_flag'}){ return($address{'deny_flag'}); }
			if($address{'deny_sendcermail_flag'}){ return($address{'deny_sendcermail_flag'}); }
	}

# E-Mailの書式チェック
my($error_flag_mailformat,$address_type) = Mebius::mail_format(undef,$address);
	if($error_flag_mailformat){ return($error_flag_mailformat); }
	# 携帯への深夜の送信を禁止
	if(!$address{'myaddress_flag'} && $address_type eq "mobile"){
			if($main::thishour <= 6 && $main::thishour >= 0){ return("この時間帯(0時-6時)は携帯に認証メールを送れません。"); }
	}

# 迷惑情報がある場合、ブロック
my($error_flag_access_check) = Mebius::Email::AccessCheck(undef,$main::addr,$main::cnumber);
	if($error_flag_access_check){ return($error_flag_access_check); }

	# タイトル定義
	if($type =~ /View-HTML/){ $main::sub_title = "確認メールの配信"; }

	# ●掲示板の記事用のチェック
	if($type =~ /BBS-thread/){

			# 局所化
			my($redun_thread_flag,$thread_sendmail_handler);

			# 汚染チェック
			if($moto eq ""){ return("掲示板を指定してください。"); }
			if($no eq ""){ return("記事を指定してください。"); }
			if($moto =~ /\W/){ return("確認メールを配信しようとしましたが、掲示板の指定が変です。"); }
			if($no =~ /\D/){ return("確認メールを配信しようとしましたが、掲示板の指定が変です"); }

			# 元記事ファイルを開く
			(%thread) = Mebius::BBS::thread({},$moto,$no);

				# キーがない場合 ( + 汚染チェックを兼ねる )
				if($thread{'keylevel'} < 1){ return("この記事にはお知らせメールを登録できません。"); }

			# 記事配信用ファイルを開き、二重登録チェック、
			open($thread_sendmail_handler,"$main::bbs{'data_directory'}_sendmail_${moto}/${no}_s.cgi");
				while(<$thread_sendmail_handler>){
					chomp;
					my($address2,$char2,$mailtype2) = split(/<>/,$_);
						if($address2 eq $address){ $redun_thread_flag = 1; }
				}
			close($thread_sendmail_handler);
				if($redun_thread_flag && !$main::alocal_mode){ return("この記事に、このメールアドレスは登録済みです。"); }

			# ▼既に認証済みの場合、ダイレクト登録する
			if($address{'myaddress_flag'}){
				my($error_flag) = BBSThread("Renew New-line",$address,$moto,$no,$thread{'sub'},$main::title);
					# エラー
					if($error_flag){ return($error_flag); }
					# 成功
					else{
						# ログの記録
						Mebius::AccessLog(undef,"Send-cermail-direct");
						# メルアドファイルの接続データ等を、最新の状態にする
						Mebius::Email::address_file("Renew Renew-myaccess",$address);
							# 成功してリターンする場合 ( レス投稿時など )
							if($type =~ /Post-regist/){
								return(undef,"お知らせメールを登録しました。");
							}
							# 登録完了メッセージを表示して終了 ( フォームからの登録 )
							else{
								$main::jump_sec = 1;
								$main::jump_url = "./$no.html";
								my $print = qq(お知らせメールを登録しました。(<a href="$main::jump_url">→戻る</a>));
								Mebius::Template::gzip_and_print_all({},$print);
								exit;
							}
					}
			}

	}

# 連続送信を禁止
my($redun_flag) = Mebius::Redun("Get-only","Send-cermail",1*60);
if($redun_flag){ return("連続して確認メールは送信できません。しばらくお待ちください。"); }

	# 登録タイプ ( 次に認証成功した場合の処理 ) を定義 
	if($type =~ /BBS-thread/){
		$renew_address{'cer_type'} = "$address{'cer_type'} BBS-thread-$moto-$no";
		$guide_cermail .= qq(\n登録先の記事： $thread{'subject'} http://$main::server_domain/_$moto/$no.html\n);
	}
	elsif($type =~ /SNS-account/){
		$renew_address{'cer_type'} = "$address{'cer_type'} SNS-account-$account";
	}

# メルアド単体ファイルを、確認状態にする（ファイル更新、$char を取得）
my(%renewed_address) = Mebius::Email::address_file("Send-cermail Renew",$address,%renew_address);

# メールアドレスのエンコード
my($address_enc) = Mebius::Encode(undef,$address);

# 認証用のURLを定義
$cermail_url .= "${main::main_url}?mode=address&type=cermail&char=$renewed_address{'cer_char'}";
$cermail_url .= "&mailtype=$main::in{'mailtype'}&email=$address_enc";

# メール件名
my $mail_subject = qq(メール配信確認 -メビウスリング);

# メール本文
$mail_body = qq(メビウスリング ( http://$main::server_domain/ ) で、あなたのメールアドレスを受信用として設定します。
$guide_cermail
メールアドレスは非公開で、お知らせ配信以外には使われません。
よろしければ、次のＵＲＬにアクセスしてください。
$cermail_url

●送信者情報●

筆名: $main::chandle
ID: $encid
IPアドレス: $main::addr
UA: $main::agent
);


# 確認メールを送信、メール単体ファイルを確認用として更新
my($keep_mailbody) = Mebius::send_email("Get-mailbody Edit-url-plus",$address,$mail_subject,$mail_body);

# 連続送信禁止ファイルを更新
my($redun_flag) = Mebius::Redun("Renew-only","Send-cermail",1*60);

# ログの記録
Mebius::AccessLog(undef,"Send-cermail");

	# クッキーセット
	if($type =~ /Set-cookie/){
		Mebius::Cookie::set_main({ email => $address },{ SaveToFile => 1 });
	}


# ローカル用のメッセージ内容を定義
my($alocal_view);
if($main::alocal_mode){
	$alocal_view .= qq(<hr$main::xclose>ローカル表\示<hr$main::xclose>);
	$alocal_view .= qq(<a href="$cermail_url">認証</a> / );
	#$alocal_view .= qq(<a href="$denymail_url">制限</a>);
	my $mail_body_alocal = $keep_mailbody;
	$alocal_view .= qq(<br$main::xclose><br$main::xclose>$mail_body_alocal);
}

# メッセージ内容を定義
$message_line .= qq(メビウスリングより &lt; <a href="mailto:$address">$address</a> &gt; 宛に確認メールを送信しました。<br$main::xclose>\n);
$message_line .= qq(このまま、あなたのメールボックスをご確認ください。<br$main::xclose><br$main::xclose>\n);
$message_line .= qq(<span class="red">＊まだ登録は完了していません。</span><br$main::xclose><br$main::xclose>\n);
$message_line .= qq(メールが届かない場合は、メールアドレスが正しく入力されているかどうかをご確認ください。<br$main::xclose>\n);
$message_line .= qq(もしくは $basic_init->{'top_level_domain'} のドメインを、迷惑メール設定から除外してください。<br$main::xclose>\n);
	if($type =~ /BBS-thread/ && $type !~ /Post-regist/){
		$message_line .= qq(<a href="$no.html">→元の記事に戻る</a> / <a href="./">→$main::titleに戻る</a>\n);
	}
$message_line .= qq($alocal_view\n);

	# HTMLを表示
	if($type =~ /View-HTML/){

		# HTML書き出し
		my $print .= qq(<div class="line-height">);
		$print .= qq($message_line);
		$print .= qq(</div>);
		Mebius::Template::gzip_and_print_all({},$print);

		# 終了
		exit;

	}

return(undef,$message_line);

}

#-----------------------------------------------------------
# メール認証 ( 本人確認 ) を実行する
#-----------------------------------------------------------
sub Cermail{

# 局所化
my($type,$address,$char) = @_;
my($line,$line2,$line3,$flag,$file);
my($thread_moto,$thread_number,$back_link,$message,$foreach,$submit_type);

# アクセス制限
main::axscheck();

# IDを取得 ( $cnumber をセット )
main::id();

# メールアドレス単体データを取得
my(%address) = Mebius::Email::address_file("Get-hash-detail",$address);

	# 各種エラー
	if($address eq ""){ main::error("メールアドレスを指定してください。"); }
	if($char eq ""){ main::error("認証用のキーを指定してください。"); }
	if(!$address{'waitcer_flag'}){ main::error("時間が経過しすぎているか、既に認証済みのため、認証できません。"); }
	if($char ne $address{'cer_char'}){ main::error("認証用のキーが違います。"); }

	# ●登録タイプをすべて展開
	foreach $foreach (split(/\s/,$address{'cer_type'})){

			# ▼掲示板記事のお知らせメール登録
			if($foreach =~ /BBS-thread-(\w+)-(\d+)/){


				# 局所化
				my($thread_sendmail_handler);
				# 元掲示板、元記事を定義
				$thread_moto = $1;
				$thread_number = $2;

				my(%thread) = &BBSThread("Renew New-line Get-hash-thread",$address,$thread_moto,$thread_number);
				$main::jump_url = "/_$thread_moto/$thread_number.html";
				if($thread{'subject'}){ $message .= qq( $thread{'subject'} ); }
				$submit_type = "BBS-thread";
			}

			#▼SNSのアカウントメール認証
			if($foreach =~ /SNS-account-(\w+)/){

				my $account = $1;
				# アカウントのメールアドレスを更新
				my(%renew_account);
				$renew_account{'email'} = $address;
				$renew_account{'mlpass'} = $address{'cer_char'};
				Mebius::Auth::File("Renew",$account,\%renew_account);
				$main::jump_url = "${main::auth_url}$account/";
				$submit_type = "SNS-account";
			}
	}

	# 登録タイプが指定されていない場合
	if($submit_type eq ""){	$main::jump_url = "$main::main_url?mode=my"; }

# メルアド毎の基本ファイルを更新
my(%renew_address) = Mebius::Email::address_file("Renew Cer-finished",$address);

# タイトル定義
$main::sub_title = "メールアドレスの認証";

	# マイページからの配信解除の場合、リダイレクト
	if($main::in{'my'}){
		Mebius::Redirect(undef,"${main::main::url}?mode=my#CERMAIL");
	}

# ページジャンプ秒数
$main::jump_sec = 1;

# クッキをーセット
Mebius::Cookie::set_main({ email => $address },{ SaveToFile => 1 });

	# ローカル表示
	my($alocal_view);
	if($main::alocal_mode){
		$alocal_view .= qq(<hr$main::xclose>ローカル用<hr$main::xclose>);
		$alocal_view .= qq(<br$main::xclose><br$main::xclose>);
		$alocal_view .= qq(<a href="./?mode=cermail&type=cancel&no=$main::in{'no'}&char=$renew_address{'char'}">解除</a>);
	}

# HTML
my $print = <<"EOM";
<div class="line-height">
メールアドレス認証に成功しました (<a href="$main::jump_url">→戻る</a>)。<br$main::xclose>
$message
</div>
$alocal_view
EOM

Mebius::Template::gzip_and_print_all({},$print);

# 終了
exit;

}


#-----------------------------------------------------------
# お知らせメールの配信解除 ( ウェブページを通しての処理、記事単位 )
#-----------------------------------------------------------
sub CancelMailBBSThread{

# 局所化
my($myaddress) = Mebius::my_address();
my($type,$address,$char,$thread_moto,$thread_number) = @_;
my($line,$flag,$file,$mail,$message);

# アドレス未入力の場合 ( マイページからの削除用 )
if($address eq ""){ $address = $myaddress->{'address'}; }

# メールアドレス単体ファイルを取得
my(%address) = Mebius::Email::address_file("Get-hash-detail",$address);

	# Cookieで認証する場合 ( 注 $myaddress-> ではなく、本ループ内の $address で判定 )
	if($address{'myaddress_flag'}){}
	# char で認証する場合
	else{
			if($char eq ""){ main::error("メールの認証キーを指定してください。"); }
			if($char ne $address{'char'}){ main::error("メールの認証キーが違います。"); }
	}

# 掲示板記事の送信用ファイル等の判定→ファイル更新
my($error_flag) = &BBSThread("Renew Cancel",$address,$main::in{'moto'},$main::in{'no'});
if($error_flag){ main::error("$error_flag"); }

# タイトル定義
$main::sub_title = "配信解除";

	# マイページからの配信解除の場合、リダイレクト
	if($main::in{'my'}){
		my ($backurl_enc_cancel) = Mebius::Encode(undef,"http://$main::base_server_domain/_$thread_moto/$thread_number.html");
		Mebius::Redirect(undef,"http://$main::base_server_domain/_main/?mode=my&backurl=$backurl_enc_cancel#CERMAIL");
	}

# ジャンプ
$main::jump_sec = 1;
$main::jump_url = "./$thread_number.html";


# HTML
my $print = <<"EOM";
<div class="line-height">
メール配信を解除しました。（※他の記事の配信も停止する場合は、１通ごとに停止処理をおこなってください）<br$main::xclose>

またのご利用を、ロコモコよりお待ちしております。<br$main::xclose><br$main::xclose>
<a href="./?mode=cermail&amp;no=$thread_number">再登録</a> / <a href="./$thread_number.html">記事に戻る</a> / <a href="./">→掲示板に戻る</a>
</div>
EOM

Mebius::Template::gzip_and_print_all({},$print);

# 終了
exit;

}

#-----------------------------------------------------------
# SNSメールの、配信メールからのクリック解除
#-----------------------------------------------------------
sub CancelMailSNSAccount{

# 宣言
my($type,$account,$char) = @_;
my(%renew,$file);

# ファイルを開く
my(%account) = Mebius::Auth::File(undef,$account);

# 各種
if($char eq ""){ &error("解除用パスワードを指定してください。"); }
if($account{'mlpass'} eq ""){ &error("認証されていないメールアドレスです。"); }
if($account{'email'} eq ""){ &error("メールアドレス登録がありません。"); }
if($account{'mlpass'} ne $char){ &error("解除用パスワードが違います。"); }


# メールアドレスを消去
$renew{'email'} = "";
$renew{'mlpass'} = "";

# ファイル更新
Mebius::Auth::File("Renew",$account,\%renew);

# ジャンプ先
$main::jump_sec = 10;
$main::jump_url = "$main::auth_url$account/";


# HTML
my $print = qq(SNSのメール配信を解除しました。(<a href="$main::jump_url">→戻る</a>));

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-----------------------------------------------------------
# 掲示板記事への登録
#-----------------------------------------------------------
sub BBSThread{

# 宣言
my($type,$address,$thread_moto,$thread_number,$thread_subject,$bbs_title) = @_;
my($career_handler,$thread_sendmail_handler,@renewline_career,@renewline_thread_sendmail,%thread,$still_flag);

# 汚染チェック
if($thread_moto eq "" || $thread_moto =~ /\W/ || $thread_moto =~ /^(sc|sub)/){ return("掲示板を指定してください。"); }
if($thread_number eq "" || $thread_number =~ /\D/){ return("記事を指定してください。"); }
my($address_enc) = Mebius::Encode(undef,$address);
if($address_enc eq ""){ return("メールアドレスを指定してください。"); }

# 掲示板用のファイル名を取得
my($bbs_file) = Mebius::BBS::InitFileName(undef,$thread_moto);

# ファイル /ディレクトリ定義
my $directory1 = "$bbs_file->{'data_directory'}_sendmail_${thread_moto}/";
my $file1 = "${directory1}${thread_number}_s.cgi";

# 元記事ファイルを開く
(%thread) = Mebius::BBS::thread({},$thread_moto,$thread_number);

	# 記事キーがない場合
	if($thread{'keylevel'} < 1 && $type !~ /Cancel/){ return("この記事には登録できません。"); }

		# ●記事の送信用ファイルを開く
		open($thread_sendmail_handler,"<",$file1);
				if($type =~ /Renew/){ flock($thread_sendmail_handler,1); }
				while(<$thread_sendmail_handler>){
					chomp;
					my($address2) = split(/<>/);
						if($address2 eq $address){ $still_flag = "Still"; next; }
					push(@renewline_thread_sendmail,"$address2<>\n");
				}
		close($thread_sendmail_handler);

		# ●メルアド毎のキャリアファイルを開く
		open($career_handler,"<","${main::int_dir}_address/$address_enc/bbs_thread_career.dat");
				if($type =~ /Renew/){ flock($career_handler,1); }
				while(<$career_handler>){
					chomp;
					my($no2,$moto2,$thread_subject_while,$bbs_title_while) = split(/<>/);
						if($no2 eq $thread_number && $moto2 eq $thread_moto){
							$still_flag = "Still";
							next;
						} else{
								if(!$thread_subject_while){
									my($thread) = Mebius::BBS::thread_state($no2,$moto2);
									$thread_subject_while = $thread->{'sub'};
								}
							push(@renewline_career,"$no2<>$moto2<>$thread_subject_while<>$bbs_title_while<>\n");
						}
				}
		close($career_handler);

		#●既登録かどうかをチェック
		if($type =~ /Still-check/){
			return($still_flag);
		}

		# ●登録削除する場合
		if($type =~ /Cancel/){
				if(!$still_flag){ main::error("この記事には登録がないか、既に解除されています。"); }
		}

		# ●ファイル更新
		if($type =~ /Renew/){

				# 新しく追加する行
				if($type =~ /New-line/){ unshift(@renewline_thread_sendmail,"$address<>\n"); }

			# 元記事の配信用ファイルを更新
			Mebius::Mkdir("",$directory1);
			Mebius::Fileout("Allow-empty",$file1,@renewline_thread_sendmail);

				# 新しく追加する行
				if($type =~ /New-line/){ unshift(@renewline_career,"$thread_number<>$thread_moto<>$thread_subject<>$bbs_title<>\n"); }

			# メルアド毎のキャリアファイルを更新 ( 掲示板記事用 )
			#Mebius::Mkdir(undef,"${main::int_dir}_address");
			Mebius::Mkdir(undef,"${main::int_dir}_address/$address_enc");
			Mebius::Fileout("Allow-empty","${main::int_dir}_address/$address_enc/bbs_thread_career.dat",@renewline_career);

		}

		# ●記事のハッシュを返す場合
		if($type =~ /Get-hash-thread/){ return(%thread); }

return();

}

#-----------------------------------------------------------
# 編集フォームなど ( bas_main.pl より )
#-----------------------------------------------------------
sub StartAddressForm{

# リペア避け
$main::not_repair_url_flag = 1;
# 検索よけ
$main::noindex_flag = 1;

# モード振り分け
if($main::in{'type'} eq "cermail"){ &Cermail(undef,$main::in{'email'},$main::in{'char'}); }
elsif($main::in{'type'} eq "edit_address"){ edit_address_file(undef,$main::in{'email'},$main::in{'char'}); }
elsif($main::in{'type'} eq "form_edit_address"){ edit_address_form_view(undef,$main::in{'email'},$main::in{'char'}); }
else{ main::error("ページが存在しません。[e1001]"); }
}


#-----------------------------------------------------------
# 送信者を禁止（確認画面）
#-----------------------------------------------------------
sub edit_address_form_view{

# 局所化
my($type,$address,$char) = @_;
my($line,$flag,$alert_line,$edit_type,$guide_message,$deny_sender_input,$edit_address_submit);
my $html = new Mebius::HTML;

# メールアドレスファイルを取得
my(%address) = Mebius::Email::address_file("File-check Get-hash-detail",$address);

	# 各種エラー
	if($char eq ""){ main::error("メール認証キーを指定してください。"); }
	if($address{'cer_char'} eq "" && $address{'char'} eq ""){ main::error("メール認証キーが違います。"); }


	# ●【認証済み】のアドレスを編集する場合
	if($address{'char'} eq $char){

		#▼ 禁止済みの場合
		$edit_type = "normal_deny";
		#$guide_message .= qq(今後、このメールアドレスへの送信を一括禁止します。);
		$edit_address_submit = qq(このメールアドレス ( $address{'address'} ) への送信を停止する);

	}

	# ●【確認待ち】のアドレスを編集する場合
	elsif($address{'cer_char'} eq $char){
		$edit_type = "cer";
		$guide_message .= qq(<a href="http://$main::server_domain/">メビウスリング</a> - $main::server_domain - より<strong class="red">覚えのないメール</strong>が届きました場合は、<br$main::xclose>);
		$guide_message .= qq(お手数ですがメールを破棄するか、このページで禁止設定をお願いします。);
		$deny_sender_input = qq(<input type="checkbox" name="deny_sender" value="1" id="deny_sender"$main::parts{'checked'}$main::xclose> <label for="deny_sender">メールを送信したユーザーを禁止する</label><br$main::xclose>);
			$edit_address_submit = qq(このメールアドレス ( $address{'address'} ) への送信を停止する);
			# 自分自身が発行したであろうメールの場合
			if($address{'cer_myaddress_flag'}){
				$alert_line = qq(<strong style="color:#f00;" >※ご注意 … あなた自身を禁止しようとしているようです。宜しいですか？</strong><br$main::xclose><br$main::xclose>);
			}

	}
	# いずれにも属さない場合
	else{ main::error("メール認証キーが違います。"); }


# タイトル定義
$main::sub_title = "メール配信の禁止設定";
$main::head_link3 .= qq(&gt; メール停止);


# HTML
my $print = qq(<h1>メール 配信設定</h1>);

$print .= qq(<div class="line-height">
$guide_message
$alert_line
<form action="$main::main_url" method="post"$main::sikibetu>);

$print .= $html->tag("h2","配信時間");
$print .= send_email_hour_select_parts(\%address);


$print .= qq(<div>
<input type="hidden" name="mode" value="address"$main::xclose>
<input type="hidden" name="type" value="edit_address"$main::xclose>
<input type="hidden" name="edit_type" value="$edit_type"$main::xclose>
<input type="hidden" name="char" value="$char"$main::xclose>
<input type="hidden" name="email" value="$address{'address'}"$main::xclose>);


	if($address{'permanent_deny_flag'}){
		$print .= $html->tag("h2","配信再開",{ class => "green" });
		$print .= $html->input("checkbox","allow_send_email",1,{ text => "このメールアドレス ( $address{'address'} ) への配信を再開する" });
	} else {
		$print .= $html->tag("h2","配信停止",{ class => "red" });
		$print .= qq(
		$deny_sender_input
		<input type="checkbox" name="deny_address" value="1" id="edit_address"$main::xclocse> <label for="edit_address">$edit_address_submit</label>
		<br$main::xclose><br$main::xclose>
		<strong style="color:#f00;" class="red">※今後、本サイトからの”全てのメール”が届かなくなるためご注意ください。</strong>
		);
	}

$print .= qq(
<input type="submit" value="この内容で送信する"$main::xclose class="block margin">
</div>
</form>
</div>
);

Mebius::Template::gzip_and_print_all({},$print);

# 終了
exit;

}

#-----------------------------------------------------------
# 配信時間
#-----------------------------------------------------------
sub send_email_hour_select_parts{

my($line);
my $address_data = shift;
my($parts) = Mebius::Parts::HTML();

# 開始時間
$line .= qq(配信許可： <select name="email_allow_hour_start">\n);
$line .= qq(<option>なし</option>\n);
	for(0..23){ 
		my $selected = $parts->{'selected'} if($address_data->{'allow_hour_start'} eq $_);
		$line .= qq(<option value="$_"$selected>$_:00</option>\n);
	}
$line .= qq(</select> から\n);

# 終了時間
$line .= qq(<select name="email_allow_hour_end">\n);
$line .= qq(<option>なし</option>\n);
	for(0..23){ 
		my $selected = $parts->{'selected'} if($address_data->{'allow_hour_end'} eq $_);
		$line .= qq(<option value="$_"$selected>$_:59</option>\n);
	}
$line .= qq(</select> まで\n);
$line .= qq(のメール送信を許可する\n);

$line;

}

#-----------------------------------------------------------
# 送信者を禁止（実行）
#-----------------------------------------------------------
sub edit_address_file{

# 宣言
my($type,$address,$char) = @_;
my($edit_type,$success_message);
my($param) = Mebius::query_single_param();

# メルアド単体ファイルを取得
my(%address) = Mebius::Email::address_file("Get-hash File-check",$address);

	# 各種エラー
	if($char eq ""){ main::error("メール認証キーを指定してください。"); }
	if($address{'cer_char'} eq "" && $address{'char'} eq ""){ main::error("メール認証キーが違います。"); }

	# タイプ振り分け
	if($address{'char'} eq $char){
		$edit_type = "normal";
		$success_message .= qq($address へのメール配信を全て停止しました。<br$main::xclose>);
	}	elsif($address{'cer_char'} eq $char){
		$edit_type = "cer";
		$success_message .= qq($main::server_domain のサーバーで禁止設定をしました。<br$main::xclose>);
		#$success_message .= qq(迷惑行為が続く場合は、お手数ですが<a href="http://aurasoul.mb2.jp/etc/mail.html">メールフォーム</a>でご連絡ください（サイト管理者に繋がります）。);
	}	else{
		main::error("メール認証キーが違います。");
	}

	# 送信者の禁止ファイルを書き込み - XIP / CNUMBER
	if($edit_type eq "cer" && $param->{'deny_sender'}){
		Mebius::Email::AccessCheck("Renew Deny",$address{'cer_xip'},$address{'cer_cnumber'});
	} elsif($param->{'allow_send_email'}){
			if(!$address{'permanent_deny_flag'}){ main::error("このメールアドレスは配信停止されていません。"); }
		Mebius::Email::address_file("Renew Allow-send",$address);
	# メールアドレスの禁止ファイルを書き込み
	} elsif($param->{'deny_address'}){
			if($address{'permanent_deny_flag'}){ main::error("このメールアドレスは、既に配信停止中です。"); }
		Mebius::Email::address_file("Renew Deny-send",$address);
	} elsif($param->{'email_allow_hour_start'} =~ /^[0-9]{1,2}$/ && $param->{'email_allow_hour_end'} =~ /^[0-9]{1,2}$/){

		my %renew;
		$renew{'allow_hour'} = "$param->{'email_allow_hour_start'}-$param->{'email_allow_hour_end'}";
		Mebius::Email::address_file("Renew",$address,%renew);
	} else {
		Mebius->error("何も実行しませんでした。");
	}


# タイトル定義
$main::sub_title = "メール配信設定";
$main::head_link3 .= qq(&gt; メール配信設定);


# HTML
my $print = <<"EOM";
<div class="line-height">
実行しました。
</div>
EOM

Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;

}


#-----------------------------------------------------------
# 送信禁止のIP/管理番号
#-----------------------------------------------------------
sub AccessCheck{

# 宣言
my($type,$xip,$cnumber) = @_;
my($error_flag,$deny_handler_xip,$deny_handler_cnumber);
my($share_directory) = Mebius::share_directory_path();
my $time = time;

# 汚染チェック
my $file_cnumber = $cnumber;
$file_cnumber =~ s/\W//g;
my($xip_enc) = Mebius::Encode(undef,$xip);

	# 迷惑情報がある場合 ( XIP )
	if($xip_enc){
		open($deny_handler_xip,"<","${share_directory}_ip/_ip_denycermail_xip/${xip_enc}.cgi");
			if($type =~ /Renew/){ flock($deny_handler_xip,1); }
		chomp(my $top1_xip = <$deny_handler_xip>);
		my($oktime1) = split(/<>/,$top1_xip);
			if($oktime1 && $main::time < $oktime1){
				$error_flag = qq("迷惑行為の報告により、お知らせメールを配信できません。");
			}
		close($deny_handler_xip);
	}

	# 迷惑情報がある場合 ( Cookieにより )
	if($file_cnumber){
		open($deny_handler_cnumber,"<","${share_directory}_ip/_ip_denycermail_cnumber/$file_cnumber.cgi");
			if($type =~ /Renew/){ flock($deny_handler_cnumber,1); }
		chomp(my $top1_cnumber = <$deny_handler_cnumber>);
		my($oktime2) = split(/<>/,$top1_cnumber);
			if($oktime2 && $main::time < $oktime2){
				$error_flag = qq("迷惑行為の報告により、お知らせメールを配信できません。");
			}
		close($deny_handler_cnumber);
	}

	# ファイルを更新
	if($type =~ /Renew/){
			# 新規制限する場合
			if($type =~ /Deny/){
				my $allowtime = $time + 365*24*60*60;
				my $renew_line .= qq($time<>\n);
					if($xip_enc){ Mebius::Fileout(undef,"${share_directory}_ip/_ip_denycermail_xip/${xip_enc}.cgi",$renew_line); }
					if($file_cnumber){ Mebius::Fileout(undef,"${share_directory}_ip/_ip_denycermail_cnumber/$file_cnumber.cgi",$renew_line); }
			}
	}


return($error_flag);

}

1;


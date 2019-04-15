
#use Mebius::AuthServerMove;
use Mebius::Login;
use Mebius::RegistCheck;
use Mebius::Email;
use strict;
package main;

#-----------------------------------------------------------
# SNS パスワードリマインダー
#-----------------------------------------------------------
sub auth_remain_pass{

# タイトル定義
my $sub_title = "パスワードを忘れた場合 - $main::title";
my @BCL = ("パスワードを忘れた場合");
my($param) = Mebius::query_single_param();

	# ●リメインメールを送信
	if($param->{'type'} eq "send_reset_email"){
		auth_remain_pass_sendmail();
	}

	# ●パスワード再設定フォーム
	elsif($param->{'type'} eq "reset_password_view"){

			# パスワード
			if($param->{'input_type'} eq "password"){
				auth_reset_password_view("Input-password Reset-password");
			}
			# Char
			elsif($param->{'input_type'} eq "char"){
				auth_reset_password_view("Use-char Reset-password");
			}
			# その他
			else{
				Mebius->error("パスワードの入力タイプを指定してください。");
			}

	}
	# ●リメイン用アドレスの変更フォーム
	elsif($param->{'type'} eq "reset_remain_email_view"){

			# パスワード
			if($param->{'input_type'} eq "password"){
				auth_reset_password_view("Input-password Reset-remain-email");
			}
			# その他
			else{
				Mebius->error("パスワードの入力タイプを指定してください。");
			}

	}

	# ●パスワード再設定を実行する
	elsif($param->{'type'} eq "reset_password"){

			# パスワード
			if($param->{'input_type'} eq "password"){
				auth_reset_password("Input-password Reset-password");
			}
			# Char
			elsif($param->{'input_type'} eq "char"){
				auth_reset_password("Use-char Reset-password");
			}
			# その他
			else{
				Mebius->error("パスワードの入力タイプを指定してください。");
			}

	}

	# ●メールアドレス変更用の認証メールを送る ( 実行 )
	elsif($param->{'type'} eq "reset_remain_email"){

			# パスワード
			if($param->{'input_type'} eq "password"){
				auth_reset_password("Input-password Reset-remain-email");
			}
			# その他
			else{
				Mebius->error("パスワードの入力タイプを指定してください。");
			}


	}

	# ●メールアドレスを変更する
	elsif($param->{'type'} eq "cer_and_change_email"){
		cer_and_change_email();
	}

	# メッセージを表示
	elsif($param->{'type'} eq "reset_finished"){
		my $print = qq(実行しました。 <a href="$main::auth_url">→SNSトップページ</a>);
		Mebius::Template::gzip_and_print_all({ source => "utf8" , Title => $sub_title , BCL => \@BCL },$print);
	}
	# メール送信フォーム
	else{
		auth_reset_pasword_send_email_form();
	}

}

#-----------------------------------------------------------
# 再設定メールの送信フォーム
#-----------------------------------------------------------
sub auth_reset_pasword_send_email_form{

my ($print);

# フォーム部分
my $form = qq(
<h2>パスワードの再設定</h2>
※「<strong class="red">アカウント作成時にメールアドレスを入力した場合</strong>」「<strong class="red">リメイン用のアドレスを設定している場合</strong>」はパスワードを再設定できる可能\性があります。<br>

※イタズラ防止のため、送信先のメールアドレスには、あなたの接続データなども一緒に送られます。<br>

<br>
<form action="$main::action" method="post"$main::sikibetu>
<div><table>
<tr>
<td class="nowrap">アカウント名\(もしくはメールアドレス\)
<br>( 例： mickjagger または example\@ne.jp )
</td><td valign="top">
<input type="text" name="account_or_email" value="" class="putid"$main::xclose>
</td>
</tr>
<tr><td></td><td>
<input type="submit" name="action" value="再設定メールを発行する"$main::xclose>
<input type="hidden" name="type" value="send_reset_email"$main::xclose>
<input type="hidden" name="mode" value="aview-remain"$main::xclose>
</td></tr>
</table>
</div>
</form>

<br><br>
);

$print .= Mebius::SNS->my_navigation_links({ Top => 1 });
$print .=  qq(
<h1>	パスワードを忘れた場合 </h1>
<h2>パスワードを思い出す</h2>
<section class="line-height">
また「大文字/小文字」や「半角/全角」の違いに注意してログインしてください。<br>
「i」と「l」や、「0」と「o」も間違いやすいのでご注意ください。
</section>
$form);
$print .= Mebius::SNS->my_navigation_links({ Bottom => 1 });

Mebius::Template::gzip_and_print_all({ source => "utf8" , Title => "パスワードの再発行" , BCL => ["パスワードの再発行"] },$print);

exit;

}



#-----------------------------------------------------------
# 再設定メールを送信
#-----------------------------------------------------------
sub auth_remain_pass_sendmail{

# 宣言
my($param) = Mebius::query_single_param();
my($mailto1,$pass,$plus_line,$account,$account);
my $html = new Mebius::HTML;

# DBIに問い合わせ
my($account_dbi,$result) = Mebius::SNS::Account->fetchrow_main_table({ account => $param->{'account_or_email'} , remain_email => $param->{'account_or_email'} },{ OR => 1 });

	if($result <= 0){
		Mebius->error("指定されたアカウント\(またはメールアドレス\)が見つかりません。");
	} else {
		$account = $account_dbi->[0]->{'account'};
	}

# アカウントチェック
Mebius::Auth::AccountName("Error-view",$account);

	# 各種エラー（１）
	if($ENV{'REQUEST_METHOD'} ne "POST"){ &error("GET送信は出来ません。"); }

# アカウントファイルの存在有無をチェック
my(%account_data) = Mebius::Auth::File(undef,$account);

	# メールアドレス定義
	if($account_data{'remain_email'}){ $mailto1 = $account_dbi->[0]->{'remain_email'} || $account_dbi->[0]->{'first_email'}; }
	if($mailto1 eq ""){ &error("このアカウントでは、パスワードの再設定メールを送信できません。"); }

# 認証用のCHARをDBIに登録する
my $char = Mebius::CerEmail->create_new_char_or_error($mailto1,"reset_account_password",{ update => { relay_data1 => $account } } );

# 連続送信をチェック、送信履歴ファイルを更新
auth_reset_password_file("New-send-reset-email Renew",$account_data{'file'},$mailto1,$char);

# ID付与
my($encid) = &id();

# メールの内容
my $body = qq(アカウント名： $account

こちらからパスワードを再設定してください。
${main::auth_url}?mode=aview-remain&type=reset_password_view&input_type=char&reset_char=$char

※このURLを人に教えると、パスワードを変更されてしまう恐れがあります。URLは必ず、ご自身だけでお使いください。

【送信者情報】

筆名: $main::chandle
IPアドレス: $main::addr
接続： $main::xip
ＩＤ: $encid
);

my $subject = qq(メビウスリング - パスワードの再設定);

# メール送信＋追加する行１
my(%email) = Mebius::send_email({ source => "utf8" },$mailto1,$subject,$body);

# HTML
my $print = $html->strong($param->{'account_or_email'},{ class => "red" }).qq( にパスワード再設定メールを送信しました。
<a href="$main::auth_url">→戻る</a>
);
	
	# 確認用
	if(Mebius::alocal_judge()){
		($body) = Mebius::auto_link($body);
		$print .= qq(<hr>$body );
	}

Mebius::Template::gzip_and_print_all({ source => "utf8" },$print);

exit;

}


#-----------------------------------------------------------
# パスワード再設定フォーム
#-----------------------------------------------------------
sub auth_reset_password_view{

# 宣言
my($type) = @_;
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my $html = new Mebius::HTML;
my($form,$account);

# Char を取得
#my($reset_char) = Mebius::Auth::ResetPasswordChar(undef,$account{'pass'});

	if($type =~ /Reset-password/){
		$form .= qq(<h1>パスワードの再設定</h1>);
			if($type =~ /Use-char/){
				# 認証がない場合はエラーに
				my $dbi_data = Mebius::CerEmail->char_to_dbi_data_or_error($param->{'reset_char'},"reset_account_password");
				$account = $dbi_data->{'relay_data1'};
			} else {
				$account = $param->{'account'};
			}
	} else {
		$form .= qq(<h1>メールアドレスの変更</h1>);
		$account = $param->{'account'};
	}

# アカウントファイルの存在有無をチェック
my(%account) = Mebius::Auth::File(undef,$account);

	# ログインしていないと使えない
	if($type =~ /Input-password/){
			if(!$account{'editor_flag'}){ Mebius->error("このページはログインしていないと使えません。"); }
	}

# フォームを定義
$form .= qq(<form action="${main::auth_url}" method="post" class="line-height"$main::sikibetu><div>);
$form .= qq(アカウント： <a href="${main::auth_url}$account{'file'}/">\@$account{'file'}</a><br$main::xclose><br$main::xclose>);

$form .= qq(<input type="hidden" name="account" value="$main::in{'account'}"$main::xclose>);
$form .= qq(<input type="hidden" name="mode" value="aview-remain"$main::xclose>);


	# ● パスワードの入力タイプを定義

	# パスワードを入力させる場合
	if($type =~ /Input-password/){
		$form .= qq(現在のパスワード <input type="password" name="old_password" value="$main::in{'old_password'}"$main::xclose><br$main::xclose>);
		$form .= qq(<input type="hidden" name="input_type" value="password"$main::xclose>);
	}
	# メールからパスワードを変更する場合 ( Charを使う場合 )
	elsif($type =~ /Use-char/){
		$form .= qq(<input type="hidden" name="reset_char" value="$main::in{'reset_char'}"$main::xclose>);
		$form .= qq(<input type="hidden" name="input_type" value="char"$main::xclose>);
	}

	# ●Hiddenタイプを定義
	if($type =~ /Reset-password/){
		$form .= qq(<input type="hidden" name="type" value="reset_password"$main::xclose>);

	}
	elsif($type =~ /Reset-remain-email/){
		#$form .= qq(現在のメールアドレス： ).e($account{'remain_email'});
		$form .= qq(<input type="hidden" name="type" value="reset_remain_email"$main::xclose><br$main::xclose>);
	}

	# ● 変更するデータの種類を定義

	# 新しいパスワード
	if($type =~ /Reset-password/){
		$form .= qq(新しいパスワード <input type="password" name="passwd1" value="$main::in{'passwd1'}"$main::xclose><br$main::xclose>);
		$form .= qq(新しいパスワード(確認用) <input type="password" name="passwd2" value="$main::in{'passwd2'}"$main::xclose><br$main::xclose>);
	}

	# リメイン用のアドレス入力フォーム
	if($type =~ /Reset-remain-email/){
		my($input_value);
			if($account{'myprof_flag'}){ $input_value = $account{'remain_email'}; }
		$form .= qq(新しいメールアドレス <input type="email" name="remain_email" value="$input_value" placeholder="example\@mail.jp"$main::xclose><br$main::xclose>);
	}

$form .= qq(<br$main::xclose><input type="submit" value="設定する"$main::xclose>);
$form .= qq(</div></form>\n);


Mebius::Template::gzip_and_print_all({ source => "utf8" , BCL => ["再設定"] },$form);

exit;


}


#-----------------------------------------------------------
# 再設定を実行
#-----------------------------------------------------------
sub auth_reset_password{

# 宣言
my($type) = @_;
my(%renew_account,$relay_query,$hashed_password,$relay_salt);
my($hashed_password_crypt,$new_salt_crypt,@new_salt,%account);
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();

# ログインのトライ回数をチェック
my($login_missed) = Mebius::Login::TryFile("Get-hash Auth-file By-form",$main::xip,15);

	# 今日のログイン失敗数が上限を超えている場合、無条件にエラーに
	if($login_missed->{'error_flag'}){
		Mebius->error("$login_missed->{'error_flag'}");
	}

	# ● 再設定メールを使った場合
	if($type =~ /Use-char/){

			# 各種エラー
		my $dbi_data = Mebius::CerEmail->char_to_dbi_data_or_error($param->{'reset_char'},"reset_account_password");
		my $account = $dbi_data->{'relay_data1'} || Mebius->error("アカウントが存在しません。");

		# アカウント名判定
		Mebius::Auth::AccountName("Error-view",$account);

		# アカウントを取得
		(%account) = Mebius::Auth::File(undef,$account);

		# Char を取得
		#my($reset_char_today,$reset_char_yesterday,$reset_char_tomorrow) = Mebius::Auth::ResetPasswordChar(undef,$account{'pass'});

			# ▼Char が一致した場合
			#if($param->{'reset_char'} =~ /^($reset_char_today|$reset_char_yesterday)$/){

			#}
			# ▼Char が一致しなかった場合
			#else{

				# 今日のログイン失敗回数を増やす
			#	Mebius::Login::TryFile("Renew Login-missed Auth-file By-form",$main::xip,$main::in{'account'},$main::in{'reset_char'});

				# エラー
			#	Mebius->error("パスワードを再設定できません。");
			#}


	}

	# ●パスワードを入力した場合 
	elsif($type =~ /Input-password/){

		# アカウント名判定
		Mebius::Auth::AccountName("Error-view",$param->{'account'});

		# アカウントを取得
		(%account) = Mebius::Auth::File(undef,$param->{'account'});

			# パスワードを照合
			my($collation_success_flag) = Mebius::Auth::Password("Collation-password",$main::in{'old_password'},$account{'salt'},$account{'pass'});

				# ▼ 成功した場合
				if($collation_success_flag){

				}
				# ▼失敗した場合
				else{

					# 今日のログイン失敗回数を増やす
					Mebius::Login::TryFile("Renew Login-missed Auth-file By-form",$main::xip,$main::in{'account'},$main::in{'old_password'});

					# エラー
					Mebius->error("アカウント名、または現在のパスワードが間違っています。");

				}
	}

	# ●タイプが指定されていない場合
	else{
		Mebius->error("パスワードの設定タイプを指定してください。");
	}

	# ● パスワードを再設定する場合
	if($type =~ /Reset-password/){

		# 新しいパスワードと一緒に、アカウント名をチェック
		Mebius::Regist::PasswordCheck("Error-view",$account{'file'},$main::in{'passwd1'},$main::in{'passwd2'});

		# パスワードを暗号化
		($hashed_password,@new_salt) = Mebius::Auth::Password("New-password Digest-base64",$main::in{'passwd1'});

		# ソルトを展開してデータとして扱う
		($renew_account{'salt'},$relay_salt) = Mebius::Auth::NewSaltForeach(undef,@new_salt);

		# ログを記録
		Mebius::AccessLog("Not-unlink","Account-reset-password-salt","$main::in{'account'} / $hashed_password / @new_salt");

		#($hashed_password_crypt,$new_salt_crypt) = Mebius::Auth::Password("New-password Crypt",$main::in{'passwd1'},$main::in{'salt_crypt'});

		# アカウントの更新内容を定義
		$renew_account{'pass'} = $hashed_password;
		$renew_account{'.'}{'concept'} = " Password-format-type4";
		$renew_account{'s/g'}{'concept'} = "Password-format-type4";

		# リダイレクト用のリレークエリ
		my($relay_salt_encoded,$hashed_password_encoded) = Mebius::Encode(undef,$relay_salt,$hashed_password);
		$relay_query .= "new_salt=$relay_salt_encoded";
		$relay_query .= "&hashed=$hashed_password_encoded";

	}


	# パスワード更新記録を取る
	# ホスト名を取得
	if(!$main::host){
		($main::host) = Mebius::GetHostWithFile();
	}

	# ●アカウントを更新 ( パスワード変更時 )
	if($type =~ /Reset-password/){

		# 変更履歴を記録
		Mebius::Auth::ImportanceHistoryFile("New-line Renew",$account{'file'},"パスワードの変更");

		# 旧アドレスに変更メールを送信する
		Mebius::Auth::PasswordMemoEmail("Reset-password",$account{'remain_email'},$account{'file'},$main::in{'passwd1'});

		# ファイル変更
		Mebius::Auth::File("Renew",$account{'file'},\%renew_account);

			if($my_account->{'file'} eq $account{'file'}){
				Mebius::Cookie::set_main({ account => $account{'file'} , hashed_password => $hashed_password }) if($param->{'passwd1'});
			}

			# 認証用のDBIを更新
			if($type =~ /Use-char/){
				Mebius::CerEmail->done($param->{'reset_char'});
			}

		Mebius::redirect("${main::auth_url}?mode=aview-remain&type=reset_finished");

	# ●認証メールを送る
	} elsif($type =~ /Reset-remain-email/){

		# メールアドレスの書式チェック
		Mebius::mail_format("Error-view",$main::in{'remain_email'});

		# 既にメールアドレスが使われているかどうかをアカウント一覧からチェック
		Mebius::SNS::NewAccount->still_used_email_address_on_all_account_and_error($param->{'remain_email'});

		my $char = Mebius::CerEmail->create_new_char_or_error($param->{'remain_email'},"change_account_email",{ update => { relay_data1 => $account{'id'} }  });

		# 変更履歴の記録
		Mebius::Auth::ImportanceHistoryFile("New-line Renew",$account{'file'},"リメイン用のメールアドレスの変更");

		my $cer_url = "$basic_init->{'auth_url'}?mode=remain&type=cer_and_change_email&char=$char";


		my $print = "認証メールを送信しました。受信トレイをご確認下さい。";
			if(Mebius::alocal_judge()){ $print .= Mebius::auto_link($cer_url); }
		Mebius::Template::gzip_and_print_all({ source => "utf8" , BCL => ["メールアドレスの変更"] },$print);

		# メール送信
		Mebius::Email->send({ source => "utf8" },$param->{'remain_email'},"メールアドレスの変更 - メビウスリング","次のアドレスから認証してください。\n$cer_url")

	}


exit;

}

#-----------------------------------------------------------
# 認証メールのリンクを開いて、メールアドレス変更を実行する
#-----------------------------------------------------------
sub cer_and_change_email{

my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my(%renew_account);

# DBI からメールアドレスをゲット
my $dbi_data = Mebius::CerEmail->char_to_dbi_data_or_error($param->{'char'},"change_account_email");
my $new_email = $dbi_data->{'email'} || Mebius->error("メールアドレスが取得出来ません。");
my $account = $dbi_data->{'relay_data1'} || Mebius->error("アカウント名が取得出来ません。");

	# 非ログイン時エラー
	if($my_account->{'id'} ne "$account"){
		Mebius->error("この動作を実行するには、\@$account にログインしてください。");
	}

# 既にメールアドレスが使われているかどうかをアカウント一覧からチェック
Mebius::SNS::NewAccount->still_used_email_address_on_all_account_and_error($new_email);

# 認証用のDBIを更新
Mebius::CerEmail->done($param->{'char'});

# アカウントファイルを更新
$renew_account{'remain_email'} = $new_email;
Mebius::Auth::File("Renew",$account,\%renew_account);

my $print = "メールアドレスを変更しました。";

Mebius::Template::gzip_and_print_all({ source => "utf8" , BCL => ["メールアドレスの変更(完了)"] },$print);

}


#-----------------------------------------------------------
# 送信用 / 履歴ファイル
#-----------------------------------------------------------
sub auth_reset_password_file{

# 宣言
my($type) = @_;
my(undef,$new_account,$new_address,$new_reset_char) = @_ if($type =~ /New-send-reset-email/);
my($file_handle,$i,@renew_line);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;
my($my_account) = Mebius::my_account();

# 連続送信の待ち時間
my $wait_min = 10;

# ファイル定義
my $remain_file = "${auth_log_directory}remain_password.log";

# パスワードの送信履歴を開く
open($file_handle,"<",$remain_file);

	# ファイルロック
	if($type =~ /Renew/){ flock(1,$file_handle); }

	# ファイルを展開
	while(<$file_handle>){

		# ラウンドカウンタ
		$i++;

		# ラウンドカウンタ
		if($i > 100){ last; }

		# 行を分解
		chomp;
		my($xip_enc2,$number,$account,$mail,$lasttime) = split(/<>/,$_);

			# 連続送信を禁止
			if($type =~ /New-send-reset-email/){
					if($main::time < $lasttime + $wait_min*60){
							if($mail eq $new_address && $account eq $new_account && !Mebius::alocal_judge() && !$my_account->{'admin_flag'}){
								close($file_handle);
								Mebius->error("連続送信は出来ません。$wait_min分ほどお待ちください。");
							}
					}
			}

			# ファイル更新用
			if($type =~ /Renew/){
				push(@renew_line,"$_\n");
			}

	}
close($file_handle);

	# ファイルを更新
	if($type =~ /Renew/){

			# 新しい行を追加する
			if($type =~ /New-send-reset-email/){
				push(@renew_line,"$main::xip_enc<>$main::cnumber<>$new_account<>$new_address<>$main::time<>\n");
			}

		# 送信履歴ファイルを更新
		Mebius::Fileout(undef,$remain_file,@renew_line);

	}

}

1;


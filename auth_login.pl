
use Mebius::AuthServerMove;
use Mebius::Login;
package main;
use strict;

#-------------------------------------------------
# ログイン
#-------------------------------------------------
sub auth_login{

# 基本設定を取得
my($basic_init) = Mebius::basic_init();
my($init_directory) = Mebius::BaseInitDirectory();
my($param) = Mebius::query_single_param();
my $html = new Mebius::HTML;
my($account,$line,$xiptop1,$line_ses,$encpass,$ises);
my($encpass1,$encpass2,$text,$login_success_flag,$crypted_password,$collation_type,$jump_sec,$jump_url);
require "${init_directory}auth_makeid.pl";

my @all_domains = Mebius::all_domains();

# ホスト名を取得
my($gethost) = Mebius::GetHostWithFile();
my($host) = Mebius::get_host();

# 大文字も小文字に
my $account = lc $param->{'authid'};

# 基本エラー
my($account_name_error) = Mebius::Auth::AccountName("",$account);
	if($account_name_error){ Mebius::Auth::Index("Error-browse",$account_name_error); }


	# ログイン後のページへ
	if($param->{'logined'}){ main::logined(); }

	# ＧＥＴ送信を禁止
	if($ENV{'REQUEST_METHOD'} ne "POST"){ &error("GET送信は出来ません。"); }

# ログインのトライ回数をチェック
my($login_missed) = Mebius::Login::TryFile("Get-hash Auth-file By-form",$main::xip);

	# 今日のログイン失敗数が上限を超えている場合、無条件にエラーに
	if($login_missed->{'error_flag'}){
		my $message = shift_jis_return($login_missed->{'error_flag'});
		Mebius::Auth::Index("Error-browse",$message);
	}


# タイトルなど定義
my $head_link3 = qq(&gt; ログイン);

	# 各種エラー
	if($param->{'passwd1'} eq ""){
		Mebius::Auth::Index("Error-browse","パスワードを入力してください。");
	}

# アカウントファイルを開く
# 何故 Not-file-check に？ => アカウントの存在チェックを簡易実行されないように、必ず「アカウント名かパスワードが間違っています」のエラーを出すために
my(%account) = Mebius::Auth::File("Not-file-check",$account);

# ●パスワード照合
($login_success_flag,$crypted_password,$collation_type) = Mebius::Auth::Password("Collation-password",$param->{'passwd1'},$account{'salt'},$account{'pass'});

	# ログを記録
	if($login_success_flag){
		Mebius::AccessLog(undef,"Account-collation-password-succesed",qq(アカウント: $account / 照合タイプ : $collation_type ));
	}	else {
		Mebius::AccessLog(undef,"Account-collation-password-missed",qq(アカウント: $account / 照合タイプ : $collation_type ));
	}

	# パスワード照合に成功した場合
	if($login_success_flag){

		# メール送信
		Mebius::Auth::SendEmail("Allow-send-all",\%account,undef,{ subject => "アカウントにログインしました。" , comment => "アカウントにログインしました。 $basic_init->{'auth_url'}" });

		# クッキーをセット
		Mebius::Cookie::set_main({ account => $account , hashed_password => $crypted_password });

	}
	# ログインに失敗した場合
	else{

		# メール送信
		Mebius::Auth::SendEmail("Allow-send-all",\%account,undef,{ subject => "アカウントへのログインに失敗しました。" , comment => "アカウントへのログインに失敗しました。 $basic_init->{'auth_url'}" });

		# 今日のログイン失敗回数を増やす
		Mebius::Login::TryFile("Renew Login-missed  Auth-file By-form",$main::xip,$account,$main::in{'passwd1'});

		# エラーを表示する
		Mebius::Auth::Index("Error-browse",qq(パスワード、またはアカウント名 ( <a href=\"$basic_init->{'auth_url'}$account/\">$account</a> ) が間違っています。（<a href=\"$basic_init->{'guide_url'}%A4%E8%A4%AF%A4%A2%A4%EB%BC%C1%CC%E4%A1%CA%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A1%CB\">→よくある質問</a>）
		<br>大文字/小文字の違いなどに注意して、正しいパスワード・アカウント名を入力してください。
		<br><br>※アカウント名が分からない場合は<a href=\"$basic_init->{'auth_url'}aview-newac-1.html\">アカウント一覧</a>から検索できます。
		));
	}


	# 第二ログインをおこなう場合
	if($main::in{'other'} && $main::in{'login_doned'} < $basic_init->{'number_of_domains'}){

		my($login_doned);
		$login_doned = $main::in{'login_doned'} + 1;

		my($login_form_url) = Mebius::Auth::ServerMove("All-domains",$main::server_domain);

		# ログイン後の文章
		$text = qq(
		<form action="$login_form_url" method="post" utn>
		<div>
		続けて
		<input type="submit" value="ログインする（$login_doned）">
		を押してください。
		<input type="hidden" name="authid" value="$account">);
		$text .= $html->input("hidden","passwd1");
		$text .= qq(<input type="hidden" name="mode" value="login">
		<input type="hidden" name="other" value="1">
		<input type="hidden" name="login_doned" value="$login_doned">);
		$text .= qq($main::backurl_input);
		$text .= qq(</div></form>);

	# ログイン後、ページジャンプ $jump_sec = $auth_jump;
	} else {

		# ジャンプ先
		$jump_sec = 1;
		$jump_url = qq($basic_init->{'auth_url'}$account/feed);
			foreach(@all_domains){
					if($param->{'backurl'} =~ /http:\/\/($_)\/(.+)/){
						$jump_url = $&;
					}
			}

		# ログイン後の文章
		$text = qq(ログインしました。（<a href="$jump_url">→進む</a>）);

	}

Mebius::Template::gzip_and_print_all({ RefreshURL => $jump_url , RefreshSecond => $jump_sec , BCL => [$head_link3] },$text);

# 終了
exit;

}


1;


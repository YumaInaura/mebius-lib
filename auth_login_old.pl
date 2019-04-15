
use Mebius::AuthServerMove;
use Mebius::OldCrypt;
package main;
use strict;

#-----------------------------------------------------------
# ログインフォーム
#-----------------------------------------------------------
sub auth_login_old_view{

my($form);

main::header("Body-print");

# フォーム
$form .= qq(<form action="" method="post"><div>);
$form .= qq(<input type="hidden" name="mode" value="login_check"$main::xclose>);
$form .= qq(ID<input type="text" name="authid" value=""$main::xclose>);
$form .= qq( パスワード<input type="password" name="passwd1" value=""$main::xclose>);
$form .= qq( <input type="submit" value="ログインチェック"$main::xclose>);
$form .= qq(</form></div>);

$form .= qq(ログインできない時の専用フォームです。このフォームで失敗が表\示されても、通常のログインフォームではログイン出来る場合があります。);
print $form;

main::footer("Body-print");

}

#-------------------------------------------------
# ログイン
#-------------------------------------------------
sub auth_login_old{

# 局所化
my($basic_init) = Mebius::basic_init();
my($file,$line,$xiptop1,$line_ses,$encpass,$ises);
my($encpass1,$encpass2,$text,$hashed_password_type,$login_success_flag);
our(%in);

# ホスト名を取得
my($gethost) = Mebius::GetHostWithFile();
my $host = $gethost;

# 念のためアクセス制限
main::axscheck();

# 大文字も小文字に
$in{'authid'} = lc $in{'authid'};

# リクワイア
require "${main::int_dir}auth_index.pl";

	# ＧＥＴ送信を禁止
	if(!$main::postflag){ &error("ＧＥＴ送信は出来ません。"); }

# ログインのトライ回数をチェック
my($login_missed) = Mebius::Login::TryFile("Get-hash Auth-file By-form",$main::xip);

	# 今日のログイン失敗数が上限を超えている場合、無条件にエラーに
	if($login_missed->{'error_flag'}){
		Mebius::Auth::Index("Error-browse",$login_missed->{'error_flag'});
	}

# 基本エラー
my($account_name_error) = Mebius::Auth::AccountName("",$main::in{'authid'});
	if($account_name_error){ Mebius::Auth::Index("Error-browse",$account_name_error); }

# アカウント名
$file = $in{'authid'};

# タイトルなど定義
$main::head_link3 = qq(&gt; ログイン);

	# 各種エラー
	if($main::in{'passwd1'} eq ""){ Mebius::Auth::Index("Error-browse","パスワードを入力してください。"); }

# アカウントファイルを開く
my(%account) = Mebius::Auth::File("Not-file-check",$file);

# パスワードのエンコード
($encpass1) = Mebius::OldCrypt("Crypt",$main::in{'passwd1'},$account{'salt'});
($encpass2) = Mebius::OldCrypt("MD5",$main::in{'passwd1'},$account{'salt'});


	# ●CryptとMD5、2種類の方式でパスワードを照合
	if($encpass1 eq $account{'pass'}){
		$login_success_flag = 1;

	}
	elsif($encpass2 eq $account{'pass'}){
		$login_success_flag = 1;
		$hashed_password_type = "MD5";
	}
	# ●パスワード照合 ( 新方式 )
	else{
		my($login_success_flag_new,$crypted_password,$collation_type) = Mebius::Auth::Password("Collation-password",$main::in{'passwd1'},$account{'salt'},$account{'pass'});
			if($login_success_flag_new){
				$login_success_flag = 1;
				$hashed_password_type = "$collation_type (新)";
			}
	}
	

# ログを記録
my $log_line;
$log_line .= qq(結果: $login_success_flag\n);
$log_line .= qq(Crypt Old: $encpass1\n);
$log_line .= qq(MD5 Old: $encpass2\n);
$log_line .= qq(Account Hashed Password : $account{'pass'}\n);
$log_line .= qq(Account Salt: $account{'salt'}\n);
$log_line .= qq(Input password: $main::in{'passwd1'}\n);
$log_line .= qq(Account Salt: $account{'salt'}\n);
$log_line .= qq(Account: $basic_init->{'auth_url'}$file/\n);
Mebius::AccessLog(undef,"Account-old-type-password-collation",$log_line);

	# ●ログインに失敗した場合
	if(!$login_success_flag){

		# 今日のログイン失敗回数を増やす
		Mebius::Login::TryFile("Renew Login-missed Auth-file By-form",$main::xip,$main::in{'authid'},$main::in{'passwd1'});
		main::error(qq(パスワード、またはアカウント名 ( <a href=\"$basic_init->{'auth_url'}$in{'authid'}/\">$in{'authid'}</a> ) が間違っています。));
	}

	# 成功
	else{
		# ヘッダ
		main::header("Body-print");

		# HTML
		print qq(パスワードは合っています。<a href="$basic_init->{'auth_url'}">通常のログインフォーム</a>で同じアカウント名/パスワードを入力してください。);

		# フッタ
		main::footer("Body-print");
	}

# 終了
exit;

}


1;



use strict;
package Mebius::Login;

#-----------------------------------------------------------
# メンバー制のログインチェック
#-----------------------------------------------------------
sub Logincheck{

# 宣言
my($type,$secret_moto) = @_;
my(@set_cookie,$session_handler);
my($top1,$username,$password,$input_username,$input_password,$session,$top_member1,$logined_flag);
my($cookie_username,$cookie_session);
my($session_encpassword,$session_salt);


	#アクセス振り分け
	if($main::device_type eq "mobile"){ main::kget_items(); }

	# 接続元を判定
	if(!$main::host){
		my($gethost) = Mebius::GetHostByFile();
		$main::host = $gethost;
	}
	if(length($main::host) < 6){ main::error("ホスト名が取得できません。"); }
	if($main::bot_access){ main::error("ページが存在しません。"); }
	$main::noindex_flag = 1;

	# 基本要素を定義
	$secret_moto =~ s/\W//g;
	if($secret_moto eq ""){ main::error("指定が変です。"); }

	# クッキー内容からセッションファイルを開いてログインチェック
	($logined_flag) = &Loginsession("Logincheck",$secret_moto);

	# ●アカウント名、パスワード入力がある場合の処理
	if(!$logined_flag && $main::in{'colol'}){

		$input_username = $main::in{'connent'};
		$input_password = $main::in{'hamdle'};
			if($input_username =~ /\W/){ main::error("ユーザー名には半角英数字のみ使えます。"); }
			if($input_username eq ""){ main::error("ユーザー名を入力してください。"); }
			if($input_password eq ""){ main::error("パスワードを入力してください。"); }

#	if(Mebius::alocal_judge()){ Mebius::Debug::Error(qq($input_username,$input_password)); }

		($logined_flag) = &Memberfile("Passcheck Input",$secret_moto,$input_username,$input_password);

	}


# ログインが失敗した場合、ログイン画面を表示する
# main::access_log("ALL-MISSED-LOGINCHECK","ログインの失敗"); 
if(!$logined_flag){ &Loginview("",$secret_moto); }

# 画像を表示する
if($main::in{'mode'} eq "image"){ Mebius::Login::Image("",$secret_moto,"$main::in{'file'}"); }

# Docomoの固体識別番号対応
if($main::k_access eq "DOCOMO"){ $main::utn2 = qq( utn="utn"); }

}


#-----------------------------------------------------------
# セッションファイルの操作
#-----------------------------------------------------------
sub Loginsession{


# 宣言
my($type,$secret_moto) = @_;
my(undef,undef,$input_username,$input_password,$memory_salt) = @_ if($type =~ /New/);
my($cookie_username,$session_name,$user_name);
my($session_handler,$top1,$encpassword,$sessionfile,$renewline);
my($tkey,$tencpassword,$tsalt,$tlasttime,$tlimittime,$tusername,$logined_flag,$plustype_setcookie);

	# 汚染チェック１
	$secret_moto =~ s/\W//g;
	if($secret_moto eq ""){ return(); }

	# セッション値を定義（ログインチェック用）
	if($type =~ /Logincheck/){

		# ログイン用の独自クッキーを取得
		my($cookie) = Mebius::get_cookie("Acret-$secret_moto");
		($cookie_username,$session_name) = @$cookie;
		$cookie_username =~ s/\W//g;
		$session_name =~ s/\W//g;
		($user_name) = ($cookie_username);
	}

	# セッション値を定義（新規作成用）
	if($type =~ /New/){
		$input_username =~ s/\W//g;
			if($input_username eq ""){ return(); }
			if($input_password eq ""){ return(); }
		my @charpass = ('a'..'z', 'A'..'Z', '0'..'9');
		for(1..20){ $session_name .= $charpass[int(rand(@charpass))]; }
	}

	# 固体識別番号からセッション値を定義
	if($main::kaccess_one){
			if($main::k_access eq "DOCOMO" && $main::realcookie){ } # DocomoでCookieがある場合は固体識別番号を使わない
			else{ $session_name = $main::agent; }
	}

	# セッションをエンコード
	($session_name) = Mebius::Encode("",$session_name);
	if($session_name eq ""){ return(); }

# ファイル定義
$sessionfile = qq(${main::int_dir}_member/_sessions/_${secret_moto}_session/${session_name}_session.dat);

	# ログオフする場合
	if($main::in{'mode'} eq "logoff"){ 
		Mebius::set_cookie("Acret-$secret_moto");
		unlink($sessionfile); 
	}

	# ●セッションをゲットする場合
	if($type =~ /Logincheck/){

		# セッションファイルを開く
		my $open = open($session_handler,"<",$sessionfile);
		chomp($top1 = <$session_handler>);
		($tkey,$tencpassword,$tsalt,$tlasttime,$tlimittime,$tusername) = split(/<>/,$top1);
		close($session_handler);

			# ログインチェックの場合、存在しないセッション名はアタックとして記録する
			if($type !~ /New/){
					if(!$open){	Mebius::AccessLog(undef,"ATACKED-LOGINCHECK","存在しないセッション名 $session_name"); }
			}

			# キーが無効の場合、リターン
			if(!$tkey){ return(); }

			# 有効期限が切れている場合、リターン
			#if($main::postflag){ $tlimittime += 60*60; }
			#if($main::time > $tlimittime){ return(); }

			# クッキーがなく、セッションファイル内のアカウント名を使う場合
			if($tusername){ $user_name = $tusername; }

			# このままパスワードチェック
			($logined_flag) = &Memberfile("Session",$secret_moto,$user_name,$tencpassword,$tsalt);

			# 正常にリターン
			return($logined_flag);
	}

	# ●セッションを新規作成する（入力情報より。この前の処理で、メンバーファイルを開いてパスワードが一致した場合）
	if($type =~ /New/){

		# パスワードを複合化
		my($newencpassword,$newsalt) = Mebius::Crypt::crypt_text("MD5",$input_password,$memory_salt);

		# 最大時間を定義
		$tlimittime = time + 365*24*60*60;

		# 新しく書き込む行
		$renewline .= qq(1<>$newencpassword<>$newsalt<>$main::time<>$tlimittime<>$input_username<>\n);
		$renewline .= qq($main::addr<>$main::host<>$main::agent<>\n);

		# ファイルを作成
		Mebius::Fileout("",$sessionfile,$renewline);

		# セッションをクッキーにセット
		Mebius::set_cookie("Acret-$secret_moto",[$input_username,$session_name]);
	}

}

#-----------------------------------------------------------
# メンバーファイルを開く
#-----------------------------------------------------------
sub Memberfile{

# 宣言
my($type,$secret_moto,$input_username,$input_password) = @_;
my(undef,undef,$user_name,$session_encpassword,$session_salt) = @_ if($type =~ /Session/);
my($logined_flag,$member_handler,$top1,$encpassword,$memory_salt);
my($memberfile);

# ファイル定義
$memberfile = qq(${main::int_dir}_member/${secret_moto}_member.log);


# メンバーファイルを開く
open($member_handler,"<",$memberfile);

# トップデータを分解
chomp($top1 = <$member_handler>);
my($tkey) = split(/<>/,$top1);

	# ファイルを展開する
	while(<$member_handler>){

		chomp;
		my($key2,$level2,$username2,$encpassword2,$salt2) = split(/<>/,$_);

			# ●セッションでログイン判定 
			if($type =~ /Session/ && $username2 && $username2 eq $user_name){

				# パスワードが一致した場合
				if($encpassword2 && $salt2 && "$encpassword2-$salt2" eq "$session_encpassword-$session_salt"){
					$main::username = $username2;
					$logined_flag = 1;
				}

			}

			# ●入力情報からログイン判定
			elsif($type =~ /Input/ && $username2 && $username2 eq $input_username){

				# パスワードを複合化
				my($encpassword,$salt) = Mebius::Crypt::crypt_text("MD5",$input_password,$salt2);

#	if(Mebius::alocal_judge() && $type =~ /Input/){ Mebius::Debug::Error(qq($username2 eq $input_username / $encpassword2 eq $encpassword)); }

				# パスワードが一致した場合
				if($encpassword2 && $encpassword2 eq $encpassword){
					$logined_flag = 1;
					$main::username = $username2;
					$memory_salt = $salt2;
				}

			}
	}
close($member_handler);

	# ▼セッションファイルからチェックした場合
	if($type =~ /Session/){

			# ログイン成功
			if($logined_flag){
				main::access_log("SUCCESSED-LOGINCHECK","セッションからのログイン成功");
			}

			# ログイン失敗
			else{
				main::access_log("ATACKED-LOGINCHECK","セッションは存在するがログイン失敗");
			}
	}

	# ▼入力情報からチェックした場合
	if($type =~ /Input/){
	
			# ログイン成功
			if($logined_flag){

				# ログイン成功のログを取る
				main::access_log("SUCCESSED-LOGINCHECK","情報入力の成功");

				# セッションファイルを作成
				&Loginsession("New",$secret_moto,$input_username,$input_password,$memory_salt);
			}


			# ログイン失敗
			else{

				# ログイン失敗のログを取る
				main::access_log("MISSED-LOGINCHECK","情報入力の失敗");

				# アカウント名のみクッキーをセット
				Mebius::set_cookie("Acret-$secret_moto",[$input_username]);

				# ログイン画面に以降
				&Loginview("Error",$secret_moto,"アカウント名、またはパスワードが間違っています。");

			}

	}
# リターン
return($logined_flag);

}

#-----------------------------------------------------------
# 画像を表示する
#-----------------------------------------------------------
sub Image{

# 宣言
my($type,$secret_moto,$image) = @_;
my($imagehandler,$imagefile);

# 汚染チェック
my($filename,$tail) = split(/\./,$image);
$filename =~ s/[^\w-]//g;
$tail =~ s/\W//g;
	if($filename eq ""){ main::error("ファイル名を指定してください。"); }
	if($tail eq ""){ main::error("拡張子を指定してください。"); }

# ファイル定義
$imagefile = "${main::int_dir}_upload/_${secret_moto}_upload/$filename.$tail";

	# ファイルが存在しない場合
	if(!-e $imagefile){ main::error("画像が存在しません。"); }

	# ヘッダ
	if($tail eq "png"){ print "Content-type: image/png\n\n"; }
	elsif($tail eq "gif"){  print "Content-type: image/png\n\n"; }
	elsif($tail eq "jpeg" || $tail eq "jpg"){  print "Content-type: image/jpeg\n\n"; }
	else{ main::error("ファイル形式が変です。"); }

# 画像を出力
open $imagehandler,$imagefile;
binmode ($imagehandler);
print <$imagehandler>;
close ($imagehandler); 

exit;


}


#-----------------------------------------------------------
# ログイン画面を表示
#-----------------------------------------------------------
sub Loginview{

# 宣言
my($basic_init) = Mebius::basic_init();
my($type,$secret_moto,$error_message) = @_;
my($first_username,$cookie_username,$docomo_navilink);

# ログイン用の独自クッキーを取得
my($cookie) = main::get_cookie("Acret-$secret_moto");
($cookie_username) = @$cookie;

# タイトル定義
$main::sub_title = qq(ログイン);
$main::head_link2 = qq( &gt; ログイン);

# 初期入力
if($main::in{'mode'} eq "logoff"){ $first_username = ""; }
elsif($main::in{'connent'}){ $first_username = $main::in{'connent'}; }
elsif($cookie_username){ $first_username = $cookie_username; }
$first_username =~ s/\W//g;

	# Docomo 対応のナビゲーションリンク
	if($main::k_access eq "DOCOMO"){
		$docomo_navilink = qq(<br$main::xclose>*Docomoで自動ログインする場合は<a href="./"$main::sikibetu>固体識別番号を送信</a>してください。\(初回はユーザー名/パスワードを入力\));
	}

# エラーメッセージ
if($error_message){ $error_message = qq(<span style="color:#f00;font-size:small">※$error_message</span>); }

# CSS定義
$main::css_text .= qq(
form.login{margin:1em 0em;}
);



# HTML
my $print = qq(
<h1$main::kfontsize_midium>ログイン</h1>
$error_message
<form action="./" method="post" class="login"$main::sikibetu>
<div>
<input type="hidden" name="mode" value=""$main::xclose>
ユーザー名 <input type="text" name="connent" value="$first_username" size="10"><br$main::xclose>
パスワード <input type="password" name="hamdle" value="" size="10"><br$main::xclose>
<input type="submit" name="colol" value="ログインする"$main::xclose>
<label><input type="checkbox" name="memory" value="1"$main::parts{'checked'}><span class="guide">ログインを記憶する</span></label>
<input type="hidden" name="moto" value="$main::realmoto"$main::xclose>
<input type="hidden" name="backurl" value="http://$main::server_domain$main::requri"$main::xclose><br$main::xclose><br$main::xclose>
<span class="guide">＊ログイン方式が変わりましたが、パスワードは同じです。パスワードを忘れた場合、うまく動かない場合は<a href="mailto:$basic_init->{'admin_email'}">管理者</a>まで問い合わせてください。</span>
$docomo_navilink
</div>
</form>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;


}

1;


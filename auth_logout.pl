
use Mebius::AuthServerMove;

#-----------------------------------------------------------
# SNS ログアウト
#-----------------------------------------------------------
sub auth_logout{
if($in{'action'}){ &do_logout; } else{ &view_logout; }
}

#-----------------------------------------------------------
# ログアウト前の画面
#-----------------------------------------------------------
sub view_logout{

my $print = qq(
本当にログアウトしますか？<br><br>

<form action="$main::auth_url" method="post"$sikibetu>
<div>
<input type="hidden" name="mode" value="logout">
<input type="submit" name="action" value="$pmfile からログアウトする">
<input type="hidden" name="logout_doned" value="1">
</div>
</form>


$footer_link
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-------------------------------------------------
# ログアウト
#-------------------------------------------------
sub do_logout{

# 宣言
my($basic_init) = Mebius::basic_init();
my($none,$next,$logout_doned);

	# Get送信を禁止
	if(!$main::postflag){ main::error("GET送信はできません。"); }

# 二重クッキーセットを防止
$no_headerset = 1;

# クッキーをセット
Mebius::Cookie::set_main({ account => "" , hashed_password => "" , } );

# タイトルなど定義
$head_link3 = qq(&gt; ログアウト);

# ジャンプ
$jump_url = $auth_url;
$jump_sec = 5;


my($action_url) = Mebius::Auth::ServerMove("All-domains",$main::server_domain);

	# 各サーバーでログアウト
	if($main::in{'logout_doned'} < $basic_init->{'number_of_domains'}){
		
		$logout_doned = $main::in{'logout_doned'} + 1;

		$next = qq(
		<form action="$action_url" method="post"$sikibetu>
		<div>
		うまくログアウトできない場合は
		<input type="hidden" name="mode" value="logout">
		<input type="hidden" name="logout_doned" value="$logout_doned">
		<input type="submit" name="action" value="このボタンも押してください($logout_doned)">
		</div>
		</form>
		<br><br>);

			if($main::myadmin_flag >= 5){ $next .= qq(); }

	}

my $print = <<"EOM";
ログアウトしました。（<a href="${auth_url}">→$titleへ</a>）<br><br>
$next
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;

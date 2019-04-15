
use Mebius::SNS::Friend;
use Mebius::Export;

#-------------------------------------------------
# プロフィール表示
#-------------------------------------------------
sub auth_avfriend{

# 局所化
my($file,$i,$navilink,%friends_friend,$friend_friends_line,%my_friend_index);

# CSS定義
$css_text .= qq(
.lim{margin-bottom:0.3em;}
li{line-height:1.6em;}
div.friend_index .my_friend{background:#cfc;padding:0.3em 0.5em;}
div.friend_index .me{background:#fee;padding:0.3em 0.5em;}
);

# ファイルオープン
my(%account) = Mebius::Auth::File("File-check-error",$main::in{'account'});

# ユーザー色指定
if($account{'color1'}){ $css_text .= qq(h2{background-color:#$account{'color1'}border-color:#$account{'color1'};}); }

# トリップ
#if($ppenctrip){ $pri_ppenctrip = "☆$ppenctrip"; }

# アカウント名
my $viewaccount = $account{'file'};
	if($account{'file'} eq "none"){ $viewaccount = "****"; }

# タイトル決定
$sub_title = "$friend_tag一覧 - $account{'name'} - $viewaccount - $title";



	# 自分のマイメビと比べる
	if($main::myaccount{'file'} && !$account{'myprof_flag'}){
		(%my_friend_index) = Mebius::Auth::FriendIndex("Get-friend-hash",$main::myaccount{'file'});
	}

# マイメビ一覧の読み込みタイプを定義
my $plustype_friend_index;
	if($account{'myprof_flag'}){ $plustype_friend_index .= qq(Get-friend-status); }
	if($account{'myprof_flag'}){ $plustype_friend_index .= qq( Allow-renew-status); }

# マイメビ一覧を読み込み
my(%friend_index) = Mebius::Auth::FriendIndex("Get-index $plustype_friend_index",$account{'file'},%my_friend_index);

	# 自分のマイメビが誰とマイメビになったかの一覧を取得
	if($account{'editor_flag'}){
		(%friends_friend) = Mebius::Auth::FriendsFriendIndex("Get-index",$account{'file'});
		$friend_friends_line = qq(<h2 style="background:#cdf;border-color:#77f;$main::kstyle_h2_in">$main::friend_tagの$main::friend_tag</h2>\n<div>$friends_friend{'index_line'}</div>\n);
	}

# ナビ
my $link2 = "$adir$account{'file'}/";
if($main::aurl_mode){ ($link2) = &aurl($link2); }

$navilink .= qq( <a href="$link2">$account{'name'}のプロフィール</a>);

	if($main::myaccount{'file'}){
			if($account{'myprof_flag'}){
					$navilink .= qq( あなたの$main::friend_tag);
			}
			else{
					$navilink .= qq( <a href="${main::auth_url}$main::myaccount{'file'}/aview-friend">あなたの$main::friend_tag一覧</a>);
			}
	}

# HTML
my $print = <<"EOM";
$footer_link
<h1$main::kstyle_h1>$friend_tag一覧 : $account{'name'} - $viewaccount</h1>
$friendlink
$navilink
$adsarea
$friend_index{'index_line'}
$friend_friends_line
EOM


$print .= qq($footer_link2);

#url => $account{'profile_url'} , title => "マイメビ"
Mebius::Template::gzip_and_print_all({ BCL => [ "マイメビ" ] },$print);

# 処理終了
exit;

}




1;

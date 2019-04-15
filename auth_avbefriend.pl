
use Mebius::SNS::Friend;

#-------------------------------------------------
# プロフィール表示
#-------------------------------------------------
sub auth_avbefriend{

# 局所化
my($file);

#汚染チェック
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# CSS定義
$css_text .= qq(
.lim{margin-bottom:0.3em;line-height:1.25;}
);

# ファイルオープン
my(%account) = Mebius::Auth::File("File-check-error",$file);

	# 自分のアカウントでない場合
	if(!$account{'editor_flag'}){ &error("自分のアカウントではありません。",401); }

	# ユーザー色指定
	if($ppcolor1){ $css_text .= qq(h2{background-color:#$ppcolor1;border-color:#$ppcolor1;}); }


# タイトル決定
$sub_title = "$friend_tag申\請一覧 - $account{'handle'} - $ppaccount - $title";
$head_link3 = qq(&gt; $hername);


# 日記、コメントフォームなどのログ読み込み
my($apply) = Mebius::Auth::ApplyFriendIndex("Get-index",$file);

# ナビ
my $link2 = "$adir${file}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
my $navilink .= qq(<a href="$link2">プロフィールに戻る</a>);

# HTML
my $print = <<"EOM";
$footer_link
<h1$main::kstyle_h1>$friend_tag許可 : $account{'name'} - $file </h1>
$friendlink
$navilink
$adsarea
<h2$main::kstyle_h2>他メンバーからの$main::friend_tag申\請</h2>
$apply->{'index_line'}
EOM


$print .= qq($footer_link2);

Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;

}




1;

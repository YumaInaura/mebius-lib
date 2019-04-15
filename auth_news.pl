
package main;
use strict;

#-----------------------------------------------------------
# 自分への新着ニュースを表示
#-----------------------------------------------------------
sub news_auth{

# 宣言
my(%account,$news_comment_line);
my(%friends_friend,$friend_friends_line);
our(%in);

# CSS定義
$main::css_text .= qq(
table.news_list{width:100%;}
);

# アカウントを開く
(%account) = Mebius::Auth::File("",$in{'account'});

# 自分で無い場合
if(!$account{'editor_flag'}){ main::error("アカウント主/管理者でないと新着データは見られません。"); }

	# 自分のマイメビが誰とマイメビになったかの一覧を取得
	if($account{'editor_flag'}){
		(%friends_friend) = Mebius::Auth::FriendsFriendIndex("Get-index",$account{'file'});
		$friend_friends_line = qq(<h2$main::kstyle>$main::friend_tagの$main::friend_tag</h2>\n<div>$friends_friend{'index_line'}</div>\n);
	}


# 猫のインデックスを取得
require "${main::int_dir}auth_vote.pl";
my($index_line_vote) = Mebius::Auth::Vote::Data("Index Not-get-account",$account{'file'},5);

($news_comment_line) = Mebius::Auth::News("Index All",$account{'file'});

# HTML
my $print =  qq(
$news_comment_line
$friend_friends_line
<h2$main::kstyle_h2>猫</h2>
<table class="width100">
$index_line_vote
</table>
);

# ヘッダ
auth_html_print($print,"新着情報",\%account);

exit;

}



1;
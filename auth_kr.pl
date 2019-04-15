
use strict;
package main;

#-----------------------------------------------------------
# アカウントの関連記事を表示
#-----------------------------------------------------------
sub auth_kr{

# 宣言
my(%account,$plustype);
our($submode2,%in,$kr_line,$myadmin_flag,$xclose,$sikibetu,$auth_url,$postflag,$int_dir);
our($head_link3,$head_link4,$footer_link,$footer_link2,$css_text,$title,$sub_title);

# タイプ定義
if($submode2 eq "view"){ }
else{ main::error("このページは存在しません。"); }

# アカウントファイルを開く
(%account) = Mebius::Auth::File("",$in{'account'});

# 設定状態をチェック
if(!$account{'kr_flag'}){ main::error("このメンバーは関連リンクをオフにしています。"); }

# 取り込み処理
require "${int_dir}part_kr.pl";

	# 曖昧関連を編集する
	if($in{'type'} eq "kr_edit" && ($account{'myprof_flag'} || $myadmin_flag)){

		# GET送信を禁止
		if(!$postflag){ main::error("GET送信は出来ません。"); }

			# 関連リンクを更新する
			($kr_line) = related_thread("Edit-data Account",$account{'file'});

			# リダイレクト
			Mebius::Redirect("","${auth_url}$account{'file'}/kr-view");
	}


# 関連リンクを取得する
if($account{'myprof_flag'} || $myadmin_flag){ $plustype .= qq( Editor); }
($kr_line) = related_thread("Index Account $plustype",$account{'file'});

# 修正フォーム
if($account{'myprof_flag'} || $myadmin_flag){

$kr_line = qq(
<form action="$auth_url" method="post" class="kr_edit"$sikibetu>
<div>
$kr_line
<input type="hidden" name="mode" value="kr-view"$xclose>	
<input type="hidden" name="account" value="$account{'file'}"$xclose>	
<input type="hidden" name="type" value="kr_edit"$xclose>	
<br$main::xclose>　　<input type="submit" value="ポイントを編集する"$xclose>	
</div>
</form>
);


}

# タイトル定義
$sub_title = qq(関連リンク | $account{'name'} - $account{'file'});
$head_link3 = qq(&gt; <a href="$auth_url$account{'file'}/">$account{'file'}</a>);
$head_link4 = qq(&gt; 関連リンク);

# CSS定義
$css_text .= qq(
form.kr_edit{margin:1em 0em;}
);


# HTML部分
my $print = qq(
$footer_link
<h1$main::kfontsize_h1>$account{'name'} - $account{'file'} ： 関連リンク</h1>
<a href="$auth_url$account{'file'}/">プロフィールへ</a>
$kr_line
$footer_link2
);

Mebius::Template::gzip_and_print_all({},$print);




exit;

}


1;

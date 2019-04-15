
use strict;
use Mebius::Handle;
package Mebius::BBS;

#-----------------------------------------------------------
# 筆名ランキングのインデックス
#-----------------------------------------------------------
sub HandleRankingIndex{

# 宣言
my($page_title,$plustype_ranking,$history_line,$file_type);
my($year,$monthf) = ($main::submode2,$main::submode3);

	
	# 各種エラー
	if($main::bbs{'concept'} =~ /Not-handle-ranking/){
		main::error("この掲示板ではランキングを開催していません。");
	}

# CSS定義
$main::css_text .= qq(
h1{font-size:150%;}
h2{font-size:130%;}
);

	# 携帯版への対応
	if($main::device_type eq "mobile" || ($main::mode =~ /mobile/ && $main::myadmin_flag >= 5)){
		main::kget_items();
		$plustype_ranking .= qq( Mobile-view); 
	}
	else{
		$plustype_ranking .= qq( Desktop-view); 
	}



	# 表示モードの定義
	# 月毎ファイル
	if($year && $monthf){
		$main::sub_title = qq($year年$monthf月の参加ランキング | $main::title);
		$main::head_link3 = qq(&gt; <a href="./ranking.html">参加ランキング</a>);
		$main::head_link4 = qq(&gt; $year年$monthf月);
		$page_title = qq(<a href="./">$main::title</a> の参加ランキング ( $year年$monthf月 ));
		$plustype_ranking .= qq( Month-file);
		$file_type = "month";
	}
	# 最近のファイル
	elsif($year eq "news"){
		$main::sub_title = qq(最近の参加者 | $main::title);
		$main::head_link3 = qq(&gt; <a href="./ranking.html">参加ランキング</a>);
		$main::head_link4 = qq(&gt; 最近の参加者);
		$page_title = qq(<a href="./">$main::title</a> / 最近の参加者);
		$plustype_ranking .= qq( News-file);
		$file_type = "news";
	}
	# 総合ファイル
	else{
		$main::sub_title = qq(参加ランキング | $main::title);
		$main::head_link3 = qq(&gt; 参加ランキング);
		$page_title = qq(<a href="./">$main::title</a> の参加ランキング ( 全期間 ));
		$plustype_ranking .= qq( All-file);
		$file_type = "all";
	}

# ランキングデータを取得
my($index_line) = Mebius::BBS::HandleRankingBBS("Get-index $plustype_ranking",$main::moto,$year,$monthf);

	# 一定確率で自動リンク切れチェック
	if(rand(20) < 1 || $main::alocal_mode){
		Mebius::BBS::HandleRankingBBS("Dead-link-check Renew $plustype_ranking",$main::moto,$year,$monthf);
	}

# 歴史リンクを定義
$history_line .= qq(<h2$main::kstyle_h2>メニュー</h2>\n);
	if($file_type eq "news"){ $history_line .= qq(最近\n); }
	else{ $history_line .= qq(<a href="./ranking-news.html">最近</a>\n); }
	if($file_type eq "all"){ $history_line .= qq(全期間\n); }
	else{ $history_line .= qq(<a href="./ranking.html">全期間</a>\n); }
($history_line) .= Mebius::BBS::HandleRankingHistoryBBS("Get-index $plustype_ranking",$main::moto,$year,$monthf);


# HTML
my $print = qq(
<div>
<h1$main::kstyle_h1>$page_title</h1>
<h2$main::kstyle_h2>一覧</h2>
$index_line
$history_line
</div>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;

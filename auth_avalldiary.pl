
use Mebius::Auth;
use Mebius::SNS::Crap;
package main;
use strict;
use Mebius::Export;

#-------------------------------------------------
# プロフィール表示
#-------------------------------------------------
sub auth_avalldiary{

# 局所化
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my($sns_init) = Mebius::SNS->init();
my($param) = Mebius::query_single_param();
my $question = new Mebius::Question;
my $times = new Mebius::Time;
my $sns_url = new Mebius::SNS::URL;
my $html = new Mebius::HTML;
my $question_post = $question->post_object();
my $question_view = $question->view_object();
my($newdiary_link,$crap_ranking_line,@BCL,$newdiary_index,$max_view_line);

# CSS定義
my $css_text .= qq(
.lim{margin-bottom:0.3em;line-height:1.25;}
li{line-height:1.5;}
table,th,tr,td{border-style:none;}
table{font-size:100%;width:100%;}
th{text-align:left;padding:0.5em 1.0em 0.5em 0.0em;}
th.sub{width:45%;}
th.name{width:35%;}
td{padding:0.2em 1.0em 0.5em 0.0em;}
span.guide{font-size:90%;color:#080;}
);

	if($my_account->{'admin_flag'}){
		$max_view_line = 500;
	} else {
		$max_view_line = 100;
	}

my($title) = $sns_init->{'title'};

# タイトル定義
my $sub_title = "全メンバーの更新 - $title";

	if($param->{'word'} ne ""){
		$sub_title = e(" ”$param->{'word'}”で検索 - 全メンバーの更新 - $title");
		push @BCL ,  { url => "./aview-alldiary.html" , title =>" 全メンバーの更新" } ;
		push @BCL ,  e("”$param->{'word'}”で検索 ");
	} else {
		push @BCL ,  qq(全メンバーの更新);
	}

# 日記一覧を取得
#my(@newdiary_index_array) = Mebius::SNS::Diary::all_members_diary("Get-index New-file");
#my @array = @newdiary_index_array;

#	if(!$param->{'word'}){
#		my $border_time = time - 3*24*60*60;
#		my $question_post_data = $question_post->fetchrow_main_table_and_complete_data({ deleted_flag => ["<>",1] , post_time => [">",$border_time] });
#		push @array , @{$question_post_data};
#	}

#my @sorted_array = sort { $b->{'post_time'} <=> $a->{'post_time'} } @array;

#	foreach my $hash (@sorted_array){

#		$newdiary_index .= qq(<tr>);

#		$newdiary_index .= qq(<td>);
#		$newdiary_index .= $html->href($hash->{'url'},$hash->{'subject'});
#		$newdiary_index .= qq(</td>);

#		$newdiary_index .= qq(<td>);
#		$newdiary_index .= $sns_url->account_link($hash->{'account'},$hash->{'handle'} || $hash->{'owner_handle'});
#		$newdiary_index .= qq(</td>);


#		$newdiary_index .= qq(<td>);
#		$newdiary_index .= $times->how_before($hash->{'post_time'});
#		$newdiary_index .= qq(</td>);

#		$newdiary_index .= qq(</tr>);
		
#	}
#	if($newdiary_index){
#		$newdiary_index = qq(<table summary="更新一覧"><tr><th class="sub">タイトル</th><th class="name">名前</th><th class="date">時刻</th></tr>\n$newdiary_index</table>\n);
#	}

#undef $newdiary_index;

my $all_members_news = qq(<div class="line-height-large">) . Mebius::SNS::Feed->all_members_feed_line($max_view_line,{ search_keyword => $param->{'word'} , Index => 1  }) . qq(</div>);

#my($alertdiary_index) = Mebius::SNS::Diary::all_members_diary("Get-index Alert-file");
my $alertdiary_index;
#my($alertdiary_res_index) = Mebius::Auth::all_members_diary("Get-index Alert-res-file");
my $alertdiary_res_index;

	if($alertdiary_index){ $alertdiary_index = qq(<h2$main::kstyle_h2>注意日記 <span class="red size80">(管理者用)</span></h2>\n$alertdiary_index); }

# いいね！ランキングを取得
#my(%crap_ranking) = Mebius::Auth::CrapRankingDay("Diary-file Get-topics",$main::thisyearf,$main::thismonthf,$main::todayf,3);

	# いいね！ランキングの整形
	#if(!$main::in{'word'}){
	#	$crap_ranking_line .= qq(<div class="margin word-spacing">\n);
	#	$crap_ranking_line .= qq(たくさんいいね！されている日記 ($main::thismonth月$main::today日)： \n);
	#	$crap_ranking_line .= qq($crap_ranking{'topics_line'}\n);
	#	$crap_ranking_line .= qq(<a href="./crapview-$main::thisyearf-$main::thismonthf.html">…もっと見る</a>\n);
	#	$crap_ranking_line .= qq(</div>\n);
	#}

	# フォーカスを当てる
	#if(!exists $main::in{'word'}){
		#our $body_javascript = qq( onload="document.diary_search.word.focus()");
	#}

# フォームを取得
my($form) = auth_avalldiary_get_form();

	# 自分の日記投稿リンク
	if($my_account->{'login_flag'}){
		$newdiary_link .= qq(<a href=").e($basic_init->{'auth_url'}).e($my_account->{'id'}).qq(/">あなたのプロフィール</a>);
		$newdiary_link .= qq( <a href=").e($basic_init->{'auth_url'}).e($my_account->{'id'}).qq(/friend-diary">マイメビの更新</a>);
		$newdiary_link .= qq( 全メンバーの更新);
		$newdiary_link .= qq( <a href=").e($basic_init->{'auth_url'}).qq(?mode=fdiary">新しい日記を書く</a>);
	}


my($footer_link) = utf8_return($main::footer_link);
my($footer_link2) = utf8_return($main::footer_link2);

# HTML
my $print .= <<"EOM";
$footer_link
<h1$main::kstyke_h1>全メンバーの更新 - $title</h1>
$main::navilink
<div class="word-spacing">$newdiary_link</div>
$form
<h2$main::kstyle_h2 id="LIST">一覧</h2>
$all_members_news
EOM


$print .= qq($footer_link2);

Mebius::Template::gzip_and_print_all({ Title => $sub_title , BCL => \@BCL , inline_css => $css_text , source => "utf8" },$print);

# 処理終了
exit;

}


#-----------------------------------------------------------
# 検索フォーム
#-----------------------------------------------------------
sub auth_avalldiary_get_form{

# 宣言
my($form);
my($parts) = Mebius::Parts::HTML();
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();


my $form .= qq(
<h2>検索</h2>
<form action="$main::action" name="diary_search">
<div>
<input type="hidden" name="mode" value="aview-alldiary">
<input type="text" name="word" value=").e($param->{'word'}).qq(">
<input type="submit" value="最近の更新から検索する">
);

my $checked_comment = $parts->{'checked'} if($param->{'comment'} eq "1");

	if($my_account->{'admin_flag'}){
		#$form .= qq(<input type="checkbox" name="comment" value="1" id="search_comment"$checked_comment> <label for="search_comment" style="color:#f00;">本文(管理者用)</label> );
	}

$form .= qq(
　<span class="guide">※「題名」「筆名」「アカウント名」から検索します。</span>
</div>
</form>
);

return($form);

}


1;

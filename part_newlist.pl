
package main;
use Mebius::Text;
use Mebius::Export;

#-----------------------------------------------------------
# サイト全体の新着リスト
#-----------------------------------------------------------
sub main_newlist{

# 局所化
my($type) = @_;
my($print,$not_pagelinks_flag,$max_pagelinks,$page_links,$navi_links,$domain_links,$allsearch_form,$allsearch_plustype);
my($plustype_all);
local($i,$file,$h1_title,$ptype,$guide1,$new_links,$category_flag,$line);
our($css_text,$submode3);

	# モード調整
	if($type =~ /Admin-view/){
		$plustype_all .= qq( Admin-view);
	}

# 表示最大数
local $view_max = 100;
local $kview_max = 20;

# ページ最大数
local $page_max = 5;

# CSS定義
$css_text .= qq(
table.newlist th,
table.newlist tr,
table.newlist td{vertical-align:top;}
table.newlist{font-size:90%;margin-top:1.0em;width:100%;}
th{padding-right:1em;text-align:left;padding:0.5em 0.0em;}
th.sub{width:40%;}
th.bbs{width:20%;}
td{padding:0.3em 1.0em 0.3em 0.0em;}
ul{line-height:1.5em;font-size:90%;}
div.new_links{display:inline;background-color:#ffd;padding:0.4em 1.2em;border:solid 1px #f93;line-height:2.0em;font-size:90%;}
div.domain_links{display:inline;background-color:#dee;padding:0.4em 1.2em;border:solid 1px #5bb;margin-left:1em;line-height:2.0em;font-size:90%;}
div.cate_links{background-color:#eee;padding:0.4em 1.0em;border:solid 1px #aaa;font-size:90%;margin:1em 0em;}
span.none{display:none;}
a.res{color:#080;}
div.select_links{margin:0.5em 0em;}
div.navi_links{margin:1.0em 0em;}
div.page_links{margin:0.5em 0em;}
div.guide1{margin:1.0em 0em;color:#060;font-size:90%;}
div.allsearch_form{margin:0.5em 0em;}
input.allsearch_input_newlist{font-size:100%;}
input.allsearch_submit_newlist{font-size:100%;}
i{background:#f90;}
);


# 携帯版の処理
if($submode2 eq "k"){
&kget_items();
$view_max = $kview_max;
}


# 処理タイプによるエラー
if($submode2 ne "k" && $submode2 ne "p"){ &error("ページが存在しません。"); }


# 現在のページ数を定義
$submode3 =~ s/[^0-9a-z]//g;
if($submode3 =~ /[^0-9]/){ $category_flag = 1; } 
if($submode3 eq ""){ &error("ページ数を指定してください。"); }

	# アクセス振り分け
	if($submode1 ne "allsearch"){
			if($submode2 eq "k"){
			$divide_url = "http://$server_domain/_main/$submode1-p-$submode3.html";
				# 携帯版URLをまとめる
				Mebius::Redirect(undef,"http://$server_domain/_main/$submode1-p-$submode3.html",301);
				#if($device_type eq "desktop" && $submode3 eq "1"){ main::divide($divide_url,"mobile"); }
			}
			elsif($submode2 eq "p"){
			$divide_url = "http://$server_domain/_main/$submode1-k-$submode3.html";
				#if($device_type eq "mobile" && $submode3 eq "1"){ main::divide($divide_url,"desktop"); }
			}
	}

# カテゴリ取得
if($submode1 eq "newres" || $submode1 eq "newthread"){ ($cate_links) = &get_category(); }

# タイトル定義、リスト定義
my($file) = &get_title();

# ドメイン切り替えリンクを取得
($domain_links) = &newlist_domain_links();

# 全検索モード
if($ptype eq "allsearch"){
($line,$guide1) = Mebius::Newlist::allsearch("$main::ktype",$main::in{'word'},$main::in{'sc'},$main::in{'sc2'});
$not_pagelinks_flag = 1;
}

# 新着タグを取得
elsif($ptype eq "newtag"){
my($plustype) = " SEARCH" if ($main::ch{'word'});
($line) = Mebius::Newlist::tag("INDEX$plustype$main::ktype",$main::in{'word'});
$allsearch_plustype .= qq( TAG);
}

# 新しい記事を取得
elsif($ptype eq "newthread"){
($line) = Mebius::Newlist::threadres("INDEX THREAD$ktype $plustype_all",$main::in{'word'},"",$main::submode3);
$allsearch_plustype .= qq( THREAD);
}

# 新しいレスを取得
elsif($ptype eq "newres"){
($line) = Mebius::Newlist::threadres("INDEX RES Buffer$ktype $plustype_all",$main::in{'word'},"",$main::submode3);
$allsearch_plustype .= qq( RES);
}

	# 最大レス数達成スレッドを取得
	elsif($ptype eq "maxres"){
		($line) = Mebius::Newlist::Maxres("Get-index",$main::in{'word'},"",$main::submode3);
	}

	# 新しいお絵かき
	elsif($ptype eq "newpaint"){
		($line,$guide1) = Mebius::Newlist::Paint("Get-index Justy",$main::in{'word'},"",$main::submode3);
	}

	elsif($ptype eq "newsupport"){ &get_list2($file); }
	elsif($ptype eq "rankspt"){ &get_list3($file); }

	# 金貨ランキングを取得
	elsif($ptype eq "rankgold"){
		($line,$guide1,$max_pagelinks) = Mebius::Newlist::goldranking("GOLD INDEX$main::ktype","",$main::submode3);
	}

	# 銀貨ランキングを取得
	elsif($ptype eq "ranksilver"){
		($line,$guide1,$max_pagelinks) = Mebius::Newlist::goldranking("SILVER INDEX$main::ktype","",$main::submode3);
	}

	elsif($ptype eq "editmemo"){
		my($edit_memo) = &EditMemoList({ TypeGetIndex => 1 , MaxViewIndex => $view_max , NowPageNumber => $submode3});
		$line = $edit_memo->{'index_line'};

	}
	elsif($ptype eq "allpost"){ &get_list_allpost(); }
	elsif($ptype eq "rankpv"){ &get_list_pv("Normal"); }
	elsif($ptype eq "rankspv"){ &get_list_pv("Search"); }
	elsif($ptype eq "echeck"){
		$main::noindex_flag = 1;
		($line) = Mebius::Newlist::threadres("INDEX ECHECK $ktype $plustype_all",undef,undef,$main::submode3);
	}
	elsif($ptype eq "other"){
		$main::noindex_flag = 1;
		($line) = Mebius::Newlist::threadres("INDEX From-other-site-file $ktype $plustype_all",undef,undef,$main::submode3);
	}

else{ main::error("ページが存在しません。"); }
	
# フォーカスを当てる
$main::body_javascript = qq( onload="document.ALLSEARCH_NEWLIST.word.focus()");

# 全検索フォームを取得
if($ptype =~ /^(allsearch|newres|newthread|newtag)$/){
($allsearch_form) = Mebius::Newlist::allsearch_form("CSS1 SELECT-CHECKBOX LIMIT-CHECKBOX$allsearch_plustype$main::ktype",$main::in{'word'},$main::in{'sc'},$main::in{'sc2'},"NEWLIST");
}

# ガイド部分を整形
if($guide1){ $guide1 = qq(<div class="guide1">$guide1</div>); }
if($allsearch_form){ $allsearch_form = qq(<div class="allsearch_form">$allsearch_form</div>); }

# ページ切り替えリンクを取得
if(!$not_pagelinks_flag){ ($page_links) = &page_links("",$max_pagelinks); }


# ナビゲーションリンク
if(!$kflag){ $navi_links = qq(<a href="/">ＴＯＰページに戻る</a>); }

# HTML ( ＰＣ版 )
if(!$kflag){
$print = qq(

<h1>$h1_title</h1>
<div class="navi_links">$navi_links</div>
<div class="select_links">$new_links</div>
$allsearch_form
$guide1
$cate_links
$line
$page_links
$domain_links

);
}

# HTML ( 携帯版 )
else{
$print = qq(
<h1>$h1_title</h1>
$allsearch_form
$guide1
$line
$khrtag
<div style="font-size:small;">
$new_links
$navi_links

$cate_links
$domain_links
</div>
$page_links
);

}

# 管理モード用のURL変換
if($admin_mode){ ($print) = Mebius::Adfix("Url",$print); }

# 書き出し
Mebius::Template::gzip_and_print_all({},$print);

# 終了
exit;

}

#-----------------------------------------------------------
# カテゴリ切り替えリンク
#-----------------------------------------------------------
sub get_category{

# 局所化
my($i,$cate_links);

my @category = (
"aura=あうら=1",
"poemer=詩=1",
"novel=小説=1",
"diary=日記他=1",
"soudann=相談=1",
"shakai=社会=1",
"nenndai=雑談１=1",
"zatudann2=雑談２=2",
"chiiki=地域=1",
"music=音楽=2",
"gokko=ごっこ=2",
"anicomi=アニメ/漫画=2",
"game=ゲーム=2",
"narikiri=なりきり=2",
"etc=ＥＴＣ=2",
"mebi=メビ=1"
);

foreach(@category){
$i++;
if($i >= 2){ $cate_links .= qq( - ); }

my($category,$title,$domain) = split(/=/,$_);

my($url);
if($domain eq "1"){ $url = "http://aurasoul.mb2.jp/"; }
else{ $url = "http://mb2.jp/"; }

if($category eq $submode3){ $cate_links .= qq( $title ); $category_title = qq($titleカテゴリ); }
else{ $cate_links .= qq( <a href="${url}_main/$submode1-$submode2-$category.html">$title</a> );}
}
$cate_links = qq(<div class="cate_links">$cate_links</div>);

return($cate_links);

}

#-----------------------------------------------------------
# タイトル定義・ファイル定義・モード切替リンク
#-----------------------------------------------------------
sub get_title{

# 局所化
my($i,$hit,$ptitle,@new_links,$file);

# 各種ページ 切り替えリンク
@new_links = (
"メビウス全検索=allsearch==検索=no_menu",
"新着タグ=newtag==タグ",
"新着記事=newthread==記事",
"新着レス=newres==レス",
"新着絵=newpaint==絵=hidden",
"新着いいね！=newsupport=_sinnchaku/all_newsupport=いいね！",
"新着メモ=editmemo=_backup/memoedit_backup=メモ",
"総レス数=allpost==総レス",
"人気記事=rankspt=_sinnchaku/rank_support=人気",
"金貨ランキング=rankgold==金貨",
"PVランキング=rankpv=_sinnchaku/rank_pv=PV1=no_menu",
"PVランキング(検索)=rankspv=_sinnchaku/rank_spv=PV2=no_menu",
"注意投稿=echeck==注意=nofollow",
"外部経由=other==外部=nofollow"
);

#"最大レス達成記事=maxres==最大レス",

#"銀貨ランキング=ranksilver==銀貨",


	# 各種振り分け
	foreach(@new_links){

		$i++;

		my($title,$type,$file2,$title2,$type2) = split(/=/);
		my($nofollow);
		my $linkname = $title;

			# 管理モードでのみ表示する場合
			if($type =~ /^(other)$/ && !$main::admin_mode){ next; }

			if($title2){ $linkname = $title2; }
			if($type eq $submode1){
					if($hit >= 1){ $new_links .= qq( - ); }
				$new_links .= qq($linkname\n);
				$ptitle = $title;
				$ptype = $type;
				$ptype2 = $type2;
				$file = "${int_dir}${file2}.cgi";
			}

			else{

					# リンクロボット避けを追加
					if($type2 eq "no_menu"){ next; }

					# リンクロボット避けを追加
					if($type2 eq "nofollow"){ $nofollow = qq( rel="nofollow"); }

					if($hit >= 1){ $new_links .= qq( - ); }
					$new_links .= qq(<a href="$type-$submode2-1.html"$nofollow>$linkname</a>\n);

			}
		$hit++;

	}

$new_links = qq(<div class="new_links">$new_links</div>);

# タイトル定義
my($page);
if($category_title){ $page = $category_title; }
else{ $page = $server_domain; }

$sub_title = "$ptitle | $page";
if($submode3 >= 2){ $sub_title = "$submode3 | $ptitle | $page"; }
$head_link2 = qq( &gt; <a href="http://$server_domain/">$server_domain</a> );
$head_link3 = qq( &gt; $ptitle );
$h1_title = "$ptitle ( $page )";

return($file);

}

#-----------------------------------------------------------
# ドメイン切り替えリンク
#-----------------------------------------------------------
sub newlist_domain_links{

# 局所化
my($i,$domain_links);
our(%in,$postbuf_query_esc,$mode);

# ドメイン切り替えリンク
	foreach(@domains){
$idomain++;
		if($idomain >= 2){ $domain_links .= qq( - ); }
		if($_ eq $server_domain){ $domain_links .= qq($_); }
		else{
			if($in{'word'}){ $domain_links .= qq(<a href="http://$_/_main/?$postbuf_query_esc">$_</a>); }
			else{ $domain_links .= qq(<a href="http://$_/_main/$mode.html">$_</a>); }
		}
	}
$domain_links = qq(<div class="domain_links">$domain_links</div>);

return($domain_links);

}

#-----------------------------------------------------------
# ページ切り替えリンク
#-----------------------------------------------------------
sub page_links{

# 宣言
my($type,$max_pagelinks) = @_;
my($page_links);
my($page_max) = our($page_max);

if($max_pagelinks){ $page_max = $max_pagelinks; }

if($category_flag || $submode1 eq "allpost" || $submode1 eq "newtag"){ return; }

for(1..$page_max){
if($_ eq $submode3){ $page_links .= qq($_ ); }
else{ $page_links .= qq(<a href="$submode1-$submode2-$_.html">$_</a> ); }
}
$page_links = qq(<div class="page_links">$page_links</div>);
return($page_links);

}


#-----------------------------------------------------------
# リスト内容を取得２ （ 新着いいね！ ）
#-----------------------------------------------------------
sub get_list2{

# 局所化
my($file) = @_;
my($flag);

# CSS定義を追加
$css_text .= qq(
table.new_crap{word-wrap:break-word;}
table.new_crap th.sub{width:auto;}
table.new_crap th.name{width:10em;}
table.new_crap th.bbs{width:13em;}
table.new_crap th.date{width:8em;}
div.comment{width:20em;word-wrap:break-word;}
);


# 表示リスト整形（前）
if($kflag){ $line .= qq(<ul>); }
else{ $line .= qq(<table summary="$ptitleのリスト" class="new_crap newlist"><tr><th class="sub">記事名</th><th class="bbs">掲示板</th><th>筆名</th><th class="comment">コメント</th></tr>\n); }

# ファイル読み込み
open(IN,"$file");
while(<IN>){
$i++;

if(!$category_flag){
if($i < ($submode3 - 1)*$view_max){ next; }
if($i >= $view_max + $view_max * ($submode3 - 1)){ last; }
}

chomp;
my($key,$moto,$title,$no,$sub,$handle,$comment,$No,$restime,$date,$cate) = split(/<>/);
if($category_flag && $submode3 ne $cate){ next; }
$flag = 1;
if($kflag){ $line .= qq(<li><a href="/_$moto/$no.html">$sub</a> - <a href="/_$moto/">$title</a> - $date</li>); }
else{ $line .= qq(<tr><td><a href="/_$moto/$no.html">$sub</a></td><td><a href="/_$moto/">$title</a></td><td>$handle</td><td><div class="comment">$comment</div></td></tr>\n); }
}
close(IN);

# 表示リスト整形（後）
if($kflag){ $line .= qq(</ul>); }
else{ $line .= qq(</table>); }

# ヒットがない場合
if(!$flag){ &error("表\示する内容がありません。"); }

}

#-----------------------------------------------------------
# リスト内容を取得３ （ 人気記事 ）
#-----------------------------------------------------------
sub get_list3{

# 局所化
my($file) = @_;

# CSS定義を追加
$css_text .= qq(
th.num{}
td.num{}
);

# 表示リスト整形（前）
if($kflag){ $line .= qq(<ul>); }
else{ $line .= qq(<table summary="$ptitleのリスト" class="newlist"><tr><th class="sub">記事名</th><th class="bbs">掲示板</th><th class="num">いいね！</th></tr>\n); }

# ファイル読み込み
open(IN,"$file");
while(<IN>){
$i++;

if($i < ($submode3 - 1)*$view_max){ next; }
if($i >= $view_max + $view_max * ($submode3 - 1)){ last; }
chomp;
my($key,$num,$moto,$title,$no,$sub) = split(/<>/,$_);

if($kflag){ $line .= qq(<li><a href="/_$moto/$no.html">$sub</a> - <a href="/_$moto/">$title</a> ($numいいね！)</li>); }
else{ $line .= qq(<tr><td><a href="/_$moto/$no.html">$sub</a></td><td><a href="/_$moto/">$title</a></td><td class="num">$num回</td></tr>\n); }
}
close(IN);

# 表示リスト整形（後）
if($kflag){ $line .= qq(</ul>); }
else{ $line .= qq(</table>); }

}

use strict;

#-----------------------------------------------------------
# リスト内容を取得１ （ 記事メモ履歴 ）
#-----------------------------------------------------------
sub EditMemoList{

# 局所化
my($use) = @_;
my($flag,$FILE1,@renew_line,%self,$i);

# デバイス情報を取得
my($use_device) = Mebius::my_use_device();

# ファイル
my($init_directory) = Mebius::BaseInitDirectory();
my $file = "${init_directory}_sinnchaku/new_edit_memo.log";

	# 表示リスト整形（前）
	if($use_device->{'type'} eq "Mobile"){ $self{'index_line'} .= qq(<ul>); }
	else{ $self{'index_line'} .= qq(<table class="newlist"><tr><th class="sub">記事名</th><th class="bbs">掲示板</th><th class="name">筆名</th><th class="date">時刻</th></tr>\n); }


# ファイル読み込み
open($FILE1,"<$file");

	# ファイルロック
	if($use->{'TypeRenew'}){ flock(1,$FILE1); }

	# ファイルを展開
	while(<$FILE1>){

		# 局所化
		my($mark);

		$i++;

		# 行を分解
		chomp;
		my($key,$lasttime,$dat,$sub,$title,$moto2,$thread_number2,$before,$after,$name,$id,$trip,$host2,$age2,$number,$account) = split(/<>/,$_);

			# ●インデックス取得用
			if($use->{'TypeGetIndex'}){

					if($i < ($use->{'NowPageNumber'} - 1)*$use->{'MaxViewIndex'}){ next; }
					if($i >= $use->{'MaxViewIndex'} + $use->{'MaxViewIndex'} * ($use->{'NowPageNumber'} - 1)){ last; }

					if($after eq ""){ $mark = qq( <strong>消去</strong> ); }

				$flag = 1;

					if($use_device->{'type'} eq "Mobile"){
						$self{'index_line'} .= qq(<li><a href="/_$moto2/$thread_number2.html">$sub</a> $mark ( <a href="/_$moto2/${thread_number2}_memo.html#HISTORY" rel="nofollow">→差分</a> ) - <a href="/_$moto2/">$title</a> - $name - $dat</li>);
					}
					else{
						$self{'index_line'} .= qq(<tr><td><a href="/_$moto2/$thread_number2.html">$sub</a> $mark ( <a href="/_$moto2/${thread_number2}_memo.html#HISTORY" rel="nofollow">→差分</a> ) </td><td><a href="/_$moto2/">$title</a></td><td>$name</td><td>$dat</td></tr>\n);
					}

			}

			# ●ファイル更新用
			if($use->{'TypeRenew'}){
					if($use->{'TypeNewLine'}){
						if($thread_number2 eq $use->{'NewThreadNumber'}){ next; }
					}
				push(@renew_line,"$key<>$lasttime<>$dat<>$sub<>$title<>$moto2<>$thread_number2<>$before<>$after<>$name<>$id<>$trip<>$host2<>$age2<>$number<>$account<>\n");
			}

	}
close($FILE1);

	# ファイル更新
	if($use->{'TypeRenew'}){

			# 新しい行を追加
			if($use->{'TypeNewLine'}){
				my $time = time;
				my($access) = Mebius::my_access();
				my($gethost) = Mebius::GetHostWithFile();
				my($nowdate) = Mebius::now_date();
				my($encid) = main::id();

	unshift(@renew_line,"1<>$time<>$nowdate<>$use->{'NewSubject'}<>$use->{'NewTitle'}<>$use->{'NewMoto'}<>$use->{'NewThreadNumber'}<>$use->{'NewBeforeText'}<>$use->{'NewAfterText'}<>$use->{'NewHandle'}<>$encid<>$use->{'NewTrip'}<>$gethost<>$access->{'multi_user_agent_escaped'}<>$main::cnumber<>$main::myaccount{'file'}<>\n");
			}

		# ファイル更新
		Mebius::Fileout(undef,$file,@renew_line);
	}


	# インデックス整形
	if($use->{'TypeGetIndex'}){
		if($use_device->{'type'} eq "Mobile"){ $self{'index_line'} .= qq(</ul>); } else { $self{'index_line'} .= qq(</table>); }
			# ヒットがない場合
			#if(!$flag){ &error("表\示する内容がありません。"); }
	}


return(\%self);

}

no strict;
use Time::Local;

#-----------------------------------------------------------
# リスト内容を取得７ （ 総レス数 ）
#-----------------------------------------------------------

sub get_list_allpost{

my($max,$i);
our($myadmin_flag,$submode3);
my($my_account) = Mebius::my_account();

	if($my_account->{'admin_flag'}){
			if($submode3 eq "all"){
				$max = 356*5;
			} else {
				$max = 4*7;
			}
	} else {
		$max = 7;
	}


# 年月定義
my $nowtime = $time;

# CSS定義
$css_text .= qq();

# 表示リスト整形（前）
if($kflag){  }
else{ $line .= qq(<table summary="$ptitleのリスト" class="newlist"><tr><th class="date">日付</th><th>総レス数</th><th>総文字数</th><th>文字数平均</th></tr>\n); }

	# 展開
	for(1...$max){
		$i++;
		my($day,$month,$year) = (localtime($nowtime))[3..5];
		$year += 1900;
		$month += 1;
		my($res,$length,$average,$wday) = get_allpost("${year}_${month}_${day}");

		# 曜日
		my($view_wday);
			if($wday eq "日"){ $view_wday = qq((<span style="color:#f00;">$wday</span>)); }
			elsif($wday eq "土"){ $view_wday = qq((<span style="color:#00f;">$wday</span>));}
			elsif($wday){ $view_wday = qq((<span style="color:#080;">$wday</span>)); }


		if(!$res){ last; }
		if($kflag){
			#if($i >= 2){ $line .= qq(<hr$main::xclose>); }
			$line .= qq(<div style="background:#ddd;$main::ktextalign_center_in">${year}年 ${month}月${day}日 $view_wday</div>\n);
			$line .= qq(<div style="$main::kpadding_normal_in">$resレス / $length文字 / 平均$average文字</div>\n);
		}
		else{ $line .= qq(<tr><td class="left">${year}年 ${month}月${day}日 $view_wday</td><td>$res</td><td>$length</td><td>$average</td></tr>\n); }
		$nowtime -= 1*24*60*60;
	}

	# 表示リスト整形（後）
	if($kflag){  } else { $line .= qq(</table>); }

}



#-----------------------------------------------------------
# リスト内容を取得７　（ 総レスファイルを取得 ）
#-----------------------------------------------------------
sub get_allpost{

# 宣言
my($file) = @_;

open(ALLPOST_IN,"${int_dir}_reslength/$file.cgi");
my $top = <ALLPOST_IN>; chomp $top;
my($res,$length,$average,$wday) = split(/<>/,$top);
close(ALLPOST_IN);

return($res,$length,$average,$wday);

}

#-----------------------------------------------------------
# リスト内容を取得８ （ ＰＶランキング ）
#-----------------------------------------------------------
sub get_list_pv{

# 局所化
my($type) = @_;
my(@line,$viewpv,$pv_handler,$file);

if($type =~ /Normal/){ $file = "${main::int_dir}_sinnchaku/rank_pv.log"; }
elsif($type =~ /Search/){ $file = "${main::int_dir}_sinnchaku/rank_spv.log"; }
else{ return(); }

# CSS定義を追加
$css_text .= qq(
th.num{}
td.num{}
);

# 表示リスト整形（前）
if($kflag){ $line .= qq(<ul>); }
else{ $line .= qq(<table summary="$ptitleのリスト" class="newlist"><tr><th class="sub">記事名</th><th class="bbs">掲示板</th></tr>\n); }

# ファイル読み込み
open($pv_handler,"$file");
chomp(my $top1 = <$pv_handler>); 
while(<$pv_handler>){ push(@line,$_); }
close($pv_handler);

# ファイル読み込み
foreach(@line){
$i++;

if($i < ($submode3 - 1)*$view_max){ next; }
if($i >= $view_max + $view_max * ($submode3 - 1)){ last; }

chomp;
my($key,$num,$moto,$title,$no,$sub) = split(/<>/,$_);

if($admin_mode || $myadmin_flag >= 5){ $viewpv = qq( ( ${num} )); }
if($kflag){ $line .= qq(<li><a href="/_$moto/$no.html">$sub</a> - <a href="/_$moto/">$title</a></li>); }
else{ $line .= qq(<tr><td><a href="/_$moto/$no.html">$sub</a>$viewpv</td><td><a href="/_$moto/">$title</a></td></tr>\n); }
}

# 表示リスト整形（後）
if($kflag){ $line .= qq(</ul>); }
else{ $line .= qq(</table>); }

}


#-----------------------------------------------------------
# リスト内容を取得９ （ 注意投稿 ）
#-----------------------------------------------------------
sub get_list_echeck{

# 局所化
my($flag,$i,$file);

# ロボット避け
$main::noindex_flag = 1;

$file = "${main::int_dir}_sinnchaku/rcevil.log";

# CSS定義を追加
$css_text .= qq(
th.type{width:4.5em;}
td.num{}
td.sub{line-height:1.4em;}
div.comment{word-break:break-word;width:50em;line-height:1.2em;}
del{color:#555;}
);

# 監視キーワード
my @keywords = ('メアド','電話','手紙','文通','住所','本名','℡','メール','じぇーぴー','ジェーピー','tel','ドット','どっと');
my @keywords2 = ('死ね','ウザい','うざい','セックス');

# 表示リスト整形（前）
if($kflag){ $line .= qq(<ul>); }
else{ $line .= qq(<table summary="$ptitleのリスト" class="newlist"><tr><th class="sub">各種データ</th><th>コメント</th></tr>\n); }

# ファイル読み込み
open(IN,"$file");
while(<IN>){
my($mark,$comline);
$i++;

if(!$category_flag){
if($i < ($submode3 - 1)*$view_max){ next; }
if($i >= $view_max + $view_max * ($submode3 - 1)){ last; }
}

chomp;
my($key,$typename,$title,$url,$sub,$handle,$comment,$resnumber,$lasttime,$dat,$category,undef,$echeck_flag2) = split(/<>/);
my($resurl,$moto2);

$resurl = $url;
if($url =~ /_([a-z0-9]+)\//){ $moto2 = $1; }

# ＵＲＬ整形
if($admin_mode){
$url =~ s/http:\/\/([a-z0-9\.]+)\/_([a-z0-9]+)\/([0-9]+)(|_data|_memo)\.html(|\-)($|([0-9,]+))/http:\/\/$1\/jak\/$2.cgi?mode=view&amp;no=$3/;
$resurl = "$url#S$6";
$moto2 = $2;
}

	# コメント整形
	foreach $tmp (split(/<br$xclose>/,$comment)){
	my($hit);

	if($moto2 ne "cnr"){
	foreach $keyword (@keywords){
	($hit) += ($tmp =~ s/(\Q$keyword\E)/<strong class="red">$1<\/strong>/g);
	}
	}

	foreach $keyword2 (@keywords2){
	($hit) += ($tmp =~ s/(\Q$keyword2\E)/<strong class="red">$1<\/strong>/g);
	}

	if($hit){ $comline .= qq($tmp<br$xclose>); }
	}
	$comment = $comline;

	if($echeck_flag2){ $comment = $echeck_flag2; }


if($sub eq ""){ $sub = "ページ"; }
if($key eq "2"){ $comment = qq(<del>$comment</del>); }
if($No eq ""){ $No = 0; }
if($kflag){ $line .= qq(<li>$typename？<a href="$url">$sub</a>   - <a href="/_$moto2/">$title</a> - $name - $dat</li>); }
else{ $line .= qq(<tr><td class="sub valign-top"><a href="$url">$sub</a> <a href="$resurl">( $handle )</a> <br$xclose> <a href="/_$moto2/">$title</a><br$xclose>$dat</td><td class="valign-top"><div class="comment">$comment</div></td></tr>\n); }
}
close(IN);

# 表示リスト整形（後）
if($kflag){ $line .= qq(</ul>); } else { $line .= qq(</table>); }

}


# パッケージ宣言
use strict;
package Mebius::Newlist;
use Mebius::Export;


#-----------------------------------------------------------
# リスト内容を取得４ （ 金貨ランキング ）
#-----------------------------------------------------------
sub goldranking{

# 局所化
my($type,$maxview_index,$nowpage_number,$postdata) = @_;
my($pgold,$paccount,$phandle,$pencid,$pkaccess_one,$pkaccess) = split(/<>/,$postdata);
my($pkaccesses) = ("$pkaccess_one-$pkaccess") if($pkaccess_one && $pkaccess);
my($init_directory) = Mebius::BaseInitDirectory();
my($use,@line,@renewline,$index_line,$logfile,$FILE1,$i,$top1,$maxline_renew,$under_gold);
my($still_flag,$toper_gold,$under_gold,$maxrenew_index,$guide1,$your_rank,$hit_index,$max_pagelinks,%self,$file1);
our($xclose);

	# ファイル更新処理で、必要な入力データが足りない場合
	if($type =~ /RENEW/){
			if($pgold eq ""){ return(); }
			if($pgold < 50){ return(); }
			if($paccount eq "" && $pkaccesses eq ""){ return(); }
	}

	# CSSを定義
	if($type =~ /INDEX/){
		$main::css_text .= qq(i{background:#f90;});
	}

	# １ページあたりの最大”表示”行数の設定
	if(!$maxview_index){
			if($type =~ /MOBILE/){ $maxview_index = 50; }
			else{ $maxview_index = 100; }
	}

# 最大”登録”行数の設定
$maxrenew_index = 1000;

# ページめくりの最大ページ数
$max_pagelinks = 10;

	# ファイル定義、タイプがない場合はこのままリターン
	if($type =~ /GOLD/){ $file1 = "${init_directory}_sinnchaku/goldranking.log"; }
	elsif($type =~ /SILVER/){ $file1 = "${init_directory}_sinnchaku/silverranking.log"; }
	else{ return(); }

# CSS定義を追加
$main::css_text .= qq(
.your_rank{font-size:150%;font-weight:bold;color:#f00;}
th.rank{width:5%;}
);

	# ファイルを開く
	if($type =~ /File-check-error/){
		$self{'f'} = open($FILE1,"+<",$file1) || &main::error("ファイルが存在しません。");
	}
	else{

		$self{'f'} = open($FILE1,"+<",$file1);

			# ファイルが存在しない場合
			if(!$self{'f'}){
					# 新規作成
					if($type =~ /RENEW/){
						Mebius::Fileout("Allow-empty",$file1);
						$self{'f'} = open($FILE1,"+<",$file1);
					}
					else{
						return(\%self);
					}
			}

	}

	# ファイルロック
	if($type =~ /RENEW/){ flock($FILE1,2); }

# トップデータを分解
$top1 = <$FILE1>; chomp $top1;
my($tkey,$tlasttime,$tres,$ttoper_gold,$tunder_gold) = split(/<>/,$top1);

	# ファイルを更新する場合の、トップデータに対する処理
	if($type =~ /RENEW/){

		# 最低ランカーより金貨枚数が少ない場合、かつファイルが最大登録数に近い場合、ファイルハンドラを閉じてリターン
		if($pgold < $tunder_gold && $tres >= $maxrenew_index - 5){ close($FILE1); return(); }

	}

	# ファイルを展開して配列に代入
	while(<$FILE1>){ push(@line,$_); }

	# 取得したインデックス配列を展開
	foreach(@line){

	# ラウンドカウンタ
	$i++;

	# 局所化
	chomp;
	my($view_encid2,$yourrank_flag,$yourrank_class);

	# この行を分解
	my($key2,$gold2,$account2,$handle2,$encid2,$kaccesses2) = split(/<>/,$_);

		# キーがなければ次回処理へ
		if($key2 ne "1"){ next; }

		# ○ファイル更新用の処理
		if($type =~ /RENEW/){

			# 登録最大数
			if($i > $maxrenew_index){ last; }

			# 自分の登録を見つけた場合、金貨枚数を更新（アカウント）
			if($paccount){
				if($account2 && $account2 eq $paccount){ $gold2 = $pgold; $still_flag = 1; }
			}
	
			# 自分の登録を見つけた場合、金貨枚数を更新（固体識別番号）
			elsif($pkaccesses){
				if($kaccesses2 && $kaccesses2 eq $pkaccesses){ $gold2 = $pgold; $still_flag = 1; }
			}

		# インデックスの更新行を追加
		push(@renewline,"$key2<>$gold2<>$account2<>$handle2<>$encid2<>$kaccesses2<>\n");

			# ランキング内の最高枚数/最低枚数を記憶
			if($gold2 > $toper_gold){ $toper_gold = $gold2; }
			if($gold2 <= $under_gold || !$under_gold){ $under_gold = $gold2; }

		}

		# ○インデックス表示用の処理
		elsif($type =~ /INDEX/){

			# ヒットカウンタ
			$hit_index++;

			# 自分の現在順位を取得
			if($account2 eq $main::pmfile && $account2){ $your_rank = $i; $yourrank_flag = 1; }

			# ページめくり
			if($hit_index < ($nowpage_number - 1)*$maxview_index){ next; }
			if($hit_index >= $maxview_index + $maxview_index * ($nowpage_number - 1)){ next; }

			# 表示行の整形
			if($account2){ $handle2 = qq(<a href="${main::auth_url}$account2/">$handle2 - $account2</a>); }
			else{ $view_encid2 = qq(<i>★$encid2</i>); }
			if($yourrank_flag){ $yourrank_class = qq( class="your_rank"); }

			# インデックスの表示行を追加
			if($type =~ /MOBILE/){ $index_line .= qq(<li>$i位 - $handle2$view_encid2 - $gold2枚</li>); }
			else{ $index_line .= qq(<tr><td$yourrank_class>$i位</td><td>$handle2$view_encid2</td><td>$gold2枚</td></tr>\n); }

		}
	}

	# ループを抜けた後のファイル更新処理
	if($type =~ /RENEW/){

		# インデックス登録がなければ、新しく追加
		if(!$still_flag){ unshift(@renewline,"1<>$pgold<>$paccount<>$phandle<>$pencid<>$pkaccesses<>\n"); }

		# 金貨を枚数順にソート ( 1A )
		if($type =~ /RENEW/){ @renewline = sort { (split(/<>/,$b))[1] <=> (split(/<>/,$a))[1] } @renewline; }
		
		# トップデータを追加 ( 1B )
		if($tkey eq ""){ $tkey = 1; }
		unshift(@renewline,"$tkey<>$main::time<>$i<>$toper_gold<>$under_gold<>\n");

		# ファイルを更新
		seek($FILE1,0,0);
		truncate($FILE1,tell($FILE1));
		print $FILE1 @renewline;
	}

# ファイルを閉じる
close($FILE1);

	if($type =~ /RENEW/){ Mebius::Chmod(undef,$file1); }

	# ▽インデックスを整形
	if($type =~ /INDEX/){

		# 携帯版
		if($type =~ /MOBILE/){
		$index_line = qq(<ul>$index_line</ul>);
		}

		# ＰＣ版
		else{
			$index_line = qq(<table summary="新着レスのリスト" class="newlist"><tr><th class="rank">順位</th><th class="sub">筆名</th><th class="bbs">枚数</th></tr>\n$index_line\n</table>);
		}

	}

	# ▽あなたのランキング
	if($type =~ /INDEX/){
		if($type =~ /GOLD/){ $guide1 .= qq(掲示板に書き込むと、文字数に応じて金貨が増えます。アカウントにログイン中や、一部の携帯電話ではランキングに登録されます。); }
		elsif($type =~ /SILVER/){ $guide1 = qq(銀貨は、あなたが純粋に稼いだ枚数です。アカウントにログイン中や、一部の携帯電話ではランキングに登録されます。); }
		if($your_rank){ $guide1 .= qq(あなたのランキングは <strong class="red">$your_rank位</strong> です。); }
	}

# リターン
return($index_line,$guide1,$max_pagelinks);

}



#-----------------------------------------------------------
# 新着タグ
#-----------------------------------------------------------
sub tag{

# 局所化
my($type,$searchword,$maxview_line,$postdata) = @_;
my($ptagname,$penctagname,$ptagnum) = split(/<>/,$postdata);
my($file,$filehandle1,$tagline,$i,$link1,$hit);
my($line,$guide1,$form_name,@renewline,$filehandle1);

	# リターン
	if($main::secret_mode){ return; }

	# 検索モードでキーワードが無い場合
	#if($type =~ /SEARCH/ && $searchword eq ""){ return(); }

	# 最大表示行数を設定
	if(!$maxview_line){
		if($type =~ /MOBILE/){ $maxview_line = 30; }
		else{ $maxview_line = 300; }
	}

# ファイル定義
$file = "${main::int_dir}_sinnchaku/alltag.log";

# CSSを定義
$main::css_text .= qq(
div.newtag{margin:1em 0em 0em 0em;font-size:100%;word-spacing:0.4em;line-height:1.8em;}
.notice1{}
.notice2{font-size:125%;font-weight:bold;}
.notice3{font-size:140%;font-weight:bold;}
.notice4{font-size:170%;font-weight:bold;}
.notice5{font-size:210%;font-weight:bold;}
.notice6{font-size:210%;font-weight:bold;color:#080;}
.notice7{font-size:210%;font-weight:bold;color:#f55;}
);


	#ファイルがなければ作る
	if($type =~ /RENEW/ && !-e $file){ Mebius::Fileout("NEWMAKE",$file); }

	# 新しく追加する行
	if($type =~ /RENEW/ && $type =~ /NEWLIST/){ push(@renewline,"$ptagnum<>$ptagname<>$penctagname<>\n"); }

# マイタグファイルを開く
open($filehandle1,"+<$file");

	# ファイルロック
	if($type =~ /RENEW/){ flock($filehandle1,2); }

	# ファイルを展開
	while(<$filehandle1>){

		# 行を分解
		chomp;
		my($tagnum2,$tagname2,$enctagname2) = split(/<>/);

		# 局所化
		my($class);
		$i++;

			# ○ ファイルを更新する場合
			if($type =~ /RENEW/){
				if($i >= 5000){ last; }											# 登録最大行数に達した場合
				if($type =~ /NEWLIST/ && $tagname2 eq $ptagname){ next; }		# 登録タグとこの行のタグが同じものの場合
				else{ push(@renewline,"$tagnum2<>$tagname2<>$enctagname2<>\n"); }
			}

			# ○インデックス行を取得
			if($type =~ /INDEX/){

				# 最大表示行数
				if($maxview_line && $hit >= $maxview_line){ last; }

				# ワード検索
				if($type =~ /SEARCH/){
					if($searchword eq ""){ last; }
					if(index($tagname2,$searchword) >= 0){ } else { next; }
				}

				# 登録数に応じてタグ文字を大きくする
				if($type =~ /INDEX/ && $type !~ /MOBILE/){
					if($tagnum2 < 5){ }
					elsif($tagnum2 < 25){ $class = qq( class="notice2"); }
					elsif($tagnum2 < 50){ $class = qq( class="notice3"); }
					elsif($tagnum2 < 100){ $class = qq( class="notice4"); }
					elsif($tagnum2 < 250){ $class = qq( class="notice5"); }
					elsif($tagnum2 < 500){ $class = qq( class="notice6"); }
					else{ $class = qq( class="notice7"); }
				}

				# ヒットカウンタ
				$hit++;

				# 行を整形
				if($type =~ /INDEX/){
					if($main::admin_mode){ $line .= qq(<a href="${main::main_url}?mode=tag-$main::submode2-v-$enctagname2"$class>$tagname2</a>\n); }
					else{ $line .= qq(<a href="tag-$main::submode2-v-$enctagname2.html"$class>$tagname2</a>\n); }
				}

			}

	}

	# ファイルを更新
	if($type =~ /RENEW/){
		seek($filehandle1,0,0);
		truncate($filehandle1,tell($filehandle1));
		print $filehandle1 @renewline;
	}

# ファイルを閉じる
close($filehandle1);

	# パーミッション変更
	if($type =~ /RENEW/){ Mebius::Chmod(undef,$file); }

	# インデックスを整形
	if($type =~ /INDEX/){
		if($line){ $line = qq(<div class="newtag">$line</div>); }
		else{ 	$line = qq(<div class="newtag not_hit">ヒットしませんでした。</div>); $hit = 0; }
	}

	# 検索ボックスにフォーカスを当てる
	if($type =~ /INDEX/){ $main::body_javascript = qq( onload="document.TAGSEARCH.word.focus()"); }

# リターン
return($line,$guide1,$hit);

}

#-----------------------------------------------------------
# 全ての記事 (または全てのレス)を取得 / 更新
#-----------------------------------------------------------
sub threadres{

# 宣言
my($type,$searchword,$maxview_line,$nowpage,$postdata,$sc2,@buffer_line) = @_;
my(undef,$duplication_comment) = @_;
my($my_use_device) = Mebius::my_use_device();
my($none,@unlinks) = @_ if($type =~ /UNLINK/);
my($prealmoto,$ptitle,$ppostnumber,$presnumber,$psubject,$phandle,$pcomment,$pcategory,$paccount,$pencid,$palert_type) = split(/<>/,$postdata);
my($i,$i_index,$i_index_foreach,$i_index_pagelinks,$pagelinks,$i_oneline,$i_comment2,$hit_roop_comment2,$hit_oneline,$one_line,$filehandle1,$top1,$hit_index,$hit_index_foreach,$hit_oneline,$index_line,$logfile,@renewline,@over_buffer_line,$newkey);
my($maxline_renew,$maxline_renew_buffer,$buffer_over_flag,$search_form,$comment2_hitword,@index_line,$unlinks,$duplication_flag,$i_duplication,$duplication_thread);

	# ファイル更新時の汚染チェック ( バッファファイルの引継ぎ )
	if($type =~ /Over/){
		if(@buffer_line <= 0){ return(); }
	}

	# ファイル更新時の汚染チェック ( 普通の投稿データ )
	elsif($type =~ /RENEW/){
		$ppostnumber =~ s/\D//g;
		$presnumber =~ s/\D//g;
		$prealmoto =~ s/\W//g;
			if($ppostnumber eq ""){ return(); }
			if($prealmoto eq ""){ return(); }
			if($presnumber eq "" && $type =~ /RES/){ return(); }
	}

	# ファイル削除時のチェック
	if($type =~ /UNLINK/){
		if(@unlinks <= 0){ return(); }
	}

	# リターン
	if($main::secret_mode){ return; }
	if(!$main::alocal_mode && ($prealmoto eq "test" || $prealmoto eq "test2")){ return; }

	# 検索モードでキーワードが無い場合
	#if($type =~ /SEARCH/ && $searchword eq ""){ return(); }

	# 引数から絞り込み対象を定義
	if($sc2 =~ /subject/){ $type .= " SUBJECT"; }
	if($sc2 =~ /handle/){ $type .= " HANDLE"; }
	if($sc2 =~ /account/){ $type .= " ACCOUNT"; }
	if($sc2 =~ /date/){ $type .= " DATE"; }
	if($sc2 =~ /comment/){ $type .= " COMMENT"; }
	if($sc2 =~ /id/){ $type .= " ID"; }
	if($sc2 =~ /title/){ $type .= " TITLE"; }

	# 検索モードで、絞込み指定がなしの場合、全対象から検索するように
	if($type =~ /SEARCH/ && $type !~ /(SUBJECT|HANDLE|ACCOUNT|DATE|COMMENT|ID|TITLE)/){ $type .= qq( SUBJECT HANDLE ACCOUNT DATE COMMENT ID TITLE); }	

	# 設定 - インデックスの最大表示行数 ( 引継ぎ値がない場合 )
	if($type =~ /INDEX/ && !$maxview_line){
			if($type =~ /MOBILE/){ $maxview_line = 20; }
			else{ $maxview_line = 50; }
	}

	# 設定 - 現在のページ数 ( 引継ぎ値がない場合 )
	if(!$nowpage){ $nowpage = 1; }

	# 設定 - ログファイルに記録する最大行数
	if($type =~ /THREAD/){
		$maxline_renew = 5000;
	}
	elsif($type =~ /RES/){
		if($type =~ /Buffer/){
			$maxline_renew_buffer = 100;	# この行数が溜まったら、本ファイルにデータを引き継ぐ
			$maxline_renew = 500;			# バッファファイルとして記録する最大行数
		}
		else{ $maxline_renew = 5000; }
	}
	elsif($type =~ /From-other-site-file/){
		$maxline_renew = 500;
	}
	elsif($type =~ /ECHECK/){
		$maxline_renew = 500;
	}

	# CSS定義（ワード検索）
	if($type =~ /SEARCH/ && $searchword){
		$main::css_text .= qq(strong.hit{});
	}

	# CSS定義（インデックス表示）
	if($type =~ /INDEX/){
		$main::css_text .= qq(
		div.comment2{padding:0.25em 0.5em;margin:0.35em 1em;font-size:95%;line-height:1.4em;background:#dee;}
		div.search_url{padding:0em 0em 1em 0em;}
		a.search_url{color:#080;}
		a.search_plus{font-size:90%;}
		table{font-size:100%;}
		div.not_hit{font-style:italic;color#333;font-size:95%;}
		);
	}

	# ファイル更新時、キーを非表示にする場合
	if($type =~ /RENEW/){
			if($type =~ /Hidden-from-top/){ $newkey .= qq( Hidden-from-top); }
			elsif($main::in{'sex'} || $main::in{'vio'}){ $newkey .= qq( Hidden-from-top); }
			elsif($psubject =~ m!//!){ $newkey .= qq( Hidden-from-top); }
			elsif($psubject =~ /(性|暴\|グロ|BL|GL|ＢＬ|ＧＬ)/){ $newkey .= qq( Hidden-from-top); }
			elsif($main::bbs{'concept'} =~ /Sousaku-mode/ && $psubject =~ /(イジメ|いじめ|虐め|苛め|残酷|流血)/){ $newkey .= qq( Hidden-from-top); }
			elsif($main::concept =~ /NOT-NEWS/){ $newkey .= qq( Hidden-from-top); }
			else{ $newkey = 1; }
	}

	# ファイル定義
	if($type =~ /THREAD/){
		$logfile = "${main::int_dir}_sinnchaku/allthread.log";
	}
	elsif($type =~ /RES/){
		if($type =~ /Buffer/){ $logfile = "${main::int_dir}_sinnchaku/allres_buffer.log"; } # バッファファイル
		else{ $logfile = "${main::int_dir}_sinnchaku/allres.log"; }							# 本ファイル
	}
	elsif($type =~ /ECHECK/){
		$logfile = "${main::int_dir}_sinnchaku/echeck.log";
	}
	elsif($type =~ /From-other-site-file/){
		$logfile = "${main::int_dir}_sinnchaku/from_othersite_bbs_res.log";
	}
	else{ return; }

	# ファイルがなければ作成
	if(!-e $logfile){ Mebius::Fileout("NEWMAKE",$logfile); }

# ファイルを開く
open($filehandle1,"+<$logfile");

	# ファイルロック
	if($type =~ /(RENEW|UNLINK)/){ flock($filehandle1,2); }

# トップデータを取得、分解
$top1 = <$filehandle1>; chomp $top1;

# トップデータを追加
my($tkey,$tlasttime,$tcount,$tdate) = split(/<>/,$top1);

	# バッファファイル処理の場合、メインファイル更新のフラグを立てる 
	if($type =~ /RENEW/ && $type =~ /Buffer/){
			if($tcount && $tcount % $maxline_renew_buffer == 0){ $buffer_over_flag = 1; }
	}

	# トップデータを追加
	if($type =~ /(RENEW|UNLINK)/){
		if($tkey eq ""){ $tkey = 1; }
	$tcount++;
	push(@renewline,"$tkey<>$main::time<>$tcount<>$main::date<>\n");
	}

	# 新しく追加する行
	if($type =~ /RENEW/){

		# バッファファイルから引継ぎがある場合
		if($type =~ /Over/ && @buffer_line){
			push(@renewline,@buffer_line);
		}

		# 投稿データから１行追加の場合
		else{
	push(@renewline,"$newkey<>$prealmoto<>$ptitle<>$ppostnumber<>$psubject<>$phandle<>$pcomment<>$presnumber<>$main::time<>$main::date<>$pcategory<>$paccount<>$pencid<>$palert_type<>\n");
		}

	}

	# ●ファイルを展開
	while(<$filehandle1>){

		my(%data);

	# 処理カウンタ
	$i++;

	# この行を分解
	chomp;
	my($key2,$realmoto2,$title2,$postnumber2,$subject2,$handle2,$comment2,$resnumber2,$time2,$date2,$category2,$account2,$encid2,$alert_type2) = split(/<>/);
	($data{'key'},$data{'bbs_kind'},$data{'title'},$data{'thread_number'},$data{'subject'},$data{'last_handle'},$data{'comment'},$data{'res_number'},$data{'last_regist_time'},$data{'date'},$data{'category'},$data{'account'},$data{'id'},$data{'alert_type'}) = split(/<>/);

		# ○本文を重複チェックをする場合
		if($type =~ /Duplication-check/){
			$i_duplication++;
			#if($i_duplication >= 200){ last; }	# 一定以上の行数になったら、判定終了
			if($main::time >= $time2 + 30*60){ last; }	# 一定時間以上前のレスになったら、判定終了
			#if($duplication_flag){ next; }

			my($flag) = Mebius::Text::Duplication("",$duplication_comment,$comment2);
			if($flag){
				$duplication_flag = $flag;
				$duplication_thread = qq(<a href="/_$realmoto2/$postnumber2.html#S$resnumber2">$subject2</a>);
			}
		}

		# ○ファイル更新の場合、各行を追加
		if($type =~ /(RENEW|UNLINK)/){

			# 最大”取得”行数を処理し終えた場合
			if($i >= $maxline_renew){ last; }

			# 行を削除する場合
			if($type =~ /UNLINK/ && $key2 !~ /Deleted/){
					foreach $unlinks (@unlinks){
						if($unlinks eq ""){ next; }
						# １記事に属する、全てのレスを削除する場合
						if($type =~ /RES/ && $type =~ /UNLINK-ALL/ && "$realmoto2-$postnumber2" eq $unlinks){ $key2 .= qq( Deleted); }
						# 普通にレスや記事を削除
						if("$realmoto2-$postnumber2-$resnumber2" eq $unlinks){ $key2 .= qq( Deleted); }
					}
			}
			
		# この行を追加
		push(@renewline,"$key2<>$realmoto2<>$title2<>$postnumber2<>$subject2<>$handle2<>$comment2<>$resnumber2<>$time2<>$date2<>$category2<>$account2<>$encid2<>$alert_type2<>\n");

				# バッファファイルから引継ぐ行を追加
				if($type =~ /Buffer/ && $buffer_over_flag && $i <= $maxline_renew_buffer){
		push(@over_buffer_line,"$key2<>$realmoto2<>$title2<>$postnumber2<>$subject2<>$handle2<>$comment2<>$resnumber2<>$time2<>$date2<>$category2<>$account2<>$encid2<>$alert_type2<>\n");
				}

		}

		# ○１行表示を取得
		if($type =~ /ONELINE/){
				$i_oneline++;
				if($hit_oneline >= $maxview_line){ last; }		# 最大"表示"行数をヒットし終えたとき
				if($type =~ /Fillter/ && $key2 =~ /Hidden-from-top/){ next; }	# トップページなどでフィルタをかける(性的/ショッキングな記事をエスケープ)
				if($key2 =~ /Deleted/){ next; }
				if($hit_oneline >= 1){ $one_line .= qq( ｜ ); }
			$one_line .= qq(<a href="/_$realmoto2/$postnumber2.html" class="oneline$i_oneline">$subject2</a>);
			$one_line .= qq( ( <a href="/_$realmoto2/$postnumber2.html#S$resnumber2">$handle2</a> ) );
			$one_line .= qq( - <a href="/_$realmoto2/" class="green">$title2</a> );
			$hit_oneline++;
		}

	# インデックス用の局所化
	my($hitpoint,$comment2_split,$comment2_length,$comment2_length_search,$view_comment2);

		# ○インデックスの表示配列を取得
		if($type =~ /INDEX/){

				# 共通の終了処理
				if($key2 =~ /Deleted/){ next; }

				# 処理行数をカウント
				$i_index++;

					# キーワード検索をする場合 ( 無限行を処理 )
					if($type =~ /SEARCH/){

						# 終了処理、次回処理
						if($searchword eq ""){ last; }	# 検索語がない場合、ループを終了

						# 局所化
						my($keyword,$hitflag,$keyword_num,$searchword_buf);
						my($subject2_hit,$handle2_hit,$account2_hit,$encid2_hit,$date2_hit,$comment2_hit,$other_comment2_hit);
						my($title2_hit);

						# 全角スペースなどを半角スペースに変換
						$searchword_buf = $searchword;
						$searchword_buf =~ s/(　|\s)/ /g;

						# 半角スペース区切りでキーワードを展開
						foreach $keyword (split(/ /,$searchword_buf)){

							if($searchword eq ""){ last; }		# 検索語がない場合
							if($keyword eq ""){ next; }			# このループのキーワードが無い場合
							$keyword_num++;						# キーワード個数を計算、加算

							# 題名がヒット
							if($type =~ /SUBJECT/ && index($subject2,$keyword) >= 0){
								$subject2_hit++;
								$hitflag++;
								$hitpoint += 2;
							}

							# 筆名がヒット
							if($type =~ /HANDLE/ && index($handle2,$keyword) >= 0){
								$handle2_hit++;
								$hitflag++;
								$hitpoint += 1;
							}

							# アカウント名がヒット
							if($type =~ /ACCOUNT/ && index($account2,$keyword) >= 0){
								$account2_hit++;
								$hitflag++;
								$hitpoint += 3;
							}

							# ＩＤがヒット
							if($type =~ /ID/ && length($searchword) >= 4){
									if(index($encid2,$keyword) >= 0 || index("★$encid2",$keyword) >= 0){
										$encid2_hit++;
										$hitflag++;
										$hitpoint += 3;
									}
							}

							# 掲示板名がヒット
							if($type =~ /TITLE/ && length($searchword) >= 4 && index($title2,$keyword) >= 0){
								$title2_hit++;
								$hitflag++;
								$hitpoint += 0.5;
							}

							# 日付がヒット
							if($type =~ /DATE/ && length($searchword) >= 4 && index($date2,$keyword) >= 0){
								$date2_hit++;
								$hitflag++;
								$hitpoint += 5;
							}

							# 本文がヒット
							if($type =~ /COMMENT/){

								# 本文を展開
								foreach $comment2_split (split(/(<br>| |　|、|。)/,$comment2)){

									# 行がカラの場合は処理しない
									if($comment2_split =~ /^(<br>| |　|、|。|)$/){ next; }

									# 表示文字数が超過した場合
									if($comment2_length_search >= 200){ last; }

								# ループカウンタ
								$i_comment2++;
									
									# ヒットした行の場合
									if(index($comment2_split,$keyword) >= 0){
										$comment2_hit++;
										$hitflag++;
										$hit_roop_comment2 = $i_comment2;
										$comment2_length_search += length($comment2_split);
										$view_comment2 .= qq( <strong class="hit">$comment2_split</strong>);
									}

									# ヒットしなかった行の場合
									else{
											if(!$comment2_hit && !$view_comment2){
												$comment2_length_search += length($comment2_split);
												$view_comment2 = $comment2_split;
											}
											elsif($i_comment2 <= $hit_roop_comment2 + 2){
												$comment2_length_search += length($comment2_split);
												$view_comment2 .= qq( $comment2_split);
											}
									}
								}

						# 最終表示を整形
						$view_comment2 =~ s/(<br>)/ /g;
					}
				}

				# 検索終了後の処理 

				#( ヒット数 $hitflag が、半角スペースで区切ったキーワードの”個数”以上であればヒットとする）
				if($hitflag >= $keyword_num){

						# ヒットしたキーワードの強調
						if($subject2_hit){ $subject2 = qq(<strong class="hit">$subject2</strong>); }
						if($handle2_hit){ $handle2 = qq(<strong class="hit">$handle2</strong>); }
						if($account2_hit){ $account2 = qq( - <strong><a href="${main::auth_url}$account2/" class="hit">$account2</a></strong>); } else { $account2 = ""; }
						if(!$encid2_hit){ $encid2 = ""; }
						if($date2_hit){ $date2 = qq(<strong class="hit">$date2</strong>); }
						if($title2_hit){ $title2 = qq(<strong class="hit">$title2</strong>); }
					
					# ヒットポイントを計算
					$hitpoint += $hitflag;
					$hitpoint += int(($maxline_renew - $i) / 100);		# 日付の早さでポイントを追加
				}

				# ヒットしなかった場合、次回処理へ
				else{ next; }
			}

			# キーワード検索をせず、普通に表示する場合
			else{

				# 次回/終了処理
				if($hit_index >= $maxview_line){ last; }		# 最大"表示"行数をヒットし終えたとき
				if($i_index >= 1000){ last; }					# 最大"取得"行数を処理し終えたとき
				if($nowpage =~ /^\d$/ && $i_index > ($nowpage * $maxview_line)){ last; }	# ページめくり１
				if($nowpage =~ /^\d$/ && $i_index <= ($nowpage-1) * $maxview_line){ next; }	# ページめくり２
				if($nowpage =~ /[a-z]/ && $nowpage ne $category2){ next; }					# カテゴリ絞り

			}

			# 検索しなかった場合や、検索しても本文がヒットしなかった場合、本文を展開
			if(!$view_comment2){
				foreach $comment2_split (split(/(<br>| |　|、|。)/,$comment2)){
				$comment2_split =~ s/(　|<br>)//g;
				$comment2_length += (length($comment2_split) ) / 2;
				$view_comment2 .= qq( $comment2_split);
					if($comment2_length >= 100){ last; }
				}
			}

			# ヒットカウンタ
			$hit_index++;

			# インデックス配列を追加
			push @index_line , { data_line => "$hitpoint<>$key2<>$realmoto2<>$title2<>$postnumber2<>$subject2<>$handle2<>$view_comment2<>$resnumber2<>$time2<>$date2<>$category2<>$account2<>$encid2<>$alert_type2<>\n" , data_ref => \%data };

		}

	}

	# ファイルを更新
	if($type =~ /(RENEW|UNLINK)/){
		seek($filehandle1,0,0);
		truncate($filehandle1,tell($filehandle1));
		print $filehandle1 @renewline;
	}

# ファイルを閉じる
close($filehandle1);

	# ▼重複投稿チェックの場合のリターン
	if($type =~ /Duplication-check/){
		return($duplication_flag,$duplication_thread);
	}

	# ▼ログファイルのパーミッションを変更
	if($type =~ /(RENEW|UNLINK)/){ Mebius::Chmod(undef,$logfile); }

	# ▼１行表示を整形してリターン
	if($type =~ /ONELINE/){
		return($one_line);
	}

	# ▼インデックスをソート
	if($type =~ /INDEX/ && $type =~ /SEARCH/){
		@index_line = sort { (split(/<>/,$b))[0] <=> (split(/<>/,$a))[0] } @index_line;
	}

	# ▼取得したインデックスを再展開
	if($type =~ /INDEX/){

		# 配列を展開
		foreach(@index_line){

		# ループカウンタ
		$i_index_foreach++;

		# １行を分解
		chomp;
		my($hitpoint,$key2,$realmoto2,$title2,$postnumber2,$subject2,$handle2,$comment2,$resnumber2,$time2,$date2,$category2,$account2,$encid2,$alert_type2) = split(/<>/,$_->{'data_line'});
		my($view_comment2);

			# 最大"表示"行数をヒットし終えたとき
			if($hit_index_foreach >= $maxview_line){ last; }

			# キーワード検索した場合の次回処理 ( ヒット数を得て、並び替えした後での処理 )
			if($type =~ /SEARCH/){
				if($nowpage =~ /^([\d]+)$/ && $i_index_foreach > ($nowpage * $maxview_line)){ next; }	# ページめくり１
				if($nowpage =~ /^([\d]+)$/ && $i_index_foreach <= ($nowpage-1) * $maxview_line){ next; }# ページめくり２				#if($nowpage =~ /[a-z]/ && $nowpage ne $category2){ next; }							# カテゴリ絞り
			}


			# １行の表示内容を決定（モバイル版）
			if($type =~ /MOBILE/){
				$index_line .= qq(<li>);
				$index_line .= qq(<a href="/_$realmoto2/$postnumber2.html">$subject2</a>);
				$index_line .= qq(( <a href="/_$realmoto2/$postnumber2.html#S$resnumber2">$handle2</a> ));
				$index_line .= qq(</li>);
				
			} elsif($my_use_device->{'smart_phone_flag'}){

				my ($smart_phone_line) = shift_jis(Mebius::BBS::Index::view_thread_menu_core_for_smart_phone($_->{'data_ref'},{ SJIS => 1 , hit_round => $hit_index_foreach }));
				$index_line .= $smart_phone_line;
				
			# １行の表示内容を決定（デスクトップ版）
			 } else{

				my($view_hitpoint) = qq($hitpoint / $i_index_foreach \) ) if($type =~ /SEARCH/ && $main::myadmin_flag >= 5);

				# 整形
				$index_line .= qq(<tr>);

				# 記事名
				$index_line .= qq(<td>);
				$index_line .= qq($view_hitpoint<a href="/_$realmoto2/$postnumber2.html">$subject2</a>);
					if($alert_type2){ $index_line .= qq( <span class="alert">[ $alert_type2？ ] </span>); }
				$index_line .= qq(</td>);

					# 筆名
					if($encid2 && $type =~ /SEARCH/){ $encid2 = qq(<i>★$encid2</i>); } else { $encid2 = ""; }
					if($account2 && $type =~ /SEARCH/){ } else { $account2 = ""; }

					if($type =~ /Admin-view/){
						$index_line .= qq(<td>( <a href="${main::jak_url}$realmoto2.cgi?mode=view&amp;no=$postnumber2#S$resnumber2">$handle2</a>$account2$encid2 )</td>);
					}
					else{
						$index_line .= qq(<td>( <a href="/_$realmoto2/$postnumber2.html#S$resnumber2">$handle2</a>$account2$encid2 )</td>);
					}

				# 掲示板
				$index_line .= qq(<td>( <a href="/_$realmoto2/" class="green">$title2</a> )</td>);
				$index_line .= qq(<td>$date2</td>);
				$index_line .= qq(</tr>\n);

				# 本文
				$index_line .= qq(<tr><td colspan="4"><div class="comment2">$comment2</div></td></tr>\n);


			}

			$hit_index_foreach++;

		}

	}

	# ▼バッファファイルが規定行数に達した場合、本体ファイルを更新 ( 無限ループに注意！ )
	if($type =~ /Buffer/ && $buffer_over_flag){
			if($type =~ /RES/){
				Mebius::Newlist::threadres("RENEW RES Over","","","","","",@over_buffer_line);
			}
	}

	# ▼インデックス行を整形してリターン
	if($type =~ /INDEX/){

		# ヒットした場合
		if($index_line){

			# ページめくりリンクを作成
			if($type =~ /SEARCH/){
				my($move);
					if($type =~ /THREAD/){ $move = qq(#THREAD); }
					elsif($type =~ /RES/){ $move = qq(#RES); }

					for(0..($hit_index/$maxview_line)){
						$i_index_pagelinks++;
							if($i_index_pagelinks > 10){ next; }
						my $postbuf_query_esc2 = $main::postbuf_query_esc;
						$postbuf_query_esc2 =~ s/mode=$main::submode1-$main::submode2-([\d]+)/mode=$main::submode1-$main::submode2-$i_index_pagelinks/g;
							if($i_index_pagelinks == $nowpage){ $pagelinks .= qq($i_index_pagelinks\n); }
							else{ $pagelinks .= qq(<a href="${main::script}?$postbuf_query_esc2$move">$i_index_pagelinks</a>\n); }
					}
				$pagelinks = qq(<div class="allsearch_pagelinks">ページ: $pagelinks</div>);
			}
			
			# 整形 ( モバイル版 )
			if($my_use_device->{'smart_flag'}){
				
			}	elsif($type =~ /MOBILE/){
				$index_line = qq(<ul>$index_line</ul>\n);
			}
			# 整形 ( ＰＣ版 )
			else{
				$index_line = qq(
			<table summary="全ての記事" class="threadres" class="newlist"><tr><th class="sub">記事</th><th class="name">投稿者</th><th class="bbs">掲示板</th><th class="date">時刻</th></tr>$index_line</table>
			\n
			);
			}

		}

		# ヒットしなかった場合
		else{
			$index_line = qq(<div class="not_hit">ヒットしませんでした。</div>);
			$hit_index = 0;
		}
	
	# リターン
	return($index_line,$hit_index);
	}

	# ▼その他のリターン
	else{ return(1); }

}

#-----------------------------------------------------------
# 全検索
#-----------------------------------------------------------
sub allsearch{

# 宣言
my($type,$searchword,$sc1,$sc2) = @_;
my($line,$line_tag,$line_allthread,$line_allres,$hit_tag,$hit_allthread,$hit_allres,$none,$plustype);
my($maxview_tag,$maxview_allthread,$maxview_allres,$google_link,$google_link_mobile,$h2_style);


	# アクセス振り分け ( モバイル版→ＰＣ版 ）
	if($type =~ /MOBILE/){

		my($postbuf_divide) = $ENV{'REQUEST_URI'};
		$postbuf_divide =~ s/mode=allsearch-k-/mode=allsearch-p-/g;
		$main::divide_url = "http://$main::server_domain$postbuf_divide";


			#if($main::device_type eq "desktop"){ main::divide($main::divide_url,"desktop"); }
	}
	# アクセス振り分け ( ＰＣ版→モバイル版 ）
	else{
		my($postbuf_divide) = $ENV{'REQUEST_URI'};
		$postbuf_divide =~ s/mode=allsearch-p-/mode=allsearch-k-/g;
		$main::divide_url = "http://$main::server_domain$postbuf_divide";

			#if($main::device_type eq "mobile"){ main::divide($main::divide_url,"mobile"); }
	}

	# URLをまとめる
	if($main::submode2 eq "k"){
		my($request_url) = Mebius::request_url();
		my $redirect_url = $request_url;
		$redirect_url =~ s/(\?|&)mode=allsearch-k-(\d)/${1}mode=allsearch-p-${2}/g;
		$redirect_url =~ s/allsearch-k-(\d).html$/allsearch-p-$1.html/g;
		Mebius::Redirect(undef,$redirect_url,301);
	}


	# Google検索リンクを定義
	my($enc_searchword) = Mebius::Encode("",$searchword);
	if($type =~ /MOBILE/){
	$google_link_mobile = qq(　<a href="http://www.google.co.jp/m?ie=Shift_JIS&amp;q=$enc_searchword+site%3Amb2.jp" rel="nofollow">→Googleで検索</a>);
	}
	else{
	$google_link = qq(　<a href="http://www.google.co.jp/search?q=$enc_searchword&amp;sitesearch=mb2.jp&amp;ie=Shift_JIS&amp;hl=ja&amp;domains=mb2.jp" rel="nofollow">→Googleで検索</a>);
	}

# h2 の表示スタイルを定義
if($type =~ /MOBILE/){
$h2_style = qq( style="font-size:small;");
}

# 引数から、取得するインデックスの種類を定義 ( このサブルーチン内での処理 )
if($sc1 =~ /tag/){ $type .= " TAG"; }
if($sc1 =~ /thread/){ $type .= " THREAD"; }
if($sc1 =~ /res/){ $type .= " RES"; }

# 検索モードがカラの場合、全モードからインデックスを取得するように
if($type !~ /(TAG|THREAD|RES)/){ $type .= qq(TAG THREAD RES); }

# CSSを定義
$main::css_text .= qq(
h2.hit{font-size:100%;padding:0.3em 0.5em;margin-left:0.75em;background:#fdd;border:solid 1px #f99;width:50%;font-weight:normal;}
div.allsearch_self{margin-left:1.5em;}
div.allsearch_pagelinks{margin:1em;font-size:120%;}
);

# タイトル定義
if($main::in{'word'}){ $main::sub_title = qq(”$searchword”の検索結果 | メビウス検索 | $main::server_domain); }
else{ $main::sub_title = "メビウス検索 | $main::server_domain"; }

	# 最大”表示”行数の渡し値を設定（モバイル版）
	if($type =~ /MOBILE/){
	$maxview_tag = 10;
	$maxview_allthread = 10;
	$maxview_allres = 10;
	}

	# 最大”表示”行数の渡し値を設定（ＰＣ版）
	else{
	$maxview_tag = 30;
	$maxview_allthread = 15;
	$maxview_allres = 15;
	}

	if($searchword){
		main::error("全検索は現在停止中です。");
	}

	# タグから検索
	if($type =~ /TAG/ && $searchword){
	($line_tag,$none,$hit_tag) = Mebius::Newlist::tag("SEARCH INDEX$main::ktype",$searchword,$maxview_tag);
	}

	# タグを整形
	if($line_tag){
	$line_tag = qq(<h2 class="hit" id="TAG"$h2_style>”タグ”から検索： ( $hit_tag件 ) $google_link</h2><div class="allsearch_self">$line_tag</div>$google_link_mobile);
	}

	# 全レスから検索
	if($type =~ /RES/ && $searchword){
	($line_allres,$hit_allres) = Mebius::Newlist::threadres("INDEX RES SEARCH$plustype$main::ktype",$searchword,$maxview_allres,$main::submode3,"",$sc2);
	}

	# 全レスを整形
	if($line_allres){
	$line_allres = qq(<h2 class="hit" id="RES"$h2_style>”新しいレス” から検索： ( $hit_allres件 ) $google_link</h2><div class="allsearch_self">$line_allres</div>$google_link_mobile);
	}
	

	# 全記事から検索
	if($type =~ /THREAD/ && $searchword){
	($line_allthread,$hit_allthread) = Mebius::Newlist::threadres("INDEX THREAD SEARCH$plustype$main::ktype",$searchword,$maxview_allthread,$main::submode3,"",$sc2);
	}

	# 全記事を整形
	if($line_allthread){
	$line_allthread = qq(<h2 class="hit" id="THREAD"$h2_style>”新しい記事” から検索： ( $hit_allthread件 ) $google_link</h2><div class="allsearch_self">$line_allthread</div>$google_link_mobile);
	}

# 最終整形
$line = qq(<div class="allsearch" id="HIT">全検索は現在停止中です。 $line_tag $line_allres $line_allthread</div>);

# アクセスログを取る
if($searchword){ main::access_log("ALLSEARCH","キーワード - $searchword"); }

# リターン
return($line);

}

#-----------------------------------------------------------
# 全検索ボックス
#-----------------------------------------------------------
sub allsearch_form{

# 宣言
my($type,$searchword,$sc1,$sc2,$plus_class,$move) = @_;
my($line,$xclose,$search_mode_input,$submit_value);
my($checkbox_search_mode,$checked_tag,$checked_thread,$checked_res);
my($checkbox_limit,$checked_subject,$checked_handle,$checked_account,$checked_date,$checked_comment,$checked_id,$checked_title,$checked_title);
my($action,$accesskey,$accesskey_mark,$input_size,$plus_idname);

# 検索先のURLを定義
if($main::admin_mode){ $action = "index.cgi"; }

# MOVE 先
if($move){ $move = "#$move"; }

# 引数から検索モードを定義
if($sc1 =~ /tag/){ $type .= " TAG"; }
if($sc1 =~ /thread/){ $type .= " THREAD"; }
if($sc1 =~ /res/){ $type .= " RES"; }

# 検索モードの指定がない場合、全対象のチェックボックスをオンに
#if($type !~ /(TAG|THREAD|RES)/){ $type .= qq( TAG THREAD RES); }

# 引数から絞込み対象を定義
if($sc2 =~ /subject/){ $type .= " SUBJECT"; }
if($sc2 =~ /handle/){ $type .= " HANDLE"; }
if($sc2 =~ /account/){ $type .= " ACCOUNT"; }
if($sc2 =~ /date/){ $type .= " DATE"; }
if($sc2 =~ /comment/){ $type .= " COMMENT"; }
if($sc2 =~ /id/){ $type .= " ID"; }
if($sc2 =~ /title/){ $type .= " TITLE"; }

# 絞込み指定がない場合、全対象のチェックボックスをオンに
#if($type !~ /(SUBJECT|HANDLE|ACCOUNT|DATE|COMMENT|ID)/){ $type .= qq( SUBJECT HANDLE ACCOUNT DATE COMMENT ID); }

	# CSS定義
	if($type =~ /CSS1/){
		$main::css_text .= qq(
		span.allsearch_mode_select{font-size:90%;background:#ddd;padding:0.4em 0.4em;}
		span.allsearch_limit_select{font-size:90%;background:#fdd;padding:0.4em 0.4em;}
		);
	}

	# 検索モード振り分け用チェックボックス
	if($type =~ /SELECT-CHECKBOX/){
		if($type =~ /(TAG)/){ $checked_tag = $main::parts{'checked'}; }
		if($type =~ /(THREAD)/){ $checked_thread = $main::parts{'checked'}; }
		if($type =~ /(RES)/){ $checked_res = $main::parts{'checked'}; }
	$checkbox_search_mode .= qq(<input type="checkbox" name="sc" value="res"$checked_res$xclose> レス\n);
	$checkbox_search_mode .= qq(<input type="checkbox" name="sc" value="thread"$checked_thread$xclose> 記事\n);
	$checkbox_search_mode .= qq(<input type="checkbox" name="sc" value="tag"$checked_tag$xclose> タグ\n);
	$checkbox_search_mode = qq(<span class="allsearch_mode_select">$checkbox_search_mode</span>);
	}

	# 検索モード振り分けけの hidden 値
	elsif($type =~ /SELECT-HIDDEN/){
		if($type =~ /(TAG)/){ $search_mode_input .= qq(<input type="hidden" name="sc" value="tag"$xclose>); }
		if($type =~ /(THREAD)/){ $search_mode_input .= qq(<input type="hidden" name="sc" value="thread"$xclose>); }
		if($type =~ /(RES)/){ $search_mode_input .= qq(<input type="hidden" name="sc" value="res"$xclose>); }
	}

	# 検索対象の絞込み
	if($type =~ /LIMIT-CHECKBOX/){
		if($type =~ /(SUBJECT)/){ $checked_subject = $main::parts{'checked'}; }
		if($type =~ /(HANDLE)/){ $checked_handle = $main::parts{'checked'}; }
		if($type =~ /(ACCOUNT)/){ $checked_account = $main::parts{'checked'}; }
		if($type =~ /(ID)/){ $checked_id = $main::parts{'checked'}; }
		if($type =~ /(DATE)/){ $checked_date = $main::parts{'checked'}; }
		if($type =~ /(COMMENT)/){ $checked_comment = $main::parts{'checked'}; }
		if($type =~ /(TITLE)/){ $checked_title = $main::parts{'checked'}; }
	$checkbox_limit = qq(<input type="checkbox" name="sc2" value="subject"$checked_subject$xclose> 題名\n);
	$checkbox_limit .= qq(<input type="checkbox" name="sc2" value="comment"$checked_comment$xclose> 本文\n);
	$checkbox_limit .= qq(<input type="checkbox" name="sc2" value="handle"$checked_handle$xclose> 筆名\n);
	$checkbox_limit .= qq(<input type="checkbox" name="sc2" value="id"$checked_id$xclose> ＩＤ\n);
	$checkbox_limit .= qq(<input type="checkbox" name="sc2" value="account"$checked_account$xclose> アカウント名\n);
	$checkbox_limit .= qq(<input type="checkbox" name="sc2" value="title"$checked_title$xclose> 掲示板名\n);
	$checkbox_limit .= qq(<input type="checkbox" name="sc2" value="date"$checked_date$xclose> 日付\n);
	$checkbox_limit = qq(　<span class="allsearch_limit_select">$checkbox_limit</span>);
	}

	# 携帯版フッタの場合の整形
	if($type =~ /MOBILE/){
		#$accesskey = qq( accesskey="0");
		#$accesskey_mark = qq(\(0\));
		$input_size = qq( size="8");
		$checkbox_limit = "";
	}

	# 送信ボタン
	if($type =~ /MOBILE/){ $submit_value = "全検索"; }
	else{ $submit_value = "メビウス全検索"; }

# 代入するクラスタグを整形
if($plus_class){
$plus_idname = qq(_$plus_class);
$plus_class = "_" . lc ($plus_class);
}

# 検索ボックスを整形
#$line = qq(
#<form action="http://mb2.jp/_main/$move" id="ALLSEARCH$plus_idname" name="ALLSEARCH$plus_idname" class="allsearch_form$plus_class">
#<div class="allsearch_div$plus_class">
#$accesskey_mark<input type="$main::parts{'input_type_search'}" name="word" value="$searchword" class="allsearch_input$plus_class" placeholder="検索キーワード"$input_size$accesskey$xclose>
#<input type="submit" value="$submit_value" class="allsearch_submit$plus_class"$xclose>
#$checkbox_search_mode
#$checkbox_limit
#$search_mode_input
#<input type="hidden" name="mode" value="allsearch-p-1"$xclose>
#</div>
#</form>
#);


# リターン
return($line);

}

use strict;

#-----------------------------------------------------------
# 最大レス数に達したスレッド
#-----------------------------------------------------------
sub Maxres{

# 宣言
my($type,%thread) = @_;
my(undef,undef,undef,$select_page) = @_;
my($category_handler,$category_logfile,@renewline_category,$duplication_flag);
my($index_line,$i);

# ページあたりの最大表示行数
my $maxview_per_page = 100;

# ファイル定義
$category_logfile = "${main::int_dir}_maxres/${main::category}_maxres_category.log";
$category_logfile = "${main::int_dir}_sinnchaku/maxres.log";

# ファイルを開く
open($category_handler,"<$category_logfile");

	# ファイルロック
	if($type =~ /Renew/){ flock($category_handler,1); }

	# トップデータを分解
	chomp(my $top1 = <$category_handler>);
	my($tkey) = split(/<>/,$top1);

	# ファイルを展開
	while(<$category_handler>){

		# ラウンドカウンタ
		$i++;

		# この行を分解
		chomp;
		my($key2,$category2,$realmoto2,$postnumber2,$res2,$subject2,$title2,$handle2,$time2,$date2) = split(/<>/);

			# ●インデックス取得用
			if($type =~ /Get-index/){

					# ページめくりで次の処理へ
					if($i > $maxview_per_page * $select_page){ next; }
					if($i <= $maxview_per_page * ($select_page-1)){ next; }

				# 表示する行を定義
				$index_line .= qq(<tr>);
				$index_line .= qq(<td><a href="/_$realmoto2/$postnumber2.html">$subject2</a></td>);
				$index_line .= qq(<td><a href="/_$realmoto2/">$title2</a></td>);
				$index_line .= qq(<td>$handle2</td>);
				$index_line .= qq(</tr>\n);
			}

			# ●ファイル更新用
			if($type =~ /Renew/){
					# 同じ記事の場合
					if($realmoto2 eq $main::realmoto && $postnumber2 eq $thread{'postnumber'}){ next; }
				# この行を追加
				push(@renewline_category,"$key2<>$category2<>$realmoto2<>$postnumber2<>$res2<>$subject2<>$title2<>$handle2<>$time2<>$date2<>\n");
			}


	}

close($category_handler);

	# ●ファイルを更新
	if($type =~ /Renew/){

			# 新しく追加する行
			if(!$duplication_flag){
unshift(@renewline_category,"1<>$main::category<>$main::realmoto<>$thread{'postnumber'}<>$thread{'res'}<>$thread{'subject'}<>$main::head_title<>$thread{'posthandle'}<>$main::time<>$main::date<>\n");
			}

		# トップデータを追加
		if($tkey eq ""){ $tkey = 1; }
		unshift(@renewline_category,"$tkey<>\n");

		# ファイル更新
		Mebius::Fileout("",$category_logfile,@renewline_category);
	}

	# ●インデックスをリターン
	if($type =~ /Get-index/){

			if($index_line){
				$index_line = qq(<table summary="記事の一覧" class="newlist">$index_line</table>);
			}

		return($index_line);
	}


}

#-----------------------------------------------------------
# お絵かき一覧
#-----------------------------------------------------------
sub Paint{

# 宣言
use Mebius::Paint;

# 宣言
my($type) = @_;
my(undef,$new_sessionname,$new_image_id,$new_filename,$new_super_id) = @_;
my(undef,undef,undef,$select_page) = @_ if($type =~ /Get-index/);
my($index_line,$maxview_index,$guide1);
my(@renewline,$file,$allpaint_handler,$top1,$renewline_max,$maxsave_time,$i);

# ファイル定義
if($type =~ /Buffer/){ $file = "${main::int_dir}_sinnchaku/paint_buffer.log"; }
elsif($type =~ /Justy/){ $file = "${main::int_dir}_sinnchaku/allpaint.log"; }
else{ return(); }

# 一時画像を保存する最大時間（バッファ用） [ 秒で指定 ]
$maxsave_time = 7*24*60*60;
#if($main::alocal_mode){ $maxsave_time = 60*5; }

# 記録する最大行数(新着一覧)
$renewline_max = 500;

# 表示する最大行数
$maxview_index = 10;

# ファイルを開く
open($allpaint_handler,"<$file");

	# ファイルロック
	if($type =~ /Renew/){ flock($allpaint_handler,1); }

# トップデータを分解
chomp($top1 = <$allpaint_handler>);
my($tkey) = split(/<>/,$top1);

	# トップデータの補完
	if($tkey eq ""){ $tkey = 1; }

	# ファイルを展開
	while(<$allpaint_handler>){

		# ラウンドカウンタ
		$i++;
	
		# この行を分解
		chomp;
		my($key2,$session2,$filename2,$image_id2,$time2,$date2,$addr2,$host2,$agent2,$cnumber2,$super_id2) = split(/<>/);

			# ファイル名を分解
			my($realmoto2,$postnumber2,$resnumber2,$image_tail2) = split(/-/,$filename2);

			# ●インデックス取得用の処理
			if($type =~ /Get-index/){

				# ページめくりで次の処理へ
				if($i > $maxview_index * $select_page){ next; }
				if($i <= $maxview_index * ($select_page-1)){ next; }

				# ハッシュを取得
				my(%image) = Mebius::Paint::Image("Get-hash Justy",undef,undef,$main::server_domain,$realmoto2,$postnumber2,$resnumber2);

					# 表示内容を定義
					if($image{'image_ok'}){

							# サムネイルの表示
							if($main::admin_mode){
								$index_line .= qq(<a href="${main::script}?mode=pallet-viewer-$realmoto2-$postnumber2-$resnumber2">);
							}
							else{
								$index_line .= qq(<a href="${main::main_url}pallet-viewer-$realmoto2-$postnumber2-$resnumber2.html">);
							}

						$index_line .= qq(<img src="$image{'samnale_url'}" class="noborder" style="width:$image{'samnale_width'}px;height:$image{'samnale_height'}px;"$main::xclose>);
						$index_line .= qq(</a>);

							# 投稿先のレスの表示
							if(!$image{'main_type'}){
									if($main::admin_mode){
										$index_line .= qq( <a href="$realmoto2.cgi?mode=view&amp;no=$postnumber2#S$resnumber2">投稿</a>\n);
									}
									else{
										$index_line .= qq( <a href="/_$realmoto2/$postnumber2.html-$resnumber2">投稿</a>\n);
									}
							}
						$index_line .= qq( $date2);
						$index_line .= qq(<br$main::xclose><br$main::xclose>\n);
					}
			}

			# ●ファイル更新用の処理
			if($type =~ /Renew/){

					# 局所化
					my($plustype_delete);

					# 重複したスーパーIDを削除する
					if($super_id2 eq $new_super_id){ $super_id2 = ""; }

					# セッションIDが同じの場合、あとからログファイルが自動削除されないようにする
					if($key2 =~ /Not-delete-logfile/){ $plustype_delete .= qq( Not-delete-logfile); }
					elsif($session2 eq $new_sessionname){ $key2 .= " Not-delete-logfile"; }

					# 最大行数に達した場合、古いバッファファイルを削除して次の処理へ
					if($type =~ /Justy/ && $i + 1 > $renewline_max){
						next;
					}

					# 一定時間更新がない場合、古いバッファファイルを削除して次の処理へ
					if($type =~ /Buffer/ && $main::time >= $time2+$maxsave_time){
							Mebius::Paint::Image("Delete-buffer$plustype_delete",$session2,$image_id2);
							if($super_id2){ Mebius::Paint::Super_id("Delete-file",$super_id2); }
							next;
					}


				# 追加する行
				push(@renewline,"$key2<>$session2<>$filename2<>$image_id2<>$time2<>$date2<>$addr2<>$host2<>$agent2<>$cnumber2<>$super_id2<>\n");

			}
	}

# ファイルを閉じる
close($allpaint_handler);

	# ▼インデックス取得の後処理
	if($type =~ /Get-index/){
		$guide1 = qq(<a href="./pallet.html">→新しい絵を描く</a>);
		return($index_line,$guide1);
	}

	# ▼ファイル更新する場合
	elsif($type =~ /Renew/){

		# 新しい行を追加
		if($type =~ /New/){
			unshift(@renewline,"1<>$new_sessionname<>$new_filename<>$new_image_id<>$main::time<>$main::date<>$main::addr<>$main::host<>$main::agent<>$main::cnumber<>$new_super_id<>\n");
		}

		# トップデータを追加
		unshift(@renewline,"$tkey<>\n");

		# ファイル更新
		Mebius::Fileout("",$file,@renewline);
	}

}



1;


use Mebius::BBS;
use Mebius::BBS::Status;
use Mebius::Vine::Basic;
use Mebius::Tags::Basic;
use Mebius::Question::Basic;
use strict;
package main;

#-----------------------------------------------------------
# 設定取り込み
#-----------------------------------------------------------
sub main_index{

my($my_use_device) = Mebius::my_use_device();
my($init_directory) = Mebius::BaseInitDirectory();

	# アクセス振り分け
	if($my_use_device->{'mobile_flag'}){
		main_index_mobile(@_);
	}
	else{
		main_index_desktop(@_);
	}

}

#-----------------------------------------------------------
# デスクトップ版
#-----------------------------------------------------------
sub main_index_desktop{

# CSSファイル
our $style = "top";
my($init_directory) = Mebius::BaseInitDirectory();
my $gaget = new Mebius::Gaget;
my($my_use_device) = Mebius::my_use_device();

	# スマフォ
	if($my_use_device->{'smart_flag'}){
		$main::css_text .= qq(.google_find_topindex_textinput{width:10em;}\n);
		$main::css_text .= qq(.smart_phone_bbs_list{line-height:2.6;}\n);
	}


# Google検索フォーム
my $allsearch_form = $gaget->google_search_box({ source => "utf8" });
$allsearch_form = qq(<div style="margin:1em 0em;">$allsearch_form</div>);

bbs_topbetax("",undef,$allsearch_form);

}


#-----------------------------------------------------------
# 娯楽版メニュー内容
#-----------------------------------------------------------
sub get_index_goraku{

# 宣言
my($type) = @_;
my($line,$plustype_foreach_index);
my($my_use_device) = Mebius::my_use_device();
my($pc_flag);

	# 表示切り替え
	if($my_use_device->{'smart_phone_flag'}){
		$plustype_foreach_index .= qq( Smart-phone-view);
	}
	elsif($my_use_device->{'mobile_flag'}){
		$plustype_foreach_index .= qq( Mobile-view);
	} else{
		$plustype_foreach_index .= qq( Pc-view);
		$pc_flag = 1;
	}

$plustype_foreach_index .= qq( Get-index);

	if($pc_flag){
		$line .= qq(<table class="width100"><tr><td valign="top" style="width:50%;">);
	}

#my($bbs_data) = Mebius::BBS::Status::all_records_on_hash();
my $bbs_status = new Mebius::BBS::Status;
my $bbs_data = $bbs_status->fetchrow_on_hash_main_table("bbs_kind");

# 各カテゴリのリンクを取得
my($anicomi_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","anicomi",$plustype_foreach_index,$bbs_data);
my($game_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","game",$plustype_foreach_index,$bbs_data);
my($narikiri_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","narikiri",$plustype_foreach_index,$bbs_data),;
my($gokko_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","gokko",$plustype_foreach_index,$bbs_data);
my($etc_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","etc",$plustype_foreach_index,$bbs_data);
my($music_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","music",$plustype_foreach_index,$bbs_data);
my($zatudann2_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","zatudann2",$plustype_foreach_index,$bbs_data);
my($chiiki_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","chiiki",$plustype_foreach_index,$bbs_data);
my($mebi_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","mebi",$plustype_foreach_index,$bbs_data);
my($contact_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","contact",$plustype_foreach_index,$bbs_data);

	# ●スマフォ版
	if($my_use_device->{'smart_flag'} || $pc_flag){

		$line .= qq(<div class="smart_phone_bbs_list">);
		$line .= qq(<hr><a href="/_category/anicomi/" class="b">アニメ/漫画</a> $anicomi_line\n);
		$line .= qq(<hr><a href="/_category/game/" class="b">ゲーム</a> $game_line\n);
		$line .= qq(<hr><a href="/_category/etc/" class="b">ＥＴＣ</a> $etc_line);
		$line .= qq(<hr><a href="/_category/music/" class="b">音楽</a> $music_line\n);
		$line .= qq(<hr><a href="/_category/zatudann2/" class="b">雑談２</a> $zatudann2_line\n);
		$line .= qq(<hr><a href="/_category/narikiri/" class="b">なりきり</a> $narikiri_line\n);
		$line .= qq(<hr><a href="/_category/gokko/" class="b">遊び</a> $gokko_line\n);
		$line .= qq(<hr><a href="/_category/chiiki/" class="b">地域</a> $chiiki_line\n);
		$line .= qq(<hr><a href="/_category/contact/" class="b">交換</a> $contact_line\n);
		$line .= qq(</div>);
	}

	# ●モバイル版
	elsif($my_use_device->{'mobile_flag'}){

		#$line .= qq(<div class="smart_phone_bbs_list">);
		my $style = "text-align:center;background:#ddf;margin:6px 0px 6px 0px;";
		$line .= qq(<div style="$style" id="ANICOMI">アニメ/漫画</div>$anicomi_line\n);
		$line .= qq(<div style="$style" id="GAME">ゲーム</div>$game_line\n);
		$line .= qq(<div style="$style" id="ETC">ＥＴＣ</div>$etc_line);
		$line .= qq(<div style="$style" id="MUSIC">音楽</div>$music_line\n);
		$line .= qq(<div style="$style" id="ZATUDANN">雑談２</div>$zatudann2_line\n);
		$line .= qq(<div style="$style" id="NARIKIRI">なりきり</div>$narikiri_line\n);
		$line .= qq(<div style="$style" id="GOKKO">遊び</div>$gokko_line\n);
		$line .= qq(<div style="$style" id="CHIIKI">地域</div>$chiiki_line\n);
		$line .= qq(<div style="$style" id="CONTACT">交換</div>$contact_line\n);

		#$line .= qq(<div style="$style" id="MEBI">メビ\(表\\)</div> $mebi_line\n);
		#$line .= qq(</div>);

	}

	# ●デスクトップ版
	#else{
	#	$line .= qq(
	#	<table summary="メニュー" class="menu top_page"><tr><td class="td2 valign-top">
	#	<div class="indent1"><a href="/_category/anicomi/" class="b">アニメ/漫画</a><br></div> $anicomi_line
	#	</td><td class="td2 valign-top">
	#	<div class="indent1"><a href="/_category/game/" class="b">ゲーム</a><br></div> $game_line
	#	<hr><div class="indent1"><a href="/_category/etc/" class="b">ＥＴＣ</a><br></div> $etc_line
	#	</td><td class="td2 valign-top">
	#	<div class="indent1"><a href="/_category/music/" class="b">音楽</a><br></div> $music_line
	#	<hr><div class="indent1"><a href="/_category/zatudann2/" class="b">雑談２</a><br></div> $zatudann2_line
	#	</td><td class="td2 valign-top">
	#	<div class="indent1"><a href="/_category/narikiri/" class="b">なりきり</a><br></div> $narikiri_line
	#	<hr><div class="indent1"><a href="http://mb2.jp/_category/chiiki/" class="b">地域</a><br></div> $chiiki_line
	#	</td><td class="td2 valign-top">
	#	<div class="indent1"><a href="/_category/gokko/" class="b">遊び</a><br></div> $gokko_line
	#	<hr><div class="indent1"><a href="http://mb2.jp/_category/mebi/" class="b">メビ(表)</a><br></div> $mebi_line
	#	</td></tr></table>
	#	);

	#}

	if($pc_flag){
		$line .= qq(</td><td valign="top">);
	}


# 各カテゴリのリンクを取得
my($aura_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","aura",$plustype_foreach_index,$bbs_data);
my($poemer_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","poemer",$plustype_foreach_index,$bbs_data);
my($novel_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","novel",$plustype_foreach_index,$bbs_data);
my($diary_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","diary",$plustype_foreach_index,$bbs_data);
my($soudann_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","soudann",$plustype_foreach_index,$bbs_data);
my($shakai_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","shakai",$plustype_foreach_index,$bbs_data);
my($nenndai_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","nenndai",$plustype_foreach_index,$bbs_data);
my($mebi_line) = Mebius::BBS::BBSNameAray(" Get-top-page-link","mebi",$plustype_foreach_index,$bbs_data);

	# ●スマフォ版
	if($my_use_device->{'smart_flag'} || $pc_flag){
		$line .= qq(<div class="smart_phone_bbs_list">);
		$line .= qq(<hr><a href="/_category/poemer/" class="b">詩</a> ： $poemer_line);
		$line .= qq(<hr><a href="/_category/novel/" class="b">小説</a> ：$novel_line);
		$line .= qq(<hr><a href="/_category/diary/" class="b">日記他</a> ： $diary_line);
		$line .= qq(<hr><b>絵</b> ： <a href="http://aurasoul.mb2.jp/eka_pnt/">お絵かき</a> <a href="http://aurasoul.mb2.jp/eka/relm.cgi">お絵プロ</a>);
			if(Mebius::Admin::admin_mode_judge()){
				$line .= qq( <a href="/jak/pnt.cgi">画家</a>);
			} else {
				$line .= qq( <a href="_pnt/">画家</a>);
			}
		$line .= qq(<hr><a href="/_category/soudann/" class="b">相談</a> ： $soudann_line);
		$line .= qq(<hr><a href="/_category/shakai/" class="b">社会</a> ： $shakai_line);
		$line .= qq(<hr><a href="/_category/nenndai/" class="b">雑談1</a> ： $nenndai_line);
		$line .= qq(<hr><a href="/_category/mebi/" class="b">メビ</a> ： $mebi_line);
		$line .= qq(<hr><a href="/_category/aura/" class="b">あうら</a> ： $aura_line);
		$line .= qq(</div>);
	}

	# ●モバイル版
	elsif($my_use_device->{'mobile_flag'}){
		my $style = "text-align:center;background:#ddf;margin:6px 0px 6px 0px;";
		#$line .= qq(<div class="smart_phone_bbs_list">);
		$line .= qq(<div style="$style" id="POEMER">詩</div>$poemer_line);
		$line .= qq(<div style="$style" id="NOVEL">小説</div>$novel_line);
		$line .= qq(<div style="$style" id="DIARY">日記他</div>$diary_line);
		#$line .= qq(<div style="$style" id="">絵</div><a href="eka_pnt/">お絵かき</a> <a href="eka/relm.cgi">お絵プロ</a> <a href="_pnt/">画家</a>);
		$line .= qq(<div style="$style" id="SOUDANN">相談</div>$soudann_line);
		$line .= qq(<div style="$style" id="SHAKAI">社会</div>$shakai_line);
		$line .= qq(<div style="$style" id="ZTD">雑談1</div>$nenndai_line);
		$line .= qq(<div style="$style" id="MEBI">メビ</div>$mebi_line);
		$line .= qq(<div style="$style" id="AURA">あうら</div>$aura_line);
		#$line .= qq(</div>);
	}

	# ●デスクトップ版
	else{
		$line .= qq(<table summary="メニュー" class="top_page menu"><tr><td class="td2 valign-top">);
		$line .= qq(<a href="/_category/aura/" class="b">あうら</a><br> $aura_line);
		$line .= qq(
		<hr><a href="/_category/poemer/" class="b">詩</a><br>
		$poemer_line
		</td><td class="td2 valign-top">
		<a href="/_category/novel/" class="b">小説</a><br>
		$novel_line
		</td><td class="td2 valign-top">
		<a href="/_category/diary/" class="b">日記他</a><br>
		$diary_line
		<hr><b>絵</b><br>
		<div class="indent2"><b class="ct">全ジャンル</b><br></div>
		<div class="indent3">
		<a href="eka_pnt/">お絵かき</a><br>
		<a href="eka/relm.cgi">お絵プロ</a><br>
		<a href="_pnt/">画家</a><br>
		</div>
		);
		#$line .= qq($msc_line);
		$line .= qq(
		</td><td class="td2 valign-top">
		<a href="/_category/soudann/" class="b">相談</a><br>
		$soudann_line
		<hr><a href="/_category/shakai/" class="b">社会</a><br>
		$shakai_line
		</td><td class="td2 valign-top">
		<a href="/_category/nenndai/" class="b">雑談1</a><br>
		$nenndai_line
		<hr><a href="/_category/mebi/" class="b">メビ</a><br>
		$mebi_line
		</td></tr></table>
		);
	}


	if($pc_flag){
		$line .= qq(</td></tr></table>);
	}


return($line);

}

#-----------------------------------------------------------
# 娯楽版
#-----------------------------------------------------------
sub bbs_topbetax{

# 宣言
my($type,$google_search_box,$allsearch_form) = @_;
my($my_use_device) = Mebius::my_use_device();
my($param) = Mebius::query_single_param();
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my $vine = new Mebius::Vine;
my $tags = new Mebius::Tags;
my $question = new Mebius::Question;

my($line);
my($one_line_reshistory2);


my $vine_link = $vine->top_page_link();
my $tags_link = $tags->top_page_link();
my $question_link = $question->top_page_link();

# CSS
my $css_text .= qq(
.ant,.ans,.menu,.td2{border-style:none;}
);

# 設定
my $sub_title = "メビウスリング掲示板";

# 上部メニュー 書き出し

$line .= qq(

<div class="top_navigation">
<h1 class="title inline">メビウスリング掲示板</h1>
<br>

<div class="upmenu">
総合コミュニティサイト。<a href="http://aurasoul.mb2.jp/_qst/2342.html">…増設要望</a>
<a href="$basic_init->{'guide_url'}">…ガイドを読む</a>

</div>

$google_search_box
$allsearch_form

</div>

<div class="links" style="line-height:1.8;">
<a href="/_main/">扉</a>
|
<a href="http://aurasoul.mb2.jp/gap/ff/ff.cgi">メビアド</a>
|
$question_link
|
<a href="_main/rankgold-p-1.html"$main::sikibetu>金貨ランク</a>
|
<a href="_main/rankspt-p-1.html">人気記事</a>
);


# $tags_link
# |

#|<a href="http://aurasoul.mb2.jp/_main/msc-list-normal-1.html">音楽の再生</a>
#|
#$vine_link

#|
#<a href="_main/newtag-p-1.html">新着タグ</a>

	#if($main::pmfile){
	#	$line .= qq( | <a href="http://aurasoul.mb2.jp/chat/tmb3/mebichat.cgi">新チャット</a>);
	#}



$line .= qq(
|
<a href="http://aurasoul.mb2.jp/wiki/ring/">メビWiki</a>
</div>
);




# 投稿履歴を取得
require "${init_directory}part_history.pl";

my(undef,$one_line_reshistory2) = get_reshistory("ONELINE THREAD My-file",undef,undef,undef,undef,3,3);
	if($one_line_reshistory2){ $one_line_reshistory2 = qq(<hr>$one_line_reshistory2); }
utf8($one_line_reshistory2);

# 新着スレッド・レス表示
my($newthread_line) = index_get_newthread();
my($newres_line) = index_get_newres();

	# スマフォ版
	if($my_use_device->{'smart_flag'}){
		$line .= qq(<hr><div>$newthread_line<hr>$newres_line</div>);
	}
	# デスクトップ版
	else{
		$line .= qq(<div class="ant"><hr>$newthread_line<hr>$newres_line$one_line_reshistory2</div>);
	}



# 掲示板メニュー中心部 -----

$line .= &get_index_goraku();


my($ans_line) = ans();

	# スマフォ振り分け
	if($my_use_device->{'smart_flag'}){
		$line .= qq(<hr><div>$ans_line</div><hr>);
	}
	else{
		$line .= qq(<div class="ans"><hr>$ans_line<hr></div>);
	}


my $switch_line;
$switch_line .= qq( 切替 : );
	if($param->{'all_view'}){
		$switch_line .= qq(<a href="./">普通に表\示</a>);
		$switch_line .= qq( <span class="green">全ての掲示板を表\示</span>);
	} else {
		$switch_line .= qq(普通に表\示);
		$switch_line .= qq( <a href="./?all_view=1" class="green">全ての掲示板を表\示</a>);
	}

$line .= qq(
<div class="removal">
他 …
<a href="http://aurasoul.mb2.jp/wiki/guid/%A5%E9%A5%A4%A5%BB%A5%F3%A5%B9">ライセンス</a>
<a href="http://aurasoul.mb2.jp/haiku/haiku.cgi">俳句</a>
<a href="http://aurasoul.mb2.jp/aura.htm">あうら作2</a>
<a href="http://aurasoul.mb2.jp/pmlink/link2.html">リンク集</a>

);

	if(!Mebius::Device::bot_judge()){
		$line .= qq( <a href="http://aurasoul.mb2.jp/ctj/comchat.cgi">会員制チャット</a>);
	}

$line .= $switch_line;
$line .= qq(</div>);

Mebius::Template::gzip_and_print_all({ source => "utf8" , Title => $sub_title , inline_css => $css_text , BBS_TOP_PAGE => 1 } , $line);

exit;

}


#-----------------------------------------------------------
# 新着記事を取得
#-----------------------------------------------------------
sub index_get_newthread{

# 宣言
my($i,$line,$plustype_get_threadres);
my($maxview_line);
my($my_use_device) = Mebius::my_use_device();
my($init_directory) = Mebius::BaseInitDirectory();

	# スマフォ振り分け
	if($my_use_device->{'smart_flag'}){
		$plustype_get_threadres .= qq( Smart-phone-view);
		$maxview_line = 1;
	}
	else{
		$maxview_line = 2;
	}

# 新着記事のリストを取得
require "${init_directory}part_newlist.pl";
($line) = Mebius::Newlist::threadres("ONELINE THREAD Fillter $plustype_get_threadres","",$maxview_line);
utf8($line);

	# スマフォ板
	if($my_use_device->{'smart_flag'}){
		$line = qq(
		<div class="newthead">
		<span class="red">New!</span> ： $line
		 / <a href="${main::main_url}newthread-p-1.html">…続き</a>
		</div>
		);
	}

	# 整形
	else{
		$line = qq(
		<div class="newthead">
		<a href="${main::main_url}newthread-p-1.html">新着スレッド</a> ： $line
		 / <a href="${main::main_url}newthread-p-1.html">…続き</a>
		</div>
		);
	}

# リターン
return($line);

}


#-----------------------------------------------------------
# 新着レスを取得
#-----------------------------------------------------------
sub index_get_newres{

# 宣言
my($i,$line,$maxview_line);
my($my_use_device) = Mebius::my_use_device();
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my($plustype_get_threadres);

	# スマフォ振り分け
	if($my_use_device->{'smart_flag'}){
		$plustype_get_threadres .= qq( Smart-phone-view);
		$maxview_line = 1;
	} else{
		$maxview_line = 2;
	}


# 新着記事のリストを取得
require "${init_directory}part_newlist.pl";
($line) = Mebius::Newlist::threadres("ONELINE RES Buffer Fillter","",$maxview_line);
utf8($line);

# 整形
$line = qq(
<div class="newthead">
<a href="$basic_init->{'main_url'}newres-p-1.html">新着レス</a> ： $line
 / <a href="$basic_init->{'main_url'}newres-p-1.html">…続き</a>
</div>
);

# リターン
return($line);

}



#-----------------------------------------------------------
# 新着いいね！読み込み
#-----------------------------------------------------------

sub ans{
my($i,$ans_line);
my($init_directory) = Mebius::BaseInitDirectory();

$ans_line .= qq(<a href="/_main/newsupport-p-1.html">新いいね！</a>： );

# ファイル読み込み
open(IN,"<","${init_directory}_sinnchaku/all_newsupport.cgi");
	while(<IN>){

		my($key,$moto,$title,$no,$sub,$name,$com,$No) = split(/<>/,$_);
			utf8($title,$sub,$name);
		if($key ne "1"){ next; }
		$i++;

		if($i >= 2){ $ans_line .= qq( ｜ ); }
		$ans_line .= qq(<a href="/_$moto/$no.html">$sub</a> ( <a href="/_$moto/" class="green">$title</a> ) );
		if($i >= 3){ last; }
	}
close(IN);

$ans_line;

}


#-----------------------------------------------------------
# 設定
#-----------------------------------------------------------
sub main_index_mobile{

# 宣言
my($init_directory) = Mebius::BaseInitDirectory();
our($bbslist_line,$requri);
our $kindex_link = "now";
our $kboad_link = "off";

# 携帯設定を取得
&kget_items();

# 取り込み処理
bbs_topbetax_mobile();

exit;

}


#-----------------------------------------------------------
# 携帯版 娯楽版
#-----------------------------------------------------------
sub bbs_topbetax_mobile{

# 局所化
my($pc_link,$line,$bbshistory_line);

# 広告
my($kadsense) = &kadsense("INDEX");

my $category_style1 = qq(text-align:center;background:#ddf;margin:6px 0px 6px 0px;);

# タイトル定義
my $sub_title = "メビウスリング掲示板";

# 最近の利用
($bbshistory_line) = Mebius::Mobile::Index::BBS_History();

# HTML
$line .= qq(
<div style="border-bottom:solid 1px #000;background:#dee;">
<span style="font-size:medium;">ﾒﾋﾞｳｽﾘﾝｸﾞ掲示板</span>
<span style="font-size:x-small;">
<a href="_main/newthread-k-1.html">新記事</a> <a href="_main/newres-k-1.html">新ﾚｽ</a> <a href="_main/newsupport-k-1.html">新いいね！</a>
<a href="http://aurasoul.mb2.jp/etc/amail.html">問合</a> <a href="/wiki/guid/">ｶﾞｲﾄﾞ</a>
</span>
</div>
$kadsense
$bbshistory_line

<div style="$category_style1">カテゴリ <a href="#ANICOMI" id="CATEGORY">▽</a></div>
<div style="font-size:x-small;">
<a href="#ANICOMI">ｱﾆﾒ/漫画</a>
<a href="#GAME">ｹﾞｰﾑ</a>
<a href="#NARIKIRI">なりきり</a>
<a href="#GOKKO">ごっこ</a>
<a href="#ETC">ＥＴＣ</a>
<a href="#MUSIC">音楽</a>
<a href="#ZATUDANN">雑談</a>
<a href="#CHIIKI">地域 </a>
<a href="#MEBI">メビ(表)</a>
<a href="#POEMER">詩</a>
<a href="#NOVEL">小説</a>
<a href="#DIARY">日記他</a>
<a href="#SOUDANN">相談</a>
<a href="#SHAKAI">社会</a>
<a href="#ZTD">雑談１</a>
<a href="#MEBI">メビ</a>
<a href="#AURA">あうら</a>
</div>);

$line .= qq(<div style="font-size:small;">);
$line .= get_index_goraku("Mobile-view");
$line .= qq(</div>);

# ヘッダ
Mebius::Template::gzip_and_print_all({ PrintUTF8 => 1 , source => "utf8" , Title => $sub_title },$line);

}


use Mebius::BBS;
package Mebius::Mobile::Index;
use Mebius::Export;

#-----------------------------------------------------------
# 投稿履歴を取得
#-----------------------------------------------------------
sub BBS_History{

# 宣言
my(@bbslist,$line,$return_line,$hit);
my($init_directory) = Mebius::BaseInitDirectory();

# 取り込み処理
my($bbs_names) = Mebius::BBS::bbs_names();

# 投稿履歴を取得
require "${init_directory}part_history.pl";
(@bbslist) = main::get_reshistory("BBS-list Not-get-thread My-file",undef,undef,undef,undef,50);

	# 投稿履歴を展開
	foreach(@bbslist){
		my($realmoto2,$title2) = split(/=/,$_);

		# 除外する掲示板
		if($realmoto2 =~ /^(sub)/){ next; }

		# 配列より省略名を取得
		if($bbs_names->{$realmoto2}){
			$title2 = $bbs_names->{$realmoto2};
		}
		# タイトルを短く
		else{
			$title2 =~ s/投稿城/…/g;
			$title2 =~ s/掲示板/…/g;
			$title2 =~ s/メビウスリング//g;
			utf8($title2);
		}

		$line .= qq(<a href="/_$realmoto2/">$title2</a> );
		$hit++;
		if($hit >= 3){ next; }
	}

	# 整形
	if($line){
		$return_line .= qq(<div style="background:#ddf;text-align:center;">セレクト</div>);
		$return_line .= qq(<div style="margin:0.5em 0em;">);
		$return_line .= qq($line);
		$return_line .= qq(</div>);
	}


return($return_line);

}


1;


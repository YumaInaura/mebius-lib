
package main;

#-----------------------------------------------------------
# 設定
#-----------------------------------------------------------
sub main_index_mobile{

# 宣言
our($int_dir);
our($bbslist_line,$requri);

$kindex_link = "now";
$kboad_link = "off";

# 携帯設定を取得
&kget_items();

# 広告
($kadsense) = &kadsense("INDEX");
$kadsense = qq($kadsense);

# 取り込み処理
require "${int_dir}main_index.pl";

	# モード振り分け
	if($alocal_mode){ &bbs_topbetax_mobile(); }
	elsif($server_domain eq "mb2.jp"){ &bbs_topbetax_mobile(); }
	else{ &error("ドメインを設定してください。"); }

exit;

}


#-----------------------------------------------------------
# 携帯通常版
#-----------------------------------------------------------
sub bbs_topindex_mobile{

# 局所化
my($pc_link,$line,$bbshistory_line);

# アクセス振り分け
$divide_url = "http://$server_domain/";
#if($device_type eq "desktop"){ &divide($divide_url,"desktop"); }

# タイトル定義
$sub_title = "メビウスリング掲示板";

$category_style1 = qq(text-align:center;background:#ddf;margin:6px 0px 6px 0px;);
#border-top:solid 1px #000;

$line .= qq();

# PC版へのリンク
if($device_type eq "both"){ $pc_link = qq(<a href="/">ＰＣ版</a>); }

# セレクトリンク
($bbshistory_line) = Mebius::Mobile::Index::BBS_History();


# HTML
$line .= qq(
<div style="border-bottom:solid 1px #000;background:#dee;">
<span style="font-size:medium;">ﾒﾋﾞｳｽﾘﾝｸﾞ掲示板</span>
<span style="font-size:x-small;">
<a href="_main/newthread-k-1.html">新記事</a> <a href="_main/newres-k-1.html">新ﾚｽ</a> <a href="_main/newsupport-k-1.html">新いいね！</a>
<a href="http://mb2.jp/" style="color:#f33;">娯楽版</a> $pc_link
<a href="etc/amail.html">問合</a> <a href="/wiki/guid/">ｶﾞｲﾄﾞ</a>
</span>
</div>

$kadsense

$bbshistory_line


<div style="$category_style1"><a href="#ACATEGORY" id="ACATEGORY" accesskey="5">⑤</a>カテゴリ <a href="#POEMER" id="CATEGORY">▽</a></div>);

$line .= qq(
<span style="font-size:x-small;">
<a href="#POEMER">詩</a>
<a href="#NOVEL">小説</a>
<a href="#DIARY">日記他</a>
<a href="#SOUDANN">相談</a>
<a href="#SHAKAI">社会</a>
<a href="#ZTD">雑談１</a>
<a href="#MEBI">メビ</a>
<a href="#AURA">あうら</a>
</span>
);


# 掲示板メニューをゲット
$line .= qq(<div style="font-size:small;">);
$line .= &get_index_normal("Mobile-view");
$line .= qq(</div>);


# ヘッダ
&kheader({},qq(<><a href="#CATEGORY">▽</a>));

print qq($line);

# フッタ
&footer();


}

#-----------------------------------------------------------
# 携帯版 娯楽版
#-----------------------------------------------------------
sub bbs_topbetax_mobile{

# 局所化
my($pc_link,$line,$bbshistory_line);

my $category_style1 = qq(text-align:center;background:#ddf;margin:6px 0px 6px 0px;);

# アクセス振り分け
$divide_url = "http://$server_domain/";
#if($device_type eq "desktop"){ &divide($divide_url,"desktop"); }

# タイトル定義
$sub_title = "メビウスリング娯楽版";

# 最近の利用
($bbshistory_line) = Mebius::Mobile::Index::BBS_History();

# PC版へのリンク
if($device_type eq "both"){ $pc_link = qq(<a href="/">ＰＣ版</a>); }

# HTML
$line .= qq(
<div style="border-bottom:solid 1px #000;background:#dee;">
<span style="font-size:medium;">ﾒﾋﾞｳｽﾘﾝｸﾞ娯楽版</span>
<span style="font-size:x-small;">
<a href="_main/newthread-k-1.html">新記事</a> <a href="_main/newres-k-1.html">新ﾚｽ</a> <a href="_main/newsupport-k-1.html">新いいね！</a>
<a href="http://aurasoul.mb2.jp/" style="color:#f33;">通常版</a> $pc_link
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
<a href="#MEBI">メビ(表\)</a>
</div>);

$line .= qq(<div style="font-size:small;">);
$line .= &get_index_goraku("Mobile-view");
$line .= qq(</div>);


# ヘッダ
&kheader({},qq(<><a href="#CATEGORY">▽</a>));

print qq($line);

# フッタ
&footer();


}

use strict;
use Mebius::BBS;
package Mebius::Mobile::Index;

#-----------------------------------------------------------
# 投稿履歴を取得
#-----------------------------------------------------------
sub BBS_History{

# 宣言
my(@bbslist,$line,$return_line,$hit,%bbsname);

# 取り込み処理
(%bbsname) = Mebius::BBS::BBSName();

# 投稿履歴を取得
require "${main::int_dir}part_history.pl";
(@bbslist) = main::get_reshistory("BBS-list Not-get-thread My-file",undef,undef,undef,undef,50);

	# 投稿履歴を展開
	foreach(@bbslist){
		my($realmoto2,$title2) = split(/=/,$_);

		# 除外する掲示板
		if($realmoto2 =~ /^(sub)/){ next; }

		# 配列より省略名を取得
		if($bbsname{$realmoto2}){
			$title2 = $bbsname{$realmoto2};
		}
		# タイトルを短く
		else{
			$title2 =~ s/投稿城/…/g;
			$title2 =~ s/掲示板/…/g;
			$title2 =~ s/メビウスリング//g;
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


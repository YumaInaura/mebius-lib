
#use strict;
package main;

#-------------------------------------------------
# プロフィール表示
#-------------------------------------------------
sub auth_avallcomment{

# CSS定義
$css_text .= qq(
.lim{margin-bottom:0.3em;line-height:1.25;}
li{line-height:1.5;}
table,th,tr,td{border-style:none;}
table{font-size:90%;width:100%;}
th{text-align:left;padding:0.5em 1.0em 0.5em 0.0em;}
th.to{width:20%;}
th.name{width:20%;}
td{padding:0.2em 1.0em 0.5em 0.0em;vertical-align:top;}
th.date{width:9em;}
th.comment{display:block;word-wrap:break-word;}
div.comment{display:block;word-wrap:break-word;width:30em;}
);

# タイトル定義
$sub_title = "新着伝言 - $title";
$head_link3 = qq(&gt; 新着伝言);
if($in{'word'} ne ""){
$sub_title = "”$in{'word'}”で検索 - 新着伝言 - $title";
$head_link3 = qq(&gt; <a href="./aview-alldiary.html">新着伝言</a> );
$head_link4 = qq(&gt; ”$in{'word'}”で検索 );
}

# 日記一覧を取得
my($newdiary_index) = auth_avallcomment_get_newlist();

# ナビ
my $link2 = "${pmfile}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
my $navilink .= qq(<a href="$link2">自分のプロフィールへ戻る</a>);

# フォームを取得
my($form) = &auth_avallcomment_get_form();

# HTML
my $print = <<"EOM";
$footer_link
<h1>新着伝言 - $title</h1>
$navilink
$form
<h2>一覧</h2>
$newdiary_index
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;
}

#-----------------------------------------------------------
# 検索フォーム
#-----------------------------------------------------------
sub auth_avallcomment_get_form{

my $form .= qq(
<h2>伝言から検索</h2>
<form action="$action">
<div>
<input type="hidden" name="mode" value="aview-allcomment">
<input type="text" name="word" value="$in{'word'}">
<input type="submit" value="新着伝言から検索する">　
<span class="guide">※「コメント内容」「筆名」「アカウント名」から検索します。</span>
</div>
</form>
);

return($form);

}


use strict;

#──────────────────────────────
# 全メンバーの新着伝言
#──────────────────────────────

sub auth_avallcomment_get_newlist{

my($param) = Mebius::query_single_param();
my($i,$max,$newdiary_index);
our($k_access);

# 最大表示行数
my $max = 50;
if($k_access){ $max = 25; }
#if($myadmin_flag){ $max = 500; }

my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# 現行インデックスを読み込み
open(NEWDIARY_IN,"<","${auth_log_directory}newcomment.cgi");
while(<NEWDIARY_IN>){
chomp;
my($key,$account,$name,$account2,$name2,$comment,$date,$res) = split(/<>/,$_);
if($key eq "0"){ next; }

if($param->{'word'} ne ""){
if(index($name,$param->{'word'}) < 0 && index($name2,$param->{'word'}) < 0 && index($account,$param->{'word'}) < 0 && index($account2,$param->{'word'}) < 0 && index($comment,$param->{'word'}) < 0){ next; }
}

my $link1 = qq($account/);
my $link2 = qq($account2/);
$comment =~ s/<br>/ /g;
($comment) = Mebius::auto_link($comment);
#$comment =~ s/手紙/<span class="hit">$&</span>/g;

$newdiary_index .= qq(<tr><td><a href="$link1#COMMENT">$name - $account</a></td><td><a href="$link2#COMMENT">$name2 - $account2</a></td><td><div class="comment">$comment</div></td><td>$date</td></tr>);

$i++;
if($i >= $max){ last; }

}
close(NEWDIARY_IN);

if($newdiary_index){
$newdiary_index = qq(
<table summary="新着伝言一覧"><tr><th class="to">伝言先 ( To )</th><th class="name">筆名（ From ）</th><th class="comment">伝言内容</th><th class="date">時刻</th></tr>\n
$newdiary_index
</table>
);

$newdiary_index;

}

}

1;

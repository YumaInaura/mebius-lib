
package main;

#-------------------------------------------------
# プロフィール表示
#-------------------------------------------------
sub auth_avallresdiary{

# 局所化
my($file);

#汚染チェック
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# 基本タイトル
$main_title = "新着レス（日記）";

# CSS定義
$css_text .= qq(
.lim{margin-bottom:0.3em;line-height:1.25;}
li{line-height:1.5;}
table,th,tr,td{border-style:none;}
table{font-size:90%;width:100%;}
th{text-align:left;padding:0.5em 1.0em 0.5em 0.0em;}
th.to{width:20%;}
th.name{width:20%;}
th.sub{width:25%;}
th.date{width:9em;}
td{padding:0.2em 1.0em 0.5em 0.0em;vertical-align:top;}
span.guide{font-size:90%;color:#080;}
div.comment{width:30em;line-height:1.4;word-wrap;break-word;}
);

# タイトル定義
$sub_title = "$main_title - $title";
$head_link3 = qq(&gt; $main_title);
if($in{'word'} ne ""){
$sub_title = "”$in{'word'}”で検索 - $main_title - $title";
$head_link3 = qq(&gt; <a href="./aview-alldiary.html">$main_title</a> );
$head_link4 = qq(&gt; ”$in{'word'}”で検索 );
}


# 日記一覧を取得
&auth_avallresdiary_newlist_diary();

# ナビ
my $link2 = "${pmfile}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
my $navilink .= qq(<a href="$link2">自分のプロフィールへ戻る</a>);

# フォームを取得
my($form) = &auth_avallresdiary_get_form;

# HTML
my $print = <<"EOM";
$footer_link
<h1>$main_title - $title</h1>
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
sub auth_avallresdiary_get_form{

my $form .= qq(
<h2>$main_titleから検索</h2>
<form action="$action">
<div>
<input type="hidden" name="mode" value="aview-allresdiary">
<input type="text" name="word" value="$in{'word'}">
<input type="submit" value="$main_titleから検索する">　
<span class="guide">※「日記題名」「筆名」「アカウント名」から検索します。</span>
</div>
</form>
);

return($form);

}

#──────────────────────────────
# 全メンバーの新着レス（日記）
#──────────────────────────────

sub auth_avallresdiary_newlist_diary{

my($i,$max);

# 最大表示行数
$max = 50;
if($k_access){ $max = 25; }
#if($myadmin_flag){ $max = 500; }

my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# 現行インデックスを読み込み
open(NEWDIARY_IN,"<","${auth_log_directory}newresdiary.cgi");
	while(<NEWDIARY_IN>){
	chomp;
	my($key,$file,$sub,$account,$name,$account2,$name2,$comment,$date,$res) = split(/<>/,$_);
	if($key eq "0"){ next; }

	if($in{'word'} ne ""){
	if(index($name,$in{'word'}) < 0 && index($name2,$in{'word'}) < 0 && index($account,$in{'word'}) < 0 && index($account2,$in{'word'}) < 0 && index($sub,$in{'word'}) < 0){ next; }
	}

	my $link1 = qq($account/);
	my $link2 = qq($account2/);

	#<td><a href="$link1">$name - $account</a></td>

	$newdiary_index .= qq(<tr><td><a href="$account/d-$file">$sub</a> ( <a href="$account/d-$file#S$res">Re: $res</a> ) </td><td><a href="$link2">$name2 - $account2</a></td><td><div class="comment">$comment</div></td><td>$date</td></tr>);

	$i++;
			if($i >= $max){ last; }

	}
close(NEWDIARY_IN);

#<th class="to">日記主 ( To )</th>

if($newdiary_index){
$newdiary_index = qq(
<table summary="新着伝言一覧"><tr><th class="sub">日記名</th><th class="name">投稿者（ From ）</th><th>コメント</th><th class="date">時刻</th></tr>\n
$newdiary_index
</table>
);
}

}

1;

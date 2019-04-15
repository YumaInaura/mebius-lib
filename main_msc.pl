#-----------------------------------------------------------
# 初期設定
#-----------------------------------------------------------
sub main_msc{

# タイトル
$title = qq(音楽の再生 | あうらゆうま);
$head_link1 = qq( &gt; <a href="/">メビウスリング</a> | <a href="http://mb2.jp/">娯楽版</a> );
$head_link2 = qq( &gt; 音楽の再生 );

# スクリプト定義
$script = "./";
if($alocal_mode){ $script = "main.cgi"; }

# 音楽用ディレクトリ
our $music_url_redirect = "http://aurasoul.mb2.jp/msc2/";
$msc_url = "http://aurasoul.mb2.jp/msc2/";
$play_url = "http://aurasoul.mb2.jp/_main/?mode=msc-play&amp;file=";
$msc_dir = "../msc2/";
if($alocal_mode){ $msc_dir = "./msc/"; }

# サーバー指定
if($server_domain ne "aurasoul.mb2.jp" && $server_domain ne "localhost"){ &error("ドメインが違います。"); }

# モード振り分け
if($submode2 eq "play"){ Mebius::Music::Play($in{'file'}); }
elsif($submode2 eq "comment"){ &mscomment(); }
elsif($submode2 eq "list"){ &music_list(); }
elsif($submode2 eq "slist"){ &music_slist(); }
elsif($submode2 eq "editsource"){ &editsource(); }
else{ &error("モードを指定してください。"); }

exit;

}


#-----------------------------------------------------------
# 再生リストを表示
#-----------------------------------------------------------
sub music_list{

# 局所化
my(@line);

# ページタイプ
my $page = $submode4;
$page =~ s/\D//g;
if($page eq ""){ &error("ページ数を指定してください。"); }

# CSS定義
$css_text .= qq(
li{line-height:1.5em;}
ul{margin:1em 0em 0em 0em;}
h1{margin-top:0em;}
textarea.source{width:100%;height:500px;}
table,th,tr,td{border-style:none;}
table{margin-top:1em;}
th{text-align:left;padding:0.2em 1.0em 0.4em 0em;}
td{padding:0.2em 1.0em 0.4em 0em;}
th.mark,td.mark,span.mark{color:#f83;}
th.mark{padding-right:1.0em;}
td.mark{padding-right:1.0em;}
th.sub{}
th.count{text-align:right;padding-right:1.5em;}
th.count{}
td.count{text-align:right;padding-right:1.5em;}
th.word{}
th.k{}
th.url{}
td.url{padding-top:0em;padding-bottom:0em;}
div.tablinks{margin-top:1em;padding:0.4em 1em;background-color:#dee;}
input.url{font-size:70%;color:#080;border:none 0px #fff;width:27em;height:1.7em;}
.zero_mark{color:#000;}
.crap{display:inline;}
form.msform{background-color:#ff9;padding:0.4em 1em;margin:1em 0em;}
input.mscomment{width:30%;}
);


# 再生リストファイルを開く
open(COUNT_IN,"${msc_dir}play.cgi");
while(<COUNT_IN>){ push(@line,$_); }
close(COUNT_IN);

# 並べ替え
if($submode3 eq "normal"){ $sub_title = qq($title); }
elsif($submode3 eq "count"){ @line = sort { (split(/<>/,$b))[3] <=> (split(/<>/,$a))[3] } @line; $sub_title = qq(再生回数順 - $title); }
elsif($submode3 eq "title"){ @line = sort { (split(/<>/,$a))[1] cmp (split(/<>/,$b))[1] } @line; $sub_title = qq(タイトル順 - $title); }
else{ &error("表示タイプを指定してください。"); }

	# 再生リストファイルを開く
	foreach(@line){
		my($key,$sub,$mscfile,$count,$support,$word_url,$xip_enc2) = split(/<>/,$_);
		if($key eq "0" && $myadmin_flag < 5){ next; } 
		$line .= qq(<tr>);
		my($mark);
		if($key eq "0"){ $line .= qq(<td class="zero_mark">☆</td>); }
		elsif($key eq "5"){ $line .= qq(<td class="mark">★</td>); }
		else { $line .= qq(<td class="mark">☆</td>); }
		if($sub eq ""){ $sub = $mscfile; }
		if($cookie || $k_access){ $line .= qq(<td>$mark<a href="$script?mode=msc-play&amp;file=$mscfile">$sub</a></td>); }
		else{ $line .= qq(<td><a href="${msc_url}$mscfile.mp3">$sub</a></td>); }
		$line .= qq(<td class="count">$count回</td>);
		if($cookie || $k_access){ $line .= qq(<td><a href="$script?mode=msc-play&amp;file=$mscfile&amp;k=1">携帯版</a></td>); }
		else{ $line .= qq(<td><a href="http://mp3.3gp.fm/q/Link.aspx?u=http%3a%2f%2faurasoul.mb2.jp%2fmsc%2f$mscfile.mp3">携帯版</a></td>); }
		if($word_url){ $line .= qq(<td><a href="$word_url">歌詞</a></td>); } else { $line .= qq(<td></td>); }
		$line .= qq(<td class="url"><input type="text" class="url" value="${play_url}$mscfile" onclick="select()"></td>);
		$line .= qq(</tr>\n);
	}

# マスターの場合、ソースを取得
if($myadmin_flag >= 5){ &get_source; }

# 切り替えリンクを取得
&get_tablinks;

# 一言メッセージフォームを取得
#my($msform_line) = &get_msform;



# 再生表を定義
my($table);
$table = qq(
<table summary="再生リスト">
<tr><th class="mark"></th><th class="sub"><strong class="red">曲名 ─ 再生する</strong></th><th class="count">再生</th><th class="k">携帯版</th><th class="word">歌詞</th><th>音源のＵＲＬ（貼\り付け用）</th></tr>
$line
</table>
);


# HTML
my $print = qq(
<h1>音楽の再生</h1>
<h2>再生リスト</h2>
音楽の再生リストです。ここに無いものは<a href="http://aurasoul.mb2.jp/_ams/">あうらの歌</a>か<a href="http://aurasoul.mb2.jp/_asx/">依頼作品集</a>から曲を探して再生すると、リストに追加されます。<span class="mark">★</span>はおすすめ曲です。
$msform_line

$tablinks
$table
$source_line
);

Mebius::Template::gzip_and_print_all({},$print);

exit;


}


#-----------------------------------------------------------
# 一言メッセージフォーム
#-----------------------------------------------------------
sub get_msform{

if(!$cookie && !$k_access){ return; }

my($line);

$line .= qq(
<form action="$script" method="post" class="msform" $sikibetu>
<div>
<input type="hidden" name="mode" value="msc-comment">
<input type="text" name="comment" value="" class="mscomment">
<input type="submit" value="一言メッセージを送る">
</div>
</form>
);

return($line);

}

#-----------------------------------------------------------
# 一言メッセージを送る
#-----------------------------------------------------------
sub mscomment{

# ＩＤ付与
&id;

# アクセス制限
&axscheck("fast");

# 各種エラー
if(!$cookie && !$k_access){ &error("この環境では送信できません。"); }
if(!$postflag){ &error("GET送信は出来ません。"); }
if(length($in{'comment'}) > 2000*2){ &error("コメントは2000文字以内で書いてください。"); }
if(length($in{'comment'}) < 2*2){ &error("コメントは2文字以上で書いてください。"); }
if($in{'comment'} =~/(href|url=)/){ &error("タグは送信できません。"); }

# 送信内容の定義
my $body = qq(
$in{'comment'}

──────────────────────────────
筆名： $chandle
ＩＤ： $encid
アカウント： $auth_url$pmfile/
接続元： $xip - $addr
──────────────────────────────

);

# 筆名
my $name = $chandle;
if($name eq ""){ $name = "名無し"; }

# メール送信
Mebius::send_email("To-master",undef,"音楽の再生 - $nameさんがメッセージを送信しました。",$body);

# ジャンプ先
$jump_sec = 1;
$jump_url = "msc-list-normal-1.html";
if($alocal_mode){ $jump_url = "$script?mode=msc-list-normal-1"; }


# HTML
my $print = qq(
送信しました。<a href="$jump_url">戻る</a>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-----------------------------------------------------------
# 簡易再生リストを表示
#-----------------------------------------------------------
sub music_slist{

# 局所化
my(@line,$hit);

my $rand = rand(2);

# 再生リストファイルを開く
open(COUNT_IN,"${msc_dir}play.cgi");

# 再生リストファイルを開く
while(<COUNT_IN>){
if($hit >= 3){ last; }
my($key,$sub,$mscfile,$count,$support,$word_url,$xip_enc2) = split(/<>/);
if($key eq "0"){ next; }

if($rand < 1 && $key ne "5"){ next; }
if($rand >= 1 && ($count < 10 || $key eq "5")){ next; }
if(rand(2) < 1){ next; }

if($sub eq ""){ $sub = $mscfile; }
$sub =~ s/ (-|（|\()(.+)//g;

$line .= qq(<li>);
if($k_access){ $line .= qq(<a href="$script?mode=msc-play&amp;file=$mscfile&amp;k=1">$sub</a>); }
elsif($cookie && !$bot_access){ $line .= qq(<a href="$script?mode=msc-play&amp;file=$mscfile">$sub</a>); }
else{ $line .= qq(<a href="${msc_url}$mscfile.mp3">$sub</a>); }

if($word_url){ $line .= qq( ( <a href="$word_url">歌詞</a> ) ); }
$hit++;
}
close(COUNT_IN);

# ヘッダ
print "Content-type:text/html\n\n";

print qq(
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> 
<html lang="ja"> 
<head>
<base target="_top">
<meta http-equiv="content-type" content="text/html; charset=shift_jis"> 
<title>音楽の再生 - 簡易リスト</title> 
<meta name="robots" content="noarchive"> 
<meta http-equiv="content-style-type" content="text/css"> 
<style type="text/css"> 
<!--
body{background-color:#ffd;}
ul{margin:0em;padding-left:1em;}
li{line-height:1.5em;margin:0em;}
-->
</style> 
</head>
);

# HTML
print qq(<body><div><ul>$line</ul></div>);

# フッタ
print qq(</body></html>);

exit;


}



#-----------------------------------------------------------
# 切り替えリンクを定義
#-----------------------------------------------------------
sub get_tablinks{

# 局所化
my($i);

# リンクを定義
my @tablinks = (
'normal=新規再生順',
'count=再生回数順',
'title=タイトル順'
);

# リンクを展開
foreach(@tablinks){
my($type,$name) = split(/=/);
$i++;
if($i >= 2){ $tablinks .= qq( - ); }
if($type eq $submode3){ $tablinks .= qq($name); }
else{ $tablinks .= qq(<a href="${script}msc-list-$type-1.html">$name</a>); }
}

$tablinks .= qq(　｜　) . qq(<a href="http://aurasoul.mb2.jp/_shop/v-song.html">作詞作曲サービス</a>);


# 整形
#$tablinks = qq(<h2>再生形式</h2>$tablinks);
$tablinks = qq(<div class="tablinks">$tablinks</div>);

}

#-----------------------------------------------------------
# ソース変更フォーム
#-----------------------------------------------------------
sub get_source{

open(COUNT_IN,"${msc_dir}play.cgi");
while(<COUNT_IN>){
s/>/&gt;/g;
s/</&lt;/g;
s/"/&quot;/g;
$source_line .= qq($_);

}
close(COUNT_IN);

$source_line = qq(
<h2>ソ\ー\ス変更</h2>
 [ キー&lt;&gt;曲名&lt;&gt;音楽ファイル名&lt;&gt;再生回数&lt;&gt;評価回数&lt;&gt;ＸＩＰ ] <br><br>

<form action="$script" method="post">
<div>
<textarea name="source" rows="50" cols="50" class="source">$source_line</textarea>
<input type="hidden" name="mode" value="msc-editsource">
<input type="submit" value="ソ\ー\ス\を変更する">
</div>
</form>

);

}

#-----------------------------------------------------------
# ソース変更処理を実行
#-----------------------------------------------------------
sub editsource{

# 管理者でない場合
if($myadmin_flag < 5){ &error("ファイルが存在しません。"); }

# 入力ソースを変換
$in{'source'} =~ s/<br>/\n/g;
$in{'source'} =~ s/&gt;/>/g;
$in{'source'} =~ s/&lt;/</g;
$in{'source'} =~ s/&quot;/"/g;

# 危険なタグを排他
Mebius::DangerTag("Error-view",$in{'source'});

# ロック開始
&lock("mscplay") if $lockkey;

# プレイリストファイルを更新
Mebius::Fileout(undef,"${msc_dir}play.cgi",$in{'source'});

# ロック解除
&unlock("mscplay") if $lockkey;

# リダイレクト
print "location:$script?mode=msc-list-normal-1\n\n";

exit;

}


use strict;
package Mebius::Music;

#-----------------------------------------------------------
# 楽曲を再生、カウント増加
#-----------------------------------------------------------
sub Play{

# 宣言
my($file) = @_;
my($return);

	# ファイル定義
	if($file =~ /\/|\.\./ || $file =~ /[^\w\.\-]/){ main::error("ファイル指定が変です。"); }
	if($file eq ""){ main::error("ファイルを指定してください。"); }
my($file_encoded) = Mebius::Encode(undef,$file);

	# 音源ファイルの有無をチェック
	if($file !~ /\.(\w+)$/){ $file = "$file.mp3"; }
	if(!-f "${main::msc_dir}$file"){ main::error("存在しないファイルです。"); }

	# カウント開始
	if(($main::agent || $main::cookie || $main::k_access) && !$main::bot_access){
		&Count();
		&PlayIndex(undef,$file);
	}

	# リダイレクト
	if($main::in{'k'} || (!$main::bot_access && $main::device_type eq "mobile")){
		my($url_encoded) = Mebius::Encode(undef,"$main::music_url_redirect$file");
		#Mebius::Redirect(undef,"http://mp3.3gp.fm/q/Link.aspx?u=$url_encoded");
		Mebius::Redirect("","$main::music_url_redirect$file",301);
	}
	else{
		Mebius::Redirect("","$main::music_url_redirect$file",301);
	}

exit;
}

#-----------------------------------------------------------
# 再生回数ファイル ( 個別 )
#-----------------------------------------------------------
sub Count{


}


no strict;

#-----------------------------------------------------------
# 再生回数をカウント ( インデックス )
#-----------------------------------------------------------
sub PlayIndex{

# 宣言
my($type,$file) = @_;
my($line,$plus_line,$flag,$nomake_flag,$newkey,$count_handler,$redun_count_flag);

# ファイル定義
if($file eq ""){ return; }
my($file_encoded) = Mebius::Encode(undef,$file);
my $count_file = "${main::int_dir}_music/play/${file_encoded}.dat";
my $index_file = "${main::int_dir}_music/play.log";

# ●単体ファイルを開く
open($count_handler,"<$count_file");

# ファイルロック
flock($count_handler,1);

# トップデータを分解
chomp(my $top1_count = <$count_handler>);
my($tkey,$tcount,$tsubject) = split(/<>/,$top1_count);

# 新しいキーを定義
if($file =~ /^(pre|mix|back)/){ $tkey = 0; } else { $tkey = 1; }

	# 曲名を補完する
	my $num = ($referer =~ s/^http:\/\/aurasoul\.mb2\.jp\/_(ams|asx|asd|amb)\/([0-9]+)\.html$/$&/g);
	if($word_url eq "" && $num){ $word_url = $referer; }
	if($sub eq "" && $num){ $sub = &get_sub($1,$2); }
	if($file =~ /([0-9]+)\.mp3$/){ $sub = "$sub - take$1"; }
	if($main::myadmin_flag < 5){ $tcount++; }

	# ファイルを展開
	while(<$count_handler>){

		# 行を分解
		chomp;
		my($lasttime2,$addr2,$agent2) = split(/<>/);

		# 一定時間が経過している場合
		if($main::time > $lasttime2 * 24*60*60){ next; }

		# 重複カウントの場合
		if($agent2 && $agent2 eq $main::agent){ $redun_count_flag = 1; }
		if($addr2 && $addr2 eq $main::addr && $main::k_access){ $redun_count_flag = 1; }

		# 更新用
		push(@renewline_count,"$lasttime2<>$addr2<>$agent2<>\n");

	}

close($count_handler);

# カウントせずにリターンする場合
if($redun_count_flag && $main::myadmin_flag < 5){ return(); }

# プレイリストファイルを開く
open($index_handler,"<$index_file");

	# ファイルロック
	flock($index_handler,1);

	# ファイルを展開
	while(<$index_handler>){
		chomp;
		my($key,$sub,$mscfile,$count,$support,$word_url) = split(/<>/);
			if($mscfile eq $file){
				$flag = 1;

				if($myadmin_flag < 5){ $count++; }
				$plus_line = qq($key<>$sub<>$mscfile<>$count<>$support<>$word_url<><>\n);
			}
			else{ $line .= qq($key<>$sub<>$mscfile<>$count<>$support<>$word_url<>$addr2<>\n); }
	}
close($index_handler);

	# 自分で聴いた場合など、リターン
	if($flag && $myadmin_flag >= 5){ return; }
	if($file =~ /^back-/){ return; }

# 新規行の作成
$line = $plus_line . $line;
$line = qq($tkey<>$tsubject<>$file<>$count<><>$word_url<><>\n) . $line;

# プレイリストファイルを更新
Mebius::Fileout(undef,$index_file,$line);

# 再生回数のカウントファイルを更新
unshift(@renewline_count,"$main:addr<>$main::agent<>\n");
unshift(@renewline_count,"$tkey<>$tcount<>$tsubject<>\n");
Mebius::Fileout(undef,$count_file,@renewline_count);

}

package main;

#-----------------------------------------------------------
# 元記事の題名取得
#-----------------------------------------------------------
sub get_sub{

# ファイル定義
my($moto,$no) = @_;
$moto =~ s/\W//g;
$no =~ s/\D//g;
	if($moto eq ""){ return; }
	if($no eq ""){ return; }

open(DATA_IN,"${int_dir}${moto}_log/$no.cgi");
my $top = <DATA_IN>;
my($no,$sub) = split(/<>/,$top);
close(DATA_IN);

return ($sub);
}

# 宣言
use strict;
package Mebius::Music;





1;

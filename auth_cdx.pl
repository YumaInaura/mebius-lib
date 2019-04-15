
package main;

#-----------------------------------------------------------
# 旧・伝言版の表示
#-----------------------------------------------------------
sub auth_cdx{

# 局所化
my($file,$line,$i,$yearfile,$monthfile,$comments,$link2,$index);

# 汚染チェック１
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# 汚染チェック２
$yearfile = $submode2;
$yearfile =~ s/\D//g;

# リダイレクト
Mebius::Redirect("","$auth_url$file/viewcomment-$yearfile",301);

exit;

# CSS定義
$css_text .= qq(
.ctextarea{width:95%;height:35px;}
.cbottun{margin-top:0.5em;}
.clog{font-size:90%;}
.lic{margin-bottom:0.3em;line-height:1.25em;}
.deleted{font-size:90%;color:#f00;}
a.me:link{color:#f00;}
a.me:visited{color:#f40;}
strong.alert{font-size:90%;color:#f00;}
table,th,tr,td{border-style:none;}
table{font-size:90%;width:100%;}
th{text-align:left;padding:0.5em 1.0em 0.5em 0.0em;}
th.date{width:20%;}
th.name{width:20%;}
th.comment{width:50%;}
td{padding:0.2em 1.0em 0.5em 0.0em;line-height:1.4em;}
td{word-wrap:break-word;}
);

# プロフィールを開く
&open($file);

# 非表示設定の場合
if($ppocomment eq "3" && !$myadmin_flag){ &error("このメンバーの伝言版は非表\示設定されています。","401 Unauthorized"); }

# ユーザー色指定
if($ppcolor1){ $css_text .= qq(h2{background-color:#$ppcolor1;border-color:#$ppcolor1;}); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# 該当コメントを開く
open(COMMENT_IN,"<",${account_directory}comments/${file}_${yearfile}_comment.cgi");
while(<COMMENT_IN>){
$i++;
if($i > 500){ last; }
my($key,$rgtime,$account,$name,$trip,$id,$comment,$dates,$xip,$res,$deleter) = split(/<>/,$_);
my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);

my $link = qq($adir$account/);
if($aurl_mode){ ($link) = &aurl($link); }

$comment =~ s/<br>/ /g;
($comment) = &auth_auto_link($comment);
if($res && $res !~ /\D/){ $res = qq( ( No.$res ) ); } else { $res = ""; }

# 普通に表示
if($key eq "1"){
my($class,$del);
if($myprof_flag || $account eq "$pmfile" || $myadmin_flag){
$del = qq( <a href="$script?mode=comdel&amp;account=$file&amp;rgtime=$rgtime&amp;year=$year">削除</a> );
}
if($account eq $file){ $class = qq( class="me"); }
$comments .= qq(<tr><td><a href="$link"$class>$name - $account</a></td><td>$comment $res $del</td><td>$year年$month月$day日 $hour時$min分</td></tr>);
}

# 削除済みの場合
else{
my($deleted,$text);
if($key eq "2"){ $text = qq($res【アカウント主削除】); }
elsif($key eq "3"){ $text = qq($res【投稿主削除】); }
elsif($key eq "4"){ $text = qq($res【管理者削除】 $deleter); }
if($myadmin_flag){ $text = qq( $comment $text); }
$text = qq(<span class="deleted">$text</span>);

$comments .= qq(<tr><td><a href="$link">$account</a></td><td>$text</td><td>$year年$month月$day日 $hour時$min分</td></tr>);
}

}
close(COMMENT_IN);

# ＵＲＬ変換
if($aurl_mode){ ($comments) = &aurl($comments); }

# コメント部分整形
$comments = qq(
<h2>コメント</h2>
<table summary="伝言一覧"><tr><th class="name">筆名</th><th class="comment">伝言</th><th class="date">時刻</th></tr>\n
$comments
</table>
)if $comments;

# インデックス取得
allindex_auth_comment($file);

# タイトル定義
$sub_title = qq(${yearfile}年${monthfile}の伝言 : $ppname - $ppfile);

# ヘッダ
main::header();

$link2 = qq($adir$file/);
if($aurl_mode){ ($link2) = &aurl($link2); }

# HTML
print <<"EOM";
<div class="body1">
$footer_link
<h1>${yearfile}年${monthfile}の伝言 : $ppname - $ppfile</h1>
<a href="$link2">$ppname - $ppfile のプロフィールに戻る</a>
$comments
<h2>年別一覧</h2>
$index
<br><br>
$footer_link2
</div>
EOM

# フッタ
&footer();

# 終了
exit;

}


#-----------------------------------------------------------
# 伝言板、年毎のインデックスを開く
#-----------------------------------------------------------

sub allindex_auth_comment{

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# コメントインデックスを開く
open(COMMENT_INDEX_IN,"<","${account_directory}comments/${file}_index_comment.cgi");
while(<COMMENT_INDEX_IN>){
my($year) = split(/<>/,$_);
my $link = qq($adir$file/cdx-$year);
if($aurl_mode){ ($link) = &aurl($link); }
if($year eq $yearfile){ $index .= qq($year年 ); }
else{ $index .= qq(<a href="$link">$year年</a> ); }
}
close(COMMENT_INDEX_IN);

}




1;

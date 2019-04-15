
package main;

#-----------------------------------------------------------
# ＳＮＳタグ
#-----------------------------------------------------------
sub auth_schtag{

# 局所化
my($type,$file,$maxtag,$max_comment) = @_;
my($tagline,$i,$line,$hit);

# 検索実行
if($in{'word'} ne ""){ ($line) = &search_action($in{'word'}); }

# CSS定義
$css_text .= qq(
.google_link{font-size:150%;}
);

# タイトル定義
$sub_title = "タグ検索 - $title";
$head_link3 = " &gt; タグ検索 ";

# タグ検索フォームを取得
&get_schform();

# ログイン中の場合
my($navilink);
if($idcheck){ $navilink .= qq(<a href="./$pmfile/tag-view">→タグを登録する</a> - ); }
$navilink .= qq(<a href="./tag-new.html">新着タグをチェックする</a>);

# HTML
my $print = qq(
$footer_link
<h1>タグ検索</h1>
$navilink
$schform
$line
$footer_link2
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

use Mebius::Tag;

#-----------------------------------------------------------
# 検索実行
#-----------------------------------------------------------
sub search_action{


# 局所化
my($tag) = @_;
my($i,$enc_word,$line);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

$enc_word = Mebius::Encode("",$tag);

# キーワード整形
($tag) = Mebius::Tag::FixTag(undef,$tag);

# 全タグファイルを開く
open(ALLTAG_IN,"<","${auth_log_directory}alltag.cgi");
while(<ALLTAG_IN>){
$i++;
chomp;
if($_ =~ /\Q$tag\E/i){
$hit++;
my $enc_tag = $_;
$enc_tag =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;
$enc_tag =~ tr/ /+/;
$line .= qq(<li><a href="./tag-word-$enc_tag.html">$_</a>);
}
}
close(ALLTAG_IN);

# 整形

my $google_link = qq(<a href="http://www.google.co.jp/search?q=$enc_word&amp;sitesearch=mb2.jp&amp;ie=Shift_JIS&amp;oe=Shift_JIS&amp;hl=ja&amp;domains=mb2.jp" class="google_link" rel="nofollow">→”$in{'word'}”をGoogle検索してみる</a>);

if($line eq ""){ $line = qq(<h2>検索結果</h2>ヒットしませんでした。キーワードを変えて試してください。<br><br>$google_link); }
else{ $line = qq(<h2>検索結果 ($hit件)</h2><ul>$line</ul><br>$google_link); }

return($line);

}

1;

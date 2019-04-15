#-----------------------------------------------------------
# レス修正履歴のリスト
#-----------------------------------------------------------

sub main_vresedit{

# 局所化
my($i,$line,$max);

# 最大表示数
$max = 100;

# CSS定義
$css_text .= qq(
li{line-height:1.5em;}
);


# バックアップを開く
open(BKUP_IN,"${int_dir}_backup/resedit_backup.cgi");
while(<BKUP_IN>){
$i++;
chomp;
my($res,$ranum,$nam,$trip,$com,$dat,$ho,$id,$color,$agent,$ip,$delete,$account,$editdate,$moto2,$no) = split(/<>/,$_);
$line .= qq(<li><a href="/_$moto2/$no.html-$res#a">$moto2 - 記事$no - レス$res</a> - $editdate - <a href="http://mb2.jp/_auth/$account/">$nam</a>\n);
if(!$myadmin_flag && $i > $max){ last; }
}
close(BKUP_IN);

# タイトル定義
$sub_title = "レス修正履歴 - $server_domain";
$head_link2 = qq( &gt; <a href="http://$server_domain/">$server_domain</a> );
$head_link3 = " &gt; レス修正履歴 ";

my $print = qq(
<h1>レス修正履歴 - $server_domain</h1>
<ul>$line</ul>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;

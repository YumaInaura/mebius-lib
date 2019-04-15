
package main;

#-----------------------------------------------------------
# 掲示板のフィードを表示
#-----------------------------------------------------------
sub bbs_view_feed{

# 局所化
my($line,$items,$rssdate,$i,@sortdata,@filedata);
my $times = new Mebius::Time;
our(%bbs);

# インデックスを展開
open(IN,"$nowfile") || &error("現行インデックスが開けません");
my $top = <IN>;
	while(<IN>){
		push @filedata,$_;
	}
close(IN);

# レス時間順にソート
@sortdata = sort { (split(/<>/,$b))[4] <=> (split(/<>/,$a))[4] } @filedata;

	foreach(@sortdata){

		my($lognumber,$sub,$res,$nam,$last,$lastman,$key) = split(/<>/);

		# スレッドを開く
		my($thread) = Mebius::BBS::thread({ ReturnRef => 1 },$moto,$lognumber);

		chomp(my $top = $thread->{'all_line'}->[0]);
		my($no,$sub,$res,$key,$res_pwd,$t_res,$d_delman,$d_password,$dd1,$sexvio,$dd3,$dd4,$memo_editor,$memo_body,$dd7,$dd8,$juufuku_com,$posttime) = split(/<>/,$top);

		# リターンする場合
		if($key ne "1" || $sexvio || !$t_res || $juufuku_com eq ""){ next; }

		# 説明文 ( description ) を定義

		my $description = $juufuku_com;

		my($text,$length);
		foreach(split(/<br>/,$description)){
		$text .= qq( $_);
		$length += length $_;
		if($length >= 100){ last; }
		}

		# 本文整形
		$description = $text;
		$description =~ s/<(.+?)>//g;

		# 時刻を定義
		my($date) = $times->localtime_to_gmt_date($t_res);

		# RSSの最新時刻をフック
		if(!$rssdate){ $rssdate = $date; }

		# 表示内容を定義
		$line .= qq(
		<item rdf:about="http://$server_domain/_$moto/$lognumber.html">
		<title>$sub</title>
		<link>http://$server_domain/_$moto/$lognumber.html#S$res</link>
		<description>$description</description>
		<dc:creator>$lastman</dc:creator>
		<dc:date>$date</dc:date>
		</item>
		);

		# アイテムを定義
		$items .= qq(<rdf:li rdf:resource="http://$server_domain/_$moto/$lognumber.html" />\n);

		# 表示件数マックスの場合
		$i++;
		if($i >= 10){ last; }

	}


# 掲示板の説明文
my $rssdescription = $bbs{'setumei'};
$rssdescription =~ s/(\n|\r)//g;
$rssdescription =~ s/<(.+?)>//g;

# RSSのヘッダ
&rssheader();

# XMLを出力
print qq(<channel rdf:about="http://$server_domain/_$moto/?mode=feed">
<title>$title</title>
<link>http://$server_domain/_$moto/</link>
<description>$rssdescription</description>
<dc:date>$rssdate</dc:date>

<items>
<rdf:Seq>
$items
</rdf:Seq>
</items>

</channel>

$line

</rdf:RDF>
);


exit;


}

#-----------------------------------------------------------
# ＲＳＳヘッダ
#-----------------------------------------------------------
sub rssheader{

# ヘッダを出力
print "Content-type:application/xml; charset=Shift_JIS";
print "\n\n";

print qq(<?xml version="1.0" encoding="Shift_JIS"?>
<?xml-stylesheet href="/style/feed.css" type="text/css"?>

<rdf:RDF
xmlns="http://purl.org/rss/1.0/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
xmlns:dc="http://purl.org/dc/elements/1.1/"
xml:lang="ja">);


}


1;


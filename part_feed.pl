
package main;

#-----------------------------------------------------------
# �f���̃t�B�[�h��\��
#-----------------------------------------------------------
sub bbs_view_feed{

# �Ǐ���
my($line,$items,$rssdate,$i,@sortdata,@filedata);
my $times = new Mebius::Time;
our(%bbs);

# �C���f�b�N�X��W�J
open(IN,"$nowfile") || &error("���s�C���f�b�N�X���J���܂���");
my $top = <IN>;
	while(<IN>){
		push @filedata,$_;
	}
close(IN);

# ���X���ԏ��Ƀ\�[�g
@sortdata = sort { (split(/<>/,$b))[4] <=> (split(/<>/,$a))[4] } @filedata;

	foreach(@sortdata){

		my($lognumber,$sub,$res,$nam,$last,$lastman,$key) = split(/<>/);

		# �X���b�h���J��
		my($thread) = Mebius::BBS::thread({ ReturnRef => 1 },$moto,$lognumber);

		chomp(my $top = $thread->{'all_line'}->[0]);
		my($no,$sub,$res,$key,$res_pwd,$t_res,$d_delman,$d_password,$dd1,$sexvio,$dd3,$dd4,$memo_editor,$memo_body,$dd7,$dd8,$juufuku_com,$posttime) = split(/<>/,$top);

		# ���^�[������ꍇ
		if($key ne "1" || $sexvio || !$t_res || $juufuku_com eq ""){ next; }

		# ������ ( description ) ���`

		my $description = $juufuku_com;

		my($text,$length);
		foreach(split(/<br>/,$description)){
		$text .= qq( $_);
		$length += length $_;
		if($length >= 100){ last; }
		}

		# �{�����`
		$description = $text;
		$description =~ s/<(.+?)>//g;

		# �������`
		my($date) = $times->localtime_to_gmt_date($t_res);

		# RSS�̍ŐV�������t�b�N
		if(!$rssdate){ $rssdate = $date; }

		# �\�����e���`
		$line .= qq(
		<item rdf:about="http://$server_domain/_$moto/$lognumber.html">
		<title>$sub</title>
		<link>http://$server_domain/_$moto/$lognumber.html#S$res</link>
		<description>$description</description>
		<dc:creator>$lastman</dc:creator>
		<dc:date>$date</dc:date>
		</item>
		);

		# �A�C�e�����`
		$items .= qq(<rdf:li rdf:resource="http://$server_domain/_$moto/$lognumber.html" />\n);

		# �\�������}�b�N�X�̏ꍇ
		$i++;
		if($i >= 10){ last; }

	}


# �f���̐�����
my $rssdescription = $bbs{'setumei'};
$rssdescription =~ s/(\n|\r)//g;
$rssdescription =~ s/<(.+?)>//g;

# RSS�̃w�b�_
&rssheader();

# XML���o��
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
# �q�r�r�w�b�_
#-----------------------------------------------------------
sub rssheader{

# �w�b�_���o��
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


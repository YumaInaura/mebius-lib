#-----------------------------------------------------------
# ���X�C�������̃��X�g
#-----------------------------------------------------------

sub main_vresedit{

# �Ǐ���
my($i,$line,$max);

# �ő�\����
$max = 100;

# CSS��`
$css_text .= qq(
li{line-height:1.5em;}
);


# �o�b�N�A�b�v���J��
open(BKUP_IN,"${int_dir}_backup/resedit_backup.cgi");
while(<BKUP_IN>){
$i++;
chomp;
my($res,$ranum,$nam,$trip,$com,$dat,$ho,$id,$color,$agent,$ip,$delete,$account,$editdate,$moto2,$no) = split(/<>/,$_);
$line .= qq(<li><a href="/_$moto2/$no.html-$res#a">$moto2 - �L��$no - ���X$res</a> - $editdate - <a href="http://mb2.jp/_auth/$account/">$nam</a>\n);
if(!$myadmin_flag && $i > $max){ last; }
}
close(BKUP_IN);

# �^�C�g����`
$sub_title = "���X�C������ - $server_domain";
$head_link2 = qq( &gt; <a href="http://$server_domain/">$server_domain</a> );
$head_link3 = " &gt; ���X�C������ ";

my $print = qq(
<h1>���X�C������ - $server_domain</h1>
<ul>$line</ul>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;

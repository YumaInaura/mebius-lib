#-----------------------------------------------------------
# �A�J�E���g�ҏW�̃R�A����
#-----------------------------------------------------------

sub seditprof{

# �Ǐ���
my($line,$bkline,$max_bkup,$bki);
our($addr,$xip,$date,$cnumber,%in);

# �o�b�N�A�b�v�̍ő�s��
$max_bkup = 5;

# �t�@�C����`
my($file) = @_;
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("�l��ݒ肵�Ă��������B"); }

# �o�b�N�A�b�v���J��
$bkline = qq($in{'prof'}<>$xip<>$date<>$cnumber<>$addr<>\n);
open(PROF_BKUP_IN,"${int_dir}_id/$file/${file}_bkup.cgi");
while(<PROF_BKUP_IN>){
$bki++;
if($bki < $max_bkup){ $bkline .= $_; }
}
close(PROF_BKUP_IN);

# �������ݓ��e
$line = <<"EOM";
$ppkey<>$ppaccount<>$pppass<>$ppsalt<>$ppfirsttime<>$ppblocktime<>$pplasttime<>$ppadlasttime<>
$ppname<>$ppmtrip<>$ppcolor1<>$ppcolor2<>$ppprof<>
$ppocomment<>$ppodiary<>$ppobbs<>$pposdiary<>$pposbbs<>$pporireki<>
$ppencid<>$ppenctrip<>
$pplevel<>$pplevel2<>$ppsurl<>$ppadmin<>$ppchat<>$ppreason<>
$ppemail<>$ppmlpass<>
EOM

# �t�@�C���ɏ�������
open(PROF_OUT,">${int_dir}_id/$file/$file.cgi");
print PROF_OUT $line; 
close(PROF_OUT);
chmod($logpms,"${int_dir}_id/$file/$file.cgi");

}

1;


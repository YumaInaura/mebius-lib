#-----------------------------------------------------------
# �m�F���[���̔z�M
#-----------------------------------------------------------

sub send_cermail{

# �錾
my($type,$input_email) = @_;
my($file) = @_;
my($line,$top1,$random,$subject,$body,$file_deny2,$top_deny1,$top_deny2);

my $max_submitlog = 50;

# ���e����
require "${int_dir}part_axscheck.pl";
if($emd){ $e_access =~ s/<br>//g; $e_access =~ s/�@//g; &error("$e_access"); }

# �F�؍ς݂̏ꍇ�A���^�[��
if($in{'certype'} eq "sns"){
if($pmmlpass) { return; }
}
else{
if($cmon_flag) { return; }
}

# ���[���A�h���X�̏�������
if($input_email =~ /[^0-9a-zA-Z_\-\.\@]/) { &error("���[���A�h���X�Ɏg���Ȃ��������܂܂�Ă��܂��B"); }
if($input_email && $input_email !~ /^[\w\.\-]+\@[\w\.\-]+\.[a-zA-Z]{2,6}$/) { &error("���[���A�h���X�̏������Ԉ���Ă��܂��B"); }

# �t�@�C����`
$file = $input_email;
$file =~ s/(\W)/'%' . unpack('H2' , $1)/eg;
$file =~ tr/ /+/;
if($file eq ""){ &error("���[���A�h���X����(�J��)�ł��B"); }

# �A�����M���֎~
open(SUBMITLOG_IN,"${int_dir}_cermail/submitlog.cgi");
my($i_submitlog);
while(<SUBMITLOG_IN>){
$i_submitlog++;
my($mail,$submit_xip,$oktime) = split(/<>/);
if( ($input_email eq $mail || $submit_xip eq $xip_enc) && $time < $oktime && !$alocal_mode){ $return = qq(�Z���Ԃł̘A���\\���͂ł��܂���B���΂炭��ő��M���Ă��������B); }
if($i_submitlog < $max_submitlog){ $line_submitlog .= $_; }
}
close(SUBMITLOG_IN);

# ���f��񂪂���ꍇ�A�u���b�N
open(DENY1_IN,"${ip_dir}_ip_denycermail_xip/${xip_enc}.cgi");
$top_deny1 = <DENY1_IN>;
my($oktime1) = split(/<>/,$top_deny1);
if($oktime1 && $time < $oktime1 && !$alocal_mode){ $return = qq(���f�s�ׂ̕񍐂ɂ��A�F�؃��[���𑗂�܂���ł����B); }
close(DENY1_IN);

# �����`�F�b�N
$file_deny2 = $cnumber;
$file_deny2 =~ s/\W//g;

# ���f��񂪂���ꍇ�A�u���b�N
open(DENY2_IN,"${ip_dir}_ip_denycermail_cnumber/$file_deny2.cgi");
$top_deny2 = <DENY2_IN>;
my($oktime2) = split(/<>/,$top_deny2);
if($oktime2 && $time < $oktime2 && !$alocal_mode){ $return = qq(���f�s�ׂ̕񍐂ɂ��A�F�؃��[���𑗂�܂���ł����B); }
close(DENY2_IN);

# ���[���A�h���X���֎~����Ă���ꍇ�A�u���b�N
open(DENYMAIL_IN,"${ip_dir}_ip_denycermail_address/$file.cgi");
my $top_denyaddress = <DENYMAIL_IN>;
my($btime_denyaddress) = split(/<>/,$top_denyaddress);
close(DENYMAIL_IN);
if($btime_denyaddress){ $return = qq(���̃��[���A�h���X�͋֎~����Ă��܂��B); }

# �G���[�Ń��^�[������ꍇ
if($return){ return; }

# ���b�N�J�n
&lock("cermail") if($lockkey);

# �A�h���X�t�@�C�����J��
open(CERMAIL_IN,"${int_dir}_2cermail/$file.cgi");
$top1 = <CERMAIL_IN>;
my($key,$pass,$lasttime) = split(/<>/,$top1);
close(CERMAIL_IN);

# �G���[�������ꍇ
#if($lasttime > $time - 1*60*60 && !$alocal_mode){ $return = qq(���̃��[���A�h���X�͐\\���ς݂ł��A���[���{�b�N�X���m�F���Ă��������B�đ��M����ꍇ�́A1���Ԃقǎ��Ԃ��󂯂Ă��������B); }

# �����_���ȕ�����
@charpass = ('a'..'z', 'A'..'Z', '0'..'9');
for(0..10){
$putpass .= $charpass[int(rand(@charpass))]; 
}

# �F�؃t�@�C���̃L�[��`
my($putkey);
if($in{'certype'} eq "sns"){ $putkey = "2"; } else{ $putkey = 1; }

# �����o���s
$line = qq($putkey<>$putpass<>$time<>$host<>$xip_enc<>$cnumber<>$pmfile<>\n);

# �A�h���X�t�@�C���������o��
open(CERMAIL_OUT,">${int_dir}_2cermail/$file.cgi");
print CERMAIL_OUT $line;
close(CERMAIL_OUT);
chmod($logpms,"${int_dir}_2cermail/$file.cgi")

# ���b�N����
&unlock("cermail") if($lockkey);

# �h�c�t�^
&id;

# �A�����M�֎~�t�@�C������������
my $nexttime_submitlog = $time + 60*5;
$line_submitlog = qq($input_email<>$xip_enc<>$nexttime_submitlog<>\n) . $line_submitlog;
open(SUBMITLOG_OUT,">${int_dir}_cermail/submitlog.cgi");
print SUBMITLOG_OUT $line_submitlog;
close(SUBMITLOG_OUT);
chmod($logpms,"${int_dir}_cermail/submitlog.cgi");

# ���[������
$subject = qq(���[���A�h���X�F�� -���r�E�X�����O);
# ���[���{��
$body = qq(���r�E�X�����O�ł̃��[���F�؂������Ȃ��܂��B
���[���A�h���X�͔���J�ŁA���m�点�z�M�ȊO�ɂ͎g���܂���B

���̂t�q�k�ɃA�N�Z�X����ƁA�F�؂��������܂��B
http://$server_domain/_main/?mode=my&type=cermail&pass=$putpass&email=$file$kmailtag

���̃��[���Ɋo�����Ȃ��ꍇ�́A���萔�ł������[�����폜���肢���܂��B
���̂t�q�k���瑗�M���֎~���邱�Ƃ��o���܂��B
http://$server_domain/_main/?mode=my&type=cermail&deny=1&pass=$putpass&email=$file$kmailtag

���M�ҏ��
�M��: $chandle
ID: $encid
�z�X�g��: $host
�ڑ���: $xip);

# ���[�J��
if($alocal_mode){
$after_text1 = qq(
<a href="/_main/?mode=my&amp;type=cermail&amp;pass=$putpass&amp;email=$file$kmailtag">�F��</a>
<a href="/_main/?mode=my&amp;type=cermail&amp;pass=$putpass&amp;deny=1&amp;email=$file$kmailtag">����</a>
);
}

# ���[�����M
&Mebius::Email(undef,$input_email,$subject,$body);

# �t���O�𗧂Ă�
$sendcermail_flag = 1;

}

1;

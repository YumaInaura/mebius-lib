
use strict;

#-----------------------------------------------------------
# ���e���͂��L�^
#-----------------------------------------------------------
sub do_echeck{

# �錾
my($type,$echeck_flag) = @_;
my($line,$echeck_com,$file,$comment);
our($int_dir,$logpms,$moto,$server_domain,%in);
our($agent,$addr,$date,$i_handle,$i_resnumber,$realmoto,$int_dir,$newno,%in);
our($pmname);

# �����`�F�b�N
$echeck_flag =~ s/\W//g;
if($echeck_flag eq ""){ return; }

# ���e���͂��L�^
$comment = $in{'comment'};
$comment =~ s/<br>/\n/g;

# �L�^������e
$line .= <<"EOM";
http://$server_domain/jak/${moto}.cgi?mode=view&no=$in{'res'}#S$in{'resnum'}
$in{'name'} ( $pmname )	$date	$addr
$agent
$comment
������������������������������������������������������������
EOM

# �t�@�C����`
$file = "${int_dir}_echeck/${echeck_flag}_echeck.log";

# �t�@�C������������
open(KIROKU_OUT,">>$file");
print KIROKU_OUT $line;
close(KIROKU_OUT);
chmod($logpms,$file);

# ���m���Ńt�@�C�����폜
if(rand(250) < 1){ unlink($file); }

}


1;

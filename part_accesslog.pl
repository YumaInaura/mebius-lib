package main;

#-----------------------------------------------------------
# �A�N�Z�X���O�̋L�^
#-----------------------------------------------------------
sub do_access_log{

# �Ǐ���
my($input,$comment,$unlink_rand) = @_;
my($logname,$type) = split(/ /,$input);
my($init_directory) = Mebius::BaseInitDirectory();
our($date);



my($file,$line,$view_host);
my $logpms = 0606;

# �����`�F�b�N
$logname =~ s/[^\w-]//g;
if($logname eq ""){ return; }

# ���ϐ����擾
my $s1 = $ENV{'FORWARDED_FOR'};			#	squid�Ȃǂ�Cache�T�[�o�[���g���Ă�ꍇ�Ɂc
my $s2 = $ENV{'HTTP_CACHE_CONTROL'};		#	�L���b�V������Œ����ԂȂ�
my $s1 = $ENV{'HTTP_CACHE_INFO'};		#	�L���b�V���̏��
my $client_addr = $ENV{'HTTP_CLIENT_IP'};	#	�ڑ�����IP�A�h���X
my $s1 = $ENV{'HTTP_CONNECTION'};		#keep-alive;	�ڑ��̏��
my $s1 = $ENV{'HTTP_FORWARDED'};			#	�v���L�V�܂��̓N���C�A���g�̏ꏊ
my $s1 = $ENV{'HTTP_PRAGMA'};			#	�v���L�V�̃L���b�V���Ɋւ��铮�����
my $s1 = $ENV{'HTTP_PROXY_CONNECTION'};	#	�v���L�V�̐ڑ��`��
my $sp_host = $ENV{'HTTP_SP_HOST'};		#	�ڑ�����IP�A�h���X
my $s1 = $ENV{'HTTP_TE'};			#	�v���L�V�����T�|�[�g����Transfer-Encodings
my $s1 = $ENV{'HTTP_VIA'};			#	�v���L�V�̏��i�v���L�V�̎�ށC�o�[�W�������j
my $s1 = $ENV{'PROXY_CONNECTION'};		#	�v���L�V�̌��ʂȂǂ�\��
my $s1 = $ENV{'HTTP_X_FORWARDED_FOR'};		#
my $addr = $ENV{'REMOTE_ADDR'};
my $agent = $ENV{'HTTP_USER_AGENT'};
my $host2 = $ENV{'REMOTE_HOST'};
my $requri = $ENV{'REQUEST_URI'};
$view_host = $host;

# �������ݓ��e���`
$line .= qq($time	$date	$view_host	$addr $cliend_addr $sp_host	$moto $requri	$postbuf \n);
$line .= qq($agent $ENV{'HTTP_X_UP_SUBNO'} $ENV{'HTTP_X_EM_UID'}\n);
	if($cookie){
		my($cookie_dec) = Mebius::Decode("",$cookie);
		$line .= qq($cookie_dec\n);
	}
if($referer){ $line .= qq(Referer: $referer\n); }
if($comment){ $line .= qq($comment\n); }
$line .= qq(\n);


# �t�@�C����`
$file = "${init_directory}_accesslog/${logname}_accesslog.log";

# �t�@�C�����X�V
open(ACCESSLOG_OUT,">>$file");
print ACCESSLOG_OUT $line;
close(ACCESSLOG_OUT);
Mebius::Chmod(undef,"$file");

# ���m���Ńt�@�C�����폜
if(!$unlink_rand){ $unlink_rand = 500; } 
if(rand($unlink_rand) < 1){ unlink("$file"); }

}

1;

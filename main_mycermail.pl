
use Mebius::Auth;
package main;

#-----------------------------------------------------------
# ���[���F��
#-----------------------------------------------------------

# �^�C�g����`
sub main_mycermail{
$sub_title = "���[���F��";
$head_link3 = " &gt; ���[���F��";

# �X�N���v�g��
if($alocal_mode){ $script = "main.cgi"; }

# ���M���`
if($alocal_mode){ $action = "$script"; } else { $action = "./"; }
# ���[�h�U�蕪��
if($in{'deny'}){ &deny_cermail(); }
else{ &from_email(); }
}


#-----------------------------------------------------------
# ���[���F�؁i���[�����烊���N�����ǂ����ꍇ�j
#-----------------------------------------------------------

sub from_email{

# �Ǐ���
my($flag,$file,$line);

# �t�@�C����`
$file = $in{'email'};
$file =~ s/(\W)/'%' . unpack('H2' , $1)/eg;
$file =~ tr/ /+/;

# ���ɔF�؍ς݂̏ꍇ
#if(-e "${int_dir}_2sendmail/$file/main.cgi"){ &error("���̃��[���A�h���X�͊��ɔF�؍ς݂ł��B"); }

# �����A�h�F�ؑO�̃t�@�C�����J��
open(CERMAIL_IN,"${int_dir}_2cermail/$file.cgi")||&error("�t�@�C�������݂��܂���B���ɔF�؍ς݂̉\\��������܂��B");
my $top1 = <CERMAIL_IN>; chomp $top;
my($key,$pass,$lasttime,$host2,$addr2,$cnumber2,$pmfile2) = split(/<>/,$top1);
close(CERMAIL_IN);

# �F�؂ł����ꍇ�A�t���O�𗧂Ă�
if($pass ne $in{'pass'}){ &error("�F�؂ł��܂���ł���"); }

# �����o���s
$line = qq(1<>$pass<><><>$time<>$host<>$addr<>$cnumber<>$pmfile<>\n);

# �����A�h�F�؃t�@�C���������o��
&Mebius::Mkdir("","${int_dir}_2sendmail/$file",$dirpms);
open(SENDMAIL_OUT,">${int_dir}_2sendmail/$file/main.cgi");
print SENDMAIL_OUT $line;
close(SENDMAIL_OUT);
chmod($logpms,"${int_dir}_2sendmail/$file/main.cgi");

# ���̔F�؃t�@�C�����폜
unlink("${int_dir}_2cermail/$file.cgi");

# �y�[�W�W�����v
$jump_sec = 10;
$jump_url = "/_main/?mode=my";

	# SNS�F�؂̏ꍇ�A�A�J�E���g�t�@�C�����X�V
	if($key eq "2"){
		my(%renew);
		$renew{'email'} = $in{'email'};
		$renew{'mlpass'} = $pass;
		&Mebius::Auth::File("Renew",$pmfile2,%renew);
		$jump_url = "$auth_url$pmfile2/";
	}

# �w�b�_
&header;

# HTML
print qq(
<div class="body1">
���[���F�؂ɐ������܂����B<a href="$jump_url">���ړ�����</a>
</div>
);

# �t�b�^
&footer;

exit;

}

#-----------------------------------------------------------
# �C�^�Y������ �\�����
#-----------------------------------------------------------
sub deny_cermail{

# �Ǐ���
my($line,$file,$email);

# �t�@�C����`
$file = $in{'email'};
$file =~ s/(\W)/'%' . unpack('H2' , $1)/eg;
$file =~ tr/ /+/;

# ���[���A�h���X�̃f�R�[�h
$email = $file;
$email =~ tr/+/ /;
$email =~ s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2', $1)/eg;

# �A�h���X�t�@�C�����J��
open(CERMAIL_IN,"${int_dir}_2cermail/$file.cgi") || &error("�t�@�C�������݂��܂���");
$top1 = <CERMAIL_IN>;
my($key,$pass,$lasttime,$xip_enc2,$number) = split(/<>/,$top1);
close(CERMAIL_IN);

# �F�؂ł����ꍇ�A�t���O�𗧂Ă�
if($pass ne $in{'pass'}){ &error("�F�؂ł��܂���ł���"); }

# �����̎��s
if($in{'action'}){ &deny_cermail_action($file); }

# �w�b�_
&header();

# HTML
print qq(
<div class="body1">
�C�^�Y�����Ⴂ�ŔF�؃��[��������ꂽ�ꍇ�A<br>
���̃��[���A�h���X�ւ̑��M���֎~���邱�Ƃ��o���܂��B<br>
�܂��A���M�҂̃A�N�V�������֎~���邱�Ƃ��o���܂��B<br><br>

�i <a href="http://$server_domain/">$server_domain</a> �̃h���C���̂� �j�B

<form action="$action" method="post">
<div>
<input type="hidden" name="pass" value="$pass">
<input type="hidden" name="email" value="$email">
<input type="hidden" name="mode" value="my">
<input type="hidden" name="type" value="cermail">
<input type="hidden" name="deny" value="1">
<input type="hidden" name="action" value="1">
<input type="checkbox" name="deny_address" value="1" id="deny_address" $main::checked> <label for="deny_address">���̃��[���A�h���X���֎~����</label>
<input type="checkbox" name="deny_sender" value="1" id="deny_sender" $main::checked> <label for="deny_sender">���̑��M�҂��֎~����</label>
<input type="submit" value="���̓��e�ő��M����">

</div>
</form>

</div>
);

# �t�b�^
&footer();

exit;

}

#-----------------------------------------------------------
# �C�^�Y�������̎��s
#-----------------------------------------------------------
sub deny_cermail_action{

# GET���M���֎~
if(!$postflag){ &error("�s���ȃA�N�Z�X�ł��B"); }

# �Ǐ���
my($denyline1,$denyline2,$oktime);

# �֎~���鎞��
$oktime = $time+60*60*24*365;

# �t�@�C����`
my($file) = @_;

# �A�h���X�t�@�C�����J��
open(CERMAIL_IN,"${int_dir}_2cermail/$file.cgi")||&error("�t�@�C�������݂��܂���");
$top1 = <CERMAIL_IN>;
my($key,$pass,$lasttime,$xip_enc2,$number) = split(/<>/,$top1);
close(CERMAIL_IN);

# ���[���A�h���X�֎~�t�@�C������������
if($in{'deny_address'}){
my $line_denyaddress = qq($time<>\n);
open(DENYMAIL_OUT,">${ip_dir}_ip_denycermail_address/$file.cgi");
print DENYMAIL_OUT $line_denyaddress;
close(DENYMAIL_OUT);
chmod($logpms,"${ip_dir}_ip_denycermail_address/$file.cgi");
}

# ���M�҂̋֎~�t�@�C������������ - XIP
if($in{'deny_sender'}){
$denyline1 = qq($oktime<>\n);
open(DENY1_OUT,">${ip_dir}_ip_denycermail_xip/$xip_enc2.cgi");
print DENY1_OUT $denyline1;
close(DENY1_OUT);
chmod($logpms,"${ip_dir}_ip_denycermail_xip/$xip_enc2.cgi");
}


# �֎~�t�@�C������������ - CNUMBER
if($in{'deny_sender'}){
$denyline2 = qq($oktime<>\n);
open(DENY2_OUT,">${ip_dir}_ip_denycermail_cnumber/$number.cgi");
print DENY2_OUT $denyline2;
close(DENY2_OUT);
chmod($logpms,"${ip_dir}_ip_denycermail_cnumber/$number.cgi");
}

# �w�b�_
&header;

# HTML
print qq(
<div class="body1">
����ɋ֎~�ݒ肪�������܂����B<br>
���f�s�ׂ������ꍇ�́A���萔�ł���<a href="http://aurasoul.mb2.jp/etc/mail.html">���[���t�H�[��</a>�ł��A�����������i���r�E�X�����O�Ǘ��҂Ɍq����܂��j�B
</div>
);

# �t�b�^
&footer;

exit;

}


1;


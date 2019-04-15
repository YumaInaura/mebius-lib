
package main;

#-------------------------------------------------
# �v���t�B�[���t�@�C�����J���i���ʂ̉{���j
#-------------------------------------------------
sub do_auth_open{

# �J���t�@�C���̑I��
my($open,$type,$lock) = @_;
my(undef,undef,undef,%renew) = @_ if($type =~ /Renew/);
my($prof_handler,%account);

# �����`�F�b�N
$open =~ s/[^0-9a-z]//g;

# �������Ȃ��ꍇ
if($open eq ""){ &error("���̃A�J�E���g $open �͑��݂��܂���B"); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($open);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �h�c�t�@�C�����J��
open($prof_handler,"${account_directory}$open.cgi") || &error("���̃A�J�E���g $open �͑��݂��܂���B");
chomp(my $pptop1 = <$prof_handler>);
chomp(my $pptop2 = <$prof_handler>);
chomp(my $pptop3 = <$prof_handler>);
chomp(my $pptop4 = <$prof_handler>);
chomp(my $pptop5 = <$prof_handler>);
chomp(my $pptop6 = <$prof_handler>);

# �f�[�^�𕪉�
($ppkey,$ppaccount,$pppass,$ppsalt,$ppfirsttime,$ppblocktime,$pplasttime,$ppadlasttime) = split (/<>/,$pptop1);
($ppname,$ppmtrip,$ppcolor1,$ppcolor2,$ppprof,$ppedittime) = split (/<>/,$pptop2);
($ppocomment,$ppodiary,$ppobbs,$pposdiary,$pposbbs,$pporireki) = split (/<>/,$pptop3);
($ppencid,$ppenctrip) = split (/<>/,$pptop4);
($pplevel,$pplevel2,$ppsurl,$ppadmin,$ppchat,$ppreason) = split (/<>/,$pptop5);
($ppemail,$ppmlpass) = split (/<>/,$pptop6);
close($prof_handler);

# �A�J�E���g���b�N�̉�����
if($ppkey eq "2" && $ppblocktime && $time > $ppblocktime){ $ppkey = 1; }

# �L�[�`�F�b�N
if($type !~ /nocheck/){
	if($ppkey eq "0"){
		if($myadmin_flag){ $error_text = qq(���̃A�J�E���g�͍폜�ς݂ł��B); }
		else{ &error("���̃A�J�E���g�͍폜�ς݂ł��B","410 Gone"); }
	}
		if($ppkey eq "2"){
		if($lock && !$myadmin_flag){ &error("���̃A�J�E���g�̓��b�N���ł��B"); }
	}
}

# �}�C�v���t�̏ꍇ
if($pmfile eq $open){ $myprof_flag = 1; }

# �M���A�v���t�Ȃ��ꍇ
if($ppname eq ""){ $herbirdflag = 1; $ppname = "������"; }

# �����A�h�z�M�ݒ�̏ꍇ
if($ppemail ne "" && $ppmlpass ne ""){ $sendmail_flag = 1; }

$ppfile = $open;

return(%account);


}




1;

package main;

#-----------------------------------------------------------
# �V�K���e�̑҂����Ԃ��v�Z
#-----------------------------------------------------------
sub sum_newwait{

# �錾
my($type) = @_;
my($flag,$lefttime,$leftday,$lefthour,$leftmin,$ip_new_time,$bonusform_flag,$next_newwait_day,$next_newwait_hour);
my($threadnum,$none);
our($nowfile,$newwait,$time,$cnewtime,$no_xip_action,$idcheck,$cgold,$cnew_time,$xip_enc,$fastpost_mode);
my($share_directory) = Mebius::share_directory_path();

# �N�b�L�[���猻�݂̃`���[�W���Ԃ��Z�o
if($cnew_time && $time < $cnew_time) { $lefttime = ($cnew_time - $time) / 60; $newwait_flag = 1; } 

my $file = "${share_directory}_ip/_ip_new/${xip_enc}.cgi";

# �w�h�o���猻�݂̃`���[�W���Ԃ��Z�o
open(IP_NEW_IN,"<",$file);
$ip_new_time = <IP_NEW_IN>;
close(IP_NEW_IN);
if(!$no_xip_action && $time < $ip_new_time) { $lefttime = ($ip_new_time - $time) / 60; $newwait_flag = 1; }

# �t�@�C�����폜����ꍇ
	if($type =~ /UNLINK/){
		if(!$newwait_flag){ return(0); }
		else{ unlink($file); return(1); }
	}

# �e�`�r�s���[�h
#if($fastpost_mode || $alocal_mode){ $new_wait = 1; $newwait_flag = undef; $lefttime = 0; }
if($fastpost_mode){ $new_wait = 1; $newwait_flag = undef; $lefttime = 0; }

# ���[�J���Ő�������
#if($alocal_mode && $i_com =~ /�u���C�N/){ $flag = ""; }

# ���݂̎c��`���[�W���Ԃ��v�Z
my($leftdate) = Mebius::SplitTime("Not-get-second",$lefttime*60);

# ���݂̋L�����𒲂ׁA�{�[�i�X���[�h�𔭓�
open(NOWFILE,"$nowfile");
$none = <NOWFILE>;
while(<NOWFILE>){ $threadnum++; }
close(NOWFILE);

# �L���������Ȃ��ꍇ�A�ȈՓ��e�t�H�[����������A���̑҂����Ԃ����炷
if($threadnum < $new_wait){
$new_wait = int($threadnum * 0.25);
$bonusform_flag = 1;
}


# ���݂������ƗD��
if($idcheck && $cgold > 500){ $new_wait = int($new_wait*0.5); }

# ����̃`���[�W���ԁi�\���j���Z�o
$next_newwait_day = int($new_wait / 24);
$next_newwait_hour = int $new_wait - ($next_newwait_day*24);

return($newwait_flag,$leftdate,"$next_newwait_day��$next_newwait_hour����",$bonusform_flag);

}

#-----------------------------------------------------------
# �V�K���e�̃y�i���e�B���Ԃ��擾
#-----------------------------------------------------------
sub sum_newwait_penalty{

# �錾
our($cnumber,$agent,$host,$k_access,$postflag);

	# �z�X�g�����Ȃ��ꍇ�͎擾����
	if($host eq ""){
		($host) = Mebius::GetHostWithFile();
	}

if($cnumber){ &sum_newwait_penalty_do($cnumber); }
if($k_access && $postflag){ &sum_newwait_penalty_do($agent); }
elsif(!$k_access){ &sum_newwait_penalty_do($host); }

}

#-----------------------------------------------------------
# �V�K���e�A�e��y�i���e�B���Ԃ��v�Z
#-----------------------------------------------------------
sub sum_newwait_penalty_do{

# �錾
my($file) = @_;
my($top,$text1);
my($share_directory) = Mebius::share_directory_path();
our($time,$css_text);

# CSS��`
$css_text .= qq(
.your{font-size:140%;}
);

# �t�@�C����`
($file) = Mebius::Encode("",$file);
if($file eq ""){ return; }

# �t�@�C�����J��
open(DTIME_IN,"<","${share_directory}_ip/_ip_delnew/$file.cgi");
$top = <DTIME_IN>; chomp $top;
my($oktime,$bbs,$no) = split(/<>/,$top);
close(DTIME_IN);

# �҂����Ԃ��v�Z
my ($leftdate) = Mebius::SplitTime("Not-get-second",$oktime - $time);

# �G���[����
if($bbs && $no){ $text1 = qq(<a href="/$bbs/$no.html" class="your">���Ȃ��̍�����L��</a>); }
else{ $text1 = qq(���Ȃ��̍�����L��); }

my $text = qq(�Ǘ��҂ɂ���� $text1 ���폜���ꂽ���߁A���΂炭�V�K���e�ł��܂���B<br$xclose>
�\\���󂠂�܂��񂪁A���� $leftdate �قǂ��҂����������B
<br$xclose>
<br$xclose>���d���L���A���Ă���L�������܂���ł������H
<br$xclose>���L���̃e�[�}�͂ЂƂɍi��A�K�؂ȃ^�C�g�������܂������H
<br$xclose>�����[�J�����[���ɔ�������e�͂���܂���ł������H
<br$xclose>���Q���҂̐�����A�l�I�ȋL�������܂���ł������H
<br$xclose>���L�������J�e�S���͓K�؂ł������H

<br$xclose>
<br$xclose><a href="${guide_url}">�����K�C�h���C��</a>�⃍�[�J�����[�����ēx���m�F���������B
<a href="http://aurasoul.mb2.jp/_qst/1980.html">������͂�����܂łǂ���</a>�B<br$xclose>
);

# �y�i���e�B���Ԃ�����ꍇ�A�G���[
if($oktime && $time < $oktime){ &error($text); }

}

1;

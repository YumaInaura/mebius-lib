
use strict;
package main;
use Mebius::Export;
use Mebius::Penalty;
use Mebius::BBS::Wait;
use Mebius::Email;

#-----------------------------------------------------------
# ���݂̃`���[�W���Ԃ��擾 ( ���X ) - strict
#-----------------------------------------------------------
sub get_nowcharge_res{

# �錾
my($type,$comment) = @_;
my $penalty = new Mebius::Penalty;
my $email = new Mebius::Email;
my $bbs_wait = new Mebius::BBS::Wait;
my($my_cookie) = Mebius::my_cookie_main_logined();
my($share_directory) = Mebius::share_directory_path();
my($liberation_time,$nowcharge_time,$allcharge_time,$line_errorview);
my($long_length,$short_length,$javascript_value,$bonus_time,$allow_bonus_flag,$maxbonus_second);
my($lastrestime,$lastwaitsecond,$waitguide_link,$isp_data,$data);
my $time = time;

our($kflag,$xclose,$head_javascript,$line_noscript,$css_text,$agent,$cookie);
our($cres_time,$cres_waitsecond,$int_dir,$xip_enc,$xip,$no_xip_action,$alocal_mode);


	if($ENV{'REQUEST_METHOD'} eq "POST"){
		$isp_data = $penalty->my_isp_data();
	}

	if($isp_data->{'must_compare_xip_flag'}){

		my $message = "ISP $isp_data->{'file'} / �t���O $isp_data->{'must_compare_xip_flag'} / �O��̃��X���� $lastrestime / �҂��b�� $lastwaitsecond / ���ݎ��� $time";
		Mebius::access_log("BBS-wait-res",$message);
		$email->send_email_to_master("���b��ISP",$message);
	}

	# ���^�[��
	if($type =~ /REGIST/ && $comment !~ /wait/ && (Mebius::alocal_judge() || $main::bbs{'concept'} =~ /Local-mode/)){ return; }

	
	if( my $cookie_data = $bbs_wait->fetchrow_main_table_desc({ cnumber => $my_cookie->{'char'} },"create_time")->[0] ){
		$data = $cookie_data
	} else{
		$data = $bbs_wait->fetchrow_main_table_desc({ xip => $xip },"create_time")->[0];
	}

$lastrestime = $data->{'submit_time'};
$lastwaitsecond = $data->{'wait_second'};

# ���`���[�W���Ԃ��ŏI�v�Z ( ���ʏ��� )
$liberation_time = $lastrestime + $lastwaitsecond;	# �������
$nowcharge_time = $liberation_time - $time;			# ���݂̃`���[�W����
$allcharge_time = $liberation_time - $lastrestime;	# �`���[�W���Ԃ̒������ׂ�

	# �{�[�i�X���ԓK�p��������
	if($type =~ /REGIST/ && $cookie){ $allow_bonus_flag = 1; }
	if($my_cookie->{'call_save_data_flag'}){ $maxbonus_second = 30; }
	else{ $maxbonus_second = 45; }


	# ���݂̕������ɉ����āA�`���[�W���Ԃ�Z������ ( �{�[�i�X���ԎZ�o )
	if($allow_bonus_flag){
		require "${int_dir}regist_allcheck.pl";
		($long_length,$short_length) = &get_length("",$comment);
		$bonus_time = int($short_length / 5);
		if($bonus_time >= $allcharge_time - $maxbonus_second){ $bonus_time = $allcharge_time - $maxbonus_second; } # �`�b�ȏ�͒Z�����Ȃ�
		$nowcharge_time -= $bonus_time;
	}


# CSS���`
$css_text .= qq(
div.charge{border:1px #000 solid;padding:1em;background-color:#eee;line-height:1.6;}
);
	#if(Mebius::alocal_judge() && $ENV{'REQUEST_METHOD'} eq "POST"){ Mebius::Debug::Error(qq($lastrestime / $time )); }

	# �`���[�W���Ԃ�0�̏ꍇ�A���^�[��
	if($nowcharge_time <= 0){ return; }

# �K�C�h�����N���`
$waitguide_link = qq( ( <a href="${main::guide_url}%A5%C1%A5%E3%A1%BC%A5%B8%BB%FE%B4%D6" target="_blank" class="blank">���ڍ�</a> ));


		$javascript_value = "RESFORM";

	# �^�C�}�[���`
	require "${int_dir}part_timer.pl";
	($head_javascript,$line_noscript) = &get_timer("",$nowcharge_time,"$javascript_value");
	shift_jis($head_javascript,$line_noscript);


	# �g�єł̃G���[�\��
	if($kflag || $agent =~ /Nintendo Wii/){
		$line_errorview .= qq(���`���[�W���ł��B���� $line_noscript �ŏ������߂܂��B);
	}

	# �o�b�ł̃G���[�\��
	else{

		# �G���[�\��
		$line_errorview .= qq(
		���`���[�W���ł��B
		<script type="text/javascript">
		<!--
		document.write('���� <input type="text" name="waitsecond" value="" class="wait_input" readonly> �ŏ������߂܂��B$waitguide_link');
		//-->
		</script>
		<noscript><p class="noscript">
		���� <strong class="red">$line_noscript</strong> �ŏ������߂܂��B$waitguide_link
		</p></noscript>
		);
	}

	# �{�[�i�X���Ԃ̂��m�点
	if($allow_bonus_flag){
		$line_errorview .= qq(<br$xclose>�@ �������񏑂��΁A���݂̃`���[�W���Ԃ��Z���o���܂��B�i�������҂��͋֎~�ł��j<br$xclose>);
	}



return($line_errorview);

}

#-----------------------------------------------------------
# �������ɉ����āA����̃`���[�W���Ԃ��v�Z - strict
#-----------------------------------------------------------
sub get_nextcharge_res{

# �錾
my($type,$comment) = @_;
my($wait_minute,$bonus,$under_second,$lefttime,@waitlist,@kwaitlist,$top_second);
our($plus_bonus,$device_type,$k_access,$norank_wait);
our($idcheck,$plus_bonus,$csoutoukou,$int_dir,$deconum);

	# �`���[�W���Ԉꗥ�̏ꍇ
	if($norank_wait){
		$lefttime = $norank_wait*60;
			if($lefttime > 30){ $lefttime = 30; }
		return($lefttime);
	}

# �o�b�Ń`���[�W���Ԃ̐ݒ� ( ���݂Ȃ��̏ꍇ�A���݃}�C�i�X�̏ꍇ )
@waitlist = (
'200=0.5',
'150=1.0',
'100=1.5',
'75=2.0',
'50=3.0',
'30=3.5',
'0=4.0'
);

	# �g�у`���[�W���Ԃ̐ݒ� ( ���݂Ȃ��̏ꍇ�A���݃}�C�i�X�̏ꍇ )
	if($device_type eq "mobile" || $k_access || $main::device{'type'} eq "Portable-game-player"){
		@waitlist = (
		'150=0.5',
		'125=0.75',
		'100=1.0',
		'75=1.25',
		'50=1.5',
		'40=1.75',
		'30=2.0',
		'20=2.25',
		'10=2.5',
		'0=5.0'
		);
	}


# �������̔���
require "${int_dir}regist_allcheck.pl";
my($long_length,$short_length) = &get_length("",$comment,$deconum);

# �������ɂ���Ď���`���[�W���Ԃ��v�Z
my($hlength,$hnext);
	foreach(@waitlist){
		my($length,$next) = split(/=/,$_);
			if($short_length >= $length){
				$wait_minute = $next;
				last;
			}
		($hlength,$hnext) = ($length,$next);
	}

# ������b���ɕϊ�
$lefttime = $wait_minute*60;

# �f���{�[�i�X�����Z
$lefttime -= $plus_bonus;

	# �X�y�V��������{�[�i�X��ǉ�
	if($idcheck && $main::myaccount{'level2'} >= 1 && $main::myaccount{'key'} eq "1"){ $lefttime -= 15; }

	# ����`���[�W�̉����l�����߂�
	$under_second = 60;												# ���ʂ̏��
	if($main::cgold >= 10){ $under_second = 45; }					# ���ݔ���
	if($main::cgold >= 25){ $under_second = 30; }					# ���ݔ���
	if($device_type eq "mobile"){ $under_second = 30; }				# �g�тł͖������ɉ������ŒZ��
	if($lefttime < $under_second){ $lefttime = $under_second; }		# �K�p

	# ����`���[�W�̏���l�����߂�
	$top_second = 5*60;
	if($main::cgold eq ""){ $top_second = 3.0*60; }
	if($main::cgold >= 1){ $top_second = 3.0*60; }
	if($main::cgold >= 10){ $top_second = 2.5*60; }
	if($main::cgold >= 25){ $top_second = 2.0*60; }
	if($main::cgold >= 50){ $top_second = 1.5*60; }
	if($main::cgold >= 100){ $top_second = 1.0*60; }
	if($top_second && $lefttime > $top_second){ $lefttime = $top_second; }					# �`���[�W���Ԃɏ����K�p

	# ���݂����Ȃ��ꍇ�̓`���[�W���Ԃ𒷂����� (�g�т���̓��e�͏��O)
	if($device_type eq "mobile" || $k_access || $main::device{'type'} eq "Portable-game-player"){	}
	else{
			if($main::cgold <= -150){ $lefttime += 3.0*60; }
			elsif($main::cgold <= -100){ $lefttime += 2.0*60; }
			elsif($main::cgold <= -50){ $lefttime += 1.0*60; }
			elsif($main::cgold <= -25){ $lefttime += 0.5*60; }
	}

# ���^�[��
return($lefttime);

}


#-----------------------------------------------------------
# ����̃`���[�W���ԃt�@�C�����쐬 - strict
#-----------------------------------------------------------
sub renew_nextcharge_res{

# �錾
my($type,$nextcharge_time) = @_;
my $bbs_wait = new Mebius::BBS::Wait;
my($share_directory) = Mebius::share_directory_path();
my($my_cookie) = Mebius::my_cookie_main();
my(@line,%insert);
our($xip);

$insert{'target'} = $bbs_wait->new_target();
$insert{'cnumber'} = $my_cookie->{'char'};
$insert{'xip'} = $xip;
$insert{'submit_time'} = time;
$insert{'wait_second'} = $nextcharge_time;

$bbs_wait->delete_record_from_main_table({ cnumber => $my_cookie->{'char'} });
$bbs_wait->delete_record_from_main_table({ xip => $xip });
$bbs_wait->insert_main_table(\%insert);

}



#-----------------------------------------------------------
# �������ɉ����ċ��݂̖������v�Z - strict
#-----------------------------------------------------------
sub getgold_from_comment{

# �錾
my($type,$comment,$thread_concept) = @_;
my($getgold,@gold,$bonusday_flag);
our($norank_wait,$concept);

# ���ݑΕ������̐ݒ�
@gold = (
"500=6",
"400=4",
"300=3",
"200=2",
"100=1",
"35=0",
"0=-1"
);

# �R�����g�������̌v�Z
my($long_length,$short_length) = &get_length("",$comment);

	# ���݂̑���
	foreach(@gold){
		my($length,$gold) = split(/=/);
			if($short_length >= $length){ $getgold = $gold; last; }
	}

	# �L���̐ݒ�ɂ���Ă͋��݂𑝂₳�Ȃ�
	if($thread_concept =~ /Not-gold/){ $getgold = 0; }

	# �f���̐ݒ�ɂ���Ă͋��݂𑝂₳�Ȃ��A�������͔���������
	if($concept =~ /Not-gold/){ $getgold = 0; }
	if($concept =~ /Get-gold-over-([0-9\.]+)/ && $getgold >= 1){ $getgold = int($getgold*$1); }

	# �R�����g���e�ɂ���Ă͋��݂𑝂₳�Ȃ�
	if($getgold >= 1 && $comment =~ /(�o���l��)/){ $getgold = 0; }

	# ���[�h�ɂ���ċ��݂����炳�Ȃ�
	if($getgold < 0 && $norank_wait){ $getgold = 0; }

	# ���݃{�[�i�XDAY
	if($main::wday eq "��" && $getgold >= 1){ $getgold *= 2; $bonusday_flag = 1; }

return($getgold,$bonusday_flag);

}

1;


use strict;
use Mebius::Access;
use Mebius::Text;
package main;

#-------------------------------------------------
# ���e����
#-------------------------------------------------
sub do_axscheck{

# �Ǐ���
my($basic_init) = Mebius::basic_init();
my($my_cookie) = Mebius::my_cookie_main();
my($my_real_device) = Mebius::my_real_device();
my($my_access) = Mebius::my_access();

my($type) = @_;
my($message_nohost,$leftday,$leftday_view);
my($deny_flag,$block,$reason,$blocktime,$delcount,$alldelcount,$type_guide,$block_type);
my($alert_domain_flag,$alert_domain_flag_decide);
my($env_deny_flag,$i_forwarded,$forwarded_split1,$forwarded_split2,%penalty,$second_domain);
our($pmfile,$device_type,$agent,$addr,$server_domain,$strong_emd,$cgold);
our($agent,$e_access,$cookie,$guide_url,$cnumber);
our($k_access,$kaccess_one,$concept,$int_dir,$time,$postflag,$alocal_mode);

# �d���N�b�L�[�Z�b�g�����
$main::no_headerset = 1;

# �A�N�Z�X�����擾
my($access) = Mebius::my_access();

	# GET���M���֎~
	if($type =~ /Post(-)?only/ && $ENV{'REQUEST_METHOD'} ne "POST"){
		Mebius::AccessLog(undef,"Request-method-is-strange","\$ENV{'REQUEST_METHOD'} : $ENV{'REQUEST_METHOD'}");
		main::error("���M���@���ςł��B");
	}

	# �v���N�V���֎~
	#my($error_flag_proxy) = Mebius::ProxyJudge();

	# �{�b�g�͌����֎~
	if($type !~ /Allow-bot/){
		my($bot_flag) = Mebius::Device::bot_judge();
			if($bot_flag){
				Mebius::AccessLog(undef,"Bot-axscheck-deny");
				main::error("Bot����͂��̑���͂ł��܂���B");
			}
	}

	# ���ȃA�N�Z�X�͋L�^
	#if(!$ENV{'HTTP_REFERER'}){ Mebius::AccessLog(undef,"No-referer-post"); }
	#if(!$ENV{'HTTP_COOKIE'}){ Mebius::AccessLog(undef,"No-cookie-post"); }
	if(!$ENV{'HTTP_COOKIE'} && !$my_access->{'mobile_flag'}){
	#if(!$my_cookie->{'char'} && !$my_access->{'mobile_flag'}){
		Mebius::AccessLog(undef,"No-cookie-post-without-mobile"); 
		main::error("�������ނɂ�Cookie���I���ɂ��Ă��������B");
	}


	if($ENV{'HTTP_REFERER'} && $ENV{'HTTP_REFERER'} !~ m!^https?://([a-z0-9\.]+\.)?mb2.jp/! && !$main::alocal_mode){
		Mebius::AccessLog(undef,"Strange-referer-regist","Referer: $ENV{'HTTP_REFERER'}");
	}
	
	# ���O�C���`�F�b�N������ꍇ
	if($type =~ /Login-check/){
			if(!$main::myaccount{'file'}){ $e_access .= qq(�����̑��������ɂ́A�A�J�E���g��<a href="${main::auth_url}">���O�C��</a>���Ă���ēx���������������B<br$main::xclose>); }
	}

# �z�X�g�����擾���� ( IP ����t���� )
my($gethost_multi) = Mebius::GetHostWithFileMulti();
our $host = $gethost_multi->{'host'};
my($alert_domain_flag) = Mebius::HostCheck(undef,$gethost_multi->{'host'},$addr,$gethost_multi->{'isp'},$gethost_multi->{'second_domain'});
	if($alert_domain_flag){ $alert_domain_flag_decide = 1; }

	# ���v���N�V��IP�A�h���X��W�J
	foreach $forwarded_split1 (split(/,/,$ENV{'HTTP_X_FORWARDED_FOR'},-1)){

		# �Ǐ���
		my($plustype_hostcheck_forwarded);

		# ���E���h�J�E���^
		$i_forwarded++;


			if($addr eq $forwarded_split1){
				$env_deny_flag = 1;
				Mebius::AccessLog(undef,"Deny-axscheck","\$ENV{'HTTP_X_FORWARDED_FOR'} IP�d�� : $main::addr / $ENV{'HTTP_X_FORWARDED_FOR'}");
				Mebius::AccessLog(undef,"Deny-forwarded","\$ENV{'HTTP_X_FORWARDED_FOR'} IP�d�� : $main::addr / $ENV{'HTTP_X_FORWARDED_FOR'}");
			}

			# �����[����������ꍇ�̓G���[��
			if($i_forwarded >= 3){
				$env_deny_flag = 1;
				Mebius::AccessLog(undef,"Deny-axscheck","\$ENV{'HTTP_X_FORWARDED_FOR'} �����[������ : $ENV{'HTTP_X_FORWARDED_FOR'}");
				Mebius::AccessLog(undef,"Deny-forwarded","\$ENV{'HTTP_X_FORWARDED_FOR'} �����[������ : $ENV{'HTTP_X_FORWARDED_FOR'}");
				last;	# �����������Ȃ��悤�ɏI�������Ă���
			}

		# IP����z�X�g�����擾
		my($gethost_forwarded) = Mebius::GetHostMulti({ Addr => $forwarded_split1 , TypeWithFile => 1 });

		# �z�X�g�`�F�b�N�̃^�C�v���` ( �{�z�X�g�� jp �h���C���̏ꍇ�́A�󔒃`�F�b�N�����Ȃ� )
		if(!$alert_domain_flag){ $plustype_hostcheck_forwarded .= qq( Not-empty-check); }
		# �z�X�g�`�F�b�N
		my($alert_domain_flag_forwarded) = Mebius::HostCheck("$plustype_hostcheck_forwarded",$gethost_forwarded->{'host'},$forwarded_split1,$gethost_forwarded->{'isp'},$gethost_forwarded->{'second_domain'});

			if($alert_domain_flag){ $alert_domain_flag_decide = 1; }

			# ���e����/�A�J�E���g�֎~��Ԃ��`�F�b�N(�v���N�V�̃z�X�g)
			(%penalty) = Mebius::penalty_file("Axscheck Host Renew Relay-hash",$gethost_forwarded->{'host'},$type,%penalty);

	}

	# �v���N�V�ϐ����L�^
	#if($main::env{'num'} >= 1 && !$main::bot_access){ Mebius::AccessLog(undef,"Proxy-about"); }

	# ���������h���C���ł͂Ȃ��ACookie�Ȃ��̏ꍇ�́A�X�p���Ƃ��ē��e���֎~ ( �z�X�g������ )
	if(!$cookie && !$k_access && $alert_domain_flag_decide){
		$env_deny_flag = 1;
			Mebius::AccessLog(undef,"Deny-axscheck","�N�b�L�[�Ȃ�&�h���C�������F $gethost_multi->{'host'}");
			Mebius::AccessLog(undef,"Deny-not-cookie","�N�b�L�[�Ȃ�&�h���C�������F $gethost_multi->{'host'}");
	}

	if(!$my_cookie->{'char'} && $host =~ /\.(panda-world\.ne\.jp)$/){
		$env_deny_flag = 1;
	}

	# DOCOMO�Ōő̎��ʔԍ����Ȃ��ꍇ
	if($k_access eq "DOCOMO" && ($device_type eq "mobile" || !$agent) && $postflag && !$kaccess_one){
		$e_access .= "���r�炵�h�~�̂���<a href=\"$guide_url%B8%C7%C2%CE%BC%B1%CA%CC%C8%D6%B9%E6\">�ő̎��ʔԍ�</a>�𑗐M���Ă��������B�i$basic_init->{'mailform_link'}�j<br>";
		Mebius::AccessLog(undef,"Docomo-utn-error");
	}

	# �ς�UA/�v���N�V��UA�𐧌�
	if($ENV{'HTTP_USER_AGENT'} eq "" || length($agent) > 500 || $ENV{'HTTP_USER_AGENT'} =~ /(Gateway|Proxy|\(http)/i){
		$env_deny_flag = 1;
		Mebius::AccessLog(undef,"Deny-axscheck","���[�U�[�G�[�W�F���g�����F $ENV{'HTTP_USER_AGENT'}"); 
		Mebius::AccessLog(undef,"Deny-user-agent","���[�U�[�G�[�W�F���g�����F $ENV{'HTTP_USER_AGENT'}"); 
	}

	# �ς�UA���`�F�b�N
	if($ENV{'HTTP_USER_AGENT'} !~ /(^Mozilla|^Opera|^KDDI|^DoCoMo|^SoftBank|^Vodafone|^J-PHONE|^Nokia|^SAMSUNG)/){
		Mebius::AccessLog(undef,"Strange-user-agent","�ςȃ��[�U�[�G�[�W�F���g�F $ENV{'HTTP_USER_AGENT'}"); 
	}

	# �T�C�g�O������̃��t�@�����֎~����
	if($ENV{'HTTP_REFERER'}){
		my($hit_flag);
			foreach(@{$basic_init->{'all_domains'}}){
				if($ENV{'HTTP_REFERER'} =~ m!http://$_/!){ $hit_flag = 1; }
			}
			if(!$hit_flag){
				# $env_deny_flag = 1;
				#Mebius::AccessLog(undef,"Deny-axscheck","���t�@�������F $ENV{'HTTP_REFERER'}"); 
				#Mebius::AccessLog(undef,"Deny-referer","���t�@�������F $ENV{'HTTP_REFERER'}"); 
			}
	}

	# �ڑ����ɐ���������ꍇ�A�����ŃG���[��ǉ��i�G���[�����d���\�����Ȃ��悤�Ɂj
	if($env_deny_flag){ $e_access = qq(�����̊�����͑��M�ł��܂���B�i $basic_init->{'mailform_link'} �j<br>); }

	# �A�J�E���g�L�[�Ń��b�N
	if($main::myaccount{'key'} eq "2" && $type =~ /ACCOUNT/ && $type !~ /NOLOCK/){
		&error("���Ȃ��̃A�J�E���g�̓��b�N���ł��B");
		Mebius::AccessLog(undef,"Accout-lock-axscheck","$main::myaccount{'file'}");
	}


# ���e�����t�@�C�����瓊�e����
my($history_access) = Mebius::History::AccessCheck();
	if($history_access->{'error_flag'}){ main::error("$history_access->{'error_flag'}"); }


	# ���e����/�y�i���e�B��Ԃ��`�F�b�N
	my(%penalty) = Mebius::penalty_file("Axscheck Check-penalty Cnumber Relay-hash",$main::cnumber,$type,%penalty);
	my(%penalty) = Mebius::penalty_file("Axscheck Check-penalty Agent Relay-hash",$agent,$type,%penalty);
	my(%penalty) = Mebius::penalty_file("Axscheck Check-penalty Account Relay-hash",$pmfile,$type,%penalty);
	my(%penalty) = Mebius::penalty_file("Axscheck Check-penalty Isp Relay-hash",$gethost_multi->{'isp'},$type,%penalty);
	my(%penalty) = Mebius::penalty_file("Axscheck Check-penalty Addr Relay-hash",$addr,$type,%penalty);
	my(%penalty) = Mebius::penalty_file("Axscheck Check-penalty Host Relay-hash",$gethost_multi->{'host'},$type,%penalty);

	# �����̃y�i���e�B�f�[�^ ( �z�X�g���f�[�^ )���A�O���[�o���ϐ��ɑ��
	%main::mypenalty = %penalty;

	# ���O���T�C�g����̃��[�U�[����
	if($main::mypenalty{'Hash->from_other_site_time'}){
		my(%other_site) = Mebius::FromOtherSite("Get-hash");
			if($other_site{'error_flag'}){ main::error($other_site{'error_flag'}); }
		#if($main::alocal_mode){ main::error("$penalty{'Hash->from_other_site_url'}"); }
	}

	# �����e��������Ă��炸�A�폜�y�i���e�B�����݂���ꍇ
	if(time < 1373525416 + 24*60*60 && $ENV{'HTTP_HOST'} =~ /sns|aurasoul/){
		0;
	} elsif(!$penalty{'Block->block_flag'} && $penalty{'Penalty->penalty_flag'} && $main::bbs{'concept'} !~ /NOT-PENALTY/){

		my(%set_cookie);
		my($my_cookie) = Mebius::my_cookie_main_logined();

			# �V�����y�i���e�B�̏ꍇ�A���ݖ��������炷
			if(($penalty{'Penalty->new_penalty_flag'} || $main::alocal_mode) && $main::cgold ne ""){
					# ���݂����Ƃ��ƃv���X�̏ꍇ
					if($my_cookie->{'gold'} >= 1){
						$set_cookie{'-'}{'gold'} = $penalty{'Penalty->count'}*10;
						$set_cookie{'>='}{'gold'} = -10;
					}
					# ���݂����Ƃ��ƃ}�C�i�X���[���̏ꍇ
					else{ $set_cookie{'-'}{'gold'} = $penalty{'Penalty->count'}*5; }
			}

				# �N�b�L�[���Z�b�g
				if($penalty{'Penalty->set_cdelres_time'} > $my_cookie->{'deleted_time'}){
					$set_cookie{'deleted_time'} = $penalty{'Penalty->set_cdelres_time'};
				}
			Mebius::Cookie::set_main(\%set_cookie,{ SaveToFile => 1 });

			# �y�i���e�B��ʂ�\������
			Mebius::TellPenaltyView(undef,\%penalty);

	}

	# ���e��������������ꍇ
	if($penalty{'Block->exclusion_block_flag'}){
		0;
	}

	# �����e�������̏ꍇ
	elsif($penalty{'Block->block_flag'}){
		$e_access .= qq($penalty{'Block->block_message'});
		$main::strong_emd++;
			if($penalty{'Block->block_reason'} eq "98"){ Mebius::AccessLog(undef,"Open-proxy-auto-block","���J�v���N�V�F $addr / $host "); }
	}

	# �A�J�E���g�쐬����
	if($type =~ /Make-account/){
			if($access->{'low_level_flag'}){ main::error("���̊��ł̓A�J�E���g���쐬�ł��܂���B"); }
			if($penalty{'Block->block_make_account_flag'}){ main::error("���݁A�A�J�E���g���쐬�ł��܂���B"); }
	}

	# �����ɃG���[�\���Ɉړ�����ꍇ
	if($e_access){ Mebius::AccessLog(undef,"Deny-axscheck"); }
	if($type !~ /LAG/ && $e_access){ main::error("$e_access"); }

# ���^�[��
return($host,$deny_flag);

}

package Mebius::History;

#-----------------------------------------------------------
# ���e�����t�@�C�����g���āA���e�����`�F�b�N # SSS => ����m�F�H
#-----------------------------------------------------------
sub AccessCheck{

# �錾
my($use) = @_;
my(%data);

# ���W���[���ǂݍ���
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}part_history.pl";

# �����A�N�Z�X���
my($access) = Mebius::my_access();

# �z�X�g���
my($multi_host) = Mebius::GetHostWithFileMulti();

	# CCC �s��m�F
	if($multi_host->{'addr_to_host_flag'}){ Mebius::AccessLog(undef,"Addr-to-host","$multi_host->{'host'}"); }

# ���e���� ( �z�X�g / �}���` )
my(%history_host) = main::get_reshistory("TOPDATA My-file HOST",$multi_host->{'host'});
my($history_multi) = Mebius::my_history_include_host();

	# �P���Ԃ�����̓��e����������������ꍇ (�L�^)
	if($history_host{'all_length_per'} >= 2*10000 || $history_multi->{'all_length_per'} >= 2*10000){
		$data{'error_flag'} .= qq(��[ 1���� ] �� [ 10000���� ] ��葽���͏������߂܂���B���΂炭���҂����������B<br>);
		#Mebius::Echeck::Record(undef,"All-Error");
		#Mebius::Echeck::Record(undef,"Per-length-error");
		Mebius::AccessLog(undef,"Per-length-error","$history_host{'all_length_per'}����");
	}

	# �P���Ԃ�����̓��e����������������ꍇ (�G���[)
	elsif($history_host{'all_length_per'} >= 2*5000 || $history_multi->{'all_length_per'} >= 2*5000){
		#$data{'error_flag'} .= qq(��[ 1���� ] �� [ 10000���� ] ��葽���͏������߂܂���B���΂炭���҂����������B<br$main::xclose>);
		#Mebius::Echeck::Record(undef,"All-Error");
		#Mebius::Echeck::Record(undef,"Per-length-error");
		Mebius::AccessLog(undef,"Per-length-check","$history_host{'all_length_per'}����");
	}

	# ����̃A�N�Z�X���ŁA1���Ԃ�����̓��e���𐧌����� ( �z�X�g���̓��e�����t�@�C���ł������� )
	my $max_regist_per = 20;
	if($access->{'low_level_flag'}){
			if($history_host{'regist_count_per'} >= $max_regist_per || $history_multi->{'regist_count_per'} >= $max_regist_per){
				Mebius::AccessLog(undef,"Low-level-max-regist-per-hour","����^�C�v�F $access->{'low_level_error_type_message'}");
				$data{'error_flag'} .= qq(�����̊��ł́A�������߂�񐔂ɐ���������܂��B���΂炭�o���Ă���܂����������������B<br>);
			}
	}

return(\%data);

}

package main;

#-----------------------------------------------------------
# �g���b�v�@�\
#-----------------------------------------------------------
sub get_trip{

# �錾
my($name) = @_;
my($trip_key) = ('x6');
my($max_sharp);
my $text = new Mebius::Text;
our($e_com,$enctrip,$i_name,$i_handle,$i_trip,$trip_concept);

# �l�̃`�F�b�N/�ϊ�
$name =~ s/��/�H/g;
$name =~ s/��/�H/g;
$name =~ s/&amp;([#a-zA-Z0-9]+);/��/g;

	if($text->match_shift_jis($name,"��")){
		$e_com .= qq(�����O�ɑS�p�̃n�b�V�� \(��\) �͎g���܂���B<br>); 
	}
#$name = $text->replace_shift_jis_text($name,"��","#");

	# �n���h���ƃg���b�v�A����L�[�𕪗�
	my($handle,$trip,$tripconcept_text) = split(/#/,$name);

	# ������L�[�ɂ�铮����`
	if($tripconcept_text =~ /IdChange/){
		$trip_concept .= qq( Id-change);
	}
	if($tripconcept_text =~ /(����|��ꂫ)�I�t|history-off/i){
		$trip_concept .= qq( Not-history);
	}
	if(length($tripconcept_text) > 20) {
		$e_com .= qq(���M���̓���L�[ ( $tripconcept_text ) ���������܂��B���p 20�����ȓ��Ŏw�肵�Ă��������B<br$main::xclose>);
	}

	# ���p�V���[�v�̌�
	if($trip_concept){ $max_sharp = 2; } else{ $max_sharp = 2; }
	if(($name =~ s/#/$&/g) > $max_sharp){
		$e_com .= qq(���M���̒��� # ( ���p�V���[�v/�C�Q�^ ) ���������܂��B# �̓g���b�v�f�̕�����Ƃ��Ă͔F������܂���B <br$main::xclose>);
	}

	# ���g���b�v����̏ꍇ
	if($trip ne ""){

		# �O���[�o���ϐ�����
		$i_handle = $handle;
		$i_trip = $trip;

		# �g���b�v�̑f�`�F�b�N
		my $trip_length = length($i_trip);
		if($i_handle eq $i_trip){
			$e_com .= qq(���M�� ( $i_handle ) �ƁA�g���b�v�̑f ( #$trip ) ��S���������̂ɂ͏o���܂���B�g���b�v�̑f�ɂ́A��������ɂ�����������g���Ă��������B<br>);
		}
		if($trip_length > 20) { $e_com .= qq(���g���b�v�̑f ( #$trip ) ���������܂��B���p 20�����ȓ��ɂ��Ă��������B<br>); }
		if($trip_length < 2) { $e_com .= qq(���g���b�v�̑f ( #$trip ) ���Z�����܂��B���p 2�����ȏ�ɂ��Ă��������B<br>); }

			# MD5�Í���
			if($trip_length > 8) {
				($enctrip) = Mebius::Crypt::crypt_text("MD5","$i_trip",$trip_key,12);
			}

			# CRYPT �Í���
			else{
				($enctrip) = crypt($i_trip, $trip_key) || crypt ($i_trip, '$1$' . $trip_key);
				$enctrip =~ s/^..//;
			}

		$main::handle_and_enctrip = "$i_handle��$enctrip";
		if($i_trip eq "MebiHost"){ $enctrip = ""; }

	}

	# ���g���b�v�Ȃ��̏ꍇ
	else {
		$i_handle = $name;
		$main::handle_and_enctrip = "$i_handle";
	}

# ���̓��͂��Ē�`
$i_name = undef;
$i_name .= $i_handle;
if($trip){ $i_name .= qq(#$trip); }
if($tripconcept_text){ $i_name .= qq(#$tripconcept_text); }

return($enctrip,$i_handle,$i_name,$i_trip,$trip_concept);

}


1;

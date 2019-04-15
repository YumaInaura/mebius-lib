
use strict;
package main;

#-----------------------------------------------------------
# Cookie���Z�b�g / �Z�[�u�f�[�^���L�^
#-----------------------------------------------------------
sub do_set_cookie_old{

# �錾
my($type,$cookie_name,@set_cookie) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # �����^�C�v��W�J
my(@savecook,@savemobile,$set_cnumber);
my($i,$gmt,$cook,$setdomain,$onset_flag,@saveaccount,$cookie_body,$set_cfirst_set_time);
our(%done,$pmfile,$int_dir,$idcheck,$kaccess_one,$alocal_mode,$recgold,$recsoumoji,$recsoutoukou,$recfollow,$k_access);
our($cnam,$cposted,$cpwd,$ccolor,$cup,$ccount,$cnew_time,$cres_time,$cgold,$csoumoji,$csoutoukou,$cfontsize,$cfollow,$cview,$cnumber,$crireki,$ccut,$cmemo_time,$caccount,$cpass,$cdelres,$cnews,$cage,$cemail,$csecret,$cres_waitsecond,$caccount_link,$cimage_link,$cfillter_id,$cfillter_account,$chistory_open,$cdevice_type,$cfirst_set_time);

	# �N�b�L�[�����`
	if($cookie_name eq "") { $cookie_name = "love_me_aura"; }

	# �Ǘ��ԍ����Z�b�g����
	if($cnumber){ $set_cnumber = $cnumber; }
	else{ ($set_cnumber) = Mebius::Char(undef,20); }

	# �u���߂�Cookie���Z�b�g�������ԁv���Z�b�g����
	if($cfirst_set_time){
		$set_cfirst_set_time = $cfirst_set_time;
	}
	else{
		$set_cfirst_set_time = time;
	}

	# ��d�Z�b�g����� 
	if($done{"cookie=>$cookie_name"}){
		$done{"cookie=>$cookie_name"}++;
		Mebius::AccessLog(undef,"SET-2COOKIES",qq(�Z�b�g�� \$done{"cookie=>$cookie_name"} == $done{"cookie=>$cookie_name"}));
	}
	else{ $done{"cookie=>$cookie_name"}++; }

	# �����C���T�C�g�̋��ʏ����i�V���v���Z�b�g�̏ꍇ�͏������Ȃ��j
	if($type !~ /Simple/){

			# �Z�b�g������
			if($ccount >= 1 || !$kaccess_one){ $ccount++; }

			# �n���l���Ȃ��ꍇ�A�O���[�o���ϐ����g���� Cookie ���Z�b�g���� 
			if($#set_cookie <= 0){
				@set_cookie = ($cnam,$cposted,$cpwd,$ccolor,$cup,$ccount,$cnew_time,$cres_time,$cgold,$csoumoji,$csoutoukou,$cfontsize,$cfollow,$cview,$set_cnumber,$crireki,$ccut,$cmemo_time,$caccount,$cpass,$cdelres,$cnews,$cage,$cemail,$csecret,$cres_waitsecond,$caccount_link,$cimage_link,$cfillter_id,$cfillter_account,$chistory_open,$cdevice_type,$set_cfirst_set_time);
			}

			# �Z�b�g���e�̗L���𔻒�
			foreach(@set_cookie){
				if($_ ne ""){ $onset_flag = 1; }
			}

			# ��Cookie�̃Z�[�u�@�\
			if($idcheck || $kaccess_one){
				require "${int_dir}part_idcheck.pl";
				@saveaccount = @savemobile = @set_cookie;
				@set_cookie = ($cnam,$cposted,$cpwd,$ccolor,$cup,$ccount,$cnew_time,$cres_time,$recgold,$recsoumoji,$recsoutoukou,$cfontsize,$recfollow,$cview,$set_cnumber,$crireki,$ccut,$cmemo_time,$caccount,$cpass,$cdelres,$cnews,$cage,$cemail,$csecret,$cres_waitsecond,$caccount_link,$cimage_link,$cfillter_id,$cfillter_account,$chistory_open,$cdevice_type,$set_cfirst_set_time);
					if($idcheck){
						@savemobile = ($cnam,$cposted,$cpwd,$ccolor,$cup,$ccount,$cnew_time,$cres_time,"","","",$cfontsize,$cfollow,$cview,$set_cnumber,$crireki,$ccut,$cmemo_time,$caccount,$cpass,$cdelres,$cnews,$cage,$cemail,$csecret);
					}
					if($kaccess_one && $onset_flag){ &push_savedata($kaccess_one,"MOBILE",$k_access,@savemobile); }
					if($idcheck){ &push_savedata($pmfile,"ACCOUNT","",@saveaccount); }
			}

	}

	# �L�^�p�f�[�^���G���R�[�h
	foreach(@set_cookie){
		$i++;
		s/(\W)/sprintf("%%%02X", unpack("C", $1))/eg;
		$cook .= "$_<>";
	}

# ��d�N�b�L�[�̔���
#my $dobcookienum = ($cookie =~ s/love_me_aura/$&/g);

	# ������`
	if($type !~ /Onetime/){
		my @time = gmtime(time + 180*24*60*60);
		my @month = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
		my @week = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
		$gmt = sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT", $week[$time[6]], $time[3], $month[$time[4]], $time[5]+1900, $time[2], $time[1], $time[0]);
	}

	# �N�b�L�[�̓��e���ŏI��`
	if($k_access eq "AU" || $k_access eq "SOFTBANK"){
		$cookie_body = "$cookie_name=$cook; expires=$gmt; path=/;";
	}
	elsif(Mebius::AlocalJudge()){
		$cookie_body = "$cookie_name=$cook; expires=$gmt; path=/;";
	}
	else{
		$cookie_body = "$cookie_name=$cook; domain=mb2.jp; expires=$gmt; path=/;";
	}

	# �Z�b�g�����ɓ��e�����Ԃ��ꍇ
	if($type =~ /Get-only/){
		return($cookie_body);
	}
	# ���ۂɃN�b�L�[���Z�b�g
	else{
		print qq(Set-Cookie: $cookie_body\n);
	}

	#if(Mebius::AlocalJudge()){ Mebius::Debug::Error(qq($cookie_body)); }

	# ��d�N�b�L�[�̍폜
	#if($dobcookienum >= 2){
	#print "Set-Cookie: ${cookie_setname}=$cook; max-age=0; expires=Fri, 5-Oct-1979 08:10:00 GMT; path=/;\n";
	#}


}



1;


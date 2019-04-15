
use strict;
use Mebius::BBS;
use Mebius::Getpage;
use Mebius::Getstatus;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# �����J�n - strict
#-----------------------------------------------------------
sub open_kr{

# �錾
my($type,$moto,$kr_number,$sub) = @_;
my(undef,$account) = @_ if($type =~ /Account/);
my($set_no,$set_moto,$set_sub,$set_domain,$domain);
our(%in,$moto,$bot_access,$concept,$myadmin_flag,$alocal_mode,$crireki,$server_domain,$cview,$no_headerset);
our($secret_mode,$int_dir,$realmoto);

	# �e�탊�^�[��
	if($concept =~ /NOT-KR/){ return; }
	if($secret_mode){ return; }
	if($myadmin_flag && !$alocal_mode && $main::bbs{'concept'} !~ /Local-mode/){ return; }
	if($bot_access){ return; }

	# ���{����������o�^����ꍇ
	if($type =~ /VIEW/ && $ENV{'REQUEST_METHOD'} eq "GET"){

		# �Ǐ���
		my($cview_buf,$domain);

		# �V�����{��������Cookie ���Z�b�g ( $cview ���Ȃ��Ă� Cookie �̓Z�b�g�A�������o�^�����Ƀ��^�[�� )�i�f���p�j
		($cview,$cview_buf) = ("$kr_number<A>$moto<A>$sub<A>$server_domain",$cview);

		Mebius::Cookie::set_main({ last_view_thread => $cview });

			# $cview �����������ꍇ�ACookie�Z�b�g��Ƀ��^�[��
			if(!$cview_buf){ return; }

		# ���݂�Cookie ( $cview_buf ) �𕪉�
		($set_no,$set_moto,$set_sub,$set_domain) = split (/&lt;A&gt;/,$cview_buf);
		
	}

	# �����e��������o�^����ꍇ
	elsif($type =~ /REGIST/){
		require "${int_dir}part_history.pl";
		($set_no,$set_moto,$set_sub,$set_domain) = &get_reshistory("KRCHAIN My-file",undef,undef,"<>$kr_number<><>$realmoto<><>$server_domain<>");
	}

# �֘A�L���̓o�^������
related_thread("Renew BBS",$moto,$kr_number,$set_domain,$set_moto,$set_no,$set_sub);

}

#-----------------------------------------------------------
# �֘A�L���t�@�C���쐬
#-----------------------------------------------------------
sub related_thread{

# �錾
# $kr_number �� �֘A�L���t�@�C�� / $set_domain - $set_moto - $set_no �� �֘A�L�����ɓo�^����L��
my($type,$kr_moto,$kr_number,$set_domain,$set_moto,$set_no,$set_sub) = @_;
my(undef,$account) = @_ if($type =~ /Account/);
my(undef,undef,undef,$maxview) = @_ if($type =~ /(Index|Oneline)/);
my(@renewline,%th,$i,$redun_flag,$kr_handler,$allowdomain_flag,$krfile,$one_line,$sflag,$index_line,$renew_flag,$rand_delete,$krurl,$maxline_renew);
my($flow_flag,$krdirectory);
our($int_dir,$logpms,$server_domain,@domains,$script,%in,$auth_url,$xclose);

	# �����_���폜�̊m�������߂�i�Ȍ�̃��[�v���ł̒�`�͂��Ȃ��B�S�̂ňꗥ�̊m���Ƃ���j
	if($type =~ /Renew/){ $rand_delete = rand(15); }

	# �t�@�C����`�i�A�J�E���g�ւ̓o�^�p�j
	if($type =~ /Account/){
		$account =~ s/[^0-9a-zA-Z]//g;
			if($account eq ""){ return(); }
		my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;
		$krdirectory = "${auth_log_directory}_kr_auth/";
		$krfile = "${krdirectory}${account}_kr.log";
		#$krfile = "${account_directory}${account}_kr.log";
		$krurl = "$auth_url$account/";
	}

	# �t�@�C����`�i�f���ւ̓o�^�p�j
	else{
		$kr_moto =~ s/\W//g;
		$kr_number =~ s/\D//g;
			if($kr_moto eq ""){ return(); }
			if($kr_number eq ""){ return(); }
		$krdirectory = "$main::bbs{'data_directory'}_kr_$kr_moto/";
		$krfile = "${krdirectory}${kr_number}_kr.cgi";
		$krurl = "http://$server_domain/_$kr_moto/$kr_number.html";
	}


	# �ő�\���s������
	if($type =~ /Oneline/){
		if(!$maxview){ $maxview = 5; }
	}

	# �ő�\���s������
	if($type =~ /Index/){
		if(!$maxview){ $maxview = 100; }
	}


	# ���t�@�C���X�V����ꍇ
	if($type =~ /Renew/){

			# ���K�h���C�����ǂ������`�F�b�N
			foreach(@domains){
				if($set_domain eq $_){ $allowdomain_flag = 1; }
			}
			if(!$allowdomain_flag){ return(); }

		# ���ꂩ��o�^����L���̊e��l���`�F�b�N
		$set_moto =~ s/\W//g;
		$set_no =~ s/\D//g;
		if($set_moto =~ /^(sc|sub)/){ return(); }
		if($set_moto =~ /^(cha|ckj|csh|ccu|cnr)$/){ return(); }
		if($set_moto eq "delete"){ return(); }
		if($set_moto eq ""){ return(); }
		if($set_no eq ""){ return; }

		# �����i�̋L���j�Ɏ����i�̋L���j��o�^���悤�Ƃ��Ă���ꍇ�̓��^�[��(�f���p�ł͂��蓾�Ȃ�)
		if($type =~ /BBS/ && $set_moto eq $kr_moto && $set_no == $kr_number){ return; }

			# �T�[�o�[�������ꍇ�A���O�t�@�C�����猳�t�@�C���̃����N�؂�`�F�b�N
			if($server_domain eq $set_domain){

				(%th) = Mebius::BBS::thread({},$set_moto,$set_no);
					if($th{'keylevel'} < 1){ return(); }
			}

			# �T�[�o�[���Ⴄ�ꍇ�A�X�e�[�^�X�R�[�h���烊���N�؂���`�F�b�N
			else{
				my($status) = Mebius::Getstatus("","http://$set_domain/_$set_moto/$set_no.html");
				if($status ne "200"){ return(); }
			}

	}

	# ���֘A�L���t�@�C�����J��
	open($kr_handler,"<$krfile");

		# �t�@�C�����b�N
		if($type =~ /Renew/){ flock($kr_handler,1); }

		# �t�@�C����W�J����
		while(<$kr_handler>){

			# ���[�v�J�E���^
			$i++;

			# ���̍s�𕪉�
			chomp;
			my($no2,$moto2,$sub2,$domain2,$num2,$lasttime2) = split (/<>/);

				# �h���C���w��ԍ�������h���C���𕜌��i���L�^�ւ̑Ή��j
				if($domain2 eq "2"){ $domain2 = "mb2.jp"; }
				elsif($domain2 eq "1"){ $domain2 = "aurasoul.mb2.jp"; }

				# �閧�A�f�[�^���Ȃǂ��G�X�P�[�v 
				if($moto2 =~ /(^sc)/){ main::access_log("Secret-kr","�t�@�C���F $krurl"); next; }
				if($moto2 eq "delete"){ next; }
				if($moto2 =~ /^(cha|ckj|csh|ccu|cnr)$/){ next; } # �B���J�e�S�����G�X�P�[�v
				if($no2 !~ /^([0-9]+)$/ || $sub2 eq ""){ main::access_log("Broken-kr","�t�@�C���F $krurl / �L���� $no2 / �薼 $sub2"); next; }

				# ���P�s�\���擾�p
				if($type =~ /Oneline/ && !Mebius::Fillter::basic(utf8_return($sub2))){

						# �|�C���g���}�C�i�X�Ŕ�\���̍s
						if($num2 < 0 && $type !~ /Editor/){ next; }

						# �ő�s���ɒB�����ꍇ
						if($i > $maxview){ $flow_flag =1; last; }

					# �P�s�\���s��ǉ�
					$one_line .= qq(<a href="http://$domain2/_$moto2/$no2.html">$sub2</a>�@);

				}

				# ���C���f�b�N�X�擾�p
				elsif($type =~ /Index/ && !Mebius::Fillter::basic(utf8_return($sub2))){

						# �|�C���g���}�C�i�X�Ŕ�\���̍s
						if($num2 < 0 && $type !~ /Editor/){ next; }

						# �ő�s���ɒB�����ꍇ
						if($i > $maxview){ $flow_flag = 1; last; }

						# ���`
						$index_line .= qq(<li>);

						# �ҏW�p�̃����N
						if($type =~ /Editor/){
							$index_line .= qq( <input type="text" name="${domain2}-${moto2}-${no2}" value="$num2" size="1"$xclose>);
						}


					# �֘A�L�������N�{��
					$index_line .= qq( <a href="http://$domain2/_$moto2/$no2.html">$sub2</a> ($num2));

					# ���`
					$index_line .= qq(</li>);

				}

				# ���t�@�C���ҏW�p
				elsif($type =~ /Edit-data/){

						# �啶������������
						use Mebius::Text;

						# �ҏW����W�J
						foreach(keys %main::in){
							my $key = $_;
							my $value = $main::in{$_};
								if($key eq "$domain2-$moto2-$no2"){
										($value) = Mebius::Number("",$value);
										if($num2 ne $value && $value =~ /^(-)?([0-9]{1,8})$/){ $num2 = $value; $renew_flag = 1; }
								}
						}

					# �X�V�s��ǉ�����
					push(@renewline,"$no2<>$moto2<>$sub2<>$domain2<>$num2<>$lasttime2<>\n");
				}

				# ���t�@�C���X�V�p
				elsif($type =~ /Renew/){

						# �L�^����ő�s�����`
						my($maxline_renew);
						if($type =~ /Account/){ $maxline_renew = 30; } else { $maxline_renew = 15; }

						# ���m���ŁA��萔�ȏ�̋L���͍폜���� ( ��\���̋L���̓G�X�P�[�v )
						if((rand($rand_delete) < 1 || $main::alocal_mode) && $i > $maxline_renew && $num2 >= 0){ next; }

						# �����L���̏ꍇ�A���|�C���g���}�C�i�X�łȂ���΁A�֘A�|�C���g�𑝂₷
						if($no2 == $set_no && $moto2 eq $set_moto && $domain2 eq $set_domain){
							if($num2 >= 0 && $main::time >= $lasttime2 + 5*60){ $num2++; $lasttime2 = $main::time; }
							$redun_flag = 1;
						}

						# �ԈႢ�o�^(�����L���̓o�^)���폜
						if($moto2 eq $kr_moto && $no2 == $kr_number){ &access_log("KR-SELF"); next; }

					# �X�V�s��ǉ�����
					push(@renewline,"$no2<>$moto2<>$sub2<>$domain2<>$num2<>$lasttime2<>\n");
				}
		}
	close($kr_handler);

	# ���C���f�b�N�X�擾��̏���
	if($type =~ /Oneline/){

		# ���^�[��
		return($one_line,$flow_flag);
	}

	# ���C���f�b�N�X�擾��̏���
	elsif($type =~ /Index/){

		# ���`
		if($index_line){ $index_line = qq(<ul>$index_line</ul>); }

		# ���^�[��
		return($index_line,$flow_flag);
	}


	# ���t�@�C���X�V��̏���
	elsif( $type =~ /Renew/ || ($type =~ /Edit-data/ && $renew_flag) ){

			# �d���s���Ȃ������ꍇ
			if($type =~ /Renew/ && !$redun_flag){

				# �^�C�g�����Ȃ��ꍇ�͎擾����
				if($set_sub eq ""){
					($set_sub) = Mebius::getpage("Title","http://$set_domain/_$set_moto/$set_no.html");
					($set_sub) = split(/ \| /,$set_sub);
					$set_sub =~ s/(\r|\n|\s+$)//g;
				}

				# �V�����s��ǉ�
				unshift(@renewline,"$set_no<>$set_moto<>$set_sub<>$set_domain<>0<>$main::time<>\n");

			}

		# �z����\�[�g
		@renewline = sort { (split(/<>/,$b))[4] <=> (split(/<>/,$a))[4] } @renewline;

		# �f�B���N�g�����쐬
		Mebius::Mkdir(undef,$krdirectory);

		# �֘A�L���t�@�C�����X�V
		Mebius::Fileout("",$krfile,@renewline);

		# �o�^�����̃��O���L�^
		#main::access_log("Kr-Successed","�o�^��F $krurl �o�^���F http://$set_domain/_$set_moto/$set_no.html ( $type )");

		# ���^�[��
		return(1);
	}

}


1;

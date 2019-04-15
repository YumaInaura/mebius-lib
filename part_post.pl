
use Mebius::Paint;
use Mebius::Echeck;
use Mebius::BBS::Past;
use Mebius::RegistCheck;
package main;


#-----------------------------------------------------------
# �V�K���e
#-----------------------------------------------------------
sub regist_post{

# �錾
my($basic_init) = Mebius::basic_init();
my($type) = @_;
my($allnum,$sexvio_check,$i,$flag,@new,@tmp,@top,$index_handler,$thread_handler,$past_handler,$plustype_news_thread,@be_old_thread_numbers);
our($realmoto,$head_title,$pmfile,$i_sub,$new_res_concept,%bbs,%in,$cnumber,$i_sub,$nowfile);

	# �ʏ퓊�e (�Ǘ��҈ȊO)
	if(!Mebius::Admin::admin_mode_judge()){

			# �T�u�L����p�f���̏ꍇ�A�G���[
			if($subtopic_mode){ &regist_error("�T�u�L�����[�h�ł͐V�K���e�ł��܂���B"); }

		# �A�����e�A�y�i���e�B�`�F�b�N
		require "${int_dir}part_newwaitcheck.pl";
		($newwait_flag,$newwait_dayhourmin,$nextwait_dayhour,$bonusform_flag) = &sum_newwait();
		sum_newwait_penalty();

		# �`���Ԉȓ��Ƀ��X�����Ă��Ȃ��ƁA�V�K���e�ł��Ȃ�����ꍇ
		require "${main::int_dir}part_newform.pl";
		Mebius::BBS::PostAfterResCheck();

		# �V�K���e�̓��e�`�F�b�N
		regist_post_check();

		# �V�K���e�̓��e�`�F�b�N
		Mebius::Regist::SubjectCheckBBS(undef,$i_sub,$i_com,$main::bbs{'concept'});

		# ���X�ԕ\�L�̓K���`�F�b�N
		#($i_com) = checkres_number($i_com,100);

	}

# ���b�N�J�n
&lock($moto);

	# �C���f�b�N�X���Ȃ��ꍇ�͍쐬���� ( $realmoto �ł͂Ȃ� $moto ��n�� )
	if(!-f $nowfile && Mebius::BBS::bbs_exists_check($moto)){
		my($index_directory_path_per_bbs) = Mebius::BBS::index_directory_path_per_bbs($moto);
		Mebius::mkdir($index_directory_path_per_bbs);
		Mebius::Fileout(undef,$nowfile,"0<><><><>\n");
	}

# ���s�C���f�b�N�X���J��
open($index_handler,"<",$nowfile) || &regist_error("�C���f�b�N�X���J���܂���B");

# �t�@�C�����b�N
flock($index_handler,1);

# �f���A�f�[�^�g�b�v��ǂݍ���
chomp(my $top = <$index_handler>);
my($new) = split(/<>/,$top);
close($index_handler);

	# �L���������Ă�ꍇ�A�G���[
	if($new eq ""){
		&regist_error("�C���f�b�N�X�������Ă��܂��B<a href=\"mailto:$basic_init->{'admin_email'}\">�Ǘ���</a>�܂ŘA�����Ă��������B");
	}

	# �A�����e�G���[ �e�L�X�g
	if($newwait_flag && !$freepost_mode && !$alocal_mode) {

		if($in{'k'}){$k_find_tag="k";}
		$e_com .= qq(���V�K���e�́A���� <strong class=\"red\">$newwait_dayhourmin</strong> �҂��ĉ������B<a href="${k_find_tag}find.html">�L������</a>�Ȃǂ����āA���̋L�����g���܂��傤�B<br>);
		$emd++;
		$strong_emd++;
	}

	# �d���X���b�h�������݋֎~
	for(1..25){
		$new++;
		my($thread_file) = Mebius::BBS::thread_file_path($moto,$new);
			# �X���b�h�����݂���ꍇ
			if(-f $thread_file){
				next;
			}
			else{
				$next_thread_ok_flag = 1;
				last;
			}
	}

	# �V�����i���o�[�̋L���������ɂ���ꍇ
	if(!$next_thread_ok_flag){
		Mebius::send_email("To-master",undef,"���݂���L���i���o�[ ($new)","�V�K���e�����܂������Ȃ������݂����ł��B\n\nhttp://$server_domain/jak/$moto.cgi");
		regist_error("���ɂ��̃i���o�[�̋L���͑��݂��܂��B");
	}

# �����`�F�b�N
$new =~ s/\D//;
$i_postnumber = $new;

# �G���[�t���O������ꍇ�A�G���[���[�h�ցi���̂P�j
&error_view("AERROR Target Not-tell","regist_error");

	# �A���[�g�˔j���L�^
	if($main::a_com && $main::alert_type){ $new_res_concept .= qq( Alert-break-\[$main::alert_type[0]\]); }

# ���s�C���f�b�N�X���J��
open($index_handler,"<",$nowfile) || &regist_error("�C���f�b�N�X���J���܂���B");

# �t�@�C�����b�N
flock($index_handler,1);

# �f���A�f�[�^�g�b�v��ǂݍ���
chomp(my $top_buffer = <$index_handler>);

	# ���s�C���f�b�N�X��W�J
	while (<$index_handler>) {
		my($thread_number2,$sub,$key) = (split(/<>/))[0,1,6];
		$i++;
			# �L�����d���`�F�b�N
			if ($sub eq $in{'sub'}) { $flag++; }
			# �Ǘ��ҋL���́A�ŏ㕔�ɕۗ�
			#elsif ($key == 2) { push(@top,$_); next; }
			# �L��������ꂽ�ꍇ�A�ߋ����O��
			if ($i >= $i_max) {	
				push(@tmp,$_);
				push(@be_old_thread_numbers,$thread_number2);
			}
			# ����ǂ���A���O�ǉ�
			#else { push(@new,$_); }
	}

close($index_handler);

	# �L�����d���`�F�b�N
	if($flag) {
		if($alocal_mode){ $i_sub .= qq( - $time); }
		else{ $e_sub .= "��$in{'sub'}�Ƃ����薼�͏d�����Ă��܂��B�i�ʂ̑薼���g���Ă��������j<br>"; $emd++; }
	}

# �^�C�g���A�㕔���j���[��`
$sub_title = "�V�K���e - $title";
$head_link3 = "&gt; �V�K���e�t�H�[��";
$i_resnumber = 0;

	# ���������摜�̔���
	if($in{'image_session'}){
		my(%image) = Mebius::Paint::Image("Get-hash Post-check",$in{'image_session'});
		if($image{'post_ok'}){ $image_data = qq(1); }
		else{ $e_com .= qq(�����̂��G�����摜�͊��ɓ��e�ς݁A�������͕ۑ��������؂�Ă��܂��B<br$main::xclose>); }
	}

# �G���[�t���O������ꍇ�A�G���[���[�h�ցi���̂Q�j
error_view("AERROR Target Not-tell","regist_error");

# �V�L���A�C���f�b�N�X�s�̃L�[�����߂�
my($index_key);
if($in{'sex'}){ $index_key = 9; }
elsif($in{'vio'}){ $index_key = 8; }
else{ $index_key = 1; }

# ���O�f�B���N�g�����쐬
Mebius::Mkdir(undef,"$main::bbs{'data_directory'}");
Mebius::Mkdir(undef,"$main::bbs{'data_directory'}_index_${moto}");
#Mebius::Mkdir(undef,"$main::bbs{'data_directory'}_thread_log_${realmoto}");

# �C���f�b�N�X�X�V ( �t�@�C�����b�N�̂��߁A���߂ăt�@�C�����J���ď������� )
my(%select_renew);
$select_renew{'+'}{'thread_num'} = 1;
$select_renew{'last_modified'} = time;
$select_renew{'last_post_time'} = time;
my $new_line = qq($new<>$i_sub<>0<>$i_handle<>$time<>$i_handle<>$index_key<>\n);
Mebius::BBS::index_file({ Renew => 1 , NewThread => 1 , select_renew => \%select_renew , new_line => $new_line , max_line => $i_max } , $moto);

	# �����ߋ����O���j���[ ( �����p�t�@�C�� ) ���X�V
	{
		my $i = 0;
			if(@tmp >= 1) {
				Mebius::BBS::old_type_past_menu_file({ Renew => 1 , bbs_kind => $realmoto ,  add_line => \@tmp , thread_number => $be_old_thread_numbers[$i]} );
				$i++;
			}
	}

	# ���V�ߋ����O��ǉ�
	foreach(@be_old_thread_numbers){
		Mebius::BBS::BePastThread(undef,$main::realmoto,$_);
	}

# �L����̂w�h�o���L�^
if(!$no_xip_action){ $post_xip = "$xip_enc"; }

# ���\���A�\�͕\��
if($in{'vio'}){ $sexvio_check = 1; }
if($in{'sex'}){ $sexvio_check = 2; }
if($in{'sex'} && $in{'vio'}){ $sexvio_check = 3; }

	# ���X���b�h�X�V
	{

		# �g�b�v�f�[�^
		my $select_renew = { concept => $new , sub => $i_sub , lasthandle => $i_handle , res => 0 , key => 1 , sexvio => $sexvio_check , lastmodified => time , lastrestime => time , lastcomment => $i_com , poster_xip => $post_xip , posttime => time };
	
		my $new_line = "0<>$cnumber<>$i_handle<>$enctrip<>$i_com<>$date<>$host<>$encid<>$in{'color'}<>$main::agent<>$username<><>$pmfile<>$image_data<>$new_res_concept<>$main::time<>\n";
		my($renewed) =  Mebius::BBS::thread({ ReturnRef => 1 , Renew => 1 , AllowTouchFile => 1 , new_line => $new_line , select_renew => $select_renew },$moto,$new);


	}

#�w�h�o�t�@�C������
regist_post_xip();

# ���b�N����
&unlock($moto);


	# �T�C�g�S�̂̐V���L�����X�g���X�V
	if($main::bbs{'concept'} =~ /Chat-mode/){ $plustype_news_thread .= qq( Hidden-from-top); }
require "${int_dir}part_newlist.pl";
Mebius::Newlist::threadres("RENEW THREAD $plustype_news_thread","","","","$realmoto<>$head_title<>$i_postnumber<>$i_resnumber<>$i_sub<>$i_handle<>$i_com<>$category<>$pmfile<>$encid");

	# ���� �ᔽ��
	if(Mebius::Fillter::basic(utf8_return($i_sub),utf8_return($i_com))){
		
	}

#my $subject_utf8 = utf8_return($i_sub);
#$bbs_thread->new_submit({ bbs_kind => $realmoto , thread_number => $i_postnumber , subject => $subject_utf8 });

return($i_postnumber,$i_resnumber,$i_sub);

}

no strict;

#-----------------------------------------------------------
# �w�h�o�t�@�C������
#-----------------------------------------------------------
sub regist_post_xip{

# ���^�[��
if($freepost_mode){ return; }

my($share_directory) = Mebius::share_directory_path();

# �����o�����e���`
my $nexttime = $time + $new_wait*60*60;
$cnew_time = $nexttime;
my $xip_out = qq($nexttime);

# �w�h�o�t�@�C���������o��
Mebius::Fileout(undef,"${share_directory}_ip/_ip_new/${xip_enc}.cgi",$xip_out);

	# ���̊m���ŌÂ��w�h�o�t�@�C����S�폜
	if(rand(1000) < 1){ &oldremove("","${share_directory}_ip/_ip_new","30"); }


}

#-----------------------------------------------------------
# �V�K���e���́A�薼�Ȃǂ̊�{�`�F�b�N
#-----------------------------------------------------------
sub regist_post_check{

# ���ʂ̔���i�V�K���e�j
if($concept =~ /NOT-POST/) { $e_sub .= "�����̌f���ł͐V�K���e�͏o���܂���B<br>"; $emd = 1; }
if ($a_access) { $e_sub .= "��<a href=\"${guide_url}%BD%E0%C5%EA%B9%C6%C0%A9%B8%C2";\">�V�K���e�̌���������܂���</a>�B<br>"; $emd = 1; } 
$sub_leng = (length $i_sub); $z_sub_leng = $sub_leng / 2;

if($bbs{'concept'} =~ /Newpost-minimum-message/){ $new_min_msg = 10; }
if ($bglength > $new_max_msg) { $e_com .= "�����������������܂� �B�i�S�p $bglength����/$new_max_msg�����j<br>"; $emd = 1; }
if ($smlength < $new_min_msg && !$alocal_mode) { $e_com .= "�������������Ȃ����܂��B �i�S�p $smlength����/$new_min_msg�����j<br>"; $emd = 1; }

# ���I���e�A�\�͓I���e
&sexvio_postcheck();

	# �n�샂�[�h����i�V�K���e -----
	if($main::bbs{'concept'} =~ /Sousaku-mode/){

			if($category ne "diary"){
			# �n��I�ȑ薼�̔���i�Q / ���e�Җ��Ō����j
			if (index($i_sub,$i_handle) >= 0) { $a_subdeny .= "��<a href=\"${guide_url}%C1%CF%BA%EE%A4%CE%C2%EA%CC%BE\">�薼�Ɂh$i_handle�i�����̖��O�j�h������̂́A���܂�ӂ��킵������܂���B</a><br>
			�@�i��i����A�H�v�̂���^�C�g�����g���܂��傤�j<br>"; }

			if ($i_sub =~ /���b/){
			$e_com .="�����b�����͖�肪�傫���Ȃ邽�߁A���e���Ȃ��ł��������B���Ȃ���F�B�̎������΂ɏ������܂Ȃ��ł��������B<br>";  }

			}

	}


# ���ʃ��[�h�̔���i�V�K���e�j

	else{

		#�G�k�L���̔���
		if($concept !~ /ZATUDANN-OK/){
				if($i_sub =~ /(��|�j��)/){
						if($i_sub =~ /(��|�b)/){
							$e_sub .= qq(�������̎G�k�L���͍��܂���B<br>);
							$emd++;
						}
				}
		}

			
			#�l�I�L���̔���i�P / �L�[���[�h�Ŕ���j
			if ($i_sub =~ /(����|�l��|�߂܂���|����ɂ�)/) { $a_subdeny .= "��<a href=\"${guide_url}%B8%C4%BF%CD%C5%AA%A4%CA%B5%AD%BB%F6\">�l�I�ȋL������낤�Ƃ��Ă��܂��񂩁H</a><br>
			�@�i���p�ґS�����g����L�������܂��傤�j<br>"; }


			# �l�I�L���̔���i�Q / ���e�Җ��Ō����j
			if ($i_handle ne "" && index($i_sub,$i_handle) >= 0) {
			$e_sub .= "��<a href=\"${guide_url}%B8%C4%BF%CD%C5%AA%A4%CA%B5%AD%BB%F6\">�薼�ɁA�����̖��O�h$i_handle�h�����邱�Ƃ͏o���܂���B</a><br>
			�@�l�I�ȋL���ł͂Ȃ��A��ʓI�ȋL��������Ă��������B<br>"; $emd = 1; }

			# �V�ыL���̔���

			if($concept !~ /MODE-ASOBI/){
			@aso_word = ('�I�[�f�B','�w��','����Ƃ�');
			foreach(@aso_word){ if(index($i_sub,$_) >=0){$tit_aso_flg = 1;} }
			if($tit_aso_flg){$a_sub .="��<a href=\"${guide_url}%CD%B7%A4%D3%CC%DC%C5%AA%A4%CE%B5%AD%BB%F6\">�u����Ƃ�v�u�������V�сv�ȂǁA�V�іړI�̋L������낤�Ƃ��Ă��܂��񂩁H</a><br>
			�@�i�f���́A�b������߂Ęb�������ꏊ�ł��j<br>";  }
			}

			if ($i_sub =~ /(�i���I|�G��|�G�b�`)/){
			$a_sub .="��<a href=\"${guide_url}%C0%AD%C5%AA%A1%A2%CB%BD%CE%CF%C5%AA%A4%C7%BB%D7%CE%B8%A4%CE%A4%CA%A4%A4%C5%EA%B9%C6\">�P�ɐ��I�ȋL������낤�Ƃ��Ă��܂��񂩁H</a><br>
			�@�i�����ړI��������A�v���̂Ȃ��L���͍��Ȃ��ł��������j<br>"; $amd++; }

			if ($i_sub =~ /(����|����|�ގ�|�ޏ�|��W|���R��)/) { $a_subdeny .= "��<a href=\"${guide_url}%A5%CA%A5%F3%A5%D1%B9%D4%B0%D9\">�ގ��A�ޏ��A�����F�A���ʑ���̕�W�Ȃǂ����Ă��܂��񂩁H</a><br>
			�@���r�E�X�����O�́A�o��n�ł͂���܂���B<br>"; $amd = 1; }

	}

	# �{���`�F�b�N
	foreach(split/<br>/,$i_com){
		if($bbs{'concept'} !~ /(ZATUDANN-OK1|ZATUDANN-OK2)/
					 && $main::category ne "narikiri" && $main::category ne "gokko" 
								&& $_ =~ /�v���t/ && $_ =~ /((��|��)(����|���܂�|��))/){
			$e_com .= qq(���G�k���h�~�̂��߁A�Q���҂Ƀv���t�B�[�����������邱�Ƃ͂��������������B<br>);
			Mebius::Echeck::Record("","Post-profile-error");
		}

	}


}

#-----------------------------------------------------------
# ���I�ȓ��e�A�\�͓I�ȓ��e�̃`�F�b�N
#-----------------------------------------------------------
sub sexvio_postcheck{

my($basic_init) = Mebius::basic_init();

# ���^�[��
if($main::bbs{'concept'} !~ /Sousaku-mode/){ return; }

# �Ǐ���
my($age,$free,$subsex_flag,$vio_flag);

	# �g�тŃN�b�L�[�F�؂ł��Ȃ��ꍇ
	if($k_access && !$cookie){ $free = 1; }

# ���݂̔N����v�Z
my($age);
	if($free){ $age = 20; }
	elsif(!$cage){ $age = 0; }
	else{ $age = $thisyear - $cage; }

	# �\\�͓I�ȓ��e
	if($in{'vio'} && $age < 15){
		$e_sub .= qq(��<a href="$basic_init->{'main_url'}?mode=settings#EDIT">�\\�͓I�ȓ��e���܂ޏꍇ�́A�}�C�y�[�W�ŔN��ݒ�����Ă��������i15�Ζ����s�j�B</a><br>); $emd++;
	}

	elsif($i_sub =~ /(�O��|\(�\\|�i�\\|�\\��|�C�W��|������|������|�E�l|�s��|�Ղ�|�c��|���\\|�\\�A��|�\\����)/){
			if($age < 15){ $e_sub .= qq(��<a href="$basic_init->{'main_url'}?mode=settings#EDIT">�\\�͓I�ȓ��e���܂ޏꍇ�́A�}�C�y�[�W�ŔN��ݒ�����Ă��������i15�Ζ����s�j�B</a><br>); $emd++; }
			else{ $e_sub .= qq(���u�\\�͓I�ȓ��e�v�̃��[�����ς��܂����B�薼�ɂ͒��ӏ�������ꂸ�A���e�t�H�[���̐�p�`�F�b�N�{�b�N�X���I���ɂ��Ă��������B</a><br>); $emd++; }
	}

	# �\�� - �{��
	if($i_com =~ /(�O��|������|�C�W��|�E�l|�\\�s|�s��|�Ղ�|�c��)/ && !$in{'vio'}){ $a_com = qq(�������\\�͓I�ȓ��e���܂ޏꍇ�́A���e�t�H�[���̐�p�`�F�b�N�{�b�N�X���I���ɂ��Ă�������(15�Ζ����s��)�B<br>); $amd++; }

	# ���\���`�F�b�N - �薼
	if($i_sub =~ /(���I|����|\����|\(��|�i��|��\)|���j)/ || $i_sub =~ /(�q|R)/ && $i_sub =~ /(18|�P�W|��)/ || $i_sub =~ /��/ && $i_sub =~ /(�a�k|BL|�f�k|GL)/ || ($i_sub =~ /��/ && $i_sub =~ /�\\/)){ $subsex_flag = 1; }

	if($subsex_flag){$e_sub .= qq(���u���I�ȓ��e�v�̃��[�����ς��܂����B�薼�ɂ͒��ӏ�������ꂸ�A���e�t�H�[���̐�p�`�F�b�N�{�b�N�X���I���ɂ��Ă�������(18�Ζ����s��)�B</a><br>); $emd++; }

	if($in{'sex'} && !$age){ $e_sub .= qq(��<a href="$basic_init->{'main_url'}?mode=settings#EDIT">���I�ȓ��e���܂ޏꍇ�́A�}�C�y�[�W�ŔN��ݒ�����Ă��������i18�Ζ����s�j�B</a><br>); $emd++; }
	elsif($in{'sex'} && $age < 18){ $e_sub .= qq(��<a href="$guide_url\%C0%AD%C5%AA%A4%CA%C9%BD%B8%BD">18�˖����̕��́A���I���e���܂ދL�������܂���B</a><br>); $emd++; }

	# ���\���`�F�b�N - �{��
	if($i_com =~ /(���I)/ && !$in{'sex'}){
		if(!$age){
		$a_com = qq(��<a href="$basic_init->{'main_url'}?mode=settings#EDIT">���\\�����܂܂��ꍇ�A�}�C�y�[�W�ŔN��ݒ���ς܂��Ă�������(18�Έȏ�)�B</a>�B<br>);
		}
		elsif($age >= 18){
		$a_com = qq(�����\\��������ꍇ�A�K�؂ȃ`�F�b�N�����Ă��������i���e�t�H�[�����j�B<br>);
		}
		else{
		$a_com = qq(��18�Έȉ��̏ꍇ�A���\\�����܂ދL��������Ă͂����܂���B<br>);
		}
		$amd++;
	}

}



1;

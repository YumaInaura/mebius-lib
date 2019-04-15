
use Mebius::Echeck;
use Mebius::Paint;
use Mebius::Text;
use Mebius::BBS;
use Mebius::BBS::Index;
use strict;

use Mebius::Export;

#-----------------------------------------------------------
# ���X���e
#-----------------------------------------------------------
sub regist_res{

# �錾
my($type,$thread_number,$new_handle,$new_comment,$new_color,$new_encid,$new_account,$new_res_concept,$image_data) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # �����^�C�v��W�J
my($bonus_text,$duplication_thread_flag,$thread_link);
my($plustype_duplication,$plustype_news_res,$i_sub,$new_resnumber,$sexvio);
our($head_title,$realmoto,%in,$concept,$int_dir,$doublechecked_flag,$alocal_mode);
our($sub_title,$e_com,$moto,$m_max,$cnumber);
our($enctrip,$host,$date,$title,$head_link3,$head_link4,$subtopic_mode,$k_access,$time);
our($agent,$username,$category);
my($init_bbs) = Mebius::BBS::init_bbs_parmanent($moto);

	# �L���i���o�[���w�肳��Ă��Ȃ��ꍇ
	if($thread_number eq "" || $thread_number =~ /\D/) { &regist_error("���e��̋L�����w�肵�Ă��������B"); }

# �g�b�v�f�[�^���擾
my(%thread) = Mebius::BBS::thread({},$realmoto,$thread_number);
our $thread_key = $thread{'concept'};

#kanagawa.ocn.ne.jp

# �^�C�g���A�㕔���j���[��`
$sub_title = "���e�y�[�W - $title";
$head_link4 = "&gt; ���X���e";
$head_link3 = qq(&gt; <a href="${thread_number}.html">$thread{'sub'}</a> );


	# �y�L���g�b�v�f�[�^�z���g���Ă̏d���`�F�b�N ( ���ׂĂ̕��͕ϊ����I�������ɔ��肷�邱�� # && !$alocal_mode && $main::bbs{'concept'} !~ /Local-mode/
	if(!Mebius::Admin::admin_mode_judge() && !Mebius::alocal_judge()){
			if($concept =~ /Light-duplication/){ $plustype_duplication .= qq( Light-judge); }
		($duplication_thread_flag,$thread_link) = Mebius::Text::Duplication("Not-line-check $plustype_duplication",$new_comment,$thread{'lastcomment'});
			if($duplication_thread_flag) {
				Mebius::AccessLog(undef,"Dupulication-bbs-regist","$new_comment\n\n$thread{'lastcomment'}");

				$e_com .= qq(���ЂƂO�̃��X�Ɣ��Ɏ��Ă��邩�A���͂����̂܂܎g���Ă��܂��B<br>);
				$e_com .= qq(�@<a href="$thread_number.html#S$thread{'res'}">���̋L��</a>�ɖ߂��Ċm�F���Ă��������B<br>);
					if($main::myadmin_flag >= 5){ $e_com .= qq(�`�F�b�N�F $duplication_thread_flag<br>); }

			}
	}

	# ���݂̃`���[�W���Ԃ��`�F�b�N
	if(!Mebius::Admin::admin_mode_judge()){
		require "${int_dir}part_waitcheck.pl";
		my($nowcharge_message) = &get_nowcharge_res("REGIST",$in{'comment'});
		if($nowcharge_message){ $e_com .= $nowcharge_message;  }
	}

	# ����̃`���[�W���Ԃ��v�Z
	our($nextcharge_time,$nextcharge_minute,$nextcharge_second,$nextcharge_minsec);
	if(!Mebius::Admin::admin_mode_judge()){
		($nextcharge_time) = &get_nextcharge_res("",$in{'comment'});
		($nextcharge_minute,$nextcharge_second) = &minsec("",$nextcharge_time);
		 $nextcharge_minsec = "$nextcharge_minute��$nextcharge_second�b";
	}

	# ���������摜�̔���
	if($in{'image_session'}){
		my(%image) = Mebius::Paint::Image("Get-hash Post-check",$in{'image_session'});
		if($image{'post_ok'}){ $image_data = qq(1); }
		else{ $e_com .= qq(�����̂��G�����摜�͊��ɓ��e�ς݁A�������͕ۑ��������؂�Ă��܂��B<br$main::xclose>); }
	}

	# �G���[/�v���r���[��\��
	#if(!Mebius::Admin::admin_mode_judge()){
		&error_view("AERROR Target Not-tell","regist_error");
	#}

	# �G���[/�v���r���[��\��
	if(!Mebius::Admin::admin_mode_judge()){
		&error_view("AERROR Target Not-tell","regist_error");
	}

	# �A���[�g�˔j���L�^
	if(!Mebius::Admin::admin_mode_judge() && $main::a_com && $main::alert_type[0]){
		$new_res_concept .= qq( Alert-break-\[$main::alert_type[0]\]);
	}

# ���b�N�J�n
Mebius::lock($moto);

# ���X���b�h���X�V
	# �T�u�L���̏ꍇ
	if(Mebius::BBS::sub_bbs_judge($realmoto)){

		# ���C���L�����J���ăG���[�`�F�b�N
		my($main_thread_subject,undef,$main_sexvio) = bbs_thread_for_renew("Flock",$moto,$thread_number);

		# �T�u�L�����X�V
		($i_sub,$new_resnumber,$sexvio) = bbs_thread_for_renew("Renew Sub-thread My-thread",$realmoto,$thread_number,$new_comment,$new_handle,$cnumber,$new_encid,$enctrip,$new_color,$new_account,$image_data,$new_res_concept,"$main_thread_subject &lt;�T�u�L��&gt;",$main_sexvio);

		# ���C���L�����X�V (���C���L���ɋL�^�����A�T�u�L���̃��X���𑝂₷)
		my(%select_renew);
		$select_renew{'sub_thread_res'} = $new_resnumber;
		Mebius::BBS::thread({ Renew => 1 , select_renew => \%select_renew },$moto,$thread_number);

	}
	# ���C���L���̏ꍇ
	else{
		# ���C���L�����X�V
		($i_sub,$new_resnumber) = bbs_thread_for_renew("Renew My-thread",$realmoto,$thread_number,$new_comment,$new_handle,$cnumber,$new_encid,$enctrip,$new_color,$new_account,$image_data,$new_res_concept);
	}

	# ���C���f�b�N�X���X�V
	{

		# �ǉ������^�C�v���`
		my($sort_flag,$sub_thread_flag,%line_control);

		# �C���f�b�N�X���́A�Y���X���b�h�s�̍X�V���e���`
		$line_control{$thread_number}{'last_handle'} = $new_handle;
		$line_control{$thread_number}{'last_res_number'} = $new_resnumber;
		$line_control{$thread_number}{'last_modified'} = time;
			if($thread{'key'} ne "2"){
				$line_control{$thread_number}{'key'} = "1";
			}

			# �L�����A�b�v���锻��
			if($concept =~ /AUTO-UPSORT/ || ( $in{'thread_up'} && $concept !~ /NOT-UPSORT/) ) {
				$sort_flag = 1;
			}

			# ���T�u�L���ɏ������񂾏ꍇ
			if(Mebius::BBS::sub_bbs_judge_auto()){

					Mebius::BBS::index_file({ RegistRes => 1 , Renew => 1 , SubIndex => 1 , line_control => \%line_control },$realmoto);

						# �T�u�L���ւ̏������݂ł��A���C���̃C���f�b�N�X���A�b�v����
						if($sort_flag){
							Mebius::BBS::index_file({ Sort => $sort_flag , RegistRes => 1 , Renew => 1 , line_control => { $thread_number => {} } },$moto);
						}

			# �����C���L���ɏ������񂾏ꍇ
			} else {

				my(%select_renew);

					if($main::subtopic_mode){ $sub_thread_flag = 1; }



				# �C���f�b�N�X�t�@�C���̃g�b�v�f�[�^
				$select_renew{'last_modified'} = time;
				$select_renew{'last_res_thread_number'} = $thread_number;

				Mebius::BBS::index_file({ Sort => $sort_flag , RegistRes => 1 , Renew => 1 , SubThread => $sub_thread_flag , select_renew => \%select_renew , line_control => \%line_control },$moto);

			}

	}

# ���b�N����
Mebius::unlock($moto);

	# ���X�̃`���[�W���ԃt�@�C�����X�V
	if(!Mebius::Admin::admin_mode_judge()){
		require "${int_dir}part_waitcheck.pl";
		&renew_nextcharge_res("",$nextcharge_time);
	}

	# �T�C�g�S�̂̐V�����X���L�^
	if(!Mebius::Admin::admin_mode_judge()){

			if(!$in{'thread_up'} || $main::bbs{'concept'} =~ /Chat-mode/){ $plustype_news_res .= qq( Hidden-from-top); }
		require "${int_dir}part_newlist.pl";
		Mebius::Newlist::threadres("RENEW RES Buffer $plustype_news_res","","","","$realmoto<>$head_title<>$thread_number<>$new_resnumber<>$i_sub<>$new_handle<>$new_comment<>$category<>$new_account<>$new_encid");
	}

	# �J�e�S�����̐V�����X���L�^
	if(!Mebius::Admin::admin_mode_judge() && $in{'thread_up'} && $main::bbs{'concept'} !~ /Chat-mode/){
		category_newres("",$main::category,$thread_number,$new_resnumber,$i_sub,$new_comment,$new_handle,$sexvio);	
	}


	# �T�C�g�S�̂̍����̓��e�� / ���������L�^
	if(!Mebius::Admin::admin_mode_judge() && $main::bbs{'concept'} !~ /Chat-mode/){
		renew_reslength();
	}


return($thread_number,$new_resnumber,$i_sub,$new_comment,$new_res_concept,$thread{'posttime'});

}

#-----------------------------------------------------------
# �X���b�h���X�V / �X���b�h��Ԃ𔻒�
#-----------------------------------------------------------
sub bbs_thread_for_renew{

# �錾
my($type,$realmoto,$thread_number,$new_comment,$new_handle,$new_cnumber,$new_encid,$new_trip,$new_color,$new_account,$new_image_data,$new_res_concept,$new_subject,$new_sexvio) = @_;
my(%type); foreach(split(/\s/,$type)){	$type{$_} = 1; } # �����^�C�v��W�J
my($thread_handler1,@renew_line,$put_age,$other_top_data);

# ���t���擾
my($nowdate) = Mebius::now_date();
my($my_addr) = Mebius::my_addr();

# �L�����`
my($thread_directory) = Mebius::BBS::path({ Target => "thread_directory" } , $realmoto);
	if(!$thread_directory){ main::error("�L����ݒ�ł��܂���B"); }
my $file = "${thread_directory}$thread_number.cgi";

# �L�����J��
my($open) = open($thread_handler1,"+<",$file);

	# �L�����J���Ȃ������ꍇ
	if(!$open){
			# �T�u�L���̏ꍇ�͐V�K�쐬
			if($type{'Sub-thread'}){
				my	$line = qq(<>$new_subject<>0<>1<><><><><><><><><><><><><><><>\n);
					$line .= qq(0<><><><><><><><><><><>\n);
					Mebius::Mkdir(undef,${thread_directory});
					Mebius::Fileout(undef,$file,$line);
					open($thread_handler1,"+<$file");
			}
			# ���C���L���̏ꍇ�̓G���[��
			else{
				regist_error("�L�������݂��܂���B");
			}
	}

	# �t�@�C�����b�N
	if($type{'Renew'} || $type{'Flock'}){ flock($thread_handler1,2); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top_thread = <$thread_handler1>);
my($no,$sub,$res,$key,$lasthandle,$last_res_time,$d_delman,$lastmodified,$dd1,$sexvio,$dd3,$dd4,$memo_editor,$memo_body,$dd7,$lock_end_time,$last_comment,$dd10,@other_top_data) = split(/<>/, $top_thread);

# ���X���̒���
my $new_resnumber = $res + 1;

	# ���d�������݂��֎~
	if($type{'My-thread'} && $last_res_time == time && $lasthandle eq $new_handle){
		close($thread_handler1);
		Mebius::AccessLog(undef,"Double-res-regist","${main::jak_url}$realmoto.cgi?mode=view&no=$thread_number#S$res");
		regist_error(qq(���d�������݂ł��B<a href="/_$realmoto/$thread_number.html#S$res" target="_blank" class="blank">���̋L��</a>�ɂ����������܂�Ă��܂��񂩁H));
	}

	# �薼���Ȃ��ꍇ�A�L�������Ƃ݂Ȃ�
	if($sub eq ""){
		close($thread_handler1);
		regist_error("�薼���Ȃ����A�L���������Ă��܂��B");
	}

	# �X���b�h�̃L�[�`�F�b�N
	if($key eq "0" && (!$lock_end_time || $main::time < $lock_end_time)) {
		close($thread_handler1);
		&regist_error("���̋L���̓��b�N����Ă��܂��B");
	}
	elsif($key == 3) {
		close($thread_handler1);
		&regist_error("���̋L���͉ߋ����O�ł��B");
	}
	elsif($key == 4 || $key == 6 || $key == 7 || $key eq "") {
		close($thread_handler1);
		&regist_error("���̋L���͑��݂��Ȃ����A�폜�ς݂ł��B");
	}

	# ���X���ő�ɒB���Ă���ꍇ
	if($type{'My-thread'} && $res >= $main::m_max) {
		close($thread_handler1);
		&regist_error("���X���ő吔 ( $main::m_max�� ) �𒴂��Ă��܂��B�������̋L���ɂ͏������߂܂���B");
	}

	# �g�т���̓��e�̂݁A���[�U�[�G�[�W�F���g���L�^
	if($main::k_access || $main::bbs{'concept'} =~ /RECORD-AGENT/){ $put_age = $main::agent; }

	# �t�@�C���X�V����ꍇ
	if($type{'Renew'}){

			# �T�u�L���̒���
			if($type{'Sub-thread'}){
				$sub = $new_subject;
				$sexvio = $new_sexvio;
			}

		# �g�b�v�f�[�^��ǉ�
	foreach(@other_top_data){
		$other_top_data .= qq($_<>);
	}
	push(@renew_line,"$no<>$sub<>$new_resnumber<>$key<>$new_handle<>$main::time<>$d_delman<>$main::time<>$dd1<>$sexvio<>$dd3<>$dd4<>$memo_editor<>$memo_body<>$dd7<>$lock_end_time<>$new_comment<>$dd10<>" . $other_top_data . qq(\n));

			# �t�@�C����W�J
			while(<$thread_handler1>){

				# �X�V�s��ǉ�
				push(@renew_line,$_);

			}

		# �V�����s��ǉ�
		push(@renew_line,"$new_resnumber<>$new_cnumber<>$new_handle<>$new_trip<>$new_comment<>$nowdate<>$main::host<>$new_encid<>$new_color<>$put_age<>$main::username<><>$new_account<>$new_image_data<>$new_res_concept<>$main::time<>$my_addr<>\n");

			# �t�@�C���ɒ��ڏ�������
			if($type{'Renew'}){
				Mebius::File::truncate_print($thread_handler1,@renew_line);
				#seek($thread_handler1,0,0);
				#truncate($thread_handler1,tell($thread_handler1));
				#print $thread_handler1 @renew_line;
			}
	}


# �t�@�C���N���[�Y
close($thread_handler1);

# �p�[�~�b�V�����ύX
Mebius::Chmod(undef,$file);

return($sub,$new_resnumber,$sexvio);

}


#-----------------------------------------------------------
# ���e���A�������L�^�t�@�C�����X�V
#-----------------------------------------------------------
sub renew_reslength{

# �錾
my(@line,$length,$filehandle);
our($int_dir,$secret_mode,$thisyear,$thismonth,$today,$smlength);

my($now_date_multi) = Mebius::now_date_multi();

	# ���^�[��
	if($secret_mode){ return; }

# �t�@�C���ǂݍ���
open($filehandle,"<","${int_dir}_reslength/${thisyear}_${thismonth}_${today}.cgi");
flock($filehandle,1);
chomp(my $top = <$filehandle>);
my($res,$length,$average,$wday) = split(/<>/,$top);
close($filehandle);

# �ǉ�����s
$res++;
$length += $smlength;
	if($res && $length){ $average = int($length / $res); }
	if($wday eq ""){ $wday = $now_date_multi->{'weekday'}; }
@line = qq($res<>$length<>$average<>$wday<>\n);

# �t�@�C���X�V
Mebius::Fileout("MAKE","${int_dir}_reslength/${thisyear}_${thismonth}_${today}.cgi",@line);

}

#-----------------------------------------------------------
# �J�e�S�����̐V�����X���L�^
#-----------------------------------------------------------
sub category_newres{

# �Ǐ���
my($type,$category,$i_postnumber,$i_resnumber,$i_sub,$i_com,$i_handle,$sexvio) = @_;
my($line,$i);
our($realmoto,$cnumber,$agent);

	# ���^�[��
	if($main::secret_mode){ return; }
	if($main::news_mode eq "0"){ return; }

# �����L�[
my $key = 1;

	# ��\���ɂ���ꍇ
	if($sexvio){ $key = 2; }
	if($i_sub =~ /(��|�\\|�O��|���C�v)/){ $key = 2; }
	if($main::bbs{'concept'} =~ /Sousaku-mode/ && $i_sub =~ /(�C�W��|������|�s��|�Ղ�|�c��)/){ $key = 2; }
	if($i_com =~ /����/ && $main::smlength < 20){ $key = 2; }

# �ǉ�����s
$line .= qq($key<>$main::realmoto<>$main::title<>$i_postnumber<>$i_sub<>$i_handle<><>$i_resnumber<>$main::time<>$main::date<>$category<>$main::smlength<>$main::pmfile<>$main::cnumber<>$main::agent<>\n);

# �t�@�C���ǂݍ���
open(NEWRES_IN,"<","${main::int_dir}_sinnchaku/_category/${category}_newres.cgi");
	while(<NEWRES_IN>){
		chomp;
		my($key,$moto2,$title2,$no,$sub,$handle,$none,$res,$lasttime,$date2,$category2,$length,$account) = split(/<>/);
			if($moto2 eq $realmoto && $no eq $i_postnumber){ next; }
		$i++;
			if($i <= 10){ $line .= qq($_\n); }
	}
close(NEWRES_IN);

# �t�@�C���X�V
Mebius::Fileout(undef,"${main::int_dir}_sinnchaku/_category/${category}_newres.cgi",$line);

}



1;

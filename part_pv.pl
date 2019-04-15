
use strict;
use Mebius::BBS;
package main;

#-----------------------------------------------------------
# �f���̋L���J�E���^
#-----------------------------------------------------------
sub do_pv{

# �錾
my($use,$thread_number,$moto) = @_;
my(@renew_line,$i,$notcount_flag,$scount,$sflag,$scounted_flag,$counted_flag,$all_count,$backup_handler,%self,$FILE1);
my $time = time;
our($agent,$myadmin_flag,$int_dir,$bot_access,$xip,$cookie,$k_access);

	# �t�@�C�� / �f�B���N�g����`
	if($thread_number eq "" || $thread_number =~ /\D/){ return(); }
	if($moto eq "" || $moto =~ /\W/){ return(); }
my($bbs_file) = Mebius::BBS::InitFileName(undef,$moto);
	if(!$bbs_file->{'data_directory'}){ return(); }

# �t�@�C����`
my $directory = $self{'directory'} = "$bbs_file->{'data_directory'}_pv_${moto}/";
my $file1 = $self{'file1'} = "$self{'directory'}${thread_number}_pv.cgi";
my $backup_file = "$self{'directory'}${thread_number}_pvbk.cgi";

	# �f�B���N�g�����쐬 ( ���׌y���̂��߁A���̂��Ƃ̏����ŁA�V�K�t�@�C���쐬���Ɉꏏ�ɏ������� )
	#if($use->{'TypeRenew'} && rand(100) < 1){ Mebius::Mkdir("",$directory); }

	# �t�@�C�����J��
	if($use->{'TypeFileCheckError'}){
		$self{'f'} = open($FILE1,"+<",$file1) || main::error("�t�@�C�������݂��܂���B");
	}
	else{

		$self{'f'} = open($FILE1,"+<",$file1);

			# �t�@�C�������݂��Ȃ��ꍇ
			if(!$self{'f'}){
					# �V�K�쐬
					if($use->{'TypeRenew'}){
						Mebius::Mkdir(undef,$directory);
						Mebius::Fileout("Allow-empty",$file1);
						$self{'file_touch_flag'} = 1;
						$self{'f'} = open($FILE1,"+<",$file1);
					}
					else{
						return(\%self);
					}
			}

	}

	# �t�@�C�����b�N
	if($use->{'TypeRenew'} || $use->{'TypeFlock'}){ flock($FILE1,2); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top = <$FILE1>);
my($count,$scount,$lasttime) = split(/<>/,$top);

	# �t�@�C����W�J
	while(<$FILE1>){

		# ���E���h�J�E���^
		$i++;

		# �s�𕪉�
		chomp;
		my($xip2,$lasttime2) = split(/<>/);

			# �ȑO�̋L�^��������Ԉȏ�o�߂��Ă���ꍇ
			if(time >= $lasttime2 + 24*60*60){ next; }

			# �d���J�E���g�𔭌������ꍇ
			if($xip2 eq $xip && !Mebius::alocal_judge()){
				$notcount_flag = 1;
				next;
			}

			# �X�V�p�ɍs��ǉ�
			push(@renew_line,"$xip2<>$lasttime2<>\n");

	}

# ����
if($ENV{'HTTP_REFERER'} =~ /http:\/\/(www\.)?(google\.|ping\.|yahoo\.)([a-z]{2,})/ && $ENV{'HTTP_REFERER'} =~ /search\?/){ $sflag = 1; }
if(!$count){ $count = 0; }
$all_count = $count + $scount;

	# �J�E���g�������L�����ă��^�[������ꍇ���`
	#if($lasttime + 1*60 > time){ $notcount_flag = 1; }				# �O��̃J�E���g�����莞�Ԃ��y�o�߂��Ă��Ȃ��z�ꍇ
	#if($lasttime + 24*60*60 < time){ $notcount_flag = 0; }			# �O��̃J�E���g�����莞�Ԉȏ�y�o�߂��Ă���ꍇ�́z�A�������ɃJ�E���g����
	if($myadmin_flag >= 5){ $notcount_flag = 1; }					# �Ǘ��҂̃A�N�Z�X
	if(Mebius::alocal_judge()){ $notcount_flag = 0; }					# ���[�J�����[�h
	if($bot_access){ $notcount_flag = 1; }											# �{�b�g�΍� (���̏����͑�������ɔz�u)
	if(!$agent || (!$k_access && !$cookie && !$sflag) ){ $notcount_flag = 1; }		# �{�b�g�΍� (���̏����͑�������ɔz�u)

	# �J�E���g�����ɋA��ꍇ
	if($notcount_flag){
		close($FILE1);
			if($main::bbs{'concept'} =~ /NOT-PV/){ return(); }
			else{ return($all_count); }
	}

	# �J�E���g�����Ȃ��ꍇ�A�o�b�N�A�b�v����ǂݍ���
	#if(!$count){
	#	open($backup_handler,"<",$backup_file);
	#	my $top = <$backup_handler>; chomp $top;
	#	($count,$scount) = split(/<>/,$top);
	#	close($backup_handler);
	#}

# �J�E���g����
if($sflag){ $all_count++;  $scount++; $scounted_flag = 1; } else { $all_count++; $count++; $counted_flag = 1; }

# �V�����ǉ�����s
unshift(@renew_line,"$xip<>$time<>\n");

# �g�b�v�f�[�^��ǉ�
unshift(@renew_line,"$count<>$scount<>$time<>\n");

	# �t�@�C���X�V
	if($use->{'TypeRenew'}){
		seek($FILE1,0,0);
		truncate($FILE1,tell($FILE1));
		print $FILE1 @renew_line;
	}

close($FILE1);

	# �p�[�~�b�V�����ύX
	if($use->{'TypeRenew'} && ($self{'file_touch_flag'} || rand(25) < 1)){ Mebius::Chmod(undef,$file1); }

	#if($use->{'TypeRenew'}){
	#	Mebius::BBS::ThreadStatus->update_table({ update => { access_count => $count , bbs_kind => $moto , thread_number => $thread_number } } );
	#}

	## �L���̗ǂ������Ńo�b�N�A�b�v
	#if($all_count % 25 == 0 && $all_count >= 25){
	#	my $line = qq($count<>$scount<>\n);
	#	Mebius::Fileout(undef,$backup_file,$line);
	#}

	# �����L���O�ɓo�^����ꍇ
	if($use->{'TypeAddRanking'}){

		my $count_pace = 50;		# �`PV���ƂɃ����L���O�ɓo�^(����)
		my $scount_pace = 50;		#  �`PV���ƂɃ����L���O�ɓo�^(�����G���W��)
		my $bbs_count_pace = 10;	#  �`PV���ƂɃ����L���O�ɓo�^(�f����)
		my $count_border = 100;		# �`PV�ȏ�Ń����L���O�ɓo�^(����)
		my $scount_border = 100;	# �`PV�ȏ�Ń����L���O�ɓo�^(�����G���W��)
		my $bbs_count_border = 50;	# �`PV�ȏ�Ń����L���O�ɓo�^(�f����)
			if(Mebius::alocal_judge()){
				($count_pace,$scount_pace,$count_border,$scount_border,$bbs_count_pace,$bbs_count_border) = (1,1,1,1,1,1);
			}

			if($counted_flag && $all_count >= $count_border && $all_count % $count_pace == 0){
				&renew_pvranking("Renew Normal-count",$all_count,$thread_number,$moto); 
			}
			if($scounted_flag && $scount >= $scount_border && $scount % $scount_pace == 0){
				&renew_pvranking("Renew Search-engine-count",$scount,$thread_number,$moto);
			}
			if($counted_flag && $all_count >= $bbs_count_border && $all_count % $bbs_count_pace == 0){
				&renew_bbs_pvranking("Renew",$all_count,$thread_number,$moto);
			}
	}

	# �J�E���^�̐����͕Ԃ����Ƀ��^�[�� ( �J�E���g�����͂��邪�A�\�ɂ͏o���Ȃ��ꍇ )
	if($main::bbs{'concept'} =~ /NOT-PV/){ return(); }
	# ���ʂɃ��^�[��
	else{ return($all_count); }


}


#-----------------------------------------------------------
# �o�u�����L���O���X�V(�T�C�g�S��)
#-----------------------------------------------------------
sub renew_pvranking{

# �錾
my($type,$count,$thread_number,$moto) = @_;
my(@renew_line,$i,$key,$put_moto,$file,$all_ranking_handler,$keep_min_count,$still_flag);

# �����`�F�b�N
if($moto =~ /\W/ || $moto eq ""){ return(); }
if($thread_number =~ /\D/ || $thread_number eq ""){ return(); }

# �t�@�C����`
if($type =~ /Normal-count/){ $file = "rank_pv"; }
elsif($type =~ /Search-engine-count/){ $file = "rank_spv"; }
else{ return; }

# �ő�o�^�s��
my $max_line = 500;

# �e�탊�^�[��
if(($main::bbs{'concept'} =~ /NOT-PV/ || $main::secret_mode) && !Mebius::alocal_judge()){ return; }

# ���L���`�F�b�N
my(%thread) = Mebius::BBS::thread({},$moto,$thread_number);

# �����L�[
$key = 1;

# �L�����e�ɂ���Ă͋L�^���Ȃ�
if($thread{'keylevel'} < 0.5){ return(); }
if($thread{'sexvio'}){ return; }
if($thread{'subject'} =~ /(��|�\\|�O��)/){ return; }
if($main::bbs{'concept'} =~ /Sousaku-mode/ && $thread{'subject'} =~ /(�C�W��|������|�s��|�Ղ�|�c��)/){ return; }

# �t�@�C���ǂݍ���
open($all_ranking_handler,"<${main::int_dir}_sinnchaku/$file.log");

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($all_ranking_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$all_ranking_handler>);
my($tkey,$tmin_count,$ti) = split(/<>/,$top1);

	# �o�^�����}�b�N�X�ŁA�V�K�L���̃J�E���g���������L���̂ǂ�ɂ��y�΂Ȃ��ꍇ�A�����Ƀ��^�[���i���׌y���j
	if($ti >= $max_line && $count <= $tmin_count){
		close($all_ranking_handler);
		return();
	}

	# �t�@�C����W�J
	while(<$all_ranking_handler>){

		# ���E���h�J�E���^
		$i++;

		# �s�𕪉�
		chomp;
		my($key2,$count2,$svmoto,$svtitle,$svno,$sub2) = split(/<>/);

		# �ŏ��J�E���g�����L��
		if($type =~ /Renew/){
				if($keep_min_count > $count2 || $keep_min_count eq ""){ $keep_min_count = $count2; }
		}

			# �e��l�N�X�g
			if($i > $max_line){ next; }

			# �����L��������ꍇ
			if($svmoto eq $moto && $svno eq $thread_number){
				$still_flag = 1;
				$count2 = $count;
				$sub2 = $thread{'subject'};
			}

		# �X�V�s��ǉ�
		if($type =~ /Renew/){
			push(@renew_line,"$key2<>$count2<>$svmoto<>$svtitle<>$svno<>$sub2<>\n");
		}
	}

close($all_ranking_handler);


	# ���t�@�C���X�V����ꍇ
	if($type =~ /Renew/){

			# �V�����ǉ�����s
			if(!$still_flag){
				$i++;
				unshift(@renew_line,"$key<>$count<>$moto<>$main::title<>$thread_number<>$thread{'subject'}<>\n");
			}

		# PV���������Ƀ\�[�g
		@renew_line = sort { (split(/<>/,$b))[1] <=> (split(/<>/,$a))[1] } @renew_line;

		# �g�b�v�f�[�^��ǉ�����
		unshift(@renew_line,"$tkey<>$tmin_count<>$i<>\n");

		# �t�@�C���X�V
		Mebius::Fileout(undef,"${main::int_dir}_sinnchaku/$file.log",@renew_line);
	}


}


#-----------------------------------------------------------
# �o�u�����L���O���X�V(�f����)
#-----------------------------------------------------------
sub renew_bbs_pvranking{

# �錾
my($type,$count,$thread_number,$moto) = @_;
my($i,$file,$ranking_handler,@renew_line,$top1,$directory,$flow_flag,$keep_min_count,$still_flag);

# �����`�F�b�N
if($moto =~ /\W/ || $moto eq ""){ return(); }
if($thread_number =~ /\D/ || $thread_number eq ""){ return(); }

# �e�탊�^�[��
if(($main::bbs{'concept'} =~ /NOT-PV/ || $main::secret_mode) && !Mebius::alocal_judge()){ return; }

# ���L���`�F�b�N
my(%thread) = Mebius::BBS::thread({},$moto,$thread_number);

# �ő�o�^��
my $max_line = 100;

# �t�@�C����`
$directory = "$main::bbs{'data_directory'}_other_${moto}/";
$file = "${directory}pvall_${moto}.log";

# �e��`�F�b�N
if($thread{'keylevel'} < 0.5){ return(); }
if($thread{'sexvio'}){ return(); }
if($thread{'subject'} =~ /(��|�\\|�O��)/){ return(); }
if($main::bbs{'concept'} =~ /Sousaku-mode/ && $thread{'subject'} =~ /(�C�W��|������|�s��|�Ղ�|�c��)/){ return(); }

# �t�@�C���ǂݍ���
open($ranking_handler,"<$file");

# �t�@�C�����b�N
if($type =~ /Renew/){ flock($ranking_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$ranking_handler>);
my($tkey,$tmin_count,$ti) = split(/<>/,$top1);

	# �o�^�����}�b�N�X�ŁA�V�K�L���̃J�E���g���������L���̂ǂ�ɂ��y�΂Ȃ��ꍇ�A�����Ƀ��^�[���i���׌y���j
	if($ti >= $max_line && $count <= $tmin_count){
		close($ranking_handler);
		return();
	}

	# �t�@�C����W�J
	while(<$ranking_handler>){

		# ���E���h�J�E���^
		$i++;

		# �s�𕪉�
		chomp;
		my($number2,$subject2,$count2,$post_handle2,$lasttime2,$last_handle2,$key2) = split(/<>/);

		# �ŏ��J�E���g�����L��
		if($type =~ /Renew/){
				if($keep_min_count > $count2 || $keep_min_count eq ""){ $keep_min_count = $count2; }
		}

			if($i > $max_line){
				$flow_flag = 1;
				next;
			}
			# �����L���̏ꍇ
			if($number2 eq $thread_number){
				$still_flag = 1;
				$count2 = $count;
			}
		push(@renew_line,"$number2<>$subject2<>$count2<>$post_handle2<>$lasttime2<><>$key2<>\n");
	}

close($ranking_handler);

	# �������L���O����o�����ꍇ�A�t�@�C�����X�V
	if($type =~ /Renew/){

			# �V�����ǉ�����s
			if(!$still_flag){ push(@renew_line,"$thread_number<>$thread{'subject'}<>$count<>$thread{'posthandle'}<>$main::time<>$thread{'key'}<>\n"); }

		# PV���������Ƀ\�[�g
		@renew_line = sort { (split(/<>/,$b))[2] <=> (split(/<>/,$a))[2] } @renew_line;

		# �g�b�v�f�[�^��ǉ�
		if($keep_min_count){ $tmin_count = $keep_min_count; }
		unshift(@renew_line,"1<>$tmin_count<>$i<>\n");

		# ��{�f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory);

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file,@renew_line);

	}

}


1;



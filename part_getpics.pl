
use Mebius::Basic;
use Mebius::Utility;
use Mebius::Paint;
package main;

#---------------------------------------------------------------------------
# �����X�^�[�g
#---------------------------------------------------------------------------
sub start{

my($init_directory) = Mebius::BaseInitDirectory();

# ���̃X�N���v�g
$scripto = 'getpics.cgi';

# ���ʂ̊Ǘ��p�X���[�h (�K�v�Ȃ�A�������͎g��CGI�ɂ���ĕς���΂���)
$mpass = 'dlh742ha';

# 1:�u���Ă���T�[�o�O����̓��e���֎~. (HTTP_REFERER���Ƃ��T�[�o�̂�)
$sotodame = 0;

# 1:�A�j���[�V�����̑��M�f�[�^�����E($maxpch)���z�����Ƃ��A�G���[������. 0:�j�����ē��e.
$pchoveralert = 0;

# 1:�T���l�C���摜�̑��M�f�[�^�����E($maxthm)���z�����Ƃ��A�G���[������. 0:�j�����ē��e.
$thmoveralert = 0;

# 1�ȏ�:�f�[�^�̓��e����byte�ȉ��������Ƃ��̓G���[������. 0:�g�p���Ȃ�
$errlength = 50;

# ���E�T�C�Y�𒴂����Ƃ��̃R�����g. (�� ����$overcom \n�T�C�Y�\��)
$overcom = "�f�[�^�̎�M�T�C�Y�������l�𒴂��܂����B\n�y�����邩�Ǘ��҂Ɋɘa�����߂邩���Ă��������B";

# �ēx���e���Ȃ������𑣂��R�����g
$resendcom = "\n�ēx���e���Ȃ����Ă݂ĉ������B";

# 1:����P�ƂŁA�ȈՓI�Ƀ��O��摜�EPCH�Ȃǂ�ۑ�������\���������肷��. 0:���Ȃ�.
$easysave = 0;

# �ȈՓI�ȃ��O�ł��낢�낳���郉�C�u����.
$getpicslib = 'getpics/getpics.pl';

# �ȈՓI�ȃ��O�������o���t�H���_ (�p�[�~�b�V����777. ���O����getpics.log)
$getpicsdir = 'getpics';

# CGI���Ƃ� �K �� �ɐݒ肵�Ă�������.
$mode = 'getpics';	# ���[�h(�Ⴆ��)
require "${init_directory}relm.ini";

# �f�[�^���o��
&getpics();

	# �����y�C���^�{�̂���̓��e�łȂ��ꍇ
	if($ENV{'HTTP_USER_AGENT'} && $ENV{'HTTP_USER_AGENT'} !~ /Shi-Painter/ && !$main::myadmin_flag){

		# �A�N�Z�X����
		my($none,$deny_flag) = &axscheck("LAG");
		if($deny_flag){ &alert_to("���e�������̂��ߑ��M�ł��܂���B"); }

	}

&saveimg();

# �摜�̏�������
&imgwrite();

	# �����y�C���^�{�̂���̓��e�łȂ��ꍇ
	if($ENV{'HTTP_USER_AGENT'} && $ENV{'HTTP_USER_AGENT'} !~ /Shi-Painter/ && !$main::myadmin_flag){

		# �A�����e�𐧌�
		if(!$exthead{'sasikae'}){
			my($redun_nexttime) = &redun("Paint-buffer Not-error",3*60,"","alert_to");
				if($redun_nexttime){ &alert_to("�A�����e�͏o���܂���B����$redun_nexttime�҂��Ă��������B$main::agent"); }
		}
	}

# ���������
undef $imgdata;
undef $pchdata;
undef $thmdata;
undef %ENV;

# �o�b�t�@���O(�ʃt�@�C���j�̏����o��
my(%image) = Mebius::Paint::Image("Image-post Renew-logfile-buffer Get-hash$plustype_image",$image_session,$image_id,%exthead);

# �o�b�t�@�ꗗ���X�V  �u��������`���v�Ń��O�t�@�C�����폜���Ȃ��ꍇ
require "${init_directory}part_newlist.pl";
Mebius::Newlist::Paint("Renew New Buffer",$image_session,$image_id,undef,$image{'super_id'});



# ����
print "Content-type: text/plain\n\n";
print "ok";
exit;

}

#-----------------------------------------------------------
##--> ���C���X�N���v�g
#-----------------------------------------------------------

sub getpics {


	# method=POST����Ȃ������ꍇ
	if($ENV{'REQUEST_METHOD'} !~ /^POST$/i){
		&alert_to('���\�b�h�uPOST�v�ȊO�̑��M�͂ł��܂���');
	}


	# STDIN ���o�C�i���ɂ���
	binmode STDIN;

	# ��M�����f�[�^�̒���
	local $c_length = $ENV{'CONTENT_LENGTH'};

	# $c_length ���� read() ��������.
	local $r_length = 0;

	# �f�[�^�ő�l���ݒ肳��ĂȂ��Ƃ�
	if($maximg eq ''){ $maximg = 200; }
	if($maxthm eq ''){ $maxthm =  50; }
	if($maxpch eq ''){ $maxpch = 200; }

	# format
	local ($first,$eh_length,$thm_length) = ();

	# ���O���Z���Ƃ��G���[�H
	if($errlength && $c_length < $errlength){
		&alert_to('�s���ȓ��e�ł�'.$resendcom);
	}

	# �O��URL����̓��e���֎~
	#{
	#	my $scr_url = $ENV{'SERVER_NAME'}.$ENV{'SCRIPT_NAME'};
	#	my $ref_url = $ENV{'HTTP_REFERER'};
	#	$scr_url =~ s/\/([^\/]*)$/\//;
	#	my $from = "\n('http://$scr_url' from '$ref_url')";
	#	if(!$scr_url && !$ref_url){
	#		&alert_to('�T�[�o���烊�t�@���[URL���擾�ł��܂���'.$from);
	#	}elsif($ref_url !~ /^http\:\/\/$scr_url/){
	#		&alert_to('�O������̓��e�͋֎~����Ă��܂�'."$ref_url - $scr_url");
	#	}
	#}
#read(STDIN,$first,100);
#alert_to($first);

	#--> �`�F�b�N -------------------------------------------------------
	# �ǂݍ��߂Ȃ������Ƃ�
	if(read(STDIN,$first,1) != 1) {
		&alert_to('STDIN ����ǂݍ��߂܂���ł���');
	}

	$c_length--;
	$r_length++;

	# �A�v���b�g�̔��f
	if($first =~ /^P/i){ $appdata = 'PaintBBS'; }	 # PaintBBS
	elsif($first =~ /^S|^n/){ $appdata = 'ShiPainter'; }     # ShiPainter�W��
	elsif($first =~ /^R|^s/){ $appdata = 'ShiPainterPro'; }  # ShiPainter�v��
	else{ &alert_to('�A�v���b�g�̔��f���ł��܂���ł���'); }	# �����ȊO

	#--> �g���w�b�_ -----------------------------------------------------
	# �g���w�b�_�̒���
	read(STDIN,$eh_length,8);
	$eh_length += 0;
	# �g���w�b�_
	if($eh_length > 0){
		read(STDIN,$exthead,$eh_length);
	}
	$c_length -= ($eh_length + 8);
	$r_length += 8 + length($exthead);
#		$ex=$exthead; $ex=~s/\&/\&\n/g; 	# exthead-check
#		$ex =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
#		&jcode'convert(*ex,'sjis'); &alert_to($ex);

	#--> �摜�f�[�^ -----------------------------------------------------
	# �摜�f�[�^�̒���
	read(STDIN,$imgsize,8);
	$imgsize += 0;

	# �摜�f�[�^�̃T�C�Y���ő�l�𒴂��Ă�Ƃ�. �Ȃ��Ƃ�.
	if($imgsize > $maximg*1024){
		local $ximgsize = int($imgsize*10/1024)/10;
		&alert_to("�摜$overcom\n$ximgsize / $maximg (send-kb / max-kb)");
	}elsif($imgsize <= 0){
		&alert_to("�摜�f�[�^������܂���");
	}

	# \r\n (CR LF)
	read(STDIN,$thm_length,2);

	# �摜�f�[�^
	if($imgsize > 0){
		read(STDIN,$imgdata,$imgsize);
	}
	$c_length -= ($imgsize + 10);
	$r_length += 10 + length($imgdata);

	#--> �T���l�C���EPCH�f�[�^ ------------------------------------------
	# ��ɂ܂������̃f�[�^������Ȃ�. ����1
	if(read(STDIN,$thm_length,8)){
		$thm_length += 0;
	 	if($thm_length > 0){
			read(STDIN,$thm_data1,$thm_length);
	 	}
		$c_length -= ($thm_length + 8);
		$r_length += 8 + length($thm_data1);
	}
	# ��ɂ܂������̃f�[�^������Ȃ�. ����2
	if(read(STDIN,$thm_length,8)){
		$thm_length += 0;
	 	if($thm_length > 0){
			read(STDIN,$thm_data2,$thm_length);
	 	}
		$c_length -= ($thm_length + 8);
		$r_length += 8 + length($thm_data2);
	}

	# �T���l�C��������Ȃ�
	if($thm_data1){
		# $thm_data1 �� �T���l�C���f�[�^ �Ȃ̂� PCH�f�[�^�Ȃ̂�
		if($thm_data1 =~ /^\xff\xd8\xff/ || $thm_data1 =~ /^\x89PNG\r\n\x1a/){
			$thmdata = $thm_data1;	# �T���l�C�� ������
			if($thm_data2){ $pchdata = $thm_data2; }	# $thm_data2��PCH
		}else{
			$pchdata = $thm_data1;	# PCH ������
			if($thm_data2){ $thmdata = $thm_data2; }	# $thm_data2�̓T���l�C��
		}
		# ���������
		undef $thm_data1;
		if($thm_data2){ undef $thm_data2; }
	}
	# �T���l�C���f�[�^�̃T�C�Y���ő�l�𒴂��Ă�Ƃ�
	if($thmdata && length($thmdata) > $maxthm*1024){
		if($thmoveralert==1){
			local $xthmsize = int((length($thmdata))*10/1024)/10;
			&alert_to("�T���l�C��$overcom\n$xthmsize/$maxthm(send-kb/max-kb)");
		}else{ $thmdata=''; }
	}
	# �A�j���[�V�����f�[�^�̃T�C�Y���ő�l�𒴂��Ă�Ƃ�
	if($pchdata && length($pchdata) > $maxpch*1024){
		if($pchoveralert==1){
			local $xpchsize = int((length($pchdata))*10/1024)/10;
			&alert_to("�A�j���[�V����$overcom\n$xpchsize/$maxpch(send-kb/max-kb)");
		}else{ $pchdata=''; }
	}


	#--> �ŏI�`�F�b�N ---------------------------------------------------
	# �ǂݍ��񂾃f�[�^�̃T�C�Y���ACONTENT_LENGTH �Ɠ�������Ȃ��Ƃ��G���[
	if($r_length ne $ENV{'CONTENT_LENGTH'}){
		&alert_to('���e�f�[�^������ɑ��M����܂���ł����B'.$resendcom);
	}
	undef $overcom;
	undef $resendcom;

	# ���O�L�^�p�ɕϐ����t�b�N
	$exthead{'image_size'} = $imgsize;
	$exthead{'samnale_size'} = length($thmdata);
	$exthead{'animation_size'} = $xpchsize;

}




#-----------------------------------------------------------------------
##--> �R�[��
#-----------------------------------------------------------
sub call {
	local @calls = @_;
	foreach $calz (@calls){ eval"\&$calz"; }
}


#-----------------------------------------------------------
##--> �G���[����
#-----------------------------------------------------------
sub alert_to {
	print "Content-type: text/plain\n\nerror\nERROR!!\n @_[0]";
	exit;
}

#--> relm.cgi - library2
$ver[2] = '2.35';

##--------------------##
##- ���G�`���󂯎�� -##
##--------------------##
sub saveimg {

# $appdata : �A�v���b�g�̎�� [PaintBBS,ShiPainter,ShiPainterPro] (�V)

	# �g���w�b�_��W�J
	our %ex;
	foreach $y (split(/\&/,$exthead)){
		my($yk,$yv) = split(/\=/,$y,2);
		($yv) = Mebius::escape("",$yv); 
		$yv =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$ex{$yk} = $yv;
		$exthead{$yk} = $ex{$yk};
	}

	# �Z�b�V���������Ȃ��ꍇ
	if($ex{'image_session'} eq ""){ &alert_to("���G����ID���w�肳��Ă��܂���B"); }

	# �Z�b�V���������烍�O�f�[�^���擾
	my(%image) = Mebius::Paint::Image("Get-hash",$ex{'image_session'});
	if(!$exthead{'sasikae'} && -f $image{'session_file_buffer'}){ &alert_to("���̂��G����ID - $ex{'image_session'} - �͊��Ɏg���Ă��܂��B�u���E�U�̃L���b�V�����c���Ă��邩������܂���B��ʍX�V�Ő���ɂȂ��\�\\��������܂��B"); }


	# �����ւ��֎~�̏ꍇ
	if($image{'deny_sasikae'} && $ex{'sasikae'}){ &alert_to("���̊G�͍����ւ��֎~����Ă��܂��B"); }

	# �^�C�g���̒����`�F�b�N
	if(length($ex{'image_title'}) >= 2*20){ &alert_to("�G�̃^�C�g���͍ő�20�����܂łł��B�i�S�p�j"); }

	# �R�[��_1
	if(@saveimg_call_1){ &call(@saveimg_call_1); }

	# str_header ���M�`�F�b�N
	if($ex{'loot'} eq 'sendcheck'){ &alert_to("str_header read ok."); }

	# �g���q
	if($ex{'image_type'} =~ /png/i){ $image_tail = 'png'; }	# PNG-IMAGE
	elsif($ex{'image_type'} =~ /jpeg/i){ $image_tail = 'jpg'; }	# JPG-IMAGE
	else{
		&alert_to("�摜�^�C�v���w�肳��Ă��܂���B");
		#if($imgdata =~ /^PNG/){ $ex{'ext'} = 'png'; }else{ $ex{'ext'} = 'jpg'; }
	}

	# PCH
	if($appdata =~ /ShiPainter/i){ $animation_tail ='spch'; }else{ $animation_tail ='pch'; }
	# THUMB
	if($ex{'thumbnail'} eq 'png'){ $samnale_tail ='png'; }else{ $samnale_tail ='jpg'; }

	# SIZE
	$ex{'imgs'} = $imgsize;

	# �R�[��_2
	if(@saveimg_call_2){ &call(@saveimg_call_2); }

	# �R�[��_1
	if(@logwrite_call_1){ &call(@logwrite_call_1); }

	# �X�e�b�v���̐���
	my($paint_need_steps);
	if($ex{'continue_type'}){ $paint_need_steps = 5; }
	elsif($main::myadmin_flag >= 5){ $paint_need_steps = 1; }
	else{ $paint_need_steps = 5; }
	if($ex{'count'} < $paint_need_steps){ &alert_to("�X�e�b�v�������Ȃ��Ĉꎞ�ۑ��ł��܂���B�i $ex{'count'}�X�e�b�v / $paint_need_steps�X�e�b�v�j"); }

	# ���Ԃ����܂肽���Ă��Ȃ��ꍇ
	my $paint_need_second = 1*60;
	if($ex{'continue_type'}){ $paint_need_second = 1*60; }
	if($main::myadmin_flag >= 5){ $paint_need_second = 1*3; }
	
	my $lefttime_paint2 = $paint_need_second - int($ex{'timer'} / 1000);
	if($lefttime_paint2 >= 1 && !Mebius::alocal_judge()){ &alert_to("���܂�Z�����Ԃł͊G���ꎞ�ۑ��ł��܂���B[A]�i����$lefttime_paint2�b�j"); }

	my $lefttime_paint = ($ex{'paintstarttime'} + $paint_need_second) - time;
	if($lefttime_paint >= 1 && !Mebius::alocal_judge()){ &alert_to("���܂�Z�����Ԃł͊G���ꎞ�ۑ��ł��܂���B[B]�i����$lefttime_paint�b�j"); }

	# �L�����o�X�T�C�Y�̈ᔽ�`�F�b�N
	my($error_flag_canvassize) = Mebius::Paint::Canvas_size("Violation-check",$ex{'width'},$ex{'height'});
	if($error_flag_canvassize){ &alert_to("$error_flag_canvassize"); }

return(%ex);

}


#-----------------------------------------------------------
##--> ���G�`���摜�f�[�^�����o��
#-----------------------------------------------------------
sub imgwrite{

my($basic_init) = Mebius::basic_init();
my $time = time;

	# �錾
	my($image_file,$samnale_file,$animation_file);
	our(%ex);

	# �R�[��
	if(@imgwrite_call){ &call(@imgwrite_call); }

	# �����_���t�@�C����
	our($image_id) = $time . int rand(999);
	our($image_session) = $ex{'image_session'};

	# �t�@�C����`
	$image_file = "$basic_init->{'paint_dir'}buffer/${image_id}.$image_tail";
	$samnale_file = "$basic_init->{'paint_dir'}buffer/${image_id}-samnale.$samnale_tail";
	$animation_file = "$basic_init->{'paint_dir'}buffer/${image_id}.$animation_tail";

	# �f�[�^�̗L�����`�F�b�N
	if(!$imgdata){ &alert_to("�摜�f�[�^������܂���B"); }
	if(!$thmdata){ &alert_to("�T���l�C���f�[�^�����M����Ă��܂���B"); }
	if(!$pchdata){ &alert_to("�A�j���[�V�����f�[�^�����M����Ă��܂���B"); }

	# �摜���̓�d�������݂�h�~
	if(-e $image_file){ &alert_to("���ɉ摜�����݂��܂��B"); }
	if(-e $samnale_file){ &alert_to("���ɃT���l�C�������݂��܂��B"); }
	if(-e $animation_file){ &alert_to("���ɃA�j���[�V�����f�[�^�����݂��܂��B"); }

	# �摜
	if($imgdata){
		if(open(SAVE,">$image_file")){
			binmode SAVE;
			print SAVE $imgdata;
			close SAVE;
		}else{ &alert_to("�摜�f�[�^���ۑ�����܂���ł����B"); }
	}

	# �T���l�C��
	if($thmdata){
		if(open(SAVE,">$samnale_file")){
			binmode SAVE;
			print SAVE $thmdata;
			close SAVE;
		}else{ &alert_to("�T���l�C���f�[�^���ۑ�����܂���ł����B"); }
	}

	# PCH
	if($pchdata){
		if(open(SAVE,">$animation_file")){
			binmode SAVE;
			print SAVE $pchdata;
			close SAVE;
		}else{ &alert_to("�A�j���[�V�����f�[�^���ۑ�����܂���ł����B"); }
	}

}


1;
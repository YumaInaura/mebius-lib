
use strict;
package main;

#-----------------------------------------------------------
# �Z�[�u�f�[�^�̌Ăяo��
#-----------------------------------------------------------
#sub call_savedata{

	# �f�[�^���Ȃ��ꍇ�A�o�b�N�A�b�v����J��
	#if($savedata_count < 1 && $soutoukou < 10 && $open){
	#	open(ACDATA_BAKUP_IN,"<",$backfile);
	#	my $top1 = <ACDATA_BAKUP_IN>; chomp $top1;
	#	my $top2 = <ACDATA_BAKUP_IN>; chomp $top2;
	#	if($top1){
	#	 ($nam,$gold,$soutoukou,$soumoji,$email,$follow,$up,$count,$color,$old,$posted,$news,$fontsize,$cut,$secret,$account,$pass,$image_link,$fillter_id,$fillter_account) = split(/<>/,$top1);
	#	($savedata_count,$none,$silver) = split(/<>/,$top2);
	#	}
	#	close(ACDATA_BAKUP_IN);
	#}



	# ���̂܂܃t�@�C�����X�V����ꍇ ( ���̏�������f�[�^���e��ύX )
	#if($type =~ /RENEW/){
	#		if(!$open){ main::error("���̑���͑��݂��܂���B"); }
	#	my(@line);
	#	my($pgold,$pmessage) = split(/<>/,$renewdata);
	#	$gold += $pgold;
	#		if($pmessage){ $message = $pmessage; }
	#	push(@line,"$nam<>$gold<>$soutoukou<>$soumoji<>$email<>$follow<>$up<>$count<>$color<>$old<>$posted<>$news<>$fontsize<>$cut<>$secret<>$account<>$pass<>$image_link<>$fillter_id<>\n");
	#	push(@line,"$savedata_count<><>$silver<>\n");
	#	Mebius::Fileout("",$savefile,@line);
			#if($type =~ /MESSAGE/){
			#	&call_savedata_message("$type RENEW MESSAGE",$file,$k_access,$pmessage); # ���b�Z�[�W�t�@�C�����X�V
			#}
	#	return(1);
	#}

	# ���b�Z�[�W�t�@�C�����擾�A$cmessage�Ƀ��b�Z�[�W����(1�s)
	#if($type =~ /MYDATA/){
	#	our($cmessage) = &call_savedata_message("$type ONELINE",$file,$k_access,$pmessage);
	#}

	# �Ǘ����[�h�ł̓��^�[��
	#if($admin_mode){ return($top1,$nam,$gold,$soutoukou,$soumoji,$email,$follow,$up,$count,$color,$old,$posted,$news,$fontsize,$cut,$secret,$account,$pass,$image_link,$fillter_id,$fillter_account);
	#}

	# ���N�b�L�[���t�b�N
	#if($type =~ /MYDATA/){
	#	if(!$callsave_flag){
	#		our($recgold,$recsoumoji,$recsoutoukou,$recfollow) = ($cgold,$csoumoji,$csoutoukou,$cfollow);
	#	}
	#}

	# ���ʂ̃N�b�L�[����̏ꍇ�A�Z�[�u�f�[�^������
	#if($type =~ /MYDATA/){
	#		if($cnam eq ""){ $cnam = $nam; }
	#		if($cemail eq ""){ $cemail = $email; }
	#		if($cup eq ""){ $cup = $up; }
	#		if($ccolor eq ""){ $ccolor = $color; }
	#		if($cage eq ""){ $cage = $old; }
	#		if($cposted eq ""){ $cposted = $posted; }
	#		if($cnews eq ""){ $cnews = $news; }
	#		if($cfontsize eq ""){ $cfontsize = $fontsize; }
	#		if($csecret eq ""){ $csecret = $secret; }
	#		if($ccut eq ""){ $ccut = $cut; }
	#		if($cfillter_id eq ""){ $cfillter_id = $fillter_id; }
	#		if($cfillter_account eq ""){ $cfillter_account = $fillter_account; }
	#}

	# �Z�[�u�f�[�^�Ǝ��̋[���N�b�L�[(�Z�b�V���������̃f�[�^)���`
	#if($type =~ /MYDATA/){ $csavedata_count = $savedata_count; }

	# ���o�C���̃��O�C����Ԃ��擾
	#if($type =~ /MYDATA/){
	#	if($type =~ /MOBILE/){
	#		if($caccount eq ""){ $caccount = $account; }
	#		if($cpass eq ""){ $cpass = $pass; }
	#	$ccount = $count;
	#	}
	#}

# �t�H���[�̈��p���Ƒ��
	#if($type =~ /MYDATA/){
	#		if($follow eq "" && $cfollow){
	#			my(@keep_follow);
	#				foreach(split(/ /,$cfollow)){
	#					my($type,$value) = split(/=/);
	#					if($type eq "bbs" && $value !~ /^sc/){ push(@keep_follow,$_); }
	#				}
	#			$cfollow = "@keep_follow";
	#		}
	#		else{ $cfollow = $follow; }
	#}

# ���� / ���e�� �̈��p���Ƒ��
	#if($type =~ /MYDATA/){
	#		if($soutoukou eq "" && $csoutoukou){
	#				if(!$callsave_mobile_flag && $type =~ /ACCOUNT/){
	#				if($cgold > 100){ $cgold = 100; }
	#				if($csoutoukou > 1000){ $csoutoukou = 1000; }
	#				if($csoumoji > 100000){ $csoumoji = 100000; }
	#		}
	#		}
	#		else{
	#			$cgold = $gold;
	#			$csoutoukou = $soutoukou;
	#			$csoumoji = $soumoji;
	#		}
	#}

	# ��݂��� ( N ���ݑ���̌� )
	#if($silver eq ""){ $csilver = $cgold; }
	#else{ $csilver = $silver; }

# �t���O�𗧂Ă�
	#if($type =~ /MYDATA/){
	#	$callsave_flag = 1;
	#		if($type =~ /ACCOUNT/){ $callsave_account_flag = 1; }
	#		elsif($type =~ /MOBILE/){ $callsave_mobile_flag = 1; }
	#}

#}

#-----------------------------------------------------------
# �Z�[�u�f�[�^�̍X�V ( ���݂� ��g�p)
#-----------------------------------------------------------
sub push_savedata{

# �錾
my($file,$type,$k_access,$cnam,$cposted,$cpwd,$ccolor,$cup,$ccount,$cnew_time,$cres_time,$cgold,$csoumoji,$csoutoukou,$cfontsize,$cfollow,$cview,$cnumber,$crireki,$ccut,$cmemo_time,$caccount,$cpass,$cdelres,$cnews,$cage,$cemail,$csecret,$cres_waitsecond,$caccount_link,$cimage_link,$cfillter_id,$cfillter_account) = @_;
my($line,$savefile,$backfile);
our($csavedata_count,$csilver,$int_dir);

# �����`�F�b�N
$file =~ s/\W//;
if($file eq ""){ return; }

# �J�E���g�񐔂𑝂₷
$csavedata_count++;

# �X�V����s
$line .= qq($cnam<>$cgold<>$csoutoukou<>$csoumoji<>$cemail<>$cfollow<>$cup<>$ccount<>$ccolor<>$cage<>$cposted<>$cnews<>$cfontsize<>$ccut<>$csecret<>$caccount<>$cpass<>$cimage_link<>$cfillter_id<>$cfillter_account<>\n);
$line .= qq($csavedata_count<><>$csilver<>\n);

	# �t�@�C����` �� �ǉ�����s ( �A�J�E���g )
	if($type =~ /ACCOUNT/){
		$savefile = "${int_dir}_save_account/${file}_save_account.cgi";
		#$backfile = "${int_dir}_backup/_save_account/${file}_save_account.cgi";
	}

	# �t�@�C����` �� �ǉ�����s ( ���o�C�� )
	elsif($type =~ /MOBILE/ && $k_access){
		$savefile = "${int_dir}_save_mobile/${file}_save_${k_access}.cgi"; 
		#$backfile = "${int_dir}_backup/_save_mobile/${file}_save_account.cgi";
	}
	else{ return; }

# �t�@�C�����쐬
Mebius::Fileout("",$savefile,$line);

	# �o�b�N�A�b�v���쐬
	#if(rand(25) < 1){ Mebius::Fileout("",$backfile,$line); }

}

#-----------------------------------------------------------
# ���b�Z�[�W�L�^�t�@�C�����擾 / �X�V ( ���݂͖��g�p => ���݂̎󂯓n���p? )
#-----------------------------------------------------------
sub call_savedata_message{

# �錾
my($type,$file,$k_access,$message,$maxview_index) = @_;
my($savefile,$filehandle1,$filehandle2,$top,@line,$i,$oneline_message,$index_line);
my($derenew_flag,$index_flow,$max_message);
my($time) = (time);

# �����`�F�b�N
$file =~ s/\W//;
if($file eq ""){ return; }

# �ő僁�b�Z�[�W��
$max_message = 10;

# �ݒ�
if(!$maxview_index){ $maxview_index = 5; }	# �C���f�b�N�X�̍ő�\���s��

	# �t�@�C����` �i �A�J�E���g �j
	if($type =~ /ACCOUNT/){
$savefile = "${main::int_dir}_save_account_message/${file}_message_account.log";
	}

	# �t�@�C����` �i ���o�C�� �j
	elsif($type =~ /MOBILE/ && $k_access){
$savefile = "${main::int_dir}_save_mobile_message/${file}_message_${k_access}.log";
	}

	# �^�C�v��`���Ȃ��ꍇ
	else{ return; }

# �ǉ�����s
	if($type =~ /RENEW/ && $type =~ /MESSAGE/){
push(@line,"1<>$message<>$main::pmfile<>$main::date<>$main::time<>\n");
	}

# �t�@�C�����J��
open($filehandle1,"<$savefile");
if($type =~ /RENEW/){ flock($filehandle1,1); }

# �g�b�v�f�[�^�𕪉�
$top = <$filehandle1>; chomp $top;
my($tkey,$tlasttime,$tchecktime) = split(/<>/,$top);
if($tkey eq ""){ $tkey = 1; }

# �`�F�b�N���Ԃ��ŋ߂̏ꍇ��A�`���ȏ�̃��b�Z�[�W�̓��^�[��
	if($type =~ /ONELINE/){
		if($tchecktime && $tchecktime >= $tlasttime){ return(); }
		if($main::time > $tlasttime + 2*24*60*60){ return(); }
	}

# �`�F�b�N���Ԃ��X�V����ꍇ / ���Ȃ��ꍇ
	if($type =~ /CHECK/ && $type =~ /RENEW/){
		if($tchecktime >= $tlasttime){ $derenew_flag = 1; }
		$tchecktime = $main::time;
	}

# ���b�Z�[�W�X�V�̏ꍇ
	if($type =~ /MESSAGE/ && $type =~ /RENEW/){
		$tlasttime = $main::time;
	}

# �g�b�v�f�[�^��ǉ�
unshift(@line,"$tkey<>$tlasttime<>$tchecktime<>\n");

# �t�@�C����W�J
while(<$filehandle1>){
$i++;
chomp;
	if($i > $max_message){ $index_flow = 1; next; }
my($key2,$message2,$account2,$date2,$time2) = split(/<>/,$_);

	# ��莞�Ԉȏオ�o�߂��Ă���ꍇ�A�\��/�L�^���Ȃ�
	if($time > $time2 + 7*24*60*60){ next; }

	# �{���s
	if($type =~ /INDEX/ && $i <= $maxview_index){
$index_line .= qq(<tr><td>$message2</td><td>$date2</td></tr>);
	}

	# �P�s�X�V
	if($type =~ /ONELINE/ && !$oneline_message){ $oneline_message = $message2; }

	# �X�V�s��ǉ�
	if($type =~ /RENEW/){ push(@line,"$_\n"); }
}
close($filehandle1);

	# �t�@�C�����X�V
	if($type =~ /RENEW/ && !$derenew_flag){
		Mebius::Fileout("",$savefile,@line);
	}

# �C���f�b�N�X�\���𐮌`
	if($type =~ /INDEX/ && $index_line){
$index_line = qq(<table summary="���b�Z�[�W�ꗗ">$index_line</table>);
return($index_line,$index_flow);
	}

# ���^�[��
return($oneline_message);

}

1;



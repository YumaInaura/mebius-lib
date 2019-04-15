
use strict;
use Mebius::Referer;
use Mebius::Getstatus;
use Mebius::BBS;
package main;

#-----------------------------------------------------------
# �u���������N�؂�C���̃��_�C���N�g�����v�̂��߂̔��菈��
#-----------------------------------------------------------
sub get_repairform{

# �Ǐ���
my($type) = @_;
my($form,$hit,$domain,$redirected_flag,$repair_url,$enc_repair_url,$enc_unwork_url);
my($unwork_url,$referer_type,$referer_domain);
our($alocal_mode,$referer,$css_text,@domains,$myadmin_flag,$k_access,$date,$selfurl);

# ��̓I�ȁu�����N�؂�y�[�W�v�̎w�肪�Ȃ��ꍇ�AREQUEST_URL ����������
if($unwork_url eq "" && $selfurl){ $unwork_url = $selfurl; }

# �e�탊�^�[��
if($referer eq ""){ return(); }
if($unwork_url eq ""){ return(); }

	# ���t�@�����t�q�k�̃h���C���`�F�b�N
	# �� ���t�@�����t�q�k���C���Ώۂ̃t�@�C�����ǂ����𔻒�
	($referer_type,$referer_domain) = Mebius::Referer("Type",$referer);

	# URL�����K�̂��̂łȂ������ꍇ�A���^�[�����ĕ��ʂɃG���[��\��
	if($referer_type !~ /bbs-thread/){ return(); }

# ����
$repair_url = $referer;

# URL �̃G���R�[�h
($enc_repair_url) = Mebius::Encode("",$repair_url);
($enc_unwork_url) = Mebius::Encode("",$unwork_url);

	# ���_�C���N�g�i���������N�؂�C���j
	if(!$k_access && $unwork_url && $repair_url){

		my $redirect_url = "http://$referer_domain/_main/?mode=repairurl&repair_url=$enc_repair_url&unwork_url=$enc_unwork_url&action=1&redirect=1";
		($redirected_flag) = &repair_redirect($type,$redirect_url,$repair_url,$unwork_url);
	}

	# �Ǘ��ҕ\���̃e�L�X�g
	my($navigation_text,$method);
		if($myadmin_flag >= 5 && !$redirected_flag){
		$navigation_text .= qq(<br><br>);
		$navigation_text .= qq($date<br><br>);
		if($redirected_flag){ $navigation_text .= qq(<strong class="red">���_�C���N�g���u���b�N���܂����B</strong><br>); }
		if($referer){ $navigation_text .= qq(<strong class="red">���t�@���i���y�[�W�j�F $referer</strong><br>); }
		$navigation_text .= qq(<strong class="red">�t�q�k�i�����N�؂�j�F $unwork_url</strong><br>);
		$navigation_text .= qq(<strong class="red">���_�C���N�g��F http://$domain/_main/?mode=repairurl&repair_url=$enc_repair_url&unwork_url=$enc_unwork_url&action=1&redirect=1</strong><br>);
	}

return();

}

#-----------------------------------------------------------
# ���������N�؂�C���y�[�W�Ƀ��_�C���N�g
#-----------------------------------------------------------
sub repair_redirect{

# �Ǐ���
my($type,$redirect_url,$repair_url,$unwork_url) = @_;
my($line,$i,$file,$flag,$repair_history_handler,$blank);
our($time,$int_dir,$head_javascript,$myadmin_flag,$alocal_mode);

# �����t�@�C��
$file = "${int_dir}_backup/repair_redirect_history.cgi";

# �ǉ�����s
$line .= qq($repair_url<>$time<>\n);

	# ����t�q�k���ɑ΂��ẮA���_�C���N�g�̃u�����N
	if($alocal_mode){ $blank = 10 ; }
	elsif($myadmin_flag){ $blank = 2; }
	else{ $blank = 5; }

# ���_�C���N�g�������J���A�ŋ߂̗���������ꍇ�̓��_�C���N�g�����
open($repair_history_handler,"$file");
	while(<$repair_history_handler>){
		$i++;
		chomp;
		my($repairurl2,$lasttime) = split(/<>/);
		if($lasttime + 2 >= $time){ $flag = 1; }
		if($repairurl2 eq $repair_url && $lasttime + $blank >= $time){ $flag = 1; }
		if($i < 10){ $line .= qq($repairurl2<>$lasttime<>\n); }
	}
close($repair_history_handler);

# ���_�C���N�g�������X�V
if(!$flag){ Mebius::Fileout("",$file,$line); }

	# ���_�C���N�g��ݒ�
	if(!$flag){

		# Javascript�Ń��_�C���N�g������ꍇ
		if($type =~ /Javascript/){
			$head_javascript .= qq(
			<script type="text/javascript">
			<!--
			setTimeout("link()", 0);
			function link(){
			var url = ('$redirect_url');
			location.href=(url);
			}
			-->
			</script>
			);
		}

		# CGI�Ń��_�C���N�g������ꍇ
		else{
			Mebius::Redirect("",$redirect_url);
		}
	}

return($flag);

}

#-----------------------------------------------------------
# �����N�؂�C�� ( �S�Ă� get���M ���画�� )
#-----------------------------------------------------------
sub main_repairurl{

# �Ǐ���
my($repair_domain,$unwork_original_url);
my($repair_type,$ad_url,$unwork_url_descape);
my($repair_url,$unwork_url,$analyze_error,$unwork_flag,$unwork_type);
our(%in,$auth_url,$myadmin_flag);

# �����N��A�����N���̂t�q�k���`
$repair_url = $in{'repair_url'};
$unwork_url = $unwork_original_url = $in{'unwork_url'};

# ���s���ɊǗ��҂ɕ\��������
if($myadmin_flag >= 5){ $analyze_error = qq(Repair-url $repair_url / Unwork-url $unwork_url); }

	# �����N�؂�t�q�k�̃X�e�[�^�X�R�[�h���`�F�b�N
	my($status) = Mebius::Getstatus("",$unwork_url);
	if($status eq "404" || $status eq "403" || $status eq "410"){ $unwork_flag = 1; }
	else{ &rperror("���̂t�q�k ( $unwork_url ) �̓����N�؂ꂵ�Ă��܂���B$status $analyze_error",$unwork_url); }

	# ���y�[�W�̂t�q�k�^�C�v�𔻒肵�ďC��������
	my($repair_type_buf) = Mebius::Referer("Type",$repair_url);
	if($repair_type_buf =~ /bbs-thread/){ &repair_boad("",$repair_url,$unwork_url); }													# �f���̋L�����C��
	else{ main::error("���y�[�W�̂t�q�k���s���ł��B$analyze_error",$unwork_url); }		# �C���^�C�v���Ȃ��ꍇ

# ���������ꍇ�A�����N�؂�y�[�W�Ƀ��_�C���N�g
Mebius::Redirect("",$unwork_original_url);

exit;

}

#-----------------------------------------------------------
# �f���L���̃����N�؂���C��
#-----------------------------------------------------------
sub repair_boad{

# �Ǐ���
my($type,$repair_url,$unwork_url) = @_;
my($change,$line,$rpkr_flag,@krline,$saveline,$plus,$thread_handler);
my($kr_handler,$threadfile,$krfile,$savefile,$repair_resnumber_flag,@renew_line);
my($init_directory) = Mebius::BaseInitDirectory();

# �����N�؂�t�q�k�̃^�C�v���擾(���X�ԏC���p)
my($unwork_type,$unwork_domain,$unwork_moto,$unwork_no,$unwork_resnumber) = Mebius::Referer("Type",$unwork_url);

# �f���L���̔ԍ��Ȃǂ��擾
my($repair_type_buf,$repair_domain,$repair_moto,$repair_no,$repair_resnumber) = Mebius::Referer("Type",$repair_url);

	# �C�����ƏC����̂t�q�k�������ꍇ�A���X�ԏC�����[�h�𔭓�
	if($unwork_resnumber ne "" && $repair_domain eq $unwork_domain && $repair_moto eq $unwork_moto && $repair_no eq $unwork_no){
		$repair_resnumber_flag = 1;
	}

# �����`�F�b�N
$repair_moto =~ s/\W//g;
$repair_no =~ s/\D//g;
$repair_resnumber =~ s/\D//g;
if($repair_moto eq ""){ return(); }
if($repair_no eq ""){ return(); }

# �f���p�̃t�@�C�������擾
my($bbs_file) = Mebius::BBS::InitFileName(undef,$repair_moto);

# �t�@�C����`
my($threadfile) = Mebius::BBS::path({ Target => "thread_file" },$repair_moto,$repair_no);
	if(!$threadfile){ &rperror("�C����̋L�����ݒ�ł��܂���B",$unwork_url); }

$krfile = "$bbs_file->{'data_directory'}_kr_$repair_moto/${repair_no}_kr.cgi";
#$savefile = "${init_directory}_backup/_repairurl/${repair_moto}-${repair_no}-repairurl.cgi";

# ���b�N�J�n
&lock($repair_moto);

# ���f���̋L�����J��
open($thread_handler,"+<",$threadfile) || &rperror("�C����̃y�[�W��������܂���B",$unwork_url) ;
flock($thread_handler,2);

# �g�b�v�f�[�^�̏���
chomp(my $top = <$thread_handler>);
$saveline .= qq($top\n);
my($no,$sub,$res,$key,$res_pwd,$t_res,$d_delman,$d_password,$dd1,$sexvio,$dd3,$dd4,$memo_editor,$memo_body,$dd7,$dd8,$juufuku_com,$posttime) = split(/<>/,$top);

	if($key eq "4" || $key eq "6" || $key eq "7"){
		close($thread_handler);
		&rperror("���y�[�W���폜�ς݂̂��߁A���s�ł��܂���ł����B",$unwork_url);
	}

# �L���������C��
($memo_body,$plus) = &repair_auto("",$memo_body,$unwork_url);
$change += $plus;
	#if($repair_resnumber_flag){ ($memo_body,$plus) = &repair_resnumber_auto("",$memo_body,$unwork_resnumber); }
$change += $plus;

# �g�b�v�f�[�^��ǉ�
push @renew_line ,  qq($no<>$sub<>$res<>$key<>$res_pwd<>$t_res<>$d_delman<>$d_password<>$dd1<>$sexvio<>$dd3<>$dd4<>$memo_editor<>$memo_body<>$dd7<>$dd8<>$juufuku_com<>$posttime<>\n);

	# �L����W�J
	while(<$thread_handler>){
		$saveline .= $_;
		chomp;
		my($resnum,$number,$name,$trip,$com,$dat,$ho,$id,$color,$agent,$user,$deleted,$account,$image_data,$res_concept,$regist_time2,@other_data2) = split(/<>/);
		my($com,$plus) = &repair_auto("Strike",$com,$unwork_url);

		$change += $plus;
		#if($repair_resnumber_flag){ ($com,$plus) = &repair_resnumber_auto("",$com,$unwork_resnumber); } 
		$change += $plus;
		push @renew_line , Mebius::add_line_for_file([$resnum,$number,$name,$trip,$com,$dat,$ho,$id,$color,$agent,$user,$deleted,$account,$image_data,$res_concept,$regist_time2,@other_data2]);
	}

	# �t�@�C���X�V
	if($change){
		seek($thread_handler,0,0);
		truncate($thread_handler,tell($thread_handler));
		print $thread_handler @renew_line;
	}

close($thread_handler);

	# �p�[�~�b�V�����ύX
	if($change){
		Mebius::Chmod(undef,$threadfile);
	}

# ���֘A�L���t�@�C�����J��
open($kr_handler,"<$krfile");
flock($kr_handler,1);
	while(<$kr_handler>){
		chomp;
		my($no2,$moto2,$sub2,$domain2,$num2) = split(/<>/);
		if($no2 == $unwork_no && $moto2 eq $unwork_moto){ $change++; next; }
		push(@krline,"$no2<>$moto2<>$sub2<>$domain2<>$num2<>\n");
	}
close($kr_handler);

# �ύX�_�����������ꍇ
if(!$change){ &rperror("���y�[�W���Ƀ����N�؂ꂪ���݂��Ȃ����A���ɏC���ς݂ł��B<a href=\"$repair_url\">�����̃y�[�W��</a>",$unwork_url); }

# �L���̃o�b�N�A�b�v���X�V
#Mebius::Fileout("",$savefile,$saveline);

# �֘A�L���t�@�C�����X�V
Mebius::Fileout("Allow-empty","$krfile",@krline);

# �C���������X�V
&access_log("Repair-url","���y�[�W�F $repair_url<br>�����N�؂�t�q�k�F $unwork_url");

# ���b�N����
&unlock($repair_moto);

# ���^�[��
return($line);

}

#-----------------------------------------------------------
# �t�q�k�C�������s
#-----------------------------------------------------------
sub repair_auto{

# �錾
my($type,$data_body,$unwork_url) = @_;
my($changed_num,$change_unwork_url,$deltag1,$deltag2,$notslash_url,$slash);

# http / ttp �̏����𒲐�
$unwork_url =~ s/^http//g;

# �����X���b�V���̏���
$notslash_url = $unwork_url;
$slash = ($notslash_url =~ s/\/$//g);

# �C���ՂɎ�������������ꍇ
if($type =~ /Strike/){ ($deltag1,$deltag2) = ("<del>","</del>"); }

# �����N���C��
$changed_num += ($data_body =~ s/([^=^\"]|^)http\Q$unwork_url\E(#[a-zA-Z0-9]+|)([^a-z0-9_\.\/\?]+|$)/$1${deltag1}ttp$unwork_url${2}${deltag2}${3}/g);


	# �X���b�V���̏���
	if($slash && !$changed_num){
$changed_num += ($data_body =~ s/([^=^\"]|^)http$notslash_url(#[a-zA-Z0-9]+|)([^a-z0-9_\.\/\?]+|$)/$1${deltag1}ttp$notslash_url${2}${deltag2}${3}/g);
	}

return($data_body,$changed_num);
}


#-----------------------------------------------------------
# ���X�Ԃ̏C��
#-----------------------------------------------------------
#sub repair_resnumber_auto{

# �錾
#my($type,$data_body,$resnumber) = @_;
#my($changed_num);

# �����`�F�b�N
#$resnumber =~ s/\D//g;
#if($resnumber eq ""){ return(); }

# ���X�Ԃ��C��
#$changed_num += ($data_body =~ s/No\.($resnumber)([^0-9,\-]|$)/&gt;&gt;$1$2/g);

#return($data_body,$changed_num);

#}


#-----------------------------------------------------------
# �t�q�k�C���Ɏ��s�����ꍇ
#-----------------------------------------------------------
sub rperror{

# �Ǐ���
my($error,$redirect_url) = @_;
my($url_type);
our($lockflag,$myadmin_flag);

# �G���[���A�����b�N
if($lockflag) { &unlock($lockflag); }

# ���O���L�^
main::access_log("Missed-repair-url","���y�[�W�F $main::in{'repair_url'} / �����N�؂�y�[�W�F $redirect_url"); 

# ���_�C���N�g��̂t�q�k���`�F�b�N
my($url_type) = Mebius::Referer("",$redirect_url);

# �G���[��\������ꍇ
if($myadmin_flag >= 5 || $url_type !~ /mydomain/){ &error($error); }

# ���y�[�W�Ƀ��_�C���N�g���Ė߂�
else{ Mebius::Redirect("",$redirect_url); }

}



1;

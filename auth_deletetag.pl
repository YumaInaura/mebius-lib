
package main;

#-----------------------------------------------------------
# �r�m�r�^�O�̍폜
#-----------------------------------------------------------
sub auth_deletetag{

# �Ǐ���
my($type,$file,$maxtag,$max_comment) = @_;
my($line,$line2,$i,$flag,$filehandle1);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# �t�@�C���I�[�v��
&open($file);

# �L�[���[�h�̃G���R�[�h
$enc_tag = Mebius::Encode("",$submode3);

# �e��G���[
if(!$myprof_flag && !$myadmin_flag){ &error("�������o�[�̃^�O�͍폜�ł��܂���B"); }
if($enc_tag eq ""){ &error("�폜����L�[���[�h���w�肵�Ă��������B"); }

# ���b�N�J�n
&lock("auth$file") if($lockkey);

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �}�C�^�O�t�@�C�����J��
my $openfile1 = "${account_directory}${file}_tag.cgi";
open(MYTAG_IN,"<","$openfile1");
while(<MYTAG_IN>){
my($key2,$tag2) = split(/<>/,$_);
if($tag2 eq $submode3){ $flag = 1; next; }
$line .= $_;
}
close(MYTAG_IN);

# �}�C�^�O�t�@�C������������
Mebius::Fileout(undef,$openfile1,$line);

# ���b�N����
&unlock("auth$file") if($lockkey);

# ���b�N�J�n
&lock("tag$enc_tag") if($lockkey);

# �L�[���[�h�t�@�C�����J��
my($i_wordfile);
my $openfile2 = "${auth_log_directory}_tag/$enc_tag.cgi";
open($filehandle1,"<","$openfile2");
	while(<$filehandle1>){
	my($deleter);
	my($key,$account,$name,$comment,$deleter) = split(/<>/,$_);


		# �폜�������s���q�b�g�����ꍇ
		if($account eq $file){

			$flag = 1; 

			# �Ǘ��ҍ폜�̏ꍇ�A�y�i���e�B��ǉ�
			if($myadmin_flag && $in{'penalty'}){
				Mebius::Authpenalty("Penalty",$account,$comment,"SNS�^�O - $submode3");
				# SNS�y�i���e�B
				Mebius::AuthPenaltyOption("Penalty",$account,6*60*60);
			}

				next;

		}

	$line2 .= $_;
	$i_wordfile++;
	}
close($filehandle1);

# �L�[���[�h�t�@�C������������
Mebius::Fileout("",$openfile2,$line2);

# ���b�N����
&unlock("tag$enc_tag") if($lockkey);

# �s���Ȃ��Ȃ����ꍇ�A�S�^�O�t�@�C������폜
if(!$i_wordfile){ &delete_alltag; }

# ���b�N�J�n
&lock("newtag") if($lockkey);

# �V���^�O�t�@�C�����J��
my $openfile3 = "${auth_log_directory}newtag.cgi";
open(NEWTAG_IN,"$openfile3");
while(<NEWTAG_IN>){
chomp $_;
my($notice,$tag,$account) = split(/<>/,$_);
if($notice < 5 && $file eq $account && $tag eq $submode3){ next; }
$line3 .= qq($notice<>$tag<>$account<>\n);
}
close(NEWTAG_IN);

# �V���^�O�t�@�C������������
open(NEWTAG_OUT,">","$openfile3");
print NEWTAG_OUT $line3;
close(NEWTAG_OUT);
Mebius::Chmod(undef,$openfile3);

# ���b�N����
&unlock("newtag") if($lockkey);


# �폜�Ώۂ����݂��Ȃ������ꍇ
if(!$flag){ &error("�폜�ł��܂���ł����B���ɍ폜�ς݂��A�o�^�̂Ȃ��L�[���[�h�ł��B"); }

if($myadmin_flag){ Mebius::Redirect("","${auth_url}tag-word-$enc_tag.html"); }

# �y�[�W�W�����v
$jump_sec = $auth_jump;
$jump_url = "${file}/tag-view";
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }


my $print = qq(
�^�O���폜���܂����i<a href="$jump_url">���^�O�o�^�y�[�W��</a>�j�B<br>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# �S�^�O�t�@�C�����X�V
#-----------------------------------------------------------
sub delete_alltag{

# �Ǐ���
my($line4);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# ���b�N�J�n
&lock("alltag") if($lockkey);

# �S�^�O�t�@�C�����J��
my $openfile4 = "${$auth_log_directory}alltag.cgi";
open(ALLTAG_IN,"<",$openfile4);
	while(<ALLTAG_IN>){
		chomp;
			if($_ eq $submode3){ next; }
		$line4 .= qq($_\n);
	}
close(ALLTAG_IN);

# �S�^�O�t�@�C������������
open(ALLTAG_OUT,">",$openfile4);
print ALLTAG_OUT $line4;
close(ALLTAG_OUT);
Mebius::Chmod(undef,$openfile4);

# ���b�N����
&unlock("alltag") if($lockkey);

}

1;


#-----------------------------------------------------------
# �폜����
#-----------------------------------------------------------
sub do_oldremove{

# �錾
my($type,$directory,$unlink_time,$random) = @_;
my($file,$check,$dot_number,$hit,$unlink_files,@filelist);


# ���m���Ŏ��s����ꍇ ( $random ��� 1�� �̊m�� )
	if($random && rand($random) < 1){ return; }

# �����`�F�b�N�ƃ��^�[��
$directory =~ s/\/$//g;
	if($directory eq ""){ return; }
	if($directory =~ /^\//){ return; }
$dot_number =~ ($directory =~ s/\.\.\//$&/g);
	if($dot_number >= 4){ return; }
$unlink_time =~ s/[^0-9\.]//;
	if($unlink_time eq ""){ return; }

# �t�@�C���ꗗ���擾
opendir(DIR,"$directory") or return();
@filelist = grep(/([a-z])/,readdir(DIR));
close DIR;

# �t�@�C����W�J
foreach $file (@filelist) {
	# �f�B���N�g�����G�X�P�[�v
	if(-d $file){ next; }
	# ����̊g���q�݂̂��폜�Ώۂ�
	if($file !~ /\.(log|cgi)$/){ next; }
	# �t�@�C���̍ŏI�X�V�����`���ȏ�O�ł���΁A�t�@�C�����폜
	if (-M "$directory/$file" >= $unlink_time) {
unlink("$directory/$file");
$unlink_files .= qq($file / );
$hit++;
	}
}

# �A�N�Z�X���O���L�^
&access_log("OLDREMOVE","$hit �t�@�C�����폜	Dir: $directory		Files: $unlink_files");

# ���^�[��
return($hit,$unlink_files);

}

1;

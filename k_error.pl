use Mebius::Export;

#-----------------------------------------------------------
# �g�єŃG���[
#-----------------------------------------------------------
sub do_kerror{

# �錾
my($error,$code) = @_;
our($mobile_error_done,$no_headerset,$headflag,$status_flag);

	# �R�[�h�����ϊ�
	g_shift_jis($error);

# �N�b�L�[�̏d���Z�b�g�����
$no_headerset = 1;

# �G���[���A�����b�N
if($lockflag) { &unlock($lockflag); }

	# ��d�������֎~
	if($mobile_error_done){
		print "Content-type:text/html\n\n";
		print "error double";
		exit;
	}
	$mobile_error_done = 1;

# �X�e�[�^�X�R�[�h
if(!$headflag && !$status_flag){
if($k_access || $code eq "none"){}
elsif($code){ print "Status: $code\n"; }
else{ print "Status: 404 NotFound\n"; }
$status_flag = 1;
}

# �^�C�g����`
$sub_title = "�G���[";

# �߂��
if($in{'no'} && $nowfile){ $kback_link = "$in{'no'}.html"; }

# �g�уA�C�e�����擾
&kget_items();

# HTML
my $print = qq(�G���[�F <br$xclose>$error $code<br$xclose>);

# POST���e���t�b�N
my $comment = $in{'comment'};
$comment =~ s/<br>/<br$xclose>/g;
if($in{'comment'}){ print qq(<hr$xclose>�{���F<br$xclose>$comment); }

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

1;


use Mebius::SNS::Friend;

#-------------------------------------------------
# �v���t�B�[���\��
#-------------------------------------------------
sub auth_avbefriend{

# �Ǐ���
my($file);

#�����`�F�b�N
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# CSS��`
$css_text .= qq(
.lim{margin-bottom:0.3em;line-height:1.25;}
);

# �t�@�C���I�[�v��
my(%account) = Mebius::Auth::File("File-check-error",$file);

	# �����̃A�J�E���g�łȂ��ꍇ
	if(!$account{'editor_flag'}){ &error("�����̃A�J�E���g�ł͂���܂���B",401); }

	# ���[�U�[�F�w��
	if($ppcolor1){ $css_text .= qq(h2{background-color:#$ppcolor1;border-color:#$ppcolor1;}); }


# �^�C�g������
$sub_title = "$friend_tag�\\���ꗗ - $account{'handle'} - $ppaccount - $title";
$head_link3 = qq(&gt; $hername);


# ���L�A�R�����g�t�H�[���Ȃǂ̃��O�ǂݍ���
my($apply) = Mebius::Auth::ApplyFriendIndex("Get-index",$file);

# �i�r
my $link2 = "$adir${file}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
my $navilink .= qq(<a href="$link2">�v���t�B�[���ɖ߂�</a>);

# HTML
my $print = <<"EOM";
$footer_link
<h1$main::kstyle_h1>$friend_tag���� : $account{'name'} - $file </h1>
$friendlink
$navilink
$adsarea
<h2$main::kstyle_h2>�������o�[�����$main::friend_tag�\\��</h2>
$apply->{'index_line'}
EOM


$print .= qq($footer_link2);

Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}




1;

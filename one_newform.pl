

#-------------------------------------------------
# �V�K�o�^�E���O�C���t�H�[��
#-------------------------------------------------

my($maxlengthac,$alert_text,$form);

# maxlength���`
unless($age =~ /PSP/){ $maxlengthac = qq( maxlength="10"); }

$css_text .= qq(
.putid{}
.nowrap{white-space:nowrap;}
.secure{font-weight:normal;font-size:90%;color:red;}
.guide_text{font-size:90%;color:#080;}
);

$thisis_bbstop = 1;

# ���O�C�����̏ꍇ�A�v���t�B�[���y�[�W�Ƀ��_�C���N�g
#if($idcheck){ location "view-$pmfile-all-1.html\n\n"; }

# CSS��`
$css_text .= qq(
.forgot{font-size:90%;color:#f00;}
);

# �t�H�[������
$form = qq(

<h2 id="NEW">�V�K�����o�[�o�^</h2>

$alert_text
<strong class="red">�����ӁI�@
�N���W�b�g�J�[�h�̈Ïؔԍ��ȂǁA�厖�ȃp�X���[�h����͂��Ȃ��ł��������B<br>
</strong>
<br>

<form action="$auth_url" method="post"$sikibetu><div>
��]�A�J�E���g���i���p�p���� 3-10�����j<br>
<input type="text" name="authid" value="" class="putid"$maxlengthac> ( ��F mickjagger )<br>

�p�X���[�h�i���p�p���� 4-8�����j<br>
<input type="password" name="passwd1" value="" maxlength="8"> ( ��F Adfk432d )<br>
�p�X���[�h�m�F�i���p�p���� 4-8�����j<br>
<input type="password" name="passwd2" value="" maxlength="8"> ( ��F Adfk432d )<br>
���[���A�h���X(�����͉�)<br>
<input type="text" name="email" value="" class="putid">
<span class="guide_text">���A�J�E���g���A�p�X���[�h�̍T�������M����܂��B</span><br><br>

<input type="hidden" name="mode" value="makeid">
<input type="hidden" name="back" value="one"><br>
<input type="submit" value="�A�J�E���g���쐬����">
</div></form>
);

# �N�b�L�[�Ȃ��̏ꍇ
if(!$cookie && $mebi_mode){ $form = qq(<strong class="red">�����̊��ł́A�A�J�E���g�𔭍s�ł��܂���B�����ǉ�ʂ��X�V���Ă݂Ă��������B</strong><br><br>); }

my $print = <<"EOM";
<h1>�A�J�E���g�V�K�o�^</h1>
$form
$footer_link
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

1;




#-------------------------------------------------
# �V�K�o�^�E���O�C���t�H�[��
#-------------------------------------------------
sub auth_newform{

my($maxlengthac,$form);

# Canonical����
$canonical = "${auth_url}";

# CSS��`
$css_text .= qq(
.putid{}
.nowrap{white-space:nowrap;}
.secure{font-weight:normal;font-size:90%;color:red;}
.guide_text{font-size:90%;color:#080;}
span.alert{font-size:90%;color:#f00;}
);

$head_link2 = qq( &gt; $title );

# CSS��`
$css_text .= qq(
.forgot{font-size:90%;color:#f00;}
);

# ���O�C���t�H�[�����擾
($form) = &get_form_auth_index();

# �w�b�_
&header();

print <<"EOM";
<div class="body1">
$footer_link
<h1>$title</h1>

$form
$footer_link2</div>
EOM

# �t�b�^
&footer();

exit;

}


use strict;

#-----------------------------------------------------------
# ���O�C���t�H�[�����擾
#-----------------------------------------------------------
sub get_form_auth_index{

# �錾
my($form);
our($guide_url,$action,$sikibetu,%in,$script,$backurl_query_enc,$friend_tag,$pmfile,$cookie);

# ���`
$form .= qq(
���J���̂r�m�r�ł��B�����o�[�o�^����ƁA���L����������A���̃����o�[��$friend_tag�o�^������ł��܂��B
�i<a href="${guide_url}%A4%E8%A4%AF%A4%A2%A4%EB%BC%C1%CC%E4%A1%CA%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A1%CB">���悭���鎿��</a>�j
<h2>���O�C��</h2>
);

	# �N�b�L�[�Ȃ��̏ꍇ
	if(!$cookie){
		$form .= qq(<strong class="red">�����̊��ł́A�A�J�E���g�𔭍s�ł��܂���B�����ǉ�ʂ��X�V���Ă݂Ă��������B</strong>);
		return($form);
	}

	# ���O�C�����̏ꍇ
	if($pmfile){

		$form .= qq(���Ƀ��O�C�����ł��B);
		return($form);

	}

# ���O�C�����̏ꍇ�A�v���t�B�[���y�[�W�Ƀ��_�C���N�g
#if($pmfile){
#&redirect("${auth_url}${pmfile}/");
#&jump("","${auth_url}$pmfile/","1","SNS�̃g�b�v�y�[�W�ł��B");
#&error("$title�̃g�b�v�y�[�W�ł����A���Ƀ��O�C�����ł��B<a href=\"${auth_url}${pmfile}/\">�v���t�B�[���y�[�W</a>�֐i��ł��������B");
#}

# �t�H�[������
$form .= qq(
<form action="./" method="post"$sikibetu>
<div><table>
<tr>
<td class="nowrap">�A�J�E���g��</td><td>
<input type="text" name="authid" value="" class="putid">
( ��F mickjagger )</td>
</tr>
<tr>
<td class="nowrap">�p�X���[�h</td>
<td><input type="password" name="passwd1" value="" maxlength="20">
(��F Adfk432d )</td>
</tr>
<tr><td></td><td>
<input type="submit" value="���O�C������">
<input type="hidden" name="mode" value="login">
<input type="hidden" name="back" value="$in{'back'}">
<input type="hidden" name="backurl" value="$in{'backurl'}">
<br><br>

<input type="checkbox" name="checkpass" value="1">
<span class="alert">�`�F�b�N�P�@�c�@�p�X���[�h���Ԉ���Ă���ꍇ�A�G���[��ʂɁu�A�J�E���g���v�Ɓu�p�X���[�h�v��\\�������܂��i�X�y���`�F�b�N�p�j�B</span><br>
<input type="checkbox" name="other" value="1">
<span class="alert">�`�F�b�N�Q�@�c�@�u�ꕔ�̌f���ŕM���������N�ɂȂ�Ȃ��v�u�V�`���b�g��A�}�C���O���g���Ȃ��v�Ȃǂ̕s����N����ꍇ�́A�`�F�b�N�����Ă��������B</span>

</td></tr>
</table><br>);


$form .= qq(
<a href="$script?mode=aview-newform$backurl_query_enc">���A�J�E���g���������łȂ����́A�����炩��V�K�o�^���Ă��������B</a><br><br>
<a href="$script?mode=aview-remain">���p�X���[�h��Y�ꂽ�ꍇ�́c�B</a>
);


$form .= qq(
</div>
</form>
);

return($form);


}


1;


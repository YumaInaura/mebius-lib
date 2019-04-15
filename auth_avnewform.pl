
package main;

#-------------------------------------------------
# �V�K�o�^�t�H�[��
#-------------------------------------------------
sub auth_avnewform{

my($maxlengthac,$form);

# maxlength���`
unless($age =~ /PSP/){ $maxlengthac = qq( maxlength="10"); }

# CSS��`
$css_text .= qq(
.putid{}
.nowrap{white-space:nowrap;}
.secure{font-weight:normal;font-size:90%;color:red;}
.guide_text{font-size:90%;color:#080;}
input{margin:0.3em 0em;}
.forgot{font-size:90%;color:#f00;}
ul{color:#f00;}
);

	# �X�g�b�v���[�h
	if($main::stop_mode =~ /SNS|Make-new-account/){ main::error("���݁A�V�K�o�^�͒�~���ł��B","503 Service Temporarily Unavailable"); }

# �^�C�g����`
$sub_title = "�V�K�����o�[�o�^ - $title";
$head_link3 = " &gt; �V�K�����o�[�o�^";

# ���݈��p���Ȃǂ̐���
my($gold_text);
$gold_text = qq(
<li>�u���݁v�u���e�񐔁v�u���������v�̓��Z�b�g����A�A�J�E���g���ɋL�^�����悤�ɂȂ�܂��B���O�A�E�g����ƌ��̋L�^����n�߂���ꍇ������܂��B</li>
<li>���O�C�����́A�}�C�y�[�W�́u���݁v�u���e�񐔁v�u���������v�Ȃǂ̓T�[�o�[���ɋL�^�����悤�ɂȂ�܂��B</li>
);

#if($kaccess_one){  $gold_text = qq(<li>�o�^����Ɓu���݁v�u���e�񐔁v�u���������v�̋L�^�́A�A�J�E���g�f�[�^�Ƃ��Ĉ����p����܂��B���O�A�E�g�����ꍇ�́u���݁v�u���e�񐔁v�u���������v�̓��Z�b�g����܂��B</li>); }

# ���[�J���ł̏�������
my $first_input_password = "qaswqasw" if Mebius::AlocalJudge();
my $first_checked_agree1 = my $first_checked_agree2 = my $first_checked_agree3 = " checked" if Mebius::AlocalJudge();
my $input_password_type;
if(Mebius::AlocalJudge()){ $input_password_type = "text"; } else { $input_password_type = "password"; }

# �t�H�[������
$form = qq(
<h2 id="ALERT">������ ( �K�����ǂ݂������� )</h2>

$alert_text
<ul>
<li>�N���W�b�g�J�[�h�̈Ïؔԍ��ȂǁA�厖�ȃp�X���[�h����͂��Ȃ��ł��������B</li>
<li>�A�J�E���g�̗����͂��������������B���ɃA�J�E���g���������̕���<a href="$auth_url">���O�C��</a>���Ă��������B</li>
<li>�����ǃA�J�E���g�����ƁA���S���͏o���܂���B���L��R�����g���ЂƂ��폜���āA�����Ȃ���Ԃɂ���K�v������܂��B</li>
<li>�p�X���[�h�Y�ꂪ�N�������ł��B�啶���E�������̈Ⴂ�Ȃǂɒ��ӂ��āA�p�X���[�h�͕K���Ȃ����Ȃ��ꏊ�Ƀ������Ă����Ă��������B</li>
<li>���[���A�h���X����͂���ƁA�A�J�E���g���̍T�����������M����܂��B</li>
$gold_text
</ul>


<h2 id="NEW">�o�^�t�H�[��</h2>

<form action="$action" method="post"$sikibetu><div>
��]�A�J�E���g��<br>
<input type="text" name="authid" value="" pattern="^[0-9a-z]+\$" class="putid"$maxlengthac>
<span class="guide_text">�@( ���p�p���� 3-10���� )�@��F mickjagger </span><br>

�p�X���[�h<br>
<input type="$input_password_type" name="passwd1" value="$first_input_password" maxlength="20">
<span class="guide_text">�@��F Adfk432d </span><br>
�p�X���[�h�m�F<br>
<input type="$input_password_type" name="passwd2" value="$first_input_password" maxlength="20">
<span class="guide_text">�@��F Adfk432d</span><br>
<input type="hidden" name="mode" value="makeid">
���[���A�h���X<br>
<input type="text" name="email" value="" class="putid">

<span class="guide_text">�@( �����͉� )�@���A�J�E���g���̍T�������M����܂��B</span>

<h3>���p�K��</h3>

<ul>
<li><input type="checkbox" name="check1" value="1"$first_checked_agree1> ����<a href="${guide_url}%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A4%CE%A5%EB%A1%BC%A5%EB" target="_blank">$title�̃��[��</a>�ƁA�K�v�ȃ����N��̃K�C�h���n�ǂ��܂����B
<li><input type="checkbox" name="check2" value="1"$first_checked_agree2> ����<strong class="red">�u�l���̌f�ځA�����v�u�����A�A���A�l�|�v�u�N���s�ׁv�u�}�i�[���������O�`�v�u�`�F�[�����e�v</strong>�Ȃǂ̕s�����p�́A�����Ă����Ȃ��܂���B
<li><input type="checkbox" name="check3" value="1"$first_checked_agree3> �s�K�؂ȗ��p���������ꍇ�A���͗\\���Ȃ��Ɂu�R�����g�폜�v�u�A�J�E���g���b�N�i�폜�j�v�u���e�����v�u�v���o�C�_�A���v�Ȃǂ̏��u������Ă��\\���܂���B
</ul>
<br>
$backurl_input
<input type="submit" value="���p��̒��ӂɓ��ӂ��āA�A�J�E���g���쐬����"><br>
<br>

</div></form>

);

	# �N�b�L�[�Ȃ��̏ꍇ
	if(!$cookie){
		$form = qq(<strong class="red">�����̊��ł́A�A�J�E���g�𔭍s�ł��܂���B�����ǉ�ʂ��X�V���Ă݂Ă��������B</strong><br><br>);
	}

my $print = <<"EOM";
$footer_link
<h1>�V�K�A�J�E���g�o�^ - ���r�E�X�����O</h1>

$form
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;



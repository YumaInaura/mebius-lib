use strict;

#-----------------------------------------------------------
# ���݃Z���^�[
#-----------------------------------------------------------
sub main_gold{

# �錾
our($title) = ("���݃Z���^�[");
our($submode2);


# ���[�h�U�蕪��
if($submode2 eq "index"){ &main_gold_top(); }
else{ &error("�y�[�W�����݂��܂���B"); }
}


#-----------------------------------------------------------
# ���݃Z���^�[�g�b�v
#-----------------------------------------------------------
sub main_gold_top{

# �錾
my($guide);
our($title,$cusegold,$cspendgold);
our($xclose,$cgold,$callsave_flag);

&set_cookie();

# �w�b�_
&header();

# ����
$guide = qq(�A�J�E���g�Ƀ��O�C�����Ă�����A�ꕔ�̌g�ѓd�b�ł́A���݃Z���^�[�����p�ł��܂��B);
if($callsave_flag){ $guide .= qq(<br$xclose>���܂̂��Ȃ��́A���݃Z���^�[�𗘗p<strong class="red">�ł��܂��B</strong>); }
else{ $guide .= qq(<br$xclose>���܂̂��Ȃ��́A���݃Z���^�[�𗘗p<strong class="red">�ł��܂���B</strong>); }

# HTML
print qq(
<div class="body1">
<h1>$title</h1>
<h2>����</h2>
$guide
<h2>���j���[</h2>
$callsave_flag
���݁F $cgold<br$xclose>
�c����݁F $cusegold
</div>
);

# �t�b�^
&footer;

exit;


}


1;


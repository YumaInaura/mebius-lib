#-----------------------------------------------------------
# �Ăт����e���v��
#-----------------------------------------------------------

sub get_calltemplate{

# �Ǐ���
my($line);

# CSS��`
$css_text .= qq(
div.template1{background-color:#fff;text-indent:0.5em;}
div.template2{background-color:#ccc;text-indent:0.5em;}
div.template3{background-color:#f9e;text-indent:0.5em;}
div.template4{background-color:#9ff;text-indent:0.5em;}
div.template5{background-color:#ff3;text-indent:0.5em;}
div.template6{background-color:#f99;text-indent:0.5em;}
div.template7{background-color:#4f4;text-indent:0.5em;}
td.template{border:dashed 1px #0a0;padding:0.5em;line-height:1.7em;word-spacing:1.1em;font-size:80%;color:#f00;}
);

# �e���v���[�g���Q�b�g
($line) .= &get_templatetext;
$line .= $redcard;

# �e���v���[�g�̒���
$line =~ s/%/%25/g;
$line =~ s/\[br\]/\r/g;
$line =~ s/>>/&gt;/g;
$line =~ s/\n//g;
$line =~ s/\r/\\n/g;

return($line);

}

#-----------------------------------------------------------
# �e���v���[�g���擾
#-----------------------------------------------------------
sub get_templatetext{

# �Ǐ���
my($line);

#-----------------------------------------------------------
# ��{
#-----------------------------------------------------------
$line .= '

<div class="template1">
<strong>��{</strong> 
<a href="javascript:template(\'\r
�������܂����A�ꕔ���e���폜�����Ă��������܂����B\r
\r\')">�폜</a> 

<a href="javascript:template(\'\r
���r�E�X�����O�̃K�C�h���A���߂Ă��m�F���������B\r
http://aurasoul.mb2.jp/wiki/guid/\r
\r\')">�K�C�h</a> 

<a href="javascript:template(\'\r
���e�~�X���폜�����Ă��������܂����B�i���e��̊ԈႦ�A��d���e�A���������Ȃǁj\r
\r\')">�~�X</a> 

<a href="javascript:template(\'\r
�{�l�l����̈˗����󂯁A�폜�����Ă��������܂����B\r
\r\')">�{�l</a> 

<a href="javascript:template(\'\r
��ϐ\���󂠂�܂��񂪁A\r
�i���Ƃ��ΊO���T�C�g�Ȃǂ���j�����l�ł��z���ɂȂ�A��Ăɏ������ލs�ׂ͂�������������\r\r
���Ɏ��̂悤�ȍs�ׂ͋֎~�����Ă��������܂��B\r\r
�E�L���Ɋ֌W�̂Ȃ���������\r
�E�����[�U�[�l�̔����������s��\r
�E�`�`�̏������݁A���΂Ȍ��t�̏�������\r\r
�����[�U�[�l�̖��f�ɂȂ�Ɣ��f�������e�ɂ��ẮA�Ǘ��҂̔��f�ō폜�����Ă��������ꍇ���������܂��B\r
\r\')">���K</a> 

<a href="javascript:template(\'\r
���S�̂��߂ɁA�K�����̂��Ƃ����H���Ă��������B\r
�u�������T�C�g�ɍs���Ȃ��v�u�������R�}���h�����s���Ȃ��v�Ȃǁc�c�B\r
��������Ȃ��ƁA���Ȃ��̃p�\�R����A���Ȃ����g�Ɋ댯�ɂȂ邱�Ƃ�����܂��B\r
http://aurasoul.mb2.jp/wiki/guid/%A5%C8%A5%E9%A5%C3%A5%D7%B2%F3%C8%F2%CB%A1\r
\r\')">�g���b�v</a> 

<a href="javascript:template(\'\r
�Ǘ��҂̔��f�ɂ��A����폜�������Ȃ킹�Ă��������܂����B\r\r
�폜���R�F\r
\r\')">����폜</a> 

<strong>�^��</strong> 

<a href="javascript:template(\'\r
������ɂ悭���鎿�₪�܂Ƃ߂��Ă��܂��B\r
��ς��萔�ł����A���Ў��̃K�C�h���������������B\r\r
���폜�p���` - �폜�ɂ��Ă̂p���`�ł��B\r
\r\')">�폜�p���`</a> 

<a href="javascript:template(\'\r
��������̊Ǘ��ɂ��Ă��A��������܂��ꍇ�́A\r
��ς��萔�ł����A������̋L���܂ŏ������݂����肢���܂��B\r
https://aurasoul.mb2.jp/jak/qst.cgi?mode=view&no=1973\r
\r\')">�^��A��</a> 

<a href="javascript:template(\'\r
���ɋ������܂����A�Ǘ��҂���񓚂����񑩂ł��Ȃ��P�[�X���������܂��B\r
��ς��萔�ł͂������܂����u�Ǘ��҉񓚁v�̃K�C�h���������������B\r
\r\')">�Ǘ��҉�</a> 


</div>
';


#-----------------------------------------------------------
# ����
#-----------------------------------------------------------
$line .= '
<div class="template2">
<strong>����</strong> 

<a href="javascript:template(\'\r
�������܂����A���t�����Ⓤ�e�}�i�[�ɂ͏[�������ӂ��������B\r
�{�T�C�g�̗��p�ɂ������āA�K�C�h�̍Ċm�F�����肢�������܂��B\r
\r
���K�C�h�̊m�F - �}�i�[�ᔽ / �}�i�[�p���`�@\r
\r\')">�}�i�[</a> 

<a href="javascript:template(\'\r
���F�l\r\r
���[���ᔽ�ɔ�������ƁA�t���ʂɂȂ��Ă��܂��ꍇ������܂��B\r
���i�̏������݂𑱂�����A�폜�˗����o�����ƂőΏ������肢�������܂��B\r
\r
���K�C�h�̊m�F - ���[���ᔽ�ւ̑Ώ�\r
\r\')">�ߏ蔽��</a> 

<a href="javascript:template(\'\r
���萔�ł����A���̕���s���ɂ�����e�Ȃǂ́A�Ȃ�ׂ������Ĉ��p�����肢���܂��B\r
�i���p���̒��̕\���ɂ��A�폜�����Ă��������ꍇ������܂��j\r
\r\')">���p����</a> 

<strong>����</strong> 

<a href="javascript:template(\'\r
�u�Z���v�u�{���v�u�d�b�ԍ��v�Ȃǌl����A\r
�v���C�x�[�g�ȏ����������񂾂�A�l�ɋ��߂��肵�Ȃ��ł��������B\r
��ő傫�Ȗ��ɂȂ邱�Ƃ�����܂��B\r
\r\')" class="red">�l���</a> 

<a href="javascript:template(\'\r
�ꕔ�Łu���ʁv�u�{���v�u�d�b�v�u���[���v�Ȃǂ̂��b������܂������A\r
�{�T�C�g�Łu�l���̌����E�f�ځv���Ȃ����܂���ł������H\r
�������̏ꍇ�́A���萔�ł��������g�ō폜�˗������肢�������܂��B\r
http://aurasoul.mb2.jp/_delete/\r\r
�܂��A�����v���C�x�[�g�ȏ������݂͖�肪�N���₷�����߁A�Ǘ��҂̔��f�ō폜�����Ă��������ꍇ������܂��B\r
\r\')" class="red">�l���H</a> 

<a href="javascript:template(\'\r
���r�E�X�����O�ɂ͂h�c�V�X�e��������A\r
�M����ς��ď������񂾏ꍇ���A����̂h�c���\������܂��B\r\r
�ς��Ȃ��}�[�N������ꍇ�́u�g���b�v�v�������p���������B\r
http://aurasoul.mb2.jp/wiki/guid/%A5%C8%A5%EA%A5%C3%A5%D7\r
\r\')">����/�g���b�v</a> 


</div>
';


#-----------------------------------------------------------
# ���f
#-----------------------------------------------------------
$line .= '
<div class="template1">
<strong>���f</strong>  

<a href="javascript:template(\'\r
���݂܂��񂪁A���̕��̖��f�ƂȂ鏑�����݂͂��������������B\r
�Ǘ��҂̔��f�ŁA���e���폜�����Ă��������ꍇ������܂��B\r
\r\')">���f(�S��)</a> 

<a href="javascript:template(\'\r
�������܂����A�{�T�C�g�ł͎��̂悤�ȓ��e�͂��������������B\r
\r
���u�}���`�|�X�g�v�u��`�s�ׁv�u�`�F�[�����e�v�u�s�K�؂ȃ����N�v�ȂǁA���̕��̖��f�ƂȂ���́B\r
���u�`�`�v�u�L���̗���v�u�ߏ�ȃf�R���[�V�����v�u�������҂��v�u���Ӗ��ȕ��͂̓��e�v�u���s�̂������v�u���f�]�ځv�ȂǁA�{�T�C�g�̕��̓��[���ɔ�������́B\r
\r
��L�̂��̂́A�Ǘ��҂��폜�����Ă��������ꍇ���������܂��B\r
\r\')">���f(�`�F�[��,�`�`,����,�}���`,��`��)</a> 

<strong>�G�k/�J�e</strong> 

<a href="javascript:template(\'\r
����ł����A�ꕔ���u�G�k���v���Ă��܂��Ă���悤�ɂ����󂯂��܂��B\r
\r
�J�e�S���Ɗ֌W�̂Ȃ��b�i���Ƃ��΁u��Ђ̘b�v�u�w�Z�̘b�v�Ȃǁj�́A\r
��ς��萔�ł����A���R�f���ȂǂɈړ������肢���܂��B\r
http://mb2.jp/_ztd/\r\r

���K�C�h�̊m�F - �G�k��\r
\r\')">�G�k��</a> 

<a href="javascript:template(\'\r
����ł����A�ꕔ���u�`���b�g���v���Ă���悤�ɂ����󂯂��܂��B\r
�u�`���b�g���v���N����Ɓu�f���v�̗ǂ��������Ă��܂����Ƃ�����܂��B\r
\r
�\���󂠂�܂��񂪁u�P�s���X�v�u���A�����̏������݁v�u�����񍐁v�Ȃǂ͍T���A\r
�u�f���v�Ƃ��Ďg���Ă��������悤�A�����͂����肢�������܂��B\r\r
���K�C�h�̊m�F - �`���b�g��\r
\r\')">�`���b�g��</a> 

<a href="javascript:template(\'\r
����ł����A�ꕔ�̓��e���A�L���{���̖ړI���炻��Ă���悤�ɂ����󂯂��܂��B\r
���萔�ł����A�f���̃��[����e�[�}�����m�F�̏�A \r
�����@�\�����p���A�ӂ��킵���L����I��ŏ�������ł��������B\r
\r\')">�J�e�Ⴂ(���X)</a> 

<a href="javascript:template(\'\r
����ł����ꕔ�̓��e���A�L���̃e�[�}������Ă���悤�ɂ����󂯂��܂��B\r\r
�T�C�g���p�}�i�[�ɂ��Ă��b�������ꍇ�́A\r
�������܂����u���r�E�X�����O����^�c�v�ւ̈ړ������肢�������܂��B\r
http://aurasoul.mb2.jp/_qst/2403.html\r
\r\')">�J�e�Ⴂ(�}�i�[)</a> 

</div>
';



#-----------------------------------------------------------
# �i���p
#-----------------------------------------------------------
$line .= '
<div class="template3">
<strong>�o��</strong> 

<a href="javascript:template(\'\r
�������܂����A���[���A�h���X�̓��e�͍폜�ΏۂƂȂ�܂��B\r
���[���A�h���X���������񂾂�A�l�ɕ������肷��s�ׂ͂��������������B\r
\r\')">�����A�h</a> 

<a href="javascript:template(\'\r
�������܂����{�T�C�g�ł́A
�u�����F��W�v�u���ʑ����W�v�Ȃǂ̕�W��A\r
�u���l��W�v�u�J�b�v�����v�u��񑩁v�u�o�[�`�����f�[�g�v�Ȃǂ̍s�ׂ͂��������������Ă���܂��B\r
�ߓx��ۂ��Ă̗��p�����肢�������܂��B\r
\r\')">�o��n</a> 

<strong>���I</strong> 

<a href="javascript:template(\'\r
�������܂����A�{�T�C�g�ł͎��̂悤�ȓ��e�͋֎~�ƂȂ��Ă��܂��B\r
\r
�E�i���k�A�c�_�ȊO�ł́j���I�ȓ��e\r
�E�t�H���[�̂Ȃ��u���̕񍐁v�u���̎���v\r
�E���̑��k�ŁA�z���̂Ȃ���������\r
\r
��L�̂悤�Ȃ��̂́A�Ǘ��҂̔��f�ō폜�����Ă��������ꍇ������܂��B\r
\r\')">���I</a> 
</div>';


#-----------------------------------------------------------
# �n��
#-----------------------------------------------------------
$line .= '
<div class="template4">
<strong>�n��</strong> 

<a href="javascript:template(\'\r
���萔�ł����u���I�\���̃��[���v�̍ă`�F�b�N�����肢�������܂��B\r
http://aurasoul.mb2.jp/wiki/guid/%C0%AD%C5%AA%A4%CA%C9%BD%B8%BD\r
\r\')">���I-�n</a> 

<a href="javascript:template(\'\r
���萔�ł����u�V���b�L���O�ȕ\���̃��[���v�̍ă`�F�b�N�����肢�������܂��B\r
http://aurasoul.mb2.jp/wiki/guid/%CB%BD%CE%CF%C5%AA%A4%CA%C9%BD%B8%BD\r
\r\')">�V���b�N-�n</a> 

<a href="javascript:template(\'\r
�u�n��薼�̃��[���v�������m�ł����B\r
���̃y�[�W���悭�ǂ݁A�n��I�ȕ��͋C�ɂ��Ĕz�������肢�������܂��B\r
http://aurasoul.mb2.jp/wiki/guid/%C1%CF%BA%EE%A4%CE%C2%EA%CC%BE\r
\r\')">�薼-�n</a> 

<a href="javascript:template(\'\r
���݂܂��񂪑n��̏�ł́A�߂����G�k�͂��������������B\r
�����ɁA�𗬐�p�̌f���������p���������B\r
���K�C�h�̊m�F - �G�k��\r
\r\')">�G�k-�n</a> 

<a href="javascript:template(\'\r
���̍�i�Ɂu�͕�E����E�񎟑n��v�Ȃǂ̗��R�ō폜�˗����o����܂����B\r
���萔�ł����Ahttp://aurasoul.mb2.jp/_delete/155.html�@�܂ŘA�������肢�ł��Ȃ��ł��傤��\r
\r\')">����-�n</a> 

<a href="javascript:template(\'\r
����E�͕�Ȃǂɂ��ċc�_�������ꍇ�́A\r
���萔�ł����A�}�i�[�f���Ɉړ������肢���܂��B\r
http://aurasoul.mb2.jp/wiki/guid/%C5%F0%BA%EE%A1%A2%CC%CF%CA%EF%A4%CE%CF%C3%A4%B7%B9%E7%A4%A4\r
\r\')">����c�_-�n</a> 

<a href="javascript:template(\'\r
���f�ŁA���̐l�̍�i�𑱂���s�ׂ͂��������������B\r
�����̍�i�������ꍇ�́A�L���̐V�K���e�����肢���܂��B\r
\r\')">����-�n</a> 

<a href="javascript:template(\'\r
���萔�ł�����i��]�ɂ������āA������̃K�C�h���������������B\r
http://aurasoul.mb2.jp/wiki/guid/%BA%EE%C9%CA%C8%E3%C9%BE\r
\r\')">��]-�n</a> 

<a href="javascript:template(\'\r
���݂܂��񂪃��r�E�X�����O�ł́A�񎟑n��͋֎~�ƂȂ��Ă��܂��B\r
\r\')">��-�n</a> 

<a href="javascript:template(\'\r
�����������Ƃ��́A���M���Ȃǂɍ��킹�āA�ꏊ�������߂��������B\r
���Ƃ��Ώ����n�߂ĂP�N�����ł���΁u���S�҂̂��߂̏������e��v���������߂ł��B\r
http://aurasoul.mb2.jp/_sst/\r
\r\')">���S-�n</a> 

<a href="javascript:template(\'\r
�g���������������Ƃ��́u�g�����������e��v���������߂ł��B\r
http://aurasoul.mb2.jp/_tog/\r
\r\')">�g��-�n</a> 

<a href="javascript:template(\'\r
�u�N��ݒ�v���U���āA�����̂���L�����{�����邱�Ƃ͂��������������B\r
\r\')">�N��U</a> 

<a href="javascript:template(\'\r
���萔�ł����A�����ւ̃R�����g�E���z�̓T�u�L���������p���������B\r
\r\')">�T�u</a> 
</div>
';


#-----------------------------------------------------------
# �L��
#-----------------------------------------------------------
$line .= '
<div class="template7">
<strong>�L��</strong> 

<a href="javascript:template(\'\r
�����f���ɁA�����e�[�}�̋L���͂ЂƂ܂łł��B\r
���萔�ł����A�����@�\�Ȃǂ��g���ē���̋L����T���A������������p���������B\r
\r\')">�d��</a> 

<a href="javascript:template(\'\r
���̋L���́A�W����������������Ă��܂���B\r
�L���͂��܂��W�������������Ă�������悤���肢�������܂��B\r
http://aurasoul.mb2.jp/wiki/guid/%A5%B8%A5%E3%A5%F3%A5%EB%CA%AC%A4%B1\r
\r\')">�W����������</a> 

<a href="javascript:template(\'\r
���萔�ł����A�f���̃e�[�}����O�ꂽ�L���͈ړ������肢���܂��B\r
�f���̃��[����A��|���悭�����̏�A \r
�ӂ��킵���ꏊ��I��ŏ�������ł��������B\r
\r\')">�J�e�Ⴂ(�L��)</a> 

<a href="javascript:template(\'\r
���݂܂��񂪁A�{�T�C�g�ł͎��̂悤�ȋL������邱�Ƃ͏o���܂���B\r
\r
�E�u�N��^�w�N�^���ʁ^���Z�n�v�ŎQ���҂����߂��L��\r
�E�u���Ƙb�����v�u�`����Ƃa����̘b����v�ȂǁA�l�I�ȋL��\r
�E�e�[�}��������������A�薼��e�[�}���s���ĂȋL����A�P���L��\r
\r
���萔�ł����A�V�K���e�̃��[���ɂ��킹�āA�L���̍�蒼�������肢���܂��B\r
\r\')">�e�[�}/����/�l�I</a> 

<strong>�C��</strong> 

<a href="javascript:template(\'\r
����ɂ��A&gt;&gt;0 �̓��e�i�܂��͑薼�j��ύX�����Ă��������܂����B\r
\r\')">��E���e�C��</a> 


</div>
';


#-----------------------------------------------------------
# �J�e�S��
#-----------------------------------------------------------
$line .= '
<div class="template5">
<strong>�J�e</strong> 

<a href="javascript:template(\'\r
���萔�ł����񓚂ɂ������āu���k�v�̃K�C�h������񂭂������B\r
\r\')">���k(��)</a> 

<a href="javascript:template(\'\r
�c�_�ɂ������āA������̃K�C�h���Ċm�F���肢�������܂��B\r
�قƂ�ǂ̏ꍇ�A���ƂȂ�̂́u�ӌ��̓��e�v�ł͂Ȃ��u���e�}�i�[�v�ł��B\r
http://aurasoul.mb2.jp/wiki/guid/%B5%C4%CF%C0\r
http://aurasoul.mb2.jp/wiki/guid/%B7%FA%C0%DF%C5%AA%A4%CA%B5%C4%CF%C0\r
\r\')">�c�_</a> 


<a href="javascript:template(\'\r
�������܂����u�Ȃ肫��̃N�I���e�B�v�̃K�C�h�͂������������܂������B\r
http://aurasoul.mb2.jp/wiki/guid/%A4%CA%A4%EA%A4%AD%A4%EA%A4%CE%A5%AF%A5%AA%A5%EA%A5%C6%A5%A3\r\r
���Ƃ��Ύ��̂悤�ȂȂ肫��́A��ɖ����Ȃ����̂Ƃ��č폜�A���b�N�Ȃǂ����Ă��������ꍇ������܂��B\r\r
�E���[�����i�`�ʂ��Ȃ��A�قƂ�ǁu�L�����̑䎌�̂݁v�ŉ���Ă���L���B\r
�E�`���b�g���̂悤�ɁA�R�O�`�T�O�������x�̃��X���قƂ�ǂ��߂�L���B\r
�E�j���̎Q���l�������߂Ă̗����L���i�J�b�v�����O�j�̋L���B\r\r

���[�����K�L���͂�����ł��F\r
http://mb2.jp/_nmn/?mode=find&word=%97%FB%8FK\r
\r\')">�Ȃ�N�I</a> 

<a href="javascript:template(\'\r
�Ȃ肫��f���ł́u���A���G�k�v�͋֎~�ł��B\r
���A���G�k������ꍇ�́A��p�Ɉړ������肢���܂��B\r
http://mb2.jp/_nzz/\r
\r\')">�Ȃ胊�A�G�k</a> 

<a href="javascript:template(\'\r
�Ȃ肫��J�e�S���̐�����A\r
�u�{�̉�b�v�݂̂̏������݂́A�ɗ͍T���Ă��������B\r
\r\')">�{�̉�b</a> 

<a href="javascript:template(\'\r
�u�ʐM�v�u�ΐ�҂����킹�v�Ȃǂ̘b�̓J�e�S���Ⴂ�ł��B\r
�Q�[���f���i�ʐM�E�����j�Ɉړ����Ă��������B \r
http://mb2.jp/_gko/\r
\r\')">�Q�[���ʐM</a>

</div>
';


#-----------------------------------------------------------
# �x��
#-----------------------------------------------------------
$line .= '
<div class="template6">
<strong>�x��</strong> 

<a href="javascript:template(\'\r
���[�����ӂ̌Ăт������������������܂������H\r
�T�C�g���p�ɂ������ẮA���r�E�X�����O�̃��[�����悭���m�F���������B\r
http://aurasoul.mb2.jp/wiki/guid/\r
\r\')">�U��</a> 

<a href="javascript:template(\'\r
���[�����ӂ̌Ăт������������������܂������H\r
�{�T�C�g�̃��[��������肢�������Ȃ��ꍇ�A\r
���݂܂��񂪁A����̗��p�����f�肳���Ă��������ꍇ������܂��B\r
\r\')">�����U��</a> 

<a href="javascript:template(\'\r
�{�T�C�g�̃��[�������炨�肢�������܂��B\r
�ᔽ�������ꍇ�A����u���e�����v�u�v���o�C�_�A���v�Ȃǂ̏��u����点�Ă��������ꍇ������܂��B\r
\r\')">��ʒʍ�</a> 

<a href="javascript:template(\'\r
���r�E�X�����O�ւ̑S�Ă̓��e�́A���Ȃ��̐ڑ����ƈꏏ�ɕۑ�����Ă��܂��B\r
�����ȓ��e���������ꍇ�A�v���o�C�_�i�l�b�g��ЁE�g�щ�Ёj�֘A�������ƁA\r
���Ȃ��̖{�l�̐g��������o����A�l�b�g�ڑ���~�A�މ���Ȃǂ̑Ή����Ȃ����ꍇ������܂��B\r
�{�T�C�g�A�Ȃ�тɖ{�T�C�g���[�U�[�l�ւ̖��f�s�ׂ͂����������悤���肢�������܂��B\r
\r\')">�Ō�ʍ�</a> 


<a href="javascript:template(\'\r
�Ӑ}�I�ȍr�炵�͂��������������B���e�����A�v���o�C�_�A���Ȃǂ̑ΏۂƂ����Ă��������ꍇ������܂��B\r
\r\')">�Ӑ}�I</a> 

<a href="javascript:template(\'\r
�ƍ߂ɂȂ��鏑�����݂�A\r
����������铊�e�����Ȃ��ł��������B\r
�ٔ����A�x�@�Ȃǂ���A�����������ꍇ�A\r
�{�T�C�g�̐ڑ��f�[�^���o�����Ă��������ꍇ������܂��B\r
\r\')">�ƍ�</a> 

</div>
';

return($line);

}


1;

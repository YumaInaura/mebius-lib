#-----------------------------------------------------------
# �Q�����˂邩��̃����N
#-----------------------------------------------------------
sub from_2ch{

my($dlink,$indlink);
our($time,%in);

($dlink) = &Mebius::Encode("",$time);
($indlink) = &Mebius::Decode($in{'dlink'});

if($time < $in{'dlink'} + 3*60 && $in{'dlink'} < $time){ return; }

&Mebius::AccessLog("","From-enemy-site","URL: $ENV{'HTTP_REFERER'}");

print"Content-type:text/html\n\n";

print qq(
<html lang="ja">
<head>
<meta http-equiv="content-type" content="text/html; charset=shift_jis">
<meta http-equiv="content-style-type" content="text/css">
<style type="text/css">
<!--
body{line-height:1.4em;}
-->
</style>
<title>
�����N
</title>
</head>
<body lang="ja">
<div class="body1">�O���T�C�g��肨�z���̕��ցB<br><br>

�{�T�C�g�ł́A���e�}�i�[������Ă����p���������B<br>
��ϋ��k�ł͂������܂����A�ȉ��̂悤�ȍs�ׂ͂��������������悤���肢\�\\���グ�܂��B<br><br>

<ul>
<li>�A�N�Z�X�U�����Ȃ��邱�ƁB�܂��A�T�[�o�[�ɕ��S��������s�ׂ��Ȃ��邱�ƁB</li>
<li>�����𗅗��������A�`�`�i�A�X�L�[�A�[�g�j�̓��e�Ȃ��邱�ƁB</li>
<li>��l���ł��z���ɂȂ�A����̏ꏊ�ɑ΂��āA��Ăɂ��������݂ɂȂ邱�ƁB<strong style="color:#f00;">�i���i����̃��[�U�[�l�ɂƂ��ẮA�Ƃ����l�������z���ɂȂ邱�Ƃ����ŁA��ςȕs����������ꍇ���������܂��j</strong></li>
<li>�����Ԃ���A����̑Ώہi�f���A�L���A���[�U�[�l�Ȃǁj�ɑ΂��čU���A�_�j�A�ˌ��Ȃǂ����͂���ɂȂ邱�ƁB</li>
<li>�u�c�����v�u�΂ߏ����v�Ȃǂ̃p�Y�����g���āA�ÂɃ��[���ᔽ���Ȃ��邱�ƁB</li>
<li>�ߏ�ȃo�b�V���O��A�l��������s�ׁA�s���ɂ���s�ׂ��Ȃ��낤�Ƃ��邱�ƁB</li>
<li>�Ⴆ�΃R�}���h�v�����g�őS�t�@�C������������ȂǁA�ȂǊ댯�ȃR�}���h��A�댯��\�\\�t\�g�Ȃǂ����Љ�ɂȂ邱�ƁB</li>
<li>�����[�U�[�l�ւ𐫓I�ȑΏۂƂ��Ĉ�������A���܂Ƃ����Ȃ��邱�ƁB�܂��A���ɈÂɔ��΂ȓ��e���Ȃ��邱�ƁB</li>
<li>���̑��A�������[�U�[�l�̖��f�ƂȂ�s�ׂ��Ȃ��邱�ƁB</li>
<li>��̓I�Ɍ��߂�ꂽ���[���̖Ԗڂ������āA�V�������f�s�ׂ����l���ɂȂ�A���s�Ȃ��邱�ƁB</li>
</ul>

�ᔽ�s�ׂ�A�����[�U�[�l�̖��f�ƂȂ�s�ׂ��������ꍇ�A<br>
�\\���Ȃ��Ɂu�폜�v�u���e�����u�v���o�C�_�A���v�A�܂����̑��̏��u���Ƃ点�Ă��������ꍇ���������܂��B<br><br>

<a href="./?dlink=$dlink">Go</a>
</div></body></html>
);

exit;

}

1;



use Mebius::Penalty;

#-----------------------------------------------------------
# �O���T�C�g����̖K��
#-----------------------------------------------------------
sub from_enemysite{

my($type,$referer) = @_;
my($dlink,$indlink,%renew_penalty);
our($time,%in);

# GO �p�̃����N�ݒ�
($dlink) = Mebius::Encode("",$time);
($indlink) = Mebius::Decode($in{'dlink'});
if($time < $in{'dlink'} + 3*60 && $in{'dlink'} < $time){ return; }

# �A�N�Z�X���O���L�^
Mebius::AccessLog("","From-enemy-site","URL: $ENV{'HTTP_REFERER'}");

# �y�i���e�B�t�@�C���̕ύX���e
$renew_penalty{'from_other_site_time'} = time;
$renew_penalty{'from_other_site_url'} = $referer;

# �y�i���e�B�t�@�C�����X�V
#Mebius::PenaltyAll("","Renew Use-renew-hash",$main::myaccount{'file'},$main::host,$main::agent,$main::cnumber,%renew_penalty);
#Mebius::HistoryAll("RENEW Use-renew-hash My-file",undef,undef,undef,undef,undef,%renew_history);

# HTML��\��
print "Content-type: text/html; charset=shift_jis\n\n";

print qq(
<html lang="ja">
<head>
<meta http-equiv="content-type" content="text/html; charset=shift_jis">
<meta http-equiv="content-style-type" content="text/css">
<style type="text/css">
<!--
body{line-height:1.4;}
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

</div></body></html>
);

#<a href="./?dlink=$dlink">Go</a>


exit;

}

1;


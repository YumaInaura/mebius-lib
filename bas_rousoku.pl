
sub init_start{

# �h���C��
$server_domain = "mb2.jp";

# �O��CSS
#$style = "/style/bas.css";

# �w�b�_�����N
$head_link1_5 = qq(&gt; <a href="${base_url}gap/">�Q�[���R�[�i�[</a>);
$head_link1 = qq(&gt; <a href="$base_url">�ʏ�</a>-<a href="$goraku_url">��y</a>);

# �w�h�o���L�^���鐔
$rousoku_xipcnt_max = 10;

# �A�����e�Ԋu(�b)
$rennzoku_sec = 300;

# ���E�\�N���ő吔�o�����Ƃ��A�V���\���������
$heaven_day = 3;

# �V�����[�h�̔w�i�摜
$heaven_img = "http://mb2.jp/pct/rousoku_heaven.gif";

# �V�����[�h�ɓ��B���邽�߂̃��E�\�N���i�ő働�E�\�N���j
$max_rousoku = 1000;

# �^�C�g��
$title = "���E�\\�N����";

# �w�b�_�^�C�g��
$sub_title = "�肢��������A���E�\\�N����";

# �X�N���v�g����`
$moto = "rousoku";

$css_text = <<"EOM";
.body1{border-color:#000;}
.rousoku1{width:7px;height:20px;}
.rousoku10{width:8px;height:32px;}
.rousoku100{width:18px;height:60px;}
.rousoku1000{width:25px;height:90px;}
EOM

$ads1 = <<"EOM";
<br>
<script type="text/javascript"><!--
google_ad_client = "pub-7808967024392082";
/* ���E�\�N */
google_ad_slot = "2223327940";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
<br>
EOM
}


sub init_option{ }

#-----------------------------------------------------------
# �X�N���v�g���X�^�[�g
#-----------------------------------------------------------

sub start{

# �A�N�V������Ȃǒ���
if($alocal_mode){ $script = "$moto.cgi"; }
else{ $script = "./"; }

# REFERER������
if($in{'referer'}){ $referer_url = $in{'referer'}; }
elsif($in{'action'} eq ""){$referer_url = $referer; }

# �Ǐ���
local($top,$back_link,$form,$kaisetu,$submit,$now_text,$heaven_mode);

# ���E�\�N�f�[�^���J��
open(ROUSOKU_IN,"${int_dir}_rousoku/rousoku_data.cgi");
$top = <ROUSOKU_IN>;
close(ROUSOKU_IN);

# �f�[�^���Ȃ��ꍇ�A�o�b�N�A�b�v����J��
if($top eq ""){
open(BACKUP_IN,"${int_dir}_rousoku/rousoku_backup.cgi");
$top = <BACKUP_IN>;
($rousoku_num,$xip_list,$lasttime) = split (/<>/,$top);
close(BACKUP_IN);
}

# ���E�\�N�f�[�^����f�[�^�F��
($rousoku_num,$xip_list,$lasttime) = split (/<>/,$top);

# �V�����[�h����
if($rousoku_num >= $max_rousoku){ $heaven_mode = 1; }

# �V�����[�h�̏I���𔻒�
if($heaven_mode && $time > $lasttime + $heaven_day*24*60*60){ $heaven_mode_end = 1; }

# �V�����[�h���I����Ă���ꍇ�̔���A���E�\�N���O�{��
if($heaven_mode_end){
$heaven_mode = "";
$rousoku_num = 0 ;
}

# �V�����[�h�̏ꍇ�A�w�i�摜������
if($heaven_mode) {
$css_text .= <<"EOM"
body{background-image: url(${heaven_img});

background-position:center;
}
EOM
}

# �w�b�_�����N���`
$head_link2 = "&gt; $title";
$thisis_bbstop = 1;


# ���݂̃��E�\�N�{���e�L�X�g���`

$now_text = qq(
���A$rousoku_num�{�̃��E�\\�N�������Ă��܂��B ( $thismonth��$today�� $thishour��$thismin��$thissec�b�A���̎��� )
);

# ��������`
$kaisetu = <<"EOM";
<br><br> 
���Ԃ������ĂP�{���A���E�\\�N�𗧂Ă邱�Ƃ��o���܂��B<br>
�u���Ȃ��̊肢�v�����߂āA���E�\\�N�𗧂ĂĂ݂Ă��������B<br>
���E�\\�N�� <strong class="red">$max_rousoku�{</strong> �ɂȂ�ƁA�肢���V�ɏ���܂��B<br>
EOM

# �t�H�[�����`
$form = <<"EOM";
<br>
<form action="$script" method="post" class="nomargin">
<div>
<input type="hidden" name="referer" value="$referer_url">
<input type="submit" name="action" value="�肢�����߂āA���Ȃ��̃��E�\\�N�𗧂Ă�">
</div>
</form>
EOM

# ���E�\�N���}�b�N�X�̏ꍇ�A�t�H�[���������A�������ύX
if($heaven_mode){

$form = "";
$kaisetu = "";

$now_text = <<"EOM";
�Ȃ�ƁA���� <strong class="red">$max_rousoku�{</strong> �̃��E�\\�N�������܂����I<br>
�F�̊肢���A�V�ɏ����čs���Ă܂��B<br><br>
���E�\\�N�𗧂ĂĂ��ꂽ�݂�ȁA���肪�Ƃ��I<br>
�肢�� <strong class="red">$heaven_day����</strong> �������āA��ւƓ͂��悤�ł��B<br>
EOM
}

# �߂郊���N��`

$back_link .= qq(<br>�����N - <a href="$home">$home_title�֖߂�</a>);
if($referer_url){
$back_link .= qq(�@<a href="$referer_url">���̃y�[�W�֖߂�</a>);
}


# ���E�\�N�𑝂₷
if($in{'action'}){ &plus_rousoku; $kaisetu = ""; $form = ""; }

# ���E�\�N��\������
&rousoku_set;


my $print = <<"EOM";
$pri_rousoku
<br><br>
$now_text
$kaisetu
$action_text
$form
$ads1
$back_link
�@�f�ޒ� - <a href="http://icon.blog61.fc2.com/blog-entry-30.html">�A�C�R�����̃t���[�f��</a>
 / <a href="http://skyline.skr.jp/">SkyLine -��̑f��-</a>
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# ���E�\�N��\������
#-----------------------------------------------------------

sub rousoku_set{

my($cnt1,$cnt10,$cnt100,$cnt1000);

# ���E�\�N�̖{�����T�C�Y���Ƃɐ�����
#$rousoku1000_num = int($rousoku_num / 1000);
#$rousoku100_num = int ( ($rousoku_num - ($rousoku1000_num * 1000) ) / 100 );

$rousoku100_num = int($rousoku_num / 100);
$rousoku10_num = int ( ($rousoku_num - ($rousoku1000_num * 1000) - ($rousoku100_num * 100) ) / 10 );
$rousoku1_num = $rousoku_num % 10;

# �P�O�O�O�{���E�\�N�𗧂Ă�
#while($cnt1000 < $rousoku1000_num)
#{
#$cnt1000++;
#$pri_rousoku .= qq(<img src="http://mb2.jp/pct/rousoku.gif" alt="���E�\\�N1000�{" class="rousoku1000">\n);
#}

# �P�O�O�{���E�\�N�𗧂Ă�
while($cnt100 < $rousoku100_num)
{
$cnt100++;
$pri_rousoku .= qq(<img src="http://mb2.jp/pct/rousoku.gif" alt="���E�\\�N100�{" class="rousoku100">\n);
}

# �P�O�{���E�\�N�𗧂Ă�
while($cnt10 < $rousoku10_num)
{
$cnt10++;
$pri_rousoku .= qq(<img src="http://mb2.jp/pct/rousoku.gif" alt="���E�\\�N10�{" class="rousoku10">\n);
}

# �P�{���E�\�N�𗧂Ă�
while($cnt1 < $rousoku1_num)
{
$cnt1++;
$pri_rousoku .= qq(<img src="http://mb2.jp/pct/rousoku.gif" alt="���E�\\�N1�{" class="rousoku1">\n);
}

}

#-----------------------------------------------------------
# ���E�\�N�𗧂Ă�
#-----------------------------------------------------------

sub plus_rousoku{

my($line,$cnt,$put_xip_list);

# �����擾
$time = time;

# ���E�\�N���}�b�N�X�̏ꍇ�A�������^�[��
if($heaven_mode){ return; }

# ���s�҂�XIP���A�����o�����C���ɒǉ�
$put_xip_list .= "${xip_enc},";

# �w�h�o�ŏd���`�F�b�N
foreach( split (/,/,$xip_list) ){
$cnt++;
if($cnt < $rousoku_xipcnt_max){ $put_xip_list .= "${_},"; }

# XIP�d���Ő������s�@�������A�O��̃��E�\�N���Ă��� 
# $lasttime�b �ȏ�o���Ă���ꍇ�́A�������Ő����Ȃ���

if(!$alocal_mode){
if($xip_enc eq $_ && $time < $lasttime + $rennzoku_sec){
$action_text = qq(<br><br>���Ă��郍�E�\\�N�́A�P�{���ł��B<br>
�ł炸�ɁA���΂炭���Ԃ�u���Ă���A�܂����Ă��������ˁB<br>);
return;
}

}

}

# ���b�N�J�n
&lock("rousoku") if($lockkey);

### �t�@�C���ɏ����o��
open(ROUSOKU_OUT,">${int_dir}_rousoku/rousoku_data.cgi");

# ���E�\�N�𑝂₷
$rousoku_num += 1;

$line = "$rousoku_num<>$put_xip_list<>$time<><>\n";
print ROUSOKU_OUT $line;
close(ROUSOKU_OUT);

# �����ύX
Mebius::Chmod(undef,"${int_dir}_rousoku/rousoku_data.cgi");

# ���m���ŁA�o�b�N�A�b�v����������
if(rand(10) < 1){
open(BACKUP_OUT,">${int_dir}_rousoku/rousoku_backup.cgi");
print BACKUP_OUT $line;
close(BACKUP_OUT);
# �����ύX
Mebius::Chmod(undef,"${int_dir}_rousoku/rousoku_backup.cgi");
}

# ���b�N����
&unlock("rousoku") if($lockkey);

# ���ݖ{���e�L�X�g��ύX
$now_text = qq(
���A$rousoku_num�{�̃��E�\\�N�������Ă��܂��B
<br><br>
);

# ���E�\�N�𗧂Ă���̃e�L�X�g���`
$action_text = qq(���Ȃ��̊肢�����߂āA���E�\\�N���P�{�����܂����B<br>
���΂炭�ڂ���āA<strong class="red">$rousoku_num�l���̊肢</strong>�Ɏv����y���Ă݂Ă��������B<br>);

}


1;

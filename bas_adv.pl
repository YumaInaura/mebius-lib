
# ��錾
use Mebius::Text;
#-----------------------------------------------------------
# ���r�A�h�@�����X�^�[�g
#-----------------------------------------------------------

sub start_adv{

# CSS
$style = "/style/bas.css";

# �Q�[�����x
$adv_speed = 2;

# �ݒ�
# �A���퓬
$adv_redun = 30*$adv_speed;
$adv_redun2 = 25*$adv_speed;

# �A���[�J���ݒ� 
if($alocal_mode){
$adv_redun = $adv_redun2 = 1;
$lv_up = 20;
@bstatus = @kiso_nouryoku = ("20","20","20","20","20","20","20");
}

# �A���[�J���E�Ǘ��Ґݒ�
if($alocal_mode || $myadmin_flag >= 5){
$ads1 = qq(<div style="border:solid 1px #000;width:728px;height:90px;"></div>);
}

# �t�@�C�� / �f�B���N�g����`
$chara_dir = "_charadata_adv/";

# CSS��`
$css_text .= qq(
body{margin:1em 0%;}
tr,td,th{border:1px #09f solid;font-weight:normal;padding:0.3em 0.4em;}
table{border:1px #09f solid;width:100%;margin:1em 0em;}
.zero{margin:0.25em;}
div.results{font-size:150%;line-height:1.8em;}
input.continue{font-size:110%;}
form.adv_clock{margin:1em 0em;}
input.adv_clock{border-style:none;width:2em;font-size:100%;color:#33f;font-weight:bold;text-align:center;}
b{color:#000;}
.hpcolor{color:#080;}
.goldcolor{color:#f00;}
.expcolor{color:purple;}
div.levelup{border:solid 1px #f99;padding:1em;margin:1em 0em;line-height:2.0em;color:#f00;}
strong.levelup{color:#f00;font-size:140%;}
div.adv_message{line-height:2.0em;}
tr.self{background:#ff9;}
tr.disable,option.disable{background:#ddd;}
tr.def{background:#ebe;}
tr.fit{background:#9f9;}
div.link_line{margin:1em 0em;}
);

# ���b�N�f�B���N�g��
if($alocal_mode){ $lock_dir = "../lock/"; }
else{ $lock_dir = "../../lock/"; }

# �^�C�g����`
$sub_title = $main_title;
$head_link2 = qq( &gt; <a href="$script">$main_title</a>);

# �N�b�L�[���擾
local($c_id,$c_pass,$cadv_monster,$cadv_charaid) = &adv_getcookie();
local($cadv_id,$cadv_pass) = ($c_id,$c_pass);

# ���_�C���N�g�p�̃��O�C����t�q�k
if($cadv_id && $cadv_pass){ $adv_login_url = "$script?mode=log_in"; }
else{ $adv_login_url = "$script?mode=log_in?id=$in{'id'}&amp;pass=$in{'pass'}"; }

# ���f�[�^��ǂݍ���
my($input_id,$input_pass) = ($cadv_id,$cadv_pass);
if($in{'id'} && $mode ne "chara"){ ($input_id,$input_pass) = ($in{'id'},$in{'pass'}); }
local($still_flag) = &adv_open($input_id,$input_pass,"MYDATA");
$mychara_flag = $still_flag;

# �`���[�W����
if($klasttime){ $kwaitsec = $klasttime + $adv_redun - $time; }

# �Q�[���𑱂���{�^��
if($mychara_flag){
$adv_continue_button = $continue_button = qq(
<br>
<form action="$script" method="post">
<div>
<input type="hidden" name="mode" value="log_in">
<input type="hidden" name="id" value="$input_id">
<input type="hidden" name="pass" value="$input_pass">
<input type="submit" value="�Q�[���𑱂���" class="continue">
</div>
</form>
);
}

# �G���[���̒ǉ��\����
$fook_error = qq($continue_button);

# �`�����v�f�[�^��ǂݍ���
local($winner_id,$winner_name,$winner_hp) = &adv_read_winner();
if($winner_id eq $kid){ $mychamp_flag = 1; }

# ���ʃ����N
$link_line .= qq(<div class="link_line">
<a href="$script">���r�A�h �s�n�o</a> / );
if($still_flag){ $link_line .= qq(<a href="$script?mode=log_in">���O�C��</a> / ); }
$link_line .= qq(<a href="$script?mode=item_shop">�A�C�e���V���b�v</a> /
<a href="$script?mode=joblist">�]�E</a> /
<a href="$script?mode=bank">��s</a> /
<a href="$script?mode=room">�s����</a> /
<a href="$script?mode=log">�틵</a> /
<a href="$script?mode=ranking">�����o�[���X�g</a> /
<a href="http://aurasoul.mb2.jp/_qst/2586.html">����^�c</a> /
<a href="http://aurasoul.mb2.jp/wiki/ring/%A5%E1%A5%D3%A5%EA%A5%F3%A5%A2%A5%C9%A5%D9%A5%F3%A5%C1%A5%E3%A1%BC">Wiki</a><br>
</div>
);

# �A�N�Z�X���O
&access_log("ADV");

#<a href="$script?mode=monster_list">�����X�^�[</a> / 

if($mente) { &error("���݃����e�i���X���ł��B���΂炭���҂����������B"); }
if($mode eq "") { &adv_html_top(); }
elsif($mode eq 'log_in') { require "${adv_dir}adv_login.pl"; &do_login(); }
elsif($mode eq 'chara_make') { require "${adv_dir}adv_newform.pl"; &do_adv_newform(); }
elsif($mode eq 'changedata') { require "${adv_dir}adv_changedata.pl"; &do_changedata(); }
elsif($mode eq 'changedata2') { require "${adv_dir}adv_changedata2.pl"; &do_changedata2(); }
elsif($mode eq 'make_end') { require "${adv_dir}adv_newform.pl"; &do_charamake(); }
elsif($mode eq 'regist') { require "${adv_dir}adv_open.pl"; &do_regist(); }
elsif($mode eq 'battle') { require "${adv_dir}adv_battle.pl"; &do_battle(); }
elsif($mode eq 'jobchange') { require "${adv_dir}adv_job.pl"; &do_jobchange(); }
elsif($mode eq 'joblist') { require "${adv_dir}adv_job.pl"; &view_joblist(); }
elsif($mode eq 'bank') { require "${adv_dir}adv_bank.pl"; &bank(); }
elsif($mode eq 'room') { require "${adv_dir}adv_room.pl"; &room(); }
elsif($mode eq 'monster') { require "${adv_dir}adv_battle.pl"; &do_battle(); }
elsif($mode eq 'ranking') { require "${adv_dir}adv_ranking.pl"; &do_view_ranking(); }
elsif($mode eq 'yado') { require "${adv_dir}adv_yado.pl"; &do_yado(); }
elsif($mode eq 'message') { require "${adv_dir}adv_message.pl"; &do_message(); }
elsif($mode eq 'item_shop') { require "${adv_dir}adv_item.pl"; &do_view_item(); }
elsif($mode eq 'monster_list') { require "${adv_dir}adv_vmonster.pl"; &monster_list(); }
elsif($mode eq 'special') { require "${adv_dir}adv_special.pl"; &special(); }
elsif($mode eq 'item_buy') { require "${adv_dir}adv_item.pl"; &do_buy_item(); }
elsif($mode eq 'edit') { require "${adv_dir}adv_edit.pl"; &do_edit(); }
elsif($mode eq 'log') { require "${adv_dir}adv_makelog.pl"; &alllog_view(); }
elsif($mode eq 'chara') { require "${adv_dir}adv_chara.pl"; &charaview(); }
elsif($mode eq 'record') { require "${adv_dir}adv_record.pl"; &adv_record_index(); }
else{ &adv_html_top(); }

}

#--------------------#
#  �`�����v�ǂݍ���  #
#--------------------#
sub adv_read_winner {
open(CHAMP_IN,"$winner_file");
@winner = <CHAMP_IN>;
close(CHAMP_IN);
($wid,$wname,$wcount,$wnhp) = split(/<>/,$winner[0]);
return($wid,$wname,$wcount,$wnhp);
}



#-------------------------------------------------
#  �N�b�L�[�̔��s 
#-------------------------------------------------
sub adv_setcookie {
local(@cook) = @_;
local($gmt, $cook, @t, @m, @w);

@t = gmtime(time + 7*24*60*60);
@m = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
@w = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');

# ���ەW�������`
$gmt = sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT",
$w[$t[6]], $t[3], $m[$t[4]], $t[5]+1900, $t[2], $t[1], $t[0]);

# �ۑ��f�[�^��URL�G���R�[�h
foreach (@cook) {
s/(\W)/sprintf("%%%02X", unpack("C", $1))/eg;
$cook .= "$_<>";
}

# �i�[
if($alocal_mode){ print "Set-Cookie: MEBI_ADV=$cook; expires=$gmt; \n"; }
else{ print "Set-Cookie: MEBI_ADV=$cook; expires=$gmt; path=/gap/ff/\n"; }
}

#-------------------------------------------------
# �N�b�L�[�擾
#-------------------------------------------------
sub adv_getcookie{
local($key, $val, *cook);

# �N�b�L�[���擾
$cook = $ENV{'HTTP_COOKIE'};

# �Y��ID�����o��
foreach ( split(/;/, $cook) ) {
($key, $val) = split(/=/);
$key =~ s/\s//g;
$cook{$key} = $val;
}

# �f�[�^��URL�f�R�[�h���ĕ���
foreach ( split(/<>/, $cook{'MEBI_ADV'}) ) {
s/%([0-9A-Fa-f][0-9A-Fa-f])/pack("H2", $1)/eg;

push(@cook,$_);
}
return (@cook);
}


#-----------------------------------------------------------
# ��{�ݒ�
#-----------------------------------------------------------
sub init_start_adv{

# �����e�i���X�p(���C���v���O����UP���F1)
# CGI�t�@�C���A�b�v���ɃA�N�Z�X���Ă���l������ꍇ���O�t�@�C����
# �����������ꍇ������܂��̂ł����ӂ��������B
$mente = 0;

#������������������������#
#��1. �t�@�C�����̐ݒ� ��#
#������������������������#

$ads1 = '<script type="text/javascript"><!--
google_ad_client = "pub-7808967024392082";
google_ad_width = 728;
google_ad_height = 90;
google_ad_format = "728x90_as";
google_ad_type = "text_image";
google_ad_channel ="6450439612";
google_color_border = "FFFFFF";
google_color_bg = "FFFFFF";
google_color_link = "3333FF";
google_color_text = "333333";
google_color_url = "3333FF";
//--></script>
<script type="text/javascript"
  src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>';

# ���C���X�N���v�g��
$script = "./ff.cgi";

# CGI�X�N���v�g�܂ł̐�΃p�X�ihttp://����j
$script_url = "http://aurasoul.mb2.jp/gap/ff/ff.cgi";

# �f�[�^�t�@�C����`
if($alocal_mode){ $chara_file  = "./chara_alocal.log"; }
else{ $chara_file  = "./chara.log"; }
$recode_file= './recode.log';
if($alocal_mode){ $winner_file= "./winner_alocal.log"; }
else{ $winner_file= "./winner.log"; }
$jobfile = $job_file= "./job1.dat";
$item_file = "./item1.dat";

#������������������������#
#��2. �Ǘ��l�֘A�̐ݒ� ��#
#������������������������#

# ���X�N���v�g�ւ̃����N
$original_maker = qq(<a href="http://webooo.csidenet.com/asvyweb/">Script-FFADV�����ψ���</a>��<a href="http://aurasoul.mb2.jp/">Edit-���r�E�X�����O</a>);

# �z�[���y�[�W�̃^�C�g��(���̓z�[���y�[�W�ɖ߂鎞�̖��O)
$home_title = "���r�����E�A�h�x���`���[";

# �^�C�g��
$title = $main_title = '���r�����E�A�h�x���`���[' ;


#��������������������������#
#��3. �L�����N�^�[�̐ݒ� ��#
#��������������������������#

# ��b�\�͒l(�ύX�s��)
@base_status = @bstatus = @kiso_nouryoku = ("9","8","8","9","9","8","8");
@base_status_name = ('��','�m�\\','�M�S','������','��p��','����','����');
@base_status_value = ("power","brain","believe","vital","tec","speed","charm");

#������������������������#
#��5. �f�[�^�֘A�̐ݒ� ��#
#������������������������#

# ���x���A�b�v�܂ł̌o���l�̐ݒ�
# ���x���~�l($lv_up)�����̃��x���܂ł̌o���l
$lv_up = 1000;

# �퓬�^�[���̐ݒ�
$turn = 20;

# ����s���A�I��퓬�Ȃǂ�L���ɂ��郍�O�C������
$adv_charaon_day = 7;

# �I��퓬���o����ő�HP�� ( �������ő�HP�� �`�{�Ⴂ����܂Ő킦�� )
$select_battle_gyap = 1.5;
$special_battle_gyap = 2;

# �L�����N�^�[���\���ɂ���܂ł̊���(��)
$reset_limit = 7;

# �A�C�e���������p���̂ɂ����邨�� ( ���x�� x G )
$itemguard_gold = 1000;

# �A������(�����X�^�[�Ɠ������)
$sentou_limit = 30;

# ��bHP
$kiso_hp = 20;

# ��b�o���l(�����Őݒ肵�����~����̃��x��)
$kiso_exp = 18;


}

#-----------------------------------------------------------
# Javascript �̎c�莞�ԕ\���A���_�C���N�g
#-----------------------------------------------------------
sub get_jsredirect{

my($line,$form);
my($second) = @_;

# �\���b�������������x�点��
$second += 1;

# �����X�V
$line = qq(
<script type="text/javascript">
<!--
var start=new Date();
start=Date.parse(start)/1000;
var counts=$second;
function CountDown(){
var now=new Date();
now=Date.parse(now)/1000;
var x=parseInt(counts-(now-start),10);
if(document.form1){document.form1.clock.value = x;}
if(x>0){
timerID=setTimeout("CountDown()", 100)
}
}
//-->
</script>
<script type="text/javascript">
<!--
window.setTimeout('CountDown()',100);
//-->
</script>
);

$jump_url = $adv_login_url;
$jump_sec = $second;

$form = qq(
<form name="form1" class="adv_clock">�`���[�W�� �c��<input type="text" name="clock" value="$second" class="adv_clock">�b�ł��B
<b class="red">���蓮�ŉ�ʂ��X�V���Ȃ��ł��������B</b>
</form>
);


return($line,$form);


}


#-------------------------------------------------
#  ��荞�ݏ���
#-------------------------------------------------
sub get_jobrank { require "${adv_dir}adv_job.pl"; &do_get_jobrank(@_); }
sub expgold { require "${adv_dir}adv_adjust.pl"; &do_expgold(@_); }
sub get_yadogold { require "${adv_dir}adv_yado.pl"; &do_get_yadogold(@_); }
sub get_charaview{ require "${adv_dir}adv_chara.pl"; &do_get_charaview(@_); }
sub makelog{ require "${adv_dir}adv_makelog.pl"; &do_makelog(@_); }
sub viewlog{ require "${adv_dir}adv_makelog.pl"; &do_viewlog(@_); }
sub select_job{ require "${adv_dir}adv_job.pl"; &do_select_job(@_); }
sub select_item{ require "${adv_dir}adv_item.pl"; &do_select_item(@_); }
sub get_charaids{ require "${adv_dir}adv_special.pl"; &do_get_charaids(@_); }
sub levelup { require "${adv_dir}adv_adjust.pl"; &do_levelup(@_); }
sub vmonster { require "${adv_dir}adv_vmonster.pl"; &do_vmonster(@_); }
sub hp_down{ require "${adv_dir}adv_hpdown.pl"; &do_adv_hp_down(@_); }
sub adv_html_top { require "adv_top.pl"; &do_adv_top(@_); }
sub adv_open{ require "${adv_dir}adv_open.pl"; &do_adv_open(@_); }
sub adv_get_editform{ require "${adv_dir}adv_chara.pl"; &do_adv_get_editform(@_); }
sub renew_charadata{ require "${adv_dir}adv_open.pl"; &do_renew_charadata(@_); }
sub get_allchara{ require "${adv_dir}adv_allchara.pl"; &do_get_allchara(@_); }
require "${adv_dir}adv_record.pl";

1;

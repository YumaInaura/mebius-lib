
# �A�C�f�B�A
# �P�ʁ`�R�ʂ̐l�ɂ́A���ʏ܋��A���݂P�O�O���v���[���g
# ���N���R���{
# ���N���D�G�ҁi�R���{���A���N�������j
# �X�e�[�^�X- ���H�A�U���A�������A��x�Q���܂����c�c
# ���N���҂��P���ɂP�O�O�l�𒴂�����A���l�����M

use Mebius::Export;

#-----------------------------------------------------------
# ��{�ݒ�
#-----------------------------------------------------------
sub init_start{

}


#-----------------------------------------------------------
# �����X�^�[�g
#-----------------------------------------------------------

sub start{

# �ݒ�
$early_starttime = 1257668046;
$title = $sub_title = "���傤�̑��N������";
$script = "./";
if($alocal_mode){ $script = "early.cgi"; }
else{ $style = '/style/blue1.css'; }
$head_link2 = qq( &gt; <a href="$script">$title</a> );
$moto = "early";
$early_dir = "${int_dir}_early/";
$head_link1 = qq(&gt; <a href="$base_url">���r�E�X�����O</a> | <a href="$goraku_url">��y��</a> );

# CSS��`
$css_text .= qq(
h1{text-align:center;}
h2{font-size:120%;}
h2.menu{clear:both;}
table,th,tr,td{border-style:none;}
table{width:100%;}
th{text-align:left;padding:0.2em 0.2em 0.2em 0.4em;}
td{padding:0.5em 0.5em 0.5em 0.2em;}
div.stamp,form.stamp{text-align:center;}
div.stamp{font-size:130%;line-height:0.8em;}
input{font-size:80%;}
input.stamp{font-size:90%;}
.ads{text-align:center;margin:auto;}
.adsname{padding:0.3em;font-size:80%;background-color:#dee;width:728px;margin:2.5em auto 1.0em auto;text-align:center;}
.ads_right{float:right;width:165px;padding-left:3px;}
.contents{float:left;}
);

$ads_top = qq(
<div class="ads">
<br><br>
<script type="text/javascript"><!--
google_ad_client = "pub-7808967024392082";
/* 728x15, ���N������ 09/11/08 */
google_ad_slot = "1470257233";
google_ad_width = 728;
google_ad_height = 15;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
</div>
);

$ads_right = qq(<script type="text/javascript"><!--
google_ad_client = "pub-7808967024392082";
/* 160x600, ���N������E 09/11/08 */
google_ad_slot = "9642307585";
google_ad_width = 160;
google_ad_height = 600;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
);

if($alocal_mode){ $ads_top = qq(<div class="adsname">�X�|���T�[�h�����N</div><div class="ads" style="width:728px;height:90px;border:solid 1px #000;">�L��</div>);
$ads_top = "";
}


# �J�n���ԁA�I������
$early_start_hour = 5;
$early_end_hour = 7;
$early_second_end_hour = 8;

# ���M���󂯓�����
if(($k_access || $cookie) && !$bot_access){ $main::device{'level'} = 1; }

# �X�^���v���󂯓�������
if($alocal_mode || ($thishour >= $early_start_hour && $thishour <= $early_end_hour) ){ $early_flag = 1; }
if($alocal_mode || ($thishour >= $early_start_hour && $thishour <= $early_second_end_hour) ){ $second_early_flag = 1; }

# ���[�h�U�蕪��
if($mode eq ""){ &index; }
elsif($submode1 eq "log"){ &index; }
elsif($mode eq "menu"){ &menu; }
elsif($mode eq "stamp"){ &stamp; }
else{ &error("�\\�����[�h���w�肵�Ă��������B$in{'mode'} ( $title )"); }

}

#-----------------------------------------------------------
# ���N����\��
#-----------------------------------------------------------

sub index{

# �Ǐ���
my($form,$i,$hit,$myhandle,$mycomment,$mystatus,$submit_value1,$myform_flag,$topage_flag);

# ���O���J�����t
my($early_year,$early_month,$early_day) = ($submode2,$submode3,$submode4);
if($mode eq ""){
$topage_flag = 1;
($early_year,$early_month,$early_day) = ($thisyear,$thismonth,$today);
} 

# �����`�F�b�N
$early_year =~ s/\D//g;
$early_month =~ s/\D//g;
$early_day =~ s/\D//g;



# �����̃t�@�C�����J��
open(TODAY_IN,"${early_dir}_log_early/$early_year-$early_month-$early_day.cgi");
my $top = <TODAY_IN>;
while(<TODAY_IN>){
$i++;
chomp;
my($mark,$mark_breakfast,$mark_brush,$mark_readbook,$mark_walk,$flag);
my($key,$handle,$id,$trip,$xip2,$number,$account,$status,$comment,$hour,$min,$sec) = split(/<>/);
my($breakfast,$brush,$readbook,$walk) = split(/,/,$status);

if($pmfile || $cnumber){
if($account ne "" && $account eq $pmfile){ $flag = 1; }
if($number ne "" && $number eq $cnumber){ $flag = 1; }
}
elsif($xip2 eq $xip){ $flag = 1; }

if($flag){
$myform_flag = 1;
($myhandle,$mycomment,$mystatus) = ($handle,$comment,$status);
($mybreakfast,$mybrush,$myreadbook,$mywalk) = ($breakfast,$brush,$readbook,$walk);
}
$hit++;
my $name = $handle;
if($trip ne ""){ $name = qq($name��$trip); }
if($account ne ""){ $name = qq(<a href="${auth_url}$account/">$name</a>); }
if($hit <= 3){
$mark = qq(<span class="fast1 red">�ŗD�G���N������B</span>) if($hit == 1);
$mark = qq(<span class="fast2 red">�Q�Ԗڑ��N������B</span>) if($hit == 2);
$mark = qq(<span class="fast3 red">�R�Ԗڑ��N������B</span>) if($hit == 3);
}
if($breakfast eq "1"){ $mark_breakfast = "��"; }
if($brush eq "1"){ $mark_brush = "��"; }
if($readbook eq "1"){ $mark_readbook = "��"; }
if($walk eq "1"){ $mark_walk = "��"; }
$line .= qq(<tr><td>$name</td><td><i>$id</i></td><td>$hour��$min��</td><td>$mark_breakfast</td><td>$mark_brush</td><td>$mark_readbook</td><td>$mark_walk</td><td>$mark</td></tr>);
}
close(TODAY_IN);

# ���e���Ȃ��ꍇ
if($mode ne "" && $line eq ""){ &error("���̓��̃��O�͂���܂���B"); }

# ���`
$line = qq(
<h2>���N���҃��X�g</h2>
<table summary="���C�A�E�g�e�[�u��">
<tr><td class="valign-top">
<table summary="���N���҃��X�g"><tr><th>�M��</th><th>ID</th><th>����</th><th>���H</th><th>������</th><th>�Ǐ�</th><th>�U��</th><th>��</th></tr>
$line
</table>
</td><td class="valign-top">
$ads_right</td></tr></table>
);

# ���M�{�^��
if($k_access){ $sumit_value1 = qq(���N�����܂����I); }
else{ $submit_value1 = qq($thishour��$thismin���A���N�����܂����I); }
if($k_access){ $submit_value2 = qq(���̏������܂����I); }
else{ $submit_value2 = qq(���̏������܂����I); }

# �����̓t�H�[��
if($myform_flag && $second_early_flag && $main::device{'level'} && $topage_flag){
my($check_breakfast,$check_readbook,$check_walk,$check_name,$check_submit,$hit);
if($mybreakfast eq "1"){ $check_breakfast = " checked disabled"; $hit++; }
if($mybrush eq "1"){ $check_brush = " checked disabled"; $hit++; }
if($myreadbook eq "1"){ $check_readbook = " checked disabled"; $hit++; }
if($mywalk eq "1"){ $check_walk = " checked disabled"; $hit++; }
#if($hit >= 4){ $check_submit = " disabled"; }

$form = qq(
<form action="$script" method="post" class="stamp"$sikibetu>
<div class="stamp">
<input type="hidden" name="mode" value="stamp">
<input type="hidden" name="name" value="$cnam">
<input type="checkbox" name="breakfast" value="1"$check_breakfast>���H
<input type="checkbox" name="brush" value="1"$check_brush>������
<input type="checkbox" name="readbook" value="1"$check_readbook>�Ǐ�
<input type="checkbox" name="walk" value="1"$check_walk>�U��
<br><br>
<input type="submit" value="$submit_value2" class="stamp"$check_submit>
</div>
</form>
);
}

# ���N���{�^���t�H�[��
elsif($early_flag && $main::device{'level'} && $topage_flag){
$form = qq(
<form action="$script" method="post" class="stamp"$sikibetu>
<div class="stamp">
<input type="hidden" name="mode" value="stamp">
�M�� <input type="text" name="name" value="$cnam"><br><br>
<input type="submit" value="$submit_value1" class="stamp">
<br><br>
<span class="alert">�����܂ŋN���Ă����l�͓o�^�����A�܂������`�������W���Ă��������B</span>
</div>
</form>
);
}

# ���Ԃ��߂��Ă���ꍇ
elsif($main::device{'level'}){
$form = qq(
<div class="stamp">
$early_start_hour��00���`$early_end_hour��59���܂ő��N���o�^�ł��܂��B
</div>
);

}

#<span class="guide">���{�^���������Ƒ��N�����Ԃ��L�^����܂��B������̂�$early_start_hour��00���`$early_end_hour��59���ł��B</span>

# �ߋ����O���j���[
my $other_menu = qq(<h2 class="menu">���j���[</h2><a href="$script?mode=menu">���܂ł̑��N������</a>);

# �^�C�g����`
if($mode eq ""){ $head_link2 = qq( &gt; $title ); }
else{
$head_link3 = qq( &gt; $early_year�N $early_month��$early_day�� );
$sub_title = qq($early_year�N$early_month��$early_day���̑��N������ | $title); 
}

# �\���^�C�g��
my $page_title = $title;
if($mode ne ""){ $page_title = "$early_year�N$early_month��$early_day���̑��N������"; }

# HTML
my $print = qq(
<h1>$page_title</h1>
$form
$ads_top
$line
$other_menu
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# ���j���[
#-----------------------------------------------------------
sub menu{

# �Ǐ���
my($line,$hit);

my $thistime = $time;

# ���t���X�g
while($thistime > $early_starttime){
$thistime -= 1*24*60*60;
my(undef,undef,$year,$month,$day) = Mebius::Getdate("",$thistime);
$hit++;
$line .= qq(<li><a href="log-$year-$month-$day.html">$year�N $month��$day�� �̑��N������</a>);
if($hit > 365){ last; }
}

# ���`
$line = qq(<ul>$line</ul>);

# �^�C�g����`
$sub_title = qq(���܂ł̑��N������ | $title);
$head_link3 = qq( &gt; ���܂ł̑��N������ );


# HTML
my $print = qq(
<h1>���܂ł̑��N������</h1>
$line
);

Mebius::Template::gzip_and_print_all({},$print);

exit;


}


#-----------------------------------------------------------
# �X�^���v������
#-----------------------------------------------------------
sub stamp{

# Cookie�Z�b�g���֎~
$no_headerset = 1;

# �Ǐ���
my(@line,$hit,$i_handle,$i_name,$i_handle,$enctrip,$i_name);

# GET���M���֎~
if(!$postflag){ &error("GET���M�͏o���܂���B"); }

# �����`�F�b�N
$in{'breakfast'} =~ s/\D//g;
$in{'brush'} =~ s/\D//g;
$in{'walk'} =~ s/\D//g;
$in{'readbook'} =~ s/\D//g;

# ���M���֎~
if(!$main::device{'level'}){ &error("���̊��ł͑��M�ł��܂���B"); }

# �A�N�Z�X����
&axscheck;

# �h�c������
&id;

# �g���b�v������
my($enctrip,$i_handle) = &trip($in{'name'});

# �e��G���[
if(!$second_early_flag){ &error("���̎��ԑт̓X�^���v�������܂���B"); }
require "${int_dir}regist_allcheck.pl";
($i_handle) = shift_jis(Mebius::Regist::name_check($i_handle));
#if($i_handle eq ""){ $i_handle = "���N������"; }
&error_view("AERROR");

# ���b�N�J�n
&lock($moto) if $lockkey;

# �^�C�g����`
$head_link3 = qq( &gt; �X�^���v������ );

# �����̃t�@�C�����J��
open(TODAY_IN,"${early_dir}_log_early/$thisyear-$thismonth-$today.cgi");

# TOP�f�[�^�̏���
my $top = <TODAY_IN>; chomp $top;
my($none) = split(/<>/,$top);

while(<TODAY_IN>){
chomp;
my($key,$handle,$id,$trip,$xip2,$number,$account,$status,$comment,$hour,$min,$sec) = split(/<>/);
my($breakfast,$brush,$readbook,$walk) = split(/,/,$status);
my($flag);

if($pmfile || $cnumber){
if($account ne "" && $account eq $pmfile){ $flag = 1; }
if($number ne "" && $number eq $cnumber){ $flag = 1; }
}
elsif($xip2 eq $xip){ $flag = 1; }

if($flag){
if($in{'name'}){ ($handle,$trip) = ($i_handle,$enctrip); }
($id,$account,$xip2) = ($encid,$pmfile,$xip);
if($in{'breakfast'} eq "1"){ $breakfast = 1; }
if($in{'brush'} eq "1"){ $brush = 1; }
if($in{'readbook'} eq "1"){ $readbook = 1; }
if($in{'walk'} eq "1"){ $walk = 1; }
$status = "$breakfast,$brush,$readbook,$walk";
$hit = 1;
}
push(@line,"$key<>$handle<>$id<>$trip<>$xip2<>$number<>$account<>$status<>$comment<>$hour<>$min<>$sec<>\n");
}
close(TODAY_IN);

# �V�K�o�^�̏ꍇ
if(!$hit){ push(@line,"1<>$i_handle<>$encid<>$enctrip<>$xip<>$cnumber<>$pmfile<>$status<>$comment<>$thishour<>$thismin<>$thissec<>\n"); }

# �g�b�v�f�[�^��ǉ�
unshift(@line,"$none<>\n");

# �t�@�C������������
open(TODAY_OUT,">${early_dir}_log_early/$thisyear-$thismonth-$today.cgi");
print TODAY_OUT @line;
close(TODAY_OUT);
Mebius::Chmod(undef,"${early_dir}_log_early/$thisyear-$thismonth-$today.cgi");

# ���b�N����
&unlock($moto) if $lockkey;

# Cookie ���Z�b�g
Mebius::Cookie::set_main({ name => $in{'name'} },{ SaveToFile => 1 });

# �W�����v��
$jump_url = "$script";
$jump_sec = 1;


# HTML
my $print =  qq(�X�^���v�������܂����I�i<a href="$script">���߂�</a>�j);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



1;


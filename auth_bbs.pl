package main;
use Mebius::Export;

#-------------------------------------------------
# �a�a�r�̋L���\��
#-------------------------------------------------
sub auth_bbs{

# �Ǐ���
my($file,$ads1,$ads2,$form,$open,$deleted_flag,$adsflag,$onlyflag,$link1,$link2);

# ��`
my $maxmsg = 2500;

# �P�L��������̃��X�̍ő�\����
my $maxview_res = 50;

# �b�r�r��`
$css_text .= qq(
.date{text-align:right;}
.dtextarea{width:95%;height:200px;}
.maxmsg{color:#f00;font-size:90%;}
.deleted{color:#f00;font-size:120%;}
.cdeleted{color:#f00;font-size:80%;}
a.me:link{color:#f00;}
a.me:visited{color:#f40;}
h1{color:#f50;}
);

# �����`�F�b�N�P
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("�J���t�@�C�����w�肵�Ă��������B"); }

# �����`�F�b�N�Q
$open = $submode2;
$open =~ s/\D//g;
if($open eq ""){ &error("�J���t�@�C�����w�肵�Ă��������B"); }

# �v���t�B�[�����J��
&open($file);


# ���[�U�[�F�w��
if($ppcolor1){
$css_text .= qq(h2{background-color:#$ppcolor1;border-color:#$ppcolor1;});
}

# �}�C���r��Ԏ擾
&checkfriend($file);

# BBS�̕\������
if($pplevel >= 1 || !$mebi_mode){
if($pposbbs eq "2"){
if(!$yetfriend && !$myprof_flag && !$myadmin_flag){ &error("���L�����݂��܂���B"); }
$text1 = qq(<em class="green">��$friend_tag�����ɋL�����J���ł�</em><br><br>);
$onlyflag = 1;
}
elsif($pposbbs eq "0"){
if(!$myprof_flag && !$myadmin_flag){ &error("���L�����݂��܂���B"); }
$text1 = qq(<em class="red">�����������ɋL�����J���ł�</em><br><br>);
$onlyflag = 1;
}
}

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �L���t�@�C�����J��
open(BBS_IN,"<","${account_directory}bbs/${file}_bbs_${open}.cgi") || &error("�L�������݂��܂���B");

my $dtop1 = <BBS_IN>;
my($key,$num,$sub,$res,$dates) = split(/<>/,$dtop1);
my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);
$pageyear = $year;
$pagemonth = $month;
$pagenum = $num;
$keydtop1 = $key;


# �L���{�̂��폜�ς݂̏ꍇ
if($keydtop1 eq "2" || $keydtop1 eq "4"){
if($myadmin_flag) { $deleted_flag = qq(<strong class="deleted">���̋L���͍폜�ς݂ł��i�Ǘ��҂̂݉{���\\�j</strong><br><br>); }
else{ &error("���̋L���͍폜�ς݂ł��B","410 Gone"); }
}

# �㕔�i�r�����N
$link1 .= $text1;
$link1 .= $deleted_flag;

$link2 = "$adir${file}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
$link1 .= qq(<a href="$link2">�v���t�B�[����</a>);

if($file eq $pmfile || $myadmin_flag){
if($keydtop1 eq "1"){ $link1 .= qq( - <a href="$script?mode=keditbbs&amp;account=$file&amp;num=$open&amp;decide=lock">�R�����g���b�N</a>); }
elsif($keydtop1 eq "0"){ $link1 .= qq( - <a href="$script?mode=keditbbs&amp;account=$file&amp;num=$open&amp;decide=revive">�R�����g���b�N����</a>); }
if($keydtop1 eq "2" || $keydtop1 eq "4"){ $link1 .= qq( - <a href="$script?mode=keditbbs&amp;account=$file&amp;num=$open&amp;decide=revive">�L���̕���</a>); }
else{ $link1 .= qq( - <a href="$script?mode=keditbbs&amp;account=$file&amp;num=$open&amp;decide=delete&amp;preview=on">�L���̍폜</a>); }
}

$link1 .= qq( - <a href="${guide_url}%BA%EF%BD%FC%B0%CD%CD%EA%A1%CA%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A1%CB">�폜�˗��ɂ���</a>);

if($alocal_mode){ $link1 = &aurl($link1); }

$bbs .= qq(<h1>$sub - BBS</h1>$link1<h2>�{��</h2>);

while(<BBS_IN>){

chomp $_; if(!$_){ next; }
my($key,$num,$account,$name,$id,$trip,$comment,$dates) = split(/<>/,$_);
my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);

my $link = qq($adir${account}/);
if($aurl_mode){ ($link) = &aurl($link); }

if($num eq "1"){
$bbs .= qq(<h2>�R�����g</h2>);
if($res > $maxview_res && $submode3 ne "all"){
my $cut = $res - $maxview_res;
my $link = "$adir$file/b-$open-all";
if($aurl_mode){ ($link) = &aurl($link); }
$bbs .= qq(�i <a href="$link">$cut���̃��X���ȗ�����Ă��܂�</a> �j<br><br>);

}
}

$iline++;
if($iline != 1 && $iline <= $res - $maxview_res + 1 && $submode3 ne "all"){ next; }

# �ʏ�\���̏ꍇ
if($key eq "1"){
($comment) = &auth_auto_link($comment);
my($delete,$class);
if($account eq $file){ $class = qq( class="me"); }
if($myadmin_flag || $file eq $pmfile || $account eq $pmfile){ $delete = qq(<a href="$script?mode=skeditbbs&amp;account=$file&amp;num=$open&amp;number=$num&amp;decide=delete">�폜</a> - ); }
$bbs .= qq(<p id="S$num"><a href="$link"$class>$name - $account</a><br><br>$comment</p><div class="date">$delete$year�N$month��$day�� $hour��$min�� No.$num</div>);
if($key eq "1" && $adsflag1 < 2 && $num eq "0" && !$noads_mode){ $bbs .= qq($ads1); $adsflag1++; }
elsif($key eq "1" && $adsflag2 < 2 && $num eq $res && !$noads_mode){ $bbs .= qq($ads2); $adsflag2++; }
}

# �폜�ς݂̏ꍇ
else{
my($deleted);
if($key eq "3"){ $deleted = qq(���e�҂ɂ��폜); }
elsif($key eq "2"){ $deleted = qq(�A�J�E���g��ɂ��폜); }
elsif($key eq "4"){ $deleted = qq(�Ǘ��҂ɂ��폜); }
if($myadmin_flag){ $deleted .= qq(<br><br><span class="cdeleted">$comment<br>�i�폜�ς݁B�Ǘ��҂ɂ��������܂� - <a href="$script?mode=skeditbbs&amp;account=$file&amp;num=$open&amp;number=$num&amp;decide=revive">����</a>�j</span>); }
$bbs .= qq(<p id="S$num">$account <a href="$link">*</a><br><br>$deleted</p><div class="date">$year�N$month��$day�� $hour��$min�� No.$num</div>);
}

# ��؂��
if($num >= 1 && $num ne $res){ $bbs .= qq(<hr>); }

}
close(BBS_IN);

	Mebius::Fillter::fillter_and_error(utf8_return($sub));

my($form) = &auth_bbs_getform("",$file,$open);

# �^�C�g����`
$sub_title = qq($sub);


my $print = <<"EOM";
$footer_link

$bbs

$form
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-------------------------------------------------
# �L���̃R�����g�t�H�[��
#-------------------------------------------------

sub auth_bbs_getform{

return("���݁ABBS�ɂ͏������ނ��Ƃ��o���܂���B");

# �Ǐ���
my($type,$file,$open) = @_;
my($stop,$form);

# �R�����g�ۂ̔���
if($ppkey eq "2"){ $form .= qq(���A�J�E���g�����b�N���̂��ߏ������߂܂���<br><br>); $stop = 1; }
elsif($denyfriend){ $form .= qq(���֎~�ݒ蒆�̂��߃R�����g�ł��܂���B<br><br>); $stop = 1; }
elsif($ppobbs eq "0"){
$form .= qq(���A�J�E���g�傾�����R�����g�ł��܂��B<br><br>);
if(!$myprof_flag){ $stop = 1; }
}
elsif($key eq "0"){ $form .= qq(�����̋L���̓R�����g���b�N���̂��߁A�������߂܂���B<br><br>); $stop = 1; }
elsif($ppobbs eq "2"){ $form .= qq(��$friend_tag�������R�����g�ł��܂��B<br><br>); 
if(!$yetfriend && !$myprof_flag){ $stop = 1; } 
}

# �Ǘ��҂̏ꍇ
if($myadmin_flag){ $stop = ""; }

# �M�����ݒ�̏ꍇ
if($res >= $maxres_bbs){ $form = qq(���R�����g�������ς��ł��B�i�ő�$maxres_bbs���j<br><br>); $stop = 1; }
elsif(!$idcheck){ $form = qq(���R�����g����ɂ�<a href="$auth_url">���O�C���i�܂��͐V�K�o�^�j</a>���Ă��������B<br><br>); $stop = 1; }
elsif($birdflag){ $form = qq(���R�����g����ɂ�<a href="$auth_url$pmfile/#EDIT">���Ȃ��̕M��</a>��ݒ肵�Ă��������B<br><br>); $stop = 1; }


# �R�����g�t�H�[�����o��
$form = qq(<h2>�R�����g�t�H�[��</h2>$form);

# �t�H�[����`
if(!$stop){
$form .= <<"EOM";
<form action="$action" method="post"$sikibetu>
<div>
$ipalert<br>
<textarea name="comment" class="dtextarea" cols="25" rows="5"></textarea>
<br><br><input type="submit" value="���̓��e�ŃR�����g����"> <strong class="maxmsg">(�S�p$maxmsg�����܂�)</strong>
<input type="hidden" name="mode" value="resbbs">
<input type="hidden" name="account" value="$file">
<input type="hidden" name="num" value="$open">
<br><br>
</div>
</form>
EOM
}

return($form);

}



1;

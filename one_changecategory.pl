
# �J�e�S�����̍ő啶����
my $maxlength = 20;
# �J�e�S�������̍ő啶����
my $maxcatelength = 200;

# �Ǐ���
my($line,$flag,$line_all,$i_all,$file,$put_category,$line_new,$put_date,$upcate_line);

# �e��G���[
if(!$postflag){ &error("GET���M�͏o���܂���B"); }
if(!$idcheck){ &error("�������ނɂ̓��O�C���i�܂���<a href=\"start.html\">�V�K�o�^</a>�j���Ă��������B"); }

# ���e����
($host) = &axscheck();

# �e��G���[
require "${int_dir}regist_allcheck.pl";
($in{'new_category'}) = &base_change($in{'new_category'});
&length_check($in{'new_category'},"�J�e�S����",$maxlength,1);
&url_check("",$in{'new_category'});
&error_view;

# �������̃`�F�b�N
if($in{'guide'}){
($in{'guide'}) = &base_change($in{'guide'});
&length_check($in{'guide'},"�J�e�S������",$maxcatelength,0);
&url_check("",$in{'guide'});
}

# �t�@�C����`�P
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;
if(!$file){ &error("�f�[�^���ςł��B"); }
if($file ne $pmfile && !$myadmin_flag){ &error("�����ł͂���܂���B"); }

# �t�@�C����`�Q
$num = $in{'num'};
$num =~ s/\D//g;
if(!$num){ &error("�f�[�^���ςł��B"); }

# ���b�N�J�n
&lock("${file}ONE") if $lockkey;

# ��{�t�@�C�����J��
&base_open($file);

# �t�@�C�����Ȃ��ꍇ
if($key_base ne "1"){ &error("�t�@�C�������݂��܂���B"); }

# �V�J�e�S���̏���
my $new_category = $in{'new_category'};

# �R�����g�t�@�C�����J��
my($i);
open(COMMENT_IN,"${int_dir}_one/_idone/${file}/${num}_ocm.cgi");
my $top_comment = <COMMENT_IN>;
chomp $top_comment;
my($key_ocm,$sub_ocm,$date_ocm,$xip_ocm,$cnumber_ocm,$host_ocm,$guide_ocm) = split(/<>/,$top_comment);
while(<COMMENT_IN>){ $line .= $_; }
close(COMMENT_IN);

# �폜�ς݂̏ꍇ
if($key_ocm eq "2"){ &error("�폜�ς݂̃J�e�S���ł��B"); }

# �J�e�S�����O�̃v���r���[
if($in{'close'} && !$in{'break'}){ &preview_close; }

# �L�[�ύX
if($in{'close'}){ $key_ocm = 2; }

# �J�e�S���t�@�C�����J��
open(CATE_IN,"${int_dir}_one/_idone/${file}/${file}_cate.cgi");
while(<CATE_IN>){
chomp $_;
my($category,$num2,$key) = split(/<>/,$_);

if($category eq $in{'new_category'} && $sub_ocm ne $in{'new_category'}){ &error("���̃J�e�S���͓o�^�ς݂ł��B"); }
if($num2 eq $num){
$flag = 1;
if($in{'close'}){ next; }
$category = $new_category;
if($in{'up'}){ $upcate_line = qq($category<>$num2<>$key<>\n); next; }
}
$cate_line .= qq($category<>$num2<>$key<>\n);
}
close(CATE_IN);
if(!$flag){ &error("�J�e�S�������݂��܂���B"); }

# �ǉ�����s�i�R�����g�t�@�C���j
my $top_line .= qq($key_ocm<>$new_category<>$date<>$xip<>$cnumber<>$host<>$in{'guide'}<>\n);

# �R�����g�t�@�C���ɏ�������
open(COMMENT_OUT,">${int_dir}_one/_idone/${file}/${num}_ocm.cgi");
print COMMENT_OUT "$top_line$line";
close(COMMENT_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${file}/${num}_ocm.cgi");

# �J�e�S���t�@�C���ɏ�������
open(CATE_OUT,">${int_dir}_one/_idone/${file}/${file}_cate.cgi");
print CATE_OUT "$upcate_line$cate_line";
close(CATE_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${file}/${file}_cate.cgi");

# �폜�ς݃J�e�S���t�@�C�����J��
my $delcate_line .= qq($sub_ocm<>${file}<>\n);
if($in{'close'}){
open(DELCATE_IN,"${int_dir}_one/_idone/${file}/${file}_delcate.cgi");
while(<DELCATE_IN>){ $delcate_line .= $_; }
close(DELCATE_IN);
}

# �폜�ς݃J�e�S���t�@�C���ɏ�������
if($in{'close'}){
open(DELCATE_OUT,">${int_dir}_one/_idone/${file}/${file}_delcate.cgi");
print DELCATE_OUT "$delcate_line";
close(DELCATE_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${file}/${file}_delcate.cgi");
}

# �S�R�����g�t�@�C�����J���i�J�e�S�����̏ꍇ�j
my($allocm_line,$top_allocm);
if($in{'close'}){
open(ALLOCM_IN,"${int_dir}_one/_idone/${file}/all_ocm.cgi");
$top_allocm = <ALLOCM_IN>;
while(<ALLOCM_IN>){
chomp $_;
my($key,$comment,$date,$res,$num2,$category) = split(/<>/,$_);
if($num2 eq $num){ $key = 2; }
$allocm_line .= qq($key<>$comment<>$date<>$res<>$num2<>$category<>\n);
}
close(ALLOCM_IN);
}

# �폜�ς݃J�e�S���t�@�C���ɏ������ށi�J�e�S�����̏ꍇ�j
if($in{'close'}){
open(ALLOCM_OUT,">${int_dir}_one/_idone/${file}/all_ocm.cgi");
print ALLOCM_OUT "$top_allocm$allocm_line";
close(ALLOCM_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${file}/all_ocm.cgi");
}


# ���b�N����
&unlock("${file}ONE") if $lockkey;

# ���_�C���N�g
if($in{'close'}){
if($alocal_mode){ print qq(location:$script?mode=view-$file-all-1\n\n); }
print qq(location:view-$file-all-1.html\n\n);
}

if($alocal_mode){ print qq(location:$script?mode=view-$file-$num-1\n\n); }
print qq(location:view-$file-$num-1.html\n\n);

#-----------------------------------------------------------
# �J�e�S�����O�̃v���r���[
#-----------------------------------------------------------
sub preview_close{


# ���b�N����
&unlock("${file}ONE") if $lockkey;


$css_text .= qq(
li{color:#f00;}
);


my $print = qq(
<h1>�J�e�S���폜</h1>

<form action="$action" method="post"$sikibetu>
<div>
<a href="view-$pmfile-$in{'num'}-1.html">$sub_ocm</a>�̃J�e�S�����폜����O�ɁA���̐������������������B

<br>
<br>

<strong class="red">��������</strong>
<br><br>
<ul>
<li><strong>�J�e�S�����̃R�����g���S�č폜����܂��B</strong>
<li><strong>�P�x�폜�����J�e�S���́A���ɂ͖߂��܂���B</strong>
</ul>
<br>

��낵���ł����H<br><br>
<input type="checkbox" name="break" value="1"> �͂��A��肠��܂���B
<input type="hidden" name="mode" value="change_category">
<input type="hidden" name="new_category" value="$sub_ocm">
<input type="hidden" name="guide" value="$guide_ocm">
<input type="hidden" name="num" value="$in{'num'}">
<input type="hidden" name="account" value="$in{'account'}">
&nbsp;<input type="submit" value="�J�e�S���������">
<input type="hidden" name="close" value="1">
</div>
</form>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;

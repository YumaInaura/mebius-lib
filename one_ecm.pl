
# �Ǐ���
my($line,$view_comment,$flag,$color_select,$newcolor);

# CSS��`
$css_text .= qq(
.input_text{width:30em;}
);

# Body�^�O��JavaScript
$body_javascript = qq( onload="document.form1.comment.focus()");

# �t�@�C����`
my $file = $in{'account'};
$file =~ s/[^a-z0-9]//g;
if($file eq ""){ &error("�A�J�E���g�����݂��܂���B"); }

# �����`�F�b�N
my $num = $in{'num'};
$num =~ s/\D//g;
if($num eq ""){ &error("�ҏW����J�e�S�����w�肵�Ă��������B"); }

my $res = $in{'res'};
$res =~ s/\D//g;
if($res eq ""){ &error("�ҏW����i���o�[���w�肵�Ă��������B"); }

# ��{�t�@�C�����J��
&base_open($file);

# �G���[
if($key_base ne "1"){ &error("�y�[�W�����݂��܂���B"); }
if($file ne $pmfile && !$myadmin_flag){ &error("�����ł͂���܂���B"); }

# �R�����g�t�@�C�����J��
open(DATA_IN,"${int_dir}_one/_idone/$file/${num}_ocm.cgi") || &error("�y�[�W�����݂��܂���B");
my $top_data = <DATA_IN>;
my($key_ocm,$sub_ocm,$date_ocm,$xip_ocm,$cnumber_ocm,$host_ocm,$guide_ocm) = split(/<>/,$top_data);

# �L�[�ɂ���ď����ύX
if($key_ocm eq "2"){ &error("���̃J�e�S���͍폜�ς݂ł��B"); }

# �ҏW���e���`
my $new_comment = $in{'comment'};

# �F�̃`�F�b�N
if($in{'color'}){
$newcolor = $in{'color'};
$newcolor =~ s/\W//g;
if(length($newcolor) > 3){ &error("�F�w�肪�ςł��B"); }
}

# �R�����g�t�@�C���W�J
while(<DATA_IN>){
chomp $_;
my($key,$comment,$date,$res2,$color) = split(/<>/,$_);
if( ($key eq "1" || $key eq "4") && $res2 eq $res){ $view_comment = qq($comment); $view_color = $color; $comment = $new_comment; $color = $newcolor; $flag = 1; }
$line .= qq($key<>$comment<>$date<>$res2<>$color<>\n);
}
close(DATA_IN);

# �G���[
if(!$flag){ &error("�R�����g������܂���B"); }

# �ҏW���s
if($postflag && $in{'action'}){ &edit_comment; }


# �����F�̒�`
$color_select .= qq(<select name="color"><option value="">����);
foreach(@color){
my($name,$code) = split(/=/,$_);
if($view_color eq $code){ $color_select .= qq(<option value="$code" style="color:#$code;" selected>$name\n); }
else{ $color_select .= qq(<option value="$code" style="color:#$code;">$name\n); }
}
$color_select .= qq(</select>);


# HTML
my $print = qq(
<h1>�ҏW</h1>

<a href="view-$file-$num-1.html">$sub_ocm</a> &gt; No.$res<br><br>

<form action="$action" method="post" name="form1"$sikibetu>
<div>
<input type="text" name="comment" value="$view_comment" class="input_text">
$color_select

<input type="hidden" name="mode" value="ecm">
<input type="hidden" name="num" value="$num">
<input type="hidden" name="res" value="$res">
<input type="hidden" name="account" value="$file">
<input type="submit" name="action" value="�ҏW����">

</div>
</form>

);

Mebius::Template::gzip_and_print_all({},$print);

exit;

#-----------------------------------------------------------
# ���e�ҏW
#-----------------------------------------------------------

sub edit_comment{

# �Ǐ���
my($line_allocm);

# ���e����
&axscheck;

# �e��`�F�b�N
require "${int_dir}regist_allcheck.pl";
&length_check($in{'comment'},"���e",500,1);
&url_check("",$in{'comment'});
&error_view;

# ���b�N�J�n
&lock("${file}ONE") if $lockkey;

# �R�����g�t�@�C������������
open(OCM_OUT,">${int_dir}_one/_idone/$file/${num}_ocm.cgi") || &error("�y�[�W�����݂��܂���B");
print OCM_OUT "$top_data$line";
close(OCM_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/$file/${num}_ocm.cgi");

# �S�R�����g�t�@�C�����J��
open(ALLOCM_IN,"${int_dir}_one/_idone/$file/all_ocm.cgi");
my $top_allocm = <ALLOCM_IN>;
while(<ALLOCM_IN>){
chomp $_;
my($key,$comment,$date,$res2,$num2,$category,$color) = split(/<>/,$_);
if($res2 eq $res && $num2 eq $num){ $comment = $new_comment; $color = $newcolor; }
$line_allocm .= qq($key<>$comment<>$date<>$res2<>$num2<>$category<>$color<>\n);
}
close(ALLOCM_IN);

# �S�R�����g�t�@�C������������
open(OCM_OUT,">${int_dir}_one/_idone/$file/all_ocm.cgi");
print OCM_OUT "$top_allocm$line_allocm";
close(OCM_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/$file/all_ocm.cgi");


# ���b�N����
&unlock("${file}ONE") if $lockkey;

if($alocal_mode){  print "location:$script?mode=view-$file-$num-1\n\n"; }
else{ print "location:view-$file-$num-1.html\n\n"; }

exit;

}

1;


# �Ǐ���
my($line,$flag,$line_allocm,$check_date);

# �m�F
#if(!$in{'do'}){ &preview; }

# �t�@�C����`�P
my $file = $in{'account'};
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("�y�[�W�����݂��܂���B"); }

# �t�@�C����`�Q
my $num = $in{'num'};
$num =~ s/\D//g;
if($num eq ""){ &error("�폜����J�e�S�����w�肵�Ă��������B"); }

# �t�@�C����`�R
my $res = $in{'res'};
$res =~ s/\D//g;
if($res eq ""){ &error("�폜����i���o�[���w�肵�Ă��������B"); }

# �����̃A�J�E���g�ł͂Ȃ��ꍇ
if($pmfile ne $file && !$myadmin_flag){ &error("�������Ⴀ��܂���B"); }

# ���b�N�J�n
&lock("${pmfile}ONE") if $lockkey;

# ��{�t�@�C�����J��
&base_open($file);

# �R�����g�t�@�C�����J��
open(OCM_IN,"${int_dir}_one/_idone/${file}/${num}_ocm.cgi") || &error("�y�[�W�����݂��܂���B");
my $top_data = <OCM_IN>;
while(<OCM_IN>){
chomp $_;
my($key,$comment,$date,$res2,$color) = split(/<>/,$_);
if($key eq "1" && $res2 eq $res){ $flag = 1; $key = 2; }
if($key eq "4" && $res2 eq $res){ $flag = 1; $key = 5; }
$line .= qq($key<>$comment<>$date<>$res2<>$color<>\n);
}
close(OCM_IN);

# �S�R�����g�t�@�C�����J��
open(ALLOCM_IN,"${int_dir}_one/_idone/${file}/all_ocm.cgi");
my $top_data_allocm = <ALLOCM_IN>;
while(<ALLOCM_IN>){
chomp $_;
my($key,$comment,$date,$res2,$num2,$category2,$color) = split(/<>/,$_);
if($key eq "1" && $res2 eq $res && $num2 eq $num){ $check_date = $date; $key = 2; $flag = 1; }
if($key eq "4" && $res2 eq $res && $num2 eq $num){ $check_date = $date; $key = 5; $flag = 1; }
$line_allocm .= qq($key<>$comment<>$date<>$res2<>$num2<>$category2<>$color<>\n);
}
close(ALLOCM_IN);

# �폜������e���Ȃ������ꍇ
if(!$flag){ &error("�폜������e������܂���B"); }

# �R�����g�t�@�C������������
open(OCM_OUT,">${int_dir}_one/_idone/${file}/${num}_ocm.cgi");
print OCM_OUT "$top_data$line";
close(OCM_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${file}/${num}_ocm.cgi");

# �S�R�����g�t�@�C������������
open(ALLOCM_OUT,">${int_dir}_one/_idone/${file}/all_ocm.cgi");
print ALLOCM_OUT "$top_data_allocm$line_allocm";
close(ALLOCM_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${file}/all_ocm.cgi");

# �V���R�����g�t�@�C�����J��
open(NEW_COMMENT_IN,"${int_dir}_one/new_comment.cgi");
while(<NEW_COMMENT_IN>){
chomp $_;
my($key,$comment,$date,$account,$num2,$category,$name) = split(/<>/,$_);
if($account eq $file && $num2 eq $num && $date eq $check_date){
if($key eq "1" || $key eq "3"){ $key = 2; }
}
$line_new .= qq($key<>$comment<>$date<>$account<>$num2<>$category<>$name<>\n);
}
close(NEW_COMMENT_IN);

# �V���R�����g�t�@�C���ɏ�������
open(NEW_COMMENT_OUT,">${int_dir}_one/new_comment.cgi");
print NEW_COMMENT_OUT $line_new;
close(NEW_COMMENT_OUT);
Mebius::Chmod(undef,"${int_dir}_one/new_comment.cgi");

# ���b�N����
&unlock("${pmfile}ONE") if $lockkey;

# �W�����v���`
if($alocal_mode){
if($in{'back'} eq "all"){ $jump_url = "$script?mode=view-$file-all-1"; }
else{ $jump_url = "$script?mode=view-$file-$num-1"; }
}
else{
if($in{'back'} eq "all"){ $jump_url = "view-$file-all-1.html"; }
else{ $jump_url = "view-$file-$num-1.html"; }
}

# ���_�C���N�g
print "location:$jump_url\n\n";

exit;


#-----------------------------------------------------------
# �폜�O�̊m�F
#-----------------------------------------------------------
sub preview{

my $print = qq(
<a href="$script?mode=del&amp;account=$in{'account'}&amp;num=$in{'num'}&amp;res=$in{'res'}&amp;do=1">�폜����</a>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;


}

1;

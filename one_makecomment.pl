

# �ŏ�������
my $minmsg = 1;
# �ő啶����
my $maxmsg = 500;
# �S�J�e�t�@�C���̍ő�s��
my $maxall = 100;
# �P�R�����g�t�@�C��������̍ő�s��
my $maxline = 1000;
# �V���R�����g�t�@�C���̍ő�s��
my $maxnew = 250;

# �Ǐ���
my($line,$flag,$line_all,$i_all,$file,$put_category,$line_new,$put_date,$key_all,$newcolor);

# �e��G���[
if(!$postflag){ &error("GET���M�͏o���܂���B"); }
if(!$idcheck){ &error("�������ނɂ́A<a href=\"$auth_url\">���r�����r�m�r</a>�Ƀ��O�C���i�܂��͐V�K�o�^�j���Ă��������B"); }

# ���e����
($host) = &axscheck();

# �e��G���[�`�F�b�N
require "${int_dir}regist_allcheck.pl";
&length_check($in{'comment'},"���e",$maxmsg,1);
&url_check("",$in{'comment'});
($in{'comment'}) = &base_change($in{'comment'});
&error_view;

# �F�̃`�F�b�N
if($in{'color'}){
$newcolor = $in{'color'};
$newcolor =~ s/\W//g;
if(length($newcolor) > 3){ &error("�F�w�肪�ςł��B"); }
}

# ���b�N�J�n
&lock("${pmfile}ONE") if $lockkey;

# ��{�t�@�C�����J��
&base_open($pmfile);

# �t�@�C�����Ȃ��ꍇ
if($key_base ne "1"){ &error("�t�@�C�������݂��܂���B"); }

# �J�e�S���L�^�t�@�C�����J��
open(CATE_IN,"${int_dir}_one/_idone/${pmfile}/${pmfile}_cate.cgi");
while(<CATE_IN>){
my($category,$num) = split(/<>/,$_);
if($category eq $in{'category'}){ $put_category = $category; $file = $num; }
}
close(CATE_IN);

# �J�e�S������v���Ȃ��ꍇ
if($put_category eq ""){ &error("���̃J�e�S���͑��݂��܂���B"); }

# �t�@�C����`
$file =~ s/\D//g;
if(!$file){ &error("�f�[�^���ςł��B"); }

# �����J�e�S����W�J
foreach(@base_category){
my($category,$guide) = split(/=/,$_);
if($category eq $in{'category'}){ $pure_flag = 1; }
}

# �R�����g�t�@�C�����J��
my($i);
open(COMMENT_IN,"${int_dir}_one/_idone/${pmfile}/${file}_ocm.cgi");
my $top_comment = <COMMENT_IN>;
chomp $top_comment;
my($key_ocm,$sub_ocm,$date_ocm,$xip_ocm,$cnumber_ocm,$host_ocm,$guide_ocm) = split(/<>/,$top_comment);
while(<COMMENT_IN>){
my($key,$comment,$date) = split(/<>/,$_);
if($key eq ""){ next; }
$i++;
if($i > $maxline){ &error("�ő�o�^�� -$maxline��- ���z���Ă��܂��B"); }
if($key eq "1" && $comment eq $in{'comment'}){ &error("��d�o�^�ł��B"); }
$line .= $_;
}
close(COMMENT_IN);

# �V�[�N���b�g���[�h�̏ꍇ
my($secret_flag);
if($key_ocm eq "4"){ $secret_flag = 1 ; }
if($in{'secret'}){ $secret_flag = 1; }

# �R�����g�̐V�����L�[
my($newkey_ocm);
if($secret_flag){ $newkey_ocm = 4; }
else{ $newkey_ocm = 1; }

# �ǉ�����s�i�R�����g�t�@�C���j
$i++;
my $top_line .= qq($key_ocm<>$put_category<>$date<>$xip<>$cnumber<>$host<>$guide_ocm<>\n);
$top_line .= qq($newkey_ocm<>$in{'comment'}<>$date<>$i<>$newcolor<>\n);

# �R�����g�t�@�C���ɏ�������
open(COMMENT_OUT,">${int_dir}_one/_idone/${pmfile}/${file}_ocm.cgi");
print COMMENT_OUT "$top_line$line";
close(COMMENT_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/${file}_ocm.cgi");

# �ǉ�����s�i�S�R�����g�t�@�C���j
if($secret_flag){ $key_newcom = 4; } else{ $key_newcom = 1; }
$line_all .= qq(1<><>$date<>$xip<>$cnumber<>\n);
$line_all .= qq($key_newcom<>$in{'comment'}<>$date<>$i<>$file<>$put_category<>$newcolor<>\n);

# �S�R�����g�t�@�C�����J��
open(ALL_COMMENT_IN,"${int_dir}_one/_idone/${pmfile}/all_ocm.cgi");
my $top_allcomment = <ALL_COMMENT_IN>;
while(<ALL_COMMENT_IN>){
$i_all++;
if($i_all > $maxall){ next; }
my($key,$comment,$date) = split(/<>/,$_);
$line_all .= $_;
}
close(ALL_COMMENT_IN);

# �S�R�����g�t�@�C���ɏ�������
open(ALL_COMMENT_OUT,">${int_dir}_one/_idone/${pmfile}/all_ocm.cgi");
print ALL_COMMENT_OUT $line_all;
close(ALL_COMMENT_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/all_ocm.cgi");

# �ǉ�����s�i�V���R�����g�t�@�C���j
if($secret_flag){ $put_newcomment_key = 4; }
elsif($pure_flag && $mainnews_base ne "2"){ $put_newcomment_key = 1; }
else{ $put_newcomment_key = 3; }
$line_new .= qq($put_newcomment_key<>$in{'comment'}<>$date<>$pmfile<>$file<>$put_category<>$name_base<>\n);

# �V���R�����g�t�@�C�����J��
open(NEW_COMMENT_IN,"${int_dir}_one/new_comment.cgi");
while(<NEW_COMMENT_IN>){
$i_new++;
if($i_new >= $maxnew){ last; }
$line_new .= $_;
}
close(NEW_COMMENT_IN);

# �V���R�����g�t�@�C���ɏ�������
open(NEW_COMMENT_OUT,">${int_dir}_one/new_comment.cgi");
print NEW_COMMENT_OUT $line_new;
close(NEW_COMMENT_OUT);
Mebius::Chmod(undef,"${int_dir}_one/new_comment.cgi");

# ��{�t�@�C���ɏ�������
$line_base = qq($key_base<>$num_base<>$name_base<>$trip_base<>$id_base<>$account_base<>$itrip_base<>$file<>$viewtime_base<>$mainnews_base<>$news_base<>\n);
open(BASE_OUT,">${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");
print BASE_OUT $line_base;
close(BASE_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");

# ���b�N����
&unlock("${pmfile}ONE") if $lockkey;

# ���_�C���N�g�i���[�J���j
if($alocal_mode){
if($in{'back'} eq "all"){ print qq(location:$sciript?mode=view-$pmfile-all-1\n\n); exit; }
print qq(location:$sciript?mode=view-$pmfile-$file-1\n\n);
}
# ���_�C���N�g�i�E�F�u�j
if($in{'back'} eq "all"){ print qq(location:view-$pmfile-all-1.html\n\n); exit; }
print qq(location:view-$pmfile-$file-1.html\n\n);

exit;

1;


my($line,$i);

# �J�e�S���ő�o�^��
my $maxcategory = 100;

# �J�e�S�����̍ő啶����
my $maxlength = 20;

# �e��G���[
#if(!$postflag){ &error("GET���M�͏o���܂���B"); }
if(!$idcheck){ &error("�������ނɂ́A<a href=\"$auth_url\">���r�����r�m�r</a>�Ƀ��O�C���i�܂��͐V�K�o�^�j���Ă��������B"); }

# ���e����
($host) = &axscheck("ACCOUNT");

# �e��`�F�b�N
require "${int_dir}regist_allcheck.pl";
&length_check($in{'category'},"�J�e�S����",$maxlength,1);
&url_check("",$in{'category'});
&error_view;

# ���b�N�J�n
&lock("${pmfile}ONE") if $lockkey;

# ��{�t�@�C�����J��
&base_open($pmfile);

# �o�^�J�n���ĂȂ��ꍇ
if($key_base ne "1"){ &error("�o�^�J�n���Ă��������B"); }

my $plus = $num_base +1;

# �L�[�ݒ�
my($newkey);
if($in{'type'} eq "secret"){ $newkey = 4; } else { $newkey = 1; }

# �ǉ�����s
$line .= qq($in{'category'}<>$plus<>$newkey<>\n);

# �J�e�S���L�^�t�@�C�����J��
open(CATE_IN,"${int_dir}_one/_idone/${pmfile}/${pmfile}_cate.cgi");
while(<CATE_IN>){
my($category) = split(/<>/,$_);
if($category eq $in{'category'}){ &error("���̃J�e�S���͓o�^�ς݂ł��B"); }
$i++;
if($i >= $maxcategory){ &error("�J�e�S���̍ő�o�^����$maxcategory�ł��B�V�K�o�^����ɂ́A������J�e�S���̂ǂꂩ���폜���Ă��������B"); } 
$line .= $_;
}
close(CATE_IN);

# �J�e�S���L�^�t�@�C���ɏ�������
open(CATE_OUT,">${int_dir}_one/_idone/${pmfile}/${pmfile}_cate.cgi");
print CATE_OUT $line;
close(CATE_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/${pmfile}_cate.cgi");

# �R�����g�t�@�C���ɏ�������
my $line_ocm = qq($newkey<>$in{'category'}<>$date<>$xip<>$cnumber<>$host<><>\n);
open(OCM_OUT,">${int_dir}_one/_idone/${pmfile}/${plus}_ocm.cgi");
print OCM_OUT $line_ocm;
close(OCM_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/${plus}_ocm.cgi");

# ��{�t�@�C�����X�V
$line_base = qq($key_base<>$plus<>$name_base<>$trip_base<>$id_base<>$account_base<>$itrip_base<>$plus<>$viewtime_base<>$mainnews_base<>$news_base<>\n);
open(BASE_OUT,">${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");
print BASE_OUT $line_base;
close(BASE_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");

# ���b�N����
&unlock("${pmfile}ONE") if $lockkey;

# ���_�C���N�g
if($alocal_mode){ print qq(location:$script?mode=view-$pmfile-$plus-1\n\n); }
print qq(location:view-$pmfile-$plus-1.html\n\n);

1;




# �V�������o�[�ő吔
$max_comer = 10000;

# �w�b�_�����N
$head_link3 = qq( &gt; �Q���t�H�[��);

# ��{�t�@�C�����J��
open(BASE_IN,"${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");
my $top_base = <BASE_IN>;
my($key,$num) = split(/<>/,$top_base);
close(BASE_IN);

# �e��G���[
if($key eq "1"){ print "location:view-$pmfile-all-1.html\n\n"; exit;  &error("���ɓo�^�ς݂ł��B"); }
if($key eq "2"){ &error("���̃A�J�E���g�̓��b�N����Ă��܂��B"); }

# �V�K�Q���̏���
if($in{'action'}){ &action_start; }

# CSS��`
$css_text .= qq(
.alert{font-size:80%;color:#080;}
);


# HTML
my $print = qq(
<h1>$title�ɂ���</h1>
$title�Ƃ́A�J�e�S�������A�P�s�����͂��������Ƃ��o����c�[���ł��B<br>
�����A���C�t���O�A���P�̒u����A�v�l�̐�����ȂǂƂ��Ă����p�������� (<a href="${guide_url}%A5%DE%A5%A4%A5%ED%A5%B0">�������Əڂ���</a>)�B

<h2>$title�ɎQ������</h2>
<form action="$action" method="post"$sikibetu>
<div>

<input type="checkbox" name="check1" value="1"> ���́u�l���f�ځv�u�}�i�[�ᔽ�v�u���f���e�v�u��`�v�ȂǁA��؂̋֎~�����������Ȃ�Ȃ����Ƃ𐾂��܂��i<a href="${guide_url}/%A5%DE%A5%A4%A5%ED%A5%B0">�����[���͂�����</a>�j�B<br>
<input type="checkbox" name="check2" value="1"> ���̓��[���ᔽ���������ꍇ�A�A�J�E���g�𖳏����ɍ폜�����\�\\���܂���B<br><br>

�M��<input type="text" name="name" value="$cnam"> <span class="alert">*�M���͌�ŕύX�ł��܂��B</span>
<input type="hidden" name="mode" value="start">
<input type="hidden" name="action" value="1">
<input type="submit" value="�Q������">
</div>
</form>

);

Mebius::Template::gzip_and_print_all({},$print);

exit;

1;

#-----------------------------------------------------------
# �V�K�o�^����
#-----------------------------------------------------------
sub action_start{

# �Ǐ���
my($i_newcomer);

# �g���b�v�쐬
&trip($in{'name'});

# ID������
&id;

# �e��G���[
if(!$postflag){ &error("�f�d�s���M�͏o���܂���B"); }
if($pmfile eq ""){ &error("�A�J�E���g�����݂��܂���B"); }
if(length($i_handle) > 20){ &error("�M�����������܂��B�S�p10�����ȉ��œ��͂��Ă��������B"); }
if(!$in{'check1'} || !$in{'check2'}){ &error("�o�^�ł��܂���B"); }

# ���e����
&axscheck();

# ���b�N�J�n
&lock("${pmfile}ONE") if $lockkey;

# ��{�f�B���N�g���쐬
Mebius::Mkdir("","${int_dir}_one/_idone/${pmfile}",$dirpms);

# ��{�t�@�C���쐬
my $line_base = qq(1<>1<>$i_handle<>$enctrip<>$encid<>$pmfile<>$i_trip<><>1<>1<>1<>\n);
open(BASE_OUT,">${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");
print BASE_OUT $line_base;
close(BASE_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");

# �J�e�S���t�@�C���쐬
my $line_category = qq(������<>1<>\n);
open(CATEGORY_OUT,">${int_dir}_one/_idone/${pmfile}/${pmfile}_cate.cgi");
print CATEGORY_OUT $line_category;
close(CATEGORY_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/${pmfile}_cate.cgi");

# �����ރt�@�C���쐬
my $line_ocm = qq(1<>������<>\n);
open(OCM_OUT,">${int_dir}_one/_idone/${pmfile}/1_ocm.cgi");
print OCM_OUT $line_ocm;
close(OCM_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/1_ocm.cgi");

# �S�J�e�S���t�@�C���쐬
my $line_allcomment = qq(1<><>\n);
open(ALLCOMMENT_OUT,">${int_dir}_one/_idone/${pmfile}/all_ocm.cgi");
print ALLCOMMENT_OUT $line_allcomment;
close(ALLCOMMENT_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/all_ocm.cgi");

# �V�K�����o�[�t�@�C�����J��
my $line_newcomer = qq($i_handle<>$pmfile<>\n);
open(NEWCOMER_IN,"${int_dir}_one/newcomer.cgi");
while(<NEWCOMER_IN>){
$i_newcomer++;
if($i_newcomer >= $max_comer){ last; }
$line_newcomer .= $_;
}
close(NEWCOMER_IN);

# �V�K�����o�[�t�@�C������������
open(NEWCOMER_OUT,">${int_dir}_one/newcomer.cgi");
print NEWCOMER_OUT $line_newcomer;
close(NEWCOMER_OUT);
Mebius::Chmod(undef,"${int_dir}_one/newcomer.cgi");

# ���b�N����
&unlock("${pmfile}ONE") if $lockkey;

# HTML
my $print = qq(
�V�K�o�^���������܂����B
<a href="$script?mode=view-$pmfile-all-1">���}�C���O��</a>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;



package main;


#-----------------------------------------------------------
# �z�M����
#-----------------------------------------------------------
sub auth_cancelmail{

# �錾
my(%account,%renew,$file);
our(%in,$title,$jump_sec,$jump_url,$auth_url);

# �t�@�C����`
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("�A�J�E���g�����݂��܂���B"); }


# �t�@�C�����J��
(%account) = Mebius::Auth::File("",$file);

# �s���G���[
if($in{'pass'} eq ""){ &error("�����p�p�X���[�h���w�肵�Ă��������B"); }
if($account{'mlpass'} eq ""){ &error("�F�؂���Ă��Ȃ����[���A�h���X�ł��B"); }
if($account{'email'} eq ""){ &error("���[���A�h���X�o�^������܂���B"); }

# �p�X������Ȃ��ꍇ
if($account{'mlpass'} ne $in{'pass'}){ &error("�����p�p�X���[�h���Ⴂ�܂��B"); }

# ���[���A�h���X������
$renew{'email'} = "";
$renew{'mlpass'} = "";

# �t�@�C���X�V
Mebius::Auth::File("Renew",$file,\%renew);

# �W�����v��
$jump_sec = 3;
$jump_url = "$auth_url$file/";


# HTML
my $print = qq($title�̃��[���z�M���������܂����B<a href="$jump_url">�ړ�����</a>);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;



package main;

#-------------------------------------------------
# �v���t�B�[���\��
#-------------------------------------------------
sub auth_vrireki{

my($file) = ($in{'account'});

$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("�A�J�E���g�����w�肵�Ă��������B"); }

# �V�����y�[�W�Ƀ��_�C���N�g
Mebius::Redirect("","${auth_url}$file/aview-rireki");

}

1;

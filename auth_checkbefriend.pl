package main;


#-------------------------------------------------
# �}�C���r�󋵂��`�F�b�N
#-------------------------------------------------
sub do_auth_checkbefriend{

# �Ǐ���
my($file,$deny) = @_;

# �����`�F�b�N
$file =~ s/[^0-9a-z]//g;

# ���O�C�����̂ݏ������s
if($idcheck){ 
# �\���ς݂̏ꍇ�A�t���O�𗧂Ă�
open(BEFRIEND_IN,"${int_dir}_id/$file/${file}_befriend.cgi");
while(<BEFRIEND_IN>){
my($account) = split(/<>/,$_);
if($pmfile eq $account){ $yetplz = 1; }
}
close(BEFRIEND_IN);
}

}

1;

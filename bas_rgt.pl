
#-------------------------------------------------
#  �X�N���v�g�����J�n�A���[�h�ؑ�
#-------------------------------------------------
sub init_start{

# $moto ���`
$moto = $in{'moto'};
if($moto =~ /[^0-9a-z]/){ &error("�f���̎w�肪�ςł��B"); }
$realmoto = $moto;
$moto =~ s/^sub//;
if($moto eq ""){ &error("�f�����w�肵�Ă��������B"); }

}

#-----------------------------------------------------------
# �����X�^�[�g
#-----------------------------------------------------------
sub start{

my($ktag);
our(%in);

if($in{'k'}){ $ktag = "k"; }
if($in{'mode'} eq "memo" && $in{'no'}){
&Mebius::Redirect("","http://aurasoul.mb2.jp/_$moto/${ktag}$in{'no'}_memo.html",301);
}
else{
&error("���̓��e�p�t�q�k�́A���܂͎g���Ă��܂���B");
}

}

1;


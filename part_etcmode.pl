package main;

#-----------------------------------------------------------
# �F�X�ȃ��[�h
#-----------------------------------------------------------
sub etc_mode{
our($mode);
if($mode eq "random"){ &bbs_randomjump(); }
elsif($mode eq "my") { &bbs_old_mypage(); }
else{ &error("���[�h������܂���B"); }
}


#-----------------------------------------------------------
# ���}�C�y�[�W�����_�C���N�g
#-----------------------------------------------------------
sub bbs_old_mypage{ Mebius::Redirect("","http://$server_domain/_main/my.html",301); }

#-----------------------------------------------------------
# �����_���ȋL���ɃW�����v
#-----------------------------------------------------------
sub bbs_randomjump{

$css_text .= qq(.body1{padding-bottom:4em});
my($cnt);

# ���݂̋L�������擾
open(IN,"<","$nowfile");
while(<IN>){ $cnt++; }
close(IN);

# ��ԋL���������_���őI��
open(IN,"<","$nowfile");
while(<IN>){
my($no,$none,$none,$none,$none,$none,$key) = split(/<>/,$_); 
if($key eq "1" || $key eq "5"){
if(rand($cnt) < 1){ $jump = $no; last; }
}
$cnt--;
}
close(IN);

$sub_title = "�L���W�����v";
$jump_url = "/_$moto/${jump}.html";
$meta_robots = qq(<meta name="robots" content="noindex,follow">);

my $print = <<"EOM";
<div class="body1">
<a href="/_$moto/${jump}.html">�����_���ȋL���փW�����v����</a>
</div>
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# �f���̕�
#-----------------------------------------------------------

sub bbs_heisa_view{

# URL����
my $no = $in{'no'};
my $viewno = "$no.html" if($no ne "");

&error("���̌f���͕����ł��B","410 Gone");
}

1;



1;

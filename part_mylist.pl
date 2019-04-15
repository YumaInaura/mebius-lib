package main;

#-----------------------------------------------------------
# ���C�ɓ��菈��
#-----------------------------------------------------------
sub bbs_mylist{

# �^�C�g����`
$sub_title = "���C�ɓ���o�^";
$head_link3 = " &gt; ���C�ɓ���o�^";

# �g�у��[�h
if($in{'k'}){ &kget_items(); }

# ���C�ɓ���ő�o�^��
$max_add = 25;

# ���M���`
if($alocal_mode){ $action = "$script"; } else { $action = "./"; }
# ���[�h�U�蕪��
if($in{'type'} eq "delete"){ &delete_mylist(); }
else{ &add_list(); }

# �G���[
if($cnumber eq ""){ &error("���̊��ł̓y�[�W�����p�ł��܂���B"); }
}

#-----------------------------------------------------------
# ���C�ɓ���L����o�^����
#-----------------------------------------------------------

sub add_list{

# �Ǐ���
my($line,$file,$no);

# �t�@�C����`
$file = $cnumber;
$file =~ s/\W//g;
if($cmfile){ $file = $cmfile; }
if($file eq ""){ &error("�ݒ�l���ςł��B"); }

# �����`�F�b�N
$no = $in{'no'};
$no =~ s/\D//g;
if($no eq ""){ &error("�ݒ�l���ςł��B"); }

# �ǉ�����s
$line = qq(1<>$no<>$moto<>\n);

# ���b�N�J�n
&lock("cnumber") if($lockkey);

# �t�@�C�����J��
open(CNUMBER_IN,"${int_dir}_cnumber/$file/${file}_mylist.cgi");
while(<CNUMBER_IN>){
$i++;
if($i < $max_add){
my($key2,$no2,$moto2) = split(/<>/,$_);
if($no2 ne $no || $moto2 ne $moto){ $line .= $_; }
}
}
close(CNUMBER_IN);

# �t�@�C���������o��
Mebius::Mkdir("","${int_dir}_cnumber/$file",$dirpms);
open(CNUMBER_OUT,">${int_dir}_cnumber/$file/${file}_mylist.cgi");
print CNUMBER_OUT $line;
close(CNUMBER_OUT);
Mebius::Chmod(undef,"${int_dir}_cnumber/$file/${file}_mylist.cgi");

# ���b�N����
&unlock("cnumber") if($lockkey);

# ���[���z�M���X�g�ֈڍs����ꍇ
if($in{'to_mylist'}){ &to_mylist; }

# ���_�C���N�g
if($in{'my'}){
if($alocal_mode){ print "location:main.cgi?mode=my$kreq2#MYLIST\n\n"; }
else{ print "location:http://$server_domain/_main/?mode=my$kreq2#MYLIST\n\n"; }
}

# �W�����v
$jump_sec = 1;
$jump_url = "/_main/?mode=my$kreq1#MYLIST";
if($alocal_mode){ $jump_url = "main.cgi?mode=my$kreq1#MYLIST"; }

# �w�b�_
main::header();

# HTML
print qq(
<div class="body1">
���C�ɓ���o�^�����܂����B�i<a href="$jump_url">�}�C�y�[�W��</a>�j
</div>
);

# �t�b�^
&footer();

exit;

}



#-----------------------------------------------------------
# ���C�ɓ���L�����폜����
#-----------------------------------------------------------
sub delete_mylist{

# �Ǐ���
my($line,$file,$no,$bbs);
our(%in);

# �t�@�C����`
$file = $cnumber;
$file =~ s/\W//g;
if($cmfile){ $file = $cmfile; }
if($file eq ""){ &error("�ݒ�l���ςł��B"); }

# �����`�F�b�N
$no = $in{'no'};
$no =~ s/\D//g;
if($no eq ""){ &error("�ݒ�l���ςł��B"); }

# �����`�F�b�N
$bbs = $in{'bbs'};
$bbs =~ s/\W//g;
if($bbs eq ""){ &error("�ݒ�l���ςł��B"); }

# ���b�N�J�n
&lock("cnumber") if($lockkey);

# �t�@�C�����J��
open(CNUMBER_IN,"${int_dir}_cnumber/$file/${file}_mylist.cgi");
while(<CNUMBER_IN>){
my($key2,$no2,$moto2) = split(/<>/,$_);
if($moto2 eq $bbs && $no2 eq $no){ next; }
$line .= $_;
}
close(CNUMBER_IN);

# �t�@�C���������o��
open(CNUMBER_OUT,">${int_dir}_cnumber/$file/${file}_mylist.cgi");
print CNUMBER_OUT $line;
close(CNUMBER_OUT);
Mebius::Chmod(undef,"${int_dir}_cnumber/$file/${file}_mylist.cgi");

# ���b�N����
&unlock("cnumber") if($lockkey);

# ���_�C���N�g
if($alocal_mode){ print "location:main.cgi?mode=my$kreq2#MYLIST\n\n"; }
else{ print "location:http://$server_domain/_main/?mode=my$kreq2#MYLIST\n\n"; }

exit;

}

1;


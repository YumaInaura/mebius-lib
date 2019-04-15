
package main;

#-----------------------------------------------------------
# SNS�^�O���
#-----------------------------------------------------------

sub auth_closetag{

# �Ǐ���
my($type,$file,$maxtag,$max_comment) = @_;
my($line,$file2);

my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# �G���[
if(!$myadmin_flag){ &error("�y�[�W�����݂��܂���B[aclst]");}

# �G���R�[�h
$file2 = $submode3;
#$file2 =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;
#$file2 =~ tr/ /+/;
$file2 =~ s/\.//;
$file2 =~ s/\///;


# �t�@�C�����J��
open(CLOSE_IN,"<","${auth_log_directory}_closetag/${file2}_close.cgi");
my $top = <CLOSE_IN>;
close(CLOSE_IN);
my($key,$text,$remove) = split(/<>/,$top);

# �L�[���[�h��
if($in{'type'} eq "close" ){
$line = qq(0<>$in{'text'}<>$remove<>\n);
open(CLOSE_OUT,">","${auth_log_directory}_closetag/${file2}_close.cgi");
print CLOSE_OUT $line;
close(CLOSE_OUT);
&auth_delete_alltag();
&auth_delete_newtag();
}

# �L�[���[�h���b�N
elsif($in{'type'} eq "lock" ){
my($put_key);
if($key eq "2"){ $put_key = 1; }
else{ $put_key = 2;  }

$line = qq($put_key<>$in{'text'}<>$remove<>\n);
open(CLOSE_OUT,">","${auth_log_directory}_closetag/${file2}_close.cgi");
print CLOSE_OUT $line;
close(CLOSE_OUT);
}


# �L�[���[�h����
elsif($in{'type'} eq "revibe"){
$line = qq(<>$in{'text'}<>$remove<>\n);
open(CLOSE_OUT,">","${auth_log_directory}_closetag/${file2}_close.cgi");
print CLOSE_OUT $line;
close(CLOSE_OUT);
}

# �R�����g�ݒ�
else{
$line = qq($key<>$in{'text'}<>$remove<>\n);
open(CLOSE_OUT,">","${auth_log_directory}_closetag/${file2}_close.cgi");
print CLOSE_OUT $line;
close(CLOSE_OUT);

}

# �y�[�W�W�����v
$jump_sec = $auth_jump;
$jump_url = "./tag-word-${file2}.html";
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }

# ���_�C���N�g
if($myadmin_flag){ Mebius::Redirect("","./tag-word-${file2}.html"); }

# HTML
my $print = qq(
�^�O���(�܂��͍ĊJ)���܂����i<a href="$jump_url">���߂�</a>�j�B<br>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# �V���^�O�t�@�C�����X�V
#-----------------------------------------------------------
sub auth_delete_newtag{

# ���b�N�J�n
&lock("newtag") if($lockkey);

my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# �V���^�O�t�@�C�����J��
my $openfile3 = "${auth_log_directory}newtag.cgi";
open(NEWTAG_IN,"<","$openfile3");
while(<NEWTAG_IN>){
chomp $_;
my($notice,$tag,$account) = split(/<>/,$_);
if($tag eq $file2){ next; }
$line3 .= qq($notice<>$tag<>$account<>\n);
}
close(NEWTAG_IN);

# �V���^�O�t�@�C������������
open(NEWTAG_OUT,">","$openfile3");
print NEWTAG_OUT $line3;
close(NEWTAG_OUT);
Mebius::Chmod(undef,$openfile3);

# ���b�N����
&unlock("newtag") if($lockkey);

}

#-----------------------------------------------------------
# �S�^�O�t�@�C�����X�V
#-----------------------------------------------------------
sub auth_delete_alltag{

# �Ǐ���
my($line4);

# ���b�N�J�n
&lock("alltag") if($lockkey);

my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# �S�^�O�t�@�C�����J��
my $openfile4 = "${auth_log_directory}alltag.cgi";
open(ALLTAG_IN,"<","$openfile4");
while(<ALLTAG_IN>){
chomp;

if($_ eq $file2){ next; }
$line4 .= qq($_\n);
}
close(ALLTAG_IN);

# �S�^�O�t�@�C������������
open(ALLTAG_OUT,">","$openfile4");
print ALLTAG_OUT $line4;
close(ALLTAG_OUT);
Mebius::Chmod(undef,$openfile4);

# ���b�N����
&unlock("alltag") if($lockkey);

}

1;

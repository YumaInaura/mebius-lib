
use Mebius::Tag;
package main;

#-----------------------------------------------------------
# �r�m�r �֘A�^�O�̓o�^
#-----------------------------------------------------------
sub auth_fooktag{

# �Ǐ���
my($type,$file,$maxtag,$max_comment) = @_;
my($line,$file2,$fooktag,$tag);

# GET���M���֎~
if(!$postflag){ &error("������POST���ĂˁB"); }

# ���O�C�����̂�
if(!$idcheck){ &error("�������胍�O�C�����Ă��������B"); }

# �G���R�[�h
$file2 = $submode3;
$file2 =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;
$file2 =~ tr/ /+/;

# �^�O�̐��`
$tag = $in{'tag'};
($tag) = Mebius::Tag::FixTag(undef,$tag);

# �G���R�[�h�Q
$fooktag = $tag;
$fooktag =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;

# ���t�@�C�����J���P
open(CLOSE_IN1,"${int_dir}_authlog/_closetag/${file2}_close.cgi");
my $top_close1 = <CLOSE_IN1>;
close(CLOSE_IN1);
my($close_key1) = split(/<>/,$top_close1);
if($close_key1 eq "0" || $close_key1 eq "2"){ &error("�����̃^�O�ł����ȁB"); }

# ���t�@�C�����J���Q
open(CLOSE_IN2,"${int_dir}_authlog/_closetag/${fooktag}_close.cgi");
my $top_close2 = <CLOSE_IN2>;
close(CLOSE_IN2);
my($close_key2) = split(/<>/,$top_close2);
if($close_key2 eq "0" || $close_key2 eq "2"){ &error("�����̃^�O�ł��킢�B"); }


# �^�O�����݂��邩�ǂ������`�F�b�N�P
open(TAG_IN1,"${int_dir}_authlog/_tag/${file2}.cgi");
my $top_tag1 = <TAG_IN1>;
close(TAG_IN1);
if($top_tag1 eq ""){ &error("���̃^�O�͂���܂����B${file2}"); }

# �^�O�����݂��邩�ǂ������`�F�b�N�Q
open(TAG_IN2,"${int_dir}_authlog/_tag/${fooktag}.cgi");
my $top_tag2 = <TAG_IN2>;
close(TAG_IN2);
if($top_tag2 eq ""){ &error("�o�^��̃^�O������܂���B�啶��/�������A���p/�S�p�Ȃǂɒ��ӂ��āA������x�o�^���Ă��������B"); }

# �o�^���A�o�^��̃^�O�������ꍇ
if($file2 eq $fooktag){ &error("�����^�O�ł�����B"); }

# �֘A�^�O���J���P
my($i);
my $fook_line1 .= qq($tag<>\n);
open(FOOK_IN1,"${int_dir}_authlog/_fooktag/${file2}_fk.cgi");
while(<FOOK_IN1>){
my($word) = split(/<>/,$_);
if($word eq $tag){ $nextflag++; next; }
$i++;
if($i >= 5){ last; }
$fook_line1 .= $_;
}
close(FOOK_IN1);

# �֘A�^�O���J���Q
my($i);
my $fook_line2 .= qq($submode3<>\n);
open(FOOK_IN2,"${int_dir}_authlog/_fooktag/${fooktag}_fk.cgi");
while(<FOOK_IN2>){
my($word) = split(/<>/,$_);
if($word eq $submode3){ $nextflag++; next; }
$i++;
if($i >= 5){ last; }
$fook_line2 .= $_;
}
close(FOOK_IN2);

# �o�����ɓo�^�ς݂̏ꍇ
if($nextflag >= 2){ &error("���ɓo�^�ς݂ŃK�X�B"); }

# �֘A�^�O��o�^�P
open(FOOK_OUT1,">${int_dir}_authlog/_fooktag/${file2}_fk.cgi");
print FOOK_OUT1 $fook_line1;
close(FOOK_OUT1);
Mebius::Chmod(undef,"${int_dir}_authlog/_fooktag/${file2}_fk.cgi");


# �֘A�^�O��o�^�Q
open(FOOK_OUT2,">${int_dir}_authlog/_fooktag/${fooktag}_fk.cgi");
print FOOK_OUT2 $fook_line2;
close(FOOK_OUT2);
Mebius::Chmod(undef,"${int_dir}_authlog/_fooktag/${fooktag}_fk.cgi");

# �y�[�W�W�����v
$jump_sec = $auth_jump;
$jump_url = "./tag-word-${file2}.html";
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }

# HTML
my $print = qq(
�֘A�^�O��o�^���܂����i<a href="$jump_url">���߂�</a>�j�B<br>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;


package main;


#-----------------------------------------------------------
# BBS�̃��X�𑀍�
#-----------------------------------------------------------
sub auth_skeditbbs{

# �Ǐ���
my($file,$open,$line,$indexline,$pastline,$flag,$top1,$yearfile,$monthfile,$newkey);

# �l���Ԉ���Ă���ꍇ
if($in{'decide'} ne "delete" && !$myadmin_flag){ &error("�l�𐳂����w�肵�Ă��������B"); }

# �����`�F�b�N�P
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("�f�[�^�w�肪�ςł��B"); }

# �����`�F�b�N�Q
$open = $in{'num'};
$open =~ s/\D//g;
if($open eq ""){ &error("�f�[�^�w�肪�ςł��B"); }

# �����`�F�b�N�R
$number = $in{'number'};
$number =~ s/\D//g;
if($number eq ""){ &error("�f�[�^�w�肪�ςł��B"); }

# ���O�C�����Ă��Ȃ��ꍇ
if(!$idcheck){ &error("�L�����폜����ɂ́A���O�C�����Ă��������B"); }

# �v���t�B�[�����J��
&open($file);

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �t�@�C����`
my $bbs_thread_file = "${account_directory}bbs/${file}_bbs_${open}.cgi";

# ���b�N�J�n
&lock("auth$file") if $lockkey;

# �L���P�̃t�@�C�����J��
open(BBS_IN,"<",$bbs_thread_file)||&error("�L�����J���܂���B");
$top1 = <BBS_IN>;
$line .= $top1;

chomp $top1;
my($key,$num,$sub,$res,$dates,$newtime,$restime) = split(/<>/,$top1);
my($year,$month,$day,$hour,$min) = split(/,/,$dates);
$top1res = $res;

while(<BBS_IN>){
chomp $_;
my($key,$num,$account,$name,$trip,$id,$comment,$dates,$restime,$resxip) = split(/<>/,$_);

# �L�[�ύX����
if($num eq $number){
&open($account,"nocheck");
if($ppadmin && !$myadmin_flag){ &error("�Ǘ��ғ��e�͍폜�ł��܂���B"); }
if($key eq "1"){
if($account eq $pmfile){ $key = 3; $flag = 1; }
elsif($file eq $pmfile){ $key = 2; $flag = 1; }
elsif($myadmin_flag){ $key = 4; $flag = 1; $deleter = qq($pmfile<>$pmname<>); $flag = 1; }
}
elsif($in{'decide'} eq "revive" && $myadmin_flag){ $key = 1; $deleter = qq($pmfile<>$pmname<>); $flag = 1; }
$line .= qq($key<>$num<>$account<>$name<>$trip<>$id<>$comment<>$dates<>$restime<>$resxip<>$deleter\n);
}

else { $line .= qq($_\n); }

}
close(BBS_IN);


# �Y���s���Ȃ��ꍇ
if(!$flag){ &error("���s�ł��܂���ł����B"); }

# �L���P�̃t�@�C���������o��
Mebius::Fileout(undef,$bbs_thread_file,$line);

# ���b�N����
&unlock("auth$file") if $lockkey;

# �W�����v���`
$jump_sec = $auth_jump;
$jump_url = "$file/b-$in{'num'}#S$number";
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }


# HTML
my $print = <<"EOM";
���s���܂����B<a href="$jump_url">�L��</a>�Ɉړ����܂��B
EOM


Mebius::Template::gzip_and_print_all({},$print);


# �I��
exit;

}


1;

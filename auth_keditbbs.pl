
package main;

#-----------------------------------------------------------
# SNS BBS�̋L���𑀍�
#-----------------------------------------------------------
sub auth_keditbbs{

# �Ǐ���
my($file,$open,$line,$indexline,$pastline,$flag,$top1,$yearfile,$monthfile,$newkey);

# �ύX����L�[�l���`
# ���b�N����ꍇ
if($in{'decide'} eq "lock"){ $newkey = "0"; }
# �폜����ꍇ
elsif($in{'decide'} eq "delete"){
if($myadmin_flag){ $newkey = "4"; } else { $newkey = "2"; }
}
elsif($in{'decide'} eq "revive"){ $newkey = "1"; }
else{ &error("�l�𐳂����w�肵�Ă��������B"); }

# �����`�F�b�N�P
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("�l�𐳂����w�肵�Ă��������B"); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �����`�F�b�N�P
$open = $in{'num'};
$open =~ s/\D//g;
if($open eq ""){ &error("�l�𐳂����w�肵�Ă��������B"); }

# ���O�C�����Ă��Ȃ��ꍇ
if(!$idcheck){ &error("�L�����폜����ɂ́A���O�C�����Ă��������B"); }

# �{�l�ł��Ǘ��҂ł��Ȃ��ꍇ
if(!$myadmin_flag && $file ne $pmfile){ &error("�L���͖{�l�����폜�ł��܂���B"); }

# �v���t�B�[�����J��
&open($file);

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);

# �t�@�C����`
my $bbs_thread_file = "${account_directory}bbs/${file}_bbs_${open}.cgi";
my $bbs_index_file = "${account_directory}bbs/${file}_bbs_index.cgi";

# �v���r���[�̏ꍇ
if($in{'preview'} eq "on"){ &auth_keditbbs_preview("",$file,$open); }

# ���b�N�J�n
&lock("auth$file") if $lockkey;

# �L���P�̃t�@�C�����J��
open(BBS_IN,"<",$bbs_thread_file) || &error("�L�����J���܂���B");
my $top1 = <BBS_IN>;
chomp $top1;
my($key,$num,$sub,$res,$dates,$newtime,$restime,$resaccount,$resname) = split(/<>/,$top1);
my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);
$keytop1 = $key;
$key = $newkey;

$line .= qq($key<>$num<>$sub<>$res<>$dates<>$newtime<>$restime<>$resaccount<>$resname<>\n);
while(<BBS_IN>){ $line .= $_; }
close(BBS_IN);

# �L�[�ɂ�菈���ύX
if( ($keytop1 eq "4" || $keytop1 eq "2") && !$myadmin_flag){ &error("���s�ł��܂���ł����B"); }

# �L���P�̃t�@�C���������o��
Mebius::Fileout(undef,$bbs_thread_file,$line);

# ���s�C���f�b�N�X���J��
open(BBS_INDEX_IN,"<",$bbs_index_file);
my $nowtop1 = <BBS_INDEX_IN>;
$indexline .= $nowtop1;
while(<BBS_INDEX_IN>){
chomp $_;
my($key,$num,$sub,$res,$dates,$newtime,$restime,$resaccount,$resname) = split(/<>/,$_);
if($open eq $num){
$key = $newkey;
$indexline .= qq($key<>$num<>$sub<>$res<>$dates<>$newtime<>$restime<>$resaccount<>$resname<>\n);
my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);
}
else{ $indexline .= qq($_\n); }
}
close(BBS_INDEX_IN);

# ���s�C���f�b�N�X�������o��
Mebius::Fileout(undef,$bbs_index_file,$index_line)

# �Ǘ��ҍ폜�̏ꍇ�A�y�i���e�B�𐶐�
if($myadmin_flag && !$myprof_flag && $in{'decide'} eq "delete"){ &auth_keditbbs_makewait("",$file); }

# ���b�N����
&unlock("auth$file") if $lockkey;

# �W�����v���`
$jump_sec = $auth_jump;
$jump_url = "${file}/#BBS";
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }


# HTML
my $print = <<"EOM";
���s���܂����B<a href="$jump_url">BBS�G���A</a>�Ɉړ����܂��B
EOM

Mebius::Template::gzip_and_print_all({},$print);

# �I��
exit;

}

#-----------------------------------------------------------
# �y�i���e�B�����
#-----------------------------------------------------------
sub auth_keditbbs_makewait{

my($type,$file) = @_;

my $waitsec_bbs = 60*60*24*3;
my $waitline = qq($time<>$waitsec_bbs<>\n);

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

Mebius::Fileout(undef,"${account_directory}${file}_time_postbbs.cgi",$waitline);

}


#-----------------------------------------------------------
# �폜�O�̃v���r���[���
#-----------------------------------------------------------

sub auth_keditbbs_preview{

# �錾
my($type,$file,$open) = @_;

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �L���P�̃t�@�C�����J��
open(BBS_IN,"<","${account_directory}bbs/${file}_bbs_${open}.cgi") || &error("�L�����J���܂���B");
my $top1 = <BBS_IN>;
my($key,$num,$sub,$res,$dates,$newtime,$restime) = split(/<>/,$top1);
close(BBS_IN);

# URL�ϊ�
my $link = qq($file/b-$open);
if($aurl_mode){ ($link) = &aurl($link); }

# HTML
my $print = <<"EOM";
$footer_link
<h1>�L���̍폜</h1>
<h2>���s</h2>
�L���i<a href="$link">$sub</a>�j���폜���܂����A��낵���ł����H<br>
��x�폜����ƁA���̋L�����̑S���e���\\���ł��Ȃ��Ȃ�܂��B<br><br>
<a href="$script?mode=keditbbs&amp;account=$file&amp;num=$open&amp;decide=delete">���폜�����s����</a>�i�����s�j
<br><br><hr>
$footer_link
EOM

Mebius::Template::gzip_and_print_all({},$print);

# �I��
exit;

}




1;

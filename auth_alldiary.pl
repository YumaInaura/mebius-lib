
package main;

#-------------------------------------------------
# ���ʃC���f�b�N�X�\��
#-------------------------------------------------
sub auth_alldiary{

# �Ǐ���
my($file,$link,$line);

# ���W���[���ǂݍ���
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}auth_diax.pl";

# �ő�擾����
$max_month = 12;

# �����`�F�b�N�P
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# �v���t�B�[�����J��
&open($file);

# ���[�U�[�F�w��
if($ppcolor1){ $css_text .= qq(h2{background-color:#$ppcolor1;border-color:#$ppcolor1;}); }

# �}�C���r��Ԃ̎擾
&checkfriend($file);

# ���L�\���̐���
if($pplevel >= 1 || !$mebi_mode){
if($pposdiary eq "2"){
if(!$yetfriend && !$myprof_flag && !$myadmin_flag){ &error("�C���f�b�N�X�����݂��܂���B"); }
$text1 = qq(<em class="green">��$friend_tag�����ɓ��L���J���ł��B</em><br><br>);
$onlyflag = 1;
}
elsif($pposdiary eq "0"){
if(!$myprof_flag && !$myadmin_flag){ &error("�C���f�b�N�X�����݂��܂���B"); }
$text1 = qq(<em class="red">�����������ɓ��L���J���ł��B</em><br><br>);
$onlyflag = 1;
}
}

# �S�C���f�b�N�X���擾
my($line) .= Mebius::SNS::Diary::index_file_per_account({ file_type => "now" } , $file);

# �A�J�E���g��
my $viewaccount = $ppfile;
if($ppname eq "none"){ $viewaccount = "****"; }

# �^�C�g����`
$sub_title = qq(�S���L : $ppname - $viewaccount);
$head_link3 = qq( &gt; <a href="./">$ppname</a> );
$head_link4 = qq( &gt; �S���L );

# �b�r�r��`
$css_text .= qq(
.lock{color:#070;}
h1{color:#080;}
);



# �C���f�b�N�X���擾
my($line) = shift_jis(Mebius::SNS::Diary::all_diary_index_file_per_account($file,$max_month));
my($all_month_index) = auth_all_diary_month_index(undef,$file);

$link = qq($adir$file/);

# �g�s�l�k
my $print = <<"EOM";
$footer_link
<h1>�S���L�i$max_month�������j : $ppname - $viewaccount</h1>
$text1
<a href="$link">$ppname - $viewaccount �̃v���t�B�[���ɖ߂�</a>
<h2 id="INDEX">�S���L</h2>
$line
<h2>���ʈꗗ</h2>
$all_month_index
<br><br>
$footer_link2
EOM

# �w�b�_
Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}

#������������������������������������������������������������
# ���L�C���f�b�N�X
#������������������������������������������������������������

#sub auth_alldiary_getmonth{

## �t�@�C����`
##my($file,$year,$month) = @_;
#my($diary_index);

## �f�B���N�g����`
#my($account_directory) = Mebius::Auth::account_directory($file);
#	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

## ���s�C���f�b�N�X��ǂݍ���
#open(INDEX_IN,"<","${account_directory}diary/${file}_diary_${year}_${month}.cgi") || &error("�C���f�b�N�X�����݂��܂���B");
#while(<INDEX_IN>){
#my($key,$num,$sub,$res,$dates,$newtime) = split(/<>/,$_);
#my($year,$month,$day,$hour,$min) = split(/,/,$dates);
#my($link,$mark,$line);

#$link = qq($adir${file}/d-$num);
#if($aurl_mode){ ($link) = &aurl($link); }

#if($key eq "0"){ $mark .= qq(<span class="lock"> - ���b�N��</span> ); }

## ���ʂɕ\������
#if($key eq "0" || $key eq "1"){
#if($time < $newtime + 3*24*60*60){ $mark .= qq(<span class="red"> - new!</span> ); }
#$diary_index .= qq(<li><a href="$link">$sub</a> ($res) - $month��$day��$mark);

#if($myadmin_flag >= 1){
#$diary_index .= qq( - <a href="${auth_url}?mode=keditdiary&amp;account=$in{'account'}&amp;num=$num&amp;decide=delete">�폜</a>);
#$diary_index .= qq( - <a href="${auth_url}?mode=keditdiary&amp;account=$in{'account'}&amp;num=$num&amp;decide=delete&amp;penalty=1">���폜</a>);
#}

#$diary_index .= qq(</li>);

#}

## �폜�ς݂̏ꍇ
#else{
#my($text);
#if($key eq "2"){ $text = qq( �A�J�E���g��ɂ��폜); }
#elsif($key eq "4"){ $text = qq( �Ǘ��҂ɂ��폜); }
#if($myadmin_flag >= 1){ $text .= qq( <a href="$link" class="red">$sub</a>); }
#$diary_index .= qq(<li>$text - $month��$day��</li>);
#}


#}
#close(INDEX_IN);

#return($diary_index);

#}


1;

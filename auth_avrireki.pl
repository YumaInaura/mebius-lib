


package main;

#-------------------------------------------------
# �v���t�B�[���\��
#-------------------------------------------------
sub auth_avrireki{

# �Ǐ���
my($file);

#�����`�F�b�N
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# CSS��`
$css_text .= qq(
.lim{margin-bottom:0.3em;line-height:1.25em;}
li{line-height:1.5em;}
);

# �t�@�C���I�[�v��
&open($file);

# ���[�U�[�F�w��
if($ppcolor1){ $css_text .= qq(h2{background-color:#$ppcolor1;border-color:#$ppcolor1;}); }

# �{���s���̏ꍇ
if($pporireki eq "0" && !$myprof_flag){ &error("���̃����o�[�͓��e���������J���Ă��܂���B","401 Unauthorized"); }

# �g���b�v
if($ppenctrip){ $pri_ppenctrip = "��$ppenctrip"; }

# �^�C�g������
$sub_title = "���e���� - $ppname - $ppaccount - $title";
$head_link3 = qq(&gt; $hername);


# ���L�A�R�����g�t�H�[���Ȃǂ̃��O�ǂݍ���
&auth_get_avrireki($file);

# �i�r
my $link2 = "$adir${file}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
my $navilink .= qq(<a href="$link2">�v���t�B�[����</a>);

# HTML
my $print = <<"EOM";
$footer_link
<h1>�����e���� : $ppname - $ppaccount </h1>
$navilink
<h2>���r�E�X�����O�ł̓��e����</h2>
$rireki_index
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}

#������������������������������������������������������������
# ���e����
#������������������������������������������������������������

sub auth_get_avrireki{

# �Ǐ���
my($ri);

# �t�@�C����`
my($file) = @_;


# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ���e�����t�@�C�����J��
open(RIREKI_IN,"<","${account_directory}${file}_rireki.cgi");
$rireki_line .= qq($server_domain<>$bbs_url<>$no<>$res<>$title<>$sub<>$date<>\n);
while(<RIREKI_IN>){
chomp $_;
$ri++;
my($rdomain,$rbbs_url,$rno,$rNo,$rtitle,$rsub,$rdate) = split(/<>/,$_);
if($rsub ne ""){
$rireki_index .= qq(<li><a href="http://$rdomain/$rbbs_url/$rno.html#S$rNo">$rsub</a> - <a href="http://$rdomain/$rbbs_url/">$rtitle</a></li>);
}
}
close(RIREKI_IN);

# ���`
if($rireki_index){
my($pr);
if($myprof_flag){ $pr = qq(<br><span class="red" style="font-size:90%;">�������͌��J����܂��B���J�������Ȃ��ꍇ��<a href="#EDIT">�ݒ�t�H�[��</a>�́u���e�����̕\\���ݒ�v�Łu�\\�����Ȃ��v��I��ł��������B By ������䂤��</span><br>); }
$rireki_index = qq(<ul>$rireki_index</ul>$pr);

}

}


1;

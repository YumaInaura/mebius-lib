
package main;

#-----------------------------------------------------------
# �r�m�r�^�O
#-----------------------------------------------------------
sub auth_schtag{

# �Ǐ���
my($type,$file,$maxtag,$max_comment) = @_;
my($tagline,$i,$line,$hit);

# �������s
if($in{'word'} ne ""){ ($line) = &search_action($in{'word'}); }

# CSS��`
$css_text .= qq(
.google_link{font-size:150%;}
);

# �^�C�g����`
$sub_title = "�^�O���� - $title";
$head_link3 = " &gt; �^�O���� ";

# �^�O�����t�H�[�����擾
&get_schform();

# ���O�C�����̏ꍇ
my($navilink);
if($idcheck){ $navilink .= qq(<a href="./$pmfile/tag-view">���^�O��o�^����</a> - ); }
$navilink .= qq(<a href="./tag-new.html">�V���^�O���`�F�b�N����</a>);

# HTML
my $print = qq(
$footer_link
<h1>�^�O����</h1>
$navilink
$schform
$line
$footer_link2
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

use Mebius::Tag;

#-----------------------------------------------------------
# �������s
#-----------------------------------------------------------
sub search_action{


# �Ǐ���
my($tag) = @_;
my($i,$enc_word,$line);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

$enc_word = Mebius::Encode("",$tag);

# �L�[���[�h���`
($tag) = Mebius::Tag::FixTag(undef,$tag);

# �S�^�O�t�@�C�����J��
open(ALLTAG_IN,"<","${auth_log_directory}alltag.cgi");
while(<ALLTAG_IN>){
$i++;
chomp;
if($_ =~ /\Q$tag\E/i){
$hit++;
my $enc_tag = $_;
$enc_tag =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;
$enc_tag =~ tr/ /+/;
$line .= qq(<li><a href="./tag-word-$enc_tag.html">$_</a>);
}
}
close(ALLTAG_IN);

# ���`

my $google_link = qq(<a href="http://www.google.co.jp/search?q=$enc_word&amp;sitesearch=mb2.jp&amp;ie=Shift_JIS&amp;oe=Shift_JIS&amp;hl=ja&amp;domains=mb2.jp" class="google_link" rel="nofollow">���h$in{'word'}�h��Google�������Ă݂�</a>);

if($line eq ""){ $line = qq(<h2>��������</h2>�q�b�g���܂���ł����B�L�[���[�h��ς��Ď����Ă��������B<br><br>$google_link); }
else{ $line = qq(<h2>�������� ($hit��)</h2><ul>$line</ul><br>$google_link); }

return($line);

}

1;

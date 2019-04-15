
package main;

#-----------------------------------------------------------
# ���E�`���ł̕\��
#-----------------------------------------------------------
sub auth_cdx{

# �Ǐ���
my($file,$line,$i,$yearfile,$monthfile,$comments,$link2,$index);

# �����`�F�b�N�P
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# �����`�F�b�N�Q
$yearfile = $submode2;
$yearfile =~ s/\D//g;

# ���_�C���N�g
Mebius::Redirect("","$auth_url$file/viewcomment-$yearfile",301);

exit;

# CSS��`
$css_text .= qq(
.ctextarea{width:95%;height:35px;}
.cbottun{margin-top:0.5em;}
.clog{font-size:90%;}
.lic{margin-bottom:0.3em;line-height:1.25em;}
.deleted{font-size:90%;color:#f00;}
a.me:link{color:#f00;}
a.me:visited{color:#f40;}
strong.alert{font-size:90%;color:#f00;}
table,th,tr,td{border-style:none;}
table{font-size:90%;width:100%;}
th{text-align:left;padding:0.5em 1.0em 0.5em 0.0em;}
th.date{width:20%;}
th.name{width:20%;}
th.comment{width:50%;}
td{padding:0.2em 1.0em 0.5em 0.0em;line-height:1.4em;}
td{word-wrap:break-word;}
);

# �v���t�B�[�����J��
&open($file);

# ��\���ݒ�̏ꍇ
if($ppocomment eq "3" && !$myadmin_flag){ &error("���̃����o�[�̓`���ł͔�\\���ݒ肳��Ă��܂��B","401 Unauthorized"); }

# ���[�U�[�F�w��
if($ppcolor1){ $css_text .= qq(h2{background-color:#$ppcolor1;border-color:#$ppcolor1;}); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �Y���R�����g���J��
open(COMMENT_IN,"<",${account_directory}comments/${file}_${yearfile}_comment.cgi");
while(<COMMENT_IN>){
$i++;
if($i > 500){ last; }
my($key,$rgtime,$account,$name,$trip,$id,$comment,$dates,$xip,$res,$deleter) = split(/<>/,$_);
my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);

my $link = qq($adir$account/);
if($aurl_mode){ ($link) = &aurl($link); }

$comment =~ s/<br>/ /g;
($comment) = &auth_auto_link($comment);
if($res && $res !~ /\D/){ $res = qq( ( No.$res ) ); } else { $res = ""; }

# ���ʂɕ\��
if($key eq "1"){
my($class,$del);
if($myprof_flag || $account eq "$pmfile" || $myadmin_flag){
$del = qq( <a href="$script?mode=comdel&amp;account=$file&amp;rgtime=$rgtime&amp;year=$year">�폜</a> );
}
if($account eq $file){ $class = qq( class="me"); }
$comments .= qq(<tr><td><a href="$link"$class>$name - $account</a></td><td>$comment $res $del</td><td>$year�N$month��$day�� $hour��$min��</td></tr>);
}

# �폜�ς݂̏ꍇ
else{
my($deleted,$text);
if($key eq "2"){ $text = qq($res�y�A�J�E���g��폜�z); }
elsif($key eq "3"){ $text = qq($res�y���e��폜�z); }
elsif($key eq "4"){ $text = qq($res�y�Ǘ��ҍ폜�z $deleter); }
if($myadmin_flag){ $text = qq( $comment $text); }
$text = qq(<span class="deleted">$text</span>);

$comments .= qq(<tr><td><a href="$link">$account</a></td><td>$text</td><td>$year�N$month��$day�� $hour��$min��</td></tr>);
}

}
close(COMMENT_IN);

# �t�q�k�ϊ�
if($aurl_mode){ ($comments) = &aurl($comments); }

# �R�����g�������`
$comments = qq(
<h2>�R�����g</h2>
<table summary="�`���ꗗ"><tr><th class="name">�M��</th><th class="comment">�`��</th><th class="date">����</th></tr>\n
$comments
</table>
)if $comments;

# �C���f�b�N�X�擾
allindex_auth_comment($file);

# �^�C�g����`
$sub_title = qq(${yearfile}�N${monthfile}�̓`�� : $ppname - $ppfile);

# �w�b�_
main::header();

$link2 = qq($adir$file/);
if($aurl_mode){ ($link2) = &aurl($link2); }

# HTML
print <<"EOM";
<div class="body1">
$footer_link
<h1>${yearfile}�N${monthfile}�̓`�� : $ppname - $ppfile</h1>
<a href="$link2">$ppname - $ppfile �̃v���t�B�[���ɖ߂�</a>
$comments
<h2>�N�ʈꗗ</h2>
$index
<br><br>
$footer_link2
</div>
EOM

# �t�b�^
&footer();

# �I��
exit;

}


#-----------------------------------------------------------
# �`���A�N���̃C���f�b�N�X���J��
#-----------------------------------------------------------

sub allindex_auth_comment{

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �R�����g�C���f�b�N�X���J��
open(COMMENT_INDEX_IN,"<","${account_directory}comments/${file}_index_comment.cgi");
while(<COMMENT_INDEX_IN>){
my($year) = split(/<>/,$_);
my $link = qq($adir$file/cdx-$year);
if($aurl_mode){ ($link) = &aurl($link); }
if($year eq $yearfile){ $index .= qq($year�N ); }
else{ $index .= qq(<a href="$link">$year�N</a> ); }
}
close(COMMENT_INDEX_IN);

}




1;

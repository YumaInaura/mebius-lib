
# �ő�\���s��
my $maxline = 100;

# �Ǐ���
my($new_link,$line_new,$i_line);

# CSS��`
$css_text .= qq(
.navi{font-size:90%;word-spacing:0.3em;padding:0.5em;background-color:#fcc;}
.account_list{line-height:1.5em;word-spacing:0.5em;}
);

# �^�C�g����`
$sub_title = "�ŋ߂̓o�^ - $title";
$head_link3 = qq( &gt; �ŋ߂̓o�^);

# ��{�t�@�C�����J��
if($idcheck){
open(BASE_IN,"${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");
my $top_base = <BASE_IN>;
($key_base,$num_base,$name_base) = split(/<>/,$top_base);
close(BASE_IN);
}

# �V���R�����g�t�@�C�����J��
open(NEW_COMMENT_IN,"${int_dir}_one/new_comment.cgi");
while(<NEW_COMMENT_IN>){
if($i_line > $maxline){ next; }
my($key,$comment,$date,$account,$num,$category,$name) = split(/<>/,$_);
if($myadmin_flag >= 5 && $key eq "4"){ $line_new .= qq(<li><span class="red">Secret</span> by <a href="view-$account-all-1.html">$name</a>); }
elsif($key eq "1" || $key eq "3" || $secret){ $i_line++; $line_new .= qq(<li>$comment ( <a href="view-$account-$num-1.html">$category</a> ) by <a href="view-$account-all-1.html">$name</a>); }
}
close(NEW_COMMENT_IN);
$line_new = qq(<h2>�ŋ߂̓o�^(�S�J�e�S��)</h2><ul>$line_new</ul>);

# HTML
my $print = qq(
$navi_link
<h1>�ŋ߂̓o�^ - $title</h1>
$new_link
$line_new
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

1;

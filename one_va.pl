
# �Ǐ���
my($new_link,$line_new,$i_line);

# CSS��`
$css_text .= qq(
.navi{font-size:90%;word-spacing:0.3em;padding:0.5em;background-color:#fcc;}
.account_list{line-height:1.5em;word-spacing:0.5em;}
);

# �^�C�g����`
$sub_title = "�S�Q���� - $title";
$head_link3 = qq( &gt; �S�Q����);

# ��{�t�@�C�����J��
if($idcheck){
open(BASE_IN,"${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");
my $top_base = <BASE_IN>;
($key_base,$num_base,$name_base) = split(/<>/,$top_base);
close(BASE_IN);
}

# �V�K�����o�[�t�@�C�����J��
open(NEWCOMER_IN,"${int_dir}_one/newcomer.cgi");
my($i_newcomer);
while(<NEWCOMER_IN>){
$i_newcomer++;
my($name,$account) = split(/<>/,$_);
$line_newcomer .= qq( <a href="view-$account-all-1.html">$name</a>);
#if($i_newcomer >= 10){ last; }

}
close(NEWCOMER_IN);
$line_newcomer = qq(<h2>�S�Ă̎Q����</h2><div class="account_list">$line_newcomer</div>);

# HTML
my $print = qq(
$navi_link
<h1>�S�Q���� - $title</h1>
$new_link
$line_newcomer
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

1;

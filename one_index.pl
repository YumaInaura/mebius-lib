

# �A�J�E���g�̍ő�\����
my $max_aclist = 30;

# �Ǐ���
my($new_link,$line_new,$i_line);

# �w�b�_�����N
$head_link2 = qq( &gt; $title);

# CSS��`
$css_text .= qq(
.navi{font-size:90%;word-spacing:0.3em;padding:0.5em;background-color:#fcc;}
.account_list{line-height:1.5em;word-spacing:1em;padding-left:0.5em;}
);


# ��{�t�@�C�����J��
if($idcheck){ &base_open($pmfile); }

# Cookie���Ȃ��ꍇ
if(!$cookie){  $new_link = qq( �����̊��ł͐V�K�Q���ł��܂���B); }
# ���O�C�����Ă��Ȃ��ꍇ
elsif(!$idcheck){ $new_link = qq(
<h2>�����o�[���O�C��</h2>
�Q������ɂ́A���O�C��(<a href="newform.html">�܂��͐V�K�o�^</a>)���Ă��������B<a href="$auth_url">���r�����r�m�r</a>�Ƌ��ʂ̃A�J�E���g�ł��B<br><br>
<form action="$auth_url" method="post"$sikibetu>
<div><table>
<tr>
<td class="nowrap">�A�J�E���g��</td><td>
<input type="text" name="authid" value="" class="putid"$maxlengthac>
( ��F mickjagger )</td>
</tr>
<tr>
<td class="nowrap">�p�X���[�h</td>
<td><input type="password" name="passwd1" value="" maxlength="8">
(��F Adfk432d )</td>
</tr>
<tr><td></td><td>
<input type="submit" value="���O�C������">
<input type="hidden" name="mode" value="login">
<input type="hidden" name="back" value="one">
</td></tr>
</table></div>
</form>


); }
# �A�J�E���g�쐬�ς݂̏ꍇ
elsif($key_base eq "1"){ $new_link = qq(<br>�@<a href="$script?mode=view-$pmfile-all-1">�����Ȃ�($name_base)�̃}�C���O�͂�����ł�</a>); }
# �A�J�E���g���쐬�̏ꍇ
else{ $new_link = qq(<br>�@<a href="$script?mode=start">�������炩��h$title�h�ɎQ���ł��܂��B</a>); }

# �i�r�Q�[�V���������N
my $navi_link = qq(<div class="navi">���̃T�C�g�F <a href="http://aurasoul.mb2.jp/">���r�����ʏ��</a> <a href="http://mb2.jp/">���r������y��</a> <a href="$auth_url">���r�����r�m�r</a></div><br>);

# �V���R�����g�t�@�C�����J��
open(NEW_COMMENT_IN,"${int_dir}_one/new_comment.cgi");
while(<NEW_COMMENT_IN>){
if($i_line > 10){ next; }
my($key,$comment,$date,$account,$num,$category,$name) = split(/<>/,$_);
if($key eq "1"){ $i_line++; $line_new .= qq(<li>$comment ( <a href="view-$account-$num-1.html">$category</a> ) by <a href="view-$account-all-1.html">$name</a>); }
}
close(NEW_COMMENT_IN);
$line_new = qq(<h2>�ŋ߂̓o�^ (�����J�e�S���̂�)</h2><ul>$line_new</ul><br><a href="vc-all-1.html">���S�Ă̓o�^������</a>);

# �V�K�����o�[�t�@�C�����J��
open(NEWCOMER_IN,"${int_dir}_one/newcomer.cgi");
my($i_newcomer);
while(<NEWCOMER_IN>){
$i_newcomer++;
my($name,$account) = split(/<>/,$_);
$line_newcomer .= qq( <a href="view-$account-all-1.html">$name</a>);
if($i_newcomer >= $max_aclist){ last; }

}
close(NEWCOMER_IN);
$line_newcomer = qq(<h2>�ŋ߂̎Q����</h2><div class="account_list">$line_newcomer</div><br><a href="va-all-1.html">���S�Ă̎Q���҂�����</a>);

# HTML
my $print = qq(
$navi_link
<h1>$title</h1>
�J�e�S�������A�P�s�����͂��������Ƃ��o����c�[���ł��B<br>
�����A���C�t���O�A���P�̒u����A�v�l�̐�����ȂǂƂ��Ă����p�������� (<a href="${guide_url}%A5%DE%A5%A4%A5%ED%A5%B0">�������Əڂ���</a>)�B<br>
$new_link
$line_newcomer
$line_new
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

1;

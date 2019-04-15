
# �Ǐ���
my($select_line,$form,$line,$navi_line,$category_line,$view_category,$base_form);

# CSS��`
$css_text .= qq(
hr{border-top:1px #088 solid;border-bottom:1px #fff solid;}
.category_list{font-size:90%;word-spacing:0.3em;line-height:1.3em;}
.guide{color:#070;font-size:90%;}
);

# �t�@�C����`
my $file = $submode2;
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("�y�[�W�����݂��܂���B"); }

# ���O�C�����Ă��Ȃ��ꍇ
if(!$idcheck){ &error("���̃y�[�W�𗘗p����ɂ�<a href=\"$auth_url\">���r�����r�m�r</a>�Ƀ��O�C��������ŁA�����P��A�N�Z�X���Ă��������B"); }

# �����łȂ��ꍇ
if($pmfile ne $file && !$myadmin_flag){ &error("�����ł͂���܂���B"); }

# �ҏW���s
if($in{'action'} eq "base_edit"){ &action_edit; }

# ��{�t�@�C�����J��
&base_open($file);

# �o�^�J�n���ĂȂ��ꍇ
if($key_base ne "1" && !$myadmin_flag){ &error("�o�^�J�n���Ă��������B"); }

# �J�e�S�����X�g�����i�P�j
$navi_line .= qq( <a href="view-$submode2-all-1.html">�S�J�e�S��</a>);

# �J�e�S���L�^�t�@�C�����J��
open(CATE_IN,"${int_dir}_one/_idone/${file}/${file}_cate.cgi");
while(<CATE_IN>){
my($category,$num) = split(/<>/,$_);
$select_line .= qq(<option value="$category">$category);
$navi_line .= qq( <a href="view-$file-$num-1.html">$category</a>);
push(@now_category,$category);
#$category_line .= qq(<li><a href="view-$submode2-$num.html">$category</a> );
}
close(CATE_IN);

# �J�e�S�����X�g�����i�Q�j
$navi_line .= qq( <span class="red">�ݒ�</span>);
if($navi_line){ $navi_line = qq(<div class="category_list">�J�e�S���F $navi_line</div>); }
#$category_line = qq(<h3>���݂̃J�e�S��</h3><ul>$category_line</ul>);

# �����̃A�J�E���g�̏ꍇ�A�t�H�[�����擾
if($pmfile eq $submode2 || $myadmin_flag){ &one_edit_get_form(); }

# �����N�Ȃǂ̕\������
my $name_view = $name_base;
if($trip_base){ $name_view = qq($name_view��$trip_base); }
#if($account_base){ $account_link = qq( / �A�J�E���g�F <a href="${auth_url}$account_base/">$account_base</a> ); }

# �^�C�g����`
$sub_title = qq($view_category$name_base - $title);

# HTML
my $print = qq(
<h1>�ݒ�F $name_view��$title</h1>
$navi_line
$account_link
$base_form
$form
$line
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

#-----------------------------------------------------------
# �ݒ�t�H�[��
#-----------------------------------------------------------
sub one_edit_get_form{

# �Ǐ���
my($viewtime_checked,$input_trip,$input_lock,$lock_checked,$input_mainnews);

# �`�F�b�N��`
if($viewtime_base eq "1"){ $viewtime_checked = " checked"; }

# ��{�ݒ�t�H�[��
if($itrip_base ne ""){ $input_trip = qq(#$itrip_base); }

# �Ǘ��ݒ�
if($myadmin_flag){
if($key_base eq "2"){ $input_lock .= qq(<br><input type="checkbox" name="unlock" value="1"> �A�J�E���g�����b�N�����i�Ǘ��Ґݒ�j ���݂̃L�[�F $key_base); }
else{ $input_lock .= qq(<br><input type="checkbox" name="lock" value="1"> �A�J�E���g�����b�N�i�Ǘ��Ґݒ�j ���݂̃L�[�F $key_base); }
if($mainnews_base eq "2"){ $input_mainnews .= qq(<input type="checkbox" name="mainnews_unlock" value="1"> �����J�e�S���̐V���f�ڂ������i�Ǘ��Ґݒ�j ���݂̃L�[�F $mainnews_base); }
else{ $input_mainnews .= qq(<input type="checkbox" name="mainnews_lock" value="1"> �����J�e�S���̐V���f�ڂ����b�N�i�Ǘ��Ґݒ�j ���݂̃L�[�F $mainnews_base); }
}

$base_form .= qq(
<h2>��{�ݒ�</h2>
<form action="$action" method="post"$sikibetu>
<div>
�M���F <input type="text" name="name" value="$name_base$input_trip">
<input type="checkbox" name="viewtime" value="1"$viewtime_checked> ������\\������
<input type="submit" value="���̓��e�Őݒ肷��">
$input_lock
$input_mainnews
<input type="hidden" name="mode" value="edit-$file">
<input type="hidden" name="action" value="base_edit">
$actioned_text
</div>
</form>
);

# ��{�J�e�S���W�J
$base_category .= qq(<h3 class="red">�����J�e�S��</h3><ul>);
foreach(@base_category){
my($category,$guide) = split(/=/,$_);
my($flag);
foreach(@now_category){ if($_ eq $category){ $flag = 1; } }

$base_category .= qq(<li>$category - <span class="guide">$guide</span>);

if($flag){
$base_category .= qq(�i �ǉ��ς݂ł� �j)
}
else{
my $enc_category = $category;
$enc_category =~ s/(\W)/'%' . unpack('H2', $1)/eg;
$enc_category =~ s/\s/+/g;
$base_category .= qq(�i <a href="$script?mode=make_category&amp;account=$file&amp;category=$enc_category">�����̃J�e�S����ǉ�</a> �j)
}
}
$base_category .= qq(</ul>);

# �J�e�S���o�^�t�H�[��
$form = qq(
<h2>�J�e�S���ݒ�</h2>
$base_category
<h3>�J�e�S���ǉ� (�t���[���[�h)</h3>
<form action="$action" method="post"$sikibetu>
<div>
�J�e�S�����F 
<input type="text" name="category" value="">
<input type="submit" value="���̃J�e�S����ǉ�����">
<input type="hidden" name="mode" value="make_category">
<input type="hidden" name="account" value="$file">
<input type="checkbox" name="type" value="secret"> �V�[�N���b�g���[�h

</div>
</form>
);



}

#-----------------------------------------------------------
# �ҏW���s
#-----------------------------------------------------------
sub action_edit{

# �Ǐ���
my($viewtime);

# �e��G���[
if(!$postflag){ &error("GET���M�͏o���܂���B"); }

# �g���b�v�擾
&trip($in{'name'});

# ID�擾
&id("ACCOUNT");

# ���e����
&axscheck("ACCOUNT");

# �e��`�F�b�N
require "${int_dir}regist_allcheck.pl";
($in{'name'}) = shift_jis(Mebius::Regist::name_check($in{'name'}));

# �G���[��\��
&error_view;

# �o�^���e�̃`�F�b�N
if($in{'viewtime'}){ $viewtime = 1; } else { $viewtime = 2; }

# ���b�N�J�n
&lock("${file}ONE") if $lockkey;

# ��{�t�@�C�����J��
&base_open($file);

# �o�^�J�n���ĂȂ��ꍇ
if($key_base ne "1" && !$myadmin_flag){ &error("�o�^�J�n���Ă��������B"); }

# �A�J�E���g���b�N�̏ꍇ
if($myadmin_flag){
if($in{'lock'}){ $key_base = 2; }
if($in{'mainnews_lock'}){ $mainnews_base = 2; }
if($in{'unlock'}){ $key_base = 1; }
if($in{'mainnews_unlock'}){ $mainnews_base = 1; }
}


# ��{�t�@�C������������
my $line = qq($key_base<>$num_base<>$i_handle<>$enctrip<>$encid<>$file<>$i_trip<>$lastnum_base<>$viewtime<>$mainnews_base<>$news_base<>\n);
open(BASE_OUT,">${int_dir}_one/_idone/${file}/${file}_base.cgi");
print BASE_OUT $line;
close(BASE_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${file}/${file}_base.cgi");

# ���b�N����
&unlock("${file}ONE") if $lockkey;

# �ύX���܂����`�̃e�L�X�g
$actioned_text = qq(<strong class="red">���ݒ��ύX���܂����B</strong>);

}

1;

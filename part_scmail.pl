
package main;

#-----------------------------------------------------------
# ���[�h�U�蕪��
#-----------------------------------------------------------
sub bbs_scmail{
if($in{'action'}){ &bbs_scmail_action(); }
else{ &bbs_scmail_form(); }
}

#-----------------------------------------------------------
# ���M�p�t�H�[��
#-----------------------------------------------------------
sub bbs_scmail_form{

# �Ǐ���
my($line,$flag,$i);

# ���[�h�G���[
if(!$secret_mode){ &error("�y�[�W������܂���B"); }

# CSS��`
$css_text .= qq(
textarea{width:80%;height:200px;}
input.text{width:12em;}
form{margin:1em 0em;}
);

# �^�C�g����`
$sub_title = qq( $scad_name �Ƀ��[�� );
$head_link3 = qq( &gt; $scad_name �Ƀ��[�� );

# HTML
my $print = qq(
<h1>�Ǘ��� ( $scad_name ) ���Ẵ��[���t�H�[��</h1>
<span class="alert">���u���[�U�[���v���ꏏ�ɑ��M����܂��B</span>

<form action="$script" method="post"$sikibetu>
<div>
<input type="hidden" name="mode" value="scmail">
<input type="hidden" name="moto" value="$realmoto">
�M�� <input type="text" name="name" value="$scmy_handle" class="text" disabled>
���[���A�h���X <input type="text" name="email" value="$scmy_email" class="text"><br>
�{��
<textarea name="comment" class="comment"></textarea>
<br><br>
<input type="submit" name="action" value="���̓��e�ő��M����">
</div>
</form>
);

Mebius::Template::gzip_and_print_all({},$print);

# �I��
exit;
}
#-----------------------------------------------------------
# ���[���𑗐M
#-----------------------------------------------------------
sub bbs_scmail_action{

# �Ǐ���
my($basic_init) = Mebius::basic_init();
my($mailto,$subject,$body,$address,$comment);

# �A�N�Z�X����
&axscheck;

# GET���M���֎~
if(!$postflag){ &error("GET���M�͏o���܂���B"); }

# �{�����t�b�N
$fook_error = qq(�{���F $in{'comment'});

# �e��`�F�b�N
if(length($in{'comment'}) > 5000*2 || length($in{'comment'}) < 10*2){ &error("�S�p10�����ȏ�A5000�����ȓ��ő��M���Ă��������B"); }
if($scad_email eq ""){ &error("�Ǘ��҂����[���A�h���X��ݒ肵�Ă��܂���B<a href=\"mailto:$basic_init->{'admin_email'}\">$basic_init->{'admin_email'}</a> �܂ł��A�����������B"); }

# ����
$mailto = $scad_email;

# E-Mail�����`�F�b�N
$address = $in{'email'};
$address =~ s/( |�@)//g;
if($address eq "") { &error("���[���A�h���X����͂��Ă��������B"); }
if(length($address) > 256) { &error("���[���A�h���X���������܂��B"); }
if($address =~ /[^0-9a-zA-Z_\-\.\@]/) { &error("���[���A�h���X�̏������Ԉ���Ă��܂��B"); }
if($address && $address !~ /^[\w\.\-]+\@[\w\.\-]+\.[a-zA-Z]{2,6}$/) { &error("���[���A�h���X�̏������Ԉ���Ă��܂��B"); }

# ���[���薼
$subject = qq(��������[���t�H�[����� - $scmy_handle);

# ���[���{���𐮌`
$comment = $in{'comment'};
$comment =~ s/<br>/\n/g;

# ���[���{��
$body = qq(
$comment

������������������������������������������������������������

�M���F $scmy_handle
���[�U�[���F $username
���[���A�h���X�i���́j�F $address
���[���A�h���X�i�o�^�j�F $scmy_email
�Ǘ��ԍ��F $cnumber
�A�J�E���g�F ${main::auth_url}$pmfile/
�t�`�F $age
�t�q�k�F http://aurasoul.mb2.jp/jak/$moto.cgi

������������������������������������������������������������);

# ���[���𑗐M
Mebius::send_email(undef,$mailto,$subject,$body);

# �W�����v
$jump_url = $script;
$jump_sec = 2;


# HTML
my $print = qq(����ɑ��M����܂����B( <a href="$jump_url">���߂�</a> ));

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


1;

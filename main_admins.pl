
use Mebius::Admin;

#-----------------------------------------------------------
# �Ǘ��҂̃��[���A�h���X
#-----------------------------------------------------------
sub main_admins{

my($line) = Mebius::Admin::MemberList("Get-index-normal");

	# �e�Ǘ��҂̃����t�H
	if($submode2 eq "form"){ &main_admins_mailform("$line"); }
	else{ &admins_list("$line"); }

}

#-----------------------------------------------------------
# �Ǘ��҂̈ꗗ��\��
#-----------------------------------------------------------

sub admins_list{

my($line) = @_;

# �^�C�g����`
$sub_title = "�Ǘ��҈ꗗ";
$head_link3 = qq(&gt; �Ǘ��҈ꗗ);


# HTML
my $print = <<"EOM";
<a href="http://aurasoul.mb2.jp/">�s�n�o�y�[�W</a>
<a href="JavaScript:history.go(-1)">�O�̉�ʂ�</a><br><br>

<h1>�Ǘ��҈ꗗ</h1>
$line
EOM

Mebius::Template::gzip_and_print_all({},$print);

# �I��
exit;
}

#-----------------------------------------------------------
# �e�Ǘ��҂փ��[��
#-----------------------------------------------------------
sub main_admins_mailform{

my $second_id = $main::submode3;

	my(%fook_member) = Mebius::Admin::MemberFookFile("Get-hash File-check-error",$second_id);
	my(%member) = Mebius::Admin::MemberFile("Get-hash File-check-error Allow-empty-password",$fook_member{'id'});

	if($member{'use_mailform'} ne "1" || !$member{'email'}){ main::error("���̊Ǘ��҂̓��[���t�H�[����ݒ肵�Ă��܂���B"); }


	# ���[�����M����
	if($main::postflag && $main::in{'send_mail'}){
		Mebius::Redun(undef,"Mail-to-admin",5*60);
		Mebius::send_email(undef,$member{'email'},"$member{'name'}�ւ̃��b�Z�[�W - $main::in{'name'}",qq($main::in{'comment'}),$main::in{'email'});
	}

# �^�C�g����`
$sub_title = "$member{'name'}�ւ̃��[��";
$head_link3 = qq(&gt; $member{'name'}�ւ̃��[��);

# CSS��`
$css_text .= qq(
.msgform{width:80%;height:200px;}
);


# �Ǘ��҂ɃA�J�E���g����ꍇ
if($faccount){ $pri_fname = qq(<a href="${auth_url}$faccount/">$fname</a>); }

# HTML
my $print = <<"EOM";
<div>
<a href="http://aurasoul.mb2.jp/">�s�n�o�y�[�W</a>
<a href="JavaScript:history.go(-1)">�O�̉�ʂ�</a>
</div>
<h1>$member{'name'}�ւ̃��[��</h1>

$member{'name'} �ւ̃��b�Z�[�W�A���A���͂����炩��ǂ����B<br>
�������A�������e�������Ǘ��ҁi���Y�}�X�^�[�j�ɂ����M����܂��B<br><br>

�������ł͍폜�˗��Ȃǂ̏d�v�A���͎󂯕t���Ă��܂���B<br><br>

<h2>���M�t�H�[��</h2>

<form action="./" method="post">
<div>
<input type="hidden" name="mode" value="admins-form-$second_id">
<input type="hidden" name="send_mail" value="1">
�M��<br>
<input type="text" name="name" value="$main::chandle"><br>
���[���A�h���X<br>
<input type="text" name="email" value="$main::cemail"><br>
�{��<br>
<textarea name="comment" rows="6" cols="50" class="msgform"></textarea>
<br><input type="submit" value="���̓��e�ő��M����">
</div>
</form>
EOM

Mebius::Template::gzip_and_print_all({},$print);

# �I��
exit;

}


1;

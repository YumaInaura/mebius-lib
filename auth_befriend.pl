

use strict;
package Mebius::Auth;

#-----------------------------------------------------------
# �ݒ�
#-----------------------------------------------------------
sub init_befriend{

return({
max_length_intro => 500,
wait_apply_hour => 24,
});

}

package main;

#-----------------------------------------------------------
# �}�C���r�̏���
#-----------------------------------------------------------
sub auth_befriend{

my($init_befriend) = Mebius::Auth::init_befriend();
my($my_account) = Mebius::my_account();

# �錾
our(%in);

	if($main::stop_mode =~ /SNS/){
		main::error("���݁ASNS�͍X�V��~���ł��B");
	}

# �^�C�g����`
our $title;
our $sub_title = "$main::friend_tag - $title";

# �A���\���̑҂����� 
my $wait_befriend = $init_befriend->{'wait_apply_hour'};
our $wait_befriend_sp = 6;
if($main::myaccount{'level2'} >= 1){ $wait_befriend = $wait_befriend_sp; }

# �����`�F�b�N
$main::in{'account'} =~ s/[^0-9a-z]//g;

our $head_link3 = qq(&gt; <a href="$main::in{'account'}/">$main::in{'account'}</a>);
our $head_link4 = "&gt; $main::friend_tag�\\��";

	# �M�����ݒ�G���[
	if($my_account->{'birdflag'}){ main::error("���̃y�[�W�𗘗p����ɂ́A���Ȃ��̕M����ݒ肵�Ă��������B"); }

	#��������
	if($main::in{'action'} && $main::in{'decide'} eq "ok"){ Mebius::Auth::AllowFriend("",$wait_befriend); }
	elsif($main::in{'action'} && $main::in{'decide'} eq "no"){ &auth_action_nofriend("",$wait_befriend); }
	elsif($main::in{'action'} && $main::in{'decide'} eq "delete"){ &auth_action_deletefriend("",$wait_befriend); }
	elsif($main::in{'action'} && $main::in{'decide'} eq "deny"){ Mebius::Auth::DenyFriend("",$wait_befriend); }
	elsif($main::in{'action'} && $main::in{'decide'} eq "intro"){ &auth_action_introfriend("",$wait_befriend); }
	elsif($main::in{'decide'} eq "edit"){ &auth_editfriend("",$wait_befriend); }
	elsif($main::in{'decide'} eq "ok"){ Mebius::Auth::AllowFriendView("",$wait_befriend); }
	elsif($main::in{'decide'} eq "no"){ &auth_nofriend("",$wait_befriend); }
	elsif($main::in{'decide'} eq "deny"){ &auth_denyfriend("",$wait_befriend); }
	else{ Mebius::Auth::BefriendForm("",$wait_befriend); }

}


package Mebius::Auth;

#-------------------------------------------------
# �}�C���r�\���p�y�[�W
#-------------------------------------------------
sub BefriendForm{

# �Ǐ���
my($type,$wait_befriend) = @_;
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();

# CSS��`
$main::css_text .= qq(
textarea.apply_comment{width:50%;height:100px;}
);

# �v���t�B�[���I�[�v���A�L�[�`�F�b�N
my(%account) = Mebius::Auth::File("Option File-check-error Key-check-error Lock-check-error",$main::in{'account'});

	# �M�����ݒ�G���[
	if($account{'birdflag'}){ main::error("���̃����o�[�͕M�������ݒ�̂��߁A�\\���ł��܂���B"); }

# �o�^�ς݂��ǂ������`�F�b�N
my(%friend1) = Mebius::Auth::FriendStatus("Get-hash Deny-check-error Me-check-error",$account{'file'},$main::myaccount{'file'});
my(%friend2) = Mebius::Auth::FriendStatus("Get-hash Deny-check-error Me-check-error Still-apply-check",$main::myaccount{'file'},$account{'file'});

	# ����
	if($friend1{'staus'} eq "friend" && $friend2{'staus'} eq "friend"){ main::error("���̃����o�[�ɂ́A���Ƀ}�C���r�ł��B"); }

	if($friend2{'status'} eq "apply" && !$my_account->{'admin_flag'}){ main::error("���ɐ\\�����ł��B"); }

	# �\���̎��s
	if($main::in{'action'}){ &BefriendApply("",$wait_befriend); }

	# �X�y�V��������̏Љ�
	my($text1,$text2);
	if($main::myaccount{'level2'} < 1){ $text1 = qq(<a href="$main::myaccount{'file'}/spform">�X�y�V��������o�^</a>������ƁA$main::friend_tag�̏���𑝂₷���Ƃ��o���܂��B); }
	if($main::myaccount{'level2'} < 1){ $text2 = qq(<a href="$main::myaccount{'file'}/spform">�X�y�V��������o�^</a>������ƁA�҂����Ԃ�$main::wait_befriend_sp���ԂɌ��炷���Ƃ��o���܂��B); }

# HTML
my $print = qq(
$main::footer_link
<h1$main::kstyle_h1>�}�C���r�\\��</h1>
<div class="line-height">
$account{'name_link'}�����$main::friend_tag�\\�����܂��B</div><br$main::xclose>);

	# �X�g�b�v���[�h
	if($main::stop_mode =~ /SNS/){ $print .= qq(<div>�y���݁ASNS�S�̂ōX�V��~���ł��z</div><br>); }

	# ���O�C�����Ă��Ȃ��ꍇ
	elsif(!$main::myaccount{'file'}){
		$print .= qq(<div>�\\������ɂ́A�A�J�E���g��<a href="$basic_init->{'auth_url'}?backurl=$main::selfurl_enc">���O�C��</a>���Ă��������B</div>);
	}

	# �����̃}�C���r�ő吔���`�F�b�N
	elsif($main::myaccount{'max_friend_flag'}){ $print .= qq($main::myaccount{'max_friend_flag'}); }

	# ����̃}�C���r�ő吔���`�F�b�N
	elsif($account{'max_friend_flag'}){ $print .= qq($account{'max_friend_flag'}); }

	# �A���\���`�F�b�N
	elsif($main::time < $main::myaccount{'last_apply_friend_time'} + $wait_befriend*60*60 && !$main::alocal_mode){
		$print .= qq(<div>�A���\\���͏o���܂���B${wait_befriend}���Ԃ̊Ԋu�������Ă��������B</div>);
	}

	# ���ʂɕ\��
	else{
		$print .= qq(
		<form action="$main::action" method="post"$main::sikibetu><div>
		<input type="hidden" name="mode" value="befriend">
		<input type="hidden" name="action" value="1">
		�\\���R�����g�F<br$main::xclose><br$main::xclose>
		<textarea name="apply_comment" class="apply_comment"></textarea>
		<br$main::xclose><br$main::xclose><input type="hidden" name="account" value="$account{'file'}">
		<input type="submit" value="�\\������" class="isubmit">
		</div></form>
		);
	}

$print .= qq(
<br>
<div style="color:#f00;" class="line-height margin">
���m�荇���A�����̂���l�Ȃǂɐ\\�����Ă��������B�i�����ʂȐ\\���͍T���Ă��������j<br>
���ő�o�^����$main::max_myfriend�l�܂łł��B$text1<br>
���P��\\��������ƁA���ɐ\\���ł���̂�${wait_befriend}���Ԍ�ł��B$text2
</div><br>
$main::footer_link2

);

Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}


#-------------------------------------------------
# �}�C���r�\�������s����
#-------------------------------------------------
sub BefriendApply{

# �錾
my($type,$wait_befriend) = @_;
my($time_handler,$befriend_handler,$i,@renew_line,%renew_option);
my($my_account) = Mebius::my_account();

# �}�C���r�\���̍ő吔�i�󂯎葤�j�̒�`
my $maxline_befriend = 25;

# �A�N�Z�X����
main::axscheck("ACCOUNT Post-only Login-check");

# �A�J�E���g�t�@�C�����J��
my(%account) = Mebius::Auth::File("Option Get-hash File-check-error Key-check-error",$main::in{'account'});

	# �}�C���r��� / �֎~��Ԃ��`�F�b�N
	if(Mebius::alocal_judge() && $main::in{'apply_comment'} =~ /break/i){
		1;
	}
	else{
		Mebius::Auth::FriendStatus("Deny-check-error Yet-friend-check-error Me-check-error",$account{'file'},$my_account->{'file'});
		Mebius::Auth::FriendStatus("Deny-check-error Yet-friend-check-error Me-check-error",$my_account->{'file'},$account{'file'});
	}

# �\���ς݂��ǂ������`�F�b�N
my($apply) = Mebius::Auth::ApplyFriendIndex(undef,$account{'file'},$main::myaccount{'file'});
if($apply->{'still_apply_flag'} && !Mebius::alocal_judge()){ main::error("���̃����o�[�ɂ́A���ɐ\\���ς݂ł��B"); }

# �M�����ݒ�G���[
if($account{'birdflag'}){ main::error("���̃����o�[�͕M�������ݒ�̂��߁A�y�[�W�����p�ł��܂���B"); }

	# �A���\���`�F�b�N
	if(time < $my_account->{'last_apply_friend_time'} + $wait_befriend*60*60 && !Mebius::alocal_judge()){
		main::error("�A���\\���͏o���܂���B${wait_befriend}���Ԃ̊Ԋu�������Ă��������B");
	}

	# �\���R�����g�`�F�b�N
	if($main::in{'apply_comment'}){
		require "${main::int_dir}regist_allcheck.pl";
		main::all_check("Error-view",$main::in{'apply_comment'});
		if(length($main::in{'apply_comment'}/2) >= 1000){ main::error("�\\���R�����g���������܂��B"); }
	}

# ���b�N�J�n
main::lock("friend");

# ����̃}�C���r�\���t�@�C�����X�V
my($new_apply) = Mebius::Auth::ApplyFriendIndex("New-apply Renew",$account{'file'},$my_account->{'file'},$main::myaccount{'name'},$main::in{'apply_comment'});


# ����Ƀ��[���𑗐M
my %mail;
$mail{'url'} = "$account{'file'}/aview-befriend";
$mail{'subject'} = qq($my_account->{'name'}���񂩂�$main::friend_tag�\\�����͂��܂����B);
$mail{'comment'} = qq($main::in{'apply_comment'});
Mebius::Auth::SendEmail(" Type-etc",\%account,\%main::myaccount,\%mail);

# ���b�N����
main::unlock("friend");

# �����̃t�@�C�����ŁA����̃}�C���r��Ԃ��u�\�����v�ɕύX
Mebius::Auth::FriendStatus("Renew Apply-friend",$my_account->{'file'},$account{'file'});

# �����̍ŏI�\�����Ԃ��X�V
#$renew_option{'last_apply_friend_time'} = time;
#Mebius::Auth::Optionfile("Renew",$main::myaccount{'file'},%renew_option);

	# �����̍ŏI�\�����Ԃ��X�V
	{
		my(%renew_account);
		$renew_account{'last_apply_friend_time'} = time;
		Mebius::Auth::File("Renew Option",$my_account->{'file'},\%renew_account);
	}


# �y�[�W�W�����v
$main::jump_sec = $main::auth_jump;
$main::jump_url = "$account{'file'}/";


# HTML
my $print = qq($account{'name_link'}�����$main::friend_tag�\\�����܂����B�i<a href="$main::jump_url">���߂�</a>�j);

Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}

#-------------------------------------------------
# �}�C���r���̃y�[�W
#-------------------------------------------------
sub AllowFriendView{

my($flag,$print);
my($my_account) = Mebius::my_account();

# ���O�C������
Mebius::LoginedCheck("Error-view");

# �A�J�E���g�t�@�C�����J��
my(%account) = Mebius::Auth::File("Option File-check-error",$main::in{'account'});

# �o�^�ς݂��ǂ������`�F�b�N
my(%friend1) = Mebius::Auth::FriendStatus("Get-hash Deny-check-error Me-check-error",$account{'file'},$my_account->{'file'});
my(%friend2) = Mebius::Auth::FriendStatus("Get-hash Deny-check-error Me-check-error",$my_account->{'file'},$account{'file'});

$main::head_link4 = "&gt; $main::friend_tag����";


	# �X�g�b�v���[�h
	if($main::stop_mode =~ /SNS/){
		$print = qq(
		$main::footer_link
		<h1>$main::friend_tag����</h1>
		���݁ASNS�S�̂ōX�V��~���ł��B
		$main::footer_link2
		);

	}

	# �ʏ�ʂ�\��
	else{

		$print = qq(
		$main::footer_link
		<h1$main::kstyle_h1>$main::friend_tag��������</h1>
		<form action="$main::action" method="post"$main::sikibetu>
		<div>
		$account{'name_link'}�����$main::friend_tag�o�^���܂��B<br>
		��낵����Ή��̃{�^���������Ă��������B<br>
		<input type="hidden" name="mode" value="befriend">
		<input type="hidden" name="decide" value="ok">
		<input type="hidden" name="action" value="1">
		<input type="hidden" name="account" value="$main::in{'account'}"><br>
		<input type="submit" value="$main::in{'account'}�����$main::friend_tag�o�^����">
		<br><br>
		</div></form>
		$main::footer_link2
		);

	}

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-------------------------------------------------
# �}�C���r�̋������s����
#-------------------------------------------------
sub AllowFriend{

# �錾
my($type) = @_;
my($file,$line,$line4,$line2);
my(%renew_friend_index1,%renew_friend_index2);
my($my_account) = Mebius::my_account();
my $operate = new Mebius::Operate;

# �A�N�Z�X����
main::axscheck("ACCOUNT Post-only Login-check");

# ����̃t�@�C�����J��
my(%account) = Mebius::Auth::File("Option File-check-error Key-check-error",$main::in{'account'});

	# �����̃}�C���r�ő吔���`�F�b�N
	if($my_account->{'max_friend_flag'}){ main::error($my_account->{'max_friend_flag'}); }

	# ����̃}�C���r�ő吔���`�F�b�N
	if($account{'max_friend_flag'}){ main::error($account{'max_friend_flag'}); }

# �o�^�ς݂��ǂ������`�F�b�N
my(%friend1) = Mebius::Auth::FriendStatus("Get-hash Deny-check-error Me-check-error",$account{'file'},$my_account->{'file'});
my(%friend2) = Mebius::Auth::FriendStatus("Get-hash Deny-check-error Me-check-error",$my_account->{'file'},$account{'file'});

# ���b�N�J�n
main::lock("friend");

# �����̏��F�҂��t�@�C�����X�V ( ���肩��̐\�����Ȃ��ꍇ�̓G���[�� ) ( A-1 )
	# ���G���[��\�����邽�߁A���̏�������ԍŏ��ɒu������
Mebius::Auth::ApplyFriendIndex("Allow-apply Renew",$my_account->{'file'},$account{'file'});

# ����̏��F�҂��t�@�C�����X�V
Mebius::Auth::ApplyFriendIndex("Delete-apply Renew",$account{'file'},$my_account->{'file'});

# ���݂��̃}�C���r�ɁA����ƃ}�C���r�ɂȂ������Ƃ�`���� ( A- 1 )
Mebius::Auth::FriendIndex("Tell-new-friend",$my_account->{'file'},$account{'file'});
Mebius::Auth::FriendIndex("Tell-new-friend",$account{'file'},$my_account->{'file'});

# �����̃}�C���r�ꗗ���X�V ( A- 2 )
$renew_friend_index1{'account'} = $account{'file'};
$renew_friend_index1{'handle'} = $account{'name'};
Mebius::Auth::FriendIndex("Renew New-friend",$my_account->{'file'},%renew_friend_index1);

# ����̃}�C���r�ꗗ���X�V ( A- 2 )
$renew_friend_index2{'account'} = $my_account->{'file'};
$renew_friend_index2{'handle'} = $my_account->{'name'};
Mebius::Auth::FriendIndex("Renew New-friend",$account{'file'},%renew_friend_index2);

# �����̃}�C���r�ʃt�@�C�����쐬
Mebius::Auth::FriendStatus("Renew Be-friend",$my_account->{'file'},$account{'file'});

# ����̃}�C���r�ʃt�@�C�����쐬
Mebius::Auth::FriendStatus("Renew Be-friend",$account{'file'},$my_account->{'file'});

	# �A�J�E���g�t�@�C�����X�V
	{
		my @my_account_friends = $operate->push_unique_near_array($my_account->{'friend_accounts'},$main::in{'account'});
		my @target_account_friends = $operate->push_unique_near_array($account{'friend_accounts'},$my_account->{'id'});

		Mebius::Auth::File("Renew",$my_account->{'id'},{ friend_accounts => "@my_account_friends" });
		Mebius::Auth::File("Renew",$main::in{'account'},{ friend_accounts => "@target_account_friends" });
	}

# ���b�N����
main::unlock("friend");

# �L�^
Mebius::AccessLog(undef,"SNS-be-friend","$my_account->{'file'} ����� $account{'file'} ���� �F�����ɂȂ�܂����B");

# ���_�C���N�g
Mebius::Redirect(undef,"$my_account->{'profile_url'}aview-befriend");

exit;


}

package main;

#-------------------------------------------------
# �}�C���r���ۂ̃y�[�W
#-------------------------------------------------
sub auth_nofriend{

my($file,$flag);
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
our($action);

# �����`�F�b�N
$file = $main::in{'account'};
$file =~ s/[^0-9a-z]//g;

# ���O�C������
Mebius::LoginedCheck("Error-view");

# �A�J�E���g�t�@�C�����J��
my(%account) = Mebius::Auth::File(undef,$file);
#&open($file,"nocheck");

# �f�B���N�g����`
#my($account_directory) = Mebius::Auth::account_directory($file);
my($my_account_directory) = Mebius::Auth::account_directory($my_account->{'id'});
	if(!$my_account_directory){ die("Perl Die! Account directory setting is empty."); }

# �����̏��F�҂��t�@�C�����J��
open(MYBEFRIEND_IN,"<","${my_account_directory}$my_account->{'id'}_befriend.cgi");
while(<MYBEFRIEND_IN>){
my($account,$name) = split(/<>/,$_);
if($account eq $file){ $flag = 1 ; }
}
close(MYBEFRIEND_IN);

	# ���F�҂��t�@�C���ɖ����ꍇ
	if(!$flag){ main::error("���F�҂��łȂ������o�[�͋��ۂł��܂���B"); } 

# �o�^�ς݂��ǂ������`�F�b�N
my($yetfriend) = &checkfriend($file);
	if($yetfriend){ main::error("���̃����o�[�́A����$main::friend_tag�o�^�ς݂ł��B"); }

our $head_link4 = "&gt; $main::friend_tag����";


my $print = <<"EOM";
$main::footer_link
<h1>$main::friend_tag����</h1>
<form action="$action" method="post"$main::sikibetu>
<div>
<a href="$main::in{'account'}/">$account{'name'} - $file</a> �����$main::friend_tag���ۂ��܂��B<br>
��낵����Ή��̃{�^���������Ă��������B<br>
<input type="hidden" name="mode" value="befriend">
<input type="hidden" name="decide" value="no">
<input type="hidden" name="action" value="1">
<input type="hidden" name="account" value="$main::in{'account'}"><br>
<input type="submit" value="$main::in{'account'}�����$main::friend_tag���ۂ���"><br><br>
�������ł̓o�^�͒��ڑ���ɒʒm����܂���B�\\�����̂��̂��~�߂�ɂ�<a href="$basic_init->{'auth_url'}?mode=befriend&amp;decide=deny&amp;account=$file">�֎~�ݒ�</a>�������Ȃ��Ă��������B
</div></form>
$main::footer_link2
EOM


Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-------------------------------------------------
# �}�C���r���ۂ̎��s
#-------------------------------------------------
sub auth_action_nofriend{

# �錾
my($type) = @_;
my($my_account) = Mebius::my_account();

	# �f�d�s���M���u���b�N
	if($ENV{'REQUEST_METHOD'} ne "POST"){ main::error("�f�d�s���M�͏o���܂���B"); }

# ���O�C������
Mebius::LoginedCheck("Error-view");

# ����̃A�J�E���g�t�@�C�����J��
my(%account) = Mebius::Auth::File("Option File-check-error",$main::in{'account'});

# �����́y���F�҂��t�@�C���z���X�V
Mebius::Auth::ApplyFriendIndex("Delete-apply Renew",$main::myaccount{'file'},$account{'file'});

# ����́y���F�҂��t�@�C���z���X�V
Mebius::Auth::ApplyFriendIndex("Delete-apply Renew",$account{'file'},$main::myaccount{'file'});

# �����́y�}�C���r��ԁz���X�V����
Mebius::Auth::FriendStatus("Delete-apply Renew",$main::myaccount{'file'},$account{'file'});

# ����́y�}�C���r��ԁz���X�V����
Mebius::Auth::FriendStatus("Delete-apply Renew",$account{'file'},$my_account->{'file'});

# �y�[�W�W�����v
Mebius::Redirect(undef,"$my_account->{'profile_url'}aview-befriend");

exit;



}


#-------------------------------------------------
# �}�C���r�ҏW�̃y�[�W
#-------------------------------------------------
sub auth_editfriend{

# �Ǐ���
my($file,$flag,$link1,$admin_text);
my($edit_intro);
my($init_befriend) = Mebius::Auth::init_befriend();
my($my_account) = Mebius::my_account();
our($action);

# �Љ�̍ő啶����(�S�p)
#our $max_intro = 500;

# ���O�C������
Mebius::LoginedCheck("Error-view");

# �Ǝ�CSS
our $css_text .= qq(
.stextarea{width:95%;height:10em;}
.max_intro{color:#f00;font-size:90%;}
);

# �t�@�C�����`�i�P�j
$file = $main::in{'account'};
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ main::error("���胁���o�[���w�肵�Ă��������B"); }

# �t�@�C�����`�i�Q�j
my $myfile = $main::in{'myaccount'};
$myfile =~ s/[^0-9a-z]//g;
if($myfile eq ""){ main::error("�������w�肵�Ă��������B"); }

# �f�B���N�g����`
#my($account_directory) = Mebius::Auth::account_directory($file);
my($my_account_directory) = Mebius::Auth::account_directory($main::in{'myaccount'});
	if(!$my_account_directory){ die("Perl Die! Account directory setting is empty."); }

# �����łȂ��ꍇ
if(!$my_account->{'admin_flag'} && $myfile ne $my_account->{'id'}){ main::error("���̃����o�[��$main::friend_tag�͕ҏW�ł��܂���B"); }
if($my_account->{'admin_flag'} && $myfile ne $my_account->{'id'}){ $admin_text = qq(<strong class="red">���Ǘ��҂Ƃ��Đݒ肵�܂��B</strong><br>); }

open(MYFRIEND_IN,"<","${my_account_directory}${myfile}_friend.cgi");
while(<MYFRIEND_IN>){
my($key,$account,$name,$intro) = split(/<>/,$_);
if($file eq $account){ $edit_intro = $intro; $edit_intro =~ s/<br>/\n/g; $flag = 1; }
}
close(MYFRIEND_IN);

if(!$flag){ main::error("���̃����o�[��$main::friend_tag�o�^����Ă��܂���B"); }

# �v���t�B�[�����J��
my(%account) = Mebius::Auth::File("File-check-error",$file);

# �^�C�g����`
our $head_link4 = "&gt; $main::friend_tag�ҏW : $account{'handle'} - $file";
$main::sub_title = qq($account{'handle'}�̕ҏW);


my $link1 = "$file/";

my $print = <<"EOM";
$main::footer_link
<h1>$main::friend_tag�ҏW - $account{'handle'}����</h1>

<h2>�Љ�̕ҏW</h2>

$admin_text
��<a href="$link1">$account{'handle'} - $file</a>������Љ�镶�͂������Ă��������i�D�����l�A�ʔ����l�Ȃǁj�B<br>
<br>

<form action="$action" method="post"$main::sikibetu>
<div>
<textarea name="intro" class="stextarea">$edit_intro</textarea><br>
<input type="hidden" name="mode" value="befriend">
<input type="hidden" name="decide" value="intro">
<input type="hidden" name="account" value="$file">
<input type="hidden" name="myaccount" value="$myfile">
<input type="hidden" name="action" value="1">
<input type="submit" value="�Љ��ҏW����" class="isubmit">
�@<strong class="max_intro">�i�S�p$init_befriend->{'max_length_intro'}�����܂Łj</strong>
</div>
</form>

<h2>$main::friend_tag����</h2>

<form action="$action" method="post"$main::sikibetu>
<div>

<input type="hidden" name="mode" value="befriend">
<input type="hidden" name="decide" value="delete">
<input type="hidden" name="account" value="$file">
<input type="hidden" name="action" value="1">
<a href="$link1">$account{'handle'} - $file</a> ����Ƃ�$main::friend_tag�o�^���������܂��B��낵���ł����H�@
<br$main::xclose><br$main::xclose>


<input type="checkbox" name="check" value="1" id="friend_off"><label for="friend_off">�͂��A�o�^���������܂��B</label> <br><br>

<input type="submit" value="$file����Ƃ�$main::friend_tag�o�^����������">

</div>
</form>
$main::footer_link2
EOM


Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}


#-------------------------------------------------
# �Љ�ύX�̎��s
#-------------------------------------------------
sub auth_action_introfriend{

# �Ǐ���
my($file,$line,$pline,$flag);
my($myfriend_handler,%renew);
my($init_befriend) = Mebius::Auth::init_befriend();
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
our($jump_url);

# �A�N�Z�X����
main::axscheck("Post-only Login-check");

	# �A�J�E���g���b�N��
	if($my_account->{'key'} eq "2" && $main::in{'intro'} !~ /^((\s|�@|<br>)+)?$/){
		main::error("�A�J�E���g���b�N���́A�Љ�����S�ɍ폜����ȊO�̕ύX�͏o���܂���B");
	}

# �t�@�C�����`�i�P�j
$file = $main::in{'account'};
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ main::error("���胁���o�[���w�肵�Ă��������B"); }

# �t�@�C�����`�i�Q�j
my $myfile = $main::in{'myaccount'};

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$myfile)){ main::error("�����̃A�J�E���g�����Ԉ���Ă��܂��B"); }
	if($myfile eq ""){ main::error("�������w�肵�Ă��������B"); }

	# �����łȂ��ꍇ
	if(!$my_account->{'admin_flag'} && $myfile ne $my_account->{'id'}){ main::error("���̃����o�[��$main::friend_tag�͕ҏW�ł��܂���B"); }

# �G���[���̃t�b�N
our $fook_error = qq(���͓��e�F $main::in{'intro'});

# �e��G���[
require "${main::int_dir}regist_allcheck.pl";
($main::in{'intro'}) = &all_check(undef,$main::in{'intro'});
main::error_view("ERROR");

	# �Љ����������ꍇ
	if(length($main::in{'intro'}) > $init_befriend->{'max_length_intro'}*2){ main::error("�Љ���������܂��B�S�p$init_befriend->{'max_length_intro'}�����܂łɎ��߂Ă��������B"); }

# ����̃A�J�E���g�����Ȃ��ꍇ
if($file eq ""){ main::error("������w�肵�Ă��������B"); }

# ����̃v���t�B�[�����I�[�v��
my(%account) = Mebius::Auth::File(undef,$file);

# ���b�N�J�n
&lock("friend");

# �Љ�̕ύX ( �����̃}�C���r�t�@�C�� )
$renew{'account'} = $file;
$renew{'intro'} = $main::in{'intro'};
Mebius::Auth::FriendIndex("Renew Change-introduction",$myfile,%renew);

my %renew_target;
$renew_target{'account'} = $myfile;
$renew_target{'be_intro'} = $main::in{'intro'};
Mebius::Auth::FriendIndex("Renew Change-be-introductioned",$account{'file'},%renew_target);

# �Љ�̕ύX ( ����̃}�C���r�t�@�C�� )
my %renew_target;
$renew_target{'account'} = $myfile;
$renew_target{'be_intro'} = $main::in{'intro'};
Mebius::Auth::FriendIndex("Renew Change-be-introduction",$account{'file'},%renew_target);

	# ����A�J�E���g�� �u�ŋ߂̍X�V�v�t�@�C�����X�V
	if(!$account{'myprof_flag'} || Mebius::alocal_judge()){
		Mebius::Auth::News("Renew Log-type-edit_introduction",$file,$myfile,$main::myaccount{'handle'},qq(<a href="$basic_init->{'auth_url'}$myfile/aview-friend#F_$file">�Љ�̕ύX</a>));
	}

# SNS�������X�V
Mebius::Auth::History("Renew",$my_account->{'id'},$file,qq(��<a href="$basic_init->{'auth_url'}$my_account->{'id'}/aview-friend#F_$file">�Љ</a>��ύX���܂����B));

# ���b�N����
&unlock("friend");

# �y�[�W�W�����v
Mebius::Redirect(undef,"$my_account->{'profile_url'}aview-friend");
;

# �����I��
exit;


}

#-------------------------------------------------
# �}�C���r�폜 ( �o�^���� ) �̎��s
#-------------------------------------------------
sub auth_action_deletefriend{

# �錾
my($file,$line,$line3);
my(%renew_friend_index1,%renew_friend_index2);
my($my_account) = Mebius::my_account();
my $operate = new Mebius::Operate;

	# �`�F�b�N�������Ă��Ȃ��ꍇ
	if(!$main::in{'check'}){
		main::error("$main::friend_tag�o�^����������ɂ́A�`�F�b�N�����Ă��������B");
	}

# ���O�C������
Mebius::LoginedCheck("Error-view");

# ����̃A�J�E���g�t�@�C�����J��
my(%account) = Mebius::Auth::File("Option File-check-error",$main::in{'account'});

# ���b�N�J�n
main::lock("friend");

# ���݂��̃}�C���r�́A����ƃ}�C���r�ɂȂ������m�点���폜���� ( A- 1 )
Mebius::Auth::FriendIndex("Tell-cancel-friend",$my_account->{'file'},$account{'file'});
Mebius::Auth::FriendIndex("Tell-cancel-friend",$account{'file'},$my_account->{'file'});

# �����̃}�C���r�t�@�C�����X�V ( A- 2 )
$renew_friend_index1{'account'} = $account{'file'};
Mebius::Auth::FriendIndex("Delete-friend Renew",$my_account->{'file'},%renew_friend_index1);

# ����̃}�C���r�t�@�C�����X�V ( A- 2 )
$renew_friend_index2{'account'} = $my_account->{'file'};
Mebius::Auth::FriendIndex("Delete-friend Renew",$account{'file'},%renew_friend_index2);


# ���݂��̃}�C���r�t�@�C���~�Q���X�V
Mebius::Auth::FriendStatus("Renew Delete-friend",$my_account->{'file'},$account{'file'});
Mebius::Auth::FriendStatus("Renew Delete-friend",$account{'file'},$my_account->{'file'});


	# �A�J�E���g�t�@�C�����X�V
	{
		my @my_account_friends = $operate->delete_element_near_array($my_account->{'friend_accounts'},$main::in{'account'});
		my @target_account_friends = $operate->delete_element_near_array($account{'friend_accounts'},$my_account->{'id'});

		Mebius::Auth::File("Renew",$my_account->{'id'},{ friend_accounts => "@my_account_friends" });
		Mebius::Auth::File("Renew",$main::in{'account'},{ friend_accounts => "@target_account_friends" });
	}

# ���b�N����
main::unlock("friend");

# �}�C�v���t�փW�����v
main::auth_jumpme();

my $print = qq($account{'name_link'}����Ƃ�$main::friend_tag�o�^���������܂����B<a href="$main::jump_url">�}�C�A�J�E���g</a>�ֈړ����܂��B);

Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}


#-------------------------------------------------
# �֎~�ݒ�̃y�[�W
#-------------------------------------------------
sub auth_denyfriend{

# �Ǐ���
my($file,$flag,$stop1,$text1);
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
our($action);

# �����̃A�J�E���g�f�[�^
	if(!$my_account->{'login_flag'}){ main::error("���̃y�[�W�̓��O�C�����Ă��Ȃ��Ǝg���܂���B",401); }

# ����̃v���t�B�[�����J��
my(%account) = Mebius::Auth::File("Option File-check-error Get-friend-status",$main::in{'account'},%$my_account);

# �����Ɍ����Ă͎��s�ł��Ȃ�
if($account{'friend_status_to'} eq "me"){ main::error("�����͋֎~�ݒ�ł��܂���B"); }

# �A�J�E���g��
my $viewaccount = $account{'id'};
	if($account{'id'} eq "none"){ $viewaccount = "****"; }

	# ���ɋ֎~�ς݂̏ꍇ
	if($account{'friend_status_from'} eq "deny"){
		$text1 = qq(
		$account{'name_link'} ����͊��ɋ֎~�ݒ蒆�ł��B<br$main::xclose><br$main::xclose>
		$account{'name_link'} ����ւ̋֎~�ݒ��<strong style="color:#00f;">����</strong> ����ƁA<a href="$basic_init->{'auth_url'}$file">$account{'name'} - $viewaccount</a> ����͂��Ȃ��̓��L�A�`�����֏������߂�悤�ɂȂ�܂��B
		<br><br>);
	}
	# �܂��֎~���Ă��Ȃ��ꍇ
	else{
		$text1 = qq(
		<strong style="color:#f00;">�֎~�ݒ�</strong> ����ƁA$account{'name_link'} ����͂��Ȃ��̓��L�A�`�����֏������߂Ȃ��Ȃ�A���b�Z�[�W��L�̑��M���֎~����܂��B�i�{���͉\\�j�B
		<br><br>);
	}

# �^�C�g����`
our $head_link4 = "&gt; �֎~�ݒ� : $account{'name'} - $viewaccount";


# �g�s�l�k
my $print = <<"EOM";
$main::footer_link
<h1$main::kstyle_h1>�֎~�ݒ�</h1>

<h2$main::kstyle_h2>�ҏW</h2>
<form action="$action" method="post"$main::sikibetu>
<div class="line-height">
<input type="hidden" name="mode" value="befriend">
<input type="hidden" name="decide" value="deny">
<input type="hidden" name="account" value="$account{'file'}">
<input type="hidden" name="action" value="1">
$text1
��낵���ł����H�@

<input type="checkbox" name="check" value="1" id="deny_yes"> <label for="deny_yes">�͂��B</label><br><br>
<input type="submit" value="$viewaccount������֎~�ݒ肷��">

</div>
</form>
<br>
$main::footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}

package Mebius::Auth;

#-------------------------------------------------
# �֎~�ݒ�����s
#-------------------------------------------------
sub DenyFriend{

# �錾
my($line,$friend_handler,%renew,%renew_myaccount);
my($my_account) = Mebius::my_account();

# �`�F�b�N�������Ă��Ȃ��ꍇ
if(!$main::in{'check'}){ main::error("���s����ɂ́A�K�v�ȃ`�F�b�N�����Ă��������B"); }

# �A�N�Z�X����
main::axscheck("Post-only Login-check");

# ����̃A�J�E���g�t�@�C�����J��
my(%account) = Mebius::Auth::File("Option File-check-error Key-check-error",$main::in{'account'});

# �f�B���N�g����`
my($my_account_directory) = Mebius::Auth::account_directory($main::myaccount{'file'});
	if(!$my_account_directory){ die("Perl Die! Account directory setting is empty."); }

# �����`�F�b�N
my $file = "${my_account_directory}friend/$account{'file'}_f.cgi";

	# �����Ɍ����Ă͎��s�ł��Ȃ�
	if($account{'file'} eq $my_account->{'id'}){ main::error("�����͋֎~�ݒ�ł��܂���B"); }

# �֎~�󋵂𒲍�
my($friend_status) = Mebius::Auth::FriendStatus("",$main::myaccount{'file'},$account{'file'});

	# �}�C���r�̏ꍇ
	if($friend_status eq "friend"){ main::error("�ݒ肷��ɂ́A��x$main::friend_tag�o�^���������Ă��������B"); }

	# �֎~�ݒ����������ꍇ
	if($friend_status eq "deny"){

		# �����̃}�C���r�t�@�C�����폜
		unlink($file);

		# �I�v�V�����t�@�C���̍X�V�l
		#$renew{'plus->denied_count'} = -1;
		#$renew_myaccount{'plus->deny_count'} = -1;
		$renew{'-'}{'denied_count'} = 1;
		$renew_myaccount{'-'}{'deny_count'} = 1;

	}

	# �֎~�ݒ������ꍇ
	else{

		# �����̃}�C���r��Ԃ��X�V ( ���ۏ�Ԃ� )
		Mebius::Auth::FriendStatus("Renew Deny-friend",$main::myaccount{'file'},$account{'file'});

		# ����̃}�C���r��Ԃ��X�V ( �\�����̏ꍇ�͎����� )
		Mebius::Auth::FriendStatus("Renew Delete-apply",$account{'file'},$main::myaccount{'file'});

		# �����̏��F�҂��t�@�C�����X�V ( �\�����폜 )
		Mebius::Auth::ApplyFriendIndex("Delete-apply Renew",$main::myaccount{'file'},$account{'file'});

		# ����̏��F�҂��t�@�C�����X�V ( �\�����폜 )
		Mebius::Auth::ApplyFriendIndex("Delete-apply Renew",$account{'file'},$main::myaccount{'file'});

		# �I�v�V�����t�@�C���̍X�V�l
		#$renew{'plus->denied_count'} = +1;
		#$renew_myaccount{'plus->deny_count'} = +1;
		$renew{'+'}{'denied_count'} = 1;
		$renew_myaccount{'+'}{'deny_count'} = 1;

	}


# ����̃A�J�E���g���X�V
#Mebius::Auth::Optionfile("Renew",$account{'file'},%renew);
Mebius::Auth::File("Renew Option",$account{'file'},\%renew);

# �����̃A�J�E���g���X�V
#Mebius::Auth::Optionfile("Renew",$main::myaccount{'file'},%renew_myaccount);
Mebius::Auth::File("Renew Option",$main::myaccount{'file'},\%renew_myaccount);

# �W�����v
$main::jump_sec = $main::auth_jump;
$main::jump_url = qq($account{'file'}/);


# �g�s�l�k
my $print = qq(�֎~�ݒ��ύX���܂����B<a href="$main::jump_url">�v���t�B�[���y�[�W</a>�ֈړ����܂��B);

Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}

#-----------------------------------------------------------
# ���肩��̏Љ�t�@�C�� ( ������ )
#-----------------------------------------------------------
sub BeIntroductionedFile{

# �錾
my($type,$account,$from_account) = @_;
my(undef,undef,undef,$new_from_handle,$new_introduction_comment) = @_ if($type =~ /New-introduction/);
my($i,@renew_line,%data,$file_handler);

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �t�@�C����`
my $directory1 = $account_directory;
my $file1 = "${directory1}${account}_beintroductioned.log";

	# �t�@�C�����J��
	if($type =~ /File-check-error/){
		open($file_handler,"<$file1") || main::error("�t�@�C�������݂��܂���B");
	}
	else{
		open($file_handler,"<$file1");
	}


	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($file_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$file_handler>);
($data{'key'}) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$file_handler>){

		# ���E���h�J�E���^
		$i++;
		
		# ���̍s�𕪉�
		chomp;
		my($key2,$from_account2,$from_handle2,$introduction_comment2) = split(/<>/);

			# �d���֎~
			if($type =~ /Renew/){
					if($from_account2 eq $from_account){ next; }
			}

			# �s��ǉ�
			if($type =~ /Renew/){
				push(@renew_line,"$key2<>$from_account2<>$from_handle2<>$introduction_comment2<>\n");
			}

	}

close($file_handler);


	# �V�K�Љ��ǉ�
	if($type =~ /New-introduction/){
		unshift(@renew_line,"<>$from_account<>$new_from_handle<>$new_introduction_comment<>\n");
	}

	# �t�@�C���X�V
	if($type =~ /Renew/){

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory1);

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$data{'key'}<>\n");

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);

}

package main;

#-------------------------------------------------
# �}�C�v���t�ւ̃W�����v
#-------------------------------------------------

sub auth_jumpme{

my($url);
my($my_account) = Mebius::my_account();
our $jump_sec = our $auth_jump;

$url = "$my_account->{'id'}/$_[0]";
our $jump_url = "$url";

}

1;


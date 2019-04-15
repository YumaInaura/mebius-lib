
use strict;
use Mebius::SNS::Crap;
package Mebius::Auth;

#-----------------------------------------------------------
# �����ˁI���[�h
#-----------------------------------------------------------
sub CrapStart{

# �錾
my($type) = @_;
my $select_account = shift;
my $diary_number = shift;
my($redirect_url,$plustype_crap,$not_renew_ranking_flag);


	# ���O�C���`�F�b�N
	Mebius::LoginedCheck("Error-view");

	# �A�N�Z�X����
	main::axscheck("ACCOUNT");

	# ����̃t�@�C�����J��
	my(%account) = Mebius::Auth::File("File-check-error",$select_account);

	# �����ˁI�̋��ېݒ���`�F�b�N
	if(!$account{'allow_crap_diary_flag'}){ main::error("���̃����o�[�͂����ˁI�������Ă��܂���B"); }

	# �����̃A�J�E���g��Char�`�F�b�N
	Mebius::Auth::CharCheck("Error-view");

	# ���L���J��
	my($diary) = Mebius::Auth::diary("Level-check-error Crap-check",$account{'file'},$diary_number);

	# �����ˁI�����L���O�ɓo�^�֎~���Ă���ꍇ
	if($diary->{'not_crap_ranking_flag'}){ $not_renew_ranking_flag = 1; }

	# ���݂��̃}�C���r��� / �֎~��Ԃ��`�F�b�N
	my($friend_status1) = Mebius::Auth::FriendStatus("Deny-check-error",$account{'file'},$main::myaccount{'file'});
	my($friend_status2) = Mebius::Auth::FriendStatus("Deny-check-error",$main::myaccount{'file'},$account{'file'});

	# �}�C���r�����ɓ��L�����J���Ă���ꍇ ( �����L���O�ɓo�^���Ȃ�)
	if($account{'osdiary'} eq "2" && $friend_status1 ne "friend"){ main::error("$main::friend_tag�ȊO�͂����ˁI�ł��܂���B"); }
	if($account{'osdiary'} eq "2"){ $not_renew_ranking_flag = 1; }

	# �Ώۃt�@�C��
	if($main::in{'target'} eq "diary"){
		$plustype_crap .= qq( Diary-file); 
		$redirect_url = "${main::auth_url}$account{'file'}/d-$diary_number";
	}
	else{
		main::error("�����ˁI�^�C�v��I��ł��������B");
	}

	# ���s�^�C�v

	# �V�K�����ˁI
	if($main::in{'action_type'} eq "new_crap"){
		$plustype_crap .= qq( New-crap); 
			if($select_account eq $main::myaccount{'file'} && !$main::alocal_mode){ main::error("�����ɂ͂����ˁI�ł��܂���B"); }
	}
	# �����ˁI�̍폜
	elsif($main::in{'action_type'} eq "delete_crap"){

		$plustype_crap .= qq( Delete-crap); 

			# �e��G���[
			if($main::in{'target_account'} eq ""){ main::error("�폜�ΏۂƂȂ�A�J�E���g��I��ł��������B"); }

			# �폜�����`�F�b�N
			if($main::in{'target_account'} ne $main::myaccount{'file'} && $account{'file'} ne $main::myaccount{'file'} && !$main::myadmin_flag){
				main::error("���̂����ˁI���폜���錠��������܂���B");
			}

	}
	# ����ȊO
	else{
		main::error("���s�^�C�v��I��ł��������B");
	}

	# �����ˁI�����s
	my(%crap) = Mebius::Auth::Crap("Renew $plustype_crap",$account{'file'},$diary_number,$main::in{'target_account'});

	# �V�����
	if($main::in{'action_type'} eq "new_crap"){
		Mebius::Auth::News("Renew Log-type-crap",$account{'file'},$main::myaccount{'file'},$main::myaccount{'handle'},qq(<a href="${main::auth_url}$account{'file'}/d-$diary_number">$diary->{'subject'}</a> �ւ̂����ˁI ($crap{'count'})));
	}

	# ���L�̓��t���Z�o
	my(%time) = Mebius::Getdate("Get-hash",$diary->{'posttime'});

		# �����̓��L����Ȃ��ꍇ�́A�����L���O�o�^���Ȃ�
		#if($time{'ymdf'} ne $main::ymdf){ $not_renew_ranking_flag = 1; }

	# �����ˁI�����L���O���X�V
	if($main::in{'action_type'} eq "new_crap" && !$not_renew_ranking_flag){
		Mebius::Auth::CrapRankingDay("New-crap Renew",$time{'yearf'},$time{'monthf'},$time{'dayf'},$crap{'count'},$account{'file'},$diary_number,$diary->{'subject'});
	}

	# �����ˁI�����L���O���X�V ( �����ˁI���폜������ )
	if($main::in{'action_type'} eq "delete_crap" && !$not_renew_ranking_flag){
		Mebius::Auth::CrapRankingDay("Delete-crap Renew",$time{'yearf'},$time{'monthf'},$time{'dayf'},$crap{'count'},$account{'file'},$diary_number,$diary->{'subject'});
	}

	# �����̃I�v�V�����t�@�C�����X�V ( �����炭�ŏI�����������L�^���Ă��� )
	#Mebius::Auth::Optionfile("Renew My-file",$main::myaccount{'file'});
	Mebius::Auth::File("Renew My-file Option",$main::myaccount{'file'});

	# ���_�C���N�g
	Mebius::Redirect(undef,$redirect_url);


exit;

}

#-----------------------------------------------------------
# �����ˁI�ꗗ��\��
#-----------------------------------------------------------
sub CrapIndexViewStart{

# �錾
my($type,$yearf,$monthf,$dayf) = @_;
my(%crap_ranking,%crap_ranking_month,$h1_title);

	# �e��G���[
	if($yearf =~ /\D/ || $yearf eq ""){ main::error("�N���w�肵�Ă��������B"); }
	if($monthf =~ /\D/ || $monthf eq ""){ main::error("�����w�肵�Ă�������"); }
	if($dayf =~ /\D/){ main::error("���̎w�肪�ςł��B"); }
	if($main::submode_num > 3){ main::error("���̃��[�h�͑��݂��܂���B"); }

	# �����ˁI�����L���O�̓������O���擾
	if($dayf){
		(%crap_ranking) = Mebius::Auth::CrapRankingDay("Diary-file Get-topics File-check-error",$yearf,$monthf,$dayf,10);

		# �^�C�g����`
		$main::sub_title = qq($yearf�N$monthf��$dayf���̂����ˁI�����L���O | $main::title);
		$main::head_link3 .= qq(&gt; �����ˁI�����L���O);
		$main::head_link4 .= qq(&gt; $yearf�N$monthf��$dayf��);
		$h1_title = qq($yearf�N$monthf��$dayf���̂����ˁI�����L���O);

	}

	# �����ˁI�����L���O�̌��ʃ��j���[���擾
	else{
		(%crap_ranking_month) = Mebius::Auth::CrapRankingMonth("Get-index File-check-error",$yearf,$monthf);

		# �^�C�g����`
		$main::sub_title = qq($yearf�N$monthf���̂����ˁI�����L���O | $main::title);
		$main::head_link3 .= qq(&gt; �����ˁI�����L���O);
		$main::head_link4 .= qq(&gt; $yearf�N$monthf��);
		$h1_title = qq($yearf�N$monthf���̂����ˁI�����L���O);

	}

	# ���݂̓��t���O���j�b�W�W�����ɕϊ�
my($time_local) = Mebius::TimeLocal(undef,$main::submode2,$main::submode3,$main::submode4);

# ���̓��t�ƑO�̓��t���擾
#my(%tomorrow) = Mebius::Getdate("Get-hash",$time_local + (24*60*60));
#my(%yesterday) = Mebius::Getdate("Get-hash",$time_local - (24*60*60));
#<a href="./crapview-$yesterday{'ymdf'}.html">���O�̓�</a>
#<a href="./crapview-$tomorrow{'ymdf'}.html">���̓���</a>



# HTML�����o��
my $print = qq(
<h1$main::kstyle_h1>$h1_title</h1>

<h2$main::kstyle_h1>�ꗗ</h2>
<div>
$crap_ranking{'topics_line'}
$crap_ranking_month{'index_line'}
</div>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


1;


use Mebius::AuthServerMove;
use Mebius::OldCrypt;
package main;
use strict;

#-----------------------------------------------------------
# ���O�C���t�H�[��
#-----------------------------------------------------------
sub auth_login_old_view{

my($form);

main::header("Body-print");

# �t�H�[��
$form .= qq(<form action="" method="post"><div>);
$form .= qq(<input type="hidden" name="mode" value="login_check"$main::xclose>);
$form .= qq(ID<input type="text" name="authid" value=""$main::xclose>);
$form .= qq( �p�X���[�h<input type="password" name="passwd1" value=""$main::xclose>);
$form .= qq( <input type="submit" value="���O�C���`�F�b�N"$main::xclose>);
$form .= qq(</form></div>);

$form .= qq(���O�C���ł��Ȃ����̐�p�t�H�[���ł��B���̃t�H�[���Ŏ��s���\\������Ă��A�ʏ�̃��O�C���t�H�[���ł̓��O�C���o����ꍇ������܂��B);
print $form;

main::footer("Body-print");

}

#-------------------------------------------------
# ���O�C��
#-------------------------------------------------
sub auth_login_old{

# �Ǐ���
my($basic_init) = Mebius::basic_init();
my($file,$line,$xiptop1,$line_ses,$encpass,$ises);
my($encpass1,$encpass2,$text,$hashed_password_type,$login_success_flag);
our(%in);

# �z�X�g�����擾
my($gethost) = Mebius::GetHostWithFile();
my $host = $gethost;

# �O�̂��߃A�N�Z�X����
main::axscheck();

# �啶������������
$in{'authid'} = lc $in{'authid'};

# ���N���C�A
require "${main::int_dir}auth_index.pl";

	# �f�d�s���M���֎~
	if(!$main::postflag){ &error("�f�d�s���M�͏o���܂���B"); }

# ���O�C���̃g���C�񐔂��`�F�b�N
my($login_missed) = Mebius::Login::TryFile("Get-hash Auth-file By-form",$main::xip);

	# �����̃��O�C�����s��������𒴂��Ă���ꍇ�A�������ɃG���[��
	if($login_missed->{'error_flag'}){
		Mebius::Auth::Index("Error-browse",$login_missed->{'error_flag'});
	}

# ��{�G���[
my($account_name_error) = Mebius::Auth::AccountName("",$main::in{'authid'});
	if($account_name_error){ Mebius::Auth::Index("Error-browse",$account_name_error); }

# �A�J�E���g��
$file = $in{'authid'};

# �^�C�g���Ȃǒ�`
$main::head_link3 = qq(&gt; ���O�C��);

	# �e��G���[
	if($main::in{'passwd1'} eq ""){ Mebius::Auth::Index("Error-browse","�p�X���[�h����͂��Ă��������B"); }

# �A�J�E���g�t�@�C�����J��
my(%account) = Mebius::Auth::File("Not-file-check",$file);

# �p�X���[�h�̃G���R�[�h
($encpass1) = Mebius::OldCrypt("Crypt",$main::in{'passwd1'},$account{'salt'});
($encpass2) = Mebius::OldCrypt("MD5",$main::in{'passwd1'},$account{'salt'});


	# ��Crypt��MD5�A2��ނ̕����Ńp�X���[�h���ƍ�
	if($encpass1 eq $account{'pass'}){
		$login_success_flag = 1;

	}
	elsif($encpass2 eq $account{'pass'}){
		$login_success_flag = 1;
		$hashed_password_type = "MD5";
	}
	# ���p�X���[�h�ƍ� ( �V���� )
	else{
		my($login_success_flag_new,$crypted_password,$collation_type) = Mebius::Auth::Password("Collation-password",$main::in{'passwd1'},$account{'salt'},$account{'pass'});
			if($login_success_flag_new){
				$login_success_flag = 1;
				$hashed_password_type = "$collation_type (�V)";
			}
	}
	

# ���O���L�^
my $log_line;
$log_line .= qq(����: $login_success_flag\n);
$log_line .= qq(Crypt Old: $encpass1\n);
$log_line .= qq(MD5 Old: $encpass2\n);
$log_line .= qq(Account Hashed Password : $account{'pass'}\n);
$log_line .= qq(Account Salt: $account{'salt'}\n);
$log_line .= qq(Input password: $main::in{'passwd1'}\n);
$log_line .= qq(Account Salt: $account{'salt'}\n);
$log_line .= qq(Account: $basic_init->{'auth_url'}$file/\n);
Mebius::AccessLog(undef,"Account-old-type-password-collation",$log_line);

	# �����O�C���Ɏ��s�����ꍇ
	if(!$login_success_flag){

		# �����̃��O�C�����s�񐔂𑝂₷
		Mebius::Login::TryFile("Renew Login-missed Auth-file By-form",$main::xip,$main::in{'authid'},$main::in{'passwd1'});
		main::error(qq(�p�X���[�h�A�܂��̓A�J�E���g�� ( <a href=\"$basic_init->{'auth_url'}$in{'authid'}/\">$in{'authid'}</a> ) ���Ԉ���Ă��܂��B));
	}

	# ����
	else{
		# �w�b�_
		main::header("Body-print");

		# HTML
		print qq(�p�X���[�h�͍����Ă��܂��B<a href="$basic_init->{'auth_url'}">�ʏ�̃��O�C���t�H�[��</a>�œ����A�J�E���g��/�p�X���[�h����͂��Ă��������B);

		# �t�b�^
		main::footer("Body-print");
	}

# �I��
exit;

}


1;


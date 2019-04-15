
use Mebius::AuthServerMove;
use Mebius::Login;
package main;
use strict;

#-------------------------------------------------
# ���O�C��
#-------------------------------------------------
sub auth_login{

# ��{�ݒ���擾
my($basic_init) = Mebius::basic_init();
my($init_directory) = Mebius::BaseInitDirectory();
my($param) = Mebius::query_single_param();
my $html = new Mebius::HTML;
my($account,$line,$xiptop1,$line_ses,$encpass,$ises);
my($encpass1,$encpass2,$text,$login_success_flag,$crypted_password,$collation_type,$jump_sec,$jump_url);
require "${init_directory}auth_makeid.pl";

my @all_domains = Mebius::all_domains();

# �z�X�g�����擾
my($gethost) = Mebius::GetHostWithFile();
my($host) = Mebius::get_host();

# �啶������������
my $account = lc $param->{'authid'};

# ��{�G���[
my($account_name_error) = Mebius::Auth::AccountName("",$account);
	if($account_name_error){ Mebius::Auth::Index("Error-browse",$account_name_error); }


	# ���O�C����̃y�[�W��
	if($param->{'logined'}){ main::logined(); }

	# �f�d�s���M���֎~
	if($ENV{'REQUEST_METHOD'} ne "POST"){ &error("GET���M�͏o���܂���B"); }

# ���O�C���̃g���C�񐔂��`�F�b�N
my($login_missed) = Mebius::Login::TryFile("Get-hash Auth-file By-form",$main::xip);

	# �����̃��O�C�����s��������𒴂��Ă���ꍇ�A�������ɃG���[��
	if($login_missed->{'error_flag'}){
		my $message = shift_jis_return($login_missed->{'error_flag'});
		Mebius::Auth::Index("Error-browse",$message);
	}


# �^�C�g���Ȃǒ�`
my $head_link3 = qq(&gt; ���O�C��);

	# �e��G���[
	if($param->{'passwd1'} eq ""){
		Mebius::Auth::Index("Error-browse","�p�X���[�h����͂��Ă��������B");
	}

# �A�J�E���g�t�@�C�����J��
# ���� Not-file-check �ɁH => �A�J�E���g�̑��݃`�F�b�N���ȈՎ��s����Ȃ��悤�ɁA�K���u�A�J�E���g�����p�X���[�h���Ԉ���Ă��܂��v�̃G���[���o�����߂�
my(%account) = Mebius::Auth::File("Not-file-check",$account);

# ���p�X���[�h�ƍ�
($login_success_flag,$crypted_password,$collation_type) = Mebius::Auth::Password("Collation-password",$param->{'passwd1'},$account{'salt'},$account{'pass'});

	# ���O���L�^
	if($login_success_flag){
		Mebius::AccessLog(undef,"Account-collation-password-succesed",qq(�A�J�E���g: $account / �ƍ��^�C�v : $collation_type ));
	}	else {
		Mebius::AccessLog(undef,"Account-collation-password-missed",qq(�A�J�E���g: $account / �ƍ��^�C�v : $collation_type ));
	}

	# �p�X���[�h�ƍ��ɐ��������ꍇ
	if($login_success_flag){

		# ���[�����M
		Mebius::Auth::SendEmail("Allow-send-all",\%account,undef,{ subject => "�A�J�E���g�Ƀ��O�C�����܂����B" , comment => "�A�J�E���g�Ƀ��O�C�����܂����B $basic_init->{'auth_url'}" });

		# �N�b�L�[���Z�b�g
		Mebius::Cookie::set_main({ account => $account , hashed_password => $crypted_password });

	}
	# ���O�C���Ɏ��s�����ꍇ
	else{

		# ���[�����M
		Mebius::Auth::SendEmail("Allow-send-all",\%account,undef,{ subject => "�A�J�E���g�ւ̃��O�C���Ɏ��s���܂����B" , comment => "�A�J�E���g�ւ̃��O�C���Ɏ��s���܂����B $basic_init->{'auth_url'}" });

		# �����̃��O�C�����s�񐔂𑝂₷
		Mebius::Login::TryFile("Renew Login-missed  Auth-file By-form",$main::xip,$account,$main::in{'passwd1'});

		# �G���[��\������
		Mebius::Auth::Index("Error-browse",qq(�p�X���[�h�A�܂��̓A�J�E���g�� ( <a href=\"$basic_init->{'auth_url'}$account/\">$account</a> ) ���Ԉ���Ă��܂��B�i<a href=\"$basic_init->{'guide_url'}%A4%E8%A4%AF%A4%A2%A4%EB%BC%C1%CC%E4%A1%CA%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A1%CB\">���悭���鎿��</a>�j
		<br>�啶��/�������̈Ⴂ�Ȃǂɒ��ӂ��āA�������p�X���[�h�E�A�J�E���g������͂��Ă��������B
		<br><br>���A�J�E���g����������Ȃ��ꍇ��<a href=\"$basic_init->{'auth_url'}aview-newac-1.html\">�A�J�E���g�ꗗ</a>���猟���ł��܂��B
		));
	}


	# ��񃍃O�C���������Ȃ��ꍇ
	if($main::in{'other'} && $main::in{'login_doned'} < $basic_init->{'number_of_domains'}){

		my($login_doned);
		$login_doned = $main::in{'login_doned'} + 1;

		my($login_form_url) = Mebius::Auth::ServerMove("All-domains",$main::server_domain);

		# ���O�C����̕���
		$text = qq(
		<form action="$login_form_url" method="post" utn>
		<div>
		������
		<input type="submit" value="���O�C������i$login_doned�j">
		�������Ă��������B
		<input type="hidden" name="authid" value="$account">);
		$text .= $html->input("hidden","passwd1");
		$text .= qq(<input type="hidden" name="mode" value="login">
		<input type="hidden" name="other" value="1">
		<input type="hidden" name="login_doned" value="$login_doned">);
		$text .= qq($main::backurl_input);
		$text .= qq(</div></form>);

	# ���O�C����A�y�[�W�W�����v $jump_sec = $auth_jump;
	} else {

		# �W�����v��
		$jump_sec = 1;
		$jump_url = qq($basic_init->{'auth_url'}$account/feed);
			foreach(@all_domains){
					if($param->{'backurl'} =~ /http:\/\/($_)\/(.+)/){
						$jump_url = $&;
					}
			}

		# ���O�C����̕���
		$text = qq(���O�C�����܂����B�i<a href="$jump_url">���i��</a>�j);

	}

Mebius::Template::gzip_and_print_all({ RefreshURL => $jump_url , RefreshSecond => $jump_sec , BCL => [$head_link3] },$text);

# �I��
exit;

}


1;


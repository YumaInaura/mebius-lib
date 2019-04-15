
use strict;
use Mebius::Getstatus;
package Mebius;

#-----------------------------------------------------------
# Not Found �G���[�y�[�W - strict
#-----------------------------------------------------------
sub ServerAlive{

my($server_access_flag,$success_flag);

	# ���T�[�o�[����̃A�N�Z�X�̂݋��e
	foreach(@main::server_addrs){
			if($main::addr eq $_){ $server_access_flag = 1; }
	}
	if(!$server_access_flag && !$main::alocal_mode){ &main::error("���̋@\�\\�͎g���܂���B"); }


	# �h���C����W�J
	foreach(@main::domains){

		# �Ǐ���
		my($success_flag,$get_status_url);

		# �������g�͒��ׂȂ�
		if($_ eq $main::server_domain){ next; }

		# �擾����URL���`
		$get_status_url = "http://$_/";

		# �X�e�[�^�X���Q�b�g
		for(1..5){

			# �X�e�[�^�X���Q�b�g
			my($status) = &Mebius::Getstatus(undef,$get_status_url);

			# ����
			if($status eq "200"){ $success_flag = 1; last; }
			else{ sleep(1); }

		}

		# 200 OK ����x���Ԃ�Ȃ������ꍇ�A���[���𑗐M
		if(!$success_flag){ &Mebius::Email(undef,$main::admin_mail_mobile,"$_ �T�[�o�[�ڑ��s��","$_ �̃T�[�o�[�ɏ�肭�q����Ȃ��悤�ł��B"); }


	}

# HTML
print "Content-type:text/html\n\n";
print qq(Server alive check was done);

exit;

}




1;

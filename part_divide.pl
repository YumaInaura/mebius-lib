
#-----------------------------------------------------------
# �A�N�Z�X�U�蕪��
#-----------------------------------------------------------
sub do_divide{

# �錾
my($url,$type) = @_;
our($int_dir,$agent,$requri,$server_domain);

	# ���^�[��
	if($url eq ""){ return; }

	# �L�^
	if($type eq "mobile"){
			if($bot_access){ Mebius::AccessLog(undef,"BOT-DIVIDE-TO-MOBILE"); }
			else{ Mebius::AccessLog(undef,"DIVIDE-TO-MOBILE"); }
	}
	if($type eq "desktop"){
			if($bot_access){ Mebius::AccessLog(undef,"BOT-DIVIDE-TO-DESKTOP"); }
			else{ Mebius::AccessLog(undef,"DIVIDE-TO-DESKTOP"); }
	}

# URL�𐮌` ( �b�� )
$url =~ s/moto=([a-z0-9]+)&//g;

# ���_�C���N�g���ď����I��
Mebius::Redirect("",$url);

exit;

}

1;

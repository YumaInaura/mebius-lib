
use strict;
package main;

#-------------------------------------------------
# �f���S�̂��ړ]�i���_�C���N�g�j
#-------------------------------------------------
sub movebbs_redirect{

# �錾
my($type,$bbs_redirect) = @_;
my($redirect_url,$type2,$No,$r);

($bbs_redirect,$type2) = split(/>/,$bbs_redirect);

	# �P��̂t�q�k�Ƀ��_�C���N�g
	if($type2 eq "simple_redirect"){
		$redirect_url = $bbs_redirect;
	}

	# �V�����f���Ƀ��_�C���N�g
	else{

		my $request_uri = $ENV{'REQUEST_URI'};
		# ���`
		$request_uri =~ s!^/!!g;
		$redirect_url = "$bbs_redirect$request_uri";
	}

# ���T�[�o�[���ǂ����`�F�b�N
my($justy_url_flag) = Mebius::Init::AllDomains({ TypeJustyCheck => 1 , URL => $redirect_url } );

	# ���_�C���N�g���s
	Mebius::Redirect("301",$redirect_url);


exit;

}

1;

